-------------
-- FRAMEWORK CLASS
-------------
local Inventory = exports.vorp_inventory
local Core = exports.vorp_core:GetCore()

local FrameworkClass = {
  core = Core,
  inv = Inventory
}

-------------
-- VARIABLES
-------------

local inventoriesCreated = {}

-------------
-- INVENTORY
-------------

function FrameworkClass:canUseItem(source, item, amount, meta, remove)
  local count = Inventory:getItemCount(source, nil, item, meta)
  if count >= amount then
    if remove then
      Inventory:subItem(source, item, amount, meta)
    end
    return true
  end
  return false
end

function FrameworkClass:registerUseItem(item, closeAfterUsed, callback)
  CreateThread(function()
    if (closeAfterUsed == nil) then closeAfterUsed = true end
    local isExist = Inventory:getItemDB(item)
    local count = 0
    while not isExist and count < 10 do
      isExist = Inventory:getItemDB(item)
      count = count + 1
      Wait(1000)
    end
    if not isExist then
      return eprint(item .. " < item does not exist in the database")
    end
    Inventory:registerUsableItem(item, function(data)
      if closeAfterUsed then
        Inventory:closeInventory(data.source)
      end
      return callback(data.source, { metadata = data.item.metadata })
    end)
  end)
end

function FrameworkClass:giveItem(source, item, quantity, meta)
  if Inventory:canCarryItem(source, item, quantity) then
    return Inventory:addItem(source, item, quantity, meta)
  end
  return false
end

function FrameworkClass:createInventory(id, name, invConfig)
  inventoriesCreated[id] = {
    id = id,
    name = name,
    config = invConfig,
    inventory = {}
  }

  inventoriesCreated[id].inventory = Inventory:registerInventory({
    id = id,
    name = name,
    limit = invConfig.maxSlots,
    acceptWeapons = GetValue(invConfig.acceptWeapons, false),
    shared = GetValue(invConfig.shared, true),
    ignoreItemStackLimit = GetValue(invConfig.ignoreStackLimit, true),
    whitelistItems = invConfig.whitelist and true or false,
  })
  for _, data in pairs(invConfig.whitelist or {}) do
    Inventory:setCustomInventoryItemLimit(id, data.item, data.limit)
  end
  return inventoriesCreated[id].inventory
end

function FrameworkClass:removeInventory(id)
  Inventory:removeInventory(id)
end

function FrameworkClass:openInventory(source, id)
  if not Inventory:isCustomInventoryRegistered(id) then
    return false, eprint(("This custom inventory doesn't exist: %s. You can create it with `jo.framework.createInventory()`."):format(tostring(id)))
  end
  return Inventory:openInventory(source, id)
end

function FrameworkClass:addItemInInventory(source, id, item, quantity, metadata)
  local user = self.UserClass:get(source)
  local charIdentifier = user.data.charIdentifier

  local items = {
    {
      name = item,
      amount = quantity,
      metadata = metadata
    }
  }

  return Inventory:addItemsToCustomInventory(id, items, charIdentifier)
end

function FrameworkClass:getItemsFromInventory(invId)
  local invItems = Inventory:getCustomInventoryItems(invId)

  local items = {}
  for i = 1, #invItems do
    items[i] = {
      id = invItems[i].id,
      amount = invItems[i].amount,
      item = invItems[i].item,
      metadata = invItems[i].metadata
    }
  end
  return items
end

-------------
-- SKIN & CLOTHES
-------------

