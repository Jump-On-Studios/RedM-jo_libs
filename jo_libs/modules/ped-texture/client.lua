jo.pedTexture = {}

if not IsModuleLoaded('utils') then
  jo.require('utils')
end
if not IsModuleLoaded('table') then
  jo.require('table')
end
if not IsModuleLoaded('timeout') then
  jo.require('timeout')
end

local pedsTextures = {}

local function AddTextureLayer(...) return Citizen.InvokeNative(0x86BB5FF45F193A02,...) end
local function ApplyTextureOnPed(...) return Citizen.InvokeNative(0x0B46E25761519058,...) end
local function ClearPedTexture(...) return Citizen.InvokeNative(0xB63B9178D0F58D82,...) end
local function GetCategoryOfComponentAtIndex(ped, componentIndex) return Citizen.InvokeNative(0x9b90842304c938a7, ped, componentIndex, 0, Citizen.ResultAsInteger()) end
local function GetMetaPedAssetGuids(ped, index) return Citizen.InvokeNative(0xA9C28516A6DC9D56, ped, index, Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt(), Citizen.PointerValueInt()) end
local function GetNumComponentsInPed(ped) return Citizen.InvokeNative(0x90403E8107B60E81, ped) end
local function IsTextureValid(...) return Citizen.InvokeNative(0x31DC8D3F216D8509,...) end
local function ReleaseTexture(...) return Citizen.InvokeNative(0x6BEFAA907B076859,...) end
local function RequestTexture(...) return Citizen.InvokeNative(0xC5E7204F322E49EB,...) end
local function SetTextureLayerAlpha(...) return Citizen.InvokeNative(0x6C76BC24F8BB709A,...) end
local function SetTextureLayerPallete(...) return Citizen.InvokeNative(0x1ED8588524AC9BE1,...) end
local function SetTextureLayerSheetGridIndex(...) return Citizen.InvokeNative(0x3329AAE2882FC8E4,...) end
local function SetTextureLayerTint(...) return Citizen.InvokeNative(0x2DF59FFE6FFD6044,...) end
local function UpdatePedTexture(...) return Citizen.InvokeNative(0x92DAABA2C1C10B0E,...) end
local function N_0x704C908E9C405136(...) return Citizen.InvokeNative(0x704C908E9C405136,...) end
local function UpdatePedVariation(ped) return Citizen.InvokeNative(0xCC8CA3E88256E58F,ped, false, true, true, true, false) end
local function _updatePedVariation(ped)
  N_0x704C908E9C405136(ped)
  return UpdatePedVariation(ped)
