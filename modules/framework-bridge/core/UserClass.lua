-------------
-- USER CLASS
-------------

local Core = exports.core:getSharedObject()

local UserClass = {}

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

  local data = Core.GetCharacterFromPlayerId(self.source)
  if not data then
    return false, eprint("User doesn't exist. source:", self.source)
  end

  self.data = data
  return user
end

---@param moneyType number
---@return number
function UserClass:getMoney(moneyType)
  local character = Core.GetCharacterFromPlayerId(self.source)
  local user = Core.GetUserFromPlayerId(self.source)

  local money = character.getMoney()
  local gold = user.getGold()

  local resultTypes = {
      [0] = money,
      [1] = gold,
  }

  return resultTypes[moneyType] or 0
end

function UserClass:addMoney(source, amount, moneyType)
  local character = Core.GetCharacterFromPlayerId(source)
  local user = Core.GetUserFromPlayerId(source)
  if moneyType == 0 and (character.addMoney(amount)) or (moneyType == 1 and user.addGold(amount)) or 0 then end
end


function UserClass:removeMoney(amount, moneyType)
  local character = Core.GetCharacterFromPlayerId(self.source)
  local user = Core.GetUserFromPlayerId(self.source)
  if moneyType == 0 and (character.removeMoney(amount)) or (moneyType == 1 and user.removeGold(amount)) or 0 then end
end

function UserClass:getIdentifiers()
  local character = Core.GetCharacterFromPlayerId(self.source)
    local user = Core.GetUserFromPlayerId(self.source)

    return {
        id = tonumber(user?.id),
        charid = tonumber(character?.id),
    }
end

function UserClass:getJob()
  local character = Core.GetCharacterFromPlayerId(self.source)
  local jobs = table.map(character?.roles, function(v, i)
      return v.group.name
  end)

  return jobs
end

function UserClass:getRPName()
  local character = Core.GetCharacterFromPlayerId(self.source)
  return character.getName()
end

return UserClass --Should be the last line of the file
