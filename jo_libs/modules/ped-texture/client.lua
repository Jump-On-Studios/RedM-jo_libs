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
  for _,textures in pairs (pedsTextures) do
		for _,data in pairs (textures) do
      ReleaseTexture(data.textureId)
    end
	end
end)


local function GetNumComponentsInPed(ped) return Citizen.InvokeNative(0x90403E8107B60E81, ped) end
local function GetCategoryOfComponentAtIndex(ped, componentIndex) return Citizen.InvokeNative(0x9b90842304c938a7, ped, componentIndex, 0, Citizen.ResultAsInteger()) end
local function GetMetaPedAssetGuids(ped, index) return Citizen.InvokeNative(0xA9C28516A6DC9D56, ped, index, Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt()) end
local function RequestTexture(...) return Citizen.InvokeNative(0xC5E7204F322E49EB,...) end

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

jo.pedTexture.variations = {
  blush = {
    {label="none", value = false},
    {label="flushed",value={id=0}},
    {label="rosy",value={id=1}},
    {label="highbrow",value={id=2}},
    {label="contoured",value={id=3}},
  },
  eyebrow = {
    mp_male = {
      {label = "full", value={id=0}},
      {label = "short", value={id=1}},
      {label = "blunt", value={id=2}},
      {label = "fluffy", value={id=3}},
      {label = "slight", value={id=4}},
      {label = "natural", value={id=5}},
      {label = "thin", value={id=6}},
      {label = "blushy", value={id=7}},
      {label = "low", value={id=8}},
      {label = "plucked", value={id=9}},
      {label = "arched", value={id=10}},
      {label = "neat", value={id=11}},
      {label = "sharp", value={id=12}},
      {label = "pointed", value={id=13}},
      {label = "trimmed", value={id=14}},
      {label = "thick", value={id=15}},
    },
    mp_female = {
      {label = "plucked", value={id=0}},
      {label = "full", value={id=1}},
      {label = "trimmed", value={id=2}},
      {label = "shaped", value={id=3}},
      {label = "thick", value={id=4}},
      {label = "fluffy", value={id=5}},
      {label = "natural", value={id=6}},
      {label = "heavy", value={id=7}},
    }
  },
  eyeliner = {
    {label="none",value=false},
    {label="simple",value={id=0,sheetGrid = 0}},
    {label="winged",value={id=0,sheetGrid = 1}},
    {label="long",value={id=0,sheetGrid = 2}},
    {label="underlined",value={id=0,sheetGrid = 3}},
    {label="hooked",value={id=0,sheetGrid = 4}},
    {label="curved",value={id=0,sheetGrid = 5}},
    {label="drama",value={id=0,sheetGrid = 6}},
    {label="indian",value={id=0,sheetGrid = 7}},
    {label="indianBold",value={id=0,sheetGrid = 13}},
    {label="indianFull",value={id=0,sheetGrid = 15}},
    {label="pinup",value={id=0,sheetGrid = 8}},
    {label="pinupBold",value={id=0,sheetGrid = 14}},
    {label="full",value={id=0,sheetGrid = 9}},
    {label="double",value={id=0,sheetGrid = 10}},
    {label="doubleTop",value={id=0,sheetGrid = 11}},
    {label="egyptian",value={id=0,sheetGrid = 12}},
  },
  eyeshadow = {
    {label="none",value=false},
    {label="smokyEye",value={id=0,sheetGrid = 0}},
    {label="neatArc",value={id=0,sheetGrid = 1}},
    {label="heavyWing",value={id=0,sheetGrid = 2}},
    {label="blendedFlick",value={id=0,sheetGrid = 3}},
    {label="twotoneWing",value={id=0,sheetGrid = 4}},
    {label="highlighted",value={id=0,sheetGrid = 5}},
  },
  foundation = {
    {label="none",value=false},
    {label="facePowder",value={id=0}}
  },
  lipstick = {
    {label="none", value = false},
    {label="matte",value={id=0,sheetGrid = 0}},
    {label="lined",value={id=0,sheetGrid = 1}},
    {label="shadow",value={id=0,sheetGrid = 2}},
    {label="smudged",value={id=0,sheetGrid = 3}},
    {label="square",value={id=0,sheetGrid = 4}},
    {label="heart",value={id=0,sheetGrid = 5}},
    {label="border",value={id=0,sheetGrid = 7}},
  },
  scars = {
    {label = "none", value = false},
      {label="0",value=0},
      {label="1",value=1},
      {label="2",value=2},
      {label="3",value=3},
      {label="4",value=4},
      {label="5",value=5},
      {label="6",value=6},
      {label="7",value=7},
      {label="8",value=8},
      {label="9",value=9},
      {label="10",value=10},
      {label="11",value=11},
      {label="12",value=12},
      {label="13",value=13},
      {label="14",value=14},
      {label="15",value=15},
    },
    ageing = {
      {label="0",value=0},
      {label="1",value=1},
      {label="2",value=2},
      {label="3",value=3},
      {label="4",value=4},
      {label="5",value=5},
      {label="6",value=6},
      {label="7",value=7},
      {label="8",value=8},
      {label="9",value=9},
      {label="10",value=10},
      {label="11",value=11},
      {label="12",value=12},
      {label="13",value=13},
      {label="14",value=14},
      {label="15",value=15},
      {label="16",value=16},
      {label="17",value=17},
      {label="18",value=18},
      {label="19",value=19},
      {label="20",value=20},
      {label="21",value=21},
      {label="22",value=22},
      {label="23",value=23},
    },
    complex = {
      {label="0",value=0},
      {label="1",value=1},
      {label="2",value=2},
      {label="3",value=3},
      {label="4",value=4},
      {label="5",value=5},
      {label="6",value=6},
      {label="7",value=7},
      {label="8",value=8},
      {label="9",value=9},
      {label="10",value=10},
      {label="11",value=11},
      {label="12",value=12},
      {label="13",value=13},
    },
    disc = {
      {label="0",value=0},
      {label="1",value=1},
      {label="2",value=2},
      {label="3",value=3},
      {label="4",value=4},
      {label="5",value=5},
      {label="6",value=6},
      {label="7",value=7},
      {label="8",value=8},
      {label="9",value=9},
      {label="10",value=10},
      {label="11",value=11},
      {label="12",value=12},
      {label="13",value=13},
      {label="14",value=14},
      {label="15",value=15},
    },
    freckles = {
      {label="0",value=0},
      {label="1",value=1},
      {label="2",value=2},
      {label="3",value=3},
      {label="4",value=4},
      {label="5",value=5},
      {label="6",value=6},
      {label="7",value=7},
      {label="8",value=8},
      {label="9",value=9},
      {label="10",value=10},
      {label="11",value=11},
      {label="12",value=12},
      {label="13",value=13},
      {label="14",value=14},
    },
    grime = {
      {label="0",value=0},
      {label="1",value=1},
      {label="2",value=2},
      {label="3",value=3},
      {label="4",value=4},
      {label="5",value=5},
      {label="6",value=6},
      {label="7",value=7},
      {label="8",value=8},
      {label="9",value=9},
      {label="10",value=10},
      {label="11",value=11},
      {label="12",value=12},
      {label="13",value=13},
      {label="14",value=14},
      {label="15",value=15},
    },
    moles = {
      {label="0",value=0},
      {label="1",value=1},
      {label="2",value=2},
      {label="3",value=3},
      {label="4",value=4},
      {label="5",value=5},
      {label="6",value=6},
      {label="7",value=7},
      {label="8",value=8},
      {label="9",value=9},
      {label="10",value=10},
      {label="11",value=11},
      {label="12",value=12},
      {label="13",value=13},
      {label="14",value=14},
      {label="15",value=15},
    },
    spots = {
      {label="0",value=0},
      {label="1",value=1},
      {label="2",value=2},
      {label="3",value=3},
      {label="4",value=4},
      {label="5",value=5},
      {label="6",value=6},
      {label="7",value=7},
      {label="8",value=8},
      {label="9",value=9},
      {label="10",value=10},
      {label="11",value=11},
      {label="12",value=12},
      {label="13",value=13},
      {label="14",value=14},
      {label="15",value=15},
    }
}

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
  
  if table.count(pedsTextures[ped][category].layers) == 0 then return end

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