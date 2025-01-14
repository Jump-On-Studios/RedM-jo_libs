local Core = exports.vorp_core:GetCore()

local UserClass = {}

---Init the UserClass
---@param source integer Player server ID
---@return any user UserClass if the user exists
function UserClass:get(source)
    local user = {}
    setmetatable(user, self)
    self.__index = self

    user.source = tonumber(source)

    local data = Core.getUser(self.source)
    if not data then
        return false, eprint("User doesn't exist. source:", self.source)
    end

    self.data = data.getUsedCharacter()
    return user
end

---Get the money of user
---@param moneyType? integer 0: money, 1: gold, 2: rol (default: 0)
---@return number amount the amount of money
function UserClass:getMoney(moneyType)
    moneyType = moneyType or 0
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
    moneyType = moneyType or 0
    return self.data.addCurrency(moneyType, amount)
end

---Remove the amount of player's money
---@param amount number amount to remove
---@param moneyType? integer 0: money, 1: gold, 2: rol
function UserClass:removeMoney(amount, moneyType)
    moneyType = moneyType or 0
    return self.data.removeCurrency(moneyType, amount)
end

---@param amount number price
---@param moneyType integer 0: money, 1: gold, 2: rol
---@param removeIfCan? boolean (optional) default: false
---@return boolean hasEnough `true` if the player has enough money
---@return boolean isRemoved `true` if the money has been removed successfully
function UserClass:canBuy(amount, moneyType, removeIfCan)
    moneyType = moneyType or 0
    removeIfCan = removeIfCan or false
    if not amount then
        return false, false, eprint("PRICE IS NIL !")
    end
    local money = self:getMoney(moneyType)
    local hasEnough = money >= amount
    if removeIfCan and hasEnough then
        return true, self:removeMoney(amount, moneyType)
    end
    return hasEnough, false
end

---@param amount number amount of gold
function UserClass:giveGold(amount)
    return self:addMoney(amount, 1)
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
