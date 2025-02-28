-------------
-- FRAMEWORK CLASS
-------------
FrameworkClass = FrameworkClass or {}
FrameworkClass.name = "VORP"
FrameworkClass.longName = "VORP Framework"
FrameworkClass.core = exports.vorp_core:GetCore()
FrameworkClass.inv = exports.vorp_inventory

-------------
-- VARIABLES
-------------

local inventoriesCreated = {}

-------------
-- INVENTORY
-------------

function FrameworkClass:canUseItem(source, item, amount, meta, remove)
  local count = self.inv:getItemCount(source, nil, item, meta)
  if count >= amount then
    if remove then
      self.inv:subItem(source, item, amount, meta)
    end
    return true
  end
  return false
end

function FrameworkClass:registerUseItem(item, closeAfterUsed, callback)
  CreateThread(function()
    if (closeAfterUsed == nil) then closeAfterUsed = true end
    local isExist = self.inv:getItemDB(item)
    local count = 0
    while not isExist and count < 10 do
      isExist = self.inv:getItemDB(item)
      count = count + 1
      Wait(1000)
    end
    if not isExist then
      return eprint(item .. " < item does not exist in the database")
    end
    self.inv:registerUsableItem(item, function(data)
      if closeAfterUsed then
        self.inv:closeInventory(data.source)
      end
      return callback(data.source, { metadata = data.item.metadata })
    end)
  end)
end

function FrameworkClass:giveItem(source, item, quantity, meta)
  if self.inv:canCarryItem(source, item, quantity) then
    self.inv:addItem(source, item, quantity, meta)
    return true
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

  inventoriesCreated[id].inventory = self.inv:registerInventory({
    id = id,
    name = name,
    limit = invConfig.maxSlots,
    acceptWeapons = invConfig.acceptWeapons or false,
    shared = invConfig.shared or true,
    ignoreItemStackLimit = invConfig.ignoreStackLimit or true,
    whitelistItems = invConfig.whitelist and true or false,
  })
  for _, data in pairs(invConfig.whitelist or {}) do
    self.inv:setCustomInventoryItemLimit(id, data.item, data.limit)
  end
  return inventoriesCreated[id].inventory
end

function FrameworkClass:removeInventory(id)
  self.inv:removeInventory(id)
end

function FrameworkClass:openInventory(source, id)
  if not self.inv:isCustomInventoryRegistered(id) then
    return false, eprint(("This custom inventory doesn't exist: %s. You can create it with `jo.framework.createInventory()`."):format(tostring(id)))
  end
  return self.inv:openInventory(source, id)
end

function FrameworkClass:addItemInInventory(source, id, item, quantity, metadata)
  local user = UserClass:get(source)
  local charIdentifier = user.data.charIdentifier

  local items = {
    {
      name = item,
      amount = quantity,
      metadata = metadata
    }
  }

  return self.inv:addItemsToCustomInventory(id, items, charIdentifier)
end

function FrameworkClass:getItemsFromInventory(id)
  local invItems = self.inv:getCustomInventoryItems(id)

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


