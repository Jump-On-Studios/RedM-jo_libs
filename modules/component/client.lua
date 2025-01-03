jo.component = {}

jo.require("table")
jo.require("timeout")
jo.require("dataview")
jo.require("waiter")
jo.require("utils")

-------------
-- CACHE
-------------
jo.cache.component = {
  color = {},
  getEquiped = {}
}

-------------
-- DATA
-------------
jo.component.data = {}
jo.component.data.order = {
  "ponchos",
  "cloaks",
  "hair_accessories",
  "dresses",
  "gloves",
  "coats",
  "coats_closed",
  "vests",
  "suspenders",
  "neckties",
  "neckwear",
  "shirts_full",
  "spats",
  "gunbelts",
  "gauntlets",
  "holsters_left",
  "loadouts",
  "belt_buckles",
  "belts",
  "skirts",
  "boots",
  "pants",
  "boot_accessories",
  "accessories",
  "satchels",
  "jewelry_rings_right",
  "jewelry_rings_left",
  "jewelry_bracelets",
  "aprons",
  "chaps",
  "badges",
  "gunbelt_accs",
  "eyewear",
  "armor",
  "masks",
  "masks_large",
  "hats",
  "hair",
  "beards_complete",
  "teeth",

  "horse_heads",
  "horse_bodies",
  "horse_blankets",
  "saddle_horns",
  "saddle_stirrups",
  "saddle_lanterns",
  "horse_saddlebags",
  "horse_bedrolls",
  "horse_tails",
  "horse_shoes",
  "horse_mustache",
  "horse_manes",
  "horse_accessories",
  "horse_outfits",
  "horse_saddles",
  "horse_bridles",
}
jo.component.order = jo.component.data.order --deprecated name

jo.component.data.pedClothes = {
  "ponchos",
  "cloaks",
  "hair_accessories",
  "dresses",
  "gloves",
  "coats",
  "coats_closed",
  "vests",
  "suspenders",
  "neckties",
  "neckwear",
  "shirts_full",
  "spats",
  "gunbelts",
  "gauntlets",
  "holsters_left",
  "loadouts",
  "belt_buckles",
  "belts",
  "skirts",
  "boots",
  "pants",
  "boot_accessories",
  "accessories",
  "satchels",
  "jewelry_rings_right",
  "jewelry_rings_left",
  "jewelry_bracelets",
  "aprons",
  "chaps",
  "badges",
  "gunbelt_accs",
  "eyewear",
  "armor",
  "masks",
  "masks_large",
  "hats"
}
jo.component.pedClothes = jo.component.data.pedClothes --deprecated name

jo.component.data.categoryName = {
  [`heads`] = "heads",
  [`bodies_lower`] = "bodies_lower",
  [`bodies_upper`] = "bodies_upper",
  [`eyes`] = "eyes",
  [`neckerchiefs`] = "neckerchiefs"
}
for _, category in pairs(jo.component.data.order) do
  jo.component.data.categoryName[joaat(category)] = category
end
jo.component.categoryName = jo.component.data.categoryName --deprecated name

jo.component.data.wearableStates = {
  shirts_full = {
    -- first digit for collar : 0 = closed/1 = opened
    -- second digit for sleeve : 0 = full/1 = rolled
    [00] = "base",
    [01] = "closed_collar_rolled_sleeve",
    [10] = "open_collar_full_sleeve",
    [11] = "open_collar_rolled_sleeve",
  },
  neckwear = {
    [0] = "base",     --down
    [1] = -1829635046 --up
  },
  boots = {
    [0] = "base",       --upper
    [1] = "under_pants" --under
  },
  loadouts = {
    [0] = "base",       --right
    [1] = "base_right", --left
  },
  vests = {
    [0] = "base",       --upper
    [1] = "under_pants" --under
  },
  hair = {
    [0] = "base",
    [1] = "pomade"
  }
}
jo.component.wearableStates = jo.component.data.wearableStates --deprecated name

jo.component.data.palettes = {
  "metaped_tint_animal",
  "metaped_tint_combined",
  "metaped_tint_combined_leather",
  "metaped_tint_combined_leather",
  "metaped_tint_eye",
  "metaped_tint_generic",
  "metaped_tint_generic_clean",
  "metaped_tint_generic_weathered",
  "metaped_tint_generic_worn",
  "metaped_tint_hair",
  "metaped_tint_hat",
  "metaped_tint_hat_clean",
  "metaped_tint_hat_weathered",
  "metaped_tint_hat_worn",
  "metaped_tint_horse",
  "metaped_tint_horse_leather",
  "metaped_tint_leather",
  "metaped_tint_makeup",
  "metaped_tint_mpadv",
  "metaped_tint_skirt_clean",
  "metaped_tint_skirt_weathered",
  "metaped_tint_skirt_worn",
}
jo.component.palettes = jo.component.data.palettes --deprecated name

