RegisterNetEvent("jo_libs:client:openInventory", function(name, config)
  TriggerServerEvent("inventory:server:OpenInventory", "stash", name, { maxweight = config.maxWeight, slots = config.maxSlots })
  TriggerEvent("inventory:client:SetCurrentStash", name)
end)
