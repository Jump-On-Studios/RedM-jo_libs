jo.nui = {}
local nuiLoaded = {}

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

function jo.nui.forceFocus(uiName)
  if not nuiLoaded[uiName] then return eprint("This nui is not loaded:", uiName) end
  SendNUIMessage({
    action = "jo_nui_force_focus",
    uiName = uiName
  })
end

function jo.nui.resetFocus()
  SendNUIMessage({
    action = "jo_nui_reset_focus"
  })
end
