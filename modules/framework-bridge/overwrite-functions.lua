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

function OWFramework.User.getMoney(source, moneyType)
    local character = Core.GetCharacterFromPlayerId(source)
    local user = Core.GetUserFromPlayerId(source)
    local currency = moneyType == 0 and (character.getMoney()) or (moneyType == 1 and user.getGold()) or 0
    return currency
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

function OWFramework.updateUserClothes(source, clothesOrCategory, value)

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

    if overwrite then
        -- TODO
    else
        -- print(json.encode(_skin, { indent = true }))
        -- print(json.encode(jo.framework.revertSkinKeys(_skin), { indent = true }))
        local normalizedSkin = table.copy(_skin)

        for skinKey, skinValue in pairs(_skin) do
            if skinKey == "overlays" then
                -- todo
                -- for overlayKey, overlayValue in pairs(skinValue) do

                -- end
            elseif type(skinValue) == "table" and skinValue.hash and skinKey ~= "overlays" then
                normalizedSkin[skinKey] = skinValue.hash
            end
        end
        -- print(json.encode(normalizedSkin, { indent = true }))
        MySQL.scalar("SELECT skin from characters_appearance WHERE `characterId`=@characterId", { characterId = character.id }, function(oldSkin)
            local decoded = UnJson(oldSkin)
            table.merge(decoded, _skin)
            MySQL.Async.execute("UPDATE characters_appearance SET skin = @skin WHERE `characterId`=@characterId", { characterId = character.id, skin = json.encode(decoded) })
        end)
    end

    -- print(source, json.encode(_skin, { indent = true }), overwrite)
end

function OWFramework.User.canBuy(self, price, moneyType)
    print(self.source, price, moneyType)
end