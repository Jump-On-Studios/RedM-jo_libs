jo.clothes = {}

if not table.isEmpty then
  jo.require('table')
end

if not not IsModuleLoaded('timeout') then
  jo.require('timeout')
end

if not DataView then
  jo.require('dataview')
end

-------------
-- Variables
-------------
jo.cache.clothes = {
  color = {},
  getEquiped = {}
}

jo.clothes.order = {
  'ponchos',
  'cloaks',
  'hair_accessories',
  'dresses',
  'gloves',
  'coats',
  'coats_closed',
  'vests',
  'suspenders',
  'neckties',
  'neckwear',
  'shirts_full',
  'spats',
  'gunbelts',
  'gauntlets',
  'holsters_left',
  'loadouts',
  'belt_buckles',
  'belts',
  'skirts',
  'pants',
  'boots',
  'boot_accessories',
  'accessories',
  'satchels',
  'jewelry_rings_right',
  'jewelry_rings_left',
  'jewelry_bracelets',
  'aprons',
  'chaps',
  'badges',
  'gunbelt_accs',
  'eyewear',
  'armor',
  'masks',
  'masks_large',
  'hats',
  'hair',
  'beards_complete',
  'teeth'
}
jo.clothes.categoryName = {
  [`heads`] = "heads",
  [`bodies_lower`] = "bodies_lower",
  [`bodies_upper`] = "bodies_upper",
  [`eyes`] = "eyes",
  [`neckerchiefs`] = "neckerchiefs"
}
for _, category in pairs(jo.clothes.order) do
  jo.clothes.categoryName[joaat(category)] = category
end

jo.clothes.wearableStates = {
  shirts_full = {
    -- first digit for collar : 0 = closed/1 = opened
    -- second digit for sleeve : 0 = full/1 = rolled
    [00] = 'base',
    [01] = 'closed_collar_rolled_sleeve',
    [10] = 'open_collar_full_sleeve',
    [11] = 'open_collar_rolled_sleeve',
  },
  neckwear = {
    [0] = 'base',     --down
    [1] = -1829635046 --up
  },
  boots = {
    [0] = 'base',       --upper
    [1] = 'under_pants' --under
  },
  loadouts = {
    [0] = 'base',       --right
    [1] = 'base_right', --left
  },
  vests = {
    [0] = 'base',       --upper
    [1] = 'under_pants' --under
  },
  hair = {
    [0] = 'base',
    [1] = 'pomade'
  }
}

-------------
-- local functions
-------------

local function SetTextureOutfitTints(ped, category, palette, tint0, tint1, tint2)
  if palette == 0 then return end
  Citizen.InvokeNative(0x4EFC1F8FF1AD94DE, ped, GetHashFromString(category), palette, tint0, tint1, tint2)
end
local function N_0xAAB86462966168CE(ped) return Citizen.InvokeNative(0xAAB86462966168CE, ped, true) end
local function N_0x704C908E9C405136(ped) return Citizen.InvokeNative(0x704C908E9C405136, ped) end
local function GetShopItemBaseLayers(hash, metapedType, isMp) return Citizen.InvokeNative(0x63342C50EC115CE8, hash, 0, 0,metapedType, isMp, Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt(),Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt(),Citizen.PointerValueInt()) end
local function UpdatePedVariation(ped) return Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true,false) end
local function IsPedReadyToRender(...) return Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, ...) end
local function RefreshPed(ped)
  N_0xAAB86462966168CE(ped)
  UpdatePedVariation(ped)
  N_0x704C908E9C405136(ped)