jo.component.data.expressions = {
  cheekbonesDepth = 13709,
  cheekbonesHeight = 27147,
  cheekbonesWidth = 43983,
  chinDepth = 58147,
  chinHeight = 15375,
  chinWidth = 50098,
  earlobes = 60720,
  earsAngle = 46798,
  earsDepth = 49261,
  earsHeight = 10308,
  earsWidth = 49231,
  eyebrowDepth = 19153,
  eyebrowHeight = 13059,
  eyebrowWidth = 12281,
  eyelidHeight = 35627,
  eyelidLeft = 52902,
  eyelidRight = 22421,
  eyelidWidth = 7019,
  eyesAngle = 53862,
  eyesDepth = 60996,
  eyesDistance = 42318,
  eyesHeight = 56827,
  faceWidth = 41396,
  headWidth = 34006,
  jawDepth = 7670,
  jawHeight = 36106,
  jawWidth = 60334,
  jawY = 55182,
  mouthDepth = 43625,
  mouthWidth = 61541,
  mouthX = 31427,
  mouthY = 16653,
  noseAngle = 13489,
  noseCurvature = 61782,
  noseHeight = 1013,
  noseSize = 13425,
  noseWidth = 28287,
  nostrilsDistance = 22046,

  upperLipHeight = 6656,
  upperLipWidth = 37313,
  upperLipDepth = 50037,
  lowerLipHeight = 47949,
  lowerLipWidth = 45232,
  lowerLipDepth = 23830,
  mouthConerLeftWidth = 57350,
  mouthConerLeftDepth = 40950,
  mouthConerLeftHeight = 46661,
  mouthConerLeftLipsDistance = 22344,
  mouthConerRightWidth = 60292,
  mouthConerRightDepth = 49299,
  mouthConerRightHeight = 55718,
  mouthConerRightLipsDistance = 9423,

  arms = 46032,
  chest = 27779,
  hip = 49787,
  neckDepth = 60890,
  neckWidth = 36277,
  shoulderBlades = 18046,
  shoulders = 50039,
  shoulderThickness = 7010,
  waist = 50460,

  calves = 42067,
  thighs = 64834,
}
jo.component.expressions = jo.component.data.expressions --deprecated name

-------------
-- local functions
-------------
local delays = {}
local invokeNative = Citizen.InvokeNative
local function SetTextureOutfitTints(ped, category, palette, tint0, tint1, tint2)
  if not palette then return end
  if palette == 0 then return end
  return invokeNative(0x4EFC1F8FF1AD94DE, ped, GetHashFromString(category), GetHashFromString(palette), tint0, tint1, tint2)
end
local function N_0xAAB86462966168CE(ped) return invokeNative(0xAAB86462966168CE, ped, true) end
local function N_0x704C908E9C405136(ped) return invokeNative(0x704C908E9C405136, ped) end
local function GetShopItemBaseLayers(hash, metapedType, isMp) return invokeNative(0x63342C50EC115CE8, GetHashFromString(hash), 0, 0, metapedType, isMp, Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt()) end
local function UpdatePedVariation(ped) return invokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true, false) end
local function IsPedReadyToRender(...) return invokeNative(0xA0BC8FAED8CFEB3C, ...) end
local function IsThisModelAHorse(...) return invokeNative(0x772A1969F649E902, ...) == 1 end
local function ApplyShopItemToPed(ped, hash, immediatly, isMp, p4) return invokeNative(0xD3A7B003ED343FD9, ped, GetHashFromString(hash), immediatly, isMp, p4) end
local function GetMetaPedAssetTint(ped, index) return invokeNative(0xE7998FEC53A33BBE, ped, index, Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt()) end
local function GetNumComponentsInPed(ped) return invokeNative(0x90403E8107B60E81, ped) end
local function GetMetaPedType(ped) return invokeNative(0xEC9A1261BF0CE510, ped) end
local function GetShopItemComponentCategory(...) return invokeNative(0x5FF9A878C3D115B8, ...) end
local function IsMetaPedUsingComponent(...) return invokeNative(0xFB4891BD7578CDC1, ...) == 1 end
local function UpdateShopItemWearableState(ped, hash, state) return invokeNative(0x66B957AAC2EAAEAB, ped, GetHashFromString(hash), GetHashFromString(state), 0, true, 1) end
local function SetMetaPedTag(ped, drawable, albedo, normal, material, palette, tint0, tint1, tint2) return invokeNative(0xBC6DF00D7A4A6819, ped, GetHashFromString(drawable), GetHashFromString(albedo), GetHashFromString(normal), GetHashFromString(material), GetHashFromString(palette), tint0, tint1, tint2) end

