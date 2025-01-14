-------------
-- FRAMEWORK CLASS
-------------
---@class FrameworkClass : table Framework class
---@field name string @FrameworkClass name
---@field core table  @FrameworkClass core
---@field inv table @FrameworkClass inventory
local FrameworkClass = {
  name = "",
  core = {},
  inv = {},
  inventories = {}
}

--- Initialize the framework
function FrameworkClass:init()
end

---@return string Name of the framework
function FrameworkClass:get()
  return self.name
end

---@param name string Name of the framework
---@return boolean
function FrameworkClass:is(name)
  return self:get() == name
end

---@param source integer source ID
---@return table
function FrameworkClass:getUser(source)
  return {}
end

---@param source integer source ID
---@return table identifiers
function FrameworkClass:getUserIdentifiers(source)
  return {
    identifier = 0,
    charid = 0
  }
end

---@param source integer source ID
---@return string job Player job
function FrameworkClass:getJob(source)
  return ""
end

---@param source integer source ID
---@return string name Player name
function FrameworkClass:getRPName(source)
  return ""
end

---@param source integer
---@param amount number
---@param moneyType? integer 0: money, 1: gold, 2: rol
---@param removeIfCan? boolean (optinal) default : false
---@return boolean
function FrameworkClass:canUserBuy(source, amount, moneyType, removeIfCan)
  return false
end

---@param source integer
---@param amount number
---@param moneyType? integer 0: money, 1: gold, 2: rol
function FrameworkClass:addMoney(source, amount, moneyType)
end

-------------
-- END MONEY
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
  return false
end

---@param item string name of the item
---@param callback function function fired when the item is used
---@param closeAfterUsed boolean if inventory needs to be closes
function FrameworkClass:registerUseItem(item, closeAfterUsed, callback)
end

---@param source integer source ID
---@param item string name of the item
---@param quantity integer quantity
---@param meta table metadata of the item
---@return boolean
function FrameworkClass:giveItem(source, item, quantity, meta)
  return false
end

---@param source iteger source ID
---@param item string name of the item
---@param quantity integer quantity
---@param meta table metadata of the item
---@return boolean
function FrameworkClass:removeItem(source, item, quantity, meta)
  return false
end

---@param invName string unique ID of the inventory
---@param name string name of the inventory
---@param invConfig table Configuration of the inventory
function FrameworkClass:createInventory(invName, name, invConfig)
end

---@param invName string unique ID of the inventory
function FrameworkClass:removeInventory(invName)
end

---@param source integer sourceIdentifier
---@param invName string name of the inventory
function FrameworkClass:openInventory(source, invName)
end

---@param invId string unique ID of the inventory
---@param item string name of the item
---@param quantity integer quantity
---@param metadata table metadata of the item
---@param needWait? boolean wait after the adding
function FrameworkClass:addItemInInventory(source, invId, item, quantity, metadata, needWait)
end

---@param source integer source ID
---@param invId string name of the inventory
---@return table items the list of item in this inventory
function FrameworkClass:getItemsFromInventory(source, invId)
  return {}
end

-------------
-- END INVENTORY
-------------

-------------
-- SKIN & CLOTHES
-------------

---@param skin table Framework skin value
---@return table standard Skin value with standard keys
function FrameworkClass:standardizeSkin(skin)
  return skin
end

---@param skin table Standard skin value
---@return table skin Skin value with Framework keys
function FrameworkClass:revertSkin(skin)
  return skin
end

---@param clothes table Standard clothes value
---@return table clothes Clothes value with Framework keys
function FrameworkClass:revertClothes(clothes)
  return clothes
end

---@param clothes table Clothes value with Framework keys
---@return table clothes Standard clothes value
function FrameworkClass:standardizeClothes(clothes)
  return clothes
end

---@param source interger The player server ID
---@return table clothes Standard clothes value
function FrameworkClass:getUserClothes(source)
  return {}
end

---@param source string
---@param _clothes table with key = category
---@param value? table
function FrameworkClass:updateUserClothes(source, _clothes, value)
  if value then
    _clothes = { [_clothes] = formatComponentData(value) }
  end
end

---@param source integer
---@return skin table User skin with standard keys
function FrameworkClass:getUserSkin(source)
  return {}
end

---Can be used with 3 or 4 arguments
---@param source integer
---@param _skin any key = category, value = data OR category name if three parameters
---@param value? table if set, _skin is the category name
---@param overwrite? boolean if true, all skin data will be overwrited (default: false)
function FrameworkClass:updateUserSkin(...)
  local args = table.pack(...)
  local source, _skin, overwrite = args[1], {}, false

  if type(args[2]) == "string" then
    _skin = { [args[2]] = args[3] }
    overwrite = args[math.max(4, #args)] or overwrite
  else
    _skin = args[2]
    overwrite = args[math.max(3, #args)] or overwrite
  end
end

---@param source interger server ID
---@param data table player data
---@param spawnCoordinate vec4 Location of the spawn
---@param isDead boolean if the player is dead
function FrameworkClass:createUser(source, data, spawnCoordinate, isDead)
  if isDead == nil then isDead = false end
  spawnCoordinate = spawnCoordinate or vec4(2537.684, -1278.066, 49.218, 42.520)
  data = data or {}
  data.firstname = data.firstname or ""
  data.lastname = data.lastname or ""
  data.skin = self:revertSkin(data.skin)
  data.comps = self:revertClothes(data.comps)
end

-------------
-- END SKIN & CLOTHES
-------------

return FrameworkClass