function FrameworkClass:standardizeSkinInternal(skin)
  local standard = {}

  local function decrease(value)
    return GetValue(value, 1) - 1
  end

  standard.model = table.extract(skin, "sex")
  standard.headHash = table.extract(skin, "HeadType")
  standard.bodyUpperHash = skin.BodyType ~= 0 and skin.BodyType or skin.Torso
  skin.BodyType = nil
  skin.Torso = nil
  standard.bodyLowerHash = skin.LegsType ~= 0 and skin.LegsType or skin.Legs
  skin.LegsType = nil
  skin.Legs = nil
  standard.eyesHash = table.extract(skin, "Eyes")
  standard.teethHash = table.extract(skin, "Teeth")
  standard.hair = table.extract(skin, "Hair")
  standard.beards_complete = table.extract(skin, "Beard")
  standard.bodyType = table.extract(skin, "Body")
  standard.bodyWeight = table.extract(skin, "Waist")
  standard.bodyScale = table.extract(skin, "Scale")

  standard.expressions = {
    arms = table.extract(skin, "ArmsS"),
    calves = table.extract(skin, "CalvesS"),
    cheekbonesDepth = table.extract(skin, "CheekBonesD"),
    cheekbonesHeight = table.extract(skin, "CheekBonesH"),
    cheekbonesWidth = table.extract(skin, "CheekBonesW"),
    chest = table.extract(skin, "ChestS"),
    chinDepth = table.extract(skin, "ChinD"),
    chinHeight = table.extract(skin, "ChinH"),
    chinWidth = table.extract(skin, "ChinW"),
    earlobes = table.extract(skin, "EarsD"),
    earsAngle = table.extract(skin, "EarsA"),
    earsDepth = table.extract(skin, "earsDepth"),
    earsHeight = table.extract(skin, "EarsH"),
    earsWidth = table.extract(skin, "EarsW"),
    eyebrowDepth = table.extract(skin, "EyeBrowD"),
    eyebrowHeight = table.extract(skin, "EyeBrowH"),
    eyebrowWidth = table.extract(skin, "EyeBrowW"),
    eyelidHeight = table.extract(skin, "EyeLidH"),
    eyelidLeft = table.extract(skin, "EyeLidL"),
    eyelidRight = table.extract(skin, "EyeLidR"),
    eyelidWidth = table.extract(skin, "EyeLidW"),
    eyesAngle = table.extract(skin, "EyeAng"),
    eyesDepth = table.extract(skin, "EyeD"),
    eyesDistance = table.extract(skin, "EyeDis"),
    eyesHeight = table.extract(skin, "EyeH"),
    faceWidth = table.extract(skin, "FaceW"),
    headWidth = table.extract(skin, "HeadSize"),
    hip = table.extract(skin, "HipsS"),
    jawDepth = table.extract(skin, "JawD"),
    jawHeight = table.extract(skin, "JawH"),
    jawWidth = table.extract(skin, "JawW"),
    jawY = table.extract(skin, "jawY"),
    lowerLipDepth = table.extract(skin, "LLiphD"),
    lowerLipHeight = table.extract(skin, "LLiphH"),
    lowerLipWidth = table.extract(skin, "LLiphW"),
    mouthConerLeftDepth = table.extract(skin, "MouthCLD"),
    mouthConerLeftHeight = table.extract(skin, "MouthCLH"),
    mouthConerLeftLipsDistance = table.extract(skin, "MouthCLLD"),
    mouthConerLeftWidth = table.extract(skin, "MouthCLW"),
    mouthConerRightDepth = table.extract(skin, "MouthCRD"),
    mouthConerRightHeight = table.extract(skin, "MouthCRH"),
    mouthConerRightLipsDistance = table.extract(skin, "MouthCRLD"),
    mouthConerRightWidth = table.extract(skin, "MouthCRW"),
    mouthDepth = table.extract(skin, "MouthD"),
    mouthWidth = table.extract(skin, "MouthW"),
    mouthX = table.extract(skin, "MouthX"),
    mouthY = table.extract(skin, "MouthY"),
    neckDepth = table.extract(skin, "NeckD"),
    neckWidth = table.extract(skin, "NeckW"),
    noseAngle = table.extract(skin, "NoseAng"),
    noseCurvature = table.extract(skin, "NoseC"),
    noseHeight = table.extract(skin, "NoseH"),
    noseSize = table.extract(skin, "NoseS"),
    noseWidth = table.extract(skin, "NoseW"),
    nostrilsDistance = table.extract(skin, "NoseDis"),
    shoulderBlades = table.extract(skin, "ShouldersM"),
    shoulders = table.extract(skin, "ShouldersS"),
    shoulderThickness = table.extract(skin, "ShouldersT"),
    thighs = table.extract(skin, "LegsS"),
    upperLipDepth = table.extract(skin, "ULiphD"),
    upperLipHeight = table.extract(skin, "ULiphH"),
    upperLipWidth = table.extract(skin, "ULiphW"),
    waist = table.extract(skin, "WaistW"),
  }

  local function needOverlay(value)
    if not value then return nil end
    if value == 0 then return nil end
    return true
  end

  standard.overlays = {}
  standard.overlays.ageing = needOverlay(skin.ageing_visibility) and {
    id = decrease(skin.ageing_tx_id),
    opacity = self:convertToPercent(skin.ageing_opacity)
  }
  skin.ageing_tx_id = nil
  skin.ageing_opacity = nil
  skin.ageing_visibility = nil

  standard.overlays.beard = needOverlay(skin.beardstabble_visibility) and {
    id = 0,
    tint0 = skin.beardstabble_color_primary,
    opacity = self:convertToPercent(skin.beardstabble_opacity)
  }
  skin.beardstabble_color_primary = nil
  skin.beardstabble_opacity = nil
  skin.beardstabble_visibility = nil

  standard.overlays.blush = needOverlay(skin.blush_visibility) and {
    id = decrease(skin.blush_tx_id),
    tint0 = skin.blush_palette_color_primary,
    opacity = self:convertToPercent(skin.blush_opacity)
  }
  skin.blush_tx_id = nil
  skin.blush_palette_color_primary = nil
  skin.blush_opacity = nil
  skin.blush_visibility = nil

  standard.overlays.eyebrow = needOverlay(skin.eyebrows_visibility) and (function()
    local id = decrease(skin.eyebrows_tx_id)
    local sexe = "m"
    if id > 15 then
      id = id - 15
      sexe = "f"
    end
    return {
      id = id,
      sexe = sexe,
      tint0 = skin.eyebrows_color,
      opacity = self:convertToPercent(skin.eyebrows_opacity)
    }
  end)()
  skin.eyebrows_tx_id = nil
  skin.eyebrows_color = nil
  skin.eyebrows_opacity = nil
  skin.eyebrows_visibility = nil

  standard.overlays.eyeliner = needOverlay(skin.eyeliner_visibility) and {
    id = decrease(skin.eyeliner_tx_id),
    sheetGrid = decrease(skin.eyeliner_palette_id),
    tint0 = skin.eyeliner_color_primary,
    opacity = self:convertToPercent(skin.eyeliner_opacity)
  }
  skin.eyeliner_tx_id = nil
  skin.eyeliner_palette_id = nil
  skin.eyeliner_color_primary = nil
  skin.eyeliner_opacity = nil
  skin.eyeliner_visibility = nil

  standard.overlays.eyeshadow = needOverlay(skin.shadows_visibility) and {
    id = 0,
    sheetGrid = decrease(skin.shadows_palette_id),
    tint0 = skin.shadows_palette_color_primary,
    tint1 = skin.shadows_palette_color_secondary,
    tint2 = skin.shadows_palette_color_tertiary,
    opacity = self:convertToPercent(skin.shadows_opacity)
  }
  skin.shadows_palette_id = nil
  skin.shadows_palette_color_primary = nil
  skin.shadows_palette_color_secondary = nil
  skin.shadows_palette_color_tertiary = nil
  skin.shadows_opacity = nil
  skin.shadows_visibility = nil

  standard.overlays.freckles = needOverlay(skin.freckles_visibility) and {
    id = decrease(skin.freckles_tx_id),
    opacity = self:convertToPercent(skin.freckles_opacity)
  }
  skin.freckles_tx_id = nil
  skin.freckles_opacity = nil
  skin.freckles_visibility = nil

  standard.overlays.lipstick = needOverlay(skin.lipsticks_visibility) and {
    id = 0,
    sheetGrid = decrease(skin.lipsticks_palette_id),
    tint0 = skin.lipsticks_palette_color_primary,
    tint1 = skin.lipsticks_palette_color_secondary,
    tint2 = skin.lipsticks_palette_color_tertiary,
    opacity = self:convertToPercent(skin.lipsticks_opacity)
  }
  skin.lipsticks_palette_id = nil
  skin.lipsticks_palette_color_primary = nil
  skin.lipsticks_palette_color_secondary = nil
  skin.lipsticks_palette_color_tertiary = nil
  skin.lipsticks_opacity = nil
  skin.lipsticks_visibility = nil

  standard.overlays.moles = needOverlay(skin.moles_visibility) and {
    id = decrease(skin.moles_tx_id),
    opacity = self:convertToPercent(skin.moles_opacity)
  }
  skin.moles_tx_id = nil
  skin.moles_opacity = nil
  skin.moles_visibility = nil

  standard.overlays.scar = needOverlay(skin.scars_visibility) and {
    id = decrease(skin.scars_tx_id),
    opacity = self:convertToPercent(skin.scars_opacity)
  }
  skin.scars_tx_id = nil
  skin.scars_opacity = nil
  skin.scars_visibility = nil

  standard.overlays.spots = needOverlay(skin.spots_visibility) and {
    id = decrease(skin.spots_tx_id),
    opacity = self:convertToPercent(skin.spots_opacity)
  }
  skin.spots_tx_id = nil
  skin.spots_opacity = nil
  skin.spots_visibility = nil

  standard.overlays.acne = needOverlay(skin.acne_visibility) and {
    id = decrease(skin.acne_tx_id),
    opacity = self:convertToPercent(skin.acne_opacity)
  }
  skin.acne_tx_id = nil
  skin.acne_opacity = nil
  skin.acne_visibility = nil

  standard.overlays.grime = needOverlay(skin.grime_visibility) and {
    id = decrease(skin.grime_tx_id),
    opacity = self:convertToPercent(skin.grime_opacity)
  }
  skin.grime_tx_id = nil
  skin.grime_opacity = nil
  skin.grime_visibility = nil

  standard.overlays.hair = needOverlay(skin.hair_visibility) and {
    id = decrease(skin.hair_tx_id),
    tint0 = skin.hair_color_primary,
    opacity = self:convertToPercent(skin.hair_opacity)
  }
  skin.hair_tx_id = nil
  skin.hair_color_primary = nil
  skin.hair_opacity = nil
  skin.hair_visibility = nil

  standard.overlays.complex = needOverlay(skin.complex_visibility) and {
    id = decrease(skin.complex_tx_id),
    opacity = self:convertToPercent(skin.complex_opacity)
  }
  skin.complex_tx_id = nil
  skin.complex_opacity = nil
  skin.complex_visibility = nil

  standard.overlays.disc = needOverlay(skin.disc_visibility) and {
    id = decrease(skin.disc_tx_id),
    opacity = self:convertToPercent(skin.disc_opacity)
  }
  skin.disc_tx_id = nil
  skin.disc_opacity = nil
  skin.disc_visibility = nil

  standard.overlays.foundation = needOverlay(skin.foundation_visibility) and {
    id = decrease(skin.foundation_tx_id),
    tint0 = skin.foundation_palette_color_primary,
    tint1 = skin.foundation_palette_color_secondary,
    tint2 = skin.foundation_palette_color_tertiary,
    sheetGrid = decrease(skin.foundation_palette_id),
    opacity = self:convertToPercent(skin.foundation_opacity)
  }
  skin.foundation_tx_id = nil
  skin.foundation_palette_color_primary = nil
  skin.foundation_palette_color_secondary = nil
  skin.foundation_palette_color_tertiary = nil
  skin.foundation_palette_id = nil
  skin.foundation_opacity = nil
  skin.foundation_visibility = nil

  standard.overlays.masks = needOverlay(skin.paintedmasks_visibility) and {
    id = decrease(skin.paintedmasks_tx_id),
    tint0 = skin.paintedmasks_palette_color_primary,
    tint1 = skin.paintedmasks_palette_color_secondary,
    tint2 = skin.paintedmasks_palette_color_tertiary,
    sheetGrid = decrease(skin.paintedmasks_palette_id),
    opacity = self:convertToPercent(skin.paintedmasks_opacity)
  }
  skin.paintedmasks_tx_id = nil
  skin.paintedmasks_palette_color_primary = nil
  skin.paintedmasks_palette_color_secondary = nil
  skin.paintedmasks_palette_color_tertiary = nil
  skin.paintedmasks_palette_id = nil
  skin.paintedmasks_opacity = nil
  skin.paintedmasks_visibility = nil

  --Clear unneccessary keys
  table.extract(skin, "FaceD")              --Same hash than EyeBrowW
  table.extract(skin, "FaceS")              --Same hash than EyeBrowH
  table.extract(skin, "albedo")             --Useless
  table.extract(skin, "beardstabble_tx_id") --Unused by VORP
  table.extract(skin, "blush_palette_id")   --Unused by VORP
  table.extract(skin, "shadows_tx_id")      --Unused by VORP
  table.extract(skin, "lipsticks_tx_id")    --Unused by VORP

  return standard
