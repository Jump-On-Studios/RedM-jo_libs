jo.nui = {}
local nuiLoaded = {}

--- Loads a NUI interface
---@param uiName string (The name of the NUI to load)
---@param url string (The URL of the NUI to load)
function jo.nui.load(uiName, url)
  if GetResourceMetadata(GetCurrentResourceName(), "ui_page") ~= "nui://jo_libs/nui/index.html" then
    return eprint('You have to use "nui://jo_libs/nui/index.html" as your main ui_page in the fxmanifest.lua')
  end
  if (url:sub(1, 1) == "@") then url = url:sub(2) end
  if (not url:find("://")) then url = "nui://" .. url end
  if nuiLoaded[uiName] then return eprint("This nui is already loaded:", uiName) end

  nuiLoaded[uiName] = true
  SendNUIMessage({
    action = "jo_nui_loadNUI",
    url = url,
    uiName = uiName,
  })
end

--- Forces focus on a specific NUI interface and don't spread events to other NUIs
---@param uiName string (The name of the NUI to focus on)
function jo.nui.forceFocus(uiName)
  if not nuiLoaded[uiName] then return eprint("This nui is not loaded:", uiName) end
  SendNUIMessage({
    action = "jo_nui_force_focus",
    uiName = uiName
  })
end

--- Resets the focus from any NUI interface and spread events
function jo.nui.resetFocus()
  SendNUIMessage({
    action = "jo_nui_reset_focus"
  })
end

--- A function to know if a nui is loaded
---@param uiName string (The name of the NUI)
---@return boolean (`true` if the nui is already loaded)
function jo.nui.isLoaded(uiName)
  return nuiLoaded[uiName] and true or false
end
