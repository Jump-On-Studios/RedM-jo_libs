-------------
-- FRAMEWORK CLASS
-------------

-------------
-- USER CLASS
-------------

---@param source integer the player ID
---@return table user User data
function jo.framework.UserClass:get(source)
  self = table.copy(jo.framework.UserClass)
  self.source = tonumber(source)
  local user = promise.new()
  TriggerEvent("redemrp:getPlayerFromId", self.source, function(_user)
    user:resolve(_user)
  end)
  self.data = Citizen.Await(user)
  return self
end

---@param moneyType integer 0: money, 1: gold, 2: rol
---@return number
function jo.framework.UserClass:getMoney(moneyType)
  moneyType = GetValue(moneyType, 0)
  if moneyType == 0 then
    return self.data.getMoney()
  elseif moneyType == 1 then
    return self.data.getGold()
  elseif moneyType == 2 then
    oprint("Rol in not supported by your Framework")
    oprint("Please check jo_libs docs to add this feature")
    return 0
  end
  return 0
end

---@param amount number amount to remove
---@param moneyType integer 0: money, 1: gold, 2: rol
---@return boolean `true` if the money removed
function jo.framework.UserClass:removeMoney(amount, moneyType)
  moneyType = GetValue(moneyType, 0)
  if moneyType == 0 then
    return self.data.removeMoney(amount)
  elseif moneyType == 1 then
    return self.data.removeGold(amount)
  elseif moneyType == 2 then
    oprint("Rol in not supported by your Framework")
    oprint("Please check jo_libs docs to add this feature")
  end
  return false
end

---@param amount number amount to remove
---@param moneyType integer 0: money, 1: gold, 2: rol
---@return boolean `true` if the money added
function jo.framework.UserClass:addMoney(amount, moneyType)
  moneyType = GetValue(moneyType, 0)
  if moneyType == 0 then
    return self.data.addMoney(amount)
  elseif moneyType == 1 then
    return self.data.addGold(amount)
  elseif moneyType == 2 then
    oprint("Rol in not supported by your Framework")
    oprint("Please check jo_libs docs to add this feature")
  end
  return false
end

---@return table identifiers player's identifiers
function jo.framework.UserClass:getIdentifiers()
  return {
    identifier = self.data.getIdentifier(),
    charid = self.data.getSessionVar("charid")
  }
end

---@return string job player's job
function jo.framework.UserClass:getJob()
  return self.data.getJob()
end

---@return string name player's name
function jo.framework.UserClass:getRPName()
  return ("%s %s"):format(GetValue(self.data.firstname, ""), GetValue(self.data.lastname, ""))
end

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
  local clothes = MySQL.scalar.await("SELECT clothes FROM clothes WHERE identifier=? AND charid=?;", { user.identifier, user.charid })
  return UnJson(clothes)
end

function jo.framework:updateUserClothesInternal(source, clothes, overwrite)
  local identifiers = self:getUserIdentifiers(source)
  MySQL.scalar("SELECT clothes FROM clothes WHERE identifier=? AND charid=?;", { identifiers.identifier, identifiers.charid }, function(oldClothes)
    local decoded = UnJson(oldClothes)
    if overwrite then
      decoded = clothes
    else
      table.merge(decoded, clothes)
    end
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
  return true
end

function jo.framework:getUserSkinInternal(source)
  local user = self.UserClass:get(source)
  if not user then return {} end
  local identifiers = user:getIdentifiers()
  local skin = MySQL.scalar.await("SELECT skin FROM skins WHERE identifier=? AND charid=?;", { identifiers.identifier, identifiers.charid })

  return UnJson(skin)
end

function jo.framework:updateUserSkinInternal(source, skin, overwrite)
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

function jo.framework:createUser(source, data, spawnCoordinate, isDead)
  return {}
end

AddEventHandler("redemrp:selectCharacter", function()
  local source = source
  Wait(1000)
  ExecCharacterSelectedCallback(source, isNew)
end)