end

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
  acne = {
    {label="none", value=false},
    {label="rugged", value={id=0}},
  },
  ageing = {
    {label="ageing_var0",value={id=0}},
    {label="ageing_var1",value={id=1}},
    {label="ageing_var2",value={id=2}},
    {label="ageing_var3",value={id=3}},
    {label="ageing_var4",value={id=4}},
    {label="ageing_var5",value={id=5}},
    {label="ageing_var6",value={id=6}},
    {label="ageing_var7",value={id=7}},
    {label="ageing_var8",value={id=8}},
    {label="ageing_var9",value={id=9}},
    {label="ageing_var10",value={id=10}},
    {label="ageing_var11",value={id=11}},
    {label="ageing_var12",value={id=12}},
    {label="ageing_var13",value={id=13}},
    {label="ageing_var14",value={id=14}},
    {label="ageing_var15",value={id=15}},
    {label="ageing_var17",value={id=17}},
    {label="ageing_var18",value={id=18}},
    {label="ageing_var19",value={id=19}},
    {label="ageing_var20",value={id=20}},
    {label="ageing_var21",value={id=21}},
    {label="ageing_var22",value={id=22}},
    {label="ageing_var23",value={id=23}},
  },
  beard = {
    {label="1", value={id=0}}
  },
  blush = {
    {label="none", value = false},
    {label="flushed",value={id=0}},
    {label="rosy",value={id=1}},
    {label="highbrow",value={id=2}},
    {label="contoured",value={id=3}},
  },
  complex = {
    {label = "none", value = false},
    {label="exhausted",value={id=0}},
    {label="ruddy",value={id=1}},
    {label="chapped",value={id=2}},
    {label="stippled",value={id=3}},
    {label="flushed",value={id=4}},
    {label="healthyGlow",value={id=5}},
    {label="alcoholic",value={id=6}},
    {label="windWhipped",value={id=7}},
    {label="reddening",value={id=8}},
    {label="toughened",value={id=9}},
    {label="sunBurnt",value={id=10}},
    {label="weathered",value={id=11}},
    {label="fatigued",value={id=12}},
    {label="damaged",value={id=13}},
  },
  disc = {
    {label = "none", value = false},
    {label="rugged",value={id=0}},
    {label="dappled",value={id=1}},
    {label="speckled",value={id=2}},
    {label="styppled",value={id=3}},
    {label="constant",value={id=4}},
    {label="uneven",value={id=5}},
    {label="spotted",value={id=6}},
    {label="minor",value={id=7}},
    {label="hearty",value={id=8}},
    {label="blotched",value={id=9}},
    {label="flecked",value={id=10}},
    {label="random",value={id=11}},
    {label="motley",value={id=12}},
    {label="spread",value={id=13}},
    {label="coarse",value={id=14}},
    {label="patchy",value={id=15}},
  },
  eyebrow = {
    {label = "none", value=false},
    {label = "full", value={id=0, sexe="m"}},
    {label = "short", value={id=1, sexe="m"}},
    {label = "blunt", value={id=2, sexe="m"}},
    {label = "fluffy", value={id=3, sexe="m"}},
    {label = "slight", value={id=4, sexe="m"}},
    {label = "natural", value={id=5, sexe="m"}},
    {label = "thin", value={id=6, sexe="m"}},
    {label = "blushy", value={id=7, sexe="m"}},
    {label = "low", value={id=8, sexe="m"}},
    {label = "plucked", value={id=9, sexe="m"}},
    {label = "arched", value={id=10, sexe="m"}},
    {label = "neat", value={id=11, sexe="m"}},
    {label = "sharp", value={id=12, sexe="m"}},
    {label = "pointed", value={id=13, sexe="m"}},
    {label = "trimmed", value={id=14, sexe="m"}},
    {label = "thick", value={id=15, sexe="m"}},
    {label = "plucked", value={id=0, sexe="f"}},
    {label = "full", value={id=1, sexe="f"}},
    {label = "trimmed", value={id=2, sexe="f"}},
    {label = "shaped", value={id=3, sexe="f"}},
    {label = "thick", value={id=4, sexe="f"}},
    {label = "fluffy", value={id=5, sexe="f"}},
    {label = "natural", value={id=6, sexe="f"}},
    {label = "heavy", value={id=7, sexe="f"}},
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
  freckles = {
    {label = "none", value = false},
    {label="sunned",value={id=0}},
    {label="cheeky",value={id=1}},
    {label="random",value={id=2}},
    {label="few",value={id=3}},
    {label="several",value={id=4}},
    {label="covered",value={id=5}},
    {label="faded",value={id=6}},
    {label="scattered",value={id=7}},
    {label="lighted",value={id=8}},
    {label="visually",value={id=9}},
    {label="dotted",value={id=10}},
    {label="pinpricked",value={id=11}},
    {label="nosy",value={id=12}},
    {label="cheeked",value={id=13}},
    {label="bigCheeked",value={id=14}},
  },
  grime = {
    {label = "none", value = false},
    {label="0",value={id=0}},
    {label="1",value={id=1}},
    {label="2",value={id=2}},
    {label="3",value={id=3}},
    {label="4",value={id=4}},
    {label="5",value={id=5}},
    {label="6",value={id=6}},
    {label="7",value={id=7}},
    {label="8",value={id=8}},
    {label="9",value={id=9}},
    {label="10",value={id=10}},
    {label="11",value={id=11}},
    {label="12",value={id=12}},
    {label="13",value={id=13}},
    {label="14",value={id=14}},
    {label="15",value={id=15}},
  },
  hair = {
    mp_male = {
      {label="1", value = {id=0}},
      -- {label="2", value = {id=2}},
      {label="9", value = {id=9}},
    },
    mp_female = {},
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
  moles = {
    {label = "none", value = false},
    {label="odd",value={id=0}},
    {label="flicked",value={id=1}},
    {label="varied",value={id=2}},
    {label="bunch",value={id=3}},
    {label="scarce",value={id=4}},
    {label="speckled",value={id=5}},
    {label="peppered",value={id=6}},
    {label="pronounced",value={id=7}},
    {label="dotted",value={id=8}},
    {label="dwindling",value={id=9}},
    {label="cast",value={id=10}},
    {label="strewn",value={id=11}},
    {label="set",value={id=12}},
    {label="speckled",value={id=13}},
    {label="group",value={id=14}},
    {label="sparse",value={id=15}},
  },
  scar = {
    {label = "none", value = false},
    {label="slashed",value={id=0}},
    {label="clawed",value={id=1}},
    {label="split",value={id=2}},
    {label="torn",value={id=3}},
    {label="struck",value={id=4}},
    {label="sliced",value={id=5}},
    {label="hacked",value={id=6}},
    {label="cracked",value={id=7}},
    {label="smashed",value={id=8}},
    {label="patched",value={id=9}},
    {label="scraped",value={id=10}},
    {label="broken",value={id=11}},
    {label="marred",value={id=12}},
    {label="raised",value={id=13}},
    {label="blemished",value={id=14}},
    {label="scalped",value={id=15}},
  },
  spots = {
    {label = "none", value = false},
    {label="0",value={id=0}},
    {label="1",value={id=1}},
    {label="2",value={id=2}},
    {label="3",value={id=3}},
    {label="4",value={id=4}},
    {label="5",value={id=5}},
    {label="6",value={id=6}},
    {label="7",value={id=7}},
    {label="8",value={id=8}},
    {label="9",value={id=9}},
    {label="10",value={id=10}},
    {label="11",value={id=11}},
    {label="12",value={id=12}},
    {label="13",value={id=13}},
    {label="14",value={id=14}},
    {label="15",value={id=15}},
  }
}

jo.pedTexture.categories = {
  acne='heads',
  ageing = "heads",
  blush = "heads",
  complex = "heads",
  disc = "heads",
  eyebrow = "heads",
  eyeliner = "heads",
  eyeshadow = "heads",
  foundation = "heads",
  freckles = "heads",
  grime = "heads",
  lipstick = "heads",
  moles = "heads",
  scar = "heads",
  spots = "heads",
  masks = "heads",
  hair = "heads",
  beard = "heads"
}

---@param isMale boolean
---@param category string
---@param data table
function jo.pedTexture.getOverlayAssetFromId(isMale,category,data)
  if type(data) == "number" then
    data = {id = data}
  end
  if data.albedo then
    return data.albedo
  end
  if category == "eyebrow" then
    local sex = data.sexe or (isMale and 'm' or 'f')
    return ('mp_u_faov_%s_%s_%03d'):format(category,sex,data.id)
  elseif category == "hair" then
    if type(data.id) == "number" then
      return ('mp_u_faov_m_hair_%03d'):format(data.id)
    else
      return ('mp_u_faov_m_hair_%s'):format(data.id)
    end
  end
  return ('mp_u_faov_%s_%03d'):format(category,data.id)
end

---@param ped integer
---@param layerName string
---@param data table
function jo.pedTexture.apply(ped,layerName,data)
  if not NetworkGetEntityIsNetworked(ped) then
    return eprint("ERROR: RedM doesn't allow editing of texture on a local entity")
  end
  local data = table.copy(data or {})
  local index, albedo, normal, material, layerIndex, textureId,palette
  local category = jo.pedTexture.categories[layerName]
  if not category then
    return print('No texture category for layer: '..layerName)
  end
  pedsTextures[ped] = pedsTextures[ped] or Entity(ped).state['jo_pedTexture'] or {}
  pedsTextures[ped][category] = pedsTextures[ped][category] or {layers = {}}


  if data.id then
    data.albedo = jo.pedTexture.getOverlayAssetFromId(IsPedMale(ped),layerName, data)
    data.id = nil
  end

  if not data.albedo then
    pedsTextures[ped][category].layers[layerName] = nil
  else
    if not data.palette and category == "heads" then
      data.palette = "metaped_tint_makeup"
    end
    data.normal = data.albedo.."_nm"
    data.material = data.albedo.."_ab"
    pedsTextures[ped][category].layers[layerName] = data
  end

  jo.timeout.delay('updatePedTexture',200, function()
    if pedsTextures[ped][category].textureId ~= nil then
      ClearPedTexture(pedsTextures[ped][category].textureId)
    end
    index = GetComponentIndexByCategory(ped,category)
    _, albedo, normal, material = GetMetaPedAssetGuids(ped, index)
    if albedo == 0 then
      return
    end
    textureId = RequestTexture(albedo, normal, material)
    if (textureId == -1) then
      return print('IMPOSSIBLE TO APPLY THE TEXTURES')
    end
    pedsTextures[ped][category].textureId = textureId

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
      layerIndex = AddTextureLayer(textureId, albedo, normal, material, layer.blendType or blendType, (layer.opacity or 1.0)*1.0, layer.sheetGrid or 0)
      if blendType == 0 and layer.palette then
        palette = GetHashFromString(layer.palette)
        SetTextureLayerPallete(textureId, layerIndex, palette)
        SetTextureLayerTint(textureId, layerIndex, layer.tint0 or 0, layer.tint1 or 0, layer.tint2 or 0)
      end
      SetTextureLayerSheetGridIndex(textureId, layerIndex, layer.sheetGrid or 0)
      SetTextureLayerAlpha(textureId, layerIndex, (layer.opacity or 1.0)*1.0)
    end
    jo.utils.waiter(function() return not IsTextureValid(textureId) end)

    if IsTextureValid(textureId) then
      ApplyTextureOnPed(ped, GetHashFromString(category), textureId)
      UpdatePedTexture(textureId)
      _updatePedVariation(ped)
      Entity(ped).state:set('jo_pedTexture',pedsTextures[ped])
      CreateThread(function()
        local textureId = textureId
        jo.utils.waiter(function() return IsPedReadyToRender(ped) end)
        ReleaseTexture(textureId)
      end)
    else
      ReleaseTexture(textureId)
    end
  end)
end

---@param ped integer
---@param category string
---@param layerName string
function jo.pedTexture.remove(ped,layerName)
  jo.pedTexture.apply(ped,layerName,{})
end

---@param ped integer
function jo.pedTexture.refreshAll(ped)
  pedsTextures[ped] = pedsTextures[ped] or Entity(ped).state['jo_pedTexture'] or {}
  if table.count(pedsTextures[ped]) == 0 then return end

  for _,data in pairs (pedsTextures[ped]) do
    for layername,layer in pairs (data.layers) do
      jo.pedTexture.apply(ped,layername,layer)
    end
  end
end

function jo.pedTexture.overwriteCategory(ped,category,overlays)
  pedsTextures[ped] = pedsTextures[ped] or Entity(ped).state['jo_pedTexture'] or {}
  if pedsTextures[ped][category] then
    pedsTextures[ped][category].layers = {}
    for layername,cat in pairs (jo.pedTexture.categories) do
      if cat == category then
        jo.pedTexture.remove(ped,layername)
        break
      end
    end
  end

  for layername,layer in pairs (overlays) do
    jo.pedTexture.apply(ped,layername,layer)
  end
end

function jo.pedTexture.getAll(ped)
  local layers = {}
  pedsTextures[ped] = pedsTextures[ped] or Entity(ped).state['jo_pedTexture'] or {}
  for _,data in pairs (pedsTextures[ped]) do
    for layername,layer in pairs (data.layers) do
      layers[layername] = layer
    end
  end
  return layers
end

-- Entity(PlayerPedId()).state:set('jo_pedTexture',nil)

return jo.pedTexture


