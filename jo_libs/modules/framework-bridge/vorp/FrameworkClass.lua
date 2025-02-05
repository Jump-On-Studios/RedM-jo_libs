-------------
-- FRAMEWORK CLASS
-------------
FrameworkClass = FrameworkClass or {}
FrameworkClass.name = "VORP"
FrameworkClass.longName = "VORP Framework"
FrameworkClass.core = exports.vorp_core:GetCore()
FrameworkClass.inv = exports.vorp_inventory

local inventoriesCreated = {}

function FrameworkClass:init()
end

function FrameworkClass:get()
  return self.name
end

-------------
-- INVENTORY
-------------

function FrameworkClass:canUseItem(source, item, amount, meta, remove)
  local count = self.inv:getItemCount(source, nil, item, meta)
  if count >= amount then
    if remove then
      self.inv:subItem(source, item, amount, meta)
    end
    return true
  end
  return false
end

function FrameworkClass:registerUseItem(item, closeAfterUsed, callback)
  CreateThread(function()
    if (closeAfterUsed == nil) then closeAfterUsed = true end
    local isExist = self.inv:getItemDB(item)
    local count = 0
    while not isExist and count < 10 do
      isExist = self.inv:getItemDB(item)
      count = count + 1
      Wait(1000)
    end
    if not isExist then
      return eprint(item .. " < item does not exist in the database")
    end
    self.inv:registerUsableItem(item, function(data)
      if closeAfterUsed then
        self.inv:closeInventory(data.source)
      end
      return callback(data.source, { metadata = data.item.metadata })
    end)
  end)
end

function FrameworkClass:giveItem(source, item, quantity, meta)
  if self.inv:canCarryItem(source, item, quantity) then
    self.inv:addItem(source, item, quantity, meta)
    return true
  end
  return false
end

function FrameworkClass:createInventory(id, name, invConfig)
  inventoriesCreated[id] = {
    id = id,
    name = name,
    config = invConfig,
    inventory = {}
  }

  inventoriesCreated[id].inventory = self.inv:registerInventory({
    id = id,
    name = name,
    limit = invConfig.maxSlots,
    acceptWeapons = invConfig.acceptWeapons or false,
    shared = invConfig.shared or true,
    ignoreItemStackLimit = invConfig.ignoreStackLimit or true,
    whitelistItems = invConfig.whitelist and true or false,
  })
  for _, data in pairs(invConfig.whitelist or {}) do
    self.inv:setCustomInventoryItemLimit(id, data.item, data.limit)
  end
  return inventoriesCreated[id].inventory
end

function FrameworkClass:removeInventory(id)
  self.inv:removeInventory(id)
end

function FrameworkClass:openInventory(source, id)
  if not self.inv:isCustomInventoryRegistered(id) then
    return false, eprint(("This custom inventory doesn't exist: %s. You can create it with `jo.framework.createInventory()`."):format(tostring(id)))
  end
  return self.inv:openInventory(source, id)
end

function FrameworkClass:addItemInInventory(source, id, item, quantity, metadata)
  local user = UserClass:get(source)
  local charIdentifier = user.data.charIdentifier

  local items = {
    {
      name = item,
      amount = quantity,
      metadata = metadata
    }
  }

  return self.inv:addItemsToCustomInventory(id, items, charIdentifier)
end

function FrameworkClass:getItemsFromInventory(id)
  local invItems = self.inv:getCustomInventoryItems(id)

  local items = {}
  for i = 1, #invItems do
    items[i] = {
      id = invItems[i].id,
      amount = invItems[i].amount,
      item = invItems[i].item,
      metadata = invItems[i].metadata
    }
  end
  return items
end

return FrameworkClass
