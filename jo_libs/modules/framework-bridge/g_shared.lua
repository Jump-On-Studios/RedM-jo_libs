jo.framework:loadFile("g_shared")
jo.framework:loadFile("_custom", "g_shared")

local initInventoryItemsInProcess = false

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
