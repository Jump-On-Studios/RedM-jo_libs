-------------
-- FRAMEWORK CLASS
-------------
local QRCore = exports["qr-core"]:GetCoreObject()

jo.framework.core = QRCore
-------------
-- VARIABLES
-------------

local inventories = {}

-------------
-- END VARIABLES
-------------
-------------
-- INVENTORY
-------------

---@param source integer source ID
---@param item string name of the item
---@param amount integer amount to use
---@param meta table metadata of the item
---@param remove boolean if removed after used
function jo.framework:canUseItem(source, item, amount, meta, remove)
  local Player = self.UserClass:get(source)
  local itemData = Player.data.Functions.GetItemByName(item)
  if itemData and itemData.amount >= amount then
    if remove then
      Player.data.Functions.RemoveItem(item, amount)
    end
    return true
  end
  return false
end

---@param item string name of the item
---@param callback function function fired when the item is used
---@param closeAfterUsed boolean if inventory needs to be closes
---@return boolean
function jo.framework:registerUseItem(item, closeAfterUsed, callback)
  closeAfterUsed = GetValue(closeAfterUsed, true)
  local isAdded = QRCore.Functions.AddItem(item, nil)
  if isAdded then
    return false, eprint(item .. " < item does not exist in the core configuration")
  end
  QRCore.Functions.CreateUseableItem(item, function(source, data)
    callback(source, { metadata = data.info })
    if closeAfterUsed then
      TriggerClientEvent("qr-inventory:client:closeinv", source)
    end
  end)
  return true
end

---@param source integer source ID
---@param item string name of the item
---@param quantity integer quantity
---@param meta table metadata of the item
---@return boolean
function jo.framework:giveItem(source, item, quantity, meta)
  local Player = self.UserClass:get(source)
  return Player.data.Functions.AddItem(item, quantity, false, meta)
end

---@param invName string unique ID of the inventory
---@param name string name of the inventory
---@param invConfig table Configuration of the inventory
---@return boolean
function jo.framework:createInventory(invName, name, invConfig)
  inventories[invName] = {
    invName = invName,
    name = name,
    invConfig = invConfig
  }
  return true
end

---@param invName string unique ID of the inventory
---@return boolean
function jo.framework:removeInventory(invName)
  return false
end

---@param source integer sourceIdentifier
---@param invName string name of the inventory
---@return boolean
function jo.framework:openInventory(source, invName)
  local invConfig = inventories[invName].invConfig
  TriggerClientEvent("jo_libs:client:openInventory", source, invName, invConfig)
  return true
end

---@param invId string unique ID of the inventory
---@param item string name of the item
---@param quantity integer quantity
---@param metadata table metadata of the item
---@param needWait? boolean wait after the adding
---@return boolean
function jo.framework:addItemInInventory(source, invId, item, quantity, metadata, needWait)
  return false
end

---@param invId string name of the inventory
---@return table
function jo.framework:getItemsFromInventory(invId)
  --[[ item structure
  {
    metadata = {},
    amount = 0,
    item = "itemName"
  }
  ]]
  return {}
end

-------------
-- END INVENTORY
-------------

-------------
-- SKIN & CLOTHES
-------------

---A function to standardize the skin data
---@param skin table skin data with framework keys
---@return table skin skin data with standard keys
function jo.framework:standardizeSkinInternal(skin)
  return skin
end

---A function to reversed the skin data
---@param standard table standard skin data
---@return table skin framework skin data
function jo.framework:revertSkinInternal(standard)
  return standard
end

---A function to standardize the clothes data
---@param clothes table standard clothes data
---@return table clothes framework clothes data
function jo.framework:standardizeClothesInternal(clothes)
  return clothes
end

---A function to revert a standardize clothes table
---@param standard table clothes with standard keys
---@return table clothes clothes with framework keys
function jo.framework:revertClothesInternal(standard)
  return standard
end

function jo.framework:getUserClothesInternal(source)
  local user = self:getUserIdentifiers(source)
  local clothes = MySQL.scalar.await("SELECT clothes FROM playerclothe WHERE citizenid=?", { user.identifier })
  return UnJson(clothes)
end

function jo.framework:updateUserClothesInternal(source, clothes)
  local identifiers = self:getUserIdentifiers(source)
  MySQL.scalar("SELECT clothes FROM playerclothe WHERE citizenid=?", { identifiers.identifier }, function(oldClothes)
    local decoded = UnJson(oldClothes)
    table.merge(decoded, clothes)
    MySQL.update("UPDATE playerclothe SET clothes=? WHERE citizenid=?", { json.encode(decoed), identifiers.identifier })
  end)
  return true
end

function jo.framework:getUserSkinInternal(source)
  return {}
end

function jo.framework:updateUserSkinInternal(source, skin, overwrite)
  return {}
end

function jo.framework:createUser(source, data, spawnCoordinate, isDead)
  return {}
end

function jo.framework:onCharacterSelected(cb)
  AddEventHandler("qr-multicharacter:server:loadUserData", function()
    local source = source
    Wait(1000)
    cb(source)
  end)
end
