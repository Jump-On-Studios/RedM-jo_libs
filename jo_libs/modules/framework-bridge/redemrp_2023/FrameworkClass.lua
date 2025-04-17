-------------
-- FRAMEWORK CLASS
-------------
local RedEM = exports["redem_roleplay"]:RedEM()
local Inventory

jo.framework.core = RedEM

TriggerEvent("redemrp_inventory:getData", function(call)
  Inventory = call
  jo.framework.inv = Inventory
end)

-------------
-- VARIABLES
-------------

local inventories = {}
local fromFrameworkToStandard = {
  skin_tone = { 1, 4, 3, 5, 2, 6 },
  heads = {
    mp_male = { [16] = 18, [17] = 21, [18] = 22, [19] = 25, [20] = 28 },
    mp_female = { [17] = 20, [18] = 22, [19] = 27, [20] = 28 }
  },
  bodies = { 2, 1, 3, 4, 5, 6 },
  ov_eyebrows = {
    [1] = { id = 0x07844317, standard = { sexe = "m", id = 012 } },
    [2] = { id = 0x0A83CA6E, standard = { sexe = "m", id = 006 } },
    [3] = { id = 0x139A5CA3, standard = { sexe = "m", id = 003 } },
    [4] = { id = 0x1832E474, standard = { sexe = "m", id = 011 } },
    [5] = { id = 0x216EF84C, standard = { sexe = "m", id = 002 } },
    [6] = { id = 0x2594304D, standard = { sexe = "f", id = 004 } },
    [7] = { id = 0x33C39BC5, standard = { sexe = "m", id = 013 } },
    [8] = { id = 0x443E3CBA, standard = { sexe = "m", id = 014 } },
    [9] = { id = 0x4F5052DE, standard = { sexe = "m", id = 015 } },
    [10] = { id = 0x5C049D35, standard = { sexe = "f", id = 001 } },
    [11] = { id = 0x77A1546E, standard = { sexe = "f", id = 003 } },
    [12] = { id = 0x8A4B79C2, standard = { sexe = "f", id = 002 } },
    [13] = { id = 0x9728137B, standard = { sexe = "f", id = 006 } },
    [14] = { id = 0xA6DE8325, standard = { sexe = "m", id = 008 } },
    [15] = { id = 0xA8CCB6C4, standard = { sexe = "f", id = 005 } },
    [16] = { id = 0xB3F74D19, standard = { sexe = "f", id = 007 } },
    [17] = { id = 0xBD38AFD9, standard = { sexe = "m", id = 007 } },
    [18] = { id = 0xCD0A4F7C, standard = { sexe = "m", id = 009 } },
    [19] = { id = 0xD0EC86FF, standard = { sexe = "f", id = 000 } },
    [20] = { id = 0xEB088A20, standard = { sexe = "m", id = 010 } },
    [21] = { id = 0xF0CA96FC, standard = { sexe = "m", id = 005 } },
    [22] = { id = 0xF3351BD9, standard = { sexe = "m", id = 001 } },
    [23] = { id = 0xF9052779, standard = { sexe = "m", id = 000 } },
    [24] = { id = 0xFE183197, standard = { sexe = "m", id = 004 } },
  },
  ov_scars = {
    [1] = { id = 0xC8E45B5B, standard = { id = 000 } },
    [2] = { id = 0x90D86B44, standard = { id = 001 } },
    [3] = { id = 0x23190FC3, standard = { id = 002 } },
    [4] = { id = 0x7574B47D, standard = { id = 003 } },
    [5] = { id = 0x7FE8C965, standard = { id = 004 } },
    [6] = { id = 0x083059FE, standard = { id = 005 } },
    [7] = { id = 0x19E9FD71, standard = { id = 006 } },
    [8] = { id = 0x4CAF62FB, standard = { id = 007 } },
    [9] = { id = 0xDE650668, standard = { id = 008 } },
    [10] = { id = 0xC648562B, standard = { id = 009 } },
    [11] = { id = 0x484BAEF8, standard = { id = 010 } },
    [12] = { id = 0x190F5080, standard = { id = 011 } },
    [13] = { id = 0x2B5DF51D, standard = { id = 012 } },
    [14] = { id = 0xE490E784, standard = { id = 013 } },
    [15] = { id = 0x0ED23C06, standard = { id = 014 } },
    [16] = { id = 0x5712CCB6, standard = { id = 015 } },
  },
  ov_eyeliners = {
    [1] = { id = 0x29A2E58F, standard = { id = 0 } },
  },
  ov_lipsticks = {
    [1] = { id = 0x887E11E0, standard = { id = 0 } },
  },
  ov_acne = {
    [1] = { id = 0x96DD8F42, standard = { id = 0 } },
  },
  ov_shadows = {
    [1] = { id = 0x47BD7289, standard = { id = 0 } },
  },
  ov_beardstabble = {
    [1] = { id = 0x375D4807, standard = { id = 0 } },
  },
  ov_paintedmasks = {
    [1] = { id = 0x5995AA6F, standard = { id = 0 } },
  },
  ov_ageing = {
    -- [1] = { id = 0x96DD8F42, standard = { id = 000 } },
    [2] = { id = 0x6D9DC405, standard = { id = 000 } },
    [3] = { id = 0x2761B792, standard = { id = 001 } },
    [4] = { id = 0x19009AD0, standard = { id = 002 } },
    [5] = { id = 0xC29F6E07, standard = { id = 003 } },
    [6] = { id = 0xA45F3187, standard = { id = 004 } },
    [7] = { id = 0x5E21250C, standard = { id = 005 } },
    [8] = { id = 0x4FFE08C6, standard = { id = 006 } },
    [9] = { id = 0x2DAD4485, standard = { id = 007 } },
    [10] = { id = 0x3F70680B, standard = { id = 008 } },
    [11] = { id = 0xD3310F8E, standard = { id = 009 } },
    [12] = { id = 0xF27A4C84, standard = { id = 010 } },
    [13] = { id = 0x0044E819, standard = { id = 011 } },
    [14] = { id = 0xA648348D, standard = { id = 012 } },
    [15] = { id = 0x94F991F0, standard = { id = 013 } },
    [16] = { id = 0xCAACFD56, standard = { id = 014 } },
    [17] = { id = 0xB9675ACB, standard = { id = 015 } },
    [18] = { id = 0x3C2CE03C, standard = { id = 016 } },
    [19] = { id = 0xF2D64D90, standard = { id = 016 } },
    [20] = { id = 0xE389AEF7, standard = { id = 018 } },
    [21] = { id = 0x89317A44, standard = { id = 019 } },
    [22] = { id = 0x64B3347C, standard = { id = 020 } },
    [23] = { id = 0x9FFDAB10, standard = { id = 021 } },
    [24] = { id = 0x91D40EBD, standard = { id = 022 } },
    [25] = { id = 0x6B94C23F, standard = { id = 023 } },
  },
  ov_blush = {
    [1] = { id = 0x6DB440FA, standard = { id = 000 } },
    [2] = { id = 0x47617455, standard = { id = 001 } },
    [3] = { id = 0x114D082D, standard = { id = 002 } },
    [4] = { id = 0xEC6F3E72, standard = { id = 003 } },
  },
  ov_complex = {
    [1] = { id = 0xF679EDE7, standard = { id = 000 } },
    [2] = { id = 0x3FFB80ED, standard = { id = 001 } },
    [3] = { id = 0x31C0E478, standard = { id = 002 } },
    [4] = { id = 0x2457C9A6, standard = { id = 003 } },
    [5] = { id = 0x16262D43, standard = { id = 004 } },
    [6] = { id = 0x88F312DB, standard = { id = 005 } },
    [7] = { id = 0x785C71AE, standard = { id = 006 } },
    [8] = { id = 0x6D7D5BF0, standard = { id = 007 } },
    [9] = { id = 0x5F2FBF55, standard = { id = 008 } },
    [10] = { id = 0xBF38FF6A, standard = { id = 009 } },
    [11] = { id = 0xF5656C26, standard = { id = 010 } },
    [12] = { id = 0x03A408A3, standard = { id = 011 } },
    [13] = { id = 0x293453C3, standard = { id = 012 } },
    [14] = { id = 0x43150800, standard = { id = 013 } },
  },
  ov_disc = {
    [1] = { id = 0xD44A5ABA, standard = { id = 000 } },
    [2] = { id = 0xE2CF77C4, standard = { id = 001 } },
    [3] = { id = 0xCF57D0E9, standard = { id = 002 } },
    [4] = { id = 0xE0A8738A, standard = { id = 003 } },
    [5] = { id = 0xABD109DC, standard = { id = 004 } },
    [6] = { id = 0xB91C2472, standard = { id = 005 } },
    [7] = { id = 0x894844B7, standard = { id = 006 } },
    [8] = { id = 0x96FAE01C, standard = { id = 007 } },
    [9] = { id = 0x86D3BFCE, standard = { id = 008 } },
    [10] = { id = 0x5488DB39, standard = { id = 009 } },
    [11] = { id = 0x7DA5A5AE, standard = { id = 010 } },
    [12] = { id = 0xE73778DC, standard = { id = 011 } },
    [13] = { id = 0xD83EDADF, standard = { id = 012 } },
    [14] = { id = 0xE380F163, standard = { id = 013 } },
    [15] = { id = 0xB4611324, standard = { id = 014 } },
    [16] = { id = 0xC6ABB7B9, standard = { id = 015 } },
  },
  ov_foundation = {
    [1] = { id = 0xEF5AB280, standard = { id = 000 } },
  },
  ov_freckles = {
    [1] = { id = 0x1B794C51, standard = { id = 000 } },
    [2] = { id = 0x29BFE8DE, standard = { id = 001 } },
    [3] = { id = 0x0EF6B34C, standard = { id = 002 } },
    [4] = { id = 0x64925E7E, standard = { id = 003 } },
    [5] = { id = 0xF5F280FC, standard = { id = 004 } },
    [6] = { id = 0x33B0FC78, standard = { id = 005 } },
    [7] = { id = 0x25675FE5, standard = { id = 006 } },
    [8] = { id = 0xD10F3736, standard = { id = 007 } },
    [9] = { id = 0x5126B75F, standard = { id = 008 } },
    [10] = { id = 0x6B8EEC2F, standard = { id = 009 } },
    [11] = { id = 0x0A9A26F7, standard = { id = 010 } },
    [12] = { id = 0xFDE40D8B, standard = { id = 011 } },
    [13] = { id = 0x7E338E44, standard = { id = 012 } },
    [14] = { id = 0x70F273C2, standard = { id = 013 } },
    [15] = { id = 0x61C7D56D, standard = { id = 014 } },
  },
  ov_grime = {
    [1] = { id = 0xA2F30923, standard = { id = 000 } },
    [2] = { id = 0xD5B1EEA0, standard = { id = 001 } },
    [3] = { id = 0x7EC740CC, standard = { id = 002 } },
    [4] = { id = 0xB08F245B, standard = { id = 003 } },
    [5] = { id = 0x1A5E77F8, standard = { id = 004 } },
    [6] = { id = 0xE81B9373, standard = { id = 005 } },
    [7] = { id = 0x3CFA3D2F, standard = { id = 006 } },
    [8] = { id = 0x0B865A48, standard = { id = 007 } },
    [9] = { id = 0x506DE416, standard = { id = 008 } },
    [10] = { id = 0x1F250185, standard = { id = 009 } },
    [11] = { id = 0xE71930B0, standard = { id = 010 } },
    [12] = { id = 0xDE571F2C, standard = { id = 011 } },
    [13] = { id = 0x0CA6FBCB, standard = { id = 012 } },
    [14] = { id = 0x21F62669, standard = { id = 013 } },
    [15] = { id = 0xFB09D881, standard = { id = 014 } },
    [16] = { id = 0x11530513, standard = { id = 015 } },
  },
  ov_hair = {
    [1] = { id = 0x39051515, standard = { id = 000 } },
    [2] = { id = 0x5E71DFEE, standard = { id = 002 } },
    [3] = { id = 0xDD735DEF, standard = { id = 009 } },
    -- [] = { id = 0x69622EAD, standard = {id =}},
  },
  ov_moles = {
    [1] = { id = 0x821FD077, standard = { id = 000 } },
    [2] = { id = 0xCD38E6A8, standard = { id = 001 } },
    [3] = { id = 0x9F9D8B72, standard = { id = 002 } },
    [4] = { id = 0xE7179A39, standard = { id = 003 } },
    [5] = { id = 0xBB094249, standard = { id = 004 } },
    [6] = { id = 0x03AC5362, standard = { id = 005 } },
    [7] = { id = 0x154FF6A9, standard = { id = 006 } },
    [8] = { id = 0x1E23084F, standard = { id = 007 } },
    [9] = { id = 0x31DBAFC0, standard = { id = 008 } },
    [10] = { id = 0x3AC5C194, standard = { id = 009 } },
    [11] = { id = 0x4500D516, standard = { id = 010 } },
    [12] = { id = 0x3695B840, standard = { id = 011 } },
    [13] = { id = 0x286C1BED, standard = { id = 012 } },
    [14] = { id = 0x934BF1AF, standard = { id = 013 } },
    [15] = { id = 0x84F55502, standard = { id = 014 } },
    [16] = { id = 0xBD9A464B, standard = { id = 015 } },
  },
  ov_spots = {
    [1] = { id = 0x5BBFF5F7, standard = { id = 000 } },
    [2] = { id = 0x65EC0A4F, standard = { id = 001 } },
    [3] = { id = 0x3F143CA0, standard = { id = 002 } },
    [4] = { id = 0x49675146, standard = { id = 003 } },
    [5] = { id = 0x07504D2D, standard = { id = 004 } },
    [6] = { id = 0xF161214F, standard = { id = 005 } },
    [7] = { id = 0xE43286F2, standard = { id = 006 } },
    [8] = { id = 0xDDDC7A46, standard = { id = 007 } },
    [9] = { id = 0xD086DF9B, standard = { id = 008 } },
    [10] = { id = 0xBA51B331, standard = { id = 009 } },
    [11] = { id = 0xE4CF097B, standard = { id = 010 } },
    [12] = { id = 0xF70CADF6, standard = { id = 011 } },
    [13] = { id = 0xC07F40DC, standard = { id = 012 } },
    [14] = { id = 0xD3B1E741, standard = { id = 013 } },
    [15] = { id = 0xB494A903, standard = { id = 014 } },
    [16] = { id = 0xC6EE4DB6, standard = { id = 015 } },
  },
}

