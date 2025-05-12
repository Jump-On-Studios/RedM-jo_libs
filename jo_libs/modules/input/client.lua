jo.input = {}

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

function jo.input.loadNUI()
  jo.require("nui")
  if jo.nui.isLoaded("jo_input") then return end
  jo.nui.load("jo_input", "nui://jo_libs/nui/input/index.html")
end

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
  log(options)
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
