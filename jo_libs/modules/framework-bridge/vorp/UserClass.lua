-------------
-- USER CLASS
-------------

local Core = exports.vorp_core:GetCore()

local UserClass = {}

---Init the UserClass
---@param source integer Player server ID
---@return any user UserClass if the user exists
function UserClass:get(source)
  if not tonumber(source) then
    return false, eprint("UserClass:get() -> source value is wrong:", GetValue(source, "nil"))
  end

  local user = {}
  setmetatable(user, self)
  self.__index = self
  self.source = tonumber(source)

  local data = Core.getUser(self.source)
  if not data then
    return false, eprint("User doesn't exist. source:", self.source)
  end

  self.data = data.getUsedCharacter
  return user
end

---Get the money of user
---@param moneyType? integer 0: money, 1: gold, 2: rol (default: 0)
---@return number amount the amount of money
function UserClass:getMoney(moneyType)
  moneyType = GetValue(moneyType, 0)
  if moneyType == 0 then
    return self.data.money
  elseif moneyType == 1 then
    return self.data.gold
  elseif moneyType == 2 then
    return self.data.rol
  end
  return 0
end

---@param amount number amount to add
---@param moneyType integer 0: money, 1: gold, 2: rol
function UserClass:addMoney(amount, moneyType)
  moneyType = GetValue(moneyType, 0)
  return self.data.addCurrency(moneyType, amount)
end

---Remove the amount of player's money
---@param amount number amount to remove
---@param moneyType? integer 0: money, 1: gold, 2: rol
function UserClass:removeMoney(amount, moneyType)
  moneyType = GetValue(moneyType, 0)
  return self.data.removeCurrency(moneyType, amount)
end

function UserClass:getIdentifiers()
  return {
    identifier = self.data.identifier,
    charid = self.data.charIdentifier
  }
end

---@return string job
function UserClass:getJob()
  return self.data.job
end

---@return string name
function UserClass:getRPName()
  return ("%s %s"):format(self.data.firstname, self.data.lastname)
end

return UserClass
