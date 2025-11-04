
/*

SharedItems.item
SharedItems.label
SharedItems.weight
SharedItems.remove
SharedItems.type
SharedItems.description
SharedItems.action
SharedItems.stackable
SharedItems.droppable
SharedItems.closeInventory
*/

local function GetItemsList()
  return exports.tpz_inventory:getInventoryAPI().getSharedItems()
end

jo.ready(function()
  Wait(1000)
  jo.framework.inventoryItems = GetItemsList()
end)

local function waitInitInventoryItems()
  while table.isEmpty(jo.framework.inventoryItems) do Wait(10) end
end

jo.callback.register.latent("jo_framework_getInventoryItems", function()
  waitInitInventoryItems()
  return jo.framework.inventoryItems
end)

function jo.framework:getInventoryItems()
  waitInitInventoryItems()
  return jo.framework.inventoryItems
end

