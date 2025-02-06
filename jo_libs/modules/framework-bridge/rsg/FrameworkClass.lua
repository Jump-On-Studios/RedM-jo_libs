-------------
-- FRAMEWORK CLASS
-------------

FrameworkClass = FrameworkClass or {}
FrameworkClass.name = "RSG"
FrameworkClass.core = exports["rsg-core"]:GetCoreObject()
FrameworkClass.coreVersion = GetResourceMetadata("rsg-core", "version", 0) or 1
if ("2.0.0"):convertVersion() <= FrameworkClass.coreVersion:convertVersion() then
  FrameworkClass.inv = exports["rsg-inventory"]
  FrameworkClass.isV2 = true
  FrameworkClass.longName = "RSG V2 Framework"
else
  FrameworkClass.isV2 = false
  FrameworkClass.longName = "RSG V1 Framework"
end

-------------
-- VARIABLES
-------------

local inventoriesCreated = {}

-------------
-- INVENTORY
-------------

function FrameworkClass:canUseItem(source, item, amount, meta, remove)
  local Player = UserClass:get(source)
  local itemData = Player.data.Functions.GetItemByName(item)
  if itemData and itemData.amount >= amount then
    if remove then
      Player.data.Functions.RemoveItem(item, amount)
    end
    return true
  end
end

function FrameworkClass:registerUseItem(item, closeAfterUsed, callback)
  if self.isV2 then
    local isAdded = self.core.Functions.AddItem(item, nil)
    if isAdded then
      return eprint(item .. " < item does not exist in the core configuration")
    end
    self.core.Functions.CreateUseableItem(item, function(source, data)
      callback(source, { metadata = data.info })
      if closeAfterUsed then
        TriggerClientEvent("rsg-inventory:client:closeInv", source)
      end
    end)
  else
    local isAdded = self.core.Functions.AddItem(item, nil)
    if isAdded then
      return eprint(item .. " < item does not exist in the core configuration")
    end
    self.core.Functions.CreateUseableItem(item, function(source, data)
      callback(source, { metadata = data.info })
      if closeAfterUsed then
        TriggerClientEvent(string.lower(self:get()) .. "-inventory:client:closeinv", source)
      end
    end)
  end
end

function FrameworkClass:giveItem(source, item, quantity, meta)
  local Player = UserClass:get(source)
  return Player.data.Functions.AddItem(item, quantity, false, meta)
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
  local config = inventoriesCreated[id]
  if self.isV2 then
    local data = {
      label = config.name,
      maxweight = config.invConfig.maxWeight,
      slots = config.invConfig.maxSlots
    }
    self.inv:OpenInventory(source, id, data)
  else
    TriggerClientEvent(GetCurrentResourceName() .. ":client:openInventory", source, id, config)
    return
  end
end

return FrameworkClass
