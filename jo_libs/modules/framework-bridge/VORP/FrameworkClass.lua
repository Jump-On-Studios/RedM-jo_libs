local Core = exports.vorp_core:GetCore()
local Inventory = exports.vorp_inventory
local RegisteredInventories = {}
local CoreName = "VORP"

-------------
-- FRAMEWORK CLASS
-------------
---@class FrameworkClass : table Framework class
local FrameworkClass = {}

--- Initialize the framework
function FrameworkClass:init()
  bprint("VORP detected")
end

---@return string Name of the framework
function FrameworkClass:get()
  return CoreName
end

---@param name string Name of the framework
---@return boolean
function FrameworkClass:is(name)
  return self:get() == name
end

---@param source integer source ID
---@return any
function FrameworkClass:getUser(source)
  return UserClass:get(source)
end

---@param source integer source ID
---@return any identifiers
function FrameworkClass:getUserIdentifiers(source)
  local user = UserClass:get(source)
  if not user then return false end
  return user:getIdentifiers()
end

---@param source integer source ID
---@return any job Player job
function FrameworkClass:getUserJob(source)
  local user = UserClass:get(source)
  if not user then return false end
  return user.data.job
end

---@param source integer source ID
---@return string name Player name
function FrameworkClass:getUserRPName(source)
  local user = UserClass:get(source)
  if not user then return "" end
  return user:getRPName()
end

---@param source integer source ID
---@param moneyType? integer 0: money, 1:gold, 2: rol (default: 0)
---@return number money money amount
function FrameworkClass:getUserMoney(source, moneyType)
  local user = UserClass:get(source)
  if not user then return 0 end
  return user:getMoney(moneyType)
end

---@param source integer source ID
---@param amount number money  amount to check
---@param moneyType? integer 0: money, 1: gold, 2: rol (default: 0)
---@param removeIfCan? boolean (optinal) default : false
---@return boolean
function FrameworkClass:canUserBuy(source, amount, moneyType, removeIfCan)
  local user = UserClass:get(source)
  if not user then return false end
  return user:canBuy(source, amount, moneyType, removeIfCan)
end

---@param source integer
---@param amount number
---@param moneyType? integer 0: money, 1: gold, 2: rol
function FrameworkClass:addUserMoney(source, amount, moneyType)
  local user = UserClass:get(source)
  if not user then return false end
  return user:addMoney(source, amount, moneyType)
end

-------------
-- END MONEY
-------------

-------------
-- INVENTORY
-------------

