jo.createModule("input")
jo.require("pricing")

local nuiResult = nil
local nuiOpened = false

--- A function to open the native input
---@param label string (The text above the typing field in the black square)
---@param placeholder string (An Example Text, what it should say in the typing field)
---@param maxStringLength? integer (Maximum String length)
---@return string (Return the text from the input)
function jo.input.native(label, placeholder, maxStringLength)
  AddTextEntry("FMMC_KEY_TIP1", label)
  DisplayOnscreenKeyboard(0, "FMMC_KEY_TIP1", "", placeholder, "", "", "", maxStringLength or 60)

  while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
    Wait(0)
  end

  if UpdateOnscreenKeyboard() ~= 2 then
    local result = GetOnscreenKeyboardResult() --Gets the result of the typing
    Wait(100)
    return result or ""
  else
    Wait(100)
    return ""
  end
end

--- A function to load the NUI.
function jo.input.loadNUI()
  jo.require("nui")
  if jo.nui.isLoaded("jo_input") then return end
  jo.nui.load("jo_input", "nui://jo_libs/nui/input/index.html")
end

--- Normalizes a column and returns a shallow copy so the caller's table is never mutated.
---@param column any The raw column sent by the caller
---@return any The normalized column
local function parseColumn(column)
  if type(column) ~= "table" then return column end

  local parsed = {}
  for key, value in pairs(column) do
    if key ~= "for" then parsed[key] = value end
  end

  if column["for"] ~= nil and parsed.target == nil then
    parsed.target = column["for"]
  end

  return parsed
end

--- Normalizes rows into the canonical object format and preserves row-level
--- metadata alongside the `columns` array.
--- The column order is preserved, so the ids the NUI derives from the indexes
--- stay stable.
---@param rows table|nil (The list of rows sent by the caller)
---@return table (The rows in the `{ columns = { ... } }` format)
local function parseRows(rows)
  if type(rows) ~= "table" then return {} end

  local parsed = {}
  for i = 1, #rows do
    local row = rows[i]
    if type(row) == "table" then
      local columns = type(row.columns) == "table" and row.columns or row
      local parsedRow = {}

      -- Copy row-level metadata before normalizing its columns.
      if columns ~= row then
        for key, value in pairs(row) do
          if key ~= "columns" then parsedRow[key] = value end
        end
      end

      parsedRow.columns = {}
      for j = 1, #columns do
        parsedRow.columns[j] = parseColumn(columns[j])
      end

      parsed[#parsed + 1] = parsedRow
    end
  end

  return parsed
end

---@description Opens the NUI input panel.
---@description Rows use `{ columns = { ... } }`. A row can be placed in the `header`, `content`, or `footer` zone; only `content` scrolls.
---@description Button entries support the `success`, `danger`, `warning`, `muted`, and `flat` classes, an optional `icon` URL, and the shared `class`, `style`, and `width` properties.
---@param options table (Options of the input.)
--- options.rows table (List of row objects. Each row contains a `columns` array.)
---     options.rows.columns table (Entries rendered in each row.)
---     options.rows.position? string (Panel zone: `header`, `content`, or `footer`. Defaults to `content`; only `content` scrolls.)
--- options.lang? table (Translation table. Only string keys prefixed with `inputNui` are sent to the NUI.)
---@param cb? function (Called with the result. When omitted, the function waits synchronously and returns the result.)
---@return table|false|nil (Result when called synchronously, `false` on cancellation, or `nil` when a callback is provided.)
function jo.input.nui(options, cb)
  if nuiOpened then return false, eprint("Input NUI is already opened") end
  nuiOpened = true
  jo.require("nui")
  if not jo.nui.isLoaded("jo_input") then
    jo.nui.load("jo_input", "nui://jo_libs/nui/input/index.html")
    Wait(500)
  end
  local keepInput = IsNuiFocusKeepingInput()
  local isFocused = IsNuiFocused()
  local function reset()
    SetNuiFocus(isFocused, isFocused)
    SetNuiFocusKeepInput(keepInput)
    nuiOpened = false
  end
  nuiResult = promise.new()

  local inputStrings = {}
  local language = type(options.lang) == "table" and options.lang or {}
  for key, value in pairs(language) do
    if type(key) == "string" and key:sub(1, 8) == "inputNui" and type(value) == "string" then
      inputStrings[key] = value
    end
  end

  SendNUIMessage({
    messageTargetUiName = "jo_input",
    event = "setStrings",
    data = inputStrings
  })

  SendNUIMessage({
    messageTargetUiName = "jo_input",
    event = "newInput",
    data = {
      rows = parseRows(options.rows)
    }
  })
  SetNuiFocus(true, true)
  SetNuiFocusKeepInput(false)
  jo.nui.forceFocus("jo_input")
  if cb then
    CreateThread(function()
      local result = Await(nuiResult)
      reset()
      cb(result)
    end)
  else
    local result = Await(nuiResult)
    reset()
    return result
  end
end

--- Convert a NUI price result into the new pricing module format.
--- The NUI outputs JSON-friendly canonical objects:
--- PriceClass payload: `{ costs = { ... } }`
--- PriceGroupClass payload: `{ operator = "or"|"and", prices = { ... } }`
---@param price table|nil The price object from the NUI result
---@return PriceClass|PriceGroupClass|nil The normalized pricing instance
local function convertNUIPrice(price)
  if not price then return price end

  if price.prices ~= nil or price.operator ~= nil then
    return jo.pricing.newGroup(price)
  end

  return jo.pricing.new(price)
end

--- NUI callback: resolves the input promise with the user's result.
--- Automatically normalizes any price-type entries with the pricing module.
--- Price entry IDs are provided by the NUI via `data.priceIds`.
RegisterNuiCallback("jo_input:click", function(data, cb)
  cb("ok")
  if data and data.result and data.priceIds then
    for i = 1, #data.priceIds do
      local id = data.priceIds[i]
      if data.result[id] then
        data.result[id] = convertNUIPrice(data.result[id])
      end
    end
    data.priceIds = nil
  end
  nuiResult:resolve(data)
end)
