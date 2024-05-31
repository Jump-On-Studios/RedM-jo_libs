jo.pedTexture = {}

if not IsModuleLoaded('utils') then
  jo.require('utils')
end
if not IsModuleLoaded('table') then
  jo.require('table')
end

local pedsTextures = {}

AddEventHandler('onResourceStop', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then return end
  for ped,textures in pairs (pedsTextures) do
		for category,data in pairs (textures) do
      ReleaseTexture(data.textureId)
    end
	end
end)

local function ClearTextures()
  for ped,textures in pairs (pedsTextures) do
    if not DoesEntityExist(ped) then
      for _,data in pairs (textures) do
        ReleaseTexture(data.textureId)
      end
      pedsTextures[ped] = nil
    end
	end
  SetTimeout(10000,ClearTextures)
end
SetTimeout(10000,ClearTextures)


local function GetNumComponentsInPed(ped) return Citizen.InvokeNative(0x90403E8107B60E81, ped) end
local function GetCategoryOfComponentAtIndex(ped, componentIndex) return Citizen.InvokeNative(0x9b90842304c938a7, ped, componentIndex, 0, Citizen.ResultAsInteger()) end
local function GetMetaPedAssetGuids(ped, index) return Citizen.InvokeNative(0xA9C28516A6DC9D56, ped, index, Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt()) end
local function RequestTexture(...) return Citizen.InvokeNative(0xC5E7204F322E49EB,...) end

local function GetComponentIndexByCategory(ped, category)
	category = GetHashFromString(category)
	local numComponents = GetNumComponentsInPed(ped)
  if not numComponents then return false end
	for i=0, numComponents-1, 1 do
    local componentCategory = GetCategoryOfComponentAtIndex(ped, i)
    if componentCategory == category then
      return i
    end
	end
	return false
end

---@param isMale boolean
---@param category string
---@param id integer
function jo.pedTexture.getOverlayAssetFromId(isMale,category,id)
  if category == "eyebrow" then
    local sex = isMale and 'm' or 'f'
    return ('mp_u_faov_%s_%s_%03d'):format(category,sex,id)
  end
  return ('mp_u_faov_%s_%03d'):format(category,id)
end

---@param ped integer
---@param category string
---@param layerName string
---@param data table
function jo.pedTexture.apply(ped,category,layerName,data)
  local index, albedo, normal, material, layerIndex, textureId,palette
  pedsTextures[ped]= pedsTextures[ped] or {}
  pedsTextures[ped][category] = pedsTextures[ped][category] or Entity(ped).state['jo_pedTexture_'..category] or {layers = {}}

  if not data.albedo then
    pedsTextures[ped][category].layers[layerName] = nil
    if table.count(pedsTextures[ped][category].layers) == 0 then return end
  end

  if pedsTextures[ped][category].textureId ~= nil then
    ClearPedTexture(pedsTextures[ped][category].textureId)
    textureId = pedsTextures[ped][category].textureId
  else
    index = GetComponentIndexByCategory(ped,category)
    _, albedo, normal, material = GetMetaPedAssetGuids(ped, index)
    if albedo == 0 then
      return
    end
    textureId = RequestTexture(albedo, normal, material)
    pedsTextures[ped][category].textureId = textureId
  end

  pedsTextures[ped][category].layers[layerName] = data

  for name,layer in pairs (pedsTextures[ped][category].layers) do
    albedo = GetHashFromString(layer.albedo)
    normal = GetHashFromString(layer.normal)
    material = GetHashFromString(layer.material)
    local blendType = 0
    if name == "scar"
      or name == "spots"
      or name == "disc"
      or name == "complex"
      or name == "acne"
      or name == "ageing"
      or name == "moles"
      or name == "freckles"
    then
      blendType = 1
    end
    layerIndex = AddTextureLayer(textureId, albedo, normal, material, layer.blendType or blendType, layer.alpha or 1.0, layer.sheetGrid or 0)
    if blendType == 0 and layer.palette ~= nil then
      palette = GetHashFromString(layer.palette)
      SetTextureLayerPallete(textureId, layerIndex, palette)
      SetTextureLayerTint(textureId, layerIndex, layer.tint0 or 0, layer.tint1 or 0, layer.tint2 or 0)
    end
    SetTextureLayerSheetGridIndex(textureId, layerIndex, layer.sheetGrid or 0)
    SetTextureLayerAlpha(textureId, layerIndex, layer.opacity or 1.0)
  end
  jo.utils.waiter(function() return not IsTextureValid(textureId) end)

  if IsTextureValid(textureId) then
    ApplyTextureOnPed(ped, GetHashFromString(category), textureId)
    UpdatePedTexture(textureId)
    UpdatePedVariation(ped)
    Entity(ped).state:set('jo_pedTexture_'..category,pedsTextures[ped][category])
  else
    ReleaseTexture(textureId)
  end
end

function jo.pedTexture.remove(ped,category,layerName)
  jo.pedTexture.apply(ped,category,layerName,{})
end

return jo.pedTexture