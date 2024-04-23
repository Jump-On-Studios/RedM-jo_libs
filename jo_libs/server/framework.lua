if not bprint then
  return print('^1NEED TO LOAD prints.lua FIRST !!!!!!^0')
end

Framework = {}

-------------
-- USER CLASS
-------------

---@class User : table User class
---@field source integer source ID
local User = {
  source = 0,
  data = {}
}
_ENV.User = User

---@return User
function User:get(source)
  local user = {}
  setmetatable(user, self)
  self.source = source
  self.__index = self
  self:init()
  return user
end

---@param source integer sourceID of the player
function User:init()
  if Config.getUser then
    self.data = Config.getUser(self.source)
  elseif Framework:is("VORP") then
   self.data = Framework.core.getUser(self.source).getUsedCharacter
  elseif Framework:is("RedEM2023") then
    self.data = Framework.core.GetPlayer(self.source)
  elseif Framework:is("RedEM") then
    local user = promise.new()
    TriggerEvent('redemrp:getPlayerFromId', self.source, function(_user)
      user:resolve(_user)
    end)
    self.data = Citizen.Await(user)
  elseif Framework:is("QBR") then
    self.data = Framework.core:GetPlayer(self.source)
  elseif Framework:is("RSG") or Framework:is("QR") then
    self.data = Framework.core.Functions.GetPlayer(self.source)
  end
end

---@param moneyType integer 1: $, 2: gold, 3: rol
---@return number
function User:getMoney(moneyType)
  if moneyType == nil then
    moneyType = 1
  end
  if Config.getMoney then
    return Config.getMoney(self.source,moneyType)
  end
  if Framework:is('VORP') then
    if moneyType == 0 then
      return self.data.money
		elseif moneyType == 1 then
      return self.data.gold
    elseif moneyType == 2 then
      return self.data.rol
    end
  elseif Framework:is("RedEM2023") then
    if moneyType == 0 then
      return self.data.money
    elseif moneyType == 1 then
      return Config.getSecondMoney(source)
    elseif moneyType == 2 then
      return Config.getThirdMoney(source)
    end
  elseif Framework:is("RedEM") then
    if moneyType == 0 then
      return self.data.getMoney()
    elseif moneyType == 2 then
      return self.data.getGold()
    elseif moneyType == 3 then
      return Config.getThirdMoney(source)
    end
  elseif Framework:is("QBR") or Framework:is("RSG") or Framework:is("QR") then
    if money == 0 then
      return self.data.Functions.GetMoney('cash')
    elseif moneyType == 1 then
      return Config.getSecondMoney(source)
    elseif moneyType == 2 then
      return Config.getThirdMoney(source)
    end
  end
  return 0
end

---@param price number price
---@param moneyType integer 1: $, 2: gold, 3: rol
---@return boolean
function User:canBuy(price, moneyType)
  if moneyType == nil then
    moneyType = 1
  end
  local money = self:getMoney(moneyType)
  return money >= price
end

---@param amount number amount to remove
---@param moneyType integer 1: $, 2: gold, 3: rol
function User:removeMoney(amount, moneyType)
  if moneyType == nil then
    moneyType = 1
  end
  if Config.removeMoney then
    return Config.removeMoney(self, amount, moneyType)
  elseif Framework:is("VORP") then
    self.data.removeCurrency(moneyType, amount)
  elseif Framework:is("RedEM2023") then
    if moneyType == 0 then
      self.data.RemoveMoney(amount)
    elseif moneyType == 1 then
      Config.removeSecondMoney(self.source,amount)
    elseif moneyType == 2 then
      Config.removeThirdMoney(self.source,amount)
    end
  elseif Framework:is("RedEM") then
    if moneyType == 0 then
      self.data.removeMoney(amount)
    elseif moneyType == 1 then
      self.data.removeGold(amount)
    elseif moneyType == 2 then
      Config.removeThirdMoney(self.source,amount)
    end
  elseif Framework:is("QBR") or Framework:is('RSG') or Framework:is('QR') then
    if moneyType == 0 then
      self.data.Functions.RemoveMoney('cash', amount)
    elseif moneyType == 1 then
      Config.removeSecondMoney(self.source,amount)
    elseif moneyType == 2 then
      Config.removeThirdMoney(self.source,amount)
    end
  elseif Framework:is("RPX") then
    if moneyType == 0 then
      self.data.RemoveMoney('cash',amount)
    elseif moneyType == 1 then
      Config.removeSecondMoney(self.source,amount)
    elseif moneyType == 2 then
      Config.removeThirdMoney(self.source,amount)
    end
  end
