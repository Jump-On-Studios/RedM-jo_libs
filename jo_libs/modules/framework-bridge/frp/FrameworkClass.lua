-------------
-- FRAMEWORK CLASS
-------------
local Core = exports.frp_core:API()

jo.framework.core = Core

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
  local count = exports.ox_inventory:GetItem(source, item, meta, true)
  if not count then
    count = 0
  end
  if count >= amount then
    if remove then
      local res = exports.ox_inventory:RemoveItem(source, item, amount, meta)
      return res
    end
  end
  return false
end

---@param item string name of the item
---@param callback function function fired when the item is used
---@param closeAfterUsed boolean if inventory needs to be closes
---@return boolean
function jo.framework:registerUseItem(item, closeAfterUsed, callback)
  exports.ox_inventory:CreateUseableItem(item, function(source, data)
    callback(source, { metadata = data.metadata })
    if closeAfterUsed then
      TriggerClientEvent("ox_inventory:closeInventory", source)
    end
  end)
end

---@param source integer source ID
---@param item string name of the item
---@param quantity integer quantity
---@param meta table metadata of the item
---@return boolean
function jo.framework:giveItem(source, item, quantity, meta)
  if exports.ox_inventory:CanCarryItem(source, item, quantity, meta) then
    local res = exports.ox_inventory:AddItem(source, item, quantity, meta)
    return res
  end
  return false
end

---@param invName string unique ID of the inventory
---@param name string name of the inventory
---@param invConfig table Configuration of the inventory
---@return boolean
function jo.framework:createInventory(invName, name, invConfig)
    local inventoryConfig = {
      id = invName,
      name = name,
      slots = invConfig.maxSlots,
      maxWeight = invConfig.maxWeight * 1000,
    }
    inventories[invName] = inventoryConfig
    exports.ox_inventory:RegisterStash(inventoryConfig.id, inventoryConfig.name, inventoryConfig.slots, inventoryConfig.maxWeight)
  return true
end

---@param invName string unique ID of the inventory
---@return boolean
function jo.framework:removeInventory(invName)
  return exports.ox_inventory:RemoveInventory(invName)
end

---@param source integer sourceIdentifier
---@param invName string name of the inventory
---@return boolean
function jo.framework:openInventory(source, invName)
  TriggerClientEvent("ox_inventory:openInventory", source, 'stash', { id = invName })
  return true
end

---@param invId string unique ID of the inventory
---@param item string name of the item
---@param quantity integer quantity
---@param metadata table metadata of the item
---@param needWait? boolean wait after the adding
---@return boolean
function jo.framework:addItemInInventory(source, invId, item, quantity, metadata, needWait)
  return exports.ox_inventory:AddItem(invId, item, quantity, metadata)
end

---@param invId string name of the inventory
---@return table
function jo.framework:getItemsFromInventory(invId)
  return exports.ox_inventory:GetInventoryItems(invId)
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
  local clothes = {}
  local user = self.core.GetUserFromSource( source )
  local character = user:GetCharacter()
  local outfitId = character.outfitId
  local gender = (character.isMale == 0 or not character.isMale) and 2 or 1

  local res = MySQL.scalar.await("SELECT `apparels` FROM `character_outfit` WHERE id = ?", { outfitId })

  if type(res) == "string" then
    res = json.decode(res)
  end

  for t, item in pairs ( res ) do
    local apparatusType = tonumber(t)
    local itemHash = getShopitemAnyByMetapedBodyApparatus(
      {
        type = apparatusType,
        gender = gender,
        id = tonumber(item.id) or 1,
        styleId = tonumber(item.styleId) or 1
      }
    )

    local typeHash = eMetapedBodyApparatusTypeToStr[apparatusType]

    if itemHash then
      local itemHashKey = type(itemHash) == "number" and itemHash or GetHashKey(itemHash)
      clothes[typeHash] = itemHashKey
    end
  end
  if not clothes then return {} end
  clothes = UnJson(clothes)
  local clothesStandardized = jo.framework:standardizeClothes(clothes)

  return clothesStandardized
end

function jo.framework:updateUserClothesInternal(source, clothes)
  -- #TODO
end

function jo.framework:getUserSkinInternal(source)
  -- #TODO
end

function jo.framework:updateUserSkinInternal(source, skin, overwrite)
  -- #TODO
end

function jo.framework:createUser(source, data, spawnCoordinate, isDead)
  -- #TODO
end

function jo.framework:onCharacterSelected(cb)
  -- #TODO
end
