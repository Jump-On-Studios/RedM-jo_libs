-------------
-- FRAMEWORK CLASS
-------------

FrameworkClass = FrameworkClass or {}
FrameworkClass.name = "RSG"
FrameworkClass.core = exports["rsg-core"]:GetCoreObject()
FrameworkClass.coreVersion = GetResourceMetadata("rsg-core", "version", 0) or 1
if ("2.0.0"):convertVersion() <= FrameworkClass.coreVersion:convertVersion() then
  FrameworkClass.inv = exports["rsg-inventory"]
  FrameworkClass.isV2 = true
  FrameworkClass.longName = "RSG V2 Framework"
else
  FrameworkClass.isV2 = false
  FrameworkClass.longName = "RSG V1 Framework"
end

-------------
-- VARIABLES
-------------

local inventoriesCreated = {}

-------------
-- INVENTORY
-------------

function FrameworkClass:canUseItem(source, item, amount, meta, remove)
  local Player = UserClass:get(source)
  local itemData = Player.data.Functions.GetItemByName(item)
  if itemData and itemData.amount >= amount then
    if remove then
      Player.data.Functions.RemoveItem(item, amount)
    end
    return true
  end
end

function FrameworkClass:registerUseItem(item, closeAfterUsed, callback)
  if self.isV2 then
    local isAdded = self.core.Functions.AddItem(item, nil)
    if isAdded then
      return eprint(item .. " < item does not exist in the core configuration")
    end
    self.core.Functions.CreateUseableItem(item, function(source, data)
      callback(source, { metadata = data.info })
      if closeAfterUsed then
        TriggerClientEvent("rsg-inventory:client:closeInv", source)
      end
    end)
  else
    local isAdded = self.core.Functions.AddItem(item, nil)
    if isAdded then
      return eprint(item .. " < item does not exist in the core configuration")
    end
    self.core.Functions.CreateUseableItem(item, function(source, data)
      callback(source, { metadata = data.info })
      if closeAfterUsed then
        TriggerClientEvent(string.lower(self:get()) .. "-inventory:client:closeinv", source)
      end
    end)
  end
end

function FrameworkClass:giveItem(source, item, quantity, meta)
  local Player = UserClass:get(source)
  return Player.data.Functions.AddItem(item, quantity, false, meta)
end

function FrameworkClass:createInventory(id, name, invConfig)
  inventoriesCreated[id] = {
    id = id,
    name = name,
    config = invConfig,
    inventory = {}
  }
  -------------
  -- RSG Inventory is defined in g, not kg
  -------------
  if inventoriesCreated[id].config.maxWeight then
    inventoriesCreated[id].config.maxWeight *= 1000
  end
end

function FrameworkClass:openInventory(source, id)
  local config = inventoriesCreated[id]
  if self.isV2 then
    local data = {
      label = config.name,
      maxweight = config.invConfig.maxWeight,
      slots = config.invConfig.maxSlots
    }
    self.inv:OpenInventory(source, id, data)
  else
    TriggerClientEvent(GetCurrentResourceName() .. ":client:openInventory", source, id, config)
    return
  end
end

function FrameworkClass:addItemInInventory(source, invId, item, quantity, metadata, needWait)
  if self.isV2 then
    self.inv:CreateInventory(invId)
    return self.inv:AddItem(invId, item, quantity, false, metadata)
  else
    local waiter = promise.new()
    MySQL.scalar("SELECT items FROM stashitems WHERE stash = ?", { invId }, function(items)
      items = UnJson(items)
      if not items then items = {} end
      local slot = 1
      repeat
        local doesSlotAvailable = true
        for _, item in pairs(items) do
          if item.slot == slot then
            slot = slot + 1
            doesSlotAvailable = false
            break
          end
        end
        Wait(100)
      until doesSlotAvailable
      items[#items + 1] = {
        amount = 1,
        name = item,
        info = metadata,
        slot = slot
      }
      MySQL.insert("INSERT INTO stashitems (stash,items) VALUES (@stash,@items) ON DUPLICATE KEY UPDATE items = @items", {
        stash = invId,
        items = json.encode(items)
      }, function()
        waiter:resolve(true)
      end)
      if needWait then
        return Citizen.Await(waiter)
      end
    end)
  end
end

