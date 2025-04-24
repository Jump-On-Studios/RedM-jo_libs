-------------
-- FRAMEWORK CLASS
-------------
local RPX = exports["rpx-core"]:GetObject()
local Inventory = exports["rpx-inventory"]

jo.framework.core = RPX
jo.framework.inv = Inventory

-------------
-- VARIABLES
-------------

local Inventories = {}

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
  return false
end

---@param item string name of the item
---@param callback function function fired when the item is used
---@param closeAfterUsed boolean if inventory needs to be closes
---@return boolean
function jo.framework:registerUseItem(item, closeAfterUsed, callback)
  return false
end

---@param source integer source ID
---@param item string name of the item
---@param quantity integer quantity
---@param meta table metadata of the item
---@return boolean
function jo.framework:giveItem(source, item, quantity, meta)
  return Inventory:AddItem(source, item, quantity, meta)
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
  return false
end

---@param invId string unique ID of the inventory
---@param item string name of the item
---@param quantity integer quantity
---@param metadata table metadata of the item
---@param needWait? boolean wait after the adding
---@return boolean
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
  if needWait then
    Citizen.Await(waiter)
  end
end

---@param invId string name of the inventory
---@return table
function jo.framework:getItemsFromInventory(invId)
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
  local user = self.UserClass:get(source)
  local clothes = user.data.clothes
  return UnJson(clothes)
end

function jo.framework:updateUserClothesInternal(source, clothes)
  local user = self.UserClass:get(source)
  local newClothes = table.merge(user.data.clothes, clothes)
  return user.data.SetClothesData(newClothes)
end

function jo.framework:getUserSkinInternal(source)
  local user = self.UserClass:get(source)
  if not user then return {} end

  local skin = user.data.skin

  return UnJson(skin)
end

function jo.framework:updateUserSkinInternal(source, skin, overwrite)
  local user = self.UserClass:get(source)
  if overwrite then
    user.data.SetSkinData(skin)
  else
    local oldSkin = UnJson(user.data.skin)
    table.merge(oldSkin, skin)
    user.data.SetSkinData(oldSkin)
  end
end

function jo.framework:createUser(source, data, spawnCoordinate, isDead)
  return {}
end

function jo.framework:onCharacterSelected(cb)
  AddEventHandler("SERVER:MultiCharacter:SelectCharacter", function()
    local source = source
    cb(source)
  end)
end
