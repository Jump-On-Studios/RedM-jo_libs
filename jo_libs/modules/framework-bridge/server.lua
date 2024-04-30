jo.require('framework-bridge.overwrite-functions')

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
  local user = {}
  setmetatable(user, self)
  self.source = tonumber(source)
  self.__index = self
  self:init()
  return user
end

function User:init()
  if OWFramework.User.getUser then
    self.data = OWFramework.User.getUser(self.source)
  elseif jo.framework:is("VORP") then
   self.data = jo.framework.core.getUser(self.source).getUsedCharacter
  elseif jo.framework:is("RedEM2023") then
    self.data = jo.framework.core.GetPlayer(self.source)
  elseif jo.framework:is("RedEM") then
    local user = promise.new()
    TriggerEvent('redemrp:getPlayerFromId', self.source, function(_user)
      user:resolve(_user)
    end)
    self.data = Citizen.Await(user)
  elseif jo.framework:is("QBR") then
    self.data = jo.framework.core:GetPlayer(self.source)
  elseif jo.framework:is("RSG") or jo.framework:is("QR") then
    self.data = jo.framework.core.Functions.GetPlayer(self.source)
  end
end

---@param moneyType integer 1: $, 2: gold, 3: rol
---@return number
function User:getMoney(moneyType)
  if moneyType == nil then
    moneyType = 1
  end
  if OWFramework.User.getMoney then
    return OWFramework.User.getMoney(self.source,moneyType)
  end
  if jo.framework:is('VORP') then
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
    elseif moneyType == 2 then
      return self.data.getGold()
    elseif moneyType == 3 then
      return OWFramework.User.getThirdMoney(source)
    end
  elseif jo.framework:is("QBR") or jo.framework:is("RSG") or jo.framework:is("QR") then
    if moneyType == 0 then
      return self.data.Functions.GetMoney('cash')
    elseif moneyType == 1 then
      return OWFramework.User.getSecondMoney(source)
    elseif moneyType == 2 then
      return OWFramework.User.getThirdMoney(source)
    end
  end
  return 0
end

---@param price number price
---@param moneyType integer 1: $, 2: gold, 3: rol
---@param removeIfCan? boolean (optional) default: false
---@return boolean
function User:canBuy(price, moneyType, removeIfCan)
  if moneyType == nil then
    moneyType = 1
  end
  local money = self:getMoney(moneyType)
  local hasEnough = money >= price
  if removeIfCan == true and hasEnough then
    self:removeMoney(price,moneyType)
  end
  return hasEnough
end

---@param amount number amount to remove
---@param moneyType integer 1: $, 2: gold, 3: rol
function User:removeMoney(amount, moneyType)
  if moneyType == nil then
    moneyType = 1
  end
  if OWFramework.User.removeMoney then
    return OWFramework.User.removeMoney(self, amount, moneyType)
  elseif jo.framework:is("VORP") then
    self.data.removeCurrency(moneyType, amount)
  elseif jo.framework:is("RedEM2023") then
    if moneyType == 0 then
      self.data.RemoveMoney(amount)
    elseif moneyType == 1 then
      OWFramework.User.removeSecondMoney(self.source,amount)
    elseif moneyType == 2 then
      OWFramework.User.removeThirdMoney(self.source,amount)
    end
  elseif jo.framework:is("RedEM") then
    if moneyType == 0 then
      self.data.removeMoney(amount)
    elseif moneyType == 1 then
      self.data.removeGold(amount)
    elseif moneyType == 2 then
      OWFramework.User.removeThirdMoney(self.source,amount)
    end
  elseif jo.framework:is("QBR") or jo.framework:is('RSG') or jo.framework:is('QR') then
    if moneyType == 0 then
      self.data.Functions.RemoveMoney('cash', amount)
    elseif moneyType == 1 then
      OWFramework.User.removeSecondMoney(self.source,amount)
    elseif moneyType == 2 then
      OWFramework.User.removeThirdMoney(self.source,amount)
    end
  elseif jo.framework:is("RPX") then
    if moneyType == 0 then
      self.data.RemoveMoney('cash',amount)
    elseif moneyType == 1 then
      OWFramework.User.removeSecondMoney(self.source,amount)
    elseif moneyType == 2 then
      OWFramework.User.removeThirdMoney(self.source,amount)
    end
  end
end

