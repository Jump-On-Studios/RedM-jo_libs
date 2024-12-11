jo.require("component")
jo.require("timeout")
jo.require("hook")
jo.require("ped-texture")
jo.require("waiter")

local function waitReady(ped)
  Wait(100)
  local isReady = jo.waiter.exec(function() return IsPedReadyToRender(ped) end)
  if not isReady then return eprint("This ped is not loaded:", ped) end
end

local function applyDefaultBodyParts(ped)
  if IsPedMale(ped) then
    EquipMetaPedOutfitPreset(ped, 4, false)
    jo.component.apply(ped, "bodies_upper", `CLOTHING_ITEM_M_BODIES_UPPER_001_V_001`)
    jo.component.apply(ped, "bodies_lower", `CLOTHING_ITEM_M_BODIES_LOWER_001_V_001`)
    jo.component.apply(ped, "heads", `CLOTHING_ITEM_M_HEAD_001_V_001`)
    jo.component.apply(ped, "eyes", `CLOTHING_ITEM_M_EYES_001_TINT_001`)
    jo.component.apply(ped, "teeth", `CLOTHING_ITEM_M_TEETH_000`)
  else
    EquipMetaPedOutfitPreset(ped, 7, false)
    jo.component.apply(ped, "bodies_upper", `CLOTHING_ITEM_F_BODIES_UPPER_001_V_001`)
    jo.component.apply(ped, "bodies_lower", `CLOTHING_ITEM_F_BODIES_LOWER_001_V_001`)
    jo.component.apply(ped, "heads", `CLOTHING_ITEM_F_HEAD_001_V_001`)
    jo.component.apply(ped, "eyes", `CLOTHING_ITEM_F_EYES_001_TINT_001`)
    jo.component.apply(ped, "teeth", `CLOTHING_ITEM_F_TEETH_000`)
  end
end

local function applyPedTextures(ped, overlays)
  if not ped then return end
  if not overlays then return end

  for category, overlay in pairs(overlays) do
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
  jo.pedTexture.overwriteCategory(ped, "heads", overlays, true)
end

local function applySkin(ped, skin)
  dprint("applySkin", ped, json.encode(skin))
  if not ped then return end
  if not skin then return end

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
        jo.forceUpdateMe()
        ped = PlayerPedId()
        SetModelAsNoLongerNeeded(modelHash)
      end
    end
  end
  dprint("fix issue on body")
  applyDefaultBodyParts(ped)

  jo.component.refreshPed(ped)
  waitReady(ped)

  dprint("start apply default body components")
  jo.component.apply(ped, "heads", skin.headHash)
  jo.component.apply(ped, "body_upper", skin.bodyUpper)
  jo.component.apply(ped, "body_lower", skin.bodyLower)
  dprint("apply outfit")
  if skin.bodyBuild then
    EquipMetaPedOutfit(ped, skin.bodyBuild)
  end

  jo.component.refreshPed(ped)
  waitReady(ped)

  jo.component.apply(ped, "eyes", skin.eyes)
  jo.component.apply(ped, "teeth", skin.teeth)
  jo.component.apply(ped, "hair", skin.hair)
  if skin.model == "mp_male" then
    jo.component.apply(ped, "beards_complete", skin.beards_complete)
  end

  dprint("apply expression")
  for expression, value in pairs(skin.expressions) do
    SetCharExpression(ped, jo.component.data.expressions[expression], (value or 0.0) * 1.0)
  end

  jo.component.refreshPed(ped)
  dprint("wait refresh")
  waitReady(ped)

  applyPedTextures(ped, skin?.overlays)

  Wait(100)

  SetPedScale(ped, skin.bodyScale)
  dprint("done create ped")

  waitReady(ped)
end

local function applyClothes(ped, clothes)
  if not ped then return end
  if not clothes then return end

  jo.component.removeAllClothes(ped)

  for category, data in pairs(clothes) do
    jo.component.apply(ped, category, data)
  end
end

RegisterNetEvent("jo_libs:client:applySkinAndClothes", function(ped, skin, clothes)
  ped = ped or PlayerPedId()
  jo.timeout.delay("jo_libs:client:applySkinAndClothes:" .. ped, 100, function()
    jo.hook.doActions("jo_libs:applySkinAndClothes:before", ped, skin, clothes)

    applySkin(ped, skin)
    applyClothes(ped, clothes)

    jo.component.refreshPed(ped)

    jo.hook.doActions("jo_libs:applySkinAndClothes:after", ped, skin, clothes)
  end)
end)

RegisterNetEvent("jo_libs:client:applySkin", function(ped, skin)
  ped = ped or PlayerPedId()
  jo.timeout.delay("jo_libs:client:applySkin:" .. ped, 100, function()
    jo.hook.doActions("jo_libs:applySkin:before", ped, skin)

    applySkin(ped, skin)

    jo.hook.doActions("jo_libs:applySkinAndClothes:after", ped, skin)
  end)
end)

RegisterNetEvent("jo_libs:client:applyClothes", function(ped, clothes)
  ped = ped or PlayerPedId()
  jo.timeout.delay("jo_libs:client:applyClothes:" .. ped, 100, function()
    jo.hook.doActions("jo_libs:applyClothes:before", ped, clothes)

    applyClothes(ped, clothes)

    jo.hook.doActions("jo_libs:applyClothes:after", ped, clothes)
  end)
end)