local function getStandardValuefromFramework(category, id)
  if not fromFrameworkToStandard[category]?[id] then return false end
  return fromFrameworkToStandard[category][id].standard
end

local function getFrameworkValueFromStandard(category, data)
  if not fromFrameworkToStandard[category] then return false end
  if type(fromFrameworkToStandard[category]) ~= "table" then return false end
  if table.type(fromFrameworkToStandard[category]) ~= "hash" then return false end
  return table.find(fromFrameworkToStandard[category], function(value)
    return table.isEgal(value.standard, data, false, true, true)
  end)
end

-------------
-- END VARIABLES
-------------

-------------
-- INVENTORY
-------------

---@param source integer source ID
---@param item string name of the item
---@param amount integer amount to use
---@param meta? table metadata of the item (default: nil)
---@param remove? boolean if removed after used (default: false)
function jo.framework:canUseItem(source, item, amount, meta, remove)
  remove = GetValue(remove, false)
  local itemData = Inventory.getItem(source, item, meta)
  if itemData and itemData.ItemAmount >= amount then
    if remove then
      itemData.RemoveItem(amount)
    end
    return true
  end
  return false
end

---@param item string name of the item
---@param callback function function fired when the item is used
---@param closeAfterUsed? boolean if inventory needs to be closes (default: true)
---@return boolean
function jo.framework:registerUseItem(item, closeAfterUsed, callback)
  if not item then return false, eprint("Item has to be defined") end
  if not callback then return false, eprint("Callback has to be defined") end
  closeAfterUsed = GetValue(closeAfterUsed, true)
  local isExist = Inventory.getItemData(item)
  if not isExist then
    return false, eprint(item .. " < item does not exist in the inventory configuration")
  end
  AddEventHandler("RegisterUsableItem:" .. item, function(source, data)
    callback(source, { metadata = data.meta })
    if closeAfterUsed then
      TriggerClientEvent("redemrp_inventory:closeinv", source)
    end
  end)
  return false
