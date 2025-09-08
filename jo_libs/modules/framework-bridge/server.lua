jo.require("table")
jo.require("string")

-- -----------
-- LOAD FRAMEWORK
-- -----------

---@class UserClass
jo.framework.UserClass = {}

jo.framework:loadFile("UserClass")
jo.framework:loadFile("FrameworkClass")

-- -----------
-- END LOAD FRAMEWORK
-- -----------

-- -----------
-- POWER UP FUNCTIONS
-- -----------

--- Checks if a player has sufficient funds of a specified currency type
---@param price number|table (The amount of money the player needs to have <br> if table: {money = 1, gold = 1, rol = 1})
---@param moneyType? integer (`0`: dollar, `1`: gold, `2`: rol <br> default:`1`)
---@param removeIfCan? boolean (Remove the money if the player has enough <br> default:`false`)
---@return boolean (Return `true` if the player has more money than the amount)
function jo.framework.UserClass:canBuy(price, moneyType, removeIfCan)
  if not price then
    return false, eprint("Price value is nil")
  end
  if type(price) == "table" then
    if moneyType == 2 then
      price = price.rol
    elseif moneyType == 1 then
      price = price.gold
    else
      price = price.money
    end
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

--- Adds gold to the player's account
---@param amount number (The amount of gold to add)
function jo.framework.UserClass:giveGold(amount)
  return self:addMoney(amount, 1)
end

--- Returns the name of the current active framework being used
---@return string (Return the name of the current framework : <br> `"VORP"` or `"RedEM"` or `"RedEM2023"` or `"qbr"` or `"rsg"` or `"qr"` or `"rpx"`)
function jo.framework:get()
  return jo.framework:getFrameworkDetected().id
end

--- Compares the current framework with a specified framework name
---@param name string (The name of the framework to check against <br> Supported frameworks : <br> `"VORP"` or `"RedEM"` or `"RedEM2023"` or `"qbr"` or `"rsg"` or `"qr"` or `"rpx"`)
---@return boolean (Return `true` if the current framework matches the name)
function jo.framework:is(name)
  return self:get() == name
end

--- Retrieves a player's full UserClass object containing all player data and methods
---@param source integer (The source ID of the player)
---@return UserClass (Return a User class object containing player data and methods)
function jo.framework:getUser(source)
  local user = jo.framework.UserClass:get(source)
  return user
end