end
local function GetCategoryOfComponentAtIndex(ped, componentIndex) return Citizen.InvokeNative(0x9b90842304c938a7, ped,componentIndex, 0, Citizen.ResultAsInteger()) end
local function GetMetaPedAssetTint(ped, index) return Citizen.InvokeNative(0xE7998FEC53A33BBE, ped, index,Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt()) end
local function GetNumComponentsInPed(ped) return Citizen.InvokeNative(0x90403E8107B60E81, ped) end
local function GetMetaPedType(ped) return Citizen.InvokeNative(0xEC9A1261BF0CE510, ped) end
local function GetShopItemComponentCategory(...) return Citizen.InvokeNative(0x5FF9A878C3D115B8, ...) end
local function IsMetaPedUsingComponent(...) return Citizen.InvokeNative(0xFB4891BD7578CDC1, ...) == 1 end
local function GetShopItemComponentAtIndex(ped, index)
  local dataStruct = DataView.ArrayBuffer(10 * 8)
  local componentHash = GetShopPedComponentAtIndex(ped, index, true, dataStruct:Buffer(), dataStruct:Buffer())
  if not componentHash or componentHash == 0 then
    componentHash = GetShopPedComponentAtIndex(ped, index, false, dataStruct:Buffer(), dataStruct:Buffer())
  end
  return componentHash
end
local function UpdateShopItemWearableState(ped, hash, state)
  state = GetHashFromString(state)
  return Citizen.InvokeNative(0x66B957AAC2EAAEAB, ped, hash, state, 0, true, 1)
end
local function WaitRefreshPed(ped) while not IsPedReadyToRender(ped) do Wait(0) end end

---@return string categoryName
local function getCategoryName(category)
  if type(category) == "string" then return category end
  return jo.clothes.categoryName[category] or ('unknown:' .. category)
end

---@return table data formatted table for clothes data
local function formatClothesData(data)
  if type(data) == "table" then
    if type(data.hash) == "table" then --for VORP
      return data.hash
    end
    return data
  end
  if type(data) ~= "number" then data = tonumber(data) end
  if data == 0 or data == -1 or data == 1 or data == nil then
    data = false
  end
  return {
    hash = data
  }
end

-------------
-- Color management
-------------

---@param ped integer the entity ID
---@param category integer the category hash
local function ResetCachedColor(ped, category)
  if not jo.cache.clothes.color[ped] then return end
  jo.cache.clothes.color[ped][category] = nil
  if category == `neckwear` then
    jo.cache.clothes.color[ped][`neckerchiefs`] = nil
  end
end

---@param ped integer the entity ID
---@param category integer the category hash
---@param hash integer the component hash
---@param palette integer the palette hash
---@param tint0 integer
---@param tint1 integer
---@param tint2 integer
local function AddCachedClothes(ped, category, hash, palette, tint0, tint1, tint2)
  category = GetHashFromString(category)
  if not jo.cache.clothes.color[ped] then jo.cache.clothes.color[ped] = {} end
  jo.cache.clothes.color[ped][category] = {
    category = getCategoryName(category),
    palette = palette,
    tint0 = tint0,
    tint1 = tint1,
    tint2 = tint2,
    hash = hash
  }
  if category == `neckwear` then
    jo.cache.clothes.color[ped][`neckerchiefs`] = jo.cache.clothes.color[ped][category]
    jo.cache.clothes.color[ped][`neckerchiefs`].category = "neckerchiefs"
  elseif category == `neckerchiefs` then
    jo.cache.clothes.color[ped][`neckwear`] = jo.cache.clothes.color[ped][category]
    jo.cache.clothes.color[ped][`neckwear`].category = 'neckwear'
  end
end

---@param ped integer the entity ID
function PutInCacheCurrentClothes(ped)
  if jo.cache.clothes.color[ped] then return jo.cache.clothes.color[ped] end
  local numComponent = GetNumComponentsInPed(ped)
  if not numComponent then return end -- No component detected on the ped
  for index = 0, numComponent - 1 do
    --Get current clothes
    local palette, tint0, tint1, tint2 = GetMetaPedAssetTint(ped, index)
    local category = GetCategoryOfComponentAtIndex(ped, index)
    local hash = GetShopItemComponentAtIndex(ped, index)
    AddCachedClothes(ped, category, hash, palette, tint0, tint1, tint2)
  end
  return jo.cache.clothes.color[ped]
