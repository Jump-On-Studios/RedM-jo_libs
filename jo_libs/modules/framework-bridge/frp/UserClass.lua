-------------
-- USER CLASS
-------------
---

---@param source integer the player ID
---@return table user User data
function jo.framework.UserClass:get(source)
  self = table.copy(jo.framework.UserClass)
  self.source = tonumber(source)
  self.data = jo.framework.core.GetUserFromSource(self.source)

  return self
end

---@param moneyType integer 0: money, 1: gold, 2: rol
---@return number
function jo.framework.UserClass:getMoney(moneyType)
  moneyType = GetValue(moneyType, 0)
  if moneyType == 0 then
    return exports.ox_inventory:GetItem(self.source, "money", nil, true)
  elseif moneyType == 1 then
    local goldStatus, goldAmount = pcall(function()
      return exports.prime_api:getUserCash(self.source)
    end)
    return goldAmount or 0
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
  moneyType = GetValue(moneyType, 0)
  if moneyType == 0 then
    local success = exports.ox_inventory:RemoveItem(self.source, "money", amount + 0.001)
    return success
  elseif moneyType == 1 then
    local success = exports.prime_api:removeUserCash({ self.source, amount, "purchase" })
    return success
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
    local success = exports.ox_inventory:AddItem(self.source, "money", amount + 0.001)
    return success
  elseif moneyType == 1 then
    oprint("Gold in not supported by your Framework")
    oprint("Please check jo_libs docs to add this feature")
  elseif moneyType == 2 then
    oprint("Rol in not supported by your Framework")
    oprint("Please check jo_libs docs to add this feature")
  end
  return false
end

---@return table identifiers player's identifiers
function jo.framework.UserClass:getIdentifiers()
  local User = self.data
  return {
    identifier = User:GetId(),
    charid = User:GetCharacterId()
  }
end

---@return string job player's job
function jo.framework.UserClass:getJob()
  return nil
end

---@return string name player's name
function jo.framework.UserClass:getRPName()
  local User = self.data
  local character = User:GetCharacter()
  return character:GetFullName()
end
