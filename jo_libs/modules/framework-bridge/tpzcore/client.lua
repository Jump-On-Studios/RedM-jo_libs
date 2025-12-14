
AddEventHandler("tpz_inventory:setSecondaryInventoryOpenState", function(cb)

  if cb ~= false then return end
  TriggerEvent('kd_stable:client:closeSaddleBag')
end)
