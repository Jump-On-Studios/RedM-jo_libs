jo.createModule("input")

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

--- A function to open the nui input
---@param options table (Options of the input)
--- options.rows table (The list of rows content)
---@param cb? function (The return function. If missing, the function is syncrhonous)
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
  nuiResult = cb or promise.new()
  SendNUIMessage({
    messageTargetUiName = "jo_input",
    event = "newInput",
    data = options
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

RegisterNuiCallback("jo_input:click", function(data, cb)
  cb("ok")
  nuiResult:resolve(data)
end)

--- Convert a NUI price result into the standard Lua price format.
---@param price table|nil The price object from the NUI result
---@return table|nil The price in { {item=...}, money=X } format
function jo.input.convertPrice(price)
  if not price then return price end

  local function convertOption(opt)
    local result = {}
    if opt.items then
      for i = 1, #opt.items do
        result[#result + 1] = opt.items[i]
      end
    end
    local keys = { "money", "gold", "rol" }
    for i = 1, #keys do
      if opt[keys[i]] ~= nil then
        result[keys[i]] = opt[keys[i]]
      end
    end
    return result
  end

  if price.operator == "or" and price.options then
    local result = { operator = "or" }
    for i = 1, #price.options do
      result[#result + 1] = convertOption(price.options[i])
    end
    return result
  end

  return convertOption(price)
end
