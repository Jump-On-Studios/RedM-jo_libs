-------------
-- FRAMEWORK CLASS
-------------
local Inventory = exports.vorp_inventory
local Core = exports.vorp_core:GetCore()

jo.framework.core = Core
jo.framework.inv = Inventory

-------------
-- VARIABLES
-------------

local inventoriesCreated = {}

local fromFrameworkToStandard = {
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
-- INVENTORY
-------------

function jo.framework:canUseItem(source, item, amount, meta, remove)
  local count = Inventory:getItemCount(source, nil, item, meta)
  if count >= amount then
    if remove then
      Inventory:subItem(source, item, amount, meta)
    end
    return true
  end
  return false
end

function jo.framework:registerUseItem(item, closeAfterUsed, callback)
  CreateThread(function()
    if (closeAfterUsed == nil) then closeAfterUsed = true end
    -- local isExist = Inventory:getItemDB(item)
    -- if not isExist then
    --   return eprint(item .. " < item does not exist in the database")
    -- end
    Inventory:registerUsableItem(item, function(data)
      if closeAfterUsed then
        Inventory:closeInventory(data.source)
      end
      return callback(data.source, { metadata = data.item.metadata })
    end)
  end)
end

function jo.framework:giveItem(source, item, quantity, meta)
  if Inventory:canCarryItem(source, item, quantity) then
    Inventory:addItem(source, item, quantity, meta)
    return true
  end
  return false
end

function jo.framework:createInventory(id, name, invConfig)
  inventoriesCreated[id] = {
    id = id,
    name = name,
    config = invConfig,
    inventory = {}
  }

  local invData = {
    id = id,
    name = name,
    limit = invConfig.maxSlots,
    acceptWeapons = GetValue(invConfig.acceptWeapons, false),
    shared = GetValue(invConfig.shared, true),
    ignoreItemStackLimit = GetValue(invConfig.ignoreStackLimit, true),
    whitelistItems = GetValue(invConfig.useWhitelist, invConfig.whitelist and true or false),
    UseBlackList = GetValue(invConfig.useBlackList, invConfig.blacklist and true or false),
    whitelistWeapons = GetValue(invConfig.useWeaponlist, invConfig.weaponlist and true or false),
  }

  if exports.vorp_inventory:isCustomInventoryRegistered(id) then
    exports.vorp_inventory:updateCustomInventoryData(id, invData)
    inventoriesCreated[id].inventory = exports.vorp_inventory:getCustomInventoryData(id)
  else
    inventoriesCreated[id].inventory = exports.vorp_inventory:registerInventory(invData)
  end

  if invConfig.permissions then
    for _, permission in ipairs(invConfig.permissions.allowedJobsTakeFrom or {}) do
      exports.vorp_inventory:AddPermissionTakeFromCustom(id, permission.name or permission.job, permission.grade)
    end
    for _, permission in ipairs(invConfig.permissions.allowedJobsMoveTo or {}) do
      exports.vorp_inventory:AddPermissionMoveToCustom(id, permission.name or permission.job, permission.grade)
    end
  end

  if invData.whitelistItems then
    for _, item in ipairs(invConfig.whitelist or {}) do
      exports.vorp_inventory:setCustomInventoryItemLimit(id, item.name or item.item, item.limit)
    end
  end

  if invData.whitelistWeapons then
    for _, weapon in ipairs(invConfig.weaponlist or {}) do
      exports.vorp_inventory:setCustomInventoryWeaponLimit(id, weapon.name or weapon.weapon, weapon.limit)
    end
  end

  if invData.UseBlackList then
    for _, item in ipairs(invConfig.blacklist or {}) do
      exports.vorp_inventory:BlackListCustomAny(id, item)
    end
  end

  return inventoriesCreated[id].inventory
end

function jo.framework:removeInventory(id)
  Inventory:removeInventory(id)
end

function jo.framework:openInventory(source, id)
  if not Inventory:isCustomInventoryRegistered(id) then
    return false, eprint(("This custom inventory doesn't exist: %s. You can create it with `jo.framework:createInventory()`."):format(tostring(id)))
  end
  return Inventory:openInventory(source, id)
end

function jo.framework:addItemInInventory(source, id, item, quantity, metadata)
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

function jo.framework:getItemsFromInventory(invId)
  local invItems = Inventory:getCustomInventoryItems(invId) or {}
  local weaponItems = Inventory:getCustomInventoryWeapons(invId) or {}
  local items = {}

  for i = 1, #invItems do
    items[i] = {
      id = invItems[i].id,
      amount = invItems[i].amount,
      item = invItems[i].name,
      metadata = invItems[i].metadata
    }
  end

  for i = 1, #weaponItems do
    items[#items + 1] = {
      id = weaponItems[i].id,
      amount = 1,
      item = weaponItems[i].name,
      metadata = {
        label = weaponItems[i].label,
        custom_desc = weaponItems[i].custom_desc,
        serial_number = weaponItems[i].serial_number,
      }
    }
  end

  return items
end

-------------
-- SKIN & CLOTHES
-------------

local function getHeadHash(sex, skin)
  if skin.HeadType == 0 then
    return skin.HeadType, 1, 1
  end
  for skinTint = 1, 6 do
    for index = 1, 28 do
      local value = jo.component.getHeadFromSkinTone(sex, index, skinTint)
      local hash = joaat(value)
      if (skin.HeadType == hash) then
        dprint("getHeadHash", value, skinTint, index)
        return hash, skinTint, index
      end
    end
  end
  dprint("No head found for:")
  dprint("HeadType:", skin.HeadType)
  return skin.HeadType, 1, 1
end

local function getBodyUpperHash(sex, skin)
  dprint("getBodyUpperHash", sex, skin.BodyType, skin.Torso)
  if skin.BodyType == 0 and skin.Torso == 0 then
    return skin.BodyType, 1, 1
  end
  for skinTint = 1, 6 do
    for index = 0, 6 do
      local value = jo.component.getBodiesUpperFromSkinTone(sex, index, skinTint)
      local hash = joaat(value)
      if (skin.BodyType == hash) then
        dprint("getBodyUpperHash", "BodyType", value, hash, skinTint, index)
        return hash, skinTint, index
      end
    end
  end
  for skinTint = 1, 6 do
    for index = 0, 6 do
      local value = jo.component.getBodiesUpperFromSkinTone(sex, index, skinTint)
      local hash = joaat(value)
      if (skin.Torso == hash) then
        dprint("getBodyUpperHash", "Torso", value, hash, skinTint, index)
        return hash, skinTint, index
      end
    end
  end
  dprint("No Upper body found for:")
  dprint("BodyType:", skin.BodyType)
  dprint("Torso:", skin.Torso)
  return skin.BodyType, 1, 1
end

local function getBodyLowerHash(sex, skin)
  dprint("getBodyLowerHash", sex, skin.LegsType, skin.Legs, skin.Body)
  if skin.LegsType == 0 and skin.Legs == 0 then
    return skin.LegsType, 1, 1
  end
  for skinTint = 1, 6 do
    for index = 0, 6 do
      local value = jo.component.getBodiesLowerFromSkinTone(sex, index, skinTint)
      local hash = joaat(value)
      if (skin.LegsType == hash) then
        dprint("getBodyLowerHash", "LegsType", value, hash, skinTint, index)
        return hash, skinTint, index
      end
    end
  end
  for skinTint = 1, 6 do
    for index = 0, 6 do
      local value = jo.component.getBodiesLowerFromSkinTone(sex, index, skinTint)
      local hash = joaat(value)
      if (skin.Legs == hash) then
        dprint("getBodyLowerHash", "Legs", value, hash, skinTint, index)
        return hash, skinTint, index
      end
    end
  end
  dprint("No Lower body found for:")
  dprint("LegsType:", skin.LegsType)
  dprint("Legs:", skin.Legs)
  return skin.LegsType, 1, 1
end

function jo.framework:standardizeSkinInternal(skin)
  local standard = {}

  local function decrease(value)
    return GetValue(value, 1) - 1
  end

  standard.model = table.extract(skin, "sex")
  local skinTint = 1
  local bodyIndex = 1
  standard.headHash, skinTint = getHeadHash(standard.model, skin)
  if standard.headHash == 0 then
    standard.headHash = jo.component.getHeadFromSkinTone(standard.model, 1, 1)
    skinTint = 1
  end
  skin.HeadType = nil
  standard.bodyUpperHash, _, bodyIndex = getBodyUpperHash(standard.model, skin)
  if bodyIndex == 6 then
    standard.bodyUpperHash = jo.component.getBodiesUpperFromSkinTone(standard.model, 5, skinTint)
  end
  if bodyIndex == 0 then
    standard.bodyUpperHash = jo.component.getBodiesUpperFromSkinTone(standard.model, 1, skinTint)
  end
  if standard.bodyUpperHash == 0 then
    standard.bodyUpperHash = jo.component.getBodiesUpperFromSkinTone(standard.model, 1, skinTint)
  end
  skin.BodyType = nil
  skin.Torso = nil
  standard.bodyLowerHash, _, bodyIndex = getBodyLowerHash(standard.model, skin)
  if bodyIndex == 6 then
    standard.bodyLowerHash = jo.component.getBodiesLowerFromSkinTone(standard.model, 5, skinTint)
  end
  if bodyIndex == 0 then
    standard.bodyLowerHash = jo.component.getBodiesLowerFromSkinTone(standard.model, 1, skinTint)
  end
  if standard.bodyLowerHash == 0 then
    standard.bodyLowerHash = jo.component.getBodiesLowerFromSkinTone(standard.model, 1, skinTint)
  end
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
    id = getStandardValuefromFramework("ov_ageing", skin.ageing_tx_id)?.id or 0,
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
    id = getStandardValuefromFramework("ov_blush", skin.blush_tx_id)?.id or 0,
    tint0 = skin.blush_palette_color_primary,
    opacity = self:convertToPercent(skin.blush_opacity)
  }
  skin.blush_tx_id = nil
  skin.blush_palette_color_primary = nil
  skin.blush_opacity = nil
  skin.blush_visibility = nil

  standard.overlays.eyebrow = needOverlay(skin.eyebrows_visibility) and (function()
    local standardEyebrow = getStandardValuefromFramework("ov_eyebrows", skin.eyebrows_tx_id)
    return {
      id = standardEyebrow?.id or 0,
      sexe = standardEyebrow?.sexe or "m",
      tint0 = skin.eyebrows_color,
      opacity = self:convertToPercent(skin.eyebrows_opacity)
    }
  end)()
  skin.eyebrows_tx_id = nil
  skin.eyebrows_color = nil
  skin.eyebrows_opacity = nil
  skin.eyebrows_visibility = nil

  standard.overlays.eyeliner = needOverlay(skin.eyeliner_visibility) and {
    id = getStandardValuefromFramework("ov_eyeliners", skin.eyeliner_tx_id)?.id or 0,
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
    id = getStandardValuefromFramework("ov_freckles", skin.freckles_tx_id)?.id or 0,
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
    id = getStandardValuefromFramework("ov_moles", skin.moles_tx_id)?.id or 0,
    opacity = self:convertToPercent(skin.moles_opacity)
  }
  skin.moles_tx_id = nil
  skin.moles_opacity = nil
  skin.moles_visibility = nil

  standard.overlays.scar = needOverlay(skin.scars_visibility) and {
    id = getStandardValuefromFramework("ov_scars", skin.scars_tx_id)?.id or 0,
    opacity = self:convertToPercent(skin.scars_opacity)
  }
  skin.scars_tx_id = nil
  skin.scars_opacity = nil
  skin.scars_visibility = nil

  standard.overlays.spots = needOverlay(skin.spots_visibility) and {
    id = getStandardValuefromFramework("ov_spots", skin.spots_tx_id)?.id or 0,
    opacity = self:convertToPercent(skin.spots_opacity)
  }
  skin.spots_tx_id = nil
  skin.spots_opacity = nil
  skin.spots_visibility = nil

  standard.overlays.acne = needOverlay(skin.acne_visibility) and {
    id = getStandardValuefromFramework("ov_acne", skin.acne_tx_id)?.id or 0,
    opacity = self:convertToPercent(skin.acne_opacity)
  }
  skin.acne_tx_id = nil
  skin.acne_opacity = nil
  skin.acne_visibility = nil

  standard.overlays.grime = needOverlay(skin.grime_visibility) and {
    id = getStandardValuefromFramework("ov_grime", skin.grime_tx_id)?.id or 0,
    opacity = self:convertToPercent(skin.grime_opacity)
  }
  skin.grime_tx_id = nil
  skin.grime_opacity = nil
  skin.grime_visibility = nil

  standard.overlays.hair = needOverlay(skin.hair_visibility) and {
    id = getStandardValuefromFramework("ov_hair", skin.hair_tx_id)?.id or 0,
    tint0 = skin.hair_color_primary,
    opacity = self:convertToPercent(skin.hair_opacity)
  }
  skin.hair_tx_id = nil
  skin.hair_color_primary = nil
  skin.hair_opacity = nil
  skin.hair_visibility = nil

  standard.overlays.complex = needOverlay(skin.complex_visibility) and {
    id = getStandardValuefromFramework("ov_complex", skin.complex_tx_id)?.id or 0,
    opacity = self:convertToPercent(skin.complex_opacity)
  }
  skin.complex_tx_id = nil
  skin.complex_opacity = nil
  skin.complex_visibility = nil

  standard.overlays.disc = needOverlay(skin.disc_visibility) and {
    id = getStandardValuefromFramework("ov_disc", skin.disc_tx_id)?.id or 0,
    opacity = self:convertToPercent(skin.disc_opacity)
  }
  skin.disc_tx_id = nil
  skin.disc_opacity = nil
  skin.disc_visibility = nil

  standard.overlays.foundation = needOverlay(skin.foundation_visibility) and {
    id = getStandardValuefromFramework("ov_foundation", skin.foundation_tx_id)?.id or 0,
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
    id = getStandardValuefromFramework("ov_paintedmasks", skin.paintedmasks_tx_id)?.id or 0,
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

function jo.framework:revertSkinInternal(standard)
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
    local _, tx_id = getFrameworkValueFromStandard("ov_ageing", standard.overlays.ageing)
    if tx_id then
      reverted.ageing_visibility = 1
      reverted.ageing_tx_id = tx_id
      reverted.ageing_opacity = standard.overlays.ageing.opacity
      standard.overlays.ageing.id = nil
      standard.overlays.ageing.opacity = nil
    end
  end
  if standard.overlays.beard then
    reverted.beardstabble_visibility = 1
    reverted.beardstabble_color_primary = standard.overlays.beard.tint0
    reverted.beardstabble_opacity = standard.overlays.beard.opacity
    standard.overlays.beard.tint0 = nil
    standard.overlays.beard.opacity = nil
    standard.overlays.beard.id = nil
  end
  if standard.overlays.blush then
    local _, tx_id = getFrameworkValueFromStandard("ov_blush", standard.overlays.blush)
    if tx_id then
      reverted.blush_visibility = 1
      reverted.blush_tx_id = tx_id
      reverted.blush_palette_color_primary = standard.overlays.blush.tint0
      reverted.blush_opacity = standard.overlays.blush.opacity
      standard.overlays.blush.id = nil
      standard.overlays.blush.tint0 = nil
      standard.overlays.blush.opacity = nil
    end
  end
  if standard.overlays.eyebrow then
    local _, tx_id = getFrameworkValueFromStandard("ov_eyebrows", standard.overlays.eyebrow)
    if tx_id then
      reverted.eyebrows_visibility = 1
      reverted.eyebrows_tx_id = tx_id
      reverted.eyebrows_color = standard.overlays.eyebrow.tint0
      reverted.eyebrows_opacity = standard.overlays.eyebrow.opacity
      standard.overlays.eyebrow.id = nil
      standard.overlays.eyebrow.sexe = nil
      standard.overlays.eyebrow.tint0 = nil
      standard.overlays.eyebrow.opacity = nil
    end
  end
  if standard.overlays.eyeliner then
    local _, tx_id = getFrameworkValueFromStandard("ov_eyeliners", standard.overlays.eyeliner)
    if tx_id then
      reverted.eyeliner_visibility = 1
      reverted.eyeliner_tx_id = tx_id
      reverted.eyeliner_palette_id = increase(standard.overlays.eyeliner.sheetGrid)
      reverted.eyeliner_color_primary = standard.overlays.eyeliner.tint0
      reverted.eyeliner_opacity = standard.overlays.eyeliner.opacity
      standard.overlays.eyeliner.id = nil
      standard.overlays.eyeliner.sheetGrid = nil
      standard.overlays.eyeliner.tint0 = nil
      standard.overlays.eyeliner.opacity = nil
    end
  end
  if standard.overlays.eyeshadow then
    local _, tx_id = getFrameworkValueFromStandard("ov_shadows", standard.overlays.eyeshadow)
    if tx_id then
      reverted.shadows_visibility = 1
      reverted.shadows_tx_id = tx_id
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
  end
  if standard.overlays.freckles then
    local _, tx_id = getFrameworkValueFromStandard("ov_freckles", standard.overlays.freckles)
    if tx_id then
      reverted.freckles_visibility = 1
      reverted.freckles_tx_id = tx_id
      reverted.freckles_opacity = standard.overlays.freckles.opacity
      standard.overlays.freckles.id = nil
      standard.overlays.freckles.opacity = nil
    end
  end
  if standard.overlays.lipstick then
    local _, tx_id = getFrameworkValueFromStandard("ov_lipsticks", standard.overlays.lipstick)
    if tx_id then
      reverted.lipsticks_visibility = 1
      reverted.lipsticks_tx_id = tx_id
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
  end
  if standard.overlays.moles then
    local _, tx_id = getFrameworkValueFromStandard("ov_moles", standard.overlays.moles)
    if tx_id then
      reverted.moles_visibility = 1
      reverted.moles_tx_id = tx_id
      reverted.moles_opacity = standard.overlays.moles.opacity
      standard.overlays.moles.id = nil
      standard.overlays.moles.opacity = nil
    end
  end
  if standard.overlays.scar then
    local _, tx_id = getFrameworkValueFromStandard("ov_scars", standard.overlays.scar)
    if tx_id then
      reverted.scars_visibility = 1
      reverted.scars_tx_id = tx_id
      reverted.scars_opacity = standard.overlays.scar.opacity
      standard.overlays.scar.id = nil
      standard.overlays.scar.opacity = nil
    end
  end
  if standard.overlays.spots then
    local _, tx_id = getFrameworkValueFromStandard("ov_spots", standard.overlays.spots)
    if tx_id then
      reverted.spots_visibility = 1
      reverted.spots_tx_id = tx_id
      reverted.spots_opacity = standard.overlays.spots.opacity
      standard.overlays.spots.id = nil
      standard.overlays.spots.opacity = nil
    end
  end
  if standard.overlays.acne then
    local _, tx_id = getFrameworkValueFromStandard("ov_acne", standard.overlays.acne)
    if tx_id then
      reverted.acne_visibility = 1
      reverted.acne_tx_id = tx_id
      reverted.acne_opacity = standard.overlays.acne.opacity
      standard.overlays.acne.id = nil
      standard.overlays.acne.opacity = nil
    end
  end
  if standard.overlays.grime then
    local _, tx_id = getFrameworkValueFromStandard("ov_grime", standard.overlays.grime)
    if tx_id then
      reverted.grime_visibility = 1
      reverted.grime_tx_id = tx_id
      reverted.grime_opacity = standard.overlays.grime.opacity
      standard.overlays.grime.id = nil
      standard.overlays.grime.opacity = nil
    end
  end
  if standard.overlays.hair then
    local _, tx_id = getFrameworkValueFromStandard("ov_hair", standard.overlays.hair)
    if tx_id then
      reverted.hair_visibility = 1
      reverted.hair_tx_id = tx_id
      reverted.hair_color_primary = standard.overlays.hair.tint0
      reverted.hair_opacity = standard.overlays.hair.opacity
      standard.overlays.hair.id = nil
      standard.overlays.hair.tint0 = nil
      standard.overlays.hair.opacity = nil
    end
  end
  if standard.overlays.complex then
    local _, tx_id = getFrameworkValueFromStandard("ov_complex", standard.overlays.complex)
    if tx_id then
      reverted.complex_visibility = 1
      reverted.complex_tx_id = tx_id
      reverted.complex_opacity = standard.overlays.complex.opacity
      standard.overlays.complex.id = nil
      standard.overlays.complex.opacity = nil
    end
  end
  if standard.overlays.disc then
    local _, tx_id = getFrameworkValueFromStandard("ov_disc", standard.overlays.disc)
    if tx_id then
      reverted.disc_visibility = 1
      reverted.disc_tx_id = tx_id
      reverted.disc_opacity = standard.overlays.disc.opacity
      standard.overlays.disc.id = nil
      standard.overlays.disc.opacity = nil
    end
  end
  if standard.overlays.foundation then
    local _, tx_id = getFrameworkValueFromStandard("ov_foundation", standard.overlays.foundation)
    if tx_id then
      reverted.foundation_visibility = 1
      reverted.foundation_tx_id = tx_id
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
  end

  reverted.overlays = standard.overlays

  return reverted
end

function jo.framework:standardizeClothesInternal(clothes)
  local standard = {
    accessories = table.extract(clothes, "Accessories"),
    armor = table.extract(clothes, "Armor"),
    badges = table.extract(clothes, "Badge"),
    beards_complete = table.extract(clothes, "Beard"),
    belts = table.extract(clothes, "Belt"),
    boots = table.extract(clothes, "Boots"),
    hair_accessories = table.extract(clothes, "Bow"),
    jewelry_bracelets = table.extract(clothes, "Bracelet"),
    chaps = table.extract(clothes, "Chap"),
    belt_buckles = table.extract(clothes, "Buckle"),
    cloaks = table.extract(clothes, "Cloak"),
    coats = table.extract(clothes, "Coat"),
    coats_closed = table.extract(clothes, "CoatClosed"),
    dresses = table.extract(clothes, "Dress"),
    eyewear = table.extract(clothes, "EyeWear"),
    gauntlets = table.extract(clothes, "Gauntlets"),
    gloves = table.extract(clothes, "Glove"),
    gunbelts = table.extract(clothes, "Gunbelt"),
    gunbelt_accs = table.extract(clothes, "GunbeltAccs"),
    hair = table.extract(clothes, "Hair"),
    hats = table.extract(clothes, "Hat"),
    holsters_left = table.extract(clothes, "Holster"),
    loadouts = table.extract(clothes, "Loadouts"),
    masks = table.extract(clothes, "Mask"),
    neckties = table.extract(clothes, "NeckTies"),
    neckwear = table.extract(clothes, "NeckWear"),
    pants = table.extract(clothes, "Pant"),
    ponchos = table.extract(clothes, "Poncho"),
    jewelry_rings_left = table.extract(clothes, "RingLh"),
    jewelry_rings_right = table.extract(clothes, "RingRh"),
    satchels = table.extract(clothes, "Satchels"),
    shirts_full = table.extract(clothes, "Shirt"),
    skirts = table.extract(clothes, "Skirt"),
    spats = table.extract(clothes, "Spats"),
    boot_accessories = table.extract(clothes, "Spurs"),
    suspenders = table.extract(clothes, "Suspender"),
    teeth = table.extract(clothes, "Teeth"),
    vests = table.extract(clothes, "Vest"),
  }
  return standard
end

function jo.framework:revertClothesInternal(standard)
  local reverted = {
    Accessories = table.extract(standard, "accessories"),
    Armor = table.extract(standard, "armor"),
    Badge = table.extract(standard, "badges"),
    Beard = table.extract(standard, "beards_complete"),
    Belt = table.extract(standard, "belts"),
    Boots = table.extract(standard, "boots"),
    Bow = table.extract(standard, "hair_accessories"),
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

function jo.framework:getUserClothesInternal(source)
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

function jo.framework:updateUserClothesInternal(source, clothes)
  local newClothes = {}
  for category, value in pairs(clothes) do
    newClothes[category] = value
    if type(value) == "table" then
      newClothes[category].comp = GetValue(value?.hash, 0)
    end
  end
  local user = self.UserClass:get(source)
  local tints = UnJson(user.data.comptTints)
  for category, value in pairs(clothes) do
    if type(value) == "table" and GetValue(value?.hash, 0) ~= 0 then
      local tint = {
        state = value.state
      }
      if value.palette and value.palette ~= 0 then
        tint.tint0 = GetValue(value.tint0, 0)
        tint.tint1 = GetValue(value.tint1, 0)
        tint.tint2 = GetValue(value.tint2, 0)
        tint.palette = GetValue(value.palette, 0)
      end
      tints[category] = { [value.hash] = tint }
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

function jo.framework:getUserSkinInternal(source)
  local user = self.UserClass:get(source)
  if not user then return {} end
  return UnJson(user.data.skin)
end

function jo.framework:updateUserSkinInternal(source, skin, overwrite)
  for cat, data in pairs(skin) do
    if cat == "Teeth" then
      self:updateUserClothesInternal(source, { Teeth = { hash = self:extractComponentHashIfAlone(data) } })
      skin[cat] = nil
    end
  end
  if overwrite then
    TriggerClientEvent("vorpcharacter:updateCache", source, skin)
  else
    TriggerClientEvent("vorpcharacter:savenew", source, false, skin)
  end
end

function jo.framework:createUser(source, data, spawnCoordinate, isDead)
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

function jo.framework:onCharacterSelected(cb)
  AddEventHandler("vorp:SelectedCharacter", function(source)
    cb(source)
  end)
end