function FrameworkClass:standardizeSkin(object)
  object = table.copy(object)
  local standard = {}

  local function decrease(value)
    return (value or 1) - 1
  end

  if jo.debug then
    oprint("Standardizing skin")
    print(json.encode(object))
  end

  standard.model = table.extract(object, "sex")
  standard.headHash = table.extract(object, "HeadType")
  standard.bodyUpperHash = object.BodyType ~= 0 and object.BodyType or object.Torso
  object.BodyType = nil
  object.Torso = nil
  standard.bodyLowerHash = object.LegsType ~= 0 and object.LegsType or object.Legs
  object.LegsType = nil
  object.Legs = nil
  standard.eyesHash = table.extract(object, "Eyes")
  standard.teethHash = table.extract(object, "Teeth")
  standard.hair = table.extract(object, "Hair")
  standard.beards_complete = table.extract(object, "Beard")
  standard.bodyType = table.extract(object, "Body")
  standard.bodyWeight = table.extract(object, "Waist")
  standard.bodyScale = table.extract(object, "Scale")

  standard.expressions = {
    arms = table.extract(object, "ArmsS"),
    calves = table.extract(object, "CalvesS"),
    cheekbonesDepth = table.extract(object, "CheekBonesD"),
    cheekbonesHeight = table.extract(object, "CheekBonesH"),
    cheekbonesWidth = table.extract(object, "CheekBonesW"),
    chest = table.extract(object, "ChestS"),
    chinDepth = table.extract(object, "ChinD"),
    chinHeight = table.extract(object, "ChinH"),
    chinWidth = table.extract(object, "ChinW"),
    earlobes = table.extract(object, "EarsD"),
    earsAngle = table.extract(object, "EarsA"),
    earsDepth = table.extract(object, "earsDepth"),
    earsHeight = table.extract(object, "EarsH"),
    earsWidth = table.extract(object, "EarsW"),
    eyebrowDepth = table.extract(object, "EyeBrowD"),
    eyebrowHeight = table.extract(object, "EyeBrowH"),
    eyebrowWidth = table.extract(object, "EyeBrowW"),
    eyelidHeight = table.extract(object, "EyeLidH"),
    eyelidLeft = table.extract(object, "EyeLidL"),
    eyelidRight = table.extract(object, "EyeLidR"),
    eyelidWidth = table.extract(object, "EyeLidW"),
    eyesAngle = table.extract(object, "EyeAng"),
    eyesDepth = table.extract(object, "EyeD"),
    eyesDistance = table.extract(object, "EyeDis"),
    eyesHeight = table.extract(object, "EyeH"),
    faceWidth = table.extract(object, "FaceW"),
    headWidth = table.extract(object, "HeadSize"),
    hip = table.extract(object, "HipsS"),
    jawDepth = table.extract(object, "JawD"),
    jawHeight = table.extract(object, "JawH"),
    jawWidth = table.extract(object, "JawW"),
    jawY = table.extract(object, "jawY"),
    lowerLipDepth = table.extract(object, "LLiphD"),
    lowerLipHeight = table.extract(object, "LLiphH"),
    lowerLipWidth = table.extract(object, "LLiphW"),
    mouthConerLeftDepth = table.extract(object, "MouthCLD"),
    mouthConerLeftHeight = table.extract(object, "MouthCLH"),
    mouthConerLeftLipsDistance = table.extract(object, "MouthCLLD"),
    mouthConerLeftWidth = table.extract(object, "MouthCLW"),
    mouthConerRightDepth = table.extract(object, "MouthCRD"),
    mouthConerRightHeight = table.extract(object, "MouthCRH"),
    mouthConerRightLipsDistance = table.extract(object, "MouthCRLD"),
    mouthConerRightWidth = table.extract(object, "MouthCRW"),
    mouthDepth = table.extract(object, "MouthD"),
    mouthWidth = table.extract(object, "MouthW"),
    mouthX = table.extract(object, "MouthX"),
    mouthY = table.extract(object, "MouthY"),
    neckDepth = table.extract(object, "NeckD"),
    neckWidth = table.extract(object, "NeckW"),
    noseAngle = table.extract(object, "NoseAng"),
    noseCurvature = table.extract(object, "NoseC"),
    noseHeight = table.extract(object, "NoseH"),
    noseSize = table.extract(object, "NoseS"),
    noseWidth = table.extract(object, "NoseW"),
    nostrilsDistance = table.extract(object, "NoseDis"),
    shoulderBlades = table.extract(object, "ShouldersM"),
    shoulders = table.extract(object, "ShouldersS"),
    shoulderThickness = table.extract(object, "ShouldersT"),
    thighs = table.extract(object, "LegsS"),
    upperLipDepth = table.extract(object, "ULiphD"),
    upperLipHeight = table.extract(object, "ULiphH"),
    upperLipWidth = table.extract(object, "ULiphW"),
    waist = table.extract(object, "WaistW"),
  }

  local function needOverlay(value)
    if not value then return nil end
    if value == 0 then return nil end
    return true
  end

  standard.overlays = {}
  standard.overlays.ageing = needOverlay(object.ageing_visibility) and {
    id = decrease(object.ageing_tx_id),
    opacity = convertToPercent(object.ageing_opacity)
  }
  object.ageing_tx_id = nil
  object.ageing_opacity = nil
  object.ageing_visibility = nil

  standard.overlays.beard = needOverlay(object.beardstabble_visibility) and {
    id = 0,
    tint0 = object.beardstabble_color_primary,
    opacity = convertToPercent(object.beardstabble_opacity)
  }
  object.beardstabble_color_primary = nil
  object.beardstabble_opacity = nil
  object.beardstabble_visibility = nil

  standard.overlays.blush = needOverlay(object.blush_visibility) and {
    id = decrease(object.blush_tx_id),
    tint0 = object.blush_palette_color_primary,
    opacity = convertToPercent(object.blush_opacity)
  }
  object.blush_tx_id = nil
  object.blush_palette_color_primary = nil
  object.blush_opacity = nil
  object.blush_visibility = nil

  standard.overlays.eyebrow = needOverlay(object.eyebrows_visibility) and (function()
    local id = decrease(object.eyebrows_tx_id)
    local sexe = "m"
    if id > 15 then
      id = id - 15
      sexe = "f"
    end
    return {
      id = id,
      sexe = sexe,
      tint0 = object.eyebrows_color,
      opacity = convertToPercent(object.eyebrows_opacity)
    }
  end)()
  object.eyebrows_tx_id = nil
  object.eyebrows_color = nil
  object.eyebrows_opacity = nil
  object.eyebrows_visibility = nil

  standard.overlays.eyeliner = needOverlay(object.eyeliner_visibility) and {
    id = decrease(object.eyeliner_tx_id),
    sheetGrid = decrease(object.eyeliner_palette_id),
    tint0 = object.eyeliner_color_primary,
    opacity = convertToPercent(object.eyeliner_opacity)
  }
  object.eyeliner_tx_id = nil
  object.eyeliner_palette_id = nil
  object.eyeliner_color_primary = nil
  object.eyeliner_opacity = nil
  object.eyeliner_visibility = nil

  standard.overlays.eyeshadow = needOverlay(object.shadows_visibility) and {
    id = 0,
    sheetGrid = decrease(object.shadows_palette_id),
    tint0 = object.shadows_palette_color_primary,
    tint1 = object.shadows_palette_color_secondary,
    tint2 = object.shadows_palette_color_tertiary,
    opacity = convertToPercent(object.shadows_opacity)
  }
  object.shadows_palette_id = nil
  object.shadows_palette_color_primary = nil
  object.shadows_palette_color_secondary = nil
  object.shadows_palette_color_tertiary = nil
  object.shadows_opacity = nil
  object.shadows_visibility = nil

  standard.overlays.freckles = needOverlay(object.freckles_visibility) and {
    id = decrease(object.freckles_tx_id),
    opacity = convertToPercent(object.freckles_opacity)
  }
  object.freckles_tx_id = nil
  object.freckles_opacity = nil
  object.freckles_visibility = nil

  standard.overlays.lipstick = needOverlay(object.lipsticks_visibility) and {
    id = 0,
    sheetGrid = decrease(object.lipsticks_palette_id),
    tint0 = object.lipsticks_palette_color_primary,
    tint1 = object.lipsticks_palette_color_secondary,
    tint2 = object.lipsticks_palette_color_tertiary,
    opacity = convertToPercent(object.lipsticks_opacity)
  }
  object.lipsticks_palette_id = nil
  object.lipsticks_palette_color_primary = nil
  object.lipsticks_palette_color_secondary = nil
  object.lipsticks_palette_color_tertiary = nil
  object.lipsticks_opacity = nil
  object.lipsticks_visibility = nil

  standard.overlays.moles = needOverlay(object.moles_visibility) and {
    id = decrease(object.moles_tx_id),
    opacity = convertToPercent(object.moles_opacity)
  }
  object.moles_tx_id = nil
  object.moles_opacity = nil
  object.moles_visibility = nil

  standard.overlays.scar = needOverlay(object.scars_visibility) and {
    id = decrease(object.scars_tx_id),
    opacity = convertToPercent(object.scars_opacity)
  }
  object.scars_tx_id = nil
  object.scars_opacity = nil
  object.scars_visibility = nil

  standard.overlays.spots = needOverlay(object.spots_visibility) and {
    id = decrease(object.spots_tx_id),
    opacity = convertToPercent(object.spots_opacity)
  }
  object.spots_tx_id = nil
  object.spots_opacity = nil
  object.spots_visibility = nil

  standard.overlays.acne = needOverlay(object.acne_visibility) and {
    id = decrease(object.acne_tx_id),
    opacity = convertToPercent(object.acne_opacity)
  }
  object.acne_tx_id = nil
  object.acne_opacity = nil
  object.acne_visibility = nil

  standard.overlays.grime = needOverlay(object.grime_visibility) and {
    id = decrease(object.grime_tx_id),
    opacity = convertToPercent(object.grime_opacity)
  }
  object.grime_tx_id = nil
  object.grime_opacity = nil
  object.grime_visibility = nil

  standard.overlays.hair = needOverlay(object.hair_visibility) and {
    id = decrease(object.hair_tx_id),
    tint0 = object.hair_color_primary,
    opacity = convertToPercent(object.hair_opacity)
  }
  object.hair_tx_id = nil
  object.hair_color_primary = nil
  object.hair_opacity = nil
  object.hair_visibility = nil

  standard.overlays.complex = needOverlay(object.complex_visibility) and {
    id = decrease(object.complex_tx_id),
    opacity = convertToPercent(object.complex_opacity)
  }
  object.complex_tx_id = nil
  object.complex_opacity = nil
  object.complex_visibility = nil

  standard.overlays.disc = needOverlay(object.disc_visibility) and {
    id = decrease(object.disc_tx_id),
    opacity = convertToPercent(object.disc_opacity)
  }
  object.disc_tx_id = nil
  object.disc_opacity = nil
  object.disc_visibility = nil

  standard.overlays.foundation = needOverlay(object.foundation_visibility) and {
    id = decrease(object.foundation_tx_id),
    tint0 = object.foundation_palette_color_primary,
    tint1 = object.foundation_palette_color_secondary,
    tint2 = object.foundation_palette_color_tertiary,
    sheetGrid = decrease(object.foundation_palette_id),
    opacity = convertToPercent(object.foundation_opacity)
  }
  object.foundation_tx_id = nil
  object.foundation_palette_color_primary = nil
  object.foundation_palette_color_secondary = nil
  object.foundation_palette_color_tertiary = nil
  object.foundation_palette_id = nil
  object.foundation_opacity = nil
  object.foundation_visibility = nil

  standard.overlays.masks = needOverlay(object.paintedmasks_visibility) and {
    id = decrease(object.paintedmasks_tx_id),
    tint0 = object.paintedmasks_palette_color_primary,
    tint1 = object.paintedmasks_palette_color_secondary,
    tint2 = object.paintedmasks_palette_color_tertiary,
    sheetGrid = decrease(object.paintedmasks_palette_id),
    opacity = convertToPercent(object.paintedmasks_opacity)
  }
  object.paintedmasks_tx_id = nil
  object.paintedmasks_palette_color_primary = nil
  object.paintedmasks_palette_color_secondary = nil
  object.paintedmasks_palette_color_tertiary = nil
  object.paintedmasks_palette_id = nil
  object.paintedmasks_opacity = nil
  object.paintedmasks_visibility = nil

  --Clear unneccessary keys
  table.extract(object, "FaceD")              --Same hash than EyeBrowW
  table.extract(object, "FaceS")              --Same hash than EyeBrowH
  table.extract(object, "albedo")             --Useless
  table.extract(object, "beardstabble_tx_id") --Unused by VORP
  table.extract(object, "blush_palette_id")   --Unused by VORP
  table.extract(object, "shadows_tx_id")      --Unused by VORP
  table.extract(object, "lipsticks_tx_id")    --Unused by VORP

  if jo.debug then
    if table.count(object) > 0 then
      eprint("Skin keys not converted to standard")
      for key, value in pairs(object) do
        print(key, type(value) == "table" and json.encode(value) or value)
      end
    else
      gprint("All skin keys standardized")
    end
  end

  standard = table.merge(standard, object)

  --Clear overlays table
  standard.overlays = table.merge(standard.overlays, object.overlays)
  standard.expressions = table.merge(standard.expressions, object.expressions)

  for key, expression in pairs(standard.expressions) do
    if expression == 0 then
      standard.expressions[key] = nil
    else
      standard.expressions[key] = convertToPercent(expression)
    end
  end

  clearOverlaysTable(standard.overlays)

  if standard.hair and type(standard.hair) ~= "table" then
    standard.hair = {
      hash = standard.hair
    }
  end
  if standard.beards_complete and type(standard.beards_complete) ~= "table" then
    standard.beards_complete = {
      hash = standard.beards_complete
    }
  end

  if jo.debug then
    oprint("Standardized skin")
    print(json.encode(standard))
  end

  return standard