function FrameworkClass:getItemsFromInventory(invId)
  if self.isV2 then
    local inventory = self.inv:GetInventory(invId) or { items = {} }
    local itemFiltered = {}
    for _, item in pairs(inventory.items) do
      itemFiltered[#itemFiltered + 1] = {
        metadata = item.info,
        amount = item.amount,
        item = item.name
      }
    end
  else
    local items = MySQL.scalar.await("SELECT items FROM stashitems WHERE stash = ?", { invId })
    items = UnJson(items)
    if not items then items = {} end
    local itemFiltered = {}
    for _, item in pairs(items) do
      itemFiltered[#itemFiltered + 1] = {
        metadata = item.info,
        amount = item.amount,
        item = item.name
      }
    end
    return itemFiltered
  end
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

  local skin_tone = { 1, 4, 3, 5, 2, 6 }
  local heads = {
    mp_male = { [16] = 18, [17] = 21, [18] = 22, [19] = 25, [20] = 28 },
    mp_female = { [17] = 20, [18] = 22, [19] = 27, [20] = 28 }
  }
  local bodies = { 2, 1, 3, 4, 5, 6 }

  standard.model = table.extract(object, "sex") == 2 and "mp_female" or "mp_male"
  standard.bodiesIndex = bodies[object.body_size] or object.body_size
  object.body_size = nil
  standard.eyesIndex = table.extract(object, "eyes_color")
  local head = object.head or 1
  object.head = nil
  standard.headIndex = heads[standard.model][math.ceil(head / 6)] or math.ceil(head / 6)
  standard.skinTone = skin_tone[table.extract(object, "skin_tone")]
  standard.teethIndex = table.extract(object, "teeth")
  standard.hair = table.extract(object, "hair")
  if standard.model == "mp_male" then
    standard.beards_complete = table.extract(object, "beard")
  end
  standard.bodyScale = convertToPercent(table.extract(object, "height"))
  standard.bodyWeight = table.extract(object, "body_waist")

  standard.expressions = {
    arms = table.extract(object, "arms_size"),
    calves = table.extract(object, "calves_size"),
    cheekbonesDepth = table.extract(object, "cheekbones_depth"),
    cheekbonesHeight = table.extract(object, "cheekbones_height"),
    cheekbonesWidth = table.extract(object, "cheekbones_width"),
    chest = table.extract(object, "chest_size"),
    chinDepth = table.extract(object, "chin_depth"),
    chinHeight = table.extract(object, "chin_height"),
    chinWidth = table.extract(object, "chin_width"),
    earlobes = table.extract(object, "earlobe_size"),
    earsAngle = table.extract(object, "ears_angle"),
    earsDepth = table.extract(object, "eyebrow_depth"),
    earsHeight = table.extract(object, "ears_height"),
    earsWidth = table.extract(object, "ears_width"),
    eyebrowDepth = table.extract(object, "face_depth"),
    eyebrowHeight = table.extract(object, "eyebrow_height"),
    eyebrowWidth = table.extract(object, "eyebrow_width"),
    eyelidHeight = table.extract(object, "eyelid_height"),
    eyelidLeft = table.extract(object, "eyelid_left"),
    eyelidRight = table.extract(object, "eyelid_right"),
    eyelidWidth = table.extract(object, "eyelid_width"),
    eyesAngle = table.extract(object, "eyes_angle"),
    eyesDepth = table.extract(object, "eyes_depth"),
    eyesDistance = table.extract(object, "eyes_distance"),
    eyesHeight = table.extract(object, "eyes_height"),
    faceWidth = table.extract(object, "face_width"),
    headWidth = table.extract(object, "head_width"),
    hip = table.extract(object, "hips_size"),
    jawDepth = table.extract(object, "jaw_depth"),
    jawHeight = table.extract(object, "jaw_height"),
    jawWidth = table.extract(object, "jaw_width"),
    jawY = table.extract(object, "jawY"),
    lowerLipDepth = table.extract(object, "lower_lip_depth"),
    lowerLipHeight = table.extract(object, "lower_lip_height"),
    lowerLipWidth = table.extract(object, "lower_lip_width"),
    mouthConerLeftDepth = table.extract(object, "mouth_corner_left_depth"),
    mouthConerLeftHeight = table.extract(object, "mouth_corner_left_height"),
    mouthConerLeftLipsDistance = table.extract(object, "mouth_corner_left_lips_distance"),
    mouthConerLeftWidth = table.extract(object, "mouth_corner_left_width"),
    mouthConerRightDepth = table.extract(object, "mouth_corner_right_depth"),
    mouthConerRightHeight = table.extract(object, "mouth_corner_right_height"),
    mouthConerRightLipsDistance = table.extract(object, "mouth_corner_right_lips_distance"),
    mouthConerRightWidth = table.extract(object, "mouth_corner_right_width"),
    mouthDepth = table.extract(object, "mouth_depth"),
    mouthWidth = table.extract(object, "mouth_width"),
    mouthX = table.extract(object, "mouth_x_pos"),
    mouthY = table.extract(object, "mouth_y_pos"),
    neckDepth = table.extract(object, "neck_depth"),
    neckWidth = table.extract(object, "neck_width"),
    noseAngle = table.extract(object, "nose_angle"),
    noseCurvature = table.extract(object, "nose_curvature"),
    noseHeight = table.extract(object, "nose_height"),
    noseSize = table.extract(object, "nose_size"),
    noseWidth = table.extract(object, "nose_width"),
    nostrilsDistance = table.extract(object, "nostrils_distance"),
    shoulderBlades = table.extract(object, "back_muscle"),
    shoulders = table.extract(object, "uppr_shoulder_size"),
    shoulderThickness = table.extract(object, "back_shoulder_thickness"),
    thighs = table.extract(object, "tight_size"),
    upperLipDepth = table.extract(object, "upper_lip_depth"),
    upperLipHeight = table.extract(object, "upper_lip_height"),
    upperLipWidth = table.extract(object, "upper_lip_width"),
    waist = table.extract(object, "waist_width"),
  }

  standard.overlays = {}
  standard.overlays.ageing = object.ageing_t and {
    id = decrease(object.ageing_t),
    opacity = convertToPercent(object.ageing_op)
  }
  object.ageing_t = nil
  object.ageing_op = nil

  standard.overlays.beard = object.beardstabble_t and {
    id = object.beardstabble_t,
    opacity = convertToPercent(object.beardstabble_op)
  }
  object.beardstabble_t = nil
  object.beardstabble_op = nil

  standard.overlays.blush = object.blush_t and {
    id = decrease(object.blush_t),
    palette = object.blush_id,
    tint0 = object.blush_c1,
    opacity = convertToPercent(object.blush_op)
  }
  object.blush_t = nil
  object.blush_id = nil
  object.blush_c1 = nil
  object.blush_op = nil

  standard.overlays.eyebrow = object.eyebrows_t and (function()
    local id = decrease(object.eyebrows_t)
    local sexe = "m"
    if id > 15 then
      id = id - 15
      sexe = "f"
    end
    return {
      id = id,
      sexe = sexe,
      palette = object.eyebrows_id,
      tint0 = object.eyebrows_c1,
      opacity = convertToPercent(object.eyebrows_op)
    }
  end)()
  object.eyebrows_t = nil
  object.eyebrows_id = nil
  object.eyebrows_c1 = nil
  object.eyebrows_op = nil

  standard.overlays.eyeliner = object.eyeliners_t and {
    id = 0,
    sheetGrid = decrease(object.eyeliners_t),
    palette = object.eyeliners_id,
    tint0 = object.eyeliners_c1,
    opacity = convertToPercent(object.eyeliners_op)
  }
  object.eyeliners_t = nil
  object.eyeliners_id = nil
  object.eyeliners_c1 = nil
  object.eyeliners_op = nil

  standard.overlays.eyeshadow = object.shadows_t and {
    id = 0,
    sheetGrid = decrease(object.shadows_t),
    palette = object.shadows_id,
    tint0 = object.shadows_c1,
    opacity = convertToPercent(object.shadows_op)
  }
  object.shadows_t = nil
  object.shadows_id = nil
  object.shadows_c1 = nil
  object.shadows_op = nil

  standard.overlays.freckles = object.freckles_t and {
    id = decrease(object.freckles_t),
    opacity = convertToPercent(object.freckles_op)
  }
  object.freckles_t = nil
  object.freckles_op = nil

  standard.overlays.lipstick = object.lipsticks_t and {
    id = 0,
    sheetGrid = decrease(object.lipsticks_t),
    palette = object.lipsticks_id,
    tint0 = object.lipsticks_c1,
    tint1 = object.lipsticks_c2,
    opacity = convertToPercent(object.lipsticks_op)
  }
  object.lipsticks_t = nil
  object.lipsticks_id = nil
  object.lipsticks_c1 = nil
  object.lipsticks_c2 = nil
  object.lipsticks_op = nil

  standard.overlays.moles = object.moles_t and {
    id = decrease(object.moles_t),
    opacity = convertToPercent(object.moles_op)
  }
  object.moles_t = nil
  object.moles_op = nil

  standard.overlays.scar = object.scars_t and {
    id = decrease(object.scars_t),
    opacity = convertToPercent(object.scars_op)
  }
  object.scars_t = nil
  object.scars_op = nil

  standard.overlays.spots = object.spots_t and {
    id = decrease(object.spots_t),
    opacity = convertToPercent(object.spots_op)
  }
  object.spots_t = nil
  object.spots_op = nil

  -- standard.overlays.acne = {},
  -- standard.overlays.foundation = {},
  -- standard.overlays.grime = {},
  -- standard.overlays.hair = {},
  -- standard.overlays.masks = {},
  -- standard.overlays.complex = {},
  -- standard.overlays.disc = {},

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

  local function revertPercent(value)
    if not value then return nil end
    return math.ceil((value) * 100)
  end

  local skin_tone = { 1, 4, 3, 5, 2, 6 }
  local heads = {
    mp_male = { [16] = 18, [17] = 21, [18] = 22, [19] = 25, [20] = 28 },
    mp_female = { [17] = 20, [18] = 22, [19] = 27, [20] = 28 }
  }
  local bodies = { 2, 1, 3, 4, 5, 6 }

  reverted.sex = standard.model == "mp_female" and 2 or 1
  _, reverted.body_size = table.find(bodies, function(value) return value == standard.bodiesIndex end)
  standard.bodiesIndex = nil
  reverted.eyes_color = table.extract(standard, "eyesIndex")
  _, reverted.head = table.find(heads[standard.model], function(value) return value == standard.headIndex end)
  reverted.head = (reverted.head or standard.headIndex) * 6
  standard.headIndex = nil
  _, reverted.skin_tone = table.find(skin_tone, function(value, i) return value == standard.skinTone end)
  standard.skinTone = nil
  reverted.teeth = table.extract(standard, "teethIndex")
  reverted.hair = table.extract(standard, "hair")
  if standard.model == "mp_male" then
    reverted.beard = table.extract(standard, "beards_complete")
  end
  reverted.height = revertPercent(table.extract(standard, "bodyScale"))
  reverted.body_waist = table.extract(standard, "bodyWeight")
  standard.model = nil

  reverted.arms_size = revertPercent(table.extract(standard.expressions, "arms"))
  reverted.calves_size = revertPercent(table.extract(standard.expressions, "calves"))
  reverted.cheekbones_depth = revertPercent(table.extract(standard.expressions, "cheekbonesDepth"))
  reverted.cheekbones_height = revertPercent(table.extract(standard.expressions, "cheekbonesHeight"))
  reverted.cheekbones_width = revertPercent(table.extract(standard.expressions, "cheekbonesWidth"))
  reverted.chest_size = revertPercent(table.extract(standard.expressions, "chest"))
  reverted.chin_depth = revertPercent(table.extract(standard.expressions, "chinDepth"))
  reverted.chin_height = revertPercent(table.extract(standard.expressions, "chinHeight"))
  reverted.chin_width = revertPercent(table.extract(standard.expressions, "chinWidth"))
  reverted.earlobe_size = revertPercent(table.extract(standard.expressions, "earlobes"))
  reverted.ears_angle = revertPercent(table.extract(standard.expressions, "earsAngle"))
  reverted.eyebrow_depth = revertPercent(table.extract(standard.expressions, "earsDepth"))
  reverted.ears_height = revertPercent(table.extract(standard.expressions, "earsHeight"))
  reverted.ears_width = revertPercent(table.extract(standard.expressions, "earsWidth"))
  reverted.face_depth = revertPercent(table.extract(standard.expressions, "eyebrowDepth"))
  reverted.eyebrow_height = revertPercent(table.extract(standard.expressions, "eyebrowHeight"))
  reverted.eyebrow_width = revertPercent(table.extract(standard.expressions, "eyebrowWidth"))
  reverted.eyelid_height = revertPercent(table.extract(standard.expressions, "eyelidHeight"))
  reverted.eyelid_left = revertPercent(table.extract(standard.expressions, "eyelidLeft"))
  reverted.eyelid_right = revertPercent(table.extract(standard.expressions, "eyelidRight"))
  reverted.eyelid_width = revertPercent(table.extract(standard.expressions, "eyelidWidth"))
  reverted.eyes_angle = revertPercent(table.extract(standard.expressions, "eyesAngle"))
  reverted.eyes_depth = revertPercent(table.extract(standard.expressions, "eyesDepth"))
  reverted.eyes_distance = revertPercent(table.extract(standard.expressions, "eyesDistance"))
  reverted.eyes_height = revertPercent(table.extract(standard.expressions, "eyesHeight"))
  reverted.face_width = revertPercent(table.extract(standard.expressions, "faceWidth"))
  reverted.head_width = revertPercent(table.extract(standard.expressions, "headWidth"))
  reverted.hips_size = revertPercent(table.extract(standard.expressions, "hip"))
  reverted.jaw_depth = revertPercent(table.extract(standard.expressions, "jawDepth"))
  reverted.jaw_height = revertPercent(table.extract(standard.expressions, "jawHeight"))
  reverted.jaw_width = revertPercent(table.extract(standard.expressions, "jawWidth"))
  reverted.jawY = revertPercent(table.extract(standard.expressions, "jawY"))
  reverted.lower_lip_depth = revertPercent(table.extract(standard.expressions, "lowerLipDepth"))
  reverted.lower_lip_height = revertPercent(table.extract(standard.expressions, "lowerLipHeight"))
  reverted.lower_lip_width = revertPercent(table.extract(standard.expressions, "lowerLipWidth"))
  reverted.mouth_corner_left_depth = revertPercent(table.extract(standard.expressions, "mouthConerLeftDepth"))
  reverted.mouth_corner_left_height = revertPercent(table.extract(standard.expressions, "mouthConerLeftHeight"))
  reverted.mouth_corner_left_lips_distance = revertPercent(table.extract(standard.expressions, "mouthConerLeftLipsDistance"))
  reverted.mouth_corner_left_width = revertPercent(table.extract(standard.expressions, "mouthConerLeftWidth"))
  reverted.mouth_corner_right_depth = revertPercent(table.extract(standard.expressions, "mouthConerRightDepth"))
  reverted.mouth_corner_right_height = revertPercent(table.extract(standard.expressions, "mouthConerRightHeight"))
  reverted.mouth_corner_right_lips_distance = revertPercent(table.extract(standard.expressions, "mouthConerRightLipsDistance"))
  reverted.mouth_corner_right_width = revertPercent(table.extract(standard.expressions, "mouthConerRightWidth"))
  reverted.mouth_depth = revertPercent(table.extract(standard.expressions, "mouthDepth"))
  reverted.mouth_width = revertPercent(table.extract(standard.expressions, "mouthWidth"))
  reverted.mouth_x_pos = revertPercent(table.extract(standard.expressions, "mouthX"))
  reverted.mouth_y_pos = revertPercent(table.extract(standard.expressions, "mouthY"))
  reverted.neck_depth = revertPercent(table.extract(standard.expressions, "neckDepth"))
  reverted.neck_width = revertPercent(table.extract(standard.expressions, "neckWidth"))
  reverted.nose_angle = revertPercent(table.extract(standard.expressions, "noseAngle"))
  reverted.nose_curvature = revertPercent(table.extract(standard.expressions, "noseCurvature"))
  reverted.nose_height = revertPercent(table.extract(standard.expressions, "noseHeight"))
  reverted.nose_size = revertPercent(table.extract(standard.expressions, "noseSize"))
  reverted.nose_width = revertPercent(table.extract(standard.expressions, "noseWidth"))
  reverted.nostrils_distance = revertPercent(table.extract(standard.expressions, "nostrilsDistance"))
  reverted.back_muscle = revertPercent(table.extract(standard.expressions, "shoulderBlades"))
  reverted.uppr_shoulder_size = revertPercent(table.extract(standard.expressions, "shoulders"))
  reverted.back_shoulder_thickness = revertPercent(table.extract(standard.expressions, "shoulderThickness"))
  reverted.tight_size = revertPercent(table.extract(standard.expressions, "thighs"))
  reverted.upper_lip_depth = revertPercent(table.extract(standard.expressions, "upperLipDepth"))
  reverted.upper_lip_height = revertPercent(table.extract(standard.expressions, "upperLipHeight"))
  reverted.upper_lip_width = revertPercent(table.extract(standard.expressions, "upperLipWidth"))
  reverted.waist_width = revertPercent(table.extract(standard.expressions, "waist"))

  if standard.overlays.ageing then
    reverted.ageing_t = increase(standard.overlays.ageing.id)
    reverted.ageing_op = revertPercent(standard.overlays.ageing.opacity)
    standard.overlays.ageing.id = nil
    standard.overlays.ageing.opacity = nil
  end
  if standard.overlays.beard then
    reverted.beardstabble_t = standard.overlays.beard.id
    reverted.beardstabble_op = revertPercent(standard.overlays.beard.opacity)
    standard.overlays.beard.id = nil
    standard.overlays.beard.opacity = nil
  end
  if standard.overlays.blush then
    reverted.blush_t = increase(standard.overlays.blush.id)
    reverted.blush_id = standard.overlays.blush.palette
    reverted.blush_c1 = standard.overlays.blush.tint0
    reverted.blush_op = revertPercent(standard.overlays.blush.opacity)
    standard.overlays.blush.id = nil
    standard.overlays.blush.palette = nil
    standard.overlays.blush.tint0 = nil
    standard.overlays.blush.opacity = nil
  end
  if standard.overlays.eyebrow then
    reverted.eyebrows_t = increase(standard.overlays.eyebrow.id)
    if standard.overlays.eyebrow.sexe == "f" then
      reverted.eyebrows_t = reverted.eyebrows_t + 15
    end
    reverted.eyebrows_id = standard.overlays.eyebrow.palette
    reverted.eyebrows_c1 = standard.overlays.eyebrow.tint0
    reverted.eyebrows_op = revertPercent(standard.overlays.eyebrow.opacity)
    standard.overlays.eyebrow.id = nil
    standard.overlays.eyebrow.palette = nil
    standard.overlays.eyebrow.tint0 = nil
    standard.overlays.eyebrow.opacity = nil
    standard.overlays.eyebrow.sexe = nil
  end
  if standard.overlays.eyeliner then
    reverted.eyeliners_t = increase(standard.overlays.eyeliner.sheetGrid)
    reverted.eyeliners_id = standard.overlays.eyeliner.palette
    reverted.eyeliners_c1 = standard.overlays.eyeliner.tint0
    reverted.eyeliners_op = revertPercent(standard.overlays.eyeliner.opacity)
    standard.overlays.eyeliner.sheetGrid = nil
    standard.overlays.eyeliner.palette = nil
    standard.overlays.eyeliner.tint0 = nil
    standard.overlays.eyeliner.opacity = nil
  end
  if standard.overlays.eyeshadow then
    reverted.shadows_t = increase(standard.overlays.eyeshadow.sheetGrid)
    reverted.shadows_id = standard.overlays.eyeshadow.palette
    reverted.shadows_c1 = standard.overlays.eyeshadow.tint0
    reverted.shadows_c2 = standard.overlays.eyeshadow.tint1
    reverted.shadows_c3 = standard.overlays.eyeshadow.tint2
    reverted.shadows_op = revertPercent(standard.overlays.eyeshadow.opacity)
    standard.overlays.eyeshadow.sheetGrid = nil
    standard.overlays.eyeshadow.palette = nil
    standard.overlays.eyeshadow.tint0 = nil
    standard.overlays.eyeshadow.tint1 = nil
    standard.overlays.eyeshadow.tint2 = nil
    standard.overlays.eyeshadow.opacity = nil
  end
  if standard.overlays.freckles then
    reverted.freckles_t = increase(standard.overlays.freckles.id)
    reverted.freckles_op = revertPercent(standard.overlays.freckles.opacity)
    standard.overlays.freckles.id = nil
    standard.overlays.freckles.opacity = nil
  end
  if standard.overlays.lipstick then
    reverted.lipsticks_t = increase(standard.overlays.lipstick.sheetGrid)
    reverted.lipsticks_id = standard.overlays.lipstick.palette
    reverted.lipsticks_c1 = standard.overlays.lipstick.tint0
    reverted.lipsticks_c2 = standard.overlays.lipstick.tint1
    reverted.lipsticks_c3 = standard.overlays.lipstick.tint2
    reverted.lipsticks_op = revertPercent(standard.overlays.lipstick.opacity)
    standard.overlays.lipstick.sheetGrid = nil
    standard.overlays.lipstick.palette = nil
    standard.overlays.lipstick.tint0 = nil
    standard.overlays.lipstick.tint1 = nil
    standard.overlays.lipstick.tint2 = nil
    standard.overlays.lipstick.opacity = nil
  end
  if standard.overlays.moles then
    reverted.moles_t = increase(standard.overlays.moles.id)
    reverted.moles_op = revertPercent(standard.overlays.moles.opacity)
    standard.overlays.moles.id = nil
    standard.overlays.moles.opacity = nil
  end
  if standard.overlays.scar then
    reverted.scars_t = increase(standard.overlays.scar.id)
    reverted.scars_op = revertPercent(standard.overlays.scar.opacity)
    standard.overlays.scar.id = nil
    standard.overlays.scar.opacity = nil
  end
  if standard.overlays.spots then
    reverted.spots_t = increase(standard.overlays.spots.id)
    reverted.spots_op = revertPercent(standard.overlays.spots.opacity)
    standard.overlays.spots.id = nil
    standard.overlays.spots.opacity = nil
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

  if jo.debug then
    if table.count(standard) > 0 then
      eprint("Skin keys not reverted")
      for key, value in pairs(standard) do
        print(key, type(value) == "table" and json.encode(value) or value)
      end
    else
      gprint("All skin keys reverted")
    end
  end

  return reverted
