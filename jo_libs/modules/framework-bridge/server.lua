jo.require("table")
jo.require("string")

-------------
-- LOAD FRAMEWORK
-------------


local UserClass = {}

local userFile = jo.framework:loadFile("UserClass")
if userFile then
  table.merge(UserClass, userFile)
end
jo.framework:loadFile("FrameworkClass")

-------------
-- END LOAD FRAMEWORK
-------------

-------------
-- POWER UP FUNCTIONS
-------------

---@param price number price
---@param moneyType integer 0: money, 1: gold, 2: rol
---@param removeIfCan? boolean remove the move if the player has enough (default: false)
---@return boolean removed `true` if the money is removed
function UserClass:canBuy(price, moneyType, removeIfCan)
  if not price then
    return false, eprint("Price value is nil")
  end
  price = math.abs(price)
  moneyType = GetValue(moneyType, 0)
  if not price then
    return false, eprint("PRICE IS NIL !")
  end
  local money = self:getMoney(moneyType)
  local hasEnough = money >= price
  if removeIfCan == true and hasEnough then
    self:removeMoney(price, moneyType)
  end
  return hasEnough
end

---@param amount number amount of gold
function UserClass:giveGold(amount)
  return self:addMoney(amount, 1)
end

---@return string name the framework name
function jo.framework:get()
  return frameworkDetected.id
end

---@param name string Name of the framework
---@return boolean rightName `true` if it's the right framework
function jo.framework:is(name)
  return self:get() == name
end

---@param source integer source ID
---@return table UserClass
function jo.framework:getUser(source)
  local user = UserClass:get(source)
  return user
end

---@param source integer source ID
---@return table identifiers
function jo.framework:getUserIdentifiers(source)
  local user = UserClass:get(source)
  return user:getIdentifiers()
end

---@param source integer source ID
---@return string job Player's job
function jo.framework:getJob(source)
  local user = UserClass:get(source)
  return user:getJob()
end

---@param source integer source ID
---@return string name Player's name
function jo.framework:getRPName(source)
  local user = UserClass:get(source)
  return user:getRPName()
end

---@param source integer
---@param amount number
---@param moneyType? integer 0: money, 1: gold, 2: rol (default: 0)
---@param removeIfCan? boolean remove the move if the player has enough (default: false)
---@return boolean removed `true` if the money is removed
function jo.framework:canUserBuy(source, amount, moneyType, removeIfCan)
  local user = UserClass:get(source)
  return user:canBuy(amount, moneyType, removeIfCan)
end

---@param source integer
---@param amount number
---@param moneyType? integer 0: money, 1: gold, 2: rol (default: 0)
function jo.framework:addMoney(source, amount, moneyType)
  local user = UserClass:get(source)
  return user:addMoney(amount, moneyType)
end

---@param source integer
---@param amount number
---@param moneyType? integer 0: money, 1: gold, 2: rol (default: 0)
function jo.framework:removeMoney(source, amount, moneyType)
  local user = UserClass:get(source)
  return user:removeMoney(amount, moneyType)
end

---@param source integer source ID
---@param item string name of the item
---@param quantity integer quantity
---@param meta table metadata of the item
---@return boolean
function jo.framework:removeItem(source, item, quantity, meta)
  return self:canUseItem(source, item, quantity, meta, true)
end


function jo.framework:convertToPercent(value)
  value = tonumber(value)
  if not value then return 0 end
  if value > 1 or value < -1 then
    return value / 100
  end
  return value
end

---@param data any the clothes data
---@return table
local function formatComponentData(data)
  if type(data) == "table" then
    if data.comp then
      data.hash = data.comp
      data.comp = nil
    end
    if not data.hash or data.hash == 0 or data.hash == -1 then return nil end
    if type(data.hash) == "table" then
      return data.hash
    end
    return data
  end
  if type(data) ~= "number" then data = tonumber(data) end
  if data == 0 or data == -1 or data == 1 or data == nil then
    return nil
  end
  return {
    hash = data
  }
end

local function clearOverlaysTable(overlays)
  if not overlays then return end
  for layerName, overlay in pairs(overlays) do
    if not overlay then
      overlays[layerName] = nil
    end
    if table.type(overlay) == "array" then
      overlay = clearOverlaysTable(overlay)
    else
      if overlay.opacity == 0 then
        overlays[layerName] = nil
      else
        if overlay.palette and table.count(overlay) == 1 then
          overlays[layerName] = nil
        end
      end
    end
  end
end

local function clearExpressionsTable(expressions)
  for key, expression in pairs(expressions) do
    if expression == 0 then
      expressions[key] = nil
    else
      expressions[key] = jo.framework:convertToPercent(expression)
    end
  end
end

