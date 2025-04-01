-------------
-- USER CLASS
-------------
local RedEM = exports["redem_roleplay"]:RedEM()

local UserClass = {}

---@param source integer the player ID
---@return table user User data
function UserClass:get(source)
  self = table.copy(UserClass)
  self.source = tonumber(source)
  self.data = RedEM.GetPlayer(self.source)
  if not self.data then
    return false, eprint("User doesn't exist. source:", self.source)
  end
  return self
end

---@param moneyType integer 0: money, 1: gold, 2: rol
---@return number
function UserClass:getMoney(moneyType)
  moneyType = GetValue(moneyType, 0)
  if moneyType == 0 then
    return self.data.money
  elseif moneyType == 1 then
    oprint("Gold in not supported by your Framework")
    oprint("Please check jo_libs docs to add this feature")
    return 0
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
  amount = math.abs(GetValue(amount, 0))
  moneyType = GetValue(moneyType, 0)
  if moneyType == 0 then
    return self.data.RemoveMoney(amount)
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
function UserClass:addMoney(amount, moneyType)
  amount = math.abs(GetValue(amount, 0))
  moneyType = GetValue(moneyType, 0)
  if moneyType == 0 then
    return self.data.AddMoney(amount)
  elseif moneyType == 1 then
    oprint("Gold in not supported by your Framework")
    oprint("Please check jo_libs docs to add this feature")
  elseif moneyType == 2 then
    oprint("Roll in not supported by your Framework")
    oprint("Please check jo_libs docs to add this feature")
  end
  return false
end

---@return table identifiers player's identifiers
function UserClass:getIdentifiers()
  return {
    identifier = self.data.identifier,
    charid = self.data.charid
  }
end

---@return string job player's job
function UserClass:getJob()
  return self.data.job
end

---@return string name player's name
function UserClass:getRPName()
  return ("%s %s"):format(GetValue(self.data.firstname, ""), GetValue(self.data.lastname, ""))
end

return UserClass