local function refreshPed(ped)
  N_0xAAB86462966168CE(ped)
  UpdatePedVariation(ped)
  N_0x704C908E9C405136(ped)
end
jo.component.refreshPed = function(ped)
  ped = ped or PlayerPedId()
  if delays["refresh" .. ped] then
    delays["refresh" .. ped]:execute()
  end
  refreshPed(ped)
end
local function GetCategoryOfComponentAtIndex(ped, componentIndex)
  local pedType = IsThisModelAHorse(GetEntityModel(ped)) and 6 or 0
  return invokeNative(0x9b90842304c938a7, ped, componentIndex, pedType, Citizen.ResultAsInteger())
end

local function GetShopItemComponentAtIndex(ped, index)
  local dataStruct = DataView.ArrayBuffer(10 * 8)
  local componentHash = GetShopPedComponentAtIndex(ped, index, true, dataStruct:Buffer(), dataStruct:Buffer())
  if not componentHash or componentHash == 0 then
    componentHash = GetShopPedComponentAtIndex(ped, index, false, dataStruct:Buffer(), dataStruct:Buffer())
  end
  return componentHash
end

local function waitReadyPed(ped)
  Wait(30)
  local isReady = jo.waiter.exec(function() return IsPedReadyToRender(ped) end)
  if not isReady then return eprint("This ped is not loaded:", ped) end
end
jo.component.waitPedLoaded = waitReadyPed

local function isValidValue(value)
  return value and value ~= 0 and value ~= -1 and value ~= 1
end

---@return any data formatted table for component data
local function formatComponentData(_data)
  data = table.copy(_data)
  if type(data) ~= "table" then
    data = { hash = data }
  end
  if type(data.hash) == "table" then data = data.hash end --for VORP
  if data.hash == 0 then
    data.remove = true
  end
  data.hash = isValidValue(data.hash) and data.hash or false
  data.drawable = isValidValue(data.drawable) and data.drawable or false
  data.palette = isValidValue(data.palette) and data.palette or false

  if not data.hash and not data.drawable and not data.palette and not data.remove then
    return false
  end
  return data
end

local function getBaseLayer(ped, hash)
  local drawable, albedo, normal, material, palette, tint0, tint1, tint2 = GetShopItemBaseLayers(hash, GetMetaPedType(ped), jo.component.isMpComponent(ped, hash))
  if drawable == 0 or drawable == 1 then drawable = nil end
  if albedo == 0 then albedo = nil end
  if normal == 0 then normal = nil end
  if material == 0 then material = nil end
  if palette == 0 then palette = nil end
  return drawable, albedo, normal, material, palette, tint0, tint1, tint2
end
jo.component.getBaseLayer = getBaseLayer

local function convertToMetaTag(ped, data)
  --restrict to hats & masks
  if not data.hash then return data end
  if data.albedo then return data end
  local drawable, albedo, normal, material, palette, tint0, tint1, tint2 = getBaseLayer(ped, data.hash)
  data.drawable = data.drawable or drawable or data.hash or 0
  data.albedo = data.albedo or albedo or 0
  data.normal = data.normal or normal or 0
  data.material = data.material or material or 0
  data.palette = data.palette or palette or 0
  data.tint0 = data.tint0 or tint0
  data.tint1 = data.tint1 or tint1
  data.tint2 = data.tint2 or tint2
  data.hash = nil
  return data
end

