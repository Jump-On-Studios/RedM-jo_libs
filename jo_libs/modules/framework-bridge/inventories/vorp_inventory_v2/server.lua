local Inventory = exports.vorp_inventory
jo.framework.inv = Inventory

-------------
-- VARIABLES
-------------

local inventoriesCreated = {}

-------------
-- INVENTORY
-------------

function jo.framework:canUseItem(source, item, amount, meta, remove)
  local count = Inventory:getItemCount(source, nil, item, meta)
  if count >= amount then
    if remove then
      Inventory:subItem(source, item, amount, meta)
    end
    return true
  end
  return false
end

function jo.framework:registerUseItem(item, closeAfterUsed, callback)
  if type(closeAfterUsed) == "function" then
    callback = closeAfterUsed
    closeAfterUsed = true
  end
  CreateThread(function()
    if (closeAfterUsed == nil) then closeAfterUsed = true end
    -- local isExist = Inventory:getItemDB(item)
    -- if not isExist then
    --   return eprint(item .. " < item does not exist in the database")
    -- end
    Inventory:registerUsableItem(item, function(data)
      if closeAfterUsed then
        Inventory:closeInventory(data.source)
      end
      return callback(data.source, { metadata = data.item.metadata })
    end)
  end)
end

function jo.framework:giveItem(source, item, quantity, meta)
  if Inventory:canCarryItem(source, item, quantity) then
    Inventory:addItem(source, item, quantity, meta)
    return true
  end
  return false
end

function jo.framework:createInventory(id, name, invConfig)
  inventoriesCreated[id] = {
    id = id,
    name = name,
    config = invConfig,
    inventory = {}
  }

  local invData = {
    id = id,
    name = name,
    limit = invConfig.maxSlots,
    acceptWeapons = GetValue(invConfig.acceptWeapons, false),
    shared = GetValue(invConfig.shared, true),
    ignoreItemStackLimit = GetValue(invConfig.ignoreStackLimit, true),
    whitelistItems = GetValue(invConfig.useWhitelist, invConfig.whitelist and true or false),
    UseBlackList = GetValue(invConfig.useBlackList, invConfig.blacklist and true or false),
    whitelistWeapons = GetValue(invConfig.useWeaponlist, invConfig.weaponlist and true or false),
  }

  if exports.vorp_inventory:isCustomInventoryRegistered(id) then
    exports.vorp_inventory:updateCustomInventoryData(id, invData)
    inventoriesCreated[id].inventory = exports.vorp_inventory:getCustomInventoryData(id)
  else
    inventoriesCreated[id].inventory = exports.vorp_inventory:registerInventory(invData)
  end

  if invConfig.permissions then
    for _, permission in ipairs(invConfig.permissions.allowedJobsTakeFrom or {}) do
      exports.vorp_inventory:AddPermissionTakeFromCustom(id, permission.name or permission.job, permission.grade)
    end
    for _, permission in ipairs(invConfig.permissions.allowedJobsMoveTo or {}) do
      exports.vorp_inventory:AddPermissionMoveToCustom(id, permission.name or permission.job, permission.grade)
    end
  end

  if invData.whitelistItems then
    for i = 1, #(invConfig.whitelist or {}) do
      local item = invConfig.whitelist[i]
      exports.vorp_inventory:setCustomInventoryItemLimit(id, item.name or item.item, item.limit)
    end
  end

  if invData.whitelistWeapons then
    for i = 1, #(invConfig.weaponlist or {}) do
      local weapon = invConfig.weaponlist[i]
      exports.vorp_inventory:setCustomInventoryWeaponLimit(id, weapon.name or weapon.weapon or weapon.item, weapon.limit)
    end
  end

  if invData.UseBlackList then
    for i = 1, #(invConfig.blacklist or {}) do
      local item = invConfig.blacklist[i]
      exports.vorp_inventory:BlackListCustomAny(id, item.name or item.item)
    end
  end

  return inventoriesCreated[id].inventory
end

function jo.framework:removeInventory(id)
  Inventory:removeInventory(id)
end

function jo.framework:openInventory(source, id)
  if not Inventory:isCustomInventoryRegistered(id) then
    return false, eprint(("This custom inventory doesn't exist: %s. You can create it with `jo.framework:createInventory()`."):format(tostring(id)))
  end
  return Inventory:openInventory(source, id)
end

function jo.framework:addItemInInventory(source, id, item, quantity, metadata)
  local user = self.UserClass:get(source)
  local charIdentifier = user.data.charIdentifier

  local items = {
    {
      name = item,
      amount = quantity,
      metadata = metadata
    }
  }

  return Inventory:addItemsToCustomInventory(id, items, charIdentifier)
end

function jo.framework:getItemsFromInventory(invId)
  local invItems = Inventory:getCustomInventoryItems(invId) or {}
  local weaponItems = Inventory:getCustomInventoryWeapons(invId) or {}
  local items = {}

  for i = 1, #invItems do
    items[i] = {
      id = invItems[i].id,
      amount = invItems[i].amount,
      item = invItems[i].name,
      metadata = invItems[i].metadata
    }
  end

  for i = 1, #weaponItems do
    items[#items + 1] = {
      id = weaponItems[i].id,
      amount = 1,
      item = weaponItems[i].name,
      metadata = {
        label = weaponItems[i].label,
        custom_desc = weaponItems[i].custom_desc,
        serial_number = weaponItems[i].serial_number,
      }
    }
  end

  return items
end
