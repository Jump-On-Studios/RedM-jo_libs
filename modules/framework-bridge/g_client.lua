--Apply skin
RegisterNetEvent("rsg-appearance:client:ApplyClothes")
AddEventHandler("rsg-appearance:client:ApplyClothes", function(clothes, ped, skin)
  ped = ped or PlayerPedId()
  TriggerServerEvent("jo_libs:server:applySkinAndClothes", ped, skin, clothes)
end)

RegisterNetEvent("rdr_clothes_store:ApplyClothes")
AddEventHandler("rdr_clothes_store:ApplyClothes", function(clothes, ped, skin)
  ped = ped or PlayerPedId()
  TriggerServerEvent("jo_libs:server:applySkinAndClothes", ped, skin, clothes)
end)

RegisterNetEvent("rsg-clothes:ApplyClothes")
AddEventHandler("rsg-clothes:ApplyClothes", function(clothes, ped, skin)
  ped = ped or PlayerPedId()
  TriggerServerEvent("jo_libs:server:applySkinAndClothes'", ped, skin, clothes)
end)

RegisterNetEvent("qr-clothes:ApplyClothes")
AddEventHandler("qr-clothes:ApplyClothes", function(clothes, ped, skin)
  ped = ped or PlayerPedId()
  TriggerServerEvent("jo_libs:server:applySkinAndClothes", ped, skin, clothes)
end)

RegisterNetEvent("redemrp_clothing:load")
AddEventHandler("redemrp_clothing:load", function(clothes, ped, skin)
  ped = ped or PlayerPedId()
  TriggerServerEvent("jo_libs:server:applySkinAndClothes", ped, skin, clothes)
end)

RegisterNetEvent("rdr_creator:SkinLoaded")
AddEventHandler("rdr_creator:SkinLoaded", function(skin, ped, clothes)
  ped = ped or PlayerPedId()
  TriggerServerEvent("jo_libs:server:applySkinAndClothes", ped, skin, clothes)
end)

RegisterNetEvent("jo_libs:client:applySkinAndClothes", function(ped, skin, clothes)
  if not (jo.isModuleLoaded("component")) then
    return dprint("NO NEED skin")
  end
  ped = ped or PlayerPedId()
  jo.timeout.delay("jo_libs:client:applySkinAndClothes:" .. ped, 100, function()
    jo.hook.doActions("jo_libs:applySkinAndClothes:before", ped, skin, clothes)

    jo.component.applySkin(ped, skin)
    jo.component.applyComponents(ped, clothes)

    jo.component.refreshPed(ped)

    jo.hook.doActions("jo_libs:applySkinAndClothes:after", ped, skin, clothes)
  end)
end)

RegisterNetEvent("jo_libs:client:applySkin", function(ped, skin)
  if not (jo.isModuleLoaded("component")) then
    return
  end
  ped = ped or PlayerPedId()
  jo.timeout.delay("jo_libs:client:applySkin:" .. ped, 100, function()
    jo.hook.doActions("jo_libs:applySkin:before", ped, skin)

    jo.component.applySkin(ped, skin)

    jo.hook.doActions("jo_libs:applySkinAndClothes:after", ped, skin)
  end)
end)

RegisterNetEvent("jo_libs:client:applyClothes", function(ped, clothes)
  if not (jo.isModuleLoaded("component")) then
    return
  end
  ped = ped or PlayerPedId()
  jo.timeout.delay("jo_libs:client:applyClothes:" .. ped, 100, function()
    jo.hook.doActions("jo_libs:applyClothes:before", ped, clothes)

    jo.component.applyComponents(ped, clothes)

    jo.hook.doActions("jo_libs:applyClothes:after", ped, clothes)
  end)
end)