end

function FrameworkClass:revertSkinInternal(standard)
  local reverted = {}

  local function increase(value)
    return GetValue(value, 0) + 1
  end

  reverted.sex = table.extract(standard, "model")
  reverted.HeadType = table.extract(standard, "headHash")
  reverted.Torso = standard.bodyUpperHash
  reverted.BodyType = standard.bodyUpperHash
  standard.bodyUpperHash = nil
  reverted.Legs = standard.bodyLowerHash
  reverted.LegsType = standard.bodyLowerHash
  standard.bodyLowerHash = nil
  reverted.Eyes = table.extract(standard, "eyesHash")
  reverted.Teeth = table.extract(standard, "teethHash")
  reverted.Hair = self:extractComponentHashIfAlone(table.extract(standard, "hair"))
  reverted.Beard = self:extractComponentHashIfAlone(table.extract(standard, "beards_complete"))
  reverted.Body = table.extract(standard, "bodyType")
  reverted.Waist = table.extract(standard, "bodyWeight")
  reverted.Scale = table.extract(standard, "bodyScale")

  reverted.ArmsS = table.extract(standard.expressions, "arms")
  reverted.CalvesS = table.extract(standard.expressions, "calves")
  reverted.CheekBonesD = table.extract(standard.expressions, "cheekbonesDepth")
  reverted.CheekBonesH = table.extract(standard.expressions, "cheekbonesHeight")
  reverted.CheekBonesW = table.extract(standard.expressions, "cheekbonesWidth")
  reverted.ChestS = table.extract(standard.expressions, "chest")
  reverted.ChinD = table.extract(standard.expressions, "chinDepth")
  reverted.ChinH = table.extract(standard.expressions, "chinHeight")
  reverted.ChinW = table.extract(standard.expressions, "chinWidth")
  reverted.EarsD = table.extract(standard.expressions, "earlobes")
  reverted.EarsA = table.extract(standard.expressions, "earsAngle")
  reverted.earsDepth = table.extract(standard.expressions, "earsDepth")
  reverted.EarsH = table.extract(standard.expressions, "earsHeight")
  reverted.EarsW = table.extract(standard.expressions, "earsWidth")
  reverted.EyeBrowD = table.extract(standard.expressions, "eyebrowDepth")
  reverted.EyeBrowH = table.extract(standard.expressions, "eyebrowHeight")
  reverted.EyeBrowW = table.extract(standard.expressions, "eyebrowWidth")
  reverted.EyeLidH = table.extract(standard.expressions, "eyelidHeight")
  reverted.EyeLidL = table.extract(standard.expressions, "eyelidLeft")
  reverted.EyeLidR = table.extract(standard.expressions, "eyelidRight")
  reverted.EyeLidW = table.extract(standard.expressions, "eyelidWidth")
  reverted.EyeAng = table.extract(standard.expressions, "eyesAngle")
  reverted.EyeD = table.extract(standard.expressions, "eyesDepth")
  reverted.EyeDis = table.extract(standard.expressions, "eyesDistance")
  reverted.EyeH = table.extract(standard.expressions, "eyesHeight")
  reverted.FaceW = table.extract(standard.expressions, "faceWidth")
  reverted.HeadSize = table.extract(standard.expressions, "headWidth")
  reverted.HipsS = table.extract(standard.expressions, "hip")
  reverted.JawD = table.extract(standard.expressions, "jawDepth")
  reverted.JawH = table.extract(standard.expressions, "jawHeight")
  reverted.JawW = table.extract(standard.expressions, "jawWidth")
  reverted.jawY = table.extract(standard.expressions, "jawY")
  reverted.LLiphD = table.extract(standard.expressions, "lowerLipDepth")
  reverted.LLiphH = table.extract(standard.expressions, "lowerLipHeight")
  reverted.LLiphW = table.extract(standard.expressions, "lowerLipWidth")
  reverted.MouthCLD = table.extract(standard.expressions, "mouthConerLeftDepth")
  reverted.MouthCLH = table.extract(standard.expressions, "mouthConerLeftHeight")
  reverted.MouthCLLD = table.extract(standard.expressions, "mouthConerLeftLipsDistance")
  reverted.MouthCLW = table.extract(standard.expressions, "mouthConerLeftWidth")
  reverted.MouthCRD = table.extract(standard.expressions, "mouthConerRightDepth")
  reverted.MouthCRH = table.extract(standard.expressions, "mouthConerRightHeight")
  reverted.MouthCRLD = table.extract(standard.expressions, "mouthConerRightLipsDistance")
  reverted.MouthCRW = table.extract(standard.expressions, "mouthConerRightWidth")
  reverted.MouthD = table.extract(standard.expressions, "mouthDepth")
  reverted.MouthW = table.extract(standard.expressions, "mouthWidth")
  reverted.MouthX = table.extract(standard.expressions, "mouthX")
  reverted.MouthY = table.extract(standard.expressions, "mouthY")
  reverted.NeckD = table.extract(standard.expressions, "neckDepth")
  reverted.NeckW = table.extract(standard.expressions, "neckWidth")
  reverted.NoseAng = table.extract(standard.expressions, "noseAngle")
  reverted.NoseC = table.extract(standard.expressions, "noseCurvature")
  reverted.NoseH = table.extract(standard.expressions, "noseHeight")
  reverted.NoseS = table.extract(standard.expressions, "noseSize")
  reverted.NoseW = table.extract(standard.expressions, "noseWidth")
  reverted.NoseDis = table.extract(standard.expressions, "nostrilsDistance")
  reverted.ShouldersM = table.extract(standard.expressions, "shoulderBlades")
  reverted.ShouldersS = table.extract(standard.expressions, "shoulders")
  reverted.ShouldersT = table.extract(standard.expressions, "shoulderThickness")
  reverted.LegsS = table.extract(standard.expressions, "thighs")
  reverted.ULiphD = table.extract(standard.expressions, "upperLipDepth")
  reverted.ULiphH = table.extract(standard.expressions, "upperLipHeight")
  reverted.ULiphW = table.extract(standard.expressions, "upperLipWidth")
  reverted.WaistW = table.extract(standard.expressions, "waist")

  if standard.overlays.ageing then
    reverted.ageing_visibility = 1
    reverted.ageing_tx_id = increase(standard.overlays.ageing.id)
    reverted.ageing_opacity = standard.overlays.ageing.opacity
    standard.overlays.ageing.id = nil
    standard.overlays.ageing.opacity = nil
  end
  if standard.overlays.beard then
    reverted.beardstabble_visibility = 1
    reverted.beardstabble_color_primary = standard.overlays.beard.tint0
    reverted.beardstabble_opacity = standard.overlays.beard.opacity
    standard.overlays.beard.tint0 = nil
    standard.overlays.beard.opacity = nil
  end
  if standard.overlays.blush then
    reverted.blush_visibility = 1
    reverted.blush_tx_id = increase(standard.overlays.blush.id)
    reverted.blush_palette_color_primary = standard.overlays.blush.tint0
    reverted.blush_opacity = standard.overlays.blush.opacity
    standard.overlays.blush.id = nil
    standard.overlays.blush.tint0 = nil
    standard.overlays.blush.opacity = nil
  end
  if standard.overlays.eyebrow then
    reverted.eyebrows_visibility = 1
    reverted.eyebrows_tx_id = increase(standard.overlays.eyebrow.id)
    if standard.overlays.sexe == "f" then
      reverted.eyebrows_tx_id = reverted.eyebrows_tx_id + 15
    end
    reverted.eyebrows_color = standard.overlays.eyebrow.tint0
    reverted.eyebrows_opacity = standard.overlays.eyebrow.opacity
    standard.overlays.eyebrow.id = nil
    standard.overlays.eyebrow.sexe = nil
    standard.overlays.eyebrow.tint0 = nil
    standard.overlays.eyebrow.opacity = nil
  end
  if standard.overlays.eyeliner then
    reverted.eyeliner_visibility = 1
    reverted.eyeliner_tx_id = increase(standard.overlays.eyeliner.id)
    reverted.eyeliner_palette_id = increase(standard.overlays.eyeliner.sheetGrid)
    reverted.eyeliner_color_primary = standard.overlays.eyeliner.tint0
    reverted.eyeliner_opacity = standard.overlays.eyeliner.opacity
    standard.overlays.eyeliner.id = nil
    standard.overlays.eyeliner.sheetGrid = nil
    standard.overlays.eyeliner.tint0 = nil
    standard.overlays.eyeliner.opacity = nil
  end
  if standard.overlays.eyeshadow then
    reverted.shadows_visibility = 1
    reverted.shadows_tx_id = increase(standard.overlays.eyeshadow.id)
    reverted.shadows_palette_id = increase(standard.overlays.eyeshadow.sheetGrid)
    reverted.shadows_palette_color_primary = standard.overlays.eyeshadow.tint0
    reverted.shadows_palette_color_secondary = standard.overlays.eyeshadow.tint1
    reverted.shadows_palette_color_tertiary = standard.overlays.eyeshadow.tint2
    reverted.shadows_opacity = standard.overlays.eyeshadow.opacity
    standard.overlays.eyeshadow.id = nil
    standard.overlays.eyeshadow.sheetGrid = nil
    standard.overlays.eyeshadow.tint0 = nil
    standard.overlays.eyeshadow.tint1 = nil
    standard.overlays.eyeshadow.tint2 = nil
    standard.overlays.eyeshadow.opacity = nil
  end
  if standard.overlays.freckles then
    reverted.freckles_visibility = 1
    reverted.freckles_tx_id = increase(standard.overlays.freckles.id)
    reverted.freckles_opacity = standard.overlays.freckles.opacity
    standard.overlays.freckles.id = nil
    standard.overlays.freckles.opacity = nil
  end
  if standard.overlays.lipstick then
    reverted.lipsticks_visibility = 1
    reverted.lipsticks_tx_id = increase(standard.overlays.lipstick.id)
    reverted.lipsticks_palette_id = increase(standard.overlays.lipstick.sheetGrid)
    reverted.lipsticks_palette_color_primary = standard.overlays.lipstick.tint0
    reverted.lipsticks_palette_color_secondary = standard.overlays.lipstick.tint1
    reverted.lipsticks_palette_color_tertiary = standard.overlays.lipstick.tint2
    reverted.lipsticks_opacity = standard.overlays.lipstick.opacity
    standard.overlays.lipstick.id = nil
    standard.overlays.lipstick.sheetGrid = nil
    standard.overlays.lipstick.tint0 = nil
    standard.overlays.lipstick.tint1 = nil
    standard.overlays.lipstick.tint2 = nil
    standard.overlays.lipstick.opacity = nil
  end
  if standard.overlays.moles then
    reverted.moles_visibility = 1
    reverted.moles_tx_id = increase(standard.overlays.moles.id)
    reverted.moles_opacity = standard.overlays.moles.opacity
    standard.overlays.moles.id = nil
    standard.overlays.moles.opacity = nil
  end
  if standard.overlays.scar then
    reverted.scars_visibility = 1
    reverted.scars_tx_id = increase(standard.overlays.scar.id)
    reverted.scars_opacity = standard.overlays.scar.opacity
    standard.overlays.scar.id = nil
    standard.overlays.scar.opacity = nil
  end
  if standard.overlays.spots then
    reverted.spots_visibility = 1
    reverted.spots_tx_id = increase(standard.overlays.spots.id)
    reverted.spots_opacity = standard.overlays.spots.opacity
    standard.overlays.spots.id = nil
    standard.overlays.spots.opacity = nil
  end
  if standard.overlays.acne then
    reverted.acne_visibility = 1
    reverted.acne_tx_id = increase(standard.overlays.acne.id)
    reverted.acne_opacity = standard.overlays.acne.opacity
    standard.overlays.acne.id = nil
    standard.overlays.acne.opacity = nil
  end
  if standard.overlays.grime then
    reverted.grime_visibility = 1
    reverted.grime_tx_id = increase(standard.overlays.grime.id)
    reverted.grime_opacity = standard.overlays.grime.opacity
    standard.overlays.grime.id = nil
    standard.overlays.grime.opacity = nil
  end
  if standard.overlays.hair then
    reverted.hair_visibility = 1
    reverted.hair_tx_id = increase(standard.overlays.hair.id)
    reverted.hair_color_primary = standard.overlays.hair.tint0
    reverted.hair_opacity = standard.overlays.hair.opacity
    standard.overlays.hair.id = nil
    standard.overlays.hair.tint0 = nil
    standard.overlays.hair.opacity = nil
  end
  if standard.overlays.complex then
    reverted.complex_visibility = 1
    reverted.complex_tx_id = increase(standard.overlays.complex.id)
    reverted.complex_opacity = standard.overlays.complex.opacity
    standard.overlays.complex.id = nil
    standard.overlays.complex.opacity = nil
  end
  if standard.overlays.disc then
    reverted.disc_visibility = 1
    reverted.disc_tx_id = increase(standard.overlays.disc.id)
    reverted.disc_opacity = standard.overlays.disc.opacity
    standard.overlays.disc.id = nil
    standard.overlays.disc.opacity = nil
  end
  if standard.overlays.foundation then
    reverted.foundation_visibility = 1
    reverted.foundation_tx_id = increase(standard.overlays.foundation.id)
    reverted.foundation_palette_color_primary = standard.overlays.foundation.tint0
    reverted.foundation_palette_color_secondary = standard.overlays.foundation.tint1
    reverted.foundation_palette_color_tertiary = standard.overlays.foundation.tint2
    reverted.foundation_palette_id = increase(standard.overlays.foundation.sheetGrid)
    reverted.foundation_opacity = standard.overlays.foundation.opacity
    standard.overlays.foundation.id = nil
    standard.overlays.foundation.tint0 = nil
    standard.overlays.foundation.tint1 = nil
    standard.overlays.foundation.tint2 = nil
    standard.overlays.foundation.sheetGrid = nil
    standard.overlays.foundation.opacity = nil
  end

  reverted.overlays = standard.overlays

  return reverted
