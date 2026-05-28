-- -----------
-- FRAMEWORK CLASS
-- -----------

-------------
-- USER CLASS
-------------

--- Creates and returns a new User instance for the specified player
---@param source integer (The source ID of the player)
---@return UserClass (Return a User class object containing player data and methods)
function jo.framework.UserClass:get(source)
  self = table.copy(jo.framework.UserClass)
  self.source = tonumber(source)
  self.data = {}
  return self
end

--- Gets the amount of money a player has of the specified type
---@param moneyType integer (The type of currency: `0`: dollar, `1`: gold, `2`: rol )
---@return number (Return the amount for this kind of money)
function jo.framework.UserClass:getMoney(moneyType)
  return 0
end

--- Removes money from the player
---@param amount number (The amount of money to remove)
---@param moneyType integer (The type of currency: `0`: dollar, `1`: gold, `2`: rol )
function jo.framework.UserClass:removeMoney(amount, moneyType)
  return false
end

--- Adds money to the player
---@param amount number (The amount of money to add)
---@param moneyType integer (The type of currency: `0`: dollar, `1`: gold, `2`: rol)
function jo.framework.UserClass:addMoney(amount, moneyType)
  return false
end

--- Retrieves all identifiers associated with the player
---@return table (Return the player's identifiers <br> `identifiers.identifier` - Unique identifier of the player <br> `identifiers.charid` - Unique id of the player)
function jo.framework.UserClass:getIdentifiers()
  return {
    identifier = "",
    charid = 0
  }
end

--- Returns the current job assigned to a player
---@return string (Returns the job name of the player)
function jo.framework.UserClass:getJob()
  return ""
end

--- Returns the current job grade assigned to a player
---@return number (Returns the job grade of the player)
function jo.framework.UserClass:getJobGrade()
  return 0
end

--- Returns the roleplay name (first and last name) of the player
---@return string (Returns the formatted first and last name of the player)
function jo.framework.UserClass:getRPName()
  return ""
end

-- -----------
-- SKIN & CLOTHES
-- -----------

---A function to standardize the skin data
---@param skin table skin data with framework keys
---@return table skin skin data with standard keys
---@autodoc:config ignore:true
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
---@autodoc:config ignore:true
function jo.framework:revertSkinInternal(standard)
  return standard
end

---A function to standardize the clothes data
---@param clothes table standard clothes data
---@return table clothes framework clothes data
---@autodoc:config ignore:true
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
---@autodoc:config ignore:true
function jo.framework:revertClothesInternal(standard)
  return {}
end

---@autodoc:config ignore:true
function jo.framework:getUserClothesInternal(source)
  return {}
end

---@autodoc:config ignore:true
function jo.framework:updateUserClothesInternal(source, clothes, overwrite)
  return {}
end

---@autodoc:config ignore:true
function jo.framework:getUserSkinInternal(source)
  return {}
end

---@autodoc:config ignore:true
function jo.framework:updateUserSkinInternal(source, skin, overwrite)
  return {}
end

--- Creates a new player in the framework with specified data and spawn information
---@param source integer (The source ID of the player)
---@param data table (The user data to create)
---@param spawnCoordinate vector (The spawn location for the player)
---@param isDead? boolean (Whether the player starts as dead)
---@return table (Return the newly created user data)
---@autodoc:config ignore:true
function jo.framework:createUser(source, data, spawnCoordinate, isDead)
  return {}
end

-- Listener for item removed of the player inventory
RegisterNetEvent("event_item_removed", function(source, item, quantity, meta)
  jo.framework:fireListenerItemRemoved(source, item, quantity, meta, "dropped")
end)
