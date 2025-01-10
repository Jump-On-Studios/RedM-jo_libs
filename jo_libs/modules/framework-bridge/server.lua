jo.file.load("framework-bridge.overwrite-functions")

jo.require("table")
jo.require("string")

local mainResourceFramework = {
  VORP = { "vorp_core" },
  RedEM = { "redem" },
  RedEM2023 = { "!redem", "redem_roleplay" },
  QBR = { "qbr-core" },
  RSG = { "rsg-core" },
  QR = { "qr-core" },
}

-------------
-- VARIABLES
-------------
local skinCategoryBridge = {
  VORP = {
    components = {
      Accessories = "accessories",
      armor = "armor",
      Badge = "badges",
      Beard = "beards_complete",
      Belt = "belts",
      Boots = "boots",
      bow = "hair_accessories",
      Bracelet = "jewelry_bracelets",
      Buckle = "belt_buckles",
      Chap = "chaps",
      Cloak = "cloaks",
      Coat = "coats",
      CoatClosed = "coats_closed",
      Dress = "dresses",
      EyeWear = "eyewear",
      Gauntlets = "gauntlets",
      Glove = "gloves",
      Gunbelt = "gunbelts",
      GunbeltAccs = "gunbelt_accs",
      Hair = "hair",
      Hat = "hats",
      Holster = "holsters_left",
      Loadouts = "loadouts",
      Mask = "masks",
      NeckTies = "neckties",
      NeckWear = "neckwear",
      Pant = "pants",
      Poncho = "ponchos",
      RingLh = "jewelry_rings_left",
      RingRh = "jewelry_rings_right",
      Satchels = "satchels",
      Shirt = "shirts_full",
      Skirt = "skirts",
      Spats = "spats",
      Spurs = "boot_accessories",
      Suspender = "suspenders",
      Teeth = "teeth",
      Vest = "vests",
    },
    overlays = {
      acne = "acne",
      ageing = "ageing",
      beardstabble = "beard",
      blush = "blush",
      complex = "complex",
      disc = "disc",
      eyebrows = "eyebrow",
      eyeliner = "eyeliner",
      eyeliners = "eyeliner",
      foundation_ = "foundation",
      freckles = "freckles",
      grime = "grime",
      hair = "hair",
      lipsticks = "lipstick",
      moles = "moles",
      paintedmasks = "masks",
      scars = "scar",
      shadows = "eyeshadow",
      spots = "spots",
    },
  },
}

-------------
-- END VARIABLES
-------------

-------------
-- USER CLASS
-------------

---@class User : table User class
---@field source integer source ID
local User = {
  source = 0,
  data = {}
}

---@return User
function User:get(source)
  self = table.copy(User)
  self.source = tonumber(source)
  self:init()
  return self
end

function User:init()
  if OWFramework.User.getUser then
    self.data = OWFramework.User.getUser(self.source)
  elseif jo.framework:is("VORP") then
    local user = jo.framework.core.getUser(self.source)
    if not user then
      eprint("User doesn't exist. source:", self.source)
      self.data = {}
    else
      self.data = user.getUsedCharacter
    end
  elseif jo.framework:is("RedEM2023") then
    self.data = jo.framework.core.GetPlayer(self.source)
  elseif jo.framework:is("RedEM") then
    local user = promise.new()
    TriggerEvent("redemrp:getPlayerFromId", self.source, function(_user)
      user:resolve(_user)
    end)
    self.data = Citizen.Await(user)
  elseif jo.framework:is("QBR") then
    self.data = jo.framework.core:GetPlayer(self.source)
  elseif jo.framework:is("RSG") or jo.framework:is("QR") then
    self.data = jo.framework.core.Functions.GetPlayer(self.source)
  elseif jo.framework:is("RPX") then
    self.data = jo.framework.core.GetPlayer(self.source)
  end
end

---@param moneyType integer 0: money, 1: gold, 2: rol
---@return number
function User:getMoney(moneyType)
  moneyType = moneyType or 0
  if OWFramework.User.getMoney then
    return OWFramework.User.getMoney(self.source, moneyType)
  end
  if jo.framework:is("VORP") then
    if moneyType == 0 then
      return self.data.money
    elseif moneyType == 1 then
      return self.data.gold
    elseif moneyType == 2 then
      return self.data.rol
    end
  elseif jo.framework:is("RedEM2023") then
    if moneyType == 0 then
      return self.data.money
    elseif moneyType == 1 then
      return OWFramework.User.getSecondMoney(source)
    elseif moneyType == 2 then
      return OWFramework.User.getThirdMoney(source)
    end
  elseif jo.framework:is("RedEM") then
    if moneyType == 0 then
      return self.data.getMoney()
    elseif moneyType == 1 then
      return self.data.getGold()
    elseif moneyType == 2 then
      return OWFramework.User.getThirdMoney(source)
    end
  elseif jo.framework:is("QBR") or jo.framework:is("RSG") or jo.framework:is("QR") then
    if moneyType == 0 then
      return self.data.Functions.GetMoney("cash")
    elseif moneyType == 1 then
      return OWFramework.User.getSecondMoney(source)
    elseif moneyType == 2 then
      return OWFramework.User.getThirdMoney(source)
    end
  end
  return 0
end

---@param price number price
---@param moneyType integer 0: money, 1: gold, 2: rol
---@param removeIfCan? boolean (optional) default: false
---@return boolean
function User:canBuy(price, moneyType, removeIfCan)
  moneyType = moneyType or 0
  if not price then
    return false, eprint("PRICE IS NIL !")
  end
  local money = self:getMoney(moneyType)
  local hasEnough = money >= price
  if removeIfCan == true and hasEnough then
    self:removeMoney(price, moneyType)
  end
  return hasEnough
end

---@param amount number amount to remove
---@param moneyType integer 0: money, 1: gold, 2: rol
function User:removeMoney(amount, moneyType)
  moneyType = moneyType or 0
  if OWFramework.User.removeMoney then
    return OWFramework.User.removeMoney(self, amount, moneyType)
  elseif jo.framework:is("VORP") then
    self.data.removeCurrency(moneyType, amount)
  elseif jo.framework:is("RedEM2023") then
    if moneyType == 0 then
      self.data.RemoveMoney(amount)
    elseif moneyType == 1 then
      OWFramework.User.removeSecondMoney(self.source, amount)
    elseif moneyType == 2 then
      OWFramework.User.removeThirdMoney(self.source, amount)
    end
  elseif jo.framework:is("RedEM") then
    if moneyType == 0 then
      self.data.removeMoney(amount)
    elseif moneyType == 1 then
      self.data.removeGold(amount)
    elseif moneyType == 2 then
      OWFramework.User.removeThirdMoney(self.source, amount)
    end
  elseif jo.framework:is("QBR") or jo.framework:is("RSG") or jo.framework:is("QR") then
    if moneyType == 0 then
      self.data.Functions.RemoveMoney("cash", amount)
    elseif moneyType == 1 then
      OWFramework.User.removeSecondMoney(self.source, amount)
    elseif moneyType == 2 then
      OWFramework.User.removeThirdMoney(self.source, amount)
    end
  elseif jo.framework:is("RPX") then
    if moneyType == 0 then
      self.data.RemoveMoney("cash", amount)
    elseif moneyType == 1 then
      OWFramework.User.removeSecondMoney(self.source, amount)
    elseif moneyType == 2 then
      OWFramework.User.removeThirdMoney(self.source, amount)
    end
  end
