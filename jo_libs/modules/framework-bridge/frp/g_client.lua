RegisterNetEvent("rsg-clothes:ApplyClothes", function(clothes, ped, skin)
  ped = ped or PlayerPedId()
  TriggerServerEvent("jo_libs:server:applySkinAndClothes'", ped, skin, clothes)
end)

RegisterNetEvent("jo_libs:client:openInventory", function(name, config)
  TriggerServerEvent("inventory:server:OpenInventory", "stash", name, {
    maxweight = config.maxWeight,
    slots = config.maxSlots
  })
  TriggerEvent("inventory:client:SetCurrentStash", name)
end)
