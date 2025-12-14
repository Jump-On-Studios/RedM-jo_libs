
-- The specified event is triggered once a secondary inventory storage is closed and when it does
-- we close the saddlebag properly, otherwise animation will be still looped and the saddlebag state will remain active.
AddEventHandler("tpz_inventory:setSecondaryInventoryOpenState", function(cb)

  if cb ~= false then return end
  TriggerEvent('kd_stable:client:closeSaddleBag')
end)