end

---@param amount number amount to remove
---@param moneyType integer 0: money, 1: gold, 2: rol
function User:addMoney(amount, moneyType)
  moneyType = moneyType or 0
  if OWFramework.User.addMoney then
    return OWFramework.User.addMoney(self.source, amount, moneyType)
  end
  if jo.framework:is("VORP") then
    self.data.addCurrency(moneyType, amount)
  elseif jo.framework:is("RedEM2023") then
    if moneyType == 0 then
      self.data.AddMoney(amount)
    elseif moneyType == 1 then
      if not OWFramework.User.addSecondMoney then
        jo.notif.print(self.source, "Gold in not supported by your Framework")
        jo.notif.print(self.source, "Please check jo_libs docs to add OWFramework.User.addSecondMoney()")
        return
      end
      OWFramework.User.addSecondMoney(self.source, amount)
    elseif moneyType == 2 then
      if not OWFramework.User.addSecondMoney then
        jo.notif.print(self.source, "Gold in not supported by your Framework")
        jo.notif.print(self.source, "Please check jo_libs docs to add OWFramework.User.addSecondMoney()")
        return
      end
      OWFramework.User.addThirdMoney(self.source, amount)
    end
  elseif jo.framework:is("RedEM") then
    if moneyType == 0 then
      self.data.addMoney(amount)
    elseif moneyType == 1 then
      self.data.addGold(amount)
    elseif moneyType == 2 then
      OWFramework.User.addThirdMoney(self.source, amount)
    end
  elseif jo.framework:is("QBR") or jo.framework:is("RSG") or jo.framework:is("QR") then
    if moneyType == 0 then
      self.data.Functions.AddMoney("cash", amount)
    elseif moneyType == 1 then
      if not OWFramework.User.addSecondMoney then
        jo.notif.print(self.source, "Gold in not supported by your Framework")
        jo.notif.print(self.source, "Please check jo_libs docs to add OWFramework.User.addSecondMoney()")
        return
      end
      OWFramework.User.addSecondMoney(self.source, amount)
    elseif moneyType == 2 then
      if not OWFramework.User.addSecondMoney then
        jo.notif.print(self.source, "Gold in not supported by your Framework")
        jo.notif.print(self.source, "Please check jo_libs docs to add OWFramework.User.addSecondMoney()")
        return
      end
      OWFramework.User.addThirdMoney(self.source, amount)
    end
  end
end

---@param amount number amount of gold
function User:giveGold(amount)
  self:addMoney(amount, 1)
end

function User:getIdentifiers()
  if OWFramework.User.getIdentifiers then
    return OWFramework.User.getIdentifiers(self.source)
  end

  if not self.data then return {} end

  if jo.framework:is("VORP") then
    return {
      identifier = self.data.identifier,
      charid = self.data.charIdentifier
    }
  elseif jo.framework:is("RedEM2023") then
    return {
      identifier = self.data.identifier,
      charid = self.data.charid
    }
  elseif jo.framework:is("RedEM") then
    return {
      identifier = self.data.getIdentifier(),
      charid = self.data.getSessionVar("charid")
    }
  elseif jo.framework:is("QBR") or jo.framework:is("RSG") or jo.framework:is("QR") then
    return {
      identifier = self.data.PlayerData.citizenid,
      charid = 0
    }
  end
end

---@return string job
function User:getJob()
  if OWFramework.User.getJob then
    return OWFramework.User.getJob(self.source)
  elseif jo.framework:is("VORP") or jo.framework:is("RedEM2023") then
    return self.data.job
  elseif jo.framework:is("RedEM") then
    return self.data.getJob()
  elseif jo.framework:is("QBR") or jo.framework:is("RSG") or jo.framework:is("QR") then
    return self.data.PlayerData.job.name
  end
  return ""
end

---@return string name
function User:getRPName()
  if OWFramework.User.getRPName then
    return OWFramework.User.getRPName(self.source)
  end
  if jo.framework:is("VORP") or jo.framework:is("RedEM2023") or jo.framework:is("RedEM") then
    return ("%s %s"):format(self.data.firstname, self.data.lastname)
  elseif jo.framework:is("QBR") or jo.framework:is("RSG") or jo.framework:is("QR") then
    return ("%s %s"):format(self.data.PlayerData.charinfo.firstname, self.data.PlayerData.charinfo.lastname)
  end
  return source .. ""
end

jo.User = User

-------------
-- END USER CLASS
-------------

-------------
-- FRAMEWORK CLASS
-------------

---@class FrameworkClass : table Framework class
---@field name string @FrameworkClass name
---@field core table  @FrameworkClass core
---@field inv table @FrameworkClass inventory
local FrameworkClass = {
  name = "",
  core = {},
  inv = {},
  inventories = {}
}
---@return FrameworkClass FrameworkClass class
function FrameworkClass:new(t)
  t = table.copy(FrameworkClass)
  t:init()
  return t
end

function FrameworkClass:init()
  if OWFramework.initFramework then
    return OWFramework.initFramework(self)
  elseif self:is("VORP") then
    bprint("VORP detected")
    Wait(100)
    TriggerEvent("getCore", function(core)
      self.core = core
      self.inv = exports.vorp_inventory
    end)
    return
  elseif self:is("RedEM2023") then
    bprint("RedEM:RP 2023 detected")
    self.core = exports["redem_roleplay"]:RedEM()
    TriggerEvent("redemrp_inventory:getData", function(call)
      self.inv = call
    end)
    return
  elseif self:is("RedEM") then
    bprint("RedEM:RP OLD detected")
    TriggerEvent("redemrp_inventory:getData", function(call)
      self.inv = call
    end)
    return
  elseif self:is("QBR") then
    bprint("QBR detected")
    self.core = self.core
    return
  elseif self:is("RSG") then
    self.core = exports["rsg-core"]:GetCoreObject()
    self.coreVersion = GetResourceMetadata("rsg-core", "version", 0) or 1
    if ("2.0.0"):convertVersion() <= self.coreVersion:convertVersion() then
      self.inv = exports["rsg-inventory"]
      self.isV2 = true
      bprint("RSG V2 detected")
    else
      self.isV2 = false
      bprint("RSG V1 detected")
    end
    return
  elseif self:is("QR") then
    bprint("QR detected")
    self.core = exports["qr-core"]:GetCoreObject()
    return
  elseif self:is("RPX") then
    bprint("RPX detected")
    self.inv = exports["rpx-inventory"]
  end
  eprint("No compatible Framework detected. Please contact JUMP ON studios on discord")
end

---@return string Name of the framework
function FrameworkClass:get()
  if self.name ~= "" then return self.name end

  if OWFramework.get then
    self.name = OWFramework.get()
  else
    for framework, resources in pairs(mainResourceFramework) do
      local rightFramework = true
      for _, resource in pairs(resources) do
        if resource:sub(1, 1) == "!" then
          if GetResourceState(resource) ~= "missing" then
            rightFramework = false
            break
          end
        else
          if GetResourceState(resource) == "missing" then
            rightFramework = false
            break
          end
        end
      end
      if rightFramework then
        self.name = framework
        for _, resource in pairs(resources) do
          if resource:sub(1, 1) ~= "!" then
            while GetResourceState(resource) ~= "started" do
              bprint("Waiting start of " .. framework)
              Wait(1000)
            end
          end
        end
        return self.name
      end
    end
  end
  return self.name