end

---@param amount number amount to remove
---@param moneyType integer 1: $, 2: gold, 3: rol
function User:addMoney(amount,moneyType)
  if moneyType == nil then
    moneyType = 1
  end
  if Config.addMoney then
    return Config.addMoney(self.source,amount, moneyType)
  end
  if Framework:is("VORP") then
    self.data.addCurrency(moneyType, amount)
	elseif Framework:is("RedEM2023") then
    if moneyType == 0 then
      self.data.AddMoney(amount)
    elseif moneyType == 1 then
      Config.addSecondMoney(self.source, amount)
    elseif moneyType == 2 then
      Config.addThirdMoney(self.source, amount)
    end
  elseif Framework:is("RedEM") then
    if moneyType == 0 then
      self.data.addMoney(amount)
    elseif moneyType == 1 then
      self.data.addGold(amount)
    elseif moneyType == 2 then
      Config.addThirdMoney(self.source, amount)
    end
  elseif Framework:is("QBR") or Framework:is('RSG') or Framework:is('QR') then
    if moneyType == 0 then
      self.Functions.AddMoney('cash', amount)
    elseif moneyType == 1 then
      Config.addSecondMoney(self.source, amount)
    elseif moneyType == 2 then
      Config.addThirdMoney(self.source, amount)
    end
    local xPlayer = self.getUser(source)
    xPlayer.data.Functions.AddMoney('cash', tonumber(amount), 'clothing-store')
  end
end

---@param amount number amount of gold
function User:giveGold(amount)
  self:addMoney(amount, 1)
end

function User:getIdentifier()
  if Config.getIdentifier then
    return Config.GetIdentifier(self.source)
  end

  if Framework:is("VORP") then
    return {
      identifier = self.data.identifier,
      charid = self.data.charIdentifier
    }
  elseif Framework:is("RedEM2023") then
    return {
      identifier = user.identifier,
      charid = user.charid
    }
  elseif Framework:is("RedEM") then
    return {
      identifier = self.data.getIdentifier(),
      charid = self.data.getSessionVar("charid")
    }
  elseif Framework:is("QBR") or Framework:is("RSG") or Framework:is("QR") then
    return {
      identifier = self.data.PlayerData.citizenid,
      charid = self.data.PlayerData.citizenid
    }
  end
end

---@return string job
function User:getJob()
  if Config.getJob then
    return Config.getJob(self.source)
  elseif Framework:is("VORP") or Framework:is('RedEM2023') then
    return self.data.job
  elseif Framework:is("RedEM") then
    return self.data.getJob()
  elseif Framework:is("QBR") or Framework:is("RSG") or Framework:is("QR") then
    return self.data.PlayerData.job.name
  end
  return ''
end

---@return string name
function User:getRPName()
  if Config.getRPName then
    return Config.getRPName(self.source)
  end
  if Framework:is("VORP") or Framework:is("RedEM2023") or Framework:is("RedEM") then
    return ("%s %s"):format(self.data.firstname,self.data.lastname)
  elseif Framework:is("QBR") or Framework:is("RSG") or Framework:is("QR") then
    return ("%s %s"):format(self.data.PlayerData.charinfo.firstname,self.data.PlayerData.charinfo.lastname)
  end
  return source..""
