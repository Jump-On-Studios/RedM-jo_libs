-------------
-- USER CLASS
-------------

local UserClass = {}

---@param source integer the player ID
---@return table user User data
function UserClass:get(source)
  self = table.copy(UserClass)
  self.source = tonumber(source)
  self.data = {}
  return self
end

---@param moneyType integer 0: money, 1: gold, 2: rol
---@return number
function UserClass:getMoney(moneyType)
  return 0
end

---@param amount number amount to remove
---@param moneyType integer 0: money, 1: gold, 2: rol
---@return boolean `true` if the money removed
function UserClass:removeMoney(amount, moneyType)
  return false
end

---@param amount number amount to remove
---@param moneyType integer 0: money, 1: gold, 2: rol
---@return boolean `true` if the money added
function UserClass:addMoney(amount, moneyType)
  return false
end

---@return table identifiers player's identifiers
function UserClass:getIdentifiers()
  return {
    identifier = "",
    charid = 0
  }
end

---@return string job player's job
function UserClass:getJob()
  return ""
end

---@return string name player's name
function UserClass:getRPName()
  return ""
end

return UserClass