end

---@param source integer source ID
---@param item string name of the item
---@param quantity integer quantity
---@param meta table metadata of the item
---@return boolean
function jo.framework:giveItem(source, item, quantity, meta)
  local ItemData = Inventory.getItem(source, item, meta)
  return ItemData?.AddItem(quantity, meta)
end

---@param invName string unique ID of the inventory
---@param name string name of the inventory
---@param invConfig table Configuration of the inventory
---@return boolean
function jo.framework:createInventory(invName, name, invConfig)
  inventories[invName] = {
    id = invName,
    name = name,
    config = invConfig
  }
  return true
end

---@param invName string unique ID of the inventory
---@return boolean
function jo.framework:removeInventory(invName)
  return true
end

---@param source integer sourceIdentifier
---@param invName string name of the inventory
---@return boolean
function jo.framework:openInventory(source, invName)
  local config = inventories[invName]?.config
  TriggerClientEvent("redemrp_inventory:OpenStash", source, invName, config.maxWeight)
  return true
end

---@param invName string unique ID of the inventory
---@param item string name of the item
---@param quantity integer quantity
---@param metadata table metadata of the item
---@param needWait? boolean wait after the adding
---@return boolean
function jo.framework:addItemInInventory(source, invName, item, quantity, metadata, needWait)
  return Inventory.addItemStash(source, item, quantity, metadata, invName)
