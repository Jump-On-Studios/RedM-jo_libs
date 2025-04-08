-------------
-- FRAMEWORK CLASS
-------------

-------------
-- INVENTORY
-------------

---@param source integer source ID
---@param item string name of the item
---@param amount integer amount to use
---@param meta table metadata of the item
---@param remove boolean if removed after used
function jo.framework:canUseItem(source, item, amount, meta, remove)
  return false
end

---@param item string name of the item
---@param callback function function fired when the item is used
---@param closeAfterUsed boolean if inventory needs to be closes
---@return boolean
function jo.framework:registerUseItem(item, closeAfterUsed, callback)
  return false
end

---@param source integer source ID
---@param item string name of the item
---@param quantity integer quantity
---@param meta table metadata of the item
---@return boolean
function jo.framework:giveItem(source, item, quantity, meta)
  return false
end

---@param invName string unique ID of the inventory
---@param name string name of the inventory
---@param invConfig table Configuration of the inventory
---@return boolean
function jo.framework:createInventory(invName, name, invConfig)
  return false
end

---@param invName string unique ID of the inventory
---@return boolean
function jo.framework:removeInventory(invName)
  return false
end

---@param source integer sourceIdentifier
---@param invName string name of the inventory
---@return boolean
function jo.framework:openInventory(source, invName)
  return false
end

---@param invId string unique ID of the inventory
---@param item string name of the item
---@param quantity integer quantity
---@param metadata table metadata of the item
---@param needWait? boolean wait after the adding
---@return boolean
function jo.framework:addItemInInventory(source, invId, item, quantity, metadata, needWait)
  return false
end

---@param invId string name of the inventory
---@return table
function jo.framework:getItemsFromInventory(invId)
  --[[ item structure
  {
    metadata = {},
    amount = 0,
    item = "itemName"
  }
  ]]
  return {}
end

-------------
-- END INVENTORY
-------------

-------------
-- SKIN & CLOTHES
-------------

---A function to standardize the skin data
---@param skin table skin data with framework keys
---@return table skin skin data with standard keys
function jo.framework:standardizeSkinInternal(skin)
  local standard = {}

  standard.model = table.extract(skin, "Sex")
  standard.headHash = table.extract(skin, "HeadType")
  standard.bodyUpperHash = table.extract(skin, "BodyType")
  standard.bodyLowerHash = table.extract(skin, "LegsType")
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

  standard.overlays = {
    ageing = {
      id = 0,
      opacity = 0.0
    },
    freckles = {
      id = 0,
      opacity = 0
    },
    moles = {
      id = 0,
      opacity = 0
    },
    scar = {
      id = 0,
      opacity = 0
    },
    spots = {
      id = 0,
      opacity = 0
    },
    acne = {
      id = 0,
      opacity = 0
    },
    grime = {
      id = 0,
      opacity = 0
    }
    ,
    hair = {
      id = 0,
      tint0 = 0,
      opacity = 0
    },
    complex = {
      id = 0,
      opacity = 0
    },
    disc = {
      id = 0,
      opacity = 0
    },
    beard = {
      id = 0,
      tint0 = 1,
      tint1 = 1,
      tint2 = 1,
      palette = "metaped_tint_makeup",
      opacity = 0.0
    },
    blush = {
      id = 0,
      tint0 = 0,
      opacity = 0.0
    },
    eyebrow = {
      id = 0,
      sexe = "male",
      tint0 = 1,
      tint1 = 1,
      tint2 = 1,
      palette = "metaped_tint_makeup",
      opacity = 0.0
    },
    eyeliner = {
      id = 0,
      sheetGrid = 0,
      tint0 = 0,
      opacity = 0.0
    },
    eyeshadow = {
      id = 0,
      sheetGrid = 0,
      tint0 = 0,
      tint1 = 0,
      tint2 = 0,
      palette = "metaped_tint_makeup",
      opacity = 0
    },
    lipstick = {
      id = 0,
      sheetGrid = 0,
      tint0 = 0,
      tint1 = 0,
      tint2 = 0,
      palette = "metaped_tint_makeup",
      opacity = 0
    },
    foundation = {
      id = 0,
      tint0 = 0,
      tint1 = 0,
      tint2 = 0,
      palette = "metaped_tint_makeup",
      sheetGrid = 0,
      opacity = 0
    },
    masks = {
      id = 0,
      tint0 = 0,
      tint1 = 0,
      tint2 = 0,
      palette = "metaped_tint_makeup",
      sheetGrid = 0,
      opacity = 0
    }
  }
  return standard
end

---A function to reversed the skin data
---@param standard table standard skin data
---@return table skin framework skin data
function jo.framework:revertSkinInternal(standard)
  return standard
end

---A function to standardize the clothes data
---@param clothes table standard clothes data
---@return table clothes framework clothes data
function jo.framework:standardizeClothesInternal(clothes)
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

---A function to revert a standardize clothes table
---@param standard table clothes with standard keys
---@return table clothes clothes with framework keys
function jo.framework:revertClothesInternal(standard)
  return {}
end

function jo.framework:getUserClothesInternal(source)
  return {}
end

function jo.framework:updateUserClothesInternal(source, clothes)
  return {}
end

function jo.framework:getUserSkinInternal(source)
  return {}
end

function jo.framework:updateUserSkinInternal(source, skin, overwrite)
  return {}
end

function jo.framework:createUser(source, data, spawnCoordinate, isDead)
  return {}
end
