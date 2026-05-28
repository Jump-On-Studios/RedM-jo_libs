-------------
-- VARIABLES
-------------
local initInventoryItemsInProcess = false

-------------
-- CORE
-------------
jo.framework:loadCoreFiles("g_shared")

-------------
-- INVENTORIES
-------------
jo.framework:loadInventoryFiles("g_shared")

---@return table (The list of items)
exports("jo_framework_getInventoryItems", function()
  while initInventoryItemsInProcess do Wait(10) end
  if table.isEmpty(jo.framework.inventoryItems) then
    initInventoryItemsInProcess = true
    jo.framework.inventoryItems = jo.framework:getInventoryItems()
    dprint("%d items inventory loaded", table.count(jo.framework.inventoryItems))
    initInventoryItemsInProcess = false
  end
  return jo.framework.inventoryItems
end)
