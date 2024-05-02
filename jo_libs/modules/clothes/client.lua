jo.clothes = {}

if not table.isEmpty then
  jo.require('table')
end

if not not IsModuleLoaded('timeout') then
  jo.require('timeout')
end

-------------
-- Functions to keep clothes colors
-------------
local cachedPedColor = {}
local currentTimeout

local function SetTextureOutfitTints(ped,category,palette,tint0,tint1,tint2) if palette ~= 0 then Citizen.InvokeNative(0x4EFC1F8FF1AD94DE,ped,GetHashFromString(category),palette,tint0,tint1,tint2) end end
local function N_0xAAB86462966168CE(ped) return Citizen.InvokeNative(0xAAB86462966168CE,ped,true) end
local function GetShopItemBaseLayers(hash,metapedType,isMp) return Citizen.InvokeNative(0x63342C50EC115CE8, hash,0,0,metapedType,isMp,Citizen.PointerValueInt(),Citizen.PointerValueInt(),Citizen.PointerValueInt(),Citizen.PointerValueInt(),Citizen.PointerValueInt(),Citizen.PointerValueInt(),Citizen.PointerValueInt(),Citizen.PointerValueInt()) end
local function UpdatePedVariation(ped) return Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true, false) end
local function RefreshPed(ped) Citizen.InvokeNative(0x704C908E9C405136, ped) UpdatePedVariation(ped) end
local function GetCategoryOfComponentAtIndex(ped, componentIndex) return Citizen.InvokeNative(0x9b90842304c938a7, ped, componentIndex, 0, Citizen.ResultAsInteger()) end
local function GetMetaPedAssetTint(ped, index) return Citizen.InvokeNative(0xE7998FEC53A33BBE, ped, index, Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt()) end
local function GetNumComponentsInPed(ped) return Citizen.InvokeNative(0x90403E8107B60E81, ped) end
local function GetMetaPedType(ped) return Citizen.InvokeNative(0xEC9A1261BF0CE510, ped) end
local function GetShopItemComponentCategory(...) return Citizen.InvokeNative(0x5FF9A878C3D115B8,...) end

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

---@param ped integer the entity ID
---@param category integer the category hash
local function ResetCachedColor(ped,category)
	cachedPedColor[ped].comps[category] = nil
end

---@param ped integer the entity ID
---@param category integer the category hash
---@param palette integer the palette hash
---@param tint0 integer
---@param tint1 integer
---@param tint2 integer
local function AddCachedColor(ped,category,palette,tint0,tint1,tint2)
  if not cachedPedColor[ped] then cachedPedColor[ped] = { comps = {} } end
  cachedPedColor[ped].comps[category] = {
    category = category,
    palette = palette,
    tint0 = tint0,
    tint1 = tint1,
    tint2 = tint2
  }
end

---@param ped integer the entity ID
local function PutInCacheCurrentColor(ped)
  if cachedPedColor[ped] then return end
	local numComponent = GetNumComponentsInPed(ped)
	if not numComponent then return end -- No component detected on the ped
	for index = 0, numComponent-1 do
		--Get current clothes
		local palette,tint0,tint1,tint2 = GetMetaPedAssetTint(ped,index)
		local category = GetCategoryOfComponentAtIndex(ped,index)
		AddCachedColor(ped,category,palette,tint0,tint1,tint2)
	end
end

---@param ped integer the entity ID
local function ReapplyCustomColor(ped)
	if not cachedPedColor[ped] then return end
  if currentTimeout then
    currentTimeout:clear()
  end
  currentTimeout = jo.timeout:set(50, function()
		for _,data in pairs (cachedPedColor[ped].comps or {}) do
			SetTextureOutfitTints(ped,data.category,data.palette,data.tint0,data.tint1,data.tint2)
		end
		cachedPedColor[ped] = nil
		N_0xAAB86462966168CE(ped)
 		UpdatePedVariation(ped)
	end)
end

---@param ped integer the entity ID of the ped
---@param hash integer the hash of the clothes
---@return integer categoryHash
---@return boolean isMp
function jo.clothes.getComponentCategory(ped,hash)
  local isMp = true
  local categoryHash = GetShopItemComponentCategory(hash,GetMetaPedType(ped), true)
  if not categoryHash then
    isMp = false
    categoryHash = GetShopItemComponentCategory(hash,GetMetaPedType(ped), false)
  end
  return categoryHash,isMp
end

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

---@param ped integer the entity
---@param category string the clothes category 
---@param data any the clothes data
function jo.clothes.apply(ped,category,data)
	data = formatClothesData(data)


	local categoryHash = GetHashFromString(category)
	local isMp = true

  if data.hash then
    categoryHash,isMp = jo.clothes.getComponentCategory(ped,data.hash)
	end

	PutInCacheCurrentColor(ped)

  --remove the current clothes for this category
  RemoveTagFromMetaPed(ped, categoryHash, 0)
  ResetCachedColor(ped,categoryHash)

  if data.hash then
		if category == "coats" then RemoveTagFromMetaPed(ped, 'coats_closed', 0);
		elseif category == "coats_closed" then RemoveTagFromMetaPed(ped, 'coats', 0);
		elseif category == "skirts" then RemoveTagFromMetaPed(ped, 'pants', 0);
		end
		if category == "masks" or (data.drawable) then
			local drawable, albedo, normal, material,palette, tint0, tint1, tint2 = 0,0,0,0,0,0,0,0
			if data.hash then
				drawable, albedo, normal, material,palette, tint0, tint1, tint2 = GetShopItemBaseLayers(data.hash,GetMetaPedType(ped),isMp)
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
      ApplyShopItemToPed(ped,data.hash, true, isMp, false)
      if data.palette and data.palette ~= 0 then
        AddCachedColor(ped,categoryHash, GetHashFromString(data.palette),data.tint0,data.tint1,data.tint2)
      end
    end
	end
	RefreshPed(ped)
	ReapplyCustomColor(ped)
end

---@param ped integer the entity
---@param category string the clothes category 
function jo.clothes.remove(ped,category)
  return jo.clothes.apply(ped,category,0)
end

return jo.clothes