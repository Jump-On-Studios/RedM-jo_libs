-------------
-- VARIABLES
-------------

local RSGCore = exports["rsg-core"]:GetCoreObject()
local inventoriesCreated = {}

-------------
-- INVENTORY
-------------

function jo.framework:canUseItem(source, item, amount, meta, remove)
  local Player = self.UserClass:get(source)
  local itemData = Player.data.Functions.GetItemByName(item)
  if itemData and itemData.amount >= amount then
    if remove then
      Player.data.Functions.RemoveItem(item, amount)
    end
    return true
  end
end

function jo.framework:registerUseItem(item, closeAfterUsed, callback)
  if type(closeAfterUsed) == "function" then
    callback = closeAfterUsed
    closeAfterUsed = true
  end
  local itemExists = RSGCore.Shared.Items[item] ~= nil
  if not itemExists then
    return eprint(item .. " < item does not exist in the core configuration")
  end
  RSGCore.Functions.CreateUseableItem(item, function(source, data)
    callback(source, { metadata = data.info })
    if closeAfterUsed then
      TriggerClientEvent("rsg-inventory:client:closeinv", source)
    end
  end)
end

function jo.framework:giveItem(source, item, quantity, meta)
  local Player = self.UserClass:get(source)
  return Player.data.Functions.AddItem(item, quantity, false, meta)
end

function jo.framework:createInventory(id, name, invConfig)
  inventoriesCreated[id] = {
    id = id,
    name = name,
    config = table.copy(invConfig),
    inventory = {}
  }
  -------------
  -- RSG Inventory is defined in g, not kg
  -------------
  if inventoriesCreated[id].config.maxWeight then
    inventoriesCreated[id].config.maxWeight *= 1000
  end
end

function jo.framework:openInventory(source, id)
  local config = inventoriesCreated[id].config

  TriggerClientEvent("jo_libs:client:openInventory", source, id, config)
  return
end

function jo.framework:addItemInInventory(source, invId, item, quantity, metadata, needWait)
  local waiter = promise.new()
  MySQL.scalar("SELECT items FROM stashitems WHERE stash = ?", { invId }, function(items)
    items = UnJson(items)
    if not items then items = {} end
    local slot = 1
    repeat
      local doesSlotAvailable = true
      for _, item in pairs(items) do
        if item.slot == slot then
          slot = slot + 1
          doesSlotAvailable = false
          break
        end
      end
      Wait(100)
    until doesSlotAvailable
    items[#items + 1] = {
      amount = 1,
      name = item,
      info = metadata,
      slot = slot
    }
    MySQL.insert("INSERT INTO stashitems (stash,items) VALUES (@stash,@items) ON DUPLICATE KEY UPDATE items = @items", {
      stash = invId,
      items = json.encode(items)
    }, function()
      waiter:resolve(true)
    end)
    if needWait then
      return Citizen.Await(waiter)
    end
  end)
end

function jo.framework:getItemsFromInventory(invId)
  local items = {}

  local invItems = MySQL.scalar.await("SELECT items FROM stashitems WHERE stash = ?", { invId })
  invItems = UnJson(invItems)
  for i = 1, #invItems do
    items[i] = {
      metadata = invItems[i].info,
      amount = invItems[i].amount,
      item = invItems[i].name
    }
  end
  return items
end