--- Retrieves all identifiers associated with a player <br> Shortcut for [jo.framework.UserClass:getIdentifiers()](./user#jo.framework.UserClass-getidentifiers) method
---@param source integer (The source ID of the player)
---@return table (Return the player's identifiers <br> `identifiers.identifier` - Unique identifier of the player <br> `identifiers.charid` - Unique id of the player)
function jo.framework:getUserIdentifiers(source)
  local user = jo.framework.UserClass:get(source)
  if not user or type(user) ~= "table" then
    return nil
  end
  return user:getIdentifiers()
end

--- Returns the current job assigned to a player
---@param source integer (The source ID of the player)
---@return string (Return the job name of the player)
function jo.framework:getJob(source)
  local user = jo.framework.UserClass:get(source)
  return user:getJob()
end

--- Returns the roleplay name (first and last name) of the player
---@param source integer (The source ID of the player)
---@return string (Return the formatted first and last name of the player)
function jo.framework:getRPName(source)
  local user = jo.framework.UserClass:get(source)
  return user:getRPName()
end

--- Checks if a player has sufficient funds of a specified currency type
---@param source integer (The source ID of the player)
---@param amount number (The amount of money the player needs to have <br> {money = 10.5, gold = 3, rol = 1.5})
---@param moneyType? integer|string (`0`: dollar, `1`: gold, `2`: rol <br> default:`1`)
---@param removeIfCan? boolean (Remove the money if the player has enough <br> default:`false`)
---@return boolean (Returns `true` if the player has more money than the amount)
function jo.framework:canUserBuy(source, amount, moneyType, removeIfCan)
  if moneyType == "gold" then
    moneyType = 1
  elseif moneyType == "rol" then
    moneyType = 2
  elseif type(moneyType) ~= "number" then
    moneyType = 0
  end
  if type(amount) == "table" then
    if moneyType == 0 then
      if not amount.money then
        return false, eprint("No money define in the price: %s", json.encode(amount))
      else
        amount = amount.money
      end
    elseif moneyType == 1 then
      if not amount.gold then
        return false, eprint("No gold define in the price: %s", json.encode(amount))
      else
        amount = amount.gold
      end
    elseif moneyType == 2 then
      if not amount.rol then
        return false, eprint("No rol define in the price: %s", json.encode(amount))
      else
        amount = amount.rol
      end
    end
  end
  local user = jo.framework.UserClass:get(source)
  return user:canBuy(amount, moneyType, removeIfCan)
end

--- A function that checks if a player can pay multiple prices
---@param source integer (The source ID of the player)
---@param prices table (The prices to check)
---@param removeIfCan? boolean (Remove the prices if the player can pay)
---@return boolean (Return `true` if the player can pay the prices)
---@return boolean, number (Return `true` if the player can pay the prices and the index of the price that the player can't pay)
---@ignore
function jo.framework:canUserPayWith(source, prices, removeIfCan)
  if type(prices) ~= "table" then
    eprint("jo.framework:canUserBuyMultiples: Wrong prices type. Need to be a table")
    eprint("Use jo.framework:canUserBuy() instead")
    return false
  end
  if table.type(prices) ~= "array" then prices = { prices } end
  for i = 1, #prices do
    local price = prices[i]
    if price.item then
      if not jo.framework:canUseItem(source, price.item, price.quantity or 1, price.meta, false) then
        return false, i
      end
    elseif price.money then
      if not jo.framework:canUserBuy(source, price.money, 0, false) then
        return false, i
      end
    elseif price.gold then
      if not jo.framework:canUserBuy(source, price.gold, 1, false) then
        return false, i
      end
    elseif price.rol then
      if not jo.framework:canUserBuy(source, price.rol, 2, false) then
        return false, i
      end
    end
  end

  if not removeIfCan then return true, 0 end

  for i = 1, #prices do
    local price = prices[i]
    if price.item and not price.keep then
      jo.framework:removeItem(source, price.item, price.quantity or 1, price.meta)
    elseif price.money then
      jo.framework:removeMoney(source, price.money, 0)
    elseif price.gold then
      jo.framework:removeMoney(source, price.gold, 1)
    elseif price.rol then
      jo.framework:removeMoney(source, price.rol, 2)
    end
  end

  return true, 0
end

--- A function to give money to a player
---@param source integer (The source ID of the player)
---@param amount number (The amount of money to add)
---@param moneyType? integer (`0`: dollar, `1`: gold, `2`: rol <br> default:`0`)
---@return boolean (Return `true` if the money is successfully added)
function jo.framework:addMoney(source, amount, moneyType)
  local user = jo.framework.UserClass:get(source)
  return user:addMoney(amount, moneyType)
end

--- A function to remove money from a player's account
---@param source integer (The source ID of the player)
---@param amount number (The amount of money to remove)
---@param moneyType? integer (`0`: dollar, `1`: gold, `2`: rol <br> default:`0`)
---@return boolean (Return `true` if the money is successfully removed)
function jo.framework:removeMoney(source, amount, moneyType)
  local user = jo.framework.UserClass:get(source)
  return user:removeMoney(amount, moneyType)
end

--- A function to remove an item from a player's inventory if they have enough quantity
---@param source integer (The source ID of the player)
---@param item string (The name of the item to remove)
---@param quantity integer (The quantity of the item to remove)
---@param meta? table (The metadata of the item)
---@return boolean (Return `true` if the item is successfully removed)
function jo.framework:removeItem(source, item, quantity, meta)
  return self:canUseItem(source, item, quantity, meta, true)
end

--- Converts a value to a percentage (between 0-1) whether input is in percentage or decimal form
---@param value number (The value to convert to percentage)
---@return number (Return the value as a decimal between -1 and 1)
---@autodoc:config ignore:true
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
    local clothes = formatComponentData(data)
    if clothes and (not clothes.palette or clothes.palette == 0) then
      clothes.palette = nil
      clothes.tint0 = nil
      clothes.tint1 = nil
      clothes.tint2 = nil
    end
    clothesList[cat] = clothes
  end
  return clothesList
end

--- Extracts the component hash from a data table if it's the only property
---@param data table (The component data to process)
---@return any (Return the hash if it's the only property, otherwise return the original data)
---@autodoc:config ignore:true
function jo.framework:extractComponentHashIfAlone(data)
  if type(data) ~= "table" then return data end
  if table.count(data) > 1 then return data end
  if not data.hash then return data end
  return data.hash
end

--- Converts framework-specific clothing data to a standardized format
---@param clothes table (The framework-specific clothes data)
---@return table (Return clothes data with standardized keys and structure)
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

--- Converts standardized clothing data back to framework-specific format
---@param standard table (The standardized clothes data)
---@return table (Return clothes data with framework-specific keys)
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

--- Converts framework-specific skin data to a standardized format
---@param skin table (The framework-specific skin data)
---@return table (Return skin data with standardized keys for components, overlays, and expressions)
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

--- Converts standardized skin data back to framework-specific format
---@param standard table (The standardized skin data)
---@return table (Return skin data with framework-specific keys)
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

--- Save new clothes.
--- The function has two ways to work:
--- - With 2 arguments to save multiple clothes
--- - With 3 arguments to save one piece of clothing
---@param source integer (The source ID of the player)
---@param _clothes table (The list of clothes to apply or the category name)
---@param value? table (The clothing data if updating a single category)
function jo.framework:updateUserClothes(source, _clothes, value)
  if value then
    _clothes = { [_clothes] = formatComponentData(value) }
  end
  local clothes = self:revertClothes(_clothes)
  self:updateUserClothesInternal(source, clothes)
end

--- Retrieves a player's clothing data with standardized category names
---@param source integer (The source ID of the player)
---@return table (Return the list of clothes with standardized categories and properties)
function jo.framework:getUserClothes(source)
  local clothes = self:getUserClothesInternal(source)
  if table.isEmpty(clothes) then return {} end
  return self:standardizeClothes(clothes)
end

--- Retrieves a player's skin data with standardized properties and formatting
---@param source integer (The source ID of the player)
---@return table (Return the skin data)
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

--- Save new skin values.
--- The function has two ways to work:
--- - With 3 arguments to save multiple skin data
--- - With 4 arguments to save only one skin data
---@param source integer (The source ID of the player)
---@param skinData table (The list of skin data with category for key and skin data for value)
---@param category string (The category of the skin data)
---@param data table (The skin data)
---@param overwrite? boolean (If `true`, the new value overwrites the previous skin. Else, it's merged)
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

-- -----------
-- END POWER UP FUNCTIONS
-- -----------

-- -----------
-- LOAD CUSTOM FUNCTIONS
-- -----------
jo.framework:loadFile("_custom", "UserClass")
jo.framework:loadFile("_custom", "FrameworkClass")

jo.framework:loadFile("server")
jo.framework:loadFile("_custom", "server")

-- -----------
-- END LOAD CUSTOM FUNCTIONS
-- -----------
