-------------
-- FRAMEWORK CLASS
-------------
local RPX = exports["rpx-core"]:GetObject()

jo.framework.core = RPX

-------------
-- USER CLASS
-------------
---@param source integer the player ID
---@return table user User data
function jo.framework.UserClass:get(source)
  self = table.copy(jo.framework.UserClass)
  self.source = tonumber(source)
  self.data = RPX.GetPlayer(self.source)
  return self
end

---@param moneyType integer 0: money, 1: gold, 2: rol
---@return number
function jo.framework.UserClass:getMoney(moneyType)
  moneyType = GetValue(moneyType, 0)
  if moneyType == 0 then
    return self.data.money.cash
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
  moneyType = GetValue(moneyType, 0)
  if moneyType == 0 then
    return self.data.RemoveMoney("cash", amount)
  elseif moneyType == 1 then
    oprint("Gold in not supported by your Framework")
    oprint("Please check jo_libs docs to add this feature")
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
    return self.data.addMoney("cash", amount)
  elseif moneyType == 1 then
    oprint("Gold in not supported by your Framework")
    oprint("Please check jo_libs docs to add this feature")
  elseif moneyType == 2 then
    oprint("Rol in not supported by your Framework")
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

---@return number jobGrade player's job grade
function jo.framework.UserClass:getJobGrade()
  return self.data.PlayerData.job.rank
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
  local user = self.UserClass:get(source)
  local clothes = user.data.clothes
  return UnJson(clothes)
end

function jo.framework:updateUserClothesInternal(source, clothes, overwrite)
  local user = self.UserClass:get(source)
  local data = user.data.clothes
  if overwrite then
    data = clothes
  else
    table.merge(data, clothes)
  end
  return user.data.SetClothesData(data)
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

AddEventHandler("SERVER:MultiCharacter:SelectCharacter", function()
  local source = source
  ExecCharacterSelectedCallback(source, isNew)
end)