end

function FrameworkClass:standardizeClothesInternal(clothes)
  local standard = {
    accessories = table.extract(clothes, "Accessories"),
    armor = table.extract(clothes, "armor"),
    badges = table.extract(clothes, "Badge"),
    beards_complete = table.extract(clothes, "Beard"),
    belts = table.extract(clothes, "Belt"),
    boots = table.extract(clothes, "Boots"),
    hair_accessories = table.extract(clothes, "bow"),
    jewelry_bracelets = table.extract(clothes, "Bracelet"),
    chaps = table.extract(clothes, "Chap"),
    belt_buckles = table.extract(clothes, "Buckle"),
    cloaks = table.extract(clothes, "Cloak"),
    coats = table.extract(clothes, "Coat"),
    coats_closed = table.extract(clothes, "Coat"),
    dresses = table.extract(clothes, "Dress"),
    eyewear = table.extract(clothes, "Eye"),
    gauntlets = table.extract(clothes, "Gauntlets"),
    gloves = table.extract(clothes, "Glove"),
    gunbelts = table.extract(clothes, "Gunbelt"),
    gunbelt_accs = table.extract(clothes, "Gunbelt"),
    hair = table.extract(clothes, "Hair"),
    hats = table.extract(clothes, "Hat"),
    holsters_left = table.extract(clothes, "Holster"),
    loadouts = table.extract(clothes, "Loadouts"),
    masks = table.extract(clothes, "Mask"),
    neckties = table.extract(clothes, "Neck"),
    neckwear = table.extract(clothes, "Neck"),
    pants = table.extract(clothes, "Pant"),
    ponchos = table.extract(clothes, "Poncho"),
    jewelry_rings_left = table.extract(clothes, "Ring"),
    jewelry_rings_right = table.extract(clothes, "Ring"),
    satchels = table.extract(clothes, "Satchels"),
    full = table.extract(clothes, "Shirt"),
    skirts = table.extract(clothes, "Skirt"),
    spats = table.extract(clothes, "Spats"),
    boot_accessories = table.extract(clothes, "Spurs"),
    suspenders = table.extract(clothes, "Suspender"),
    teeth = table.extract(clothes, "Teeth"),
    vests = table.extract(clothes, "Vest"),
  }
  return standard