end

function FrameworkClass:revertSkin(standard)
  standard = table.copy(standard)

  local reverted = {}

  local function increase(value)
    return (value or 0) + 1
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
  reverted.Hair = table.extract(standard, "hair")
  reverted.Beard = table.extract(standard, "beards_complete")
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

  for key, data in pairs(standard.overlays) do
    if table.count(data) == 0 then
      standard.overlays[key] = nil
    end
  end

  if table.count(standard.overlays) == 0 then
    standard.overlays = nil
  end
  if table.count(standard.expressions) == 0 then
    standard.expressions = nil
  end

  if config and Config.debug then
    if table.count(standard) > 0 then
      eprint("Skin keys not reverted")
      for key, value in pairs(standard) do
        print(key, type(value) == "table" and json.encode(value) or value)
      end
    else
      gprint("All skin keys reverted")
    end
  end

  reverted.overlays = table.copy(standard.overlays)

  return reverted
end

function FrameworkClass:revertClothes(object)
  object = table.copy(object)
  local reverted = {}
  reverted.Accessories = table.extract(object, "accessories")
  reverted.armor = table.extract(object, "armor")
  reverted.Badge = table.extract(object, "badges")
  reverted.Beard = table.extract(object, "beards_complete")
  reverted.Belt = table.extract(object, "belts")
  reverted.Boots = table.extract(object, "boots")
  reverted.bow = table.extract(object, "hair_accessories")
  reverted.Bracelet = table.extract(object, "jewelry_bracelets")
  reverted.Buckle = table.extract(object, "belt_buckles")
  reverted.Chap = table.extract(object, "chaps")
  reverted.Cloak = table.extract(object, "cloaks")
  reverted.Coat = table.extract(object, "coats")
  reverted.CoatClosed = table.extract(object, "coats_closed")
  reverted.Dress = table.extract(object, "dresses")
  reverted.EyeWear = table.extract(object, "eyewear")
  reverted.Gauntlets = table.extract(object, "gauntlets")
  reverted.Glove = table.extract(object, "gloves")
  reverted.Gunbelt = table.extract(object, "gunbelts")
  reverted.GunbeltAccs = table.extract(object, "gunbelt_accs")
  reverted.Hair = table.extract(object, "hair")
  reverted.Hat = table.extract(object, "hats")
  reverted.Holster = table.extract(object, "holsters_left")
  reverted.Loadouts = table.extract(object, "loadouts")
  reverted.Mask = table.extract(object, "masks")
  reverted.NeckTies = table.extract(object, "neckties")
  reverted.NeckWear = table.extract(object, "neckwear")
  reverted.Pant = table.extract(object, "pants")
  reverted.Poncho = table.extract(object, "ponchos")
  reverted.RingLh = table.extract(object, "jewelry_rings_left")
  reverted.RingRh = table.extract(object, "jewelry_rings_right")
  reverted.Satchels = table.extract(object, "satchels")
  reverted.Shirt = table.extract(object, "shirts_full")
  reverted.Skirt = table.extract(object, "skirts")
  reverted.Spats = table.extract(object, "spats")
  reverted.Spurs = table.extract(object, "boot_accessories")
  reverted.Suspender = table.extract(object, "suspenders")
  reverted.Teeth = table.extract(object, "teeth")
  reverted.Vest = table.extract(object, "vests")

  for key, value in pairs(object) do
    if jo.debug then
      dprint("Clothes key not reverted", key, value)
    end
    reverted[key] = value
  end

  return reverted
