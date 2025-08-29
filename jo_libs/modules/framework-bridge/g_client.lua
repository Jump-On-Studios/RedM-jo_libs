jo.require("framework-bridge")

jo.framework:loadFile("g_client")
jo.framework:loadFile("_custom", "g_client")

RegisterNetEvent("jo_libs:client:applySkinAndClothes", function(ped, skin, clothes)
  ped = ped or PlayerPedId()
  if not (jo.isModuleLoaded("component", false)) then
    return dprint("NO NEED skin. Component module is not")
  end
  jo.component.waitPedLoaded(ped)
  jo.timeout.delay("jo_libs:client:applySkinAndClothes:" .. ped, 100, function()
    jo.hook.doActions("jo_libs:applySkinAndClothes:before", ped, skin, clothes)

    jo.component.applySkin(ped, skin)
    jo.component.applyComponents(ped, clothes)

    jo.component.refreshPed(ped)

    jo.hook.doActions("jo_libs:applySkinAndClothes:after", ped, skin, clothes)
  end)
end)

RegisterNetEvent("jo_libs:client:applySkin", function(ped, skin)
  if not (jo.isModuleLoaded("component", false)) then
    return
  end
  ped = ped or PlayerPedId()
  jo.timeout.delay("jo_libs:client:applySkin:" .. ped, 100, function()
    jo.hook.doActions("jo_libs:applySkin:before", ped, skin)

    jo.component.applySkin(ped, skin)

    jo.component.refreshPed(ped)

    jo.hook.doActions("jo_libs:applySkinAndClothes:after", ped, skin)
  end)
end)

RegisterNetEvent("jo_libs:client:applyClothes", function(ped, clothes)
  if not (jo.isModuleLoaded("component", false)) then
    return
  end
  ped = ped or PlayerPedId()
  jo.timeout.delay("jo_libs:client:applyClothes:" .. ped, 100, function()
    jo.hook.doActions("jo_libs:applyClothes:before", ped, clothes)

    jo.component.applyComponents(ped, clothes)

    jo.component.refreshPed(ped)

    jo.hook.doActions("jo_libs:applyClothes:after", ped, clothes)
  end)
end)
