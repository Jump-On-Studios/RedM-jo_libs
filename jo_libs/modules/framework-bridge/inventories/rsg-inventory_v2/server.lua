local RSGCore = exports["rsg-core"]:GetCoreObject()
local Inventory = exports["rsg-inventory"]
jo.framework.inv = Inventory

AddEventHandler("RSGCore:Server:UpdateObject", function()
  RSGCore = exports["rsg-core"]:GetCoreObject()
end)

-------------
-- INVENTORY
-------------

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
      TriggerClientEvent("rsg-inventory:client:closeInv", source)
    end
  end)
end

function jo.framework:createInventory(id, name, invConfig)
  local config = {
    label = name,
    maxweight = invConfig.maxWeight and (invConfig.maxWeight * 1000), --convert kg to g
    slots = invConfig.maxSlots
  }

  Inventory:CreateInventory(id, config)
end

function jo.framework:openInventory(source, id)
  Inventory:OpenInventory(source, id)
end

function jo.framework:addItemInInventory(source, invId, item, quantity, metadata, needWait)
  if not invId then
    return false, eprint("jo.framework:addItemInInventory: Inventory ID is missing")
  end
  if not Inventory:GetInventory(invId) then
    Inventory:CreateInventory(invId, {})
  end
  local isAdded = Inventory:AddItem(invId, item, quantity, false, metadata)
  if not isAdded then
    return false, eprint("Item " .. item .. " was not added to inventory: " .. invId)
  end
  jo.timeout.delay("SaveStash:" .. invId, 1000, function()
    Inventory:SaveStash(invId)
  end)
  return true
end

function jo.framework:getItemsFromInventory(invId)
  local inventory = Inventory:GetInventory(invId) or { items = {} }
  local items = {}
  for slot, item in pairs(inventory.items) do
    table.insert(items, {
      id = item.slot or slot,
      metadata = item.info,
      amount = item.amount,
      item = item.name
    })
  end
  return items
end

function jo.framework:removeInventory(invId)
  MySQL.update("DELETE FROM inventories WHERE identifier = ?", { invId })
  return Inventory.DeleteInventory(invId)
end

function jo.framework:canUseItem(source, item, amount, meta, remove)
  local items = Inventory:GetItemsByName(source, item)

  if not items or #items == 0 then
    return false
  end
  for i = 1, #items do
    local data = items[i]
    if meta then
      if table.isEgal(data.info, meta, false, false, true) then
        if data.amount >= amount then
          if remove then
            Inventory:RemoveItem(source, item, amount, data.slot)
          end
          return true
        end
      end
    else
      if data.amount >= amount then
        if remove then
          Inventory:RemoveItem(source, item, amount, data.slot)
        end
        return true
      end
    end
  end

  return false
end

local function normalizeItem(data, slot)
  return {
    id = data.slot or slot,
    amount = data.amount or 0,
    item = data.name,
    metadata = type(data.info) == "table" and data.info or {}
  }
end

local function itemMatchesSelector(item, selector)
  if not selector then return true end
  if selector.id ~= nil and tostring(item.id) ~= tostring(selector.id) then return false end
  if selector.metadata and not table.isEgal(selector.metadata, item.metadata, false) then return false end
  return true
end

function jo.framework:getItem(source, item, selector, invId)
  local invItems
  if invId then
    local inventory = Inventory:GetInventory(invId)
    invItems = inventory and inventory.items
  else
    invItems = Inventory:GetItemsByName(source, item)
  end

  for slot, data in pairs(invItems or {}) do
    local normalizedItem = normalizeItem(data, slot)
    if normalizedItem.item == item and itemMatchesSelector(normalizedItem, selector) then
      return normalizedItem
    end
  end
end

function jo.framework:setItemMetadata(source, itemId, metadata, invId)
  if itemId == nil or type(metadata) ~= "table" then return false end

  if invId then
    local inventory = Inventory:GetInventory(invId)
    if not inventory or not inventory.items then return false end

    for slot, item in pairs(inventory.items) do
      if tostring(item.slot or slot) == tostring(itemId) then
        item.info = metadata
        Inventory:SaveStash(invId)
        return true
      end
    end
    return false
  end

  local Player = RSGCore.Functions.GetPlayer(source)
  if not Player then return false end

  for slot, item in pairs(Player.PlayerData.items or {}) do
    if tostring(item.slot or slot) == tostring(itemId) then
      item.info = metadata
      Player.Functions.SetPlayerData("items", Player.PlayerData.items)
      return true
    end
  end
  return false
end

function jo.framework:getItemCount(source, item, meta)
  local items = Inventory:GetItemsByName(source, item)
  if not items or #items == 0 then
    return 0
  end
  local count = 0
  for i = 1, #items do
    local data = items[i]
    if meta then
      if table.isEgal(data.info, meta, false, false, true) then
        count = count + data.amount
      end
    else
      count = count + data.amount
    end
  end
  return count
end
