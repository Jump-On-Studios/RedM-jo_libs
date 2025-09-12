jo.require("table")
jo.require("timeout")
jo.require("dataview")
jo.require("waiter")
jo.require("utils")
jo.require("hook")
jo.require("ped-texture")
jo.require("component", true)

-------------
-- VARIABLES
-------------
local delays = {}
local isRefreshing = false

---@Class Component
local Component = {}

-------------
-- END VARIABLE
-------------
-------------
-- CACHE
-------------
jo.cache.component = {
  color = {}
}
-------------
-- END CACHE
-------------

-------------
-- DATA
-------------
jo.component.data = {}

jo.component.data.pedCategories = {
  "heads",
  "eyes",
  "teeth",
  "bodies_upper",
  "bodies_lower",
  "hair",
  "beards_complete",
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
  "masks",
  "masks_large",
  "hats",
  "hair",
  "beards_complete",
  "teeth",
  "neckwear",
  "neckerchiefs",
  "armor",
}
jo.component.data.horseCategories = {
  "horse_heads",
  "horse_bodies",
  "horse_feathers",
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

jo.component.data.order = table.copy(jo.component.data.pedCategories)
for i = 1, #jo.component.data.horseCategories do
  jo.component.data.order[#jo.component.data.order + 1] = jo.component.data.horseCategories[i]
end

local categoryNotClothes = {
  hair = true,
  beards_complete = true,
  teeth = true,
  heads = true,
  bodies_lower = true,
  bodies_upper = true,
  eyes = true,
  neckerchiefs = true
}
jo.component.data.pedClothes = table.filter(jo.component.data.pedCategories, function(cat) return not categoryNotClothes[cat] end)
jo.component.data.clothesCategories = {}

for i = 1, #jo.component.data.pedClothes do
  local category = jo.component.data.pedClothes[i]
  local hash = jo.component.getCategoryHash(category)
  jo.component.data.clothesCategories[hash] = category
end

jo.component.data.categoryName = {}
for i = 1, #jo.component.data.order do
  local category = jo.component.data.order[i]
  local hash = jo.component.getCategoryHash(category)
  jo.component.data.categoryName[hash] = category
end

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
    [0] = "base",   --down
    [1] = "mask_up" --up
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
  },
  others = {
    "base_coat_open",
    "base_coat_open_glove",
    "base_glove",
    "base_vest",
    "base_vest_coat_open",
    "base_overalls",
    "base_overalls_coat_open",
    "open_collar_full_sleeve",
    "open_collar_full_sleeve_coat_open",
    "open_collar_full_sleeve_vest",
    "open_collar_full_sleeve_vest_coat_open",
    "open_collar_full_sleeve_overalls",
    "open_collar_full_sleeve_overalls_coat_open",
    "closed_collar_rolled_sleeve",
    "closed_collar_rolled_sleeve_vest",
    "closed_collar_rolled_sleeve_overalls",
    "open_collar_rolled_sleeve",
    "open_collar_rolled_sleeve_vest",
    "open_collar_rolled_sleeve_overalls",
    "gown",
    "base_tucked",
    "pomade_tucked",
    "tuck",
    "dummy",
    "stocking",
    "short_pants",
    "shirt_full_sleeve",
    "short_boots_under_pants",
    "under_boots",
    "under_spats",
    "under_chaps",
    "under_ripped_pants",
    "shirt_rolled_sleeve",
    "shirt_rolled_sleeve_archer_glove",
    "shirt_rolled_sleeve_gunslinger_glove",
    "shirt_rolled_sleeve_fingerless_glove",
    "shirt_rolled_sleeve_glove",
    "shirt_full_sleeve_archer_glove",
    "shirt_full_sleeve_gunslinger_glove",
    "shirt_full_sleeve_fingerless_glove",
    "shirt_full_sleeve_glove",
    "base_vest_coat_open_archer_glove",
    "base_vest_coat_open_gunslinger_glove",
    "base_vest_coat_open_fingerless_glove",
    "base_vest_coat_open_glove",
    "base_vest_gunslinger_glove",
    "base_vest_archer_glove",
    "base_vest_fingerless_glove",
    "base_vest_glove",
    "base_archer_glove",
    "base_gunslinger_glove",
    "base_fingerless_glove",
    "base_coat_open_archer_glove",
    "base_coat_open_gunslinger_glove",
    "base_coat_open_fingerless_glove",
    "shirt_009",
    "closed_collar_rolled_sleeve_vest_coat_open",
    "closed_collar_rolled_sleeve_coat_open",
  }
}
jo.component.data.wearableStatesName = {}
for category, states in pairs(jo.component.data.wearableStates) do
  for _, state in pairs(states) do
    jo.component.data.wearableStatesName[GetHashFromString(state)] = state
  end
end

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
jo.component.data.palettesName = {}
for i = 1, #jo.component.data.palettes do
  local palette = jo.component.data.palettes[i]
  local hash = GetHashFromString(palette)
  jo.component.data.palettesName[hash] = palette
