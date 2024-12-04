jo.nui = {}

function jo.nui.load(name, url)
  if GetResourceMetadata(GetCurrentResourceName(), "ui_page") ~= "nui://jo_libs/nui/index.html" then
    return eprint('You have to use "nui://jo_libs/nui/index.html" as your main ui_page in the fxmanifest.lua')
  end
  SendNUIMessage({
    action = "loadNUI",
    url = url,
    name = name
  })
end