---@param amount number amount to remove
---@param moneyType integer 1: $, 2: gold, 3: rol
function User:addMoney(amount,moneyType)
  if moneyType == nil then
    moneyType = 1
  end
  if OWFramework.User.addMoney then
    return OWFramework.User.addMoney(self.source,amount, moneyType)
  end
  if jo.framework:is("VORP") then
    self.data.addCurrency(moneyType, amount)
	elseif jo.framework:is("RedEM2023") then
    if moneyType == 0 then
      self.data.AddMoney(amount)
    elseif moneyType == 1 then
      OWFramework.User.addSecondMoney(self.source, amount)
    elseif moneyType == 2 then
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
  elseif jo.framework:is("QBR") or jo.framework:is('RSG') or jo.framework:is('QR') then
    if moneyType == 0 then
      self.Functions.AddMoney('cash', amount)
    elseif moneyType == 1 then
      OWFramework.User.addSecondMoney(self.source, amount)
    elseif moneyType == 2 then
      OWFramework.User.addThirdMoney(self.source, amount)
    end
    local xPlayer = self.getUser(source)
    xPlayer.data.Functions.AddMoney('cash', tonumber(amount), 'clothing-store')
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
  elseif jo.framework:is("VORP") or jo.framework:is('RedEM2023') then
    return self.data.job
  elseif jo.framework:is("RedEM") then
    return self.data.getJob()
  elseif jo.framework:is("QBR") or jo.framework:is("RSG") or jo.framework:is("QR") then
    return self.data.PlayerData.job.name
  end
  return ''
end

---@return string name
function User:getRPName()
  if OWFramework.User.getRPName then
    return OWFramework.User.getRPName(self.source)
  end
  if jo.framework:is("VORP") or jo.framework:is("RedEM2023") or jo.framework:is("RedEM") then
    return ("%s %s"):format(self.data.firstname,self.data.lastname)
  elseif jo.framework:is("QBR") or jo.framework:is("RSG") or jo.framework:is("QR") then
    return ("%s %s"):format(self.data.PlayerData.charinfo.firstname,self.data.PlayerData.charinfo.lastname)
  end
  return source..""
end

jo.User = User

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
	t = t or {}
	setmetatable(t, self)
	self.__index = self
  t:init()
	return t
end

function FrameworkClass:init()
  if OWFramework.initFramework then
    return OWFramework.initFramework()
  elseif self:is("VORP") then
    bprint('VORP detected')
    Wait(100)
    TriggerEvent("getCore", function(core)
      self.core = core
      self.inv = exports.vorp_inventory
    end)
    return
  elseif self:is("RedEM2023") then
    bprint('RedEM:RP 2023 detected')
    self.core= exports["redem_roleplay"]:RedEM()
    TriggerEvent("redemrp_inventory:getData",function(call)
      self.inv = call
    end)
    return
  elseif self:is("RedEM") then
    bprint('RedEM:RP OLD detected')
    TriggerEvent("redemrp_inventory:getData",function(call)
      self.inv = call
    end)
    return
  elseif self:is("QBR") then
    bprint('QBR detected')
    self.core = self.core
    return
  elseif self:is("RSG") then
    bprint('RSG detected')
    self.core= exports['rsg-core']:GetCoreObject()
    return
  elseif self:is("QR") then
    bprint('QR detected')
    self.core= exports['qr-core']:GetCoreObject()
    return
  elseif self:is('RPX') then
    bprint('RPX detected')
    self.inv = exports['rpx-inventory']
  end
  eprint('No compatible Framework detected. Please contact JUMP ON studios on discord')
end

---@return string Name of the framework
function FrameworkClass:get()
  if self.name ~= "" then return self.name end

  if OWFramework.get then
    self.name = OWFramework.get()
  elseif GetResourceState('vorp_core') == "started" then
    self.name = "VORP"
  elseif GetResourceState('redem') == "started" then
    self.name = "RedEM"
  elseif GetResourceState('redem_roleplay') == "started" then
    self.name = "RedEM2023"
  elseif GetResourceState('qbr-core') == "started" then
    self.name = "QBR"
  elseif GetResourceState('rsg-core') == "started" then
    self.name = "RSG"
  elseif GetResourceState('qr-core') == "started" then
    self.name = "QR"
  end
  return self.name
end

---@param name string Name of the framework
---@return boolean
function FrameworkClass:is(name)
  return self:get() == name
end

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

---@param source integer source ID
---@param item string name of the item
---@param amount integer amount to use
---@param meta table metadata of the item
---@param remove boolean if removed after used
function FrameworkClass:canUseItem(source,item,amount,meta,remove)
  if OWFramework.canUseItem then
    return OWFramework.canUseItem(source,item,amount,meta,remove)
  end
  if self:is("VORP") then
    local count = self.inv:getItemCount(source, nil, item)
    if count >= amount then
      if remove then
        self.inv:subItem(source, item, amount)
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
  elseif self:is("QBR") or self:is('RSG') or self:is('QR') then
    local Player = User:get(source)
    local itemData = Player.data.Functions.GetItemByName(item)
    if itemData and itemData.amount >= amount then
      if remove then
        Player.data.Functions.RemoveItem(item,amount)
      end
      return true
    end
  end
  return false