end

---@param name string Name of the framework
---@return boolean
function FrameworkClass:is(name)
  return self:get() == name
end

-------------
-- END FRAMEWORK CLASS
-------------

-------------
-- USER DATA
-------------

---@param source integer source ID
---@return table
function FrameworkClass:getUser(source)
  local user = User:get(source)
  return user
end

---@param source integer source ID
---@return table identifier
function FrameworkClass:getUserIdentifiers(source)
  local user = User:get(source)
  return user:getIdentifiers()
end

---@param source integer source ID
---@return string job Player job
function FrameworkClass:getJob(source)
  local user = User:get(source)
  return user:getJob()
end

---@param source integer source ID
function FrameworkClass:getRPName(source)
  local user = User:get(source)
  return user:getRPName()
end

-------------
-- END USER DATA
-------------

-------------
-- MONEY
-------------

---@param source integer
---@param amount number
---@param moneyType? integer 0: money, 1: gold, 2: rol
---@param removeIfCan? boolean (optinal) default : false
---@return boolean
function FrameworkClass:canUserBuy(source, amount, moneyType, removeIfCan)
  local user = User:get(source)
  return user:canBuy(amount, moneyType or 0, removeIfCan)
end

---@param source integer
---@param amount number
---@param moneyType? integer 0: money, 1: gold, 2: rol
function FrameworkClass:addMoney(source, amount, moneyType)
  local user = User:get(source)
  user:addMoney(amount, moneyType or 0)
end

-------------
-- END MONEY
-------------

-------------
-- INVENTORY
-------------

---@param source integer source ID
---@param item string name of the item
---@param amount integer amount to use
---@param meta table metadata of the item
---@param remove boolean if removed after used
function FrameworkClass:canUseItem(source, item, amount, meta, remove)
  if OWFramework.canUseItem then
    return OWFramework.canUseItem(source, item, amount, meta, remove)
  end
  if self:is("VORP") then
    local count = self.inv:getItemCount(source, nil, item, meta)
    if count >= amount then
      if remove then
        self.inv:subItem(source, item, amount, meta)
      end
      return true
    end
    return false
  elseif self:is("RedEM") or self:is("RedEM2023") then
    local itemData = self.inv.getItem(source, item)
    if itemData and itemData.ItemAmount >= amount then
      if remove then
        itemData.RemoveItem(amount)
      end
      return true
    end
  elseif self:is("QBR") or self:is("RSG") or self:is("QR") then
    local Player = User:get(source)
    local itemData = Player.data.Functions.GetItemByName(item)
    if itemData and itemData.amount >= amount then
      if remove then
        Player.data.Functions.RemoveItem(item, amount)
      end
      return true
    end
  end
  return false
end

---@param item string name of the item
---@param callback function function fired when the item is used
---@param closeAfterUsed boolean if inventory needs to be closes
function FrameworkClass:registerUseItem(item, closeAfterUsed, callback)
  CreateThread(function()
    if (closeAfterUsed == nil) then closeAfterUsed = true end
    if OWFramework.registerUseItem then
      OWFramework.registerUseItem(item, closeAfterUsed, callback)
    elseif self:is("VORP") then
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
    elseif self:is("RedEM2023") or self:is("RedEM") then
      local isExist = self.inv.getItemData(item)
      local count = 0
      while not isExist and count < 10 do
        isExist = self.inv.getItemData(item)
        count = count + 1
        Wait(1000)
      end
      if not isExist then
        return eprint(item .. " < item does not exist in the inventory configuration")
      end
      AddEventHandler("RegisterUsableItem:" .. item, function(source, data)
        callback(source, { metadata = data.meta })
        if closeAfterUsed then
          TriggerClientEvent("redemrp_inventory:closeinv", source)
        end
      end)
    elseif self:is("QBR") then
      local isAdded = self.core:AddItem(item, nil)
      if isAdded then
        return eprint(item .. " < item does not exist in the core configuration")
      end
      self.core:CreateUseableItem(item, function(source, data)
        callback(source, { metadata = data.info })
        if closeAfterUsed then
          TriggerClientEvent("qbr-inventory:client:closeinv", source)
        end
      end)
    elseif self:is("RSG") and self.isV2 then
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
    elseif self:is("RSG") or self:is("QR") then
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
  end)
end

---@param source integer source ID
---@param item string name of the item
---@param quantity integer quantity
---@param meta table metadata of the item
---@return boolean
function FrameworkClass:giveItem(source, item, quantity, meta)
  if OWFramework.giveItem then
    return OWFramework.giveItem(source, item, quantity, meta)
  elseif self:is("VORP") then
    if self.inv:canCarryItem(source, item, quantity) then
      self.inv:addItem(source, item, quantity, meta)
      return true
    end
    return false
  elseif self:is("RedEM2023") or self:is("RedEM") then
    local ItemData = self.inv.getItem(source, item, meta) -- this give you info and functions
    return ItemData.AddItem(quantity, meta)
  elseif self:is("QBR") or self:is("RSG") or self:is("QR") then
    local Player = User:get(source)
    return Player.data.Functions.AddItem(item, quantity, false, meta)
  elseif GetFramework() == "RPX" then
    return self.inv:AddItem(source, item, quantity, meta)
  end
  return false
end

function FrameworkClass:removeItem(source, item, quantity, meta)
  return self:canUseItem(source, item, quantity, meta, true)
end

---@param invName string unique ID of the inventory
---@param name string name of the inventory
---@param invConfig table Configuration of the inventory
function FrameworkClass:createInventory(invName, name, invConfig)
  self.inventories[invName] = {
    invName = invName,
    name = name,
    invConfig = invConfig
  }
  if OWFramework.createInventory then
    OWFramework.createInventory(invName, name, invConfig)
  elseif self:is("VORP") then
    local invConfig = invConfig
    self.inv:registerInventory({
      id = invName,
      name = name,
      limit = invConfig.maxSlots,
      acceptWeapons = invConfig.acceptWeapons or false,
      shared = invConfig.shared or true,
      ignoreItemStackLimit = invConfig.ignoreStackLimit or true,
      whitelistItems = invConfig.whitelist and true or false,
    })
    for _, data in pairs(invConfig.whitelist or {}) do
      self.inv:setCustomInventoryItemLimit(invName, data.item, data.limit)
    end
  elseif self:is("RedEM") then
    self.inv.createLocker(invName, "empty")
  end
end

function FrameworkClass:removeInventory(invName)
  if OWFramework.removeInventory then
    OWFramework.removeInventory(invName)
  elseif self:is("VORP") then
    self.inv:removeInventory(invName)
  end
end