---@param item string name of the item
---@param callback function function fired when the item is used
---@param closeAfterUsed boolean if inventory needs to be closes
function FrameworkClass:registerUsableItem(item, closeAfterUsed, callback)
  CreateThread(function()
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

---@param source integer source ID
---@param item string name of the item
---@param quantity integer quantity to use
---@param meta table metadata of the item
---@param remove boolean if removed after used
function FrameworkClass:canUserUserItem(source, item, quantity, meta, remove)
  local count = Inventory:getItemCount(source, nil, item, meta)
  if count >= quantity then
    if remove then
      return Inventory:subItem(source, item, quantity, meta)
    end
    return true
  end
  return false
end

---@param source integer source ID
---@param item string name of the item
---@param quantity integer quantity
---@param meta table metadata of the item
---@return boolean
function FrameworkClass:giveUserItem(source, item, quantity, meta)
  if Inventory:canCarryItem(source, item, quantity) then
    return Inventory:addItem(source, item, quantity, meta)
  end
  return false
end

---@param source integer source ID
---@param item string name of the item
---@param quantity integer quantity
---@param meta table metadata of the item
---@return boolean
function FrameworkClass:removeUserItem(source, item, quantity, meta)
  return Inventory:subItem(source, item, quantity, meta)
end

---@param invName string unique ID of the inventory
---@param name string name of the inventory
---@param invConfig table Configuration of the inventory
function FrameworkClass:createInventory(invName, name, invConfig)
  local config = invConfig or {}
  config.id = invName or invConfig.id
  config.name = name or invConfig.name
  config.limit = invConfig.maxSlots or invConfig.limit
  config.acceptWeapons = invConfig.acceptWeapons
  config.shared = invConfig.shared
  config.ignoreItemStackLimit = invConfig.ignoreStackLimit
  config.whitelistItems = invConfig.whitelist and true or false

  local whitelist = invConfig.whitelist
  invConfig.whitelist = nil

  Inventory:registerInventory(config)
  for _, data in pairs(whitelist or {}) do
    Inventory:setCustomInventoryItemLimit(invName, data.item, data.limit)
  end
end

---@param invName string unique ID of the inventory
function FrameworkClass:removeInventory(invName)
  Inventory:removeInventory(invName)
end

---@param source integer sourceIdentifier
---@param invName string name of the inventory
function FrameworkClass:openInventory(source, invName)
  if not Inventory:isCustomInventoryRegistered(invName) then
    return eprint("This inventory doesn't exist: ", invName)
  end
  return Inventory:openInventory(source, invName)
end

---@param invId string unique ID of the inventory
---@param item string name of the item
---@param quantity integer quantity
---@param metadata table metadata of the item
---@param needWait? boolean wait after the adding
function FrameworkClass:addItemInInventory(source, invId, item, quantity, metadata, needWait)
  local waiter = promise.new()
  local itemId = Inventory:getItemDB(item).id
  local user = UserClass:get(source)
  local charIdentifier = user.data.charIdentifier
  MySQL.insert("INSERT INTO items_crafted (character_id, item_id, metadata) VALUES (@charid, @itemid, @metadata)", {
    charid = charIdentifier,
    itemid = itemId,
    metadata = json.encode(metadata)
  }, function(id)
    MySQL.insert("INSERT INTO character_inventories (character_id, item_crafted_id, amount, inventory_type) VALUES (@charid, @itemid, @amount, @invId);", {
      charid = charIdentifier,
      itemid = id,
      amount = quantity,
      invId = invId
    }, function()
      waiter:resolve(true)
    end)
  end)
  if needWait then
    Citizen.Await(waiter)
  end
end

---@param source integer source ID
---@param invId string name of the inventory
---@return table items the list of item in this inventory
function FrameworkClass:getItemsFromInventory(source, invId)
  local items = MySQL.query.await("SELECT ci.character_id, ic.id, i.item, ci.amount, ic.metadata, ci.created_at FROM items_crafted ic\
      LEFT JOIN character_inventories ci on ic.id = ci.item_crafted_id\
      LEFT JOIN items i on ic.item_id = i.id\
      WHERE ci.inventory_type = @invType;",
    {
      ["invType"] = invId
    })
  local itemFiltered = {}
  for _, item in pairs(items) do
    itemFiltered[#itemFiltered + 1] = {
      metadata = UnJson(item.metadata),
      amount = item.amount,
      item = item.item,
      id = item.id
    }
  end
  return itemFiltered
end

-------------
-- END INVENTORY
-------------

-------------
-- SKIN & CLOTHES
-------------


local function convertToPercent(value)
  value = tonumber(value)
  if not value then return 0 end
  if value > 1 or value < -1 then
    return value / 100
  end
  return value
end

local function findKeyInList(list, key)
  list = list or {}
  if list[key] then return true, list[key] end
  local found, cat = table.find(list, function(cat, framCat) return framCat:lower() == key:lower() end)
  return found, cat
end

local function findValueInList(list, strandardValue)
  list = list or {}
  local value, key = table.find(list, function(category) return category:lower() == strandardValue:lower() end)
  return value, key
end

--- A function to standardize the category name
---@param category string the category name
local function standardizeSkinKey(category)
  local framName = jo.framework:get()
  if not skinCategoryBridge[framName] then return category end

  local found, key = findKeyInList(skinCategoryBridge[framName].components, category)
  if found then
    return key, "components"
  end
  found, key = findKeyInList(skinCategoryBridge[framName].expressions, category)
  if found then
    return key, "expressions"
  end
  return category, "components"
end

--- A function to revert the category name
local function revertSkinKey(category)
  local framName = jo.framework:get()
  if not skinCategoryBridge[framName] then return category end

  local found, key = findValueInList(skinCategoryBridge[framName].components, category)
  if found then
    return key, "components"
  end
  found, key = findValueInList(skinCategoryBridge[framName].expressions, category)
  if found then
    return key, "expressions"
  end
  return category, "components"
end

local function clearOverlaysTable(overlays)
  for layerName, overlay in pairs(overlays) do
    if overlay[1] then
      overlay = clearOverlaysTable(overlay)
    else
      if overlay.opacity == 0 then
        overlays[layerName] = nil
      end
    end
  end
end

---@param skin table Framework skin value
---@return table standard Skin value with standard keys
function FrameworkClass:standardizeSkin(skin)
  skin = table.copy(skin)
  local standard = {}

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
    id = skin.ageing_tx_id - 1,
    opacity = convertToPercent(skin.ageing_opacity)
  }
  skin.ageing_tx_id = nil
  skin.ageing_opacity = nil
  skin.ageing_visibility = nil

  standard.overlays.beard = needOverlay(skin.beardstabble_visibility) and {
    id = 1,
    tint0 = skin.beardstabble_color_primary,
    opacity = convertToPercent(skin.beardstabble_opacity)
  }
  skin.beardstabble_color_primary = nil
  skin.beardstabble_opacity = nil
  skin.beardstabble_visibility = nil

  standard.overlays.blush = needOverlay(skin.blush_visibility) and {
    id = skin.blush_tx_id - 1,
    tint0 = skin.blush_palette_color_primary,
    opacity = convertToPercent(skin.blush_opacity)
  }
  skin.blush_tx_id = nil
  skin.blush_palette_color_primary = nil
  skin.blush_opacity = nil
  skin.blush_visibility = nil

  standard.overlays.eyebrow = needOverlay(skin.eyebrows_visibility) and (function()
    local id = skin.eyebrows_tx_id - 1
    local sexe = "m"
    if id > 15 then
      id = id - 15
      sexe = "f"
    end
    return {
      id = id,
      sexe = sexe,
      tint0 = skin.eyebrows_color,
      sheetGrid = skin.eyebrows_palette_id - 1,
      opacity = convertToPercent(skin.eyebrows_opacity)
    }
  end)()
  skin.eyebrows_tx_id = nil
  skin.eyebrows_color = nil
  skin.eyebrows_palette_id = nil
  skin.eyebrows_opacity = nil
  skin.eyebrows_visibility = nil

  standard.overlays.eyeliner = needOverlay(skin.eyeliner_visibility) and {
    id = skin.eyeliner_tx_id - 1,
    sheetGrid = skin.eyeliner_palette_id - 1,
    tint0 = skin.eyeliner_color_primary,
    opacity = convertToPercent(skin.eyeliner_opacity)
  }
  skin.eyeliner_tx_id = nil
  skin.eyeliner_palette_id = nil
  skin.eyeliner_color_primary = nil
  skin.eyeliner_opacity = nil
  skin.eyeliner_visibility = nil

  standard.overlays.eyeshadow = needOverlay(skin.shadows_visibility) and {
    id = 1,
    sheetGrid = skin.shadows_palette_id - 1,
    tint0 = skin.shadows_palette_color_primary,
    tint1 = skin.shadows_palette_color_secondary,
    tint2 = skin.shadows_palette_color_tertiary,
    opacity = convertToPercent(skin.shadows_opacity)
  }
  skin.shadows_palette_id = nil
  skin.shadows_palette_color_primary = nil
  skin.shadows_palette_color_secondary = nil
  skin.shadows_palette_color_tertiary = nil
  skin.shadows_opacity = nil
  skin.shadows_visibility = nil

  standard.overlays.freckles = needOverlay(skin.freckles_visibility) and {
    id = skin.freckles_tx_id - 1,
    opacity = convertToPercent(skin.freckles_opacity)
  }
  skin.freckles_tx_id = nil
  skin.freckles_opacity = nil
  skin.freckles_visibility = nil

  standard.overlays.lipstick = needOverlay(skin.lipsticks_visibility) and {
    id = 1,
    sheetGrid = skin.lipsticks_palette_id - 1,
    tint0 = skin.lipsticks_palette_color_primary,
    tint1 = skin.lipsticks_palette_color_secondary,
    tint2 = skin.lipsticks_palette_color_tertiary,
    opacity = convertToPercent(skin.lipsticks_opacity)
  }
  skin.lipsticks_palette_id = nil
  skin.lipsticks_palette_color_primary = nil
  skin.lipsticks_palette_color_secondary = nil
  skin.lipsticks_palette_color_tertiary = nil
  skin.lipsticks_opacity = nil
  skin.lipsticks_visibility = nil

  standard.overlays.moles = needOverlay(skin.moles_visibility) and {
    id = skin.moles_tx_id - 1,
    opacity = convertToPercent(skin.moles_opacity)
  }
  skin.moles_tx_id = nil
  skin.moles_opacity = nil
  skin.moles_visibility = nil

  standard.overlays.scar = needOverlay(skin.scars_visibility) and {
    id = skin.scars_tx_id - 1,
    opacity = convertToPercent(skin.scars_opacity)
  }
  skin.scars_tx_id = nil
  skin.scars_opacity = nil
  skin.scars_visibility = nil

  standard.overlays.spots = needOverlay(skin.spots_visibility) and {
    id = skin.spots_tx_id - 1,
    opacity = convertToPercent(skin.spots_opacity)
  }
  skin.spots_tx_id = nil
  skin.spots_opacity = nil
  skin.spots_visibility = nil

  standard.overlays.acne = needOverlay(skin.acne_visibility) and {
    id = skin.acne_tx_id - 1,
    opacity = convertToPercent(skin.acne_opacity)
  }
  skin.acne_tx_id = nil
  skin.acne_opacity = nil
  skin.acne_visibility = nil

  standard.overlays.grime = needOverlay(skin.grime_visibility) and {
    id = skin.grime_tx_id - 1,
    opacity = convertToPercent(skin.grime_opacity)
  }
  skin.grime_tx_id = nil
  skin.grime_opacity = nil
  skin.grime_visibility = nil

  standard.overlays.hair = needOverlay(skin.hair_visibility) and {
    id = skin.hair_tx_id - 1,
    tint0 = skin.hair_color_primary,
    opacity = convertToPercent(skin.hair_opacity)
  }
  skin.hair_tx_id = nil
  skin.hair_color_primary = nil
  skin.hair_opacity = nil
  skin.hair_visibility = nil

  standard.overlays.complex = needOverlay(skin.complex_visibility) and {
    id = skin.complex_tx_id - 1,
    opacity = convertToPercent(skin.complex_opacity)
  }
  skin.complex_tx_id = nil
  skin.complex_opacity = nil
  skin.complex_visibility = nil

  standard.overlays.disc = needOverlay(skin.disc_visibility) and {
    id = skin.disc_tx_id - 1,
    opacity = convertToPercent(skin.disc_opacity)
  }
  skin.disc_tx_id = nil
  skin.disc_opacity = nil
  skin.disc_visibility = nil

  standard.overlays.foundation = needOverlay(skin.foundation_visibility) and {
    id = skin.foundation_tx_id - 1,
    tint0 = skin.foundation_palette_color_primary,
    tint1 = skin.foundation_palette_color_secondary,
    tint2 = skin.foundation_palette_color_tertiary,
    sheetGrid = skin.foundation_palette_id - 1,
    opacity = convertToPercent(skin.foundation_opacity)
  }
  skin.foundation_tx_id = nil
  skin.foundation_palette_color_primary = nil
  skin.foundation_palette_color_secondary = nil
  skin.foundation_palette_color_tertiary = nil
  skin.foundation_palette_id = nil
  skin.foundation_opacity = nil
  skin.foundation_visibility = nil

  standard.overlays.masks = needOverlay(skin.paintedmasks_visibility) and {
    id = skin.paintedmasks_tx_id - 1,
    tint0 = skin.paintedmasks_palette_color_primary,
    tint1 = skin.paintedmasks_palette_color_secondary,
    tint2 = skin.paintedmasks_palette_color_tertiary,
    sheetGrid = skin.paintedmasks_palette_id - 1,
    opacity = convertToPercent(skin.paintedmasks_opacity)
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


  if Config and Config.debug then
    if table.count(skin) > 0 then
      eprint("Skin keys not converted to standard")
      TriggerEvent("print", skin)
    else
      gprint("All skin keys standardized")
    end
  end

  standard = table.merge(standard, skin)

  --Clear overlays table
  standard.overlays = table.merge(standard.overlays, skin.overlays)
  standard.expressions = table.merge(standard.expressions, skin.expressions)

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

  return standard
end

---@param standard table Standard skin value
---@return table reverted Skin value with Framework keys
function FrameworkClass:revertSkin(standard)
  standard = table.copy(standard)

  local reverted = {}

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
    reverted.ageing_tx_id = standard.overlays.ageing.id + 1
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
    reverted.blush_tx_id = standard.overlays.blush.id + 1
    reverted.blush_palette_color_primary = standard.overlays.blush.tint0
    reverted.blush_opacity = standard.overlays.blush.opacity
    standard.overlays.blush.id = nil
    standard.overlays.blush.tint0 = nil
    standard.overlays.blush.opacity = nil
  end
  if standard.overlays.eyebrow then
    reverted.eyebrows_visibility = 1
    reverted.eyebrows_tx_id = standard.overlays.eyebrow.id + 1
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
    reverted.eyeliner_tx_id = standard.overlays.eyeliner.id + 1
    reverted.eyeliner_palette_id = standard.overlays.eyeliner.sheetGrid + 1
    reverted.eyeliner_color_primary = standard.overlays.eyeliner.tint0
    reverted.eyeliner_opacity = standard.overlays.eyeliner.opacity
    standard.overlays.eyeliner.id = nil
    standard.overlays.eyeliner.sheetGrid = nil
    standard.overlays.eyeliner.tint0 = nil
    standard.overlays.eyeliner.opacity = nil
  end
  if standard.overlays.eyeshadow then
    reverted.shadows_visibility = 1
    reverted.shadows_tx_id = standard.overlays.eyeshadow.id + 1
    reverted.shadows_palette_id = standard.overlays.eyeshadow.sheetGrid + 1
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
    reverted.freckles_tx_id = standard.overlays.freckles.id + 1
    reverted.freckles_opacity = standard.overlays.freckles.opacity
    standard.overlays.freckles.id = nil
    standard.overlays.freckles.opacity = nil
  end
  if standard.overlays.lipstick then
    reverted.lipsticks_visibility = 1
    reverted.lipsticks_tx_id = standard.overlays.lipstick.id + 1
    reverted.lipsticks_palette_id = standard.overlays.lipstick.sheetGrid + 1
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
    reverted.moles_tx_id = standard.overlays.moles.id + 1
    reverted.moles_opacity = standard.overlays.moles.opacity
    standard.overlays.moles.id = nil
    standard.overlays.moles.opacity = nil
  end
  if standard.overlays.scar then
    reverted.scars_visibility = 1
    reverted.scars_tx_id = standard.overlays.scar.id + 1
    reverted.scars_opacity = standard.overlays.scar.opacity
    standard.overlays.scar.id = nil
    standard.overlays.scar.opacity = nil
  end
  if standard.overlays.spots then
    reverted.spots_visibility = 1
    reverted.spots_tx_id = standard.overlays.spots.id + 1
    reverted.spots_opacity = standard.overlays.spots.opacity
    standard.overlays.spots.id = nil
    standard.overlays.spots.opacity = nil
  end
  if standard.overlays.acne then
    reverted.acne_visibility = 1
    reverted.acne_tx_id = standard.overlays.acne.id + 1
    reverted.acne_opacity = standard.overlays.acne.opacity
    standard.overlays.acne.id = nil
    standard.overlays.acne.opacity = nil
  end
  if standard.overlays.grime then
    reverted.grime_visibility = 1
    reverted.grime_tx_id = standard.overlays.grime.id + 1
    reverted.grime_opacity = standard.overlays.grime.opacity
    standard.overlays.grime.id = nil
    standard.overlays.grime.opacity = nil
  end
  if standard.overlays.hair then
    reverted.hair_visibility = 1
    reverted.hair_tx_id = standard.overlays.hair.id + 1
    reverted.hair_color_primary = standard.overlays.hair.tint0
    reverted.hair_opacity = standard.overlays.hair.opacity
    standard.overlays.hair.id = nil
    standard.overlays.hair.tint0 = nil
    standard.overlays.hair.opacity = nil
  end
  if standard.overlays.complex then
    reverted.complex_visibility = 1
    reverted.complex_tx_id = standard.overlays.complex.id + 1
    reverted.complex_opacity = standard.overlays.complex.opacity
    standard.overlays.complex.id = nil
    standard.overlays.complex.opacity = nil
  end
  if standard.overlays.disc then
    reverted.disc_visibility = 1
    reverted.disc_tx_id = standard.overlays.disc.id + 1
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
      TriggerEvent("print", standard)
    else
      gprint("All skin keys reverted")
    end
  end

  reverted.overlays = table.copy(standard.overlays)

  return reverted
end

---@param clothes table Standard clothes value
---@return table clothes Clothes value with Framework keys
function FrameworkClass:revertClothes(clothes)
  local reverted = {}
  for category, data in pairs(object) do
    reverted[revertSkinKey(category)] = table.copy(formatComponentData(data) or { hash = 0 })
  end
  return reverted
end

---@param clothes table Clothes value with Framework keys
---@return table clothes Standard clothes value
function FrameworkClass:standardizeClothes(clothes)
  local standard = {}

  object = convertClothesTableToObject(object)

  for catFram, data in pairs(object or {}) do
    standard[standardizeSkinKey(catFram)] = data
  end

  standard = cleanClothesTable(standard)

  return standard
end

---@param source interger The player server ID
---@return table clothes Standard clothes value
function FrameworkClass:getUserClothes(source)
  local user = UserClass:get(source)
  local clothes = UnJson(user.data.comps)
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

  if not clothes then return {} end

  local clothesStandardized = standardizeClothes(clothes)

  return clothesStandardized
end

---@param source string
---@param _clothes table with key = category
---@param value? table
function FrameworkClass:updateUserClothes(source, _clothes, value)
  if value then
    _clothes = { [_clothes] = formatComponentData(value) }
  end
  local newClothes = {}
  for category, value in pairs(clothes) do
    newClothes[category] = value
    newClothes[category].comp = value?.hash or 0
  end
  local user = User:get(source)
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

---@param source integer
---@return skin table User skin with standard keys
function FrameworkClass:getUserSkin(source)
  local user = UserClass:get(user)
  local skin = user.data.skin

  skin = UnJson(skin)

  local skinStandardized = standardizeSkin(skin)

  if not skinStandardized.teethHash or not skinStandardized.teethIndex then
    local clothes = self:getUserClothes(source)
    if clothes.teeth then
      skinStandardized.teethHash = clothes.teeth.hash
    end
  end

  return skinStandardized
end

---Can be used with 3 or 4 arguments
---@param source integer
---@param _skin any key = category, value = data OR category name if three parameters
---@param value? table if set, _skin is the category name
---@param overwrite? boolean if true, all skin data will be overwrited (default: false)
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
  local skin = revertSkin(_skin)
  if overwrite then
    TriggerClientEvent("vorpcharacter:updateCache", source, skin)
  else
    TriggerClientEvent("vorpcharacter:savenew", source, false, skin)
  end
end

---@param source interger server ID
---@param data table player data
---@param spawnCoordinate vec4 Location of the spawn
---@param isDead boolean if the player is dead
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
  Core.getUser(source).addCharacter(convertData)
  TriggerClientEvent("vorp:initCharacter", source, spawnCoordinate.xyz, spawnCoordinate.w, isDead)
  SetTimeout(3000, function()
    TriggerEvent("vorp_NewCharacter", source)
  end)
end

-------------
-- END SKIN & CLOTHES
-------------

return FrameworkClass