end

function FrameworkClass:revertClothesInternal(standard)
  local reverted = {
    Accessories = table.extract(standard, "accessories"),
    armor = table.extract(standard, "armor"),
    Badge = table.extract(standard, "badges"),
    Beard = table.extract(standard, "beards_complete"),
    Belt = table.extract(standard, "belts"),
    Boots = table.extract(standard, "boots"),
    bow = table.extract(standard, "hair_accessories"),
    Bracelet = table.extract(standard, "jewelry_bracelets"),
    Buckle = table.extract(standard, "belt_buckles"),
    Chap = table.extract(standard, "chaps"),
    Cloak = table.extract(standard, "cloaks"),
    Coat = table.extract(standard, "coats"),
    CoatClosed = table.extract(standard, "coats_closed"),
    Dress = table.extract(standard, "dresses"),
    EyeWear = table.extract(standard, "eyewear"),
    Gauntlets = table.extract(standard, "gauntlets"),
    Glove = table.extract(standard, "gloves"),
    Gunbelt = table.extract(standard, "gunbelts"),
    GunbeltAccs = table.extract(standard, "gunbelt_accs"),
    Hair = table.extract(standard, "hair"),
    Hat = table.extract(standard, "hats"),
    Holster = table.extract(standard, "holsters_left"),
    Loadouts = table.extract(standard, "loadouts"),
    Mask = table.extract(standard, "masks"),
    NeckTies = table.extract(standard, "neckties"),
    NeckWear = table.extract(standard, "neckwear"),
    Pant = table.extract(standard, "pants"),
    Poncho = table.extract(standard, "ponchos"),
    RingLh = table.extract(standard, "jewelry_rings_left"),
    RingRh = table.extract(standard, "jewelry_rings_right"),
    Satchels = table.extract(standard, "satchels"),
    Shirt = table.extract(standard, "shirts_full"),
    Skirt = table.extract(standard, "skirts"),
    Spats = table.extract(standard, "spats"),
    Spurs = table.extract(standard, "boot_accessories"),
    Suspender = table.extract(standard, "suspenders"),
    Teeth = table.extract(standard, "teeth"),
    Vest = table.extract(standard, "vests")
  }
  return reverted
