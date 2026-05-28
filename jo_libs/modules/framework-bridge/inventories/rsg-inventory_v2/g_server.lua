RegisterServerEvent("rsg-inventory:server:itemRemovedFromPlayerInventory", function(source, item, data, reason, isMove)
  if reason == "moved item" and not isMove then return end
  if reason == "swapped item" then return end
  if (reason == "split item") then return end
  TriggerEvent("jo_libs:inventory:listenerItemRemoved", source, item, { quantity = data.amount, metadata = data.info }, reason)
end)
