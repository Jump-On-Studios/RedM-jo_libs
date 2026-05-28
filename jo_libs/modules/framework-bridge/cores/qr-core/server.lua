-------------
-- FRAMEWORK CLASS
-------------
local QRCore = exports["qr-core"]:GetCoreObject()

jo.framework.core = QRCore

-------------
-- USER CLASS
-------------

---@param source integer the player ID
---@return table user User data
function jo.framework.UserClass:get(source)
  self = table.copy(jo.framework.UserClass)
  self.source = tonumber(source)
  self.data = QRCore.Functions.GetPlayer(self.source)
  return self
end

---@param moneyType integer 0: money, 1: gold, 2: rol
---@return number
function jo.framework.UserClass:getMoney(moneyType)
  moneyType = GetValue(moneyType, 0)
  if moneyType == 0 then
    return self.data.Functions.GetMoney("cash")
  elseif moneyType == 1 then
    oprint("Gold in not supported by your Framework")
    oprint("Please check jo_libs docs to add this feature")
  elseif moneyType == 2 then
    oprint("Rol in not supported by your Framework")
    oprint("Please check jo_libs docs to add this feature")
  end
  return 0
end

---@param amount number amount to remove
---@param moneyType integer 0: money, 1: gold, 2: rol
---@return boolean `true` if the money removed
function jo.framework.UserClass:removeMoney(amount, moneyType)
  if moneyType == 0 then
    return self.data.Functions.RemoveMoney("cash", amount)
  elseif moneyType == 1 then
    oprint("The Gold was not removed - Gold in not supported by your Framework")
    oprint("Please check jo_libs docs to add this feature")
  elseif moneyType == 2 then
    oprint("The Rol was not removed - Rol in not supported by your Framework")
    oprint("Please check jo_libs docs to add this feature")
  end
  return false
end

---@param amount number amount to remove
---@param moneyType integer 0: money, 1: gold, 2: rol
---@return boolean `true` if the money added
function jo.framework.UserClass:addMoney(amount, moneyType)
  if moneyType == 0 then
    return self.data.Functions.AddMoney("cash", amount)
  elseif moneyType == 1 then
    oprint("The Gold was not removed - Gold in not supported by your Framework")
    oprint("Please check jo_libs docs to add this feature")
  elseif moneyType == 2 then
    oprint("The Rol was not removed - Rol in not supported by your Framework")
    oprint("Please check jo_libs docs to add this feature")
  end
  return false
end

---@return table identifiers player's identifiers
function jo.framework.UserClass:getIdentifiers()
  return {
    identifier = self.data.PlayerData.citizenid,
    charid = 0
  }
end

---@return string job player's job
function jo.framework.UserClass:getJob()
  return self.data.PlayerData.job.name
end

---@return number jobGrade
function jo.framework.UserClass:getJobGrade()
  return self.data.job.grade.level
end

---@return string name player's name
function jo.framework.UserClass:getRPName()
  return ("%s %s"):format(self.data.PlayerData.charinfo.firstname, self.data.PlayerData.charinfo.lastname)
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
  local clothes = MySQL.scalar.await("SELECT clothes FROM playerclothe WHERE citizenid=?", { user.identifier })
  return UnJson(clothes)
end

function jo.framework:updateUserClothesInternal(source, clothes, overwrite)
  local identifiers = self:getUserIdentifiers(source)
  if overwrite then
    MySQL.update("UPDATE playerskins SET clothes=? WHERE citizenid=?", { json.encode(clothes), identifiers.identifier })
  else
    MySQL.scalar("SELECT clothes FROM playerclothe WHERE citizenid=?", { identifiers.identifier }, function(oldClothes)
      local decoded = UnJson(oldClothes)
      table.merge(decoded, clothes)
      MySQL.update("UPDATE playerclothe SET clothes=? WHERE citizenid=?", { json.encode(decoed), identifiers.identifier })
    end)
  end
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

AddEventHandler("qr-multicharacter:server:loadUserData", function()
  local source = source
  Wait(1000)
  ExecCharacterSelectedCallback(source, isNew)
end)