local function clearClothesTable(clothesList)
  if not clothesList then return {} end
  for cat, data in pairs(clothesList) do
    clothesList[cat] = formatComponentData(data)
  end
  return clothesList
end


function jo.framework:extractComponentHashIfAlone(data)
  if type(data) ~= "table" then return data end
  if table.count(data) > 1 then return data end
  if not data.hash then return data end
  return data.hash
end


function jo.framework:standardizeClothes(clothes)
  clothes = table.copy(clothes)
  local standard = self:standardizeClothesInternal(clothes)

  if jo.debug then
    for key, value in pairs(clothes) do
      oprint("Clothes key not standardized", key, value)
    end
  end

  table.merge(standard, clothes)
  clearClothesTable(standard)

  return standard
end

function jo.framework:revertClothes(standard)
  standard = table.copy(standard)
  local clothes = self:revertClothesInternal(standard)

  if jo.debug then
    for key, value in pairs(standard) do
      dprint("Clothes key not reverted", key, value)
    end
  end

  table.merge(clothes, standard)
  return clothes
end

function jo.framework:standardizeSkin(skin)
  skin = table.copy(skin)
  local standard = self:standardizeSkinInternal(skin)

  table.merge(standard, skin)

  clearOverlaysTable(standard.overlays)
  clearOverlaysTable(skin.overlays)
  if table.count(skin.overlays) == 0 then
    skin.overlays = nil
  end
  clearExpressionsTable(standard.expressions)

  if standard.hair and type(standard.hair) ~= "table" then
    standard.hair = { hash = standard.hair }
  end
  if standard.beards_complete and type(standard.beards_complete) ~= "table" then
    standard.beards_complete = { hash = standard.beards_complete }
  end

  if jo.debug then
    if table.count(skin) > 0 then
      eprint("Skin keys not converted to standard")
      for key, value in pairs(skin) do
        print(key, type(value) == "table" and json.encode(value, { indent = true }) or value)
      end
    else
      gprint("All skin keys standardized")
    end
  end

  return standard
end

function jo.framework:revertSkin(standard)
  standard = table.copy(standard)
  local skin = self:revertSkinInternal(standard)

  for key, data in pairs(skin.overlays or {}) do
    if table.count(data) == 0 then
      skin.overlays[key] = nil
    end
  end

  if table.count(skin.overlays) == 0 then
    skin.overlays = nil
  end
  if table.count(skin.expressions) == 0 then
    skin.expressions = nil
  end

  if config and Config.debug then
    if table.count(standard) > 0 then
      eprint("Skin keys not reverted")
      for key, value in pairs(standard) do
        print(key, type(value) == "table" and json.encode(value) or value)
      end
    else
      gprint("All skin keys reverted")
    end
  end
  return skin
end

function jo.framework:updateUserClothes(source, _clothes, value)
  if value then
    _clothes = { [_clothes] = formatComponentData(value) }
  end
  local clothes = self:revertClothes(_clothes)
  self:updateUserClothesInternal(source, clothes)
end

function jo.framework:getUserClothes(source)
  local clothes = self:getUserClothesInternal(source)
  if table.isEmpty(clothes) then return {} end
  return self:standardizeClothes(clothes)
end

function jo.framework:getUserSkin(source)
  local skin = self:getUserSkinInternal(source)

  local skinStandardized = self:standardizeSkin(skin)

  if not skinStandardized.teethHash and not skinStandardized.teethIndex then
    local clothes = self:getUserClothes(source)
    if clothes.teeth then
      skinStandardized.teethHash = clothes.teeth?.hash
    end
  end

  return skinStandardized
end

function jo.framework:updateUserSkin(...)
  local args = { ... }
  local source, _skin, overwrite = args[1], {}, false

  if type(args[2]) == "string" then
    _skin = { [args[2]] = args[3] }
    overwrite = GetValue(args[math.max(4, #args)], overwrite)
  else
    _skin = args[2]
    overwrite = GetValue(args[math.max(3, #args)], overwrite)
  end
  local skin = self:revertSkin(_skin)

  self:updateUserSkinInternal(source, skin, overwrite)
end

-------------
-- END POWER UP FUNCTIONS
-------------

-------------
-- LOAD CUSTOM FUNCTIONS
-------------
userFile = jo.framework:loadFile("_custom", "UserClass")
if userFile then
  table.merge(UserClass, userClass)
end

jo.framework:loadFile("_custom", "FrameworkClass")

jo.framework:loadFile("server")
jo.framework:loadFile("_custom", "server")

-------------
-- END LOAD CUSTOM FUNCTIONS
-------------

-------------
-- INIT jo VALUES
-------------

jo.framework.UserClass = UserClass

-------------
-- END INIT jo VALUES
-------------
