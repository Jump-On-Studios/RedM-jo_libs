-------------
-- USER CLASS
-------------
local QRCore = exports["qr-core"]:GetCoreObject()

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

---@return string name player's name
function jo.framework.UserClass:getRPName()
  return ("%s %s"):format(self.data.PlayerData.charinfo.firstname, self.data.PlayerData.charinfo.lastname)
end