end

---@param invName string name of the inventory
---@return table
function jo.framework:getItemsFromInventory(invId)
  local invItems = Inventory.getStash(invId)
  if not invItems then return {} end
  local items = {}
  for i = 1, #invItems do
    items[i] = {
      metadata = invItems[i].meta,
      amount = invItems[i].amount,
      item = invItems[i].name
    }
  end
  return items
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

  local function decrease(value)
    return GetValue(value, 1) - 1
  end

  standard.model = table.extract(skin, "sex") == 2 and "mp_female" or "mp_male"
  standard.bodiesIndex = GetValue(fromFrameworkToStandard.bodies[skin.body_size], skin.body_size)
  skin.body_size = nil
  standard.eyesIndex = table.extract(skin, "eyes_color")
  local head = GetValue(skin.head, 1)
  skin.head = nil
  standard.headIndex = GetValue(fromFrameworkToStandard.heads[standard.model][math.ceil(head / 6)], math.ceil(head / 6))
  standard.skinTone = fromFrameworkToStandard.skin_tone[table.extract(skin, "skin_tone")]
  standard.teethIndex = table.extract(skin, "teeth")
  standard.hair = table.extract(skin, "hair")
  if standard.model == "mp_male" then
    standard.beards_complete = table.extract(skin, "beard")
  end
  standard.bodyScale = self:convertToPercent(table.extract(skin, "height"))
  standard.bodyWeight = table.extract(skin, "body_waist")

  standard.expressions = {
    arms = table.extract(skin, "arms_size"),
    calves = table.extract(skin, "calves_size"),
    cheekbonesDepth = table.extract(skin, "cheekbones_depth"),
    cheekbonesHeight = table.extract(skin, "cheekbones_height"),
    cheekbonesWidth = table.extract(skin, "cheekbones_width"),
    chest = table.extract(skin, "chest_size"),
    chinDepth = table.extract(skin, "chin_depth"),
    chinHeight = table.extract(skin, "chin_height"),
    chinWidth = table.extract(skin, "chin_width"),
    earlobes = table.extract(skin, "earlobe_size"),
    earsAngle = table.extract(skin, "ears_angle"),
    earsDepth = table.extract(skin, "eyebrow_depth"),
    earsHeight = table.extract(skin, "ears_height"),
    earsWidth = table.extract(skin, "ears_width"),
    eyebrowDepth = table.extract(skin, "face_depth"),
    eyebrowHeight = table.extract(skin, "eyebrow_height"),
    eyebrowWidth = table.extract(skin, "eyebrow_width"),
    eyelidHeight = table.extract(skin, "eyelid_height"),
    eyelidLeft = table.extract(skin, "eyelid_left"),
    eyelidRight = table.extract(skin, "eyelid_right"),
    eyelidWidth = table.extract(skin, "eyelid_width"),
    eyesAngle = table.extract(skin, "eyes_angle"),
    eyesDepth = table.extract(skin, "eyes_depth"),
    eyesDistance = table.extract(skin, "eyes_distance"),
    eyesHeight = table.extract(skin, "eyes_height"),
    faceWidth = table.extract(skin, "face_width"),
    headWidth = table.extract(skin, "head_width"),
    hip = table.extract(skin, "hips_size"),
    jawDepth = table.extract(skin, "jaw_depth"),
    jawHeight = table.extract(skin, "jaw_height"),
    jawWidth = table.extract(skin, "jaw_width"),
    jawY = table.extract(skin, "jawY"),
    lowerLipDepth = table.extract(skin, "lower_lip_depth"),
    lowerLipHeight = table.extract(skin, "lower_lip_height"),
    lowerLipWidth = table.extract(skin, "lower_lip_width"),
    mouthConerLeftDepth = table.extract(skin, "mouth_corner_left_depth"),
    mouthConerLeftHeight = table.extract(skin, "mouth_corner_left_height"),
    mouthConerLeftLipsDistance = table.extract(skin, "mouth_corner_left_lips_distance"),
    mouthConerLeftWidth = table.extract(skin, "mouth_corner_left_width"),
    mouthConerRightDepth = table.extract(skin, "mouth_corner_right_depth"),
    mouthConerRightHeight = table.extract(skin, "mouth_corner_right_height"),
    mouthConerRightLipsDistance = table.extract(skin, "mouth_corner_right_lips_distance"),
    mouthConerRightWidth = table.extract(skin, "mouth_corner_right_width"),
    mouthDepth = table.extract(skin, "mouth_depth"),
    mouthWidth = table.extract(skin, "mouth_width"),
    mouthX = table.extract(skin, "mouth_x_pos"),
    mouthY = table.extract(skin, "mouth_y_pos"),
    neckDepth = table.extract(skin, "neck_depth"),
    neckWidth = table.extract(skin, "neck_width"),
    noseAngle = table.extract(skin, "nose_angle"),
    noseCurvature = table.extract(skin, "nose_curvature"),
    noseHeight = table.extract(skin, "nose_height"),
    noseSize = table.extract(skin, "nose_size"),
    noseWidth = table.extract(skin, "nose_width"),
    nostrilsDistance = table.extract(skin, "nostrils_distance"),
    shoulderBlades = table.extract(skin, "back_muscle"),
    shoulders = table.extract(skin, "uppr_shoulder_size"),
    shoulderThickness = table.extract(skin, "back_shoulder_thickness"),
    thighs = table.extract(skin, "tight_size"),
    upperLipDepth = table.extract(skin, "upper_lip_depth"),
    upperLipHeight = table.extract(skin, "upper_lip_height"),
    upperLipWidth = table.extract(skin, "upper_lip_width"),
    waist = table.extract(skin, "waist_width"),
  }

  standard.overlays = {}
  standard.overlays.ageing = skin.ageing_t and {
    id = getStandardValuefromFramework("ov_ageing", skin.ageing_t)?.id or 0,
    opacity = self:convertToPercent(skin.ageing_op)
  }
  skin.ageing_t = nil
  skin.ageing_op = nil

  standard.overlays.beard = skin.beardstabble_t and {
    id = skin.beardstabble_t,
    opacity = self:convertToPercent(skin.beardstabble_op)
  }
  skin.beardstabble_t = nil
  skin.beardstabble_op = nil

  standard.overlays.blush = skin.blush_t and {
    id = getStandardValuefromFramework("ov_blush", skin.blush_t)?.id or 0,
    palette = skin.blush_id,
    tint0 = skin.blush_c1,
    opacity = self:convertToPercent(skin.blush_op)
  }
  skin.blush_t = nil
  skin.blush_id = nil
  skin.blush_c1 = nil
  skin.blush_op = nil

  standard.overlays.eyebrow = skin.eyebrows_t and (function()
    local standardEyebrow = getStandardValuefromFramework("ov_eyebrows", skin.eyebrows_t)
    return {
      id = standardEyebrow?.id or 0,
      sexe = standardEyebrow?.sexe or "m",
      palette = skin.eyebrows_id,
      tint0 = skin.eyebrows_c1,
      opacity = self:convertToPercent(skin.eyebrows_op)
    }
  end)()
  skin.eyebrows_t = nil
  skin.eyebrows_id = nil
  skin.eyebrows_c1 = nil
  skin.eyebrows_op = nil

  standard.overlays.eyeliner = skin.eyeliners_t and {
    id = 0,
    sheetGrid = decrease(skin.eyeliners_t),
    palette = skin.eyeliners_id,
    tint0 = skin.eyeliners_c1,
    opacity = self:convertToPercent(skin.eyeliners_op)
  }
  skin.eyeliners_t = nil
  skin.eyeliners_id = nil
  skin.eyeliners_c1 = nil
  skin.eyeliners_op = nil

  standard.overlays.eyeshadow = skin.shadows_t and {
    id = 0,
    sheetGrid = decrease(skin.shadows_t),
    palette = skin.shadows_id,
    tint0 = skin.shadows_c1,
    opacity = self:convertToPercent(skin.shadows_op)
  }
  skin.shadows_t = nil
  skin.shadows_id = nil
  skin.shadows_c1 = nil
  skin.shadows_op = nil

  standard.overlays.freckles = skin.freckles_t and {
    id = getStandardValuefromFramework("ov_freckles", skin.freckles_t)?.id or 0,
    opacity = self:convertToPercent(skin.freckles_op)
  }
  skin.freckles_t = nil
  skin.freckles_op = nil

  standard.overlays.lipstick = skin.lipsticks_t and {
    id = 0,
    sheetGrid = decrease(skin.lipsticks_t),
    palette = skin.lipsticks_id,
    tint0 = skin.lipsticks_c1,
    tint1 = skin.lipsticks_c2,
    opacity = self:convertToPercent(skin.lipsticks_op)
  }
  skin.lipsticks_t = nil
  skin.lipsticks_id = nil
  skin.lipsticks_c1 = nil
  skin.lipsticks_c2 = nil
  skin.lipsticks_op = nil

  standard.overlays.moles = skin.moles_t and {
    id = getStandardValuefromFramework("ov_moles", skin.moles_t)?.id or 0,
    opacity = self:convertToPercent(skin.moles_op)
  }
  skin.moles_t = nil
  skin.moles_op = nil

  standard.overlays.scar = skin.scars_t and {
    id = getStandardValuefromFramework("ov_scars", skin.scars_t)?.id or 0,
    opacity = self:convertToPercent(skin.scars_op)
  }
  skin.scars_t = nil
  skin.scars_op = nil

  standard.overlays.spots = skin.spots_t and {
    id = getStandardValuefromFramework("ov_spots", skin.spots_t)?.id or 0,
    opacity = self:convertToPercent(skin.spots_op)
  }
  skin.spots_t = nil
  skin.spots_op = nil

  -- standard.overlays.acne = {},
  -- standard.overlays.foundation = {},
  -- standard.overlays.grime = {},
  -- standard.overlays.hair = {},
  -- standard.overlays.masks = {},
  -- standard.overlays.complex = {},
  -- standard.overlays.disc = {},

  return standard