end

---@param item string name of the item
---@param callback function function fired when the item is used
---@param closeAfterUsed boolean if inventory needs to be closes
function FrameworkClass:registerUseItem(item,closeAfterUsed,callback)
  if (closeAfterUsed == nil) then closeAfterUsed = true end
  if OWFramework.registerUseItem then
    OWFramework.registerUseItem(item,closeAfterUsed,callback)
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
      return callback(data.source,{metadata = data.item.metadata})
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
    AddEventHandler("RegisterUsableItem:"..item, function(source,data)
      callback(source,{metadata = data.meta})
      if closeAfterUsed then
        TriggerClientEvent("redemrp_inventory:closeinv", source)
      end
    end)
  elseif self:is("QBR") then
    local isAdded = self.core:AddItem(item,nil)
    if isAdded then
      return eprint(item .. " < item does not exist in the core configuration")
    end
    self.core:CreateUseableItem(item,function(source,data)
      callback(source,{metadata = data.info})
      if closeAfterUsed then
        TriggerClientEvent("qbr-inventory:client:closeinv",source)
      end
    end)
  elseif self:is("RSG") or self:is('QR') then
    local isAdded = self.core.Functions.AddItem(item,nil)
    if isAdded then
      return eprint(item .. " < item does not exist in the core configuration")
    end
    self.core.Functions.CreateUseableItem(item,function(source,data)
      callback(source,{metadata = data.info})
      if closeAfterUsed then
        TriggerClientEvent(string.lower(self:get()).."-inventory:client:closeinv",source)
      end
    end)
  end
end

---@param source integer source ID
---@param item string name of the item
---@param quantity integer quantity
---@param meta table metadata of the item
---@return boolean
function FrameworkClass:giveItem(source,item,quantity,meta)
  if OWFramework.giveItem then
    return OWFramework.giveItem(source,item,quantity,meta)
  elseif self:is("VORP") then
    if self.inv:canCarryItem(source, item, quantity) then
      self.inv:addItem(source, item, quantity, meta)
      return true
    end
    return false
  elseif self:is("RedEM2023") or self:is("RedEM") then
    local ItemData = self.inv.getItem(source, item, meta) -- this give you info and functions
    return ItemData.AddItem(quantity,meta)
  elseif self:is("QBR") or self:is('RSG') or self:is('QR') then
    local Player = User:get(source)
    return Player.data.Functions.AddItem(item, quantity, false, meta)
  elseif GetFramework() == "RPX" then
    return self.inv:AddItem(source, item, quantity, meta)
  end
  return false
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
  elseif self:is('VORP') then
    --id, name, limit, acceptWeapons, shared, ignoreItemStackLimit, whitelistItems,UsePermissions, UseBlackList, whitelistWeapons
    local invConfig = invConfig
    -- self.inv:registerInventory({
    --   id = invName,
    --   name = name,
    --   limit = invConfig.maxSlots,
    --   acceptWeapons =  invConfig.acceptWeapons or false,
    --   shared = invConfig.shared or true,
    --   ignoreItemStackLimit = invConfig.ignoreStackLimit or true,
    --   whitelistItems = invConfig.whitelist and true or false,
    -- })
    self.inv:registerInventory({
      id = invName,
      name = name,
      limit = invConfig.maxSlots,
      acceptWeapons =  invConfig.acceptWeapons or false,
      shared = invConfig.shared or true,
      ignoreItemStackLimit = invConfig.ignoreStackLimit or true,
      whitelistItems = invConfig.whitelist and true or false,
    })
    for _,data in pairs (invConfig.whitelist or {}) do
      self.inv:setCustomInventoryItemLimit(invName, data.item, data.limit)
    end
  elseif self:is('RedEM') then
    self.inv.createLocker(invName,"empty")
  end
end

function FrameworkClass:removeInventory(invName)
  if OWFramework.removeInventory then
    OWFramework.removeInventory(invName)
  elseif self:is('VORP') then
    self.inv:removeInventory(invName)
  end
end

---@param source integer sourceIdentifier
---@param invName string name of the inventory
function FrameworkClass:openInventory(source,invName)
  local name = self.inventories[invName].name
  local invConfig = self.inventories[invName].invConfig
  if OWFramework.openInventory then
    OWFramework.openInventory(source, invName, name, invConfig)
  elseif self:is("VORP") then
    self:createInventory(invName, name, invConfig)
    return self.inv:openInventory(source,invName)
  end
  if self:is("RedEM2023") then
    TriggerClientEvent("redemrp_inventory:OpenStash", source, invName, invConfig.maxWeight)
    return
  end
  if self:is("RedEM") then
    TriggerClientEvent("redemrp_inventory:OpenLocker",source,invName)
    return
  end
  if self:is("RSG") or self:is("QBR") or self:is("QR") then
    TriggerClientEvent(GetCurrentResourceName()..":client:openInventory",source,invName,invConfig)
    return
  end
