jo.component = {}

jo.require("table")
jo.require("timeout")
jo.require("dataview")

-------------
-- Variables
-------------
jo.cache.component = {
  color = {},
  getEquiped = {}
}

jo.component.order = {
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
jo.component.categoryName = {
  [`heads`] = "heads",
  [`bodies_lower`] = "bodies_lower",
  [`bodies_upper`] = "bodies_upper",
  [`eyes`] = "eyes",
  [`neckerchiefs`] = "neckerchiefs"
}
for _, category in pairs(jo.component.order) do
  jo.component.categoryName[joaat(category)] = category
end

jo.component.wearableStates = {
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

-------------
-- local functions
-------------
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
local function RefreshPed(ped)
  N_0xAAB86462966168CE(ped)
  UpdatePedVariation(ped)
  N_0x704C908E9C405136(ped)
end
jo.component.refreshPed = RefreshPed
local function GetCategoryOfComponentAtIndex(ped, componentIndex)
  local pedType = 0
  if IsThisModelAHorse(GetEntityModel(ped)) then
    pedType = 6
  end
  return invokeNative(0x9b90842304c938a7, ped, componentIndex, pedType, Citizen.ResultAsInteger())
end
local function GetMetaPedAssetTint(ped, index) return invokeNative(0xE7998FEC53A33BBE, ped, index, Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt()) end
local function GetNumComponentsInPed(ped) return invokeNative(0x90403E8107B60E81, ped) end
local function GetMetaPedType(ped) return invokeNative(0xEC9A1261BF0CE510, ped) end
local function GetShopItemComponentCategory(...) return invokeNative(0x5FF9A878C3D115B8, ...) end
local function IsMetaPedUsingComponent(...) return invokeNative(0xFB4891BD7578CDC1, ...) == 1 end
local function GetShopItemComponentAtIndex(ped, index)
  local dataStruct = DataView.ArrayBuffer(10 * 8)
  local componentHash = GetShopPedComponentAtIndex(ped, index, true, dataStruct:Buffer(), dataStruct:Buffer())
  if not componentHash or componentHash == 0 then
    componentHash = GetShopPedComponentAtIndex(ped, index, false, dataStruct:Buffer(), dataStruct:Buffer())
  end
  return componentHash
end
local function UpdateShopItemWearableState(ped, hash, state)
  return invokeNative(0x66B957AAC2EAAEAB, ped, GetHashFromString(hash), GetHashFromString(state), 0, true, 1)
end
local function WaitRefreshPed(ped) while not IsPedReadyToRender(ped) do Wait(0) end end
jo.component.waitPedLoaded = WaitRefreshPed
local function SetMetaPedTag(ped, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
  return invokeNative(0xBC6DF00D7A4A6819, ped, GetHashFromString(drawable), GetHashFromString(albedo), GetHashFromString(normal), GetHashFromString(material), GetHashFromString(palette), tint0, tint1, tint2)
end

---@return string categoryName
local function getCategoryName(category)
  if not category then return "" end
  if type(category) == "string" then return category end
  return jo.component.categoryName[category]
end

local function isValidValue(value)
  return value and value ~= 0 and value ~= -1 and value ~= 1
end

---@return table data formatted table for component data
local function formatComponentData(_data)
  data = table.copy(_data)
  if type(data) ~= "table" then
    data = { hash = data }
  end
  if type(data.hash) == "table" then data = data.hash end --for VORP
  data.hash = isValidValue(data.hash) and data.hash or false
  data.drawable = isValidValue(data.drawable) and data.drawable or false
  data.palette = isValidValue(data.palette) and data.palette or false
  return data
end

-------------
-- Color management
-------------

---@param ped integer the entity ID
---@param category integer the category hash
local function ResetCachedColor(ped, category)
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
    category = getCategoryName(category),
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

function ResetCachedPed(ped)
  jo.timeout.delay("jo_libs:resetCachedPed", 25, function(ped)
    jo.cache.component.color[ped] = nil
    jo.cache.component.getEquiped[ped] = nil
  end, ped)
end

-------------
-- Cache management
-------------
local function reapplyComponentStats(ped)
  local hash = 0
  for category, _ in pairs(jo.component.wearableStates) do
    local isEquiped, index = jo.component.isCategoryEquiped(ped, category)
    local state = Entity(ped).state["wearableState:" .. category]
    if isEquiped and state and state ~= "base" then
      hash = GetShopItemComponentAtIndex(ped, index)
      UpdateShopItemWearableState(ped, hash, state)
    end
  end
  RefreshPed(ped)
end

local function reapplyComponentsColor(ped)
  for category, data in pairs(jo.cache.component.color[ped] or {}) do
    SetTextureOutfitTints(ped, category, data.palette, data.tint0, data.tint1, data.tint2)
  end
end

local function ReapplyCached(ped)
  if not jo.cache.component.color[ped] then return end
  jo.timeout.delay("jo_libs:component:reapplyCachedColor", function() WaitRefreshPed(ped) end, function()
    RefreshPed(ped)
    WaitRefreshPed(ped)
    reapplyComponentStats(ped)
    reapplyComponentsColor(ped)
    ResetCachedPed(ped)
    RefreshPed(ped)
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

local function getBaseLayer(ped, hash)
  local drawable, albedo, normal, material, palette, tint0, tint1, tint2 = GetShopItemBaseLayers(hash, GetMetaPedType(ped), jo.component.isMpComponent(ped, hash))
  if drawable == 0 or drawable == 1 then drawable = nil end
  if albedo == 0 then albedo = nil end
  if normal == 0 then normal = nil end
  if material == 0 then material = nil end
  if palette == 0 then palette = nil end
  return drawable, albedo, normal, material, palette, tint0, tint1, tint2
end

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

---@param ped integer the entity
---@param category string the component category
---@param data any the component data
function jo.component.apply(ped, category, data)
  data = formatComponentData(data)

  local categoryHash = GetHashFromString(category)
  local isMp = true

  if data.hash then
    categoryHash, isMp = jo.component.getComponentCategory(ped, data.hash)
  end

  putInCacheCurrentComponent(ped)

  ResetCachedColor(ped, categoryHash)

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

    if data.hash then
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
  ReapplyCached(ped)
end

---@param ped integer the entity
---@param category string the component category
function jo.component.remove(ped, category)
  return jo.component.apply(ped, category, 0)
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
  ReapplyCached(ped)
end

function jo.component.getWearableState(ped, category)
  local state = Entity(ped).state["wearableState:" .. category]
  if (type(state) == "string") then return state end
  return ""
end

---@param ped integer the entity
---@return boolean
function jo.component.neckwearIsUp(ped)
  return Entity(ped).state["wearableState:neckwear"] == jo.component.wearableStates.neckwear[1]
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
    jo.component.setWearableState(ped, "shirts_full", hash, jo.component.wearableStates.shirts_full[10])
  else
    jo.component.setWearableState(ped, "shirts_full", hash, jo.component.wearableStates.shirts_full[00])
  end
end

jo.component.unrollSleeve = jo.component.sleeveUnroll

---@param ped integer the entity
---@param hash any the hash of the component
function jo.component.sleeveRoll(ped, hash)
  if jo.component.isCollarOpened(ped) then
    jo.component.setWearableState(ped, "shirts_full", hash, jo.component.wearableStates.shirts_full[11])
  else
    jo.component.setWearableState(ped, "shirts_full", hash, jo.component.wearableStates.shirts_full[01])
  end
end

jo.component.rollSleeve = jo.component.sleeveRoll

---@param ped integer the entity
---@param hash any the hash of the component
function jo.component.collarOpen(ped, hash)
  if jo.component.isSleeveRolled(ped) then
    jo.component.setWearableState(ped, "shirts_full", hash, jo.component.wearableStates.shirts_full[11])
  else
    jo.component.setWearableState(ped, "shirts_full", hash, jo.component.wearableStates.shirts_full[10])
  end
end

jo.component.openCollar = jo.component.collarOpen

---@param ped integer the entity
---@param hash any the hash of the component
function jo.component.collarClose(ped, hash)
  if jo.component.isSleeveRolled(ped) then
    jo.component.setWearableState(ped, "shirts_full", hash, jo.component.wearableStates.shirts_full[01])
  else
    jo.component.setWearableState(ped, "shirts_full", hash, jo.component.wearableStates.shirts_full[00])
  end
end

jo.component.closeCollar = jo.component.collarClose

---@param ped integer the entity
---@return boolean
function jo.component.bootsAreUnderPant(ped)
  return Entity(ped).state["wearableState:boots"] == jo.component.wearableStates.boots[1]
end

jo.component.isBootsUnderPant = jo.component.bootsAreUnderPant

---@param ped integer the entity
---@return boolean
function jo.component.vestIsUnderPant(ped)
  return Entity(ped).state["wearableState:vests"] == jo.component.wearableStates.vests[1]
end

jo.component.isVestUnderPant = jo.component.vestIsUnderPant

---@param ped integer the entity
---@return boolean
function jo.component.loadoutIsOnRight(ped)
  return Entity(ped).state["wearableState:loadouts"] == jo.component.wearableStates.loadouts[1]
end

jo.component.isLoadoutOnRight = jo.component.loadoutIsOnRight

function jo.component.hairIsPomade(ped)
  return Entity(ped).state["wearableState:hair"] == jo.component.wearableStates.hair[1]
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
      category = getCategoryName(category),
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
  ResetCachedPed(ped)
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

function jo.component.getComponentsEquiped(ped)
  local component = putInCacheCurrentComponent(ped) or {}
  ResetCachedPed(ped)
  return component
end

-- Add shortcut with old name
for _, shortcut in pairs({ "clothes", "comp" }) do
  jo[shortcut] = setmetatable({}, {
    __index = function(self, key)
      return jo.component[key]
    end
  })
end
