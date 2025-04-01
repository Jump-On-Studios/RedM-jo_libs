-------------
-- FRAMEWORK CLASS
-------------
local RSGCore = exports["rsg-core"]:GetCoreObject()
local Inventory = exports["rsg-inventory"]

local FrameworkClass = jo.file.load("framework-bridge.rsg.FrameworkClass")
FrameworkClass.inv = Inventory

-------------
-- VARIABLES
-------------

local inventoriesCreated = {}

-------------
-- INVENTORY
-------------

function FrameworkClass:registerUseItem(item, closeAfterUsed, callback)
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

function FrameworkClass:createInventory(id, name, invConfig)
  inventoriesCreated[id] = {
    id = id,
    name = name,
    config = invConfig,
    inventory = {}
  }
  -------------
  -- RSG Inventory is defined in g, not kg
  -------------
  if inventoriesCreated[id].config.maxWeight then
    inventoriesCreated[id].config.maxWeight *= 1000
  end
end

function FrameworkClass:openInventory(source, id)
  local data = {
    label = config.name,
    maxweight = config.invConfig.maxWeight,
    slots = config.invConfig.maxSlots
  }
  Inventory:OpenInventory(source, id, data)
end

function FrameworkClass:addItemInInventory(source, invId, item, quantity, metadata, needWait)
  Inventory:CreateInventory(invId)
  return Inventory:AddItem(invId, item, quantity, false, metadata)
end

function FrameworkClass:getItemsFromInventory(invId)
  local inventory = GetValue(Inventory:GetInventory(invId), { items = {} })
  for i = 1, #inventory.items do
    items[i] = {
      metadata = inventory.items[i].info,
      amount = inventory.items[i].amount,
      item = inventory.items[i].name
    }
  end
end

return FrameworkClass
