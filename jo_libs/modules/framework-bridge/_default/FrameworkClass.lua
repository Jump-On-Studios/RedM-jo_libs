-------------
-- FRAMEWORK CLASS
-------------

FrameworkClass = FrameworkClass or {}
FrameworkClass.name = "Default"
FrameworkClass.longName = "Default Framework: not init"
FrameworkClass.core = {} --link the core here
FrameworkClass.inv = {}  -- link the inventory here

--Fire to init the framework
function FrameworkClass:init()
end

-------------
-- INIT FRAMEWORK
-------------

---@return string name the framework name
function FrameworkClass:get()
  return self.name
end

---@param name string Name of the framework
---@return boolean rightName `true` if it's the right framework
function FrameworkClass:is(name)
  return self:get() == name
end

-------------
-- END INIT FRAMEWORK
-------------

-------------
-- USER DATA
-------------

---@param source integer source ID
---@return table
function FrameworkClass:getUser(source)
  local user = UserClass:get(source)
  return user
end

---@param source integer source ID
---@return table identifier
function FrameworkClass:getUserIdentifiers(source)
  local user = UserClass:get(source)
  return user:getIdentifiers()
end

---@param source integer source ID
---@return string job Player job
function FrameworkClass:getJob(source)
  local user = UserClass:get(source)
  return user:getJob()
end

---@param source integer source ID
function FrameworkClass:getRPName(source)
  local user = UserClass:get(source)
  return user:getRPName()
end

-------------
-- END USER DATA
-------------

-------------
-- MONEY
-------------

---@param source integer
---@param amount number
---@param moneyType? integer 0: money, 1: gold, 2: rol
---@param removeIfCan? boolean (optinal) default : false
---@return boolean
function FrameworkClass:canUserBuy(source, amount, moneyType, removeIfCan)
  local user = UserClass:get(source)
  return user:canBuy(amount, moneyType or 0, removeIfCan)
end

---@param source integer
---@param amount number
---@param moneyType? integer 0: money, 1: gold, 2: rol
function FrameworkClass:addMoney(source, amount, moneyType)
  local user = UserClass:get(source)
  user:addMoney(amount, moneyType or 0)
end

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
---@return boolean
function FrameworkClass:registerUseItem(item, closeAfterUsed, callback)
  return false
end

---@param source integer source ID
---@param item string name of the item
---@param quantity integer quantity
---@param meta table metadata of the item
---@return boolean
function FrameworkClass:giveItem(source, item, quantity, meta)
  return false
end

---@param source integer source ID
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
---@return boolean
function FrameworkClass:createInventory(invName, name, invConfig)
  return false
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
  return false
end

---@param invId string unique ID of the inventory
---@param item string name of the item
---@param quantity integer quantity
---@param metadata table metadata of the item
---@param needWait? boolean wait after the adding
---@return boolean
function FrameworkClass:addItemInInventory(source, invId, item, quantity, metadata, needWait)
  return false
end

---@param invId string name of the inventory
---@return table
function FrameworkClass:getItemsFromInventory(invId)
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
function FrameworkClass:standardizeSkin(skin)
  return {}
end

---A function to revert a standardize clothes table
---@param clothes table clothes with standard keys
---@return table clothes clothes with framework keys
function FrameworkClass:revertClothes(clothes)
  return {}
end

function FrameworkClass:getUserClothes(source)
  return {}
end

function FrameworkClass:updateUserClothes(source, _clothes, value)
  return {}
end

function FrameworkClass:getUserSkin(source)
  return {}
end

function FrameworkClass:updateUserSkin(...)
  return {}
end

function FrameworkClass:createUser(source, data, spawnCoordinate, isDead)
  return {}
end


return FrameworkClass
