jo.require("component")
jo.require("timeout")
jo.require("hook")

RegisterNetEvent("jo_libs:client:applySkinAndClothes", function(ped, skin, clothes)
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
  ped = ped or PlayerPedId()
  jo.timeout.delay("jo_libs:client:applySkin:" .. ped, 100, function()
    jo.hook.doActions("jo_libs:applySkin:before", ped, skin)

    jo.component.applySkin(ped, skin)

    jo.hook.doActions("jo_libs:applySkinAndClothes:after", ped, skin)
  end)
end)

RegisterNetEvent("jo_libs:client:applyClothes", function(ped, clothes)
  ped = ped or PlayerPedId()
  jo.timeout.delay("jo_libs:client:applyClothes:" .. ped, 100, function()
    jo.hook.doActions("jo_libs:applyClothes:before", ped, clothes)

    jo.component.applyComponents(ped, clothes)

    jo.hook.doActions("jo_libs:applyClothes:after", ped, clothes)
  end)
end)