end

function FrameworkClass:getUserClothes(source)
  local user = self:getUserIdentifiers(source)
  local clothes = MySQL.scalar.await("SELECT clothes FROM playerskins WHERE citizenid=?", { user.identifier })

  if not clothes then return {} end
  clothes = UnJson(clothes)

  local clothesStandardized = self:standardizeClothes(clothes)

  return clothesStandardized
end

function FrameworkClass:updateUserClothes(source, _clothes, value)
  if value then
    _clothes = { [_clothes] = formatComponentData(value) }
  end
  local clothes = self:revertClothes(_clothes)

  local identifiers = self:getUserIdentifiers(source)
  MySQL.scalar("SELECT clothes FROM playerskins WHERE citizenid=? ", { identifiers.identifier }, function(oldClothes)
    local decoded = UnJson(oldClothes)
    table.merge(decoded, clothes)
    MySQL.update("UPDATE playerskins SET clothes=? WHERE citizenid=?", { json.encode(decoded), identifiers.identifier })
  end)
end

function Framework:getUserSkin(source)
  local user = UserClass:get(source)
  local identifiers = user:getIdentifiers()

  local skin = MySQL.scalar.await("SELECT skin FROM playerskins WHERE citizenid=?", { identifiers.identifier })

  skin = UnJson(skin)

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
  local args = table.pack(...)
  local source, _skin, overwrite = args[1], {}, false

  if type(args[2]) == "string" then
    _skin = { [args[2]] = args[3] }
    overwrite = args[math.max(4, #args)] or overwrite
  else
    _skin = args[2]
    overwrite = args[math.max(3, #args)] or overwrite
  end
  local skin = self:revertSkin(_skin)
  local identifiers = self:getUserIdentifiers(source)
  if overwrite then
    MySQL.update("UPDATE playerskins SET skin=? WHERE citizenid=?", { json.encode(skin), identifiers.identifier })
  else
    MySQL.scalar("SELECT skin FROM playerskins WHERE citizenid=?", { identifiers.identifier }, function(oldSkin)
      local decoded = UnJson(oldSkin)
      table.merge(decoded, skin)
      MySQL.update("UPDATE playerskins SET skin=? WHERE citizenid=?", { json.encode(decoded), identifiers.identifier })
    end)
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
    source = source,
    charinfo = {
      firstname = data.firstname or "",
      lastname = data.lastname,
      gender = data.skin.sex == 1 and "0" or "1"
    }
  }
  self.core.Player.CheckPlayerData(source, convertData)
  jo.triggerEvent.server(source, "rsg-appearance:server:SaveSkin", data.skin, data.comps)
end

-------------
-- END SKIN & CLOTHES
-------------


return FrameworkClass
