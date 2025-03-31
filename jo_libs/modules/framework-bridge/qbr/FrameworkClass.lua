-------------
-- FRAMEWORK CLASS
-------------
local Core = exports["qbr-core"]

local FrameworkClass = {
  core = Core
}

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
function FrameworkClass:canUseItem(source, item, amount, meta, remove)
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
function FrameworkClass:registerUseItem(item, closeAfterUsed, callback)
  closeAfterUsed = GetValue(closeAfterUsed, true)
  local isAdded = self.core:AddItem(item, nil)
  if isAdded then
    return eprint(item .. " < item does not exist in the core configuration")
  end
  return self.core:CreateUseableItem(item, function(source, data)
    callback(source, { metadata = data.info })
    if closeAfterUsed then
      TriggerClientEvent("qbr-inventory:client:closeinv", source)
    end
  end)
end

---@param source integer source ID
---@param item string name of the item
---@param quantity integer quantity
---@param meta table metadata of the item
---@return boolean
function FrameworkClass:giveItem(source, item, quantity, meta)
  local Player = self.UserClass:get(source)
  return Player.data.Functions.AddItem(item, quantity, false, meta)
end

---@param invName string unique ID of the inventory
---@param name string name of the inventory
---@param invConfig table Configuration of the inventory
---@return boolean
function FrameworkClass:createInventory(invName, name, invConfig)
  inventories[invName] = {
    invName = invName,
    name = name,
    invConfig = invConfig
  }
end

---@param invName string unique ID of the inventory
---@return boolean
function FrameworkClass:removeInventory(invName)
  return false
end

---@param source integer sourceIdentifier
---@param invName string name of the inventory
---@return boolean
function FrameworkClass:openInventory(source, invName)
  local invConfig = inventories[invName].invConfig
  TriggerClientEvent(GetCurrentResourceName() .. ":client:openInventory", source, invName, invConfig)
  return true
end

---@param invId string unique ID of the inventory
---@param item string name of the item
---@param quantity integer quantity
---@param metadata table metadata of the item
---@param needWait? boolean wait after the adding
---@return boolean
function FrameworkClass:addItemInInventory(source, invId, item, quantity, metadata, needWait)
  local waiter = promise.new()
  needWait = GetValue(needWait, false)
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
      amount = quantity,
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
  end)
  return needWait and Citizen.Await(waiter)
end

---@param invId string name of the inventory
---@return table
function FrameworkClass:getItemsFromInventory(invId)
  local invItems = MySQL.scalar.await("SELECT items FROM stashitems WHERE stash = ?", { invId })
  invItems = UnJson(invItems)
  local items = {}
  for i = 1, #invItems do
    items[i] = {
      metadata = invItems[i].info,
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
  return skin
end

---A function to reversed the skin data
---@param standard table standard skin data
---@return table skin framework skin data
function FrameworkClass:revertSkinInternal(standard)
  return standard
end

---A function to standardize the clothes data
---@param clothes table standard clothes data
---@return table clothes framework clothes data
function FrameworkClass:standardizeClothesInternal(clothes)
  return clothes
end

---A function to revert a standardize clothes table
---@param standard table clothes with standard keys
---@return table clothes clothes with framework keys
function FrameworkClass:revertClothesInternal(standard)
  return standard
end

function FrameworkClass:getUserClothesInternal(source)
  local user = self:getUserIdentifiers(source)
  local clothes = MySQL.scalar.await("SELECT clothes FROM playerskins WHERE citizenid=? AND active=1", { user.identifier })
  return UnJson(clothes)
end

function FrameworkClass:updateUserClothesInternal(source, clothes)
  local identifiers = self:getUserIdentifiers(source)
  MySQL.scalar("SELECT clothes FROM playerskins WHERE citizenid=? ", { identifiers.identifier }, function(oldClothes)
    local decoded = UnJson(oldClothes)
    table.merge(decoded, clothes)
    MySQL.update("UPDATE playerskins SET clothes=? WHERE citizenid=?", { json.encode(decoded), identifiers.identifier })
  end)
end

function FrameworkClass:getUserSkinInternal(source)
  local user = self.UserClass:get(source)
  local skin = {}
  if not user then return {} end
  local identifiers = user:getIdentifiers()
  skin = MySQL.scalar.await("SELECT skin FROM playerskins WHERE citizenid=?", { identifiers.identifier })
  return UnJson(skin)
end

function FrameworkClass:updateUserSkinInternal(source, skin, overwrite)
  local identifiers = self:getUserIdentifiers(source)
  if overwrite then
    MySQL.update("UPDATE playerskins SET skin=? WHERE citizenid=?", { json.encode(skin), identifiers.identifier })
  else
    MySQL.scalar("SELECT skin FROM playerskins WHERE citizenid=?", { identifiers.identifier }, function(oldSkin)
      local decoded = UnJson(oldSkin)
      table.merge(decoded, skin)
      MySQL.update("UPDATE playerskins SET skin=? WHERE citizenid=?", { json.encode(decoded), identifiers.identifier })
    end)
  end
end

function FrameworkClass:createUser(source, data, spawnCoordinate, isDead)
  return {}
end


return FrameworkClass