end

function FrameworkClass:getUserClothes(source)
  local clothes = {}

  local user = UserClass:get(source)
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

  local clothesStandardized = standardizeClothes(clothes)

  return clothesStandardized
end

function FrameworkClass:updateUserClothes(source, _clothes, value)
  if value then
    _clothes = { [_clothes] = formatComponentData(value) }
  end
  local clothes = self:revertClothes(_clothes)

  local newClothes = {}
  for category, value in pairs(clothes) do
    newClothes[category] = value
    newClothes[category].comp = value?.hash or 0
  end
  local user = UserClass:get(source)
  local tints = UnJson(user.data.comptTints)
  for category, value in pairs(clothes) do
    if clothes.hash ~= 0 then
      if type(value) == "table" then
        tints[category] = {}
        if value.palette and value.palette ~= 0 then
          tints[category][value.hash] = {
            tint0 = value.tint0 or 0,
            tint1 = value.tint1 or 0,
            tint2 = value.tint2 or 0,
            palette = value.palette or 0,
          }
        end
        if value.state then
          tints[category][value.hash] = tints[category][value.hash] or {}
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

function FrameworkClass:getUserSkin(source)
  local user = UserClass:get(source)
  if not user then return {} end

  local skin = {}
  skin = UnJson(user.data.skin)

  local skinStandardized = self:standardizeSkin(skin)

  if not skinStandardized.teeth then
    local clothes = self:getUserClothes(source)
    if clothes.teeth then
      skinStandardized.teeth = clothes.teeth.hash
    end
  end

  return skinStandardized