end

-------------
-- Cache management
-------------
local function ReapplyClothesStats(ped)
  local hash = 0
  for category, _ in pairs(jo.clothes.wearableStates) do
    local isEquiped, index = jo.clothes.isCategoryEquiped(ped, category)
    local state = Entity(ped).state['wearableState:' .. category]
    if isEquiped and state and state ~= 'base' then
      hash = GetShopItemComponentAtIndex(ped, index)
      UpdateShopItemWearableState(ped, hash, state)
    end
  end
  RefreshPed(ped)
end

local function ReapplyClothesColor(ped)
  for category, data in pairs(jo.cache.clothes.color[ped] or {}) do
    SetTextureOutfitTints(ped, category, data.palette, data.tint0, data.tint1, data.tint2)
  end
  jo.cache.clothes.color[ped] = nil
end

local function ReapplyCached(ped)
  if not jo.cache.clothes.color[ped] then return end
  jo.timeout.delay('ReapplyCachedColor', function() WaitRefreshPed(ped) end, function()
    ReapplyClothesStats(ped)
    ReapplyClothesColor(ped)
    RefreshPed(ped)
  end)
end

-------------
-- Modules functions
-------------

---@param ped integer the entity ID of the ped
---@param hash integer the hash of the clothes
---@return integer categoryHash
---@return boolean isMp
function jo.clothes.getComponentCategory(ped, hash)
  local isMp = true
  local categoryHash = GetShopItemComponentCategory(hash, GetMetaPedType(ped), true)
  if not categoryHash then
    isMp = false
    categoryHash = GetShopItemComponentCategory(hash, GetMetaPedType(ped), false)
  end
  return categoryHash, isMp
end

---@param ped integer the entity
---@param category string the clothes category
---@param data any the clothes data
function jo.clothes.apply(ped, category, data)
  data = formatClothesData(data)

  local categoryHash = GetHashFromString(category)
  local isMp = true

  if data.hash then
    categoryHash, isMp = jo.clothes.getComponentCategory(ped, data.hash)
  end

  PutInCacheCurrentClothes(ped)

  --remove the current clothes for this category
  RemoveTagFromMetaPed(ped, categoryHash, 0)
  if (categoryHash == `neckwear`) then
    RemoveTagFromMetaPed(ped, `neckerchiefs`, 0)
  end
  if (category == "ponchos") then
    RemoveTagFromMetaPed(ped, `cloaks`, 0)
    RemoveTagFromMetaPed(ped, `ponchos`, 0)
  end
  if (category == "cloaks") then
    RemoveTagFromMetaPed(ped, `ponchos`, 0)
    RemoveTagFromMetaPed(ped, `cloaks`, 0)
  end
  ResetCachedColor(ped, categoryHash)

  if data.hash then
    if category == "coats" then
      RemoveTagFromMetaPed(ped, 'coats_closed', 0);
    elseif category == "coats_closed" then
      RemoveTagFromMetaPed(ped, 'coats', 0);
    elseif category == "skirts" then
      RemoveTagFromMetaPed(ped, 'pants', 0);
    end
    if category == "masks" or (data.drawable) or category == "hats" then
      local drawable, albedo, normal, material, palette, tint0, tint1, tint2 = 0, 0, 0, 0, 0, 0, 0, 0
      if data.hash then
        drawable, albedo, normal, material, palette, tint0, tint1, tint2 = GetShopItemBaseLayers(data.hash,GetMetaPedType(ped), isMp)
      end
      if data.drawable then
        drawable = data.drawable
        albedo = data.albedo
        normal = data.normal
        material = data.material
      end
      if data.palette then
        palette = data.palette
        tint0 = data.tint0
        tint1 = data.tint1
        tint2 = data.tint2
      end
      SetMetaPedTag(ped, drawable, albedo, normal, material, palette, tint0, tint1, tint2) -- 10 is black in the case of this asset's palette_id
    else
      ApplyShopItemToPed(ped, data.hash, true, true, false)
      ApplyShopItemToPed(ped, data.hash, true, false, false)
      if data.palette and data.palette ~= 0 then
        AddCachedClothes(ped, categoryHash, data.hash, GetHashFromString(data.palette), data.tint0, data.tint1,
          data.tint2)
      end
      local state = Entity(ped).state['wearableState:' .. category]
      if state then
        UpdateShopItemWearableState(ped, data.hash, state)
      end
    end
  end
  RefreshPed(ped)
  ReapplyCached(ped)