---@param source integer sourceIdentifier
---@param invName string name of the inventory
function FrameworkClass:openInventory(source, invName)
  local name = self.inventories[invName].name
  local invConfig = self.inventories[invName].invConfig
  if OWFramework.openInventory then
    return OWFramework.openInventory(source, invName, name, invConfig)
  elseif self:is("VORP") then
    self:createInventory(invName, name, invConfig)
    return self.inv:openInventory(source, invName)
  end
  if self:is("RedEM2023") then
    TriggerClientEvent("redemrp_inventory:OpenStash", source, invName, invConfig.maxWeight)
    return
  end
  if self:is("RedEM") then
    TriggerClientEvent("redemrp_inventory:OpenLocker", source, invName)
    return
  end
  if self:is("RSG") and self.isV2 then
    local data = {
      label = self.inventories[invName].name,
      maxweight = self.inventories[invName].invConfig.maxWeight,
      slots = self.inventories[invName].invConfig.maxSlots
    }
    self.inv:OpenInventory(source, invName, data)
    return
  end
  if self:is("RSG") or self:is("QBR") or self:is("QR") then
    TriggerClientEvent(GetCurrentResourceName() .. ":client:openInventory", source, invName, invConfig)
    return
  end
end

---@param invId string unique ID of the inventory
---@param item string name of the item
---@param quantity integer quantity
---@param metadata table metadata of the item
---@param needWait? boolean wait after the adding
function FrameworkClass:addItemInInventory(source, invId, item, quantity, metadata, needWait)
  local waiter = promise.new()
  if OWFramework.addItemInInventory then
    OWFramework.addItemInInventory(invId, item, quantity, metadata, needWait)
  elseif self:is("VORP") then
    local itemId = self.inv:getItemDB(item).id
    local user = User:get(source)
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
  elseif self:is("RSG") and self.isV2 then
    self.inv:CreateInventory(invId)
    return self.inv:AddItem(invId, item, quantity, false, metadata)
  elseif self:is("QBR") or self:is("RSG") or self:is("RPX") then
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
    end)
  elseif self:is("RedEM2023") then
    self.inv.addItemStash(source, item, 1, metadata, invId)
    waiter:resolve(true)
  elseif self:is("RedEM") then
    self.inv.addItemLocker(item, 1, metadata, invId)
  end
  if needWait then
    Citizen.Await(waiter)
  end
end

---@param source integer source ID
---@param invId string name of the inventory
function FrameworkClass:getItemsFromInventory(source, invId)
  if OWFramework.getItemsFromInventory then
    return OWFramework.getItemsFromInventory(source, invId)
  elseif self:is("VORP") then
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
  elseif self:is("RSG") and self.isV2 then
    local inventory = self.inv:GetInventory(invId) or { items = {} }
    local itemFiltered = {}
    for _, item in pairs(inventory.items) do
      itemFiltered[#itemFiltered + 1] = {
        metadata = item.info,
        amount = item.amount,
        item = item.name
      }
    end
    return itemFiltered
  elseif self:is("QBR") or self:is("RSG") or self:is("RPX") then
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
  elseif self:is("RedEM2023") then
    local items = self.inv.getStash(invId)
    if not items then items = {} end
    local itemFiltered = {}
    for _, item in pairs(items) do
      itemFiltered[#itemFiltered + 1] = {
        metadata = item.meta,
        amount = item.amount,
        item = item.name
      }
    end
    return itemFiltered
  elseif self:is("RedEM") then
    local items = self.inv.getLocker(invId)
    if not items then items = {} end
    local itemFiltered = {}
    for _, item in pairs(items) do
      itemFiltered[#itemFiltered + 1] = {
        metadata = item.meta,
        amount = item.amount,
        item = item.name
      }
    end
    return itemFiltered
  end
  return {}
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

---@param key string
local function isOverlayKey(key)
  if skinCategoryBridge[jo.framework:get()].overlays[key] then return false end
  for search, layerName in pairs(skinCategoryBridge[jo.framework:get()].overlays) do
    if key:find(search) then
      if key == search then
        return false
      end
      return layerName
    end
  end
  return false
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

local function revertOverlays(reverted)
  local rights = {
    VORP = {},
    RSG = {
      opacity = "_op",
      id = "_t",
      sheetGrid = "_id",
      tint0 = "_c1",
      tint1 = "_c2",
      tint3 = "_c3",
      albedo = "_id"
    }
  }

  for prefix, layerName in pairs(skinCategoryBridge[jo.framework:get()].overlays) do
    if reverted.overlays[layerName] then
      if reverted.overlays[layerName][1] then
      else
        for key, value in pairs(reverted.overlays[layerName]) do
          local suffix = rights[jo.framework:get()]?[key]
          if suffix then
            if layerName == "eyebrow" and key == "id" then
              value = value + 1
              if reverted.overlays.eyebrow.sexe == "f" then
                reverted[prefix .. suffix] = value + 15
              else
                reverted[prefix .. suffix] = value
              end
              reverted.overlays.eyebrow.id = nil
              reverted.overlays.eyebrow.sexe = nil
            elseif layerName == "hair" and key == "albedo" then
              if value == "mp_u_faov_m_hair_000" then
                reverted[prefix .. suffix] = 1
              elseif value == "mp_u_faov_m_hair_002" then
                reverted[prefix .. suffix] = 2
              elseif value == "mp_u_faov_m_hair_009" then
                reverted[prefix .. suffix] = 3
              elseif value == "mp_u_faov_m_hair_shared_000" then
                reverted[prefix .. suffix] = 4
              end
              reverted.overlays[layerName][key] = nil
            elseif key == "id" then
              reverted[prefix .. suffix] = value + 1
              reverted.overlays[layerName][key] = nil
            elseif key == "opacity" then
              reverted[prefix .. suffix] = value
              if jo.framework:is("RSG") then
                reverted[prefix .. suffix] = reverted[prefix .. suffix] * 100
              end
              reverted.overlays[layerName][key] = nil
            else
              reverted[prefix .. suffix] = value
              reverted.overlays[layerName][key] = nil
            end
          end
        end
      end
      if table.count(reverted.overlays[layerName]) == 0 then
        reverted.overlays[layerName] = nil
      end
    end
  end
  if table.count(reverted.overlays) == 0 then
    reverted.overlays = nil
  end
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

local function revertRSGSkin(standard)
  if standard.bodyScale then
    standard.height = math.floor(standard.bodyScale * 100)
    standard.bodyScale = nil
  end
  for key, _ in pairs(skinCategoryBridge.RSG.expressions) do
    if standard[key] then
      if standard[key] > -1 and standard[key] < 1 then
        standard[key] = math.floor(standard[key] * 100)
      end
    end
  end
  if standard.skinTone then
    _, standard.skin_tone = table.find(skinCategoryBridge.RSG.convertedValues.skin_tone, function(value, key) return value == standard.skinTone end)
    standard.skinTone = nil
  end
  if standard.headIndex then
    _, standard.head = table.find(skinCategoryBridge.RSG.convertedValues.head[standard.model], function(value, key) return value == standard.headIndex end)
    standard.head = math.max(1, (standard.head or standard.headIndex or 0) * 6)
    standard.headIndex = nil
  end
  if standard.bodiesIndex then
    _, standard.body_size = table.find(skinCategoryBridge.RSG.convertedValues.bodies[standard.model], function(value, key) return value == standard.bodiesIndex end)
    standard.body_size = standard.body_size or standard.bodiesIndex
    standard.bodiesIndex = nil
  end
  if standard.model then
    standard.sex = standard.model == "mp_female" and 2 or 1
    standard.model = nil
  end
end

