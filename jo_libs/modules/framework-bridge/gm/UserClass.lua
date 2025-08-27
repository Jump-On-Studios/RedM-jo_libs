-------------
-- USER CLASS
-------------

---Init the jo.framework.UserClass
---@param source integer Player server ID
---@return any user jo.framework.UserClass if the user exists
function jo.framework.UserClass:get(source)
  if not tonumber(source) then
    return false, eprint("jo.framework.UserClass:get() -> source value is wrong:", GetValue(source, "nil"))
  end

  local user = {}
  setmetatable(user, self)
  self.__index = self
  self.source = tonumber(source)

  local data = exports.gm_core:GetPlayerSession(self.source)
  if not data then
    return false, eprint("User doesn't exist. source:", self.source)
  end

  self.data = data
  return user
end

function jo.framework.UserClass:getMoney(moneyType)
  if moneyType == 0 then
    return self.data.money.cash
  elseif moneyType == 1 then
    return self.data.money.gold
  elseif moneyType == 2 then
    oprint("Roll in not supported by your Framework")
    oprint("Please check jo_libs docs to edit jo.framework.UserClass:getMoney() function")
    return 0
  end
end

function jo.framework.UserClass:removeMoney(amount, moneyType)
  if moneyType == 0 then
    return exports.gm_core:RemoveMoney("cash", amount)
  elseif moneyType == 1 then
    return exports.gm_core:RemoveMoney(self.source, "gold", amount)
  elseif moneyType == 2 then
    oprint("The Roll was not removed - Roll in not supported by your Framework")
    oprint("Please check jo_libs docs to edit jo.framework.UserClass:removeMoney() function")
  end
  return false
end

function jo.framework.UserClass:addMoney(amount, moneyType)
  if moneyType == 0 then
    return exports.gm_core:AddMoney(self.source, "cash", amount)
  elseif moneyType == 1 then
    return exports.gm_core:AddMoney(self.source, "gold", amount)
  elseif moneyType == 2 then
    oprint("Roll in not supported by your Framework")
    oprint("Please check jo_libs docs to edit jo.framework.UserClass:addMoney() function")
  end
  return false
end

function jo.framework.UserClass:getIdentifiers()
  return {
    identifier = self.data.characterid,
    charid = 0
  }
end

function jo.framework.UserClass:getJob()
  return self.data.job.name
end

function jo.framework.UserClass:getRPName()
  return ("%s %s"):format(self.data.firstname, self.data.lastname)
end