local function applyDefaultBodyParts(ped)
  if IsPedMale(ped) then
    EquipMetaPedOutfitPreset(ped, 4, false)
    jo.component.apply(ped, "bodies_upper", `CLOTHING_ITEM_M_BODIES_UPPER_001_V_001`)
    jo.component.apply(ped, "bodies_lower", `CLOTHING_ITEM_M_BODIES_LOWER_001_V_001`)
    jo.component.apply(ped, "heads", `CLOTHING_ITEM_M_HEAD_002_V_001`)
    jo.component.apply(ped, "eyes", `CLOTHING_ITEM_M_EYES_001_TINT_001`)
    jo.component.apply(ped, "teeth", `CLOTHING_ITEM_M_TEETH_000`)
  else
    EquipMetaPedOutfitPreset(ped, 7, false)
    jo.component.apply(ped, "bodies_upper", `CLOTHING_ITEM_F_BODIES_UPPER_001_V_001`)
    jo.component.apply(ped, "bodies_lower", `CLOTHING_ITEM_F_BODIES_LOWER_001_V_001`)
    jo.component.apply(ped, "heads", `CLOTHING_ITEM_F_HEAD_002_V_001`)
    jo.component.apply(ped, "eyes", `CLOTHING_ITEM_F_EYES_001_TINT_001`)
    jo.component.apply(ped, "teeth", `CLOTHING_ITEM_F_TEETH_000`)
  end
end

-------------
-- Color management
-------------

---@param ped integer the entity ID
---@param category integer the category hash
local function resetCachedColor(ped, category)
  if not jo.cache.component.color[ped] then return end
  jo.cache.component.color[ped][category] = nil
  if category == `neckwear` then
    jo.cache.component.color[ped][`neckerchiefs`] = nil
  end
end

