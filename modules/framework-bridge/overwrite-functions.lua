-------------
-- Add your Framework function here
-------------

OWFramework = {}
OWFramework.User = {}

local Core

function OWFramework.initFramework(self)
    Core = exports.core:getSharedObject()
    return Core
end

function OWFramework.get()
    return "core"
end

function OWFramework.User.getMoney(source, moneyType)
    local character = Core.GetCharacterFromPlayerId(source)
    local user = Core.GetUserFromPlayerId(source)
    local currency = moneyType == 0 and (character.getMoney()) or (moneyType == 1 and user.getGold()) or 0
    return currency
end

function OWFramework.User.addMoney(source, amount, moneyType)
    print(Core)
end

function OWFramework.User.removeMoney(source, amount, moneyType)
    print(Core)
end

-- Config.CanBuy = function(source, price, moneyType)
-- 	-- moneyType = 0 : dolar
-- 	-- moneyType = 1 : goldcoin
-- 	local character = Config.GetIdentifier(source)

-- 	if not character then return false end

-- 	local user = Core.GetUserFromPlayerId(source)

-- 	if not user then return false end

-- 	local isIndio = Core.IsCharacterGroupMemberRole('Índio', character.id, -1)

-- 	if isIndio and moneyType == 0 then
-- 		price = price / 10
-- 	end

-- 	if moneyType == 0 and character.getMoney() >= price then
-- 		return true
-- 	elseif moneyType == 1 and user.getGold() >= price then
-- 		return true
-- 	else
-- 		return false
-- 	end
-- end