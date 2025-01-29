-------------
-- USER CLASS
-------------

UserClass = UserClass or {}

---@param source integer the player ID
---@return table user User data
function UserClass:get(source)
  self = table.copy(UserClass)
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
function UserClass:getMoney(moneyType)
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
function UserClass:removeMoney(amount, moneyType)
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
function UserClass:addMoney(amount, moneyType)
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
function UserClass:getIdentifiers()
  return {
    identifier = self.data.getIdentifier(),
    charid = self.data.getSessionVar("charid")
  }
end

---@return string job player's job
function UserClass:getJob()
  return self.data.getJob()
end

---@return string name player's name
function UserClass:getRPName()
  return ("%s %s"):format(GetValue(self.data.firstname, ""), GetValue(self.data.lastname, ""))
end

return UserClass
