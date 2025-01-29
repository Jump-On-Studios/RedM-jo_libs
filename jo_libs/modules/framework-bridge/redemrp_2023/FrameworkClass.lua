-------------
-- FRAMEWORK CLASS
-------------
local RedEM = exports["redem_roleplay"]:RedEM()
local Inventory

local FrameworkClass = {
  core = RedEM,
  inv = {}
}

TriggerEvent("redemrp_inventory:getData", function(call)
  Inventory = call
  FrameworkClass.inv = Inventory
end)

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
---@param meta? table metadata of the item (default: nil)
---@param remove? boolean if removed after used (default: false)
function FrameworkClass:canUseItem(source, item, amount, meta, remove)
  remove = GetValue(remove, false)
  local itemData = Inventory.getItem(source, item, meta)
  if itemData and itemData.ItemAmount >= amount then
    if remove then
      itemData.RemoveItem(amount)
    end
    return true
  end
  return false
end

---@param item string name of the item
---@param callback function function fired when the item is used
---@param closeAfterUsed? boolean if inventory needs to be closes (default: true)
---@return boolean
function FrameworkClass:registerUseItem(item, closeAfterUsed, callback)
  if not item then return false, eprint("Item has to be defined") end
  if not callback then return false, eprint("Callback has to be defined") end
  closeAfterUsed = GetValue(closeAfterUsed, true)
  local isExist = Inventory.getItemData(item)
  if not isExist then
    return false, eprint(item .. " < item does not exist in the inventory configuration")
  end
  AddEventHandler("RegisterUsableItem:" .. item, function(source, data)
    callback(source, { metadata = data.meta })
    if closeAfterUsed then
      TriggerClientEvent("redemrp_inventory:closeinv", source)
    end
  end)
  return false
end

---@param source integer source ID
---@param item string name of the item
---@param quantity integer quantity
---@param meta table metadata of the item
---@return boolean
function FrameworkClass:giveItem(source, item, quantity, meta)
  local ItemData = Inventory.getItem(source, item, meta)
  return ItemData?.AddItem(quantity, meta)
end

---@param invName string unique ID of the inventory
---@param name string name of the inventory
---@param invConfig table Configuration of the inventory
---@return boolean
function FrameworkClass:createInventory(invName, name, invConfig)
  inventories[invName] = {
    id = invName,
    name = name,
    config = invConfig
  }
  return true
end

---@param invName string unique ID of the inventory
---@return boolean
function FrameworkClass:removeInventory(invName)
  return true
end

---@param source integer sourceIdentifier
---@param invName string name of the inventory
---@return boolean
function FrameworkClass:openInventory(source, invName)
  local config = inventories[invName]?.config
  TriggerClientEvent("redemrp_inventory:OpenStash", source, invName, config.maxWeight)
  return true
end

---@param invName string unique ID of the inventory
---@param item string name of the item
---@param quantity integer quantity
---@param metadata table metadata of the item
---@param needWait? boolean wait after the adding
---@return boolean
function FrameworkClass:addItemInInventory(source, invName, item, quantity, metadata, needWait)
  return Inventory.addItemStash(source, item, quantity, metadata, invName)
end

---@param invName string name of the inventory
---@return table
function FrameworkClass:getItemsFromInventory(invId)
  local invItems = Inventory.getStash(invId)
  if not invItems then return {} end
  local items = {}
  for i = 1, #invItems do
    items[i] = {
      metadata = invItems[i].meta,
      amount = invItems[i].amount,
      item = invItems[i].name
    }
  end
  return items
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
function FrameworkClass:standardizeSkinInternal(skin)
  return {}
end

---A function to reversed the skin data
---@param standard table standard skin data
---@return table skin framework skin data
function FrameworkClass:revertSkinInternal(standard)
  return {}
end

---A function to standardize the clothes data
---@param clothes table standard clothes data
---@return table clothes framework clothes data
function FrameworkClass:standardizeClothesInternal(clothes)
  return {}
end

---A function to revert a standardize clothes table
---@param standard table clothes with standard keys
---@return table clothes clothes with framework keys
function FrameworkClass:revertClothesInternal(standard)
  return {}
end

function FrameworkClass:getUserClothesInternal(source)
  local user = self:getUserIdentifiers(source)
  local clothes = MySQL.scalar.await("SELECT clothes FROM clothes WHERE identifier=? AND charid=?;", { user.identifier, user.charid })
  return UnJson(clothes)
end

function FrameworkClass:updateUserClothesInternal(source, clothes)
  local identifiers = self:getUserIdentifiers(source)
  MySQL.scalar("SELECT clothes FROM clothes WHERE identifier=? AND charid=?;", { identifiers.identifier, identifiers.charid }, function(oldClothes)
    local decoded = UnJson(oldClothes)
    table.merge(decoded, clothes)
    local SQL = "UPDATE clothes SET clothes=@clothes WHERE identifier=@identifier AND charid=@charid"
    if not oldClothes then
      SQL = "INSERT INTO clothes VALUES(NULL,@identifier,@charid,@clothes)"
    end
    MySQL.update(SQL, {
      identifier = identifiers.identifier,
      charid = identifiers.charid,
      clothes = json.encode(decoded)
    })
  end)
end

function FrameworkClass:getUserSkinInternal(source)
  local user = self.UserClass:get(source)
  local skin = {}
  if not user then return {} end
  local identifiers = user:getIdentifiers()
  skin = MySQL.scalar.await("SELECT skin FROM skins WHERE identifier=? AND charid=?;", { identifiers.identifier, identifiers.charid })
  return UnJson(skin)
end

function FrameworkClass:updateUserSkinInternal(source, skin, overwrite)
  local identifiers = self:getUserIdentifiers(source)
  MySQL.scalar("SELECT skin FROM skins WHERE identifier=? AND charid=?", { identifiers.identifier, identifiers.charid }, function(oldSkin)
    if not oldSkin then
      MySQL.insert("INSERT INTO skins VALUES (NULL, ?,?,?)", { identifiers.identifier, identifiers.charid, json.encode(skin) })
    else
      local decoded = UnJson(oldSkin)
      if overwrite then
        decoded = skin
      else
        table.merge(decoded, skin)
      end
      MySQL.update("UPDATE skins SET skin=? WHERE identifier=? AND charid=?", { json.encode(decoded), identifiers.identifier, identifiers.charid })
    end
  end)
end

function FrameworkClass:createUser(source, data, spawnCoordinate, isDead)
  return {}
end


return FrameworkClass