end

function FrameworkClass:getUserClothesInternal(source)
  local clothes = {}

  local user = self.UserClass:get(source)
  clothes = UnJson(user.data.comps)
  local clothesTints = UnJson(user.data.compTints)
  for category, data in pairs(clothesTints) do
    for hash, data2 in pairs(data) do
      if tonumber(clothes[category]) == tonumber(hash) then
        clothes[category] = {
          hash = clothes[category]
        }
        table.merge(clothes[category], data2)
      end
    end
  end

  return clothes
end

function FrameworkClass:updateUserClothesInternal(source, clothes)
  local newClothes = {}
  for category, value in pairs(clothes) do
    newClothes[category] = value
    newClothes[category].comp = GetValue(value?.hash, 0)
  end
  local user = self.UserClass:get(source)
  local tints = UnJson(user.data.comptTints)
  for category, value in pairs(clothes) do
    if clothes.hash ~= 0 then
      if type(value) == "table" then
        tints[category] = {}
        if value.palette and value.palette ~= 0 then
          tints[category][value.hash] = {
            tint0 = GetValue(value.tint0, 0),
            tint1 = GetValue(value.tint1, 0),
            tint2 = GetValue(value.tint2, 0),
            palette = GetValue(value.palette, 0),
          }
        end
        if value.state then
          tints[category][value.hash] = GetValue(tints[category][value.hash], {})
          tints[category][value.hash].state = value.state
        end
        value = value.hash
      end
    end
  end
  for _, value in pairs(tints) do
    if table.count(value) == 0 then
      value = nil
    end
  end
  TriggerClientEvent("vorpcharacter:updateCache", source, false, newClothes)
  user.data.updateCompTints(json.encode(tints))
