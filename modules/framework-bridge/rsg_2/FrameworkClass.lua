-------------
-- FRAMEWORK CLASS
-------------
local RSGCore = exports["rsg-core"]:GetCoreObject()
local Inventory = exports["rsg-inventory"]

jo.file.load("framework-bridge.rsg.FrameworkClass")
jo.framework.inv = Inventory

-------------
-- VARIABLES
-------------

-------------
-- INVENTORY
-------------

function jo.framework:registerUseItem(item, closeAfterUsed, callback)
  local isAdded = RSGCore.Functions.AddItem(item, nil)
  if isAdded then
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
  Inventory:CreateInventory(invId)
  return Inventory:AddItem(invId, item, quantity, false, metadata)
end

function jo.framework:getItemsFromInventory(invId)
  local inventory = GetValue(Inventory:GetInventory(invId), { items = {} })
  for i = 1, #inventory.items do
    items[i] = {
      metadata = inventory.items[i].info,
      amount = inventory.items[i].amount,
      item = inventory.items[i].name
    }
  end
end
