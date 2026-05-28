-------------
-- FRAMEWORK CLASS
-------------
---
jo.file.load("@frp_lib.library.linker")

local Proxy = module("frp_lib", "lib/Proxy")
local API = Proxy.getInterface("API")

jo.framework.core = API

-------------
-- VARIABLES
-------------

-------------
-- END VARIABLES
-------------

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

---@return number jobGrade player's job grade
function jo.framework.UserClass:getJobGrade()
  return 0
end

---@return string name player's name
function jo.framework.UserClass:getRPName()
  local User = self.data
  local character = User:GetCharacter()
  return character:GetFullName()
end

-------------
-- SKIN & CLOTHES
-------------

local eMetapedBodyApparatusTypeToStr = {
  [-1] = "Invalid",
  [0] = "hair",
  [1] = "Heads",
  [2] = "BodiesLower",
  [3] = "BodiesUpper",
  [4] = "teeth",
  [5] = "Eyes",
  [6] = "hats",
  [7] = "shirts_full",
  [8] = "vests",
  [9] = "coats",
  [10] = "coats_closed",
  [11] = "pants",
  [12] = "boots",
  [13] = "boot_accessories",
  [14] = "cloaks",
  [15] = "chaps",
  [16] = "badges",
  [17] = "masks",
  [18] = "spats",
  [19] = "neckwear",
  [20] = "accessories",
  [21] = "jewelry_rings_right",
  [22] = "jewelry_rings_left",
  [23] = "jewelry_bracelets",
  [24] = "gauntlets",
  [25] = "neckties",
  [26] = "loadouts",
  [27] = "suspenders",
  [28] = "satchels",
  [29] = "gunbelts",
  [30] = "belts",
  [31] = "belt_buckles",
  [32] = "holsters_left",
  [33] = "ponchos",
  [34] = "armor",
  [35] = "eyewear",
  [36] = "gloves",
  [37] = "gunbelt_accs",
  [38] = "skirts",
  [39] = "beards_complete",
  [40] = "hair_accessories",
}

local function getShopitemAnyByMetapedBodyApparatus(metapedBodyApparatus)
  local dbLayerRoot = exports.frp_appearance:mp_peds_components()

  local type = metapedBodyApparatus.type
  local gender = metapedBodyApparatus.gender
  local id = metapedBodyApparatus.id
  local styleId = metapedBodyApparatus.styleId

  local dbLayerType = dbLayerRoot[type + 1]

  if dbLayerType ~= nil then
    local dbLayerGender = dbLayerType[gender]

    if dbLayerGender ~= nil then
      local dbLayerStyle = dbLayerGender[id]

      if dbLayerStyle ~= nil then
        local shopitem = dbLayerStyle[styleId]

        if shopitem ~= nil then
          return shopitem
        end
      end
    end
  end
end

---A function to standardize the skin data
---@param skin table skin data with framework keys
---@return table skin skin data with standard keys
function jo.framework:standardizeSkinInternal(skin)
  return skin
end

---A function to reversed the skin data
---@param standard table standard skin data
---@return table skin framework skin data
function jo.framework:revertSkinInternal(standard)
  return standard
end

---A function to standardize the clothes data
---@param clothes table standard clothes data
---@return table clothes framework clothes data
function jo.framework:standardizeClothesInternal(clothes)
  return clothes
end

---A function to revert a standardize clothes table
---@param standard table clothes with standard keys
---@return table clothes clothes with framework keys
function jo.framework:revertClothesInternal(standard)
  return standard
end

function jo.framework:getUserClothesInternal(source)
  local clothes = {}
  local user = self.core.GetUserFromSource(source)
  local character = user:GetCharacter()
  local outfitId = character.outfitId
  local gender = (character.isMale == 0 or not character.isMale) and 2 or 1

  local res = MySQL.scalar.await("SELECT `apparels` FROM `character_outfit` WHERE id = ?", { outfitId })

  if type(res) == "string" then
    res = json.decode(res)
  end

  for t, item in pairs(res) do
    local apparatusType = tonumber(t)
    local itemHash = getShopitemAnyByMetapedBodyApparatus(
      {
        type = apparatusType,
        gender = gender,
        id = tonumber(item.id) or 1,
        styleId = tonumber(item.styleId) or 1
      }
    )

    local typeHash = eMetapedBodyApparatusTypeToStr[apparatusType]

    if itemHash then
      local itemHashKey = type(itemHash) == "number" and itemHash or GetHashKey(itemHash)
      clothes[typeHash] = itemHashKey
    end
  end
  if not clothes then return {} end
  clothes = UnJson(clothes)
  local clothesStandardized = jo.framework:standardizeClothes(clothes)

  return clothesStandardized
end

function jo.framework:updateUserClothesInternal(source, clothes, overwrite)
  -- #TODO
end

function jo.framework:getUserSkinInternal(source)
  -- #TODO
end

function jo.framework:updateUserSkinInternal(source, skin, overwrite)
  -- #TODO
end

function jo.framework:createUser(source, data, spawnCoordinate, isDead)
  -- #TODO
end
