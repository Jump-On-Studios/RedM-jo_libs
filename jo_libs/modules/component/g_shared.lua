jo.require("file")

jo.component = {}

--- A fonction to get the category hash from its string
---@param category string|integer (The category string)
---@return integer (The category hash)
function jo.component.getCategoryHash(category)
  if type(category) == "number" then return category end

  if category == "horse_feathers" then
    return -287556490
  end

  return joaat(category)
end

-------------
-- DATA
-------------
jo.component.data = jo.component.data or {}

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
  "shawls",
  "chemises",
  "knickers",
  "gloves",
  "coats",
  "coats_closed",
  "coat_accessories",
  "coats_heavy",
  "vests",
  "vest_accessories",
  "corsets",
  "suspenders",
  "neckties",
  "shirts_full",
  "shirts_full_overpants",
  "unionsuit_legs",
  "unionsuits_full",
  "spats",
  "gunbelts",
  "gauntlets",
  "wrist_bindings",
  "holsters_left",
  "holsters_right",
  "holsters_center",
  "holsters_crossdraw",
  "holsters_knife",
  "holsters_quivers",
  "loadouts",
  "outfits",
  "belt_buckles",
  "belts",
  "skirts",
  "boots",
  "pants",
  "pants_accessories",
  "overalls_full",
  "overalls_modular_uppers",
  "overalls_modular_lowers",
  "boot_accessories",
  "ankle_bindings",
  "accessories",
  "satchels",
  "satchel_straps",
  "jewelry_rings_right",
  "jewelry_rings_left",
  "jewelry_rings",
  "jewelry_bracelets",
  "jewelry_earrings",
  "jewelry_necklaces",
  "aprons",
  "chaps",
  "badges",
  "gunbelt_accs",
  "eyewear",
  "masks",
  "masks_large",
  "hats",
  "hat_accessories",
  "headwear",
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
-- COMPONENT LISTS
-------------

--- A function to get the list of clothes sorted by sex and category
---@return table clothes_list_sorted
local playerComponentsData = nil
function jo.component.getFullPedComponentList()
  if playerComponentsData then return playerComponentsData end
  playerComponentsData = jo.file.load("component.data.playerComponents")
  return playerComponentsData
end

--- A function to get the list of horse's components sorted by category
---@return table horseData
local horseComponentsData = nil
function jo.component.getFullHorseComponentList()
  if horseComponentsData then return horseComponentsData end
  horseComponentsData = jo.file.load("component.data.horseComponents")
  return horseComponentsData
end

-------------
-- END COMPONENT LISTS
-------------

-------------
-- FUNCTIONS
-------------
--- A function to format component data
---@param _data string|number|table (The component data)
---@param hashData boolean (Hash the value is true)
---@return any data (The foormatted table for component data)
function jo.component.formatComponentData(_data, hashData)
  hashData = GetValue(hashData, false)
  local data = table.copy(_data)
  if type(data) ~= "table" then
    data = { hash = data }
  end
  if table.type(data) == "array" then
    data = {
      hash = data[1] or 0,
      drawable = data[2],
      albedo = data[3],
      normal = data[4],
      material = data[5],
      palette = data[6],
      tint0 = data[7],
      tint1 = data[8],
      tint2 = data[9]
    }
  end
  if type(data.hash) == "table" then data = data.hash end --for VORP

  if hashData then
    for key, value in pairs(data) do
      data[key] = GetHashFromString(value)
    end
  end

  return data
end

--- A function to get the head component hash from head index and skin tone
---@param ped integer (The entity ID)
---@param headIndex? integer (The head index, defaults to 1)
---@param skinTone? integer (The skin tone, defaults to 1)
---@return string (The head component hash string)
function jo.component.getHeadFromSkinTone(ped, headIndex, skinTone)
  local ped = ped or PlayerPedId()
  local sex = "M"
  if type(ped) == "string" then
    sex = (ped == "mp_male") and "M" or "F"
  else
    sex = IsPedMale(ped) and "M" or "F"
  end
  return ("CLOTHING_ITEM_%s_HEAD_%03d_V_%03d"):format(sex, headIndex or 1, skinTone or 1)
end

--- A function to get the lower body component hash from bodies index and skin tone
---@param ped integer|string (The entity ID or model name)
---@param bodiesIndex? integer (The bodies index, defaults to 1)
---@param skinTone? integer (The skin tone, defaults to 1)
---@return string (The lower body component hash string)
function jo.component.getBodiesLowerFromSkinTone(ped, bodiesIndex, skinTone)
  local ped = ped or PlayerPedId()
  local sex = "M"
  if type(ped) == "string" then
    sex = (ped == "mp_male") and "M" or "F"
  else
    sex = IsPedMale(ped) and "M" or "F"
  end
  return ("CLOTHING_ITEM_%s_BODIES_LOWER_%03d_V_%03d"):format(sex, bodiesIndex or 1, skinTone or 1)
end

--- A function to get the upper body component hash from bodies index and skin tone
---@param ped integer|string (The entity ID or model name)
---@param bodiesIndex? integer (The bodies index, defaults to 1)
---@param skinTone? integer (The skin tone, defaults to 1)
---@return string (The upper body component hash string)
function jo.component.getBodiesUpperFromSkinTone(ped, bodiesIndex, skinTone)
  local ped = ped or PlayerPedId()
  local sex = "M"
  if type(ped) == "string" then
    sex = (ped == "mp_male") and "M" or "F"
  else
    sex = IsPedMale(ped) and "M" or "F"
  end
  return ("CLOTHING_ITEM_%s_BODIES_UPPER_%03d_V_%03d"):format(sex, bodiesIndex or 1, skinTone or 1)
end

--- A function to get the eyes component hash from an index
---@param ped integer|string (The entity ID or model name)
---@param index? integer (The eyes index, defaults to 1)
---@return string (The eyes component hash string)
function jo.component.getEyesFromIndex(ped, index)
  local ped = ped or PlayerPedId()
  local sex = "M"
  if type(ped) == "string" then
    sex = (ped == "mp_male") and "M" or "F"
  else
    sex = IsPedMale(ped) and "M" or "F"
  end
  return ("CLOTHING_ITEM_%s_EYES_001_TINT_%03d"):format(sex, index or 1)
end

--- A function to get the teeth component hash from an index
---@param ped integer|string (The entity ID or model name)
---@param index? integer (The teeth index, defaults to 1)
---@return string (The teeth component hash string)
function jo.component.getTeethFromIndex(ped, index)
  local ped = ped or PlayerPedId()
  local sex = "M"
  if type(ped) == "string" then
    sex = (ped == "mp_male") and "M" or "F"
  else
    sex = IsPedMale(ped) and "M" or "F"
  end
  return ("CLOTHING_ITEM_%s_TEETH_%03d"):format(sex, index or 1)
end

-------------
-- END FUNCTIONS
-------------

exports("jo_component_get", function()
  return jo.component
end)