end

function jo.framework:revertSkinInternal(standard)
  local reverted = {}

  local function increase(value)
    return GetValue(value, 0) + 1
  end

  local function revertPercent(value)
    if not value then return nil end
    return math.ceil((value) * 100)
  end

  reverted.sex = standard.model == "mp_female" and 2 or 1
  _, reverted.body_size = table.find(fromFrameworkToStandard.bodies, function(value) return value == standard.bodiesIndex end)
  standard.bodiesIndex = nil
  reverted.eyes_color = table.extract(standard, "eyesIndex")
  _, reverted.head = table.find(fromFrameworkToStandard.heads[standard.model], function(value) return value == standard.headIndex end)
  reverted.head = GetValue(reverted.head, standard.headIndex) * 6
  standard.headIndex = nil
  _, reverted.skin_tone = table.find(fromFrameworkToStandard.skin_tone, function(value, i) return value == standard.skinTone end)
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
    local _, id = getFrameworkValueFromStandard("ov_ageing", standard.overlays.ageing)
    if id then
      reverted.ageing_t = id
      reverted.ageing_op = revertPercent(standard.overlays.ageing.opacity)
      standard.overlays.ageing.id = nil
      standard.overlays.ageing.opacity = nil
    end
  end
  if standard.overlays.beard then
    reverted.beardstabble_t = standard.overlays.beard.id
    reverted.beardstabble_op = revertPercent(standard.overlays.beard.opacity)
    standard.overlays.beard.id = nil
    standard.overlays.beard.opacity = nil
  end
  if standard.overlays.blush then
    local _, id = getFrameworkValueFromStandard("ov_blush", standard.overlays.blush)
    if id then
      reverted.blush_t = id
      reverted.blush_id = standard.overlays.blush.palette
      reverted.blush_c1 = standard.overlays.blush.tint0
      reverted.blush_op = revertPercent(standard.overlays.blush.opacity)
      standard.overlays.blush.id = nil
      standard.overlays.blush.palette = nil
      standard.overlays.blush.tint0 = nil
      standard.overlays.blush.opacity = nil
    end
  end
  if standard.overlays.eyebrow then
    local _, id = getFrameworkValueFromStandard("ov_eyebrows", standard.overlays.eyebrow)
    if id then
      reverted.eyebrows_t = id
      reverted.eyebrows_id = standard.overlays.eyebrow.palette
      reverted.eyebrows_c1 = standard.overlays.eyebrow.tint0
      reverted.eyebrows_op = revertPercent(standard.overlays.eyebrow.opacity)
      standard.overlays.eyebrow.id = nil
      standard.overlays.eyebrow.palette = nil
      standard.overlays.eyebrow.tint0 = nil
      standard.overlays.eyebrow.opacity = nil
      standard.overlays.eyebrow.sexe = nil
    end
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
    local _, id = getFrameworkValueFromStandard("ov_freckles", standard.overlays.freckles)
    if id then
      reverted.freckles_t = id
      reverted.freckles_op = revertPercent(standard.overlays.freckles.opacity)
      standard.overlays.freckles.id = nil
      standard.overlays.freckles.opacity = nil
    end
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
    local _, id = getFrameworkValueFromStandard("ov_moles", standard.overlays.moles)
    if id then
      reverted.moles_t = id
      reverted.moles_op = revertPercent(standard.overlays.moles.opacity)
      standard.overlays.moles.id = nil
      standard.overlays.moles.opacity = nil
    end
  end
  if standard.overlays.scar then
    local _, id = getFrameworkValueFromStandard("ov_scars", standard.overlays.scar)
    if id then
      reverted.scars_t = id
      reverted.scars_op = revertPercent(standard.overlays.scar.opacity)
      standard.overlays.scar.id = nil
      standard.overlays.scar.opacity = nil
    end
  end
  if standard.overlays.spots then
    local _, id = getFrameworkValueFromStandard("ov_spots", standard.overlays.spots)
    if id then
      reverted.spots_t = id
      reverted.spots_op = revertPercent(standard.overlays.spots.opacity)
      standard.overlays.spots.id = nil
      standard.overlays.spots.opacity = nil
    end
  end

  return reverted
