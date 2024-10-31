-------------
-- Add your Framework function here
-------------

OWFramework = {}
OWFramework.User = {}

---@type Core
local Core

function OWFramework.get()
    return "custom"
end

function OWFramework.initFramework(self)
    self.core = exports.core:getSharedObject()
    Core = self.core
end


function OWFramework.User.getIdentifiers(source)
    local character = Core.GetCharacterFromPlayerId(source)
    local user = Core.GetUserFromPlayerId(source)

    return {
        id = tonumber(user?.id),
        charid = tonumber(character?.id),
    }
end

function OWFramework.registerUseItem(item, closeAfterUsed, callback)
    Core.RegisterUsableItem(item, function(source, item)
        local character = Core.GetCharacterFromPlayerId(source)
        if character then
            if closeAfterUsed then
                character.triggerEvent('ox_inventory:closeInventory')
            end

            callback(source, item)
        end
    end)
end

function OWFramework.User.getJob(source)
    local character = Core.GetCharacterFromPlayerId(source)
    local jobs = table.map(character?.roles, function(v, i)
        return v.group.name
    end)

    return jobs
end

function OWFramework.createInventory(id,label,definition)
    
end

function OWFramework.canUseItem(source,item,amount,meta,remove)
	local character = Core.GetCharacterFromPlayerId(source)
	local itemData = exports.inventory:GetItem(source, item, nil, false)
	if itemData and itemData.count >= amount then
		if remove then
			character.removeInventoryItem(item, amount)
		end
		return true
	end
end

function OWFramework.User.getRPName(source)
    local character = Core.GetCharacterFromPlayerId(source)
    return character.getName()
    -- return OWFramework.User.getIdentifiers(source).getName()
end

function OWFramework.User.getMoney(source, moneyType)
    local character = Core.GetCharacterFromPlayerId(source)
    local user = Core.GetUserFromPlayerId(source)

    local money = character.getMoney()
    local gold = user.getGold()

    local resultTypes = {
        [0] = money,
        [1] = gold,
        [2] = 0
    }

    return resultTypes[moneyType]
end

function OWFramework.User.addMoney(self, amount, moneyType)
    local character = Core.GetCharacterFromPlayerId(self.source)
    local user = Core.GetUserFromPlayerId(self.source)
    if moneyType == 0 and (character.addMoney(amount)) or (moneyType == 1 and user.addGold(amount)) or 0 then end
end



function OWFramework.User.removeMoney(self, amount, moneyType)
    local character = Core.GetCharacterFromPlayerId(self.source)
    local user = Core.GetUserFromPlayerId(self.source)
    if moneyType == 0 and (character.removeMoney(amount)) or (moneyType == 1 and user.removeGold(amount)) or 0 then end
end

function OWFramework.getUserClothes(source)
    local waiter = promise.new()
    local character = Core.GetCharacterFromPlayerId(source)

    if character then
        MySQL.Async.fetchAll('SELECT * FROM characters_outfit WHERE `ownerId` = @ownerId', {
            ownerId = character.id
        }, function (clothes)
            if clothes[1] ~= nil then
                waiter:resolve(json.decode(clothes[1].clothes))
            else
				waiter:resolve(false)
            end
        end)
    end

    return Citizen.Await(waiter)
end

function OWFramework.updateUserClothes(source, clothesOrCategory, value)
    local character = Core.GetCharacterFromPlayerId(source)
    if character then
        local dadosTraje = clothesOrCategory
        for chave, valor in pairs(dadosTraje) do
            if type(valor) == "table" and valor.hash ~= nil then
                dadosTraje[chave] = valor.hash
            end
        end
        dadosTraje = json.encode(dadosTraje)

        MySQL.Async.execute("UPDATE characters_outfit SET `clothes`=@encode WHERE `ownerId`=@characterId;", { encode = dadosTraje, characterId = character.id})
    end
end

function OWFramework.getUserSkin(source)
    local result = {
        overlays = {}
    }

    local awaiter = promise.new()

    local character = Core.GetCharacterFromPlayerId(source)
    if character ~= nil then
        MySQL.Async.fetchAll('SELECT * FROM characters_appearance WHERE `characterId` = @characterId', {
            characterId = character.id
        }, function(skins)
            if skins[1] ~= nil then
                local skinStandardized = jo.framework.standardizeSkinKeys(json.decode(skins[1].skin))
                
                if not skinStandardized.teeth then
                    local clothes = jo.framework:getUserClothes(source)
                    if clothes.teeth then
                        skinStandardized.teeth = clothes.teeth
                    end
                end
                result = skinStandardized
            end
            awaiter:resolve(result)
        end)
    else
        awaiter:resolve(result)
    end

    return Citizen.Await(awaiter);
end

function OWFramework.giveItem(source, item, amount, metadata)
    local character = Core.GetCharacterFromPlayerId(source)
    if character then
        return character.addInventoryItem(item, amount, metadata)
    end
    return false
end

function OWFramework.updateUserSkin(...)
    local args = table.pack(...)
    local source, _skin, overwrite = args[1], {}, false

    if type(args[2]) == "string" then
        _skin = { [args[2]] = args[3] }
        overwrite = args[math.max(4, #args)] or overwrite
    else
        _skin = args[2]
        overwrite = args[math.max(3, #args)] or overwrite
    end

    local character = Core.GetCharacterFromPlayerId(source)

    local normalizedSkin = table.copy(_skin)

    for skinKey, skinValue in pairs(_skin) do
        if type(skinValue) == "table" and skinValue.hash and skinKey ~= "overlays" then
            normalizedSkin[skinKey] = skinValue.hash
        end
    end
    MySQL.scalar("SELECT skin from characters_appearance WHERE `characterId`=@characterId", { characterId = character.id }, function(oldSkin)
        local decoded = UnJson(oldSkin)
        if overwrite then
          decoded = _skin
        else
          table.merge(decoded, _skin)
        end
        MySQL.Async.execute("UPDATE characters_appearance SET skin = @skin WHERE `characterId`=@characterId", { characterId = character.id, skin = json.encode(decoded) })
    end)
end

-- subistitui o jo.meServerId pelo id do personagem
jo.hook.registerFilter('jo_me_forceUpdateMe', function(args)
    args[4] = LocalPlayer.state.id
    return args
end, 10)