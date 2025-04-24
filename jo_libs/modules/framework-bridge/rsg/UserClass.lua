-------------
-- USER CLASS
-------------

local RSGCore = exports["rsg-core"]:GetCoreObject()

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

  local data = RSGCore.Functions.GetPlayer(self.source)
  if not data then
    return false, eprint("User doesn't exist. source:", self.source)
  end

  self.data = data
  return user
end

function jo.framework.UserClass:getMoney(moneyType)
  if moneyType == 0 then
    return self.data.Functions.GetMoney("cash")
  elseif moneyType == 1 then
    oprint("Gold in not supported by your Framework")
    oprint("Please check jo_libs docs to edit jo.framework.UserClass:getMoney() function")
    return 0
  elseif moneyType == 2 then
    oprint("Roll in not supported by your Framework")
    oprint("Please check jo_libs docs to edit jo.framework.UserClass:getMoney() function")
    return 0
  end
end

function jo.framework.UserClass:removeMoney(amount, moneyType)
  if moneyType == 0 then
    return self.data.Functions.RemoveMoney("cash", amount)
  elseif moneyType == 1 then
    oprint("The Gold was not removed - Gold in not supported by your Framework")
    oprint("Please check jo_libs docs to edit jo.framework.UserClass:removeMoney() function")
  elseif moneyType == 2 then
    oprint("The Roll was not removed - Roll in not supported by your Framework")
    oprint("Please check jo_libs docs to edit jo.framework.UserClass:removeMoney() function")
  end
  return false
end

function jo.framework.UserClass:addMoney(amount, moneyType)
  if moneyType == 0 then
    return self.data.Functions.AddMoney("cash", amount)
  elseif moneyType == 1 then
    oprint("Gold in not supported by your Framework")
    oprint("Please check jo_libs docs to edit jo.framework.UserClass:addMoney() function")
  elseif moneyType == 2 then
    oprint("Roll in not supported by your Framework")
    oprint("Please check jo_libs docs to edit jo.framework.UserClass:addMoney() function")
  end
  return false
end

function jo.framework.UserClass:getIdentifiers()
  return {
    identifier = self.data.PlayerData.citizenid,
    charid = 0
  }
end

function jo.framework.UserClass:getJob()
  return self.data.PlayerData.job.name
end

function jo.framework.UserClass:getRPName()
  return ("%s %s"):format(self.data.PlayerData.charinfo.firstname, self.data.PlayerData.charinfo.lastname)
end