--- A function to standardize a object of categories
local function standardizeSkin(object)
  object = table.copy(object)
  local standard = {}

  if jo.framework:is("VORP") then
    standard.model = table.extract(object, "sex")
    standard.headHash = table.extract(object, "HeadType")
    standard.bodyUpperHash = object.BodyType ~= 0 and object.BodyType or object.Torso
    object.BodyType = nil
    object.Torso = nil
    standard.bodyLoverHash = object.LegsType ~= 0 and object.LegsType or object.Legs
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
      id = object.ageing_tx_id - 1,
      opacity = convertToPercent(object.ageing_opacity)
    }
    object.ageing_tx_id = nil
    object.ageing_opacity = nil
    object.ageing_visibility = nil

    standard.overlays.beard = needOverlay(object.beardstabble_visibility) and {
      id = 1,
      tint0 = object.beardstabble_color_primary,
      opacity = convertToPercent(object.beardstabble_opacity)
    }
    object.beardstabble_color_primary = nil
    object.beardstabble_opacity = nil
    object.beardstabble_visibility = nil

    standard.overlays.blush = needOverlay(object.blush_visibility) and {
      id = object.blush_tx_id - 1,
      tint0 = object.blush_palette_color_primary,
      opacity = convertToPercent(object.blush_opacity)
    }
    object.blush_tx_id = nil
    object.blush_palette_color_primary = nil
    object.blush_opacity = nil
    object.blush_visibility = nil

    standard.overlays.eyebrow = needOverlay(object.eyebrows_visibility) and (function()
      local id = object.eyebrows_tx_id - 1
      local sexe = "m"
      if id > 15 then
        id = id - 15
        sexe = "f"
      end
      return {
        id = id,
        sexe = sexe,
        tint0 = object.eyebrows_color,
        sheetGrid = object.eyebrows_palette_id - 1,
        opacity = convertToPercent(object.eyebrows_opacity)
      }
    end)()
    object.eyebrows_tx_id = nil
    object.eyebrows_color = nil
    object.eyebrows_palette_id = nil
    object.eyebrows_opacity = nil
    object.eyebrows_visibility = nil

    standard.overlays.eyeliner = needOverlay(object.eyeliner_visibility) and {
      id = object.eyeliner_tx_id - 1,
      sheetGrid = object.eyeliner_palette_id - 1,
      tint0 = object.eyeliner_color_primary,
      opacity = convertToPercent(object.eyeliner_opacity)
    }
    object.eyeliner_tx_id = nil
    object.eyeliner_palette_id = nil
    object.eyeliner_color_primary = nil
    object.eyeliner_opacity = nil
    object.eyeliner_visibility = nil

    standard.overlays.eyeshadow = needOverlay(object.shadows_visibility) and {
      id = 1,
      sheetGrid = object.shadows_palette_id - 1,
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
      id = object.freckles_tx_id - 1,
      opacity = convertToPercent(object.freckles_opacity)
    }
    object.freckles_tx_id = nil
    object.freckles_opacity = nil
    object.freckles_visibility = nil

    standard.overlays.lipstick = needOverlay(object.lipsticks_visibility) and {
      id = 1,
      sheetGrid = object.lipsticks_palette_id - 1,
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
      id = object.moles_tx_id - 1,
      opacity = convertToPercent(object.moles_opacity)
    }
    object.moles_tx_id = nil
    object.moles_opacity = nil
    object.moles_visibility = nil

    standard.overlays.scar = needOverlay(object.scars_visibility) and {
      id = object.scars_tx_id - 1,
      opacity = convertToPercent(object.scars_opacity)
    }
    object.scars_tx_id = nil
    object.scars_opacity = nil
    object.scars_visibility = nil

    standard.overlays.spots = needOverlay(object.spots_visibility) and {
      id = object.spots_tx_id - 1,
      opacity = convertToPercent(object.spots_opacity)
    }
    object.spots_tx_id = nil
    object.spots_opacity = nil
    object.spots_visibility = nil

    standard.overlays.acne = needOverlay(object.acne_visibility) and {
      id = object.acne_tx_id - 1,
      opacity = convertToPercent(object.acne_opacity)
    }
    object.acne_tx_id = nil
    object.acne_opacity = nil
    object.acne_visibility = nil

    standard.overlays.grime = needOverlay(object.grime_visibility) and {
      id = object.grime_tx_id - 1,
      opacity = convertToPercent(object.grime_opacity)
    }
    object.grime_tx_id = nil
    object.grime_opacity = nil
    object.grime_visibility = nil

    standard.overlays.hair = needOverlay(object.hair_visibility) and {
      id = object.hair_tx_id - 1,
      tint0 = object.hair_color_primary,
      opacity = convertToPercent(object.hair_opacity)
    }
    object.hair_tx_id = nil
    object.hair_color_primary = nil
    object.hair_opacity = nil
    object.hair_visibility = nil

    standard.overlays.complex = needOverlay(object.complex_visibility) and {
      id = object.complex_tx_id - 1,
      opacity = convertToPercent(object.complex_opacity)
    }
    object.complex_tx_id = nil
    object.complex_opacity = nil
    object.complex_visibility = nil

    standard.overlays.disc = needOverlay(object.disc_visibility) and {
      id = object.disc_tx_id - 1,
      opacity = convertToPercent(object.disc_opacity)
    }
    object.disc_tx_id = nil
    object.disc_opacity = nil
    object.disc_visibility = nil

    standard.overlays.foundation = needOverlay(object.foundation_visibility) and {
      id = object.foundation_tx_id - 1,
      tint0 = object.foundation_palette_color_primary,
      tint1 = object.foundation_palette_color_secondary,
      tint2 = object.foundation_palette_color_tertiary,
      sheetGrid = object.foundation_palette_id - 1,
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
      id = object.paintedmasks_tx_id - 1,
      tint0 = object.paintedmasks_palette_color_primary,
      tint1 = object.paintedmasks_palette_color_secondary,
      tint2 = object.paintedmasks_palette_color_tertiary,
      sheetGrid = object.paintedmasks_palette_id - 1,
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
  elseif jo.framework:is("RSG") then
    local skin_tone = { 1, 4, 3, 5, 2, 6 }
    local heads = {
      mp_male = { [16] = 18, [17] = 21, [18] = 22, [19] = 25, [20] = 28 },
      mp_female = { [17] = 20, [18] = 22, [19] = 27, [20] = 28 }
    }
    local bodies = { 2, 1, 3, 4, 5, 6 }

    standard.model = table.extract(object, "sex") == 2 and "mp_female" or "mp_male"
    standard.bodiesIndex = bodies[object.body_size] or object.body_size
    object.body_size = nil
    standard.eyesIndex = table.extract(object, "eye_color")
    standard.headIndex = heads[standard.model][math.ceil(object.head / 6)] or math.ceil(object.head / 6)
    object.head = nil
    standard.skinTone = skin_tone[table.extract(object, "skin_tone")]
    standard.teethIndex = table.extract(object, "teethIndex")
    standard.hair = table.extract(object, "hair")
    if standard.model == "mp_male" then
      standard.beards_complete = table.extract(object, "beard")
    end
    standard.bodyScale = convertToPercent(table.extract(object, "height"))

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

    standard.overlays = {
      ageing = object.ageing_t and {
        id = table.extract(object, "ageing_t") - 1,
        opacity = convertToPercent(table.extract(object, "ageing_op"))
      },
      beard = object.beardstabble_t and {
        id = table.extract(object, "beardstabble_t"),
        opacity = convertToPercent(table.extract(object, "beardstabble_op"))
      },
      blush = object.blush_t and {
        id = table.extract(object, "blush_t") - 1,
        palette = table.extract(object, "blush_id"),
        tint0 = table.extract(object, "blush_c1"),
        opacity = convertToPercent(table.extract(object, "blush_op"))
      },
      eyebrow = object.eyebrow_t and (function()
        local id = table.extract(object, "eyebrow_t") - 1
        local sexe = "m"
        if id > 15 then
          id = id - 15
          sexe = "f"
        end
        return {
          id = id,
          sexe = sexe,
          palette = table.extract(object, "eyebrow_id"),
          tint0 = table.extract(object, "eyebrow_c1"),
          opacity = convertToPercent(table.extract(object, "eyebrow_op"))
        }
      end)(),
      eyeliner = object.eyeliner_t and {
        id = 1,
        sheetGrid = table.extract(object, "eyeliner_t") - 1,
        palette = table.extract(object, "eyeliner_id"),
        tint0 = table.extract(object, "eyeliner_c1"),
        opacity = convertToPercent(table.extract(object, "eyeliner_op"))
      },
      eyeshadow = object.shadows_t and {
        id = 1,
        sheetGrid = table.extract(object, "shadows_t") - 1,
        palette = table.extract(object, "shadows_id"),
        tint0 = table.extract(object, "shadows_c1"),
        opacity = convertToPercent(table.extract(object, "shadows_op"))
      },
      freckles = object.freckles_t and {
        id = table.extract(object, "freckles_t") - 1,
        opacity = convertToPercent(table.extract(object, "freckles_op"))
      },
      lipstick = object.lipstick_t and {
        id = 1,
        sheetGrid = table.extract(object, "lipstick_t") - 1,
        palette = table.extract(object, "lipstick_id"),
        tint0 = table.extract(object, "lipstick_c1"),
        opacity = convertToPercent(table.extract(object, "lipstick_op"))
      },
      moles = object.moles_t and {
        id = table.extract(object, "moles_t") - 1,
        opacity = convertToPercent(table.extract(object, "moles_op"))
      },
      scar = object.scars_t and {
        id = table.extract(object, "scars_t") - 1,
        opacity = convertToPercent(table.extract(object, "scars_op"))
      },
      spots = object.spots_t and {
        id = table.extract(object, "spots_t") - 1,
        opacity = convertToPercent(table.extract(object, "spots_op"))
      },
      -- acne = {},
      -- foundation = {},
      -- grime = {},
      -- hair = {},
      -- masks = {},
      -- complex = {},
      -- disc = {},
    }
  end

  TriggerEvent("print", "clé restante =>", object)

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

  return standard
end
FrameworkClass.standardizeSkin = standardizeSkin
FrameworkClass.standardizeSkinKeys = standardizeSkin

---@param data any the clothes data
---@return table
local function formatComponentData(data)
  if type(data) == "table" then
    if data.comp then
      data.hash = data.comp
      data.comp = nil
    end
    if not data.hash or data.hash == 0 or data.hash == -1 then return nil end
    if type(data.hash) == "table" then --for VORP
      return data.hash
    end
    return data
  end
  if type(data) ~= "number" then data = tonumber(data) end
  if data == 0 or data == -1 or data == 1 or data == nil then
    return nil
  end
  return {
    hash = data
  }
end

--- A function to revert a object of categories
local function revertSkin(standard)
  standard = table.copy(standard)

  local reverted = {}

  if jo.framework:is("VORP") then
    reverted.sex = standard.model
    reverted.HeadType = standard.headHash
    reverted.Torse = standard.bodyUpperHash
    reverted.BodyType = standard.bodyUpperHash
    reverted.Legs = standard.bodyLoverHash
    reverted.LegsType = standard.bodyLoverHash
    reverted.Eyes = standard.eyesHash
    reverted.Teeth = standard.teethHash
    reverted.Hair = standard.hair
    reverted.Beard = standard.beards_complete
    reverted.Body = standard.bodyType
    reverted.Waist = standard.bodyWeight
    reverted.Scale = standard.bodyScale

    reverted.ArmsS = standard.expressions.arms
    reverted.CalvesS = standard.expressions.calves
    reverted.CheekBonesD = standard.expressions.cheekbonesDepth
    reverted.CheekBonesH = standard.expressions.cheekbonesHeight
    reverted.CheekBonesW = standard.expressions.cheekbonesWidth
    reverted.ChestS = standard.expressions.chest
    reverted.ChinD = standard.expressions.chinDepth
    reverted.ChinH = standard.expressions.chinHeight
    reverted.ChinW = standard.expressions.chinWidth
    reverted.EarsD = standard.expressions.earlobes
    reverted.EarsA = standard.expressions.earsAngle
    reverted.earsDepth = standard.expressions.earsDepth
    reverted.EarsH = standard.expressions.earsHeight
    reverted.EarsW = standard.expressions.earsWidth
    reverted.EyeBrowD = standard.expressions.eyebrowDepth
    reverted.EyeBrowH = standard.expressions.eyebrowHeight
    reverted.EyeBrowW = standard.expressions.eyebrowWidth
    reverted.EyeLidH = standard.expressions.eyelidHeight
    reverted.EyeLidL = standard.expressions.eyelidLeft
    reverted.EyeLidR = standard.expressions.eyelidRight
    reverted.EyeLidW = standard.expressions.eyelidWidth
    reverted.EyeAng = standard.expressions.eyesAngle
    reverted.EyeD = standard.expressions.eyesDepth
    reverted.EyeDis = standard.expressions.eyesDistance
    reverted.EyeH = standard.expressions.eyesHeight
    reverted.FaceW = standard.expressions.faceWidth
    reverted.HeadSize = standard.expressions.headWidth
    reverted.HipsS = standard.expressions.hip
    reverted.JawD = standard.expressions.jawDepth
    reverted.JawH = standard.expressions.jawHeight
    reverted.JawW = standard.expressions.jawWidth
    reverted.jawY = standard.expressions.jawY
    reverted.LLiphD = standard.expressions.lowerLipDepth
    reverted.LLiphH = standard.expressions.lowerLipHeight
    reverted.LLiphW = standard.expressions.lowerLipWidth
    reverted.MouthCLD = standard.expressions.mouthConerLeftDepth
    reverted.MouthCLH = standard.expressions.mouthConerLeftHeight
    reverted.MouthCLLD = standard.expressions.mouthConerLeftLipsDistance
    reverted.MouthCLW = standard.expressions.mouthConerLeftWidth
    reverted.MouthCRD = standard.expressions.mouthConerRightDepth
    reverted.MouthCRH = standard.expressions.mouthConerRightHeight
    reverted.MouthCRLD = standard.expressions.mouthConerRightLipsDistance
    reverted.MouthCRW = standard.expressions.mouthConerRightWidth
    reverted.MouthD = standard.expressions.mouthDepth
    reverted.MouthW = standard.expressions.mouthWidth
    reverted.MouthX = standard.expressions.mouthX
    reverted.MouthY = standard.expressions.mouthY
    reverted.NeckD = standard.expressions.neckDepth
    reverted.NeckW = standard.expressions.neckWidth
    reverted.NoseAng = standard.expressions.noseAngle
    reverted.NoseC = standard.expressions.noseCurvature
    reverted.NoseH = standard.expressions.noseHeight
    reverted.NoseS = standard.expressions.noseSize
    reverted.NoseW = standard.expressions.noseWidth
    reverted.NoseDis = standard.expressions.nostrilsDistance
    reverted.ShouldersM = standard.expressions.shoulderBlades
    reverted.ShouldersS = standard.expressions.shoulders
    reverted.ShouldersT = standard.expressions.shoulderThickness
    reverted.LegsS = standard.expressions.thighs
    reverted.ULiphD = standard.expressions.upperLipDepth
    reverted.ULiphH = standard.expressions.upperLipHeight
    reverted.ULiphW = standard.expressions.upperLipWidth
    reverted.WaistW = standard.expressions.waist

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

    reverted.overlays = table.copy(standard.overlays)
  elseif jo.framework:is("RSG") then
    local skin_tone = { 1, 4, 3, 5, 2, 6 }
    local heads = {
      mp_male = { [16] = 18, [17] = 21, [18] = 22, [19] = 25, [20] = 28 },
      mp_female = { [17] = 20, [18] = 22, [19] = 27, [20] = 28 }
    }
    local bodies = { 2, 1, 3, 4, 5, 6 }

    standard.model = object.sex == 2 and "mp_female" or "mp_male"
    standard.bodiesIndex = bodies[object.body_size] or object.body_size
    standard.eyesIndex = object.eye_color
    standard.headIndex = heads[standard.model][math.ceil(object.head / 6)] or math.ceil(object.head / 6)
    standard.skinTone = skin_tone[object.skin_tone]
    standard.teethIndex = object.teethIndex
    standard.hair = object.hair
    if standard.model == "mp_male" then
      standard.beards_complete = object.beard
    end
    standard.bodyScale = convertToPercent(object.height)

    standard.expressions = {
      arms = object.arms_size,
      calves = object.calves_size,
      cheekbonesDepth = object.cheekbones_depth,
      cheekbonesHeight = object.cheekbones_height,
      cheekbonesWidth = object.cheekbones_width,
      chest = object.chest_size,
      chinDepth = object.chin_depth,
      chinHeight = object.chin_height,
      chinWidth = object.chin_width,
      earlobes = object.earlobe_size,
      earsAngle = object.ears_angle,
      earsDepth = object.eyebrow_depth,
      earsHeight = object.ears_height,
      earsWidth = object.ears_width,
      eyebrowDepth = object.face_depth,
      eyebrowHeight = object.eyebrow_height,
      eyebrowWidth = object.eyebrow_width,
      eyelidHeight = object.eyelid_height,
      eyelidLeft = object.eyelid_left,
      eyelidRight = object.eyelid_right,
      eyelidWidth = object.eyelid_width,
      eyesAngle = object.eyes_angle,
      eyesDepth = object.eyes_depth,
      eyesDistance = object.eyes_distance,
      eyesHeight = object.eyes_height,
      faceWidth = object.face_width,
      headWidth = object.head_width,
      hip = object.hips_size,
      jawDepth = object.jaw_depth,
      jawHeight = object.jaw_height,
      jawWidth = object.jaw_width,
      jawY = object.jawY,
      lowerLipDepth = object.lower_lip_depth,
      lowerLipHeight = object.lower_lip_height,
      lowerLipWidth = object.lower_lip_width,
      mouthConerLeftDepth = object.mouth_corner_left_depth,
      mouthConerLeftHeight = object.mouth_corner_left_height,
      mouthConerLeftLipsDistance = object.mouth_corner_left_lips_distance,
      mouthConerLeftWidth = object.mouth_corner_left_width,
      mouthConerRightDepth = object.mouth_corner_right_depth,
      mouthConerRightHeight = object.mouth_corner_right_height,
      mouthConerRightLipsDistance = object.mouth_corner_right_lips_distance,
      mouthConerRightWidth = object.mouth_corner_right_width,
      mouthDepth = object.mouth_depth,
      mouthWidth = object.mouth_width,
      mouthX = object.mouth_x_pos,
      mouthY = object.mouth_y_pos,
      neckDepth = object.neck_depth,
      neckWidth = object.neck_width,
      noseAngle = object.nose_angle,
      noseCurvature = object.nose_curvature,
      noseHeight = object.nose_height,
      noseSize = object.nose_size,
      noseWidth = object.nose_width,
      nostrilsDistance = object.nostrils_distance,
      shoulderBlades = object.back_muscle,
      shoulders = object.uppr_shoulder_size,
      shoulderThickness = object.back_shoulder_thickness,
      thighs = object.tight_size,
      upperLipDepth = object.upper_lip_depth,
      upperLipHeight = object.upper_lip_height,
      upperLipWidth = object.upper_lip_width,
      waist = object.waist_width,
    }

    standard.overlays = {
      ageing = object.ageing_t and {
        id = object.ageing_t - 1,
        opacity = convertToPercent(object.ageing_op)
      },
      beard = object.beardstabble_t and {
        id = object.beardstabble_t,
        opacity = convertToPercent(object.beardstabble_op)
      },
      blush = object.blush_t and {
        id = object.blush_t - 1,
        palette = object.blush_id,
        tint0 = object.blush_c1,
        opacity = convertToPercent(object.blush_op)
      },
      eyebrow = object.eyebrow_t and (function()
        local id = object.eyebrow_t - 1
        local sexe = "m"
        if id > 15 then
          id = id - 15
          sexe = "f"
        end
        return {
          id = id,
          sexe = sexe,
          palette = object.eyebrow_id,
          tint0 = object.eyebrow_c1,
          opacity = convertToPercent(object.eyebrow_op)
        }
      end)(),
      eyeliner = object.eyeliner_t and {
        id = 1,
        sheetGrid = object.eyeliner_t - 1,
        palette = object.eyeliner_id,
        tint0 = object.eyeliner_c1,
        opacity = convertToPercent(object.eyeliner_op)
      },
      eyeshadow = object.shadows_t and {
        id = 1,
        sheetGrid = object.shadows_t - 1,
        palette = object.shadows_id,
        tint0 = object.shadows_c1,
        opacity = convertToPercent(object.shadows_op)
      },
      freckles = object.freckles_t and {
        id = object.freckles_t - 1,
        opacity = convertToPercent(object.freckles_op)
      },
      lipstick = object.lipstick_t and {
        id = 1,
        sheetGrid = object.lipstick_t - 1,
        palette = object.lipstick_id,
        tint0 = object.lipstick_c1,
        opacity = convertToPercent(object.lipstick_op)
      },
      moles = object.moles_t and {
        id = object.moles_t - 1,
        opacity = convertToPercent(object.moles_op)
      },
      scar = object.scars_t and {
        id = object.scars_t - 1,
        opacity = convertToPercent(object.scars_op)
      },
      spots = object.spots_t and {
        id = object.spots_t - 1,
        opacity = convertToPercent(object.spots_op)
      },
      -- acne = {},
      -- foundation = {},
      -- grime = {},
      -- hair = {},
      -- masks = {},
      -- complex = {},
      -- disc = {},
    }
  end

  if jo.framework:is("RSG") then
    revertRSGSkin(reverted)
  end
  return reverted
end
FrameworkClass.revertSkin = revertSkin

local function revertClothes(object)
  local reverted = {}
  for category, data in pairs(object) do
    reverted[revertSkinKey(category)] = table.copy(formatComponentData(data) or { hash = 0 })
  end
  return reverted
end
FrameworkClass.revertClothes = revertClothes

---@param clothesList table
local function cleanClothesTable(clothesList)
  local list = {}
  for cat, hash in pairs(clothesList or {}) do
    list[cat] = formatComponentData(hash)
  end
  return list
end

local function convertClothesTableToObject(object)
  --convert the data from ctrl_clothshop
  if object[1] then
    local clothes = {}
    for _, value in pairs(object) do
      local cloth = value
      if type(cloth) == "table" then
        cloth = cloth.comp or cloth
      end
      if type(cloth) == "table" then
        clothes[cloth.catName] = {
          hash = cloth.hash
        }
        if cloth.tints then
          clothes[cloth.catName].tint0 = cloth.tints[1]
          clothes[cloth.catName].tint1 = cloth.tints[2]
          clothes[cloth.catName].tint2 = cloth.tints[3]
        end
        if cloth.special then
          clothes[cloth.catName].normal = cloth.special.normal
          clothes[cloth.catName].albedo = cloth.special.albedo
          clothes[cloth.catName].material = cloth.special.material
        end
      end
    end
    return clothes
  else
    return object
  end
end

local function standardizeClothes(object)
  local standard = {}

  object = convertClothesTableToObject(object)

  for catFram, data in pairs(object or {}) do
    standard[standardizeSkinKey(catFram)] = data
  end

  standard = cleanClothesTable(standard)

  return standard
end
FrameworkClass.standardizeClothes = standardizeClothes
FrameworkClass.standardizeClothesKeys = standardizeClothes

function FrameworkClass:getUserClothes(source)
  local clothes = {}
  if OWFramework.getUserClothes then
    clothes = OWFramework.getUserClothes(source)
  elseif self:is("VORP") then
    local user = User:get(source)
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
  elseif self:is("RedEM2023") or self:is("RedEM") then
    local user = self:getUserIdentifiers(source)
    clothes = MySQL.scalar.await("SELECT clothes FROM clothes WHERE identifier=? AND charid=?;", { user.identifier, user.charid })
  elseif self:is("QBR") then
    local user = self:getUserIdentifiers(source)
    clothes = MySQL.scalar.await("SELECT clothes FROM playerskins WHERE citizenid=? AND active=1", { user.identifier })
  elseif self:is("RSG") then
    local user = self:getUserIdentifiers(source)
    clothes = MySQL.scalar.await("SELECT clothes FROM playerskins WHERE citizenid=?", { user.identifier })
  elseif self:is("QR") then
    local user = self:getUserIdentifiers(source)
    clothes = MySQL.scalar.await("SELECT clothes FROM playerclothe WHERE citizenid=?", { user.identifier })
  elseif self:is("RPX") then
    local user = User:get(source)
    clothes = user.data.clothes
  end

  if not clothes then return {} end
  clothes = UnJson(clothes)

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
  local clothes = revertClothes(_clothes)
  if OWFramework.updateUserClothes then
    return OWFramework.updateUserClothes(source, category, value)
  end
  if self:is("VORP") then
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
  elseif self:is("RedEM2023") or self:is("RedEM") then
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
  elseif self:is("QBR") or self:is("RSG") then
    local identifiers = self:getUserIdentifiers(source)
    MySQL.scalar("SELECT clothes FROM playerskins WHERE citizenid=? ", { identifiers.identifier }, function(oldClothes)
      local decoded = UnJson(oldClothes)
      table.merge(decoded, clothes)
      MySQL.update("UPDATE playerskins SET clothes=? WHERE citizenid=?", { json.encode(decoded), identifiers.identifier })
    end)
  elseif self:is("RPX") then
    local user = User:get(source)
    local newClothes = table.merge(user.data.clothes, clothes)
    user.data.SetClothesData(newClothes)
  elseif self:is("QR") then
    local identifiers = self:getUserIdentifiers(source)
    MySQL.scalar("SELECT clothes FROM playerclothe WHERE citizenid=?", { identifiers.identifier }, function(oldClothes)
      local decoded = UnJson(oldClothes)
      table.merge(decoded, clothes)
      MySQL.update("UPDATE playerclothe SET clothes=? WHERE citizenid=?", { json.encode(decoed), identifiers.identifier })
    end)
  end
end

---@param source integer
function FrameworkClass:getUserSkin(source)
  if OWFramework.getUserSkin then
    return UnJson(OWFramework.getUserSkin(source))
  end
  local user = User:get(source)
  local skin = {}
  if not user then return {} end
  if self:is("VORP") then
    skin = user.data.skin
  elseif self:is("RedEM2023") or self:is("RedEM") then
    local identifiers = user:getIdentifiers()
    skin = MySQL.scalar.await("SELECT skin FROM skins WHERE identifier=? AND charid=?;", { identifiers.identifier, identifiers.charid })
  elseif self:is("QBR") or self:is("RSG") then
    local identifiers = user:getIdentifiers()
    skin = MySQL.scalar.await("SELECT skin FROM playerskins WHERE citizenid=?", { identifiers.identifier })
  elseif self:is("RPX") then
    skin = user.data.skin
  end

  skin = UnJson(skin)

  local skinStandardized = standardizeSkin(skin)

  if not skinStandardized.teeth then
    local clothes = self:getUserClothes(source)
    if clothes.teeth then
      skinStandardized.teeth = clothes.teeth.hash
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
  if OWFramework.updateUserSkin then
    return OWFramework.updateUserSkin(source, skin)
  end
  if self:is("VORP") then
    if overwrite then
      TriggerClientEvent("vorpcharacter:updateCache", source, skin)
    else
      TriggerClientEvent("vorpcharacter:savenew", source, false, skin)
    end
  elseif self:is("RedEM2023") or self:is("RedEM") then
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
  elseif self:is("QBR") or self:is("RSG") then
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
  elseif self:is("RPX") then
    local user = User:get(source)
    local skin = UnJson(user.data.skin)
    skin[category] = value
    user.data.SetSkinData(skin)
  end
end



function FrameworkClass:createUser(source, data, spawnCoordinate, isDead)
  if isDead == nil then isDead = false end
  spawnCoordinate = spawnCoordinate or vec4(2537.684, -1278.066, 49.218, 42.520)
  data = data or {}
  data.firstname = data.firstname or ""
  data.lastname = data.lastname or ""
  data.skin = revertSkin(data.skin)
  data.comps = revertClothes(data.comps)
  if OWFramework.createUser then
    return OWFramework.createUser(source, data)
  end
  if self:is("VORP") then
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
    return
  elseif self:is("RedEM2023") or self:is("RedEM") then
    return
  elseif self:is("QBR") then
    return
  elseif self:is("RSG") then
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
    return
  elseif self:is("RPX") then
    return
  end
end

-------------
-- END SKIN & CLOTHES
-------------

function FrameworkClass:example()
  if OWFramework.example then
    return OWFramework.example()
  end
  if self:is("VORP") then
    return
  elseif self:is("RedEM2023") or self:is("RedEM") then
    return
  elseif self:is("QBR") then
    return
  elseif self:is("RSG") then
    return
  elseif self:is("RPX") then
    return
  end
end

jo.framework = FrameworkClass:new()