end

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
  mouthConerRightHeight = 49299,
  mouthConerRightDepth = 9423,
  mouthConerRightWidth = 55718,
  mouthConerRightLipsDistance = 60292,

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
-- END DATA
-------------

-------------
-- LOCAL FUNCTIONS
-------------

local invokeNative = Citizen.InvokeNative
local function SetTextureOutfitTints(ped, category, palette, tint0, tint1, tint2)
  if not palette then return end
  if palette == 0 then return end
  return invokeNative(0x4EFC1F8FF1AD94DE, ped, jo.component.getCategoryHash(category), GetHashFromString(palette), tint0, tint1,
    tint2)
end
local function SetActiveMetaPedComponentsUpdated(ped) return invokeNative(0xAAB86462966168CE, ped, true) end
local function N_0x704C908E9C405136(ped) return invokeNative(0x704C908E9C405136, ped) end
local function GetShopItemBaseLayers(hash, metapedType, isMp)
  return invokeNative(0x63342C50EC115CE8,
    GetHashFromString(hash), 0, 0, metapedType, isMp, Citizen.PointerValueInt(), Citizen.PointerValueInt(),
    Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt(),
    Citizen.PointerValueInt(), Citizen.PointerValueInt())
end
local function UpdatePedVariation(ped) return invokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true, false) end
local function IsPedReadyToRender(...) return invokeNative(0xA0BC8FAED8CFEB3C, ...) end
local function IsThisModelAHorse(...) return invokeNative(0x772A1969F649E902, ...) == 1 end
local function ApplyShopItemToPed(ped, hash, immediatly, isMp, p4)
  return invokeNative(0xD3A7B003ED343FD9, ped,
    GetHashFromString(hash), immediatly, isMp, p4)
end
local function GetMetaPedAssetTint(ped, index)
  return invokeNative(0xE7998FEC53A33BBE, ped, index,
    Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt())
end
local function GetNumComponentsInPed(ped) return invokeNative(0x90403E8107B60E81, ped) or 0 end
local function GetShopItemComponentCategory(...) return invokeNative(0x5FF9A878C3D115B8, ...) end
local function UpdateShopItemWearableState(ped, hash, state)
  return invokeNative(0x66B957AAC2EAAEAB, ped, GetHashFromString(hash), GetHashFromString(state), 0, true, 1)