---@param ped integer the entity ID
---@param category integer the category hash
---@param hash integer the component hash
---@param palette integer the palette hash
---@param tint0 integer
---@param tint1 integer
---@param tint2 integer
local function addCachedComponent(ped, index, category, hash, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
  category = GetHashFromString(category)
  if not jo.cache.component.color[ped] then jo.cache.component.color[ped] = {} end
  jo.cache.component.color[ped][category] = {
    category = jo.component.getCategoryNameFromHash(category),
    palette = palette,
    tint0 = tint0,
    tint1 = tint1,
    tint2 = tint2,
    hash = hash,
    index = index,
    drawable = drawable,
    albedo = albedo,
    normal = normal,
    material = material,
  }
  if category == `neckwear` then
    jo.cache.component.color[ped][`neckerchiefs`] = jo.cache.component.color[ped][category]
    jo.cache.component.color[ped][`neckerchiefs`].category = "neckerchiefs"
  elseif category == `neckerchiefs` then
    jo.cache.component.color[ped][`neckwear`] = jo.cache.component.color[ped][category]
    jo.cache.component.color[ped][`neckwear`].category = "neckwear"
  end
end

---@param ped integer the entity ID
local function putInCacheCurrentComponent(ped)
  if jo.cache.component.color[ped] then return jo.cache.component.color[ped] end
  local numComponent = GetNumComponentsInPed(ped)
  if not numComponent then return end -- No component detected on the ped
  for index = 0, numComponent - 1 do
    --Get current component
    local palette, tint0, tint1, tint2 = GetMetaPedAssetTint(ped, index)
    local _, drawable, albedo, normal, material = GetMetaPedAssetGuids(ped, index)
    local category = GetCategoryOfComponentAtIndex(ped, index)
    local hash = GetShopItemComponentAtIndex(ped, index)
    addCachedComponent(ped, index, category, hash, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
  end
  return jo.cache.component.color[ped]
end

local function resetCachedPed(ped)
  jo.timeout.delay("jo_libs:resetCachedPed" .. ped, 25, function(ped)
    jo.cache.component.color[ped] = nil
    jo.cache.component.getEquiped[ped] = nil
  end, ped)
end

-------------
-- Cache management
-------------
local function reapplyComponentStats(ped)
  local hash = 0
  for category, _ in pairs(jo.component.data.wearableStates) do
    local isEquiped, index = jo.component.isCategoryEquiped(ped, category)
    local state = Entity(ped).state["wearableState:" .. category]
    if isEquiped and state and state ~= "base" then
      hash = GetShopItemComponentAtIndex(ped, index)
      UpdateShopItemWearableState(ped, hash, state)
    end
  end
  refreshPed(ped)
end

local function reapplyComponentsColor(ped)
  for category, data in pairs(jo.cache.component.color[ped] or {}) do
    SetTextureOutfitTints(ped, category, data.palette, data.tint0, data.tint1, data.tint2)
  end
end

local function reapplyCached(ped)
  if not jo.cache.component.color[ped] then return end
  delays["refresh" .. ped] = jo.timeout.delay("jo_libs:component:reapplyCachedColor" .. ped, function() waitReadyPed(ped) end, function()
    refreshPed(ped)
    waitReadyPed(ped)
    reapplyComponentStats(ped)
    reapplyComponentsColor(ped)
    resetCachedPed(ped)
    refreshPed(ped)
  end)
end

-------------
-- Modules functions
-------------

---@param ped integer the entity ID of the ped
---@param hash integer the hash of the component
---@return integer categoryHash
---@return boolean isMp
function jo.component.getComponentCategory(ped, hash)
  local isMp = true
  hash = GetHashFromString(hash)
  local categoryHash = GetShopItemComponentCategory(hash, GetMetaPedType(ped), true)
  if not categoryHash then
    isMp = false
    categoryHash = GetShopItemComponentCategory(hash, GetMetaPedType(ped), false)
  end
  return categoryHash, isMp
end

function jo.component.isMpComponent(ped, hash)
  hash = GetHashFromString(hash)
  local categoryHash = GetShopItemComponentCategory(hash, GetMetaPedType(ped), true)
  if not categoryHash then
    return false
  end
  return true
end

-------------
-- Component management
-------------

---@param ped integer the entity
---@param category string the component category
---@param data any the component data
function jo.component.apply(ped, category, data)
  data = formatComponentData(data)

  local categoryHash = GetHashFromString(category)
  local isMp = true

  if not data then
    return dprint("Wrong component data structure")
  end

  if data.hash and not data.remove then
    categoryHash, isMp = jo.component.getComponentCategory(ped, data.hash)
    if not categoryHash then
      return dprint("Wrong component hash")
    end
  end

  putInCacheCurrentComponent(ped)

  resetCachedColor(ped, categoryHash)

  if data.hash or data.albedo then
    if data.hash and category ~= "horse_bridles" then
      RemoveTagFromMetaPed(ped, categoryHash, 0)
    end
    if (categoryHash == `neckwear`) then
      RemoveTagFromMetaPed(ped, `neckerchiefs`, 0)
    end
    if (category == "ponchos") then
      RemoveTagFromMetaPed(ped, `cloaks`, 0)
    end
    if (category == "cloaks") then
      RemoveTagFromMetaPed(ped, `ponchos`, 0)
    end
    if category == "coats" then
      RemoveTagFromMetaPed(ped, "coats_closed", 0);
    elseif category == "coats_closed" then
      RemoveTagFromMetaPed(ped, "coats", 0);
    elseif category == "skirts" then
      RemoveTagFromMetaPed(ped, "pants", 0);
    end

    --switch shop item to metatag to allow component mix
    if category == "hats" or category == "masks" or data.albedo then
      data = convertToMetaTag(ped, data)
    end

    if data.hash and data.hash ~= 0 then
      ApplyShopItemToPed(ped, data.hash, false, isMp, false)
    end

    if data.albedo then
      SetMetaPedTag(ped, data.drawable, data.albedo, data.normal, data.material, data.palette, data.tint0, data.tint1, data.tint2)
      addCachedComponent(ped, nil, categoryHash, data.hash, data.drawable, data.albedo, data.normal, data.material, data.palette, data.tint0, data.tint1, data.tint2)
    end

    if data.palette and data.palette ~= 0 then
      addCachedComponent(ped, nil, categoryHash, data.hash, data.drawable, data.albedo, data.normal, data.material, data.palette, data.tint0, data.tint1, data.tint2)
    end

    local state = data.state or Entity(ped).state["wearableState:" .. category]
    if state then
      Entity(ped).state["wearableState:" .. category] = state
      UpdateShopItemWearableState(ped, data.hash, state)
    end
  elseif data.palette then
    addCachedComponent(ped, nil, categoryHash, nil, nil, data.albedo, data.normal, data.material, data.palette, data.tint0, data.tint1, data.tint2)
  else
    RemoveTagFromMetaPed(ped, categoryHash, 0)
  end
  reapplyCached(ped)
end

---@param ped integer the entity
---@param category string the component category
function jo.component.remove(ped, category)
  return jo.component.apply(ped, category, 0)
end

function jo.component.removeAllClothes(ped)
  for _, category in pairs(jo.component.data.pedClothes) do
    jo.component.remove(ped, category)
  end
end


function jo.component.applyComponents(ped, components)
  if not ped then return end
  if not DoesEntityExist(ped) then return end
  if not components then return end

  jo.component.removeAllClothes(ped)

  for category, data in pairs(components) do
    jo.component.apply(ped, category, data)
  end
end

function jo.component.applySkin(ped, skin)
  dprint("applySkin", ped, json.encode(skin))
  if not ped then return end
  if not DoesEntityExist(ped) then return end
  if not skin then return end

  jo.require("ped-texture")

  if skin.model then
    local modelHash = GetHashFromString(skin.model)
    if GetEntityModel(ped) ~= modelHash then
      if (ped ~= PlayerPedId()) then
        eprint("You can't swap the model of existing ped. Current model:", GetEntityModel(ped), "Request model:", skin.model, modelHash)
      else
        jo.utils.loadGameData(modelHash, true)
        dprint("model loaded", skin.model)
        SetPlayerModel(PlayerId(), modelHash, true)
        Wait(100)
        ped = PlayerPedId()
        SetModelAsNoLongerNeeded(modelHash)
      end
    end
  end
  dprint("fix issue on body")
  applyDefaultBodyParts(ped)

  jo.component.refreshPed(ped)
  waitReadyPed(ped)

  dprint("start apply default body components")

  local headHash = skin.headHash or jo.component.getHeadFromSkinTone(ped, skin.headIndex, skin.skinTone)
  jo.component.apply(ped, "heads", headHash)

  local bodies_upper = skin.bodyUpperHash or jo.component.getBodiesUpperFromSkinTone(ped, skin.bodiesIndex, skin.skinTone)
  jo.component.apply(ped, "body_upper", bodies_upper)

  local bodies_lower = skin.bodyLowerHash or jo.component.getBodiesLowerFromSkinTone(ped, skin.bodiesIndex, skin.skinTone)
  jo.component.apply(ped, "body_lower", bodies_lower)

  dprint("apply outfit")
  if skin.bodyType then
    EquipMetaPedOutfit(ped, skin.bodyType)
  end
  if skin.bodyWeight then
    EquipMetaPedOutfit(ped, skin.bodyWeight)
  end

  jo.component.refreshPed(ped)
  waitReadyPed(ped)

  local eyes = skin.eyesHash or jo.component.getEyesFromIndex(ped, skin.eyesIndex)
  jo.component.apply(ped, "eyes", eyes)

  local teeth = skin.teethHash or jo.component.getTeethFromIndex(ped, skin.teethIndex)
  jo.component.apply(ped, "teeth", teeth)

  jo.component.apply(ped, "hair", skin.hair)
  if skin.model == "mp_male" then
    jo.component.apply(ped, "beards_complete", skin.beards_complete)
  end

  dprint("apply expression")
  for expression, value in pairs(skin.expressions) do
    local percent = value or 0.0
    percent = math.min(1.0, percent)
    percent = math.max(-1.0, percent)
    SetCharExpression(ped, jo.component.data.expressions[expression], percent * 1.0)
  end

  jo.component.refreshPed(ped)
  dprint("wait refresh")
  waitReadyPed(ped)

  for category, overlay in pairs(skin.overlays or {}) do
    if type(overlay) == "table" then
      local default = {
        id = 0,
        opacity = 0.0,
        category = category
      }
      if category == "hair" or category == "beard" then
        default.palette = "metaped_tint_hair"
        default.tint0 = 135
      end
      overlay = table.merge(default, overlay)
    end
  end
  jo.pedTexture.overwriteCategory(ped, "heads", skin.overlays, true)

  Wait(100)

  SetPedScale(ped, skin.bodyScale)
  dprint("done create ped")

  waitReadyPed(ped)
end

-------------
-- WEARABLE STATE
-------------

---@param ped integer the entity
---@param category string the category
---@param hash any the hash of the component
---@param state any
function jo.component.setWearableState(ped, category, hash, state)
  Entity(ped).state:set("wearableState:" .. category, state)
  putInCacheCurrentComponent(ped)
  local data = formatComponentData(hash)
  if not data.hash then
    data.hash = jo.component.getComponentEquiped(jo.me, category)
  end
  UpdateShopItemWearableState(ped, data.hash, state)
  if category == "neckwear" and GetHashFromString(state) == `base` then
    jo.component.apply(ped, "beards_complete", jo.cache.component.color[ped][`beards_complete`])
  end
  reapplyCached(ped)
end

function jo.component.getWearableState(ped, category)
  local state = Entity(ped).state["wearableState:" .. category]
  if (type(state) == "string") then return state end
  return ""
end

---@param ped integer the entity
---@return boolean
function jo.component.neckwearIsUp(ped)
  return Entity(ped).state["wearableState:neckwear"] == jo.component.data.wearableStates.neckwear[1]
end
jo.component.isNeckweaUp = jo.component.neckwearIsUp

---@param ped integer the entity
---@return boolean
function jo.component.sleeveIsRolled(ped)
  return jo.component.getWearableState(ped, "shirts_full"):find("rolled") ~= nil
end
jo.component.isSleeveRolled = jo.component.sleeveIsRolled

---@param ped integer the entity
---@return boolean
function jo.component.collarIsOpened(ped)
  return jo.component.getWearableState(ped, "shirts_full"):find("open") and true or false
end
jo.component.isCollarOpened = jo.component.collarIsOpened

---@param ped integer the entity
---@param hash any the hash of the component
function jo.component.sleeveUnroll(ped, hash)
  if jo.component.isCollarOpened(ped) then
    jo.component.setWearableState(ped, "shirts_full", hash, jo.component.data.wearableStates.shirts_full[10])
  else
    jo.component.setWearableState(ped, "shirts_full", hash, jo.component.data.wearableStates.shirts_full[00])
  end
end
jo.component.unrollSleeve = jo.component.sleeveUnroll

---@param ped integer the entity
---@param hash any the hash of the component
function jo.component.sleeveRoll(ped, hash)
  if jo.component.isCollarOpened(ped) then
    jo.component.setWearableState(ped, "shirts_full", hash, jo.component.data.wearableStates.shirts_full[11])
  else
    jo.component.setWearableState(ped, "shirts_full", hash, jo.component.data.wearableStates.shirts_full[01])
  end
end
jo.component.rollSleeve = jo.component.sleeveRoll

---@param ped integer the entity
---@param hash any the hash of the component
function jo.component.collarOpen(ped, hash)
  if jo.component.isSleeveRolled(ped) then
    jo.component.setWearableState(ped, "shirts_full", hash, jo.component.data.wearableStates.shirts_full[11])
  else
    jo.component.setWearableState(ped, "shirts_full", hash, jo.component.data.wearableStates.shirts_full[10])
  end
end
jo.component.openCollar = jo.component.collarOpen

---@param ped integer the entity
---@param hash any the hash of the component
function jo.component.collarClose(ped, hash)
  if jo.component.isSleeveRolled(ped) then
    jo.component.setWearableState(ped, "shirts_full", hash, jo.component.data.wearableStates.shirts_full[01])
  else
    jo.component.setWearableState(ped, "shirts_full", hash, jo.component.data.wearableStates.shirts_full[00])
  end
end
jo.component.closeCollar = jo.component.collarClose

---@param ped integer the entity
---@return boolean
function jo.component.bootsAreUnderPant(ped)
  return Entity(ped).state["wearableState:boots"] == jo.component.data.wearableStates.boots[1]
end
jo.component.isBootsUnderPant = jo.component.bootsAreUnderPant

---@param ped integer the entity
---@return boolean
function jo.component.vestIsUnderPant(ped)
  return Entity(ped).state["wearableState:vests"] == jo.component.data.wearableStates.vests[1]
end
jo.component.isVestUnderPant = jo.component.vestIsUnderPant

---@param ped integer the entity
---@return boolean
function jo.component.loadoutIsOnRight(ped)
  return Entity(ped).state["wearableState:loadouts"] == jo.component.data.wearableStates.loadouts[1]
end
jo.component.isLoadoutOnRight = jo.component.loadoutIsOnRight

function jo.component.hairIsPomade(ped)
  return Entity(ped).state["wearableState:hair"] == jo.component.data.wearableStates.hair[1]
end

-------------
-- CATEGORIES & COMPONENTS
-------------

---@param ped integer the entity
---@return table
function jo.component.getCategoriesEquiped(ped)
  if jo.cache.component.getEquiped[ped] then
    return jo.cache.component.getEquiped[ped]
  end
  jo.cache.component.getEquiped[ped] = {}
  local numComponent = GetNumComponentsInPed(ped) or 0
  for index = 0, numComponent - 1 do
    --Get current component
    local category = GetCategoryOfComponentAtIndex(ped, index)
    jo.cache.component.getEquiped[ped][category] = {
      index = index,
      category = jo.component.getCategoryNameFromHash(category),
    }
    if category == `neckwear` then
      jo.cache.component.getEquiped[ped][`neckerchiefs`] = jo.cache.component.getEquiped[ped][category]
      jo.cache.component.getEquiped[ped][`neckerchiefs`].category = "neckerchiefs"
    elseif category == `neckerchiefs` then
      jo.cache.component.getEquiped[ped][`neckwear`] = jo.cache.component.getEquiped[ped][category]
      jo.cache.component.getEquiped[ped][`neckwear`].category = "neckwear"
    end
  end
  --clear cached value
  local component = jo.cache.component.getEquiped[ped]
  resetCachedPed(ped)
  return component
end

---@param ped integer the entity
---@param category string
---@return boolean,integer
function jo.component.isCategoryEquiped(ped, category)
  local categoryHash = GetHashFromString(category)
  if not IsMetaPedUsingComponent(ped, categoryHash) then
    return false, 0
  end
  local equiped = jo.component.getCategoriesEquiped(ped)
  if not equiped[categoryHash] then return false, 0 end
  return true, equiped[categoryHash].index
end

function jo.component.getComponentEquiped(ped, category)
  local categoryHash = GetHashFromString(category)
  if not IsMetaPedUsingComponent(ped, categoryHash) then
    return false
  end
  local equiped = jo.component.getCategoriesEquiped(ped)

  if equiped?[categoryHash] then
    local index = equiped[categoryHash].index
    return GetShopItemComponentAtIndex(ped, index)
  else
    return false
  end
end

function jo.component.getComponentsEquiped(ped)
  local component = putInCacheCurrentComponent(ped) or {}
  resetCachedPed(ped)
  return component
end

function jo.component.getCategoryTint(ped, category, inTable)
  if inTable == nil then inTable = false end
  local categoryHash = GetHashFromString(category)
  if not IsMetaPedUsingComponent(ped, categoryHash) then
    return false
  end
  local equiped, index = jo.component.isCategoryEquiped(ped, categoryHash)

  if not equiped then return false end
  if inTable then
    local palette, tint0, tint1, tint2 = GetMetaPedAssetTint(ped, index)
    return {
      palette = palette,
      tint0 = tint0,
      tint1 = tint1,
      tint2 = tint2
    }
  end
  return GetMetaPedAssetTint(ped, index)
end



-------------
-- Convert Hash
-------------

function jo.component.getPaletteNameFromHash(hash)
  for _, palette in pairs(jo.component.data.palettes) do
    if joaat(palette) == hash then
      return palette
    end
  end
  return "unknown"
end

---@return string categoryName
function jo.component.getCategoryNameFromHash(category)
  if not category then return "" end
  return jo.component.data.categoryName[category] or "unknown"
end

function jo.component.getHeadFromSkinTone(ped, headIndex, skinTone)
  local ped = ped or PlayerPedId()
  local sex = "M"
  if type(ped) == "string" then
    sex = "mp_male" and "M" or "F"
  else
    sex = IsPedMale(ped) and "M" or "F"
  end
  return ("CLOTHING_ITEM_%s_HEAD_%03d_V_%03d"):format(sex, headIndex or 1, skinTone or 1)
end

function jo.component.getBodiesLowerFromSkinTone(ped, bodiesIndex, skinTone)
  local ped = ped or PlayerPedId()
  local sex = "M"
  if type(ped) == "string" then
    sex = "mp_male" and "M" or "F"
  else
    sex = IsPedMale(ped) and "M" or "F"
  end
  return ("CLOTHING_ITEM_%s_BODIES_LOWER_%03d_V_%03d"):format(sex, bodiesIndex or 1, skinTone or 1)
end

function jo.component.getBodiesUpperFromSkinTone(ped, bodiesIndex, skinTone)
  local ped = ped or PlayerPedId()
  local sex = "M"
  if type(ped) == "string" then
    sex = "mp_male" and "M" or "F"
  else
    sex = IsPedMale(ped) and "M" or "F"
  end
  return ("CLOTHING_ITEM_%s_BODIES_UPPER_%03d_V_%03d"):format(sex, bodiesIndex or 1, skinTone or 1)
end

function jo.component.getEyesFromIndex(ped, index)
  local ped = ped or PlayerPedId()
  local sex = "M"
  if type(ped) == "string" then
    sex = "mp_male" and "M" or "F"
  else
    sex = IsPedMale(ped) and "M" or "F"
  end
  return ("CLOTHING_ITEM_%s_EYES_001_TINT_%03d"):format(sex, index or 1)
end

function jo.component.getTeethFromIndex(ped, index)
  local ped = ped or PlayerPedId()
  local sex = "M"
  if type(ped) == "string" then
    sex = "mp_male" and "M" or "F"
  else
    sex = IsPedMale(ped) and "M" or "F"
  end
  return ("CLOTHING_ITEM_%s_TEETH_%03d"):format(sex, index or 1)
end
-------------
-- Deprecated old names
-------------

-- Add shortcut with old name
for _, shortcut in pairs({ "clothes", "comp" }) do
  jo[shortcut] = setmetatable({}, {
    __index = function(self, key)
      return jo.component[key]
    end
  })
end
