jo.require("notif")
jo.require("blip")

jo.createModule("witness")

local activeBlips = {}

jo.stopped(function()
  for blip in pairs(activeBlips) do
    if DoesBlipExist(blip) then RemoveBlip(blip) end
  end
  activeBlips = {}
end)

RegisterNetEvent("jo_libs:witness:alert", function(title, message, coords, blipDuration)
  jo.notif.left(title, message, "menu_textures", "menu_icon_alert", "COLOR_RED", 10000)

  local blip = jo.blip.create(coords, title, "blip_wanted_poster")
  if not blip then return end

  activeBlips[blip] = true

  CreateThread(function()
    Wait(blipDuration or 600000)
    if DoesBlipExist(blip) then RemoveBlip(blip) end
    activeBlips[blip] = nil
  end)
end)