end

---A function to standardize the clothes data
---@param clothes table standard clothes data
---@return table clothes framework clothes data
function jo.framework:standardizeClothesInternal(clothes)
  local standard = {}

  standard.boot_accessories = table.extract(clothes, "boot_accessories")
  standard.pants = table.extract(clothes, "pants")
  standard.cloaks = table.extract(clothes, "cloaks")
  standard.hats = table.extract(clothes, "hats")
  standard.vests = table.extract(clothes, "vests")
  standard.chaps = table.extract(clothes, "chaps")
  standard.shirts_full = table.extract(clothes, "shirts_full")
  standard.badges = table.extract(clothes, "badges")
  standard.masks = table.extract(clothes, "masks")
  standard.spats = table.extract(clothes, "spats")
  standard.neckwear = table.extract(clothes, "neckwear")
  standard.boots = table.extract(clothes, "boots")
  standard.accessories = table.extract(clothes, "accessories")
  standard.jewelry_rings_right = table.extract(clothes, "jewelry_rings_right")
  standard.jewelry_rings_left = table.extract(clothes, "jewelry_rings_left")
  standard.jewelry_bracelets = table.extract(clothes, "jewelry_bracelets")
  standard.gauntlets = table.extract(clothes, "gauntlets")
  standard.neckties = table.extract(clothes, "neckties")
  standard.holsters_knife = table.extract(clothes, "holsters_knife")
  standard.talisman_holster = table.extract(clothes, "talisman_holster")
  standard.loadouts = table.extract(clothes, "loadouts")
  standard.suspenders = table.extract(clothes, "suspenders")
  standard.talisman_satchel = table.extract(clothes, "talisman_satchel")
  standard.satchels = table.extract(clothes, "satchels")
  standard.gunbelts = table.extract(clothes, "gunbelts")
  standard.belts = table.extract(clothes, "belts")
  standard.belt_buckles = table.extract(clothes, "belt_buckles")
  standard.holsters_left = table.extract(clothes, "holsters_left")
  standard.holsters_right = table.extract(clothes, "holsters_right")
  standard.talisman_wrist = table.extract(clothes, "talisman_wrist")
  standard.coats = table.extract(clothes, "coats")
  standard.coats_closed = table.extract(clothes, "coats_closed")
  standard.ponchos = table.extract(clothes, "ponchos")
  standard.eyewear = table.extract(clothes, "eyewear")
  standard.gloves = table.extract(clothes, "gloves")
  standard.holsters_crossdraw = table.extract(clothes, "holsters_crossdraw")
  standard.aprons = table.extract(clothes, "aprons")
  standard.skirts = table.extract(clothes, "skirts")
  standard.hair_accessories = table.extract(clothes, "hair_accessories")
  standard.dresses = table.extract(clothes, "dresses")
  standard.armor = table.extract(clothes, "armor")

  return standard