end

---@param invId string unique ID of the inventory
---@param item string name of the item
---@param quantity integer quantity
---@param metadata table metadata of the item
---@param needWait? boolean wait after the adding
function FrameworkClass:addItemInInventory(source,invId,item,quantity,metadata,needWait)
  local waiter = promise.new()
  if OWFramework.addItemInInventory then
    OWFramework.addItemInInventory(invId,item,quantity,metadata,needWait)
  elseif self:is('VORP') then
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
  elseif self:is('QBR') or self:is('RSG') or self:is('RPX') then
    MySQL.scalar('SELECT items FROM stashitems WHERE stash = ?',{invId}, function(items)
      if type(items) == "string" then items = json.decode(items) end
      if not items then items = {} end
      local slot = 1
      repeat
        local doesSlotAvailable = true
        for _,item in pairs (items) do
          if item.slot == slot then
            slot = slot + 1
            doesSlotAvailable = false
            break
          end
        end
        Wait(100)
      until doesSlotAvailable
      items[#items+1] = {
        amount = 1,
        name = item,
        info = metadata,
        slot = slot
      }
      MySQL.insert('INSERT INTO stashitems (stash,items) VALUES (@stash,@items) ON DUPLICATE KEY UPDATE items = @items', {
        stash = invId,
        items = json.encode(items)
      }, function()
        waiter:resolve(true)
      end)
    end)
  elseif self:is('RedEM2023') then
    self.inv.addItemStash(source, item, 1, metadata, invId)
    waiter:resolve(true)
  elseif self:is('RedEM') then
    self.inv.addItemLocker(item,1,metadata,invId)
  end
  if needWait then
    Citizen.Await(waiter)
  end
end

---@param source integer source ID
---@param invId string name of the inventory
function FrameworkClass:getItemsFromInventory(source,invId)
  if OWFramework.getItemsFromInventory then
    return OWFramework.getItemsFromInventory(source,invId)
  elseif self:is('VORP') then
    local items = MySQL.query.await("SELECT ci.character_id, ic.id, i.item, ci.amount, ic.metadata, ci.created_at FROM items_crafted ic\
      LEFT JOIN character_inventories ci on ic.id = ci.item_crafted_id\
      LEFT JOIN items i on ic.item_id = i.id\
      WHERE ci.inventory_type = @invType;",
      {
        ['invType'] = invId
      })
    local itemFiltered = {}
    for _,item in pairs (items) do
      itemFiltered[#itemFiltered+1] = {
        metadata = json.decode(item.metadata),
        amount = item.amount,
        item = item.item,
        id = item.id
      }
    end
    return itemFiltered
  elseif self:is('QBR') or self:is('RSG') or self:is('RPX') then
    local items = MySQL.scalar.await('SELECT items FROM stashitems WHERE stash = ?',{invId})
    if type(items) == "string" then items = json.decode(items) end
    if not items then items = {} end
    local itemFiltered = {}
    for _,item in pairs (items) do
      itemFiltered[#itemFiltered+1] = {
        metadata = item.info,
        amount = item.amount,
        item = item.name
      }
    end
    return itemFiltered
  elseif self:is('RedEM2023') then
    local items = self.inv.getStash(invId)
    if not items then items = {} end
    local itemFiltered = {}
    for _,item in pairs (items) do
      itemFiltered[#itemFiltered+1] = {
        metadata = item.meta,
        amount = item.amount,
        item = item.name
      }
    end
    return itemFiltered
  elseif self:is('RedEM') then
    local items = self.inv.getLocker(invId)
    if not items then items = {} end
    local itemFiltered = {}
    for _,item in pairs (items) do
      itemFiltered[#itemFiltered+1] = {
        metadata = item.meta,
        amount = item.amount,
        item = item.name
      }
    end
    return itemFiltered
  end
  return {}
end

---@param source integer
---@param amount number
---@param moneyType? integer 1: $, 2: gold, 3: rol
---@param removeIfCan? boolean (optinal) default : false
---@return boolean
function FrameworkClass:canUserBuy(source,amount,moneyType, removeIfCan)
  local user = User:get(source)
  return user:canBuy(amount,moneyType or 1, removeIfCan)
end

---@param source integer
---@param amount number
---@param moneyType? integer 1: $, 2: gold, 3: rol
function FrameworkClass:addMoney(source,amount,moneyType)
  local user = User:get(source)
  user:addMoney(amount,moneyType or 1)
end

jo.framework = FrameworkClass:new()
return jo.framework