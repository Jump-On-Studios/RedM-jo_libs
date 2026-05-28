AddEventHandler("vorp_stables:setClosedInv", function()
  TriggerServerEvent(GetCurrentResourceName() .. ":server:closeInventory")
end)