end

function jo.framework:revertClothesInternal(standard)
  local clothes = {}

  clothes.boot_accessories = table.extract(standard, "boot_accessories")
  clothes.pants = table.extract(standard, "pants")
  clothes.cloaks = table.extract(standard, "cloaks")
  clothes.hats = table.extract(standard, "hats")
  clothes.vests = table.extract(standard, "vests")
  clothes.chaps = table.extract(standard, "chaps")
  clothes.shirts_full = table.extract(standard, "shirts_full")
  clothes.badges = table.extract(standard, "badges")
  clothes.masks = table.extract(standard, "masks")
  clothes.spats = table.extract(standard, "spats")
  clothes.neckwear = table.extract(standard, "neckwear")
  clothes.boots = table.extract(standard, "boots")
  clothes.accessories = table.extract(standard, "accessories")
  clothes.jewelry_rings_right = table.extract(standard, "jewelry_rings_right")
  clothes.jewelry_rings_left = table.extract(standard, "jewelry_rings_left")
  clothes.jewelry_bracelets = table.extract(standard, "jewelry_bracelets")
  clothes.gauntlets = table.extract(standard, "gauntlets")
  clothes.neckties = table.extract(standard, "neckties")
  clothes.holsters_knife = table.extract(standard, "holsters_knife")
  clothes.talisman_holster = table.extract(standard, "talisman_holster")
  clothes.loadouts = table.extract(standard, "loadouts")
  clothes.suspenders = table.extract(standard, "suspenders")
  clothes.talisman_satchel = table.extract(standard, "talisman_satchel")
  clothes.satchels = table.extract(standard, "satchels")
  clothes.gunbelts = table.extract(standard, "gunbelts")
  clothes.belts = table.extract(standard, "belts")
  clothes.belt_buckles = table.extract(standard, "belt_buckles")
  clothes.holsters_left = table.extract(standard, "holsters_left")
  clothes.holsters_right = table.extract(standard, "holsters_right")
  clothes.talisman_wrist = table.extract(standard, "talisman_wrist")
  clothes.coats = table.extract(standard, "coats")
  clothes.coats_closed = table.extract(standard, "coats_closed")
  clothes.ponchos = table.extract(standard, "ponchos")
  clothes.eyewear = table.extract(standard, "eyewear")
  clothes.gloves = table.extract(standard, "gloves")
  clothes.holsters_crossdraw = table.extract(standard, "holsters_crossdraw")
  clothes.aprons = table.extract(standard, "aprons")
  clothes.skirts = table.extract(standard, "skirts")
  clothes.hair_accessories = table.extract(standard, "hair_accessories")
  clothes.dresses = table.extract(standard, "dresses")
  clothes.armor = table.extract(standard, "armor")

  return clothes
