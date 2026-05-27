RegisterNetEvent("inventory:OnItemRemoved", function(source, item, quantity, metadata, reason)
  TriggerEvent("jo_libs:inventory:listenerItemRemoved", source, item, { quantity = quantity, metadata = metadata }, reason)
end)
