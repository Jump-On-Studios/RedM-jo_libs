local function getItemsFromDB()
  local itemsWaiter = promise.new()
  MySQL.ready(function()
    local itemsDB = MySQL.query.await("SELECT * FROM items")
    local items = {}
    for i = 1, #itemsDB do
      local item = itemsDB[i]
      items[item.item] = {
        item = item.item,
        label = item.label,
        type = item.type,
        description = item.description,
        image = "nui://vorp_inventory/html/img/items/" .. item.item .. ".png"
      }
    end
    itemsWaiter:resolve(items)
  end)
  return Await(itemsWaiter)
end

jo.ready(function()
  Wait(1000)
  jo.framework.inventoryItems = getItemsFromDB()
end)

local function waitInitInventoryItems()
  while table.isEmpty(jo.framework.inventoryItems) do Wait(10) end
end

jo.ready(function()
  jo.callback.register.latent("jo_libs:server:jo_framework_getInventoryItems", function()
    waitInitInventoryItems()
    return jo.framework.inventoryItems
  end)
end)

function jo.framework:getInventoryItems()
  waitInitInventoryItems()
  return jo.framework.inventoryItems
end

-- Listener for item removed of the player inventory
RegisterNetEvent("vorp_inventory:Server:OnItemRemoved", function(data, source)
  local item = data.name
  local quantity = data.count
  local metadata = data.metadata
  TriggerEvent("jo_libs:inventory:listenerItemRemoved", source, item, { quantity = quantity, metadata = metadata }, "dropped")
end)
