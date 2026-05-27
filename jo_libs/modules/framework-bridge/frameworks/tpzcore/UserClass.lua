--------------------------------------------------
-- USER CLASS                                   --
--------------------------------------------------

local TPZ = exports.tpz_core:getCoreAPI()

function jo.framework.UserClass:get(source)

  if not tonumber(source) then
    return false, eprint("jo.framework.UserClass:get() -> source value is wrong:", GetValue(source, "nil"))
  end

  local user = {}
  setmetatable(user, self)
  self.__index = self
  self.source = tonumber(source)

  local data = TPZ.GetPlayer(self.source)

  if not data then
    return false, eprint("User doesn't exist. source:", self.source)
  end

  if not data.loaded() then
    return false, eprint("User is on session, character is not selected.", self.source)
  end

  self.data = data
  return user

end

function jo.framework.UserClass:getIdentifiers()

  local identifier     = self.data.getIdentifier()
  local charIdentifier = self.data.getCharacterIdentifier()

  return { identifier = identifier, charid = charIdentifier }
end

function jo.framework.UserClass:getJob()
  return self.data.getJob()
end

function jo.framework.UserClass:getJobGrade()
  return self.data.getJobGrade()
end

function jo.framework.UserClass:getGroup()
  return self.data.getGroup()
end

function jo.framework.UserClass:getIdentityId() -- returns a unique identity id for passports, etc.
  return self.data.getIdentityId()
end

function jo.framework.UserClass:getRPName()
  return ("%s %s"):format(self.data.getFirstName(), self.data.getLastName())
end

-- Accounts
function jo.framework.UserClass:getMoney(account)
  return self.data.getAccount(account)
end

function jo.framework.UserClass:removeMoney(amount, account)
  return self.data.removeAccount(account, amount)
end

function jo.framework.UserClass:addMoney(amount, account)
  return self.data.addAccount(account, amount)
end