end

---@param ped integer the entity
---@param category string the clothes category
function jo.clothes.remove(ped, category)
  return jo.clothes.apply(ped, category, 0)
end

-------------
-- WEARABLE STATE
-------------

---@param ped integer the entity
---@param category string the category
---@param hash any the hash of the clothes
---@param state any
function jo.clothes.setWearableState(ped, category, hash, state)
  Entity(ped).state:set('wearableState:' .. category, state)
  PutInCacheCurrentClothes(ped)
  local data = formatClothesData(hash)
  if not data.hash then
    data.hash = jo.clothes.getComponentEquiped(jo.me,category)
  end
  UpdateShopItemWearableState(ped, data.hash, state)
  if category == "neckwear" and GetHashFromString(state) == `base` then
    jo.clothes.apply(ped, "beards_complete", jo.cache.clothes.color[ped][`beards_complete`])
  end
  RefreshPed(ped)
  ReapplyCached(ped)
end

---@param ped integer the entity
---@return boolean
function jo.clothes.neckwearIsUp(ped)
  return Entity(ped).state['wearableState:neckwear'] == jo.clothes.wearableStates.neckwear[1]
end

jo.clothes.isNeckweaUp = jo.clothes.neckwearIsUp

---@param ped integer the entity
---@return boolean
function jo.clothes.sleeveIsRolled(ped)
  return (Entity(ped).state['wearableState:shirts_full'] or ""):find('rolled') ~= nil
end

jo.clothes.isSleeveRolled = jo.clothes.sleeveIsRolled

---@param ped integer the entity
---@return boolean
function jo.clothes.collarIsOpened(ped)
  return (Entity(ped).state['wearableState:shirts_full'] or ""):find('open') and true or false
end

jo.clothes.isCollarOpened = jo.clothes.collarIsOpened

---@param ped integer the entity
---@param hash any the hash of the clothes
function jo.clothes.sleeveUnroll(ped, hash)
  if jo.clothes.isCollarOpened(ped) then
    jo.clothes.setWearableState(ped, 'shirts_full', hash, jo.clothes.wearableStates.shirts_full[10])
  else
    jo.clothes.setWearableState(ped, 'shirts_full', hash, jo.clothes.wearableStates.shirts_full[00])
  end
end

jo.clothes.unrollSleeve = jo.clothes.sleeveUnroll

---@param ped integer the entity
---@param hash any the hash of the clothes
function jo.clothes.sleeveRoll(ped, hash)
  if jo.clothes.isCollarOpened(ped) then
    jo.clothes.setWearableState(ped, 'shirts_full', hash, jo.clothes.wearableStates.shirts_full[11])
  else
    jo.clothes.setWearableState(ped, 'shirts_full', hash, jo.clothes.wearableStates.shirts_full[01])
  end
end

jo.clothes.rollSleeve = jo.clothes.sleeveRoll

---@param ped integer the entity
---@param hash any the hash of the clothes
function jo.clothes.collarOpen(ped, hash)
  if jo.clothes.isSleeveRolled(ped) then
    jo.clothes.setWearableState(ped, 'shirts_full', hash, jo.clothes.wearableStates.shirts_full[11])
  else
    jo.clothes.setWearableState(ped, 'shirts_full', hash, jo.clothes.wearableStates.shirts_full[10])
  end