end

function jo.framework:getUserClothesInternal(source)
  local user = self:getUserIdentifiers(source)
  local clothes = MySQL.scalar.await("SELECT clothes FROM clothes WHERE identifier=? AND charid=?;", { user.identifier, user.charid })
  return UnJson(clothes)
end

function jo.framework:updateUserClothesInternal(source, clothes)
  local identifiers = self:getUserIdentifiers(source)
  MySQL.scalar("SELECT clothes FROM clothes WHERE identifier=? AND charid=?;", { identifiers.identifier, identifiers.charid }, function(oldClothes)
    local decoded = UnJson(oldClothes)
    table.merge(decoded, clothes)
    local SQL = "UPDATE clothes SET clothes=@clothes WHERE identifier=@identifier AND charid=@charid"
    if not oldClothes then
      SQL = "INSERT INTO clothes VALUES(NULL,@identifier,@charid,@clothes)"
    end
    MySQL.update(SQL, {
      identifier = identifiers.identifier,
      charid = identifiers.charid,
      clothes = json.encode(decoded)
    })
  end)
end

function jo.framework:getUserSkinInternal(source)
  local user = self.UserClass:get(source)
  local skin = {}
  if not user then return {} end
  local identifiers = user:getIdentifiers()
  skin = MySQL.scalar.await("SELECT skin FROM skins WHERE identifier=? AND charid=?;", { identifiers.identifier, identifiers.charid })
  return UnJson(skin)
end

function jo.framework:updateUserSkinInternal(source, skin, overwrite)
  local identifiers = self:getUserIdentifiers(source)
  MySQL.scalar("SELECT skin FROM skins WHERE identifier=? AND charid=?", { identifiers.identifier, identifiers.charid }, function(oldSkin)
    if not oldSkin then
      MySQL.insert("INSERT INTO skins VALUES (NULL, ?,?,?)", { identifiers.identifier, identifiers.charid, json.encode(skin) })
    else
      local decoded = UnJson(oldSkin)
      if overwrite then
        decoded = skin
      else
        table.merge(decoded, skin)
      end
      MySQL.update("UPDATE skins SET skin=? WHERE identifier=? AND charid=?", { json.encode(decoded), identifiers.identifier, identifiers.charid })
    end
  end)
end

function jo.framework:createUser(source, data, spawnCoordinate, isDead)
  return {}
end

function jo.framework:onCharacterSelected(cb)
  AddEventHandler("redemrp:selectCharacter", function()
    local source = source
    Wait(1000)
    cb(source)
  end)
end