end

function FrameworkClass:updateUserSkin(...)
  local args = { ... }
  local source, _skin, overwrite = args[1], {}, false

  if type(args[2]) == "string" then
    _skin = { [args[2]] = args[3] }
    overwrite = args[math.max(4, #args)] or overwrite
  else
    _skin = args[2]
    overwrite = args[math.max(3, #args)] or overwrite
  end
  local skin = self:revertSkin(_skin)

  if overwrite then
    TriggerClientEvent("vorpcharacter:updateCache", source, skin)
  else
    TriggerClientEvent("vorpcharacter:savenew", source, false, skin)
  end
end

function FrameworkClass:createUser(source, data, spawnCoordinate, isDead)
  if isDead == nil then isDead = false end
  spawnCoordinate = spawnCoordinate or vec4(2537.684, -1278.066, 49.218, 42.520)
  data = data or {}
  data.firstname = data.firstname or ""
  data.lastname = data.lastname or ""
  data.skin = self:revertSkin(data.skin)
  data.comps = self:revertClothes(data.comps)

  local convertData = {
    firstname = data.firstname or "",
    lastname = data.lastname or "",
    skin = json.encode(data.skin or {}),
    comps = json.encode(data.comps or {}),
    compTints = "[]",
    age = data.age,
    gender = data.skin.model == "mp_male" and "Male" or "Female",
    charDescription = data.charDescription or "",
    nickname = data.nickname or ""
  }
  self.core.getUser(source).addCharacter(convertData)
  TriggerClientEvent("vorp:initCharacter", source, spawnCoordinate.xyz, spawnCoordinate.w, isDead)
  SetTimeout(3000, function()
    TriggerEvent("vorp_NewCharacter", source)
  end)
end

return FrameworkClass