end

jo.clothes.openCollar = jo.clothes.collarOpen

---@param ped integer the entity
---@param hash any the hash of the clothes
function jo.clothes.collarClose(ped, hash)
  if jo.clothes.isSleeveRolled(ped) then
    jo.clothes.setWearableState(ped, 'shirts_full', hash, jo.clothes.wearableStates.shirts_full[01])
  else
    jo.clothes.setWearableState(ped, 'shirts_full', hash, jo.clothes.wearableStates.shirts_full[00])
  end
end

jo.clothes.closeCollar = jo.clothes.collarClose

---@param ped integer the entity
---@return boolean
function jo.clothes.bootsAreUnderPant(ped)
  return Entity(ped).state['wearableState:boots'] == jo.clothes.wearableStates.boots[1]
end

jo.clothes.isBootsUnderPant = jo.clothes.bootsAreUnderPant

---@param ped integer the entity
---@return boolean
function jo.clothes.vestIsUnderPant(ped)
  return Entity(ped).state['wearableState:vests'] == jo.clothes.wearableStates.vests[1]
end

jo.clothes.isVestUnderPant = jo.clothes.vestIsUnderPant

---@param ped integer the entity
---@return boolean
function jo.clothes.loadoutIsOnRight(ped)
  return Entity(ped).state['wearableState:loadouts'] == jo.clothes.wearableStates.loadouts[1]
end

jo.clothes.isLoadoutOnRight = jo.clothes.loadoutIsOnRight

function jo.clothes.hairIsPomade(ped)
  return Entity(ped).state['wearableState:hair'] == jo.clothes.wearableStates.hair[1]
end

-------------
-- CATEGORIES & COMPONENTS
-------------

---@param ped integer the entity
---@return table
function jo.clothes.getCategoriesEquiped(ped)
  if jo.cache.clothes.getEquiped[ped] then
    return jo.cache.clothes.getEquiped[ped]
  end
  jo.cache.clothes.getEquiped[ped] = {}
  local numComponent = GetNumComponentsInPed(ped) or 0
  for index = 0, numComponent - 1 do
    --Get current clothes
    local category = GetCategoryOfComponentAtIndex(ped, index)
    jo.cache.clothes.getEquiped[ped][category] = {
      index = index,
      category = getCategoryName(category),
    }
    if category == `neckwear` then
      jo.cache.clothes.getEquiped[ped][`neckerchiefs`] = jo.cache.clothes.getEquiped[ped][category]
      jo.cache.clothes.getEquiped[ped][`neckerchiefs`].category = 'neckerchiefs'
    elseif category == `neckerchiefs` then
      jo.cache.clothes.getEquiped[ped][`neckwear`] = jo.cache.clothes.getEquiped[ped][category]
      jo.cache.clothes.getEquiped[ped][`neckwear`].category = 'neckwear'
    end
  end
  --clear cached value
  SetTimeout(500, function()
    jo.cache.clothes.getEquiped[ped] = nil
  end)
  return jo.cache.clothes.getEquiped[ped]
end

---@param ped integer the entity
---@param category string
---@return boolean,integer
function jo.clothes.isCategoryEquiped(ped, category)
  local categoryHash = GetHashFromString(category)
  if not IsMetaPedUsingComponent(ped,categoryHash) then
    return false,0
  end
  local equiped = jo.clothes.getCategoriesEquiped(ped)
  if not equiped[categoryHash] then return false,0 end
  return true, equiped[categoryHash].index
end

function jo.clothes.getComponentEquiped(ped,category)
  local categoryHash = GetHashFromString(category)
  if not IsMetaPedUsingComponent(ped,categoryHash) then
    return false
  end
  local equiped = jo.clothes.getCategoriesEquiped(ped)
  local index = equiped[categoryHash].index
  return GetShopItemComponentAtIndex(ped, index)
end

return jo.clothes
