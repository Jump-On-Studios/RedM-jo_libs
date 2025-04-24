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