end

function FrameworkClass:getUserSkinInternal(source)
  local user = self.UserClass:get(source)
  if not user then return {} end
  return UnJson(user.data.skin)
end

function FrameworkClass:updateUserSkinInternal(source, skin, overwrite)
  if overwrite then
    TriggerClientEvent("vorpcharacter:updateCache", source, skin)
  else
    TriggerClientEvent("vorpcharacter:savenew", source, false, skin)
  end
end

function FrameworkClass:createUser(source, data, spawnCoordinate, isDead)
  if isDead == nil then isDead = false end
  spawnCoordinate = GetValue(spawnCoordinate, vec4(2537.684, -1278.066, 49.218, 42.520))
  data = GetValue(data, {})
  data.firstname = GetValue(data.firstname, "")
  data.lastname = GetValue(data.lastname, "")
  data.skin = self:revertSkin(data.skin)
  data.comps = self:revertClothes(data.comps)

  local convertData = {
    firstname = GetValue(data.firstname, ""),
    lastname = GetValue(data.lastname, ""),
    skin = json.encode(GetValue(data.skin, {})),
    comps = json.encode(GetValue(data.comps, {})),
    compTints = "[]",
    age = data.age,
    gender = data.skin.model == "mp_male" and "Male" or "Female",
    charDescription = GetValue(data.charDescription, ""),
    nickname = GetValue(data.nickname, "")
  }
  Core.getUser(source).addCharacter(convertData)
  TriggerClientEvent("vorp:initCharacter", source, spawnCoordinate.xyz, spawnCoordinate.w, isDead)
  SetTimeout(3000, function()
    TriggerEvent("vorp_NewCharacter", source)
  end)
end

return FrameworkClass
