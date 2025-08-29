RegisterNetEvent("vorpcharacter:reloadedskinlistener", function()
  local source = source

  if table.count(jo.framework:getUserIdentifiers(source)) == 0 then return end --Character not selected

  local skin = jo.framework:getUserSkin(source)
  local clothes = jo.framework:getUserClothes(source)

  TriggerClientEvent("jo_libs:client:applySkinAndClothes", source, nil, skin, clothes)
end)

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

jo.callback.register.latent("jo_framework_getInventoryItems", function()
  waitInitInventoryItems()
  return jo.framework.inventoryItems
end)

function jo.framework:getInventoryItems()
  waitInitInventoryItems()
  return jo.framework.inventoryItems
end