end
local function SetMetaPedTag(ped, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
  return invokeNative(
    0xBC6DF00D7A4A6819, ped, GetHashFromString(drawable), GetHashFromString(albedo), GetHashFromString(normal),
    GetHashFromString(material), GetHashFromString(palette), tint0, tint1, tint2)
end

local function refreshPed(ped)
  SetActiveMetaPedComponentsUpdated(ped)
  UpdatePedVariation(ped)
  N_0x704C908E9C405136(ped)
end

local function GetCategoryOfComponentAtIndex(ped, componentIndex)
  local pedType = IsThisModelAHorse(GetEntityModel(ped)) and 6 or 0
  local category = invokeNative(0x9b90842304c938a7, ped, componentIndex, pedType, Citizen.ResultAsInteger())
  --patch neckerchiefs
  if category == `neckerchiefs` then
    category = `neckwear`
  end
  return category
end

--- @return integer (Hash)
--- @return integer (WearableState)
local function GetShopItemComponentAtIndex(ped, index)
  local componentHash, a, wearableState = GetShopPedComponentAtIndex(ped, index, true, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
  if not componentHash or componentHash == 0 then
    componentHash, a, wearableState = GetShopPedComponentAtIndex(ped, index, false, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
  end
  return componentHash, wearableState
end


local function isValidValue(value)
  return value and value ~= 0 and value ~= -1 and value ~= 1
end

---@return any data formatted table for component data
local function formatComponentData(_data)
  local data = table.copy(_data)
  if type(data) ~= "table" then
    data = { hash = data }
  end
  if type(data.hash) == "table" then data = data.hash end --for VORP
  if data.hash == 0 or data.hash == false then
    data.remove = true
  end
  data.hash = isValidValue(data.hash) and data.hash or nil
  data.drawable = isValidValue(data.drawable) and data.drawable or nil
  data.palette = isValidValue(data.palette) and data.palette or nil

  if not data.hash and not data.drawable and not data.palette and not data.remove then
    return false
  end
  return data
end

local function getComponentIndexOfCategory(ped, category)
  category = jo.component.getCategoryHash(category)
  local numComponent = GetNumComponentsInPed(ped)
  for index = 0, numComponent - 1, 1 do
    if GetCategoryOfComponentAtIndex(ped, index) == category then
      return index
    end
  end
  return -1
end

function Component.new(index, category, hash, wearableState, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
  return {
    category = jo.component.getCategoryNameFromHash(category),
    categoryHash = jo.component.getCategoryHash(category),
    palette = palette,
    tint0 = tint0,
    tint1 = tint1,
    tint2 = tint2,
    hash = hash,
    wearableState = jo.component.getWearableStateNameFromHash(wearableState),
    wearableStateHash = GetHashFromString(wearableState) or false,
    index = index,
    drawable = drawable,
    albedo = albedo,
    normal = normal,
    material = material,
  }
end

local function getComponentAtIndex(ped, index)
  local palette, tint0, tint1, tint2 = GetMetaPedAssetTint(ped, index)
  local _, drawable, albedo, normal, material = GetMetaPedAssetGuids(ped, index)
  local category = GetCategoryOfComponentAtIndex(ped, index)

  local hash, wearableState = GetShopItemComponentAtIndex(ped, index)
  return Component.new(index, category, hash, wearableState, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
end

--- A function to get the base layer of a component
---@param ped integer (The entity ID or the metaped type)
---@param hash string|integer (The component hash)
---@param inTable? boolean (`true` to get the result as a table, `false` to get the result as separate values<br> Default: `false`)
---@return table|integer,integer,integer,integer,integer,integer,integer,integer (When inTable is true: returns a table with {drawable, albedo, normal, material, palette, tint0, tint1, tint2} <br> When inTable is false: 1st: drawable <br> 2nd: albedo <br> 3rd: normal <br> 4th: material <br> 5th: palette <br> 6th: tint0 <br> 7th: tint1 <br> 8th: tint2)
function jo.component.getBaseLayer(ped, hash, inTable)
  inTable = GetValue(inTable, false)
  local metapedType = DoesEntityExist(ped) and GetMetaPedType(ped) or ped
  local drawable, albedo, normal, material, palette, tint0, tint1, tint2 = GetShopItemBaseLayers(hash, metapedType, jo.component.isMpComponent(ped, hash))
  if drawable == 0 or drawable == 1 then drawable = nil end
  if albedo == 0 then albedo = nil end
  if normal == 0 then normal = nil end
  if material == 0 then material = nil end
  if palette == 0 then palette = nil end
  if inTable then
    return {
      drawable = drawable,
      albedo = albedo,
      normal = normal,
      material = material,
      palette = jo.component.getPaletteNameFromHash(palette),
      tint0 = tint0,
      tint1 = tint1,
      tint2 = tint2
    }
  end
  return drawable, albedo, normal, material, jo.component.getPaletteNameFromHash(palette), tint0, tint1, tint2
end

local function convertToMetaTag(ped, data)
  data = table.copy(data)
  --restrict to hats & masks
  if not data.hash then return data end
  if data.albedo then return data end

  local drawable, albedo, normal, material, palette, tint0, tint1, tint2 = jo.component.getBaseLayer(ped, data.hash)
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

---@param ped integer
---@param category string|integer
---@param hash table|integer|string
---@param state string|integer
local function updateComponentWearableState(ped, category, hash, state)
  category = jo.component.getCategoryNameFromHash(category)
  state = GetHashFromString(state)
  Entity(ped).state:set("wearableState:" .. category, state)
  UpdateShopItemWearableState(ped, type(hash) == "table" and hash.hash or hash, state)
end

-------------
-- END LOCAL FUNCTIONS
-------------

-------------
-- COLOR MANAGEMENT
-------------

---@param ped integer (The entity ID)
---@param category integer|string the category hash
local function resetCachedColor(ped, category)
  if not jo.cache.component.color[ped] then return end
  jo.cache.component.color[ped][category] = nil
  if category == `neckwear` then
    jo.cache.component.color[ped][`neckerchiefs`] = nil
  end
end

---@param ped integer (The entity ID)
---@param category integer (the category hash)
---@param hash integer (the component hash)
---@param wearableState integer (the wearable state)
---@param palette integer (the palette hash)
---@param tint0 integer
---@param tint1 integer
---@param tint2 integer
local function addCachedComponent(ped, index, category, hash, wearableState, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
  category = jo.component.getCategoryHash(category)
  table.addMultiLevels(jo.cache.component.color, ped, category)
  jo.cache.component.color[ped][category] = Component.new(index, category, hash, wearableState, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
  if category == `neckwear` then
    jo.cache.component.color[ped][`neckerchiefs`] = table.copy(jo.cache.component.color[ped][category])
    jo.cache.component.color[ped][`neckerchiefs`].category = "neckerchiefs"
  elseif category == `neckerchiefs` then
    jo.cache.component.color[ped][`neckwear`] = table.copy(jo.cache.component.color[ped][category])
    jo.cache.component.color[ped][`neckwear`].category = "neckwear"
  end
end

---@param ped integer the entity ID
---@return table
local function initCachePedComponents(ped)
  while isRefreshing do Wait(0) end
  if not jo.cache.component.color[ped] then
    local numComponent = GetNumComponentsInPed(ped)
    if not numComponent then return {} end -- No component detected on the ped
    for index = 0, numComponent - 1 do
      --Get current component
      local palette, tint0, tint1, tint2 = GetMetaPedAssetTint(ped, index)
      local _, drawable, albedo, normal, material = GetMetaPedAssetGuids(ped, index)
      local category = GetCategoryOfComponentAtIndex(ped, index)

      local hash, wearableState = GetShopItemComponentAtIndex(ped, index)
      addCachedComponent(ped, index, category, hash, wearableState, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
    end
  end
  return table.copy(jo.cache.component.color[ped])
end
-------------
-- END COLOR MANAGEMENT
-------------

-------------
-- CACHE MANAGEMENT
-------------
local function reapplyComponentStats(ped)
  for category, list in pairs(jo.component.data.wearableStates) do
    if jo.component.isCategoryAClothes(category) then
      local isEquiped, index = jo.component.isCategoryEquiped(ped, category)
      if isEquiped then
        local state = Entity(ped).state["wearableState:" .. category] or "base"
        local stateName = jo.component.getWearableStateNameFromHash(state)
        if stateName ~= "base" and table.includes(list, stateName) then
          local hash = GetShopItemComponentAtIndex(ped, index)
          if jo.debug then
            dprint("Reapply state of %s: %s (%d)", category, jo.component.getWearableStateNameFromHash(state), state)
          end
          UpdateShopItemWearableState(ped, hash, state)
        end
      end
    end
  end
end

local function reapplyComponentsColor(ped)
  for i = 1, #jo.component.data.order do
    local category = jo.component.getCategoryHash(jo.component.data.order[i])
    if jo.cache.component.color[ped][category] then
      local data = jo.cache.component.color[ped][category]
      SetTextureOutfitTints(ped, category, data.palette, data.tint0, data.tint1, data.tint2)
    end
  end
end

local function reapplyCached(ped)
  if not jo.cache.component.color[ped] then return end
  delays["refresh" .. ped] = jo.timeout.delay("jo_libs:component:reapplyCachedColor" .. ped,
    function() jo.component.waitPedLoaded(ped) end, function()
      refreshPed(ped)
      -- jo.component.waitPedLoaded(ped)
      reapplyComponentStats(ped)
      reapplyComponentsColor(ped)
      jo.cache.component.color[ped] = nil
      refreshPed(ped)
    end)
end

-------------
-- END CACHE MANAGEMENT
-------------

-------------
-- MODULES FUNCTIONS
-------------

--- A function to refresh the ped components
--- @param ped integer (The entity ID)
function jo.component.refreshPed(ped)
  ped = ped or PlayerPedId()
  if delays["refresh" .. ped] then
    delays["refresh" .. ped]:execute()
  end
  refreshPed(ped)
end


--- A function to wait the refresh of ped
--- @param ped integer (The entity ID)
function jo.component.waitPedLoaded(ped)
  Wait(30)
  local isReady = jo.waiter.exec(function() return IsPedReadyToRender(ped) end)
  if not isReady then
    if jo.debug then eprint("This ped is not loaded:", ped) end
    return
  end
end

--- Return the category hash of a component and if it's a MP component
---@param ped integer (The entity ID)
---@param hash integer (The component hash)
---@return integer,boolean (1st: Return hash value of the category <br> 2nd: Return `true` if it's a MP component, `false` otherwise)
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

--- A function to check if a component is an MP component (multiplayer component)
---@param ped integer (The entity ID OR the metapedType)
---@param hash integer (The component hash)
---@return boolean (Return `true` if it's an MP component, `false` otherwise)
function jo.component.isMpComponent(ped, hash)
  hash = GetHashFromString(hash)
  local metapedType = DoesEntityExist(ped) and GetMetaPedType(ped) or ped
  local categoryHash = GetShopItemComponentCategory(hash, metapedType, true)
  if not categoryHash then
    return false
  end
  return true
end

-------------
-- END MODULE FUNCTION
-------------

-------------
-- COMPONENT MANAGEMENT
-------------

local function isValidValue(value)
  return value and value ~= 0 and value ~= -1 and value ~= 1
end

--- A function to apply a component on the ped
---@param ped integer (The entity ID)
---@param category string|integer (The component category)
---@param _data table (The component data)
--- _data.hash integer (The component hash)
--- _data.palette? string|integer (The color palette of the component)
--- _data.tint0? integer (The first color number)
--- _data.tint1? integer (The second color number)
--- _data.tint2? integer (The third color number)
--- _data.drawable? integer (The drawable value)
--- _data.albedo? integer (The albedo value)
--- _data.normal? integer (The normal value)
--- _data.material? integer (The material value)
function jo.component.apply(ped, category, _data)
  local data = jo.component.formatComponentData(_data)

  local categoryName = jo.component.getCategoryNameFromHash(category)
  local categoryHash = jo.component.getCategoryHash(category)
  local isMp = true

  if not data then
    return dprint("Wrong component data structure", ped, category, json.encode(_data))
  end

  if data.hash == 0 or data.hash == false then
    data.remove = true
  end
  data.hash = isValidValue(data.hash) and data.hash or nil
  data.drawable = isValidValue(data.drawable) and data.drawable or nil
  data.palette = isValidValue(data.palette) and data.palette or nil

  if data.hash and not data.remove then
    categoryHash, isMp = jo.component.getComponentCategory(ped, data.hash)
    if not categoryHash then
      return dprint("Wrong component hash:", categoryName, data.hash)
    end
  end

  local cached = initCachePedComponents(ped)
  if cached and cached[categoryHash] then
    if categoryName ~= "unknown" then
      local stateName = jo.component.getWearableStateNameFromHash(cached[categoryHash].wearableStateHash)
      if not Entity(ped).state["wearableState:" .. categoryName] and stateName ~= "base" and table.includes(list, stateName) then
        dprint("Save the wearable state of %s: %s", categoryName, tostring(stateName))
        Entity(ped).state["wearableState:" .. categoryName] = cached[categoryHash].wearableStateHash
      end
    end
  end
  resetCachedColor(ped, categoryHash)

  if data.hash or data.albedo or data.palette then
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
        RemoveTagFromMetaPed(ped, "coats_closed", 0)
      elseif category == "coats_closed" then
        RemoveTagFromMetaPed(ped, "coats", 0)
      elseif category == "skirts" then
        RemoveTagFromMetaPed(ped, "pants", 0)
      end

      --switch shop item to metatag to allow component mix
      if category == "hats" or category == "masks" or data.albedo then
        data = convertToMetaTag(ped, data)
      end

      if data.hash and data.hash ~= 0 then
        ApplyShopItemToPed(ped, data.hash, false, isMp, false)
      end

      if data.drawable or data.albedo then
        SetMetaPedTag(ped, data.drawable, data.albedo, data.normal, data.material, data.palette, data.tint0, data.tint1, data.tint2)
      end

      local state = data.wearableState or Entity(ped).state["wearableState:" .. category]
      if state then
        updateComponentWearableState(ped, category, data, state)
      end
    end

    addCachedComponent(ped, nil, categoryHash, data.hash, data.wearableState, data.drawable, data.albedo, data.normal, data.material, data.palette, data.tint0, data.tint1, data.tint2)
  else
    RemoveTagFromMetaPed(ped, categoryHash, 0)
    if categoryHash == `neckwear` then
      RemoveTagFromMetaPed(ped, `neckerchiefs`, 0)
    end
  end
  reapplyCached(ped)
end

--- A function to remove a component component
---@param ped integer (The entity ID)
---@param category integer|string (The category of component to remove)
function jo.component.remove(ped, category)
  return jo.component.apply(ped, category, 0)
end

--- A function to remove all clothing components from a ped
---@param ped integer (The entity ID)
function jo.component.removeAllClothes(ped)
  for i = 1, #jo.component.data.pedClothes do
    local category = jo.component.data.pedClothes[i]
    jo.component.remove(ped, category)
  end
end

--- A function to apply multiple components to a ped
---@param ped integer (The entity ID)
---@param components table (Table of components indexed by category name with component data)
function jo.component.applyComponents(ped, components)
  if not ped then return end
  if not DoesEntityExist(ped) then return end
  if not components then return end

  jo.component.removeAllClothes(ped)

  for i = 1, #jo.component.data.pedClothes do
    local category = jo.component.data.pedClothes[i]
    if components[category] then
      jo.component.apply(ped, category, components[category])
    end
  end
end

-- todo verify if the skin table is OK
--- A function to apply a complete skin configuration to a ped
---@param ped integer (The entity ID)
---@param skin table (The skin configuration data)
--- skin.model? string (The model name)
--- skin.headHash? integer (The head component hash)
--- skin.headIndex? integer (The head index for skin tone)
--- skin.skinTone? integer (The skin tone value)
--- skin.bodyUpperHash? integer (The upper body component hash)
--- skin.bodyLowerHash? integer (The lower body component hash)
--- skin.bodiesIndex? integer (The body index for skin tone)
--- skin.bodyType? integer (The body type outfit preset)
--- skin.bodyWeight? integer (The body weight outfit preset)
--- skin.expressions? table (Table of expression values)
--- skin.eyesHash? integer (The eyes component hash)
--- skin.eyesIndex? integer (The eyes index)
--- skin.teethHash? integer (The teeth component hash)
--- skin.teethIndex? integer (The teeth index)
--- skin.hair? table (Hair component data)
--- skin.beards_complete? table (Beard component data)
--- skin.overlays? table (Table of overlay configurations)
--- skin.bodyScale? number (The body scale value)
function jo.component.applySkin(ped, skin)
  dprint("applySkin", ped, json.encode(skin))
  if not ped then return end
  if not DoesEntityExist(ped) then return dprint("jo.component.applySkin() => Ped doesn't exist:", ped) end
  if not skin then return end

  if skin.model then
    local modelHash = GetHashFromString(skin.model)
    if GetEntityModel(ped) ~= modelHash then
      if (ped ~= PlayerPedId()) then
        eprint("You can't swap the model of existing ped. Current model:", GetEntityModel(ped), "Request model:",
          skin.model, modelHash)
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
  jo.component.waitPedLoaded(ped)

  dprint("start apply default body components")

  local headHash = skin.headHash or jo.component.getHeadFromSkinTone(ped, skin.headIndex, skin.skinTone)
  dprint("headHash", headHash)
  if headHash and headHash ~= 0 then
    jo.component.apply(ped, "heads", headHash)
  end

  local bodies_upper = skin.bodyUpperHash or
      jo.component.getBodiesUpperFromSkinTone(ped, skin.bodiesIndex, skin.skinTone)
  dprint("bodies_upper", bodies_upper)
  if bodies_upper and bodies_upper ~= 0 then
    jo.component.apply(ped, "bodies_upper", bodies_upper)
  end

  local bodies_lower = skin.bodyLowerHash or
      jo.component.getBodiesLowerFromSkinTone(ped, skin.bodiesIndex, skin.skinTone)
  dprint("bodies_lower", bodies_lower)
  if bodies_lower and bodies_lower ~= 0 then
    jo.component.apply(ped, "bodies_lower", bodies_lower)
  end

  dprint("apply outfit")
  if skin.bodyType then
    EquipMetaPedOutfit(ped, skin.bodyType)
  end
  if skin.bodyWeight then
    EquipMetaPedOutfit(ped, skin.bodyWeight)
  end

  jo.component.refreshPed(ped)
  jo.component.waitPedLoaded(ped)

  dprint("apply expression")
  for expression, value in pairs(skin.expressions or {}) do
    local percent = (value or 0.0) * 1.0
    percent = math.min(1.0, percent)
    percent = math.max(-1.0, percent)
    SetCharExpression(ped, jo.component.data.expressions[expression], percent)
  end

  jo.component.refreshPed(ped)
  dprint("wait refresh")
  jo.component.waitPedLoaded(ped)

  local eyes = skin.eyesHash or jo.component.getEyesFromIndex(ped, skin.eyesIndex)
  jo.component.apply(ped, "eyes", eyes)

  local teeth = skin.teethHash or jo.component.getTeethFromIndex(ped, skin.teethIndex)
  jo.component.apply(ped, "teeth", teeth)

  jo.component.apply(ped, "hair", skin.hair)
  if skin.model == "mp_male" then
    jo.component.apply(ped, "beards_complete", skin.beards_complete)
  end

  jo.component.waitPedLoaded(ped)

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
  if jo.isModuleLoaded("pedTexture", false) and NetworkGetEntityIsNetworked(ped) then
    jo.pedTexture.overwriteBodyPart(ped, "heads", skin.overlays, true)
  end

  Wait(100)

  SetPedScale(ped, skin.bodyScale)
  dprint("done create ped")

  jo.component.waitPedLoaded(ped)
end

-------------
-- END COMPONENT MANAGEMENT
-------------

-------------
-- WEARABLE STATE
-------------

--- A function to edit the wearable state of a category
--- @param ped integer (The entity ID)
--- @param category integer|string (The category of the component)
--- @param data table (The component data, see the structure in [jo.component.apply()](#jo-component-apply))
--- @param state integer|string (The wearable state to apply on the component <br>  The list of wearable state can be find in the `jo_libs>module>component>client.lua` file `line 76`)
function jo.component.setWearableState(ped, category, data, state)
  local stateHash = GetHashFromString(state)
  local categoryName = jo.component.getCategoryNameFromHash(category)
  local categoryHash = jo.component.getCategoryHash(category)

  local index = getComponentIndexOfCategory(ped, categoryHash)
  if index >= 0 then
    local _, wearableState = GetShopItemComponentAtIndex(ped, index)
    if wearableState == state then
      return false, dprint("State already equiped")
    end
  end

  data = formatComponentData(data) or {}
  local oldComp = getComponentAtIndex(ped, index)
  data.hash = data.hash or oldComp.hash

  if categoryHash == `neckwear` then
    if stateHash == `base` then
      local beardHard, beard = jo.component.getComponentEquiped(ped, "beards_complete")
      if beardHard then
        jo.component.apply(ped, beard.category, beard)
      end
    elseif stateHash == `mask_up` then
      --Dirty fix of beard
      local beardIndex = getComponentIndexOfCategory(ped, "beards_complete")
      if beardIndex >= 0 then
        local armorHash, armor = jo.component.getComponentEquiped(ped, "armor")
        if armorHash then
          local shirtHash, shirt = jo.component.getComponentEquiped(ped, "shirts_full")
          RemoveTagFromMetaPed(ped, `armor`, 0)
          CreateThread(function()
            if shirtHash then
              SetTextureOutfitTints(ped, shirt.category, shirt.palette, shirt.tint0, shirt.tint1, shirt.tint2)
            end
            jo.component.apply(ped, armor.category, armor)
          end)
        end
      end
    end
  end
  if categoryHash == `boots` then
    local pantHash, pant = jo.component.getComponentEquiped(ped, "pants")
    if pantHash then
      CreateThread(function()
        SetTextureOutfitTints(ped, pant.category, pant.palette, pant.tint0, pant.tint1, pant.tint2)
      end)
    end
  end
  updateComponentWearableState(ped, categoryName, data, stateHash)
  if oldComp.palette ~= 0 then
    SetTextureOutfitTints(ped, category, oldComp.palette, oldComp.tint0, oldComp.tint1, oldComp.tint2)
  end
  refreshPed(ped)
end

--- Get the wearable state of a category
--- @param ped integer (The entity ID)
--- @param category string|integer (The category name)
--- @return string (Return the wearable state of the category)
--- @return integer (Return the wearable state hash of the category)
function jo.component.getWearableState(ped, category)
  local index = getComponentIndexOfCategory(ped, category)
  if index < 0 then
    return "not_equiped", 0
  end
  local _, wearableState = GetShopItemComponentAtIndex(ped, index)
  if wearableState == 0 then
    local categoryName = jo.component.getCategoryNameFromHash(category)
    wearableState = Entity(ped).state["wearableState:" .. categoryName]
  end
  local wearableStatesName = jo.component.getWearableStateNameFromHash(wearableState)
  return wearableStatesName, wearableState
end

--- Return if the neckwear is on the face of the player or not
---@param ped integer (The entity ID)
---@return boolean (Return `true` if the neckwear is on the face, `false` otherwise.)
function jo.component.neckwearIsUp(ped)
  return jo.component.getWearableState(ped, "neckwear") == "mask_up"
end

jo.component.isNeckweaUp = jo.component.neckwearIsUp

--- Return if the sleeve are rolled
---@param ped integer (The entity ID)
---@return boolean (Return `true` if the sleeve are rolled, `false` otherwise.)
function jo.component.sleeveIsRolled(ped)
  return jo.component.getWearableState(ped, "shirts_full"):find("rolled") ~= nil
end

jo.component.isSleeveRolled = jo.component.sleeveIsRolled

--- Return if the collar is opened
---@param ped integer (The entity ID)
---@return boolean (Return `true` if the collar is opened, `false` otherwise.)
function jo.component.collarIsOpened(ped)
  return jo.component.getWearableState(ped, "shirts_full"):find("open") and true or false
end

jo.component.isCollarOpened = jo.component.collarIsOpened

--- A function to unroll sleeve
---@param ped integer (The entity ID)
---@param data table (The component data, see the structure in [jo.component.apply()](#jo-component-apply))
function jo.component.sleeveUnroll(ped, hash)
  if jo.component.isCollarOpened(ped) then
    jo.component.setWearableState(ped, "shirts_full", hash, "open_collar_full_sleeve")
  else
    jo.component.setWearableState(ped, "shirts_full", hash, "base")
  end
end

jo.component.unrollSleeve = jo.component.sleeveUnroll

--- A function to roll sleeve
---@param ped integer (The entity ID)
---@param data table (The component data, see the structure in [jo.component.apply()](#jo-component-apply))
function jo.component.sleeveRoll(ped, data)
  local state = jo.component.isCollarOpened(ped) and "open_collar_rolled_sleeve" or "closed_collar_rolled_sleeve"
  jo.component.setWearableState(ped, "shirts_full", data, state)
end

jo.component.rollSleeve = jo.component.sleeveRoll

--- A function to open the collar
---@param ped integer (The entity ID)
---@param data table (The component data, see the structure in [jo.component.apply()](#jo-component-apply))
function jo.component.collarOpen(ped, data)
  local state = jo.component.isSleeveRolled(ped) and "open_collar_rolled_sleeve" or "open_collar_full_sleeve"
  jo.component.setWearableState(ped, "shirts_full", data, state)
end

jo.component.openCollar = jo.component.collarOpen

--- A function to close the collar
---@param ped integer (The entity ID)
---@param data table (The component data, see the structure in [jo.component.apply()](#jo-component-apply))
function jo.component.collarClose(ped, data)
  local state = jo.component.isSleeveRolled(ped) and "closed_collar_rolled_sleeve" or "base"
  jo.component.setWearableState(ped, "shirts_full", data, state)
end

jo.component.closeCollar = jo.component.collarClose

--- A function to know if the boots are under the pant
---@param ped integer (The entity ID)
---@return boolean (Return `true` if boots are under the pant, `false` otherwise.)
function jo.component.bootsAreUnderPant(ped)
  return jo.component.getWearableState(ped, "boots") == "under_pants"
end

jo.component.isBootsUnderPant = jo.component.bootsAreUnderPant

--- A function to know if the vest is under the pant
---@param ped integer (The entity ID)
---@return boolean (Return `true` if the vest is in the pant, `false` otherwise)
function jo.component.vestIsUnderPant(ped)
  return jo.component.getWearableState(ped, "vests") == "under_pants"
end

jo.component.isVestUnderPant = jo.component.vestIsUnderPant

--- A function to know if the loadout is on the right
---@param ped integer (The entity ID)
---@return boolean (Return `true` if the loadout in on the right, `false` otherwise)
function jo.component.loadoutIsOnRight(ped)
  return jo.component.getWearableState(ped, "loadouts") == "base_right"
end

jo.component.isLoadoutOnRight = jo.component.loadoutIsOnRight

--- A function to know if the hair is pomaded
--- @param ped integer (The entity ID)
--- @return boolean (Return `true` if the hair is pomaded)
function jo.component.hairIsPomade(ped)
  return jo.component.getWearableState(ped, "hair") == "pomade"
end

-------------
-- END WEARABLE STATE
-------------

-------------
-- CATEGORIES & COMPONENTS
-------------

--- Return the list of component categories equiped on the ped
---@param ped integer (The entity ID)
---@return table (Return an table with the category in key and data in value <br> `categories[x].index` : integer - the index of the component on the ped <br> `categories[x].category` : string - the category name if the hash is known)
function jo.component.getCategoriesEquiped(ped)
  local categories = {}
  local numComponent = GetNumComponentsInPed(ped)
  for index = 0, numComponent - 1 do
    local category = GetCategoryOfComponentAtIndex(ped, index)
    categories[category] = {
      index = index,
      category = jo.component.getCategoryNameFromHash(category),
      categoryHash = category
    }
    if category == `neckwear` then
      categories[`neckerchiefs`] = table.copy(categories[category])
      categories[`neckerchiefs`].category = "neckerchiefs"
    elseif category == `neckerchiefs` then
      categories[`neckwear`] = table.copy(categories[category])
      categories[`neckwear`].category = "neckwear"
    end
  end
  return categories
end

--- A function to know if a specific category is equiped on the ped
---@param ped integer (The entity ID)
---@param category string|integer (The category name)
---@return boolean (Return `true` if the category is equiped)
---@return integer (Return the index of the category)
function jo.component.isCategoryEquiped(ped, category)
  local index = getComponentIndexOfCategory(ped, category)
  return index >= 0, index
end

--- A function to get the hash of the component equiped in a category
---@param ped integer (The entity ID)
---@param category string|integer (The category to get the component)
---@return integer|boolean (Return the hash of the component or `false` is not equiped)
---@return table (Return the component datas)
function jo.component.getComponentEquiped(ped, category)
  local index = getComponentIndexOfCategory(ped, category)
  if index == -1 then
    return false, {}
  end
  local component = getComponentAtIndex(ped, index)
  return component.hash, component
end

--- A function to get all components equiped
--- @param ped integer (The entity ID)
--- @return table (Return the list of components equiped)
function jo.component.getComponentsEquiped(ped)
  local components = {}
  local numComponent = GetNumComponentsInPed(ped)
  for index = 0, numComponent - 1 do
    local data = getComponentAtIndex(ped, index)
    components[data.categoryHash] = data
  end
  return components
end

--- A function to get the tints of a category
--- @param ped integer (The entity ID)
--- @param category string|integer (The category of the component)
--- @param inTable boolean (When inTable is `true`, returns a table with {palette, tint0, tint1, tint2} <br> When inTable is `false`, returns four separate values: palette, tint0, tint1, tint2)
--- @return table|integer,integer,integer,integer (When inTable is true: returns a table with {palette, tint0, tint1, tint2} <br> When inTable is false: 1st: color palette <br> 2nd: tint number 0 <br> 3rd: tint number 1 <br> 4th: tint number 2)
function jo.component.getCategoryTint(ped, category, inTable)
  if inTable == nil then inTable = false end
  category = jo.component.getCategoryHash(category)
  local isEquiped, index = jo.component.isCategoryEquiped(ped, category)

  if not isEquiped then
    return false
  end

  local palette, tint0, tint1, tint2 = GetMetaPedAssetTint(ped, index)

  if inTable then
    return {
      palette = palette,
      tint0 = tint0,
      tint1 = tint1,
      tint2 = tint2
    }
  end
  return palette, tint0, tint1, tint2
end

-------------
-- END CATEGORIES & COMPONENTS
-------------

-------------
-- CONVERT HASH
-------------

--- A function to get the palette name from a hash value
---@param hash integer (The palette hash)
---@return string (The palette name, or "unknown" if not found)
function jo.component.getPaletteNameFromHash(hash)
  if not hash then return "no hash" end
  if type(hash) == "string" then return hash end
  return jo.component.data.palettesName[hash] or "unknown"
end

--- A function to get the category name from a hash value
---@param category integer|string (The category hash)
---@return string (The category name, or "unknown" if not found)
function jo.component.getCategoryNameFromHash(category)
  if type(category) == "string" then return category end
  if not category then return "no hash" end
  return jo.component.data.categoryName[category] or "unknown"
end

function jo.component.getWearableStateNameFromHash(state)
  if type(state) == "string" then return state end
  if not state then return "no hash" end
  return jo.component.data.wearableStatesName[state] or "unknown"
end

-------------
-- END CONVERT HASH
-------------

function jo.component.isCategoryAClothes(category)
  category = jo.component.getCategoryHash(category)
  return jo.component.data.clothesCategories[category] ~= nil
end
