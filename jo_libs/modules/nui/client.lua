jo.nui = {}
local nuiLoaded = {}

function jo.nui.load(name, url)
  if GetResourceMetadata(GetCurrentResourceName(), "ui_page") ~= "nui://jo_libs/nui/index.html" then
    return eprint('You have to use "nui://jo_libs/nui/index.html" as your main ui_page in the fxmanifest.lua')
  end
  if (url:sub(1, 1) == "@") then url = url:sub(2) end
  if (not url:find("://")) then url = "nui://" .. url end
  if nuiLoaded[url] then return eprint("This nui is already loaded:", url) end

  nuiLoaded[url] = true
  SendNUIMessage({
    action = "loadNUI",
    url = url,
    name = name
  })
end