end

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

---@return string Name of the framework
function FrameworkClass:get()
  if self.name ~= "" then return self.name end

  if Config.Framework == "Custom" then
    self.name = Config.Framework
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


function FrameworkClass:init()
  if Config.initFramework then
    return Config.initFramework()
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

---@param source integer source ID
---@return table identifier
function FrameworkClass:getIdentifier(source)
  local user = User:get(source)
  return user:getIdentifier()
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
  if Config.useItem then
    return Config.useItem(source,item,amount,meta,remove)
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
  if Config.registerUseItem then
    Config.registerUseItem(item,closeAfterUsed,callback)
  elseif self:is("VORP") then
    self.inv:getItemDB(item, function(itemData)
    if not itemData then
      return eprint(item .. " < item does not exist in the database")
    end
      self.inv:registerUsableItem(item, function(data)
        if closeAfterUsed then
          self.inv:closeInventory(data.source)
        end
        return callback(data.source,{metadata = data.item.metadata})
      end)
    end)
  elseif self:is("RedEM2023") or self:is("RedEM") then
    local itemData = self.inv.getItemData(item)
    if not itemData then
      return eprint(item .. " < item does not exist in the inventory configuration")
    end
    AddEventHandler("RegisterUsableItem:"..item, function(source,data)
      callback(source,{metadata = data.meta})
      if closeAfterUsed then
        TriggerClientEvent("redemrp_inventory:closeinv", source)
      end
    end)
  elseif self:is("QBR") then
    if self.core:AddItem(item,nil) then
      return eprint(item .. " < item does not exist in the core configuration")
    end
    self.core:CreateUseableItem(item,function(source,data)
      callback(source,{metadata = data.info})
      if closeAfterUsed then
        TriggerClientEvent("qbr-inventory:client:closeinv",source)
      end
    end)
  elseif self:is("RSG") or self:is('QR') then
    if self.core.Functions.AddItem(item,nil) then
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
  if Config.giveItem then
    return Config.giveItem(source,item,quantity,meta)
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
---@param config table configuration of the inventory
function FrameworkClass:createInventory(invName, name, invConfig)
  self.inventories[invName] = {
    invName = invName,
    name = name,
    invConfig = invConfig
  }
  if Config.createInventory then
    Config.createInventory(invName, name, invConfig)
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
  end
end

function FrameworkClass:removeInventory(invName)
  if Config.removeInventory then
    Config.removeInventory(invName)
  elseif self:is('VORP') then
    self.inv:removeInventory(invName)
  end
end

---@param source integer sourceIdentifier
---@param invName string name of the inventory
---@param name string name of the inventory
---@param invConfig table configuration of the inventory
function FrameworkClass:openInventory(source,invName)
  local name = self.inventories[invName].name
  local invConfig = self.inventories[invName].invConfig
  if Config.openInventory then
    Config.openInventory(source, invName, name, invConfig)
  elseif self:is("VORP") then
    self:createInventory(invName, name, invConfig)
    return self.inv:openInventory(source,invName)
  end
  if self:is("RedEM2023") then
    TriggerClientEvent("redemrp_inventory:OpenStash", source, name, invConfig.maxWeight)
    return
  end
  if self:is("RedEM") then
    TriggerClientEvent("redemrp_inventory:OpenLocker",source,name)
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
function FrameworkClass:addItemInInventory(source,invId,item,quantity,metadata,needWait)
  local waiter = promise.new()
  if Config.addItemInInventory then
    Config.addItemInInventory(invId,item,quantity,metadata)
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
      })
    end)
  end
  if needWait then
    Citizen.Await(waiter)
  end
end

---@param source integer source ID
---@param invId string name of the inventory
function FrameworkClass:getItemsFromInventory(source,invId)
  if Config.getItemsFromInventory then
    return Config.getItemsFromInventory
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
  end
  return {}
end

Framework = FrameworkClass:new()
_ENV.Framework = Framework