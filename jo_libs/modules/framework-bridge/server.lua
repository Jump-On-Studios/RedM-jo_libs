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
}

-------------
-- END VARIABLES
-------------

-------------
-- USER CLASS
-------------

---@class UserClass : table UserClass class
---@field source integer source ID
local UserClass = {
  source = 0,
  data = {}
}

---@return UserClass
function UserClass:get(source)
  self = table.copy(UserClass)
  self.source = tonumber(source)
  self:init()
  return self
end

function UserClass:init()
  if jo.framework:is("RedEM2023") then
    self.data = jo.framework.core.GetPlayer(self.source)
  elseif jo.framework:is("RedEM") then
    local user = promise.new()
    TriggerEvent("redemrp:getPlayerFromId", self.source, function(_user)
      user:resolve(_user)
    end)
    self.data = Citizen.Await(user)
  elseif jo.framework:is("QBR") then
    self.data = jo.framework.core:GetPlayer(self.source)
  elseif jo.framework:is("QR") then
    self.data = jo.framework.core.Functions.GetPlayer(self.source)
  elseif jo.framework:is("RPX") then
    self.data = jo.framework.core.GetPlayer(self.source)
  end
end

---@param moneyType integer 0: money, 1: gold, 2: rol
---@return number
function UserClass:getMoney(moneyType)
  moneyType = moneyType or 0
  if jo.framework:is("RedEM2023") then
    if moneyType == 0 then
      return self.data.money
    elseif moneyType == 1 then
      oprint("Gold in not supported by your Framework")
      oprint("Please check jo_libs docs to add OWFramework.UserClass.getSecondMoney()")
      return 0
    elseif moneyType == 2 then
      oprint("Gold in not supported by your Framework")
      oprint("Please check jo_libs docs to add OWFramework.UserClass.getThirdMoney()")
      return 0
    end
  elseif jo.framework:is("RedEM") then
    if moneyType == 0 then
      return self.data.getMoney()
    elseif moneyType == 1 then
      return self.data.getGold()
    elseif moneyType == 2 then
      oprint("Gold in not supported by your Framework")
      oprint("Please check jo_libs docs to add OWFramework.UserClass.getThirdMoney()")
      return 0
    end
  elseif jo.framework:is("QBR") or jo.framework:is("QR") then
    if moneyType == 0 then
      return self.data.Functions.GetMoney("cash")
    elseif moneyType == 1 then
      oprint("Gold in not supported by your Framework")
      oprint("Please check jo_libs docs to add OWFramework.UserClass.getSecondMoney()")
      return 0
    elseif moneyType == 2 then
      oprint("Gold in not supported by your Framework")
      oprint("Please check jo_libs docs to add OWFramework.UserClass.getThirdMoney()")
      return 0
    end
  end
  return 0
end

---@param price number price
---@param moneyType integer 0: money, 1: gold, 2: rol
---@param removeIfCan? boolean (optional) default: false
---@return boolean
function UserClass:canBuy(price, moneyType, removeIfCan)
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
function UserClass:removeMoney(amount, moneyType)
  moneyType = moneyType or 0
  if jo.framework:is("RedEM2023") then
    if moneyType == 0 then
      self.data.RemoveMoney(amount)
    elseif moneyType == 1 then
      oprint("The Gold was not removed - Gold in not supported by your Framework")
      oprint("Please check jo_libs docs to add OWFramework.UserClass.removeSecondMoney()")
      return
    elseif moneyType == 2 then
      oprint("The Gold was not removed - Gold in not supported by your Framework")
      oprint("Please check jo_libs docs to add OWFramework.UserClass.removeThirdMoney()")
      return
    end
  elseif jo.framework:is("RedEM") then
    if moneyType == 0 then
      self.data.removeMoney(amount)
    elseif moneyType == 1 then
      self.data.removeGold(amount)
    elseif moneyType == 2 then
      oprint("The Gold was not removed - Gold in not supported by your Framework")
      oprint("Please check jo_libs docs to add OWFramework.UserClass.removeThirdMoney()")
      return
    end
  elseif jo.framework:is("QBR") or jo.framework:is("QR") then
    if moneyType == 0 then
      self.data.Functions.RemoveMoney("cash", amount)
    elseif moneyType == 1 then
      oprint("The Gold was not removed - Gold in not supported by your Framework")
      oprint("Please check jo_libs docs to add OWFramework.UserClass.removeSecondMoney()")
      return
    elseif moneyType == 2 then
      oprint("The Gold was not removed - Gold in not supported by your Framework")
      oprint("Please check jo_libs docs to add OWFramework.UserClass.removeThirdMoney()")
      return
    end
  elseif jo.framework:is("RPX") then
    if moneyType == 0 then
      self.data.RemoveMoney("cash", amount)
    elseif moneyType == 1 then
      oprint("The Gold was not removed - Gold in not supported by your Framework")
      oprint("Please check jo_libs docs to add OWFramework.UserClass.removeSecondMoney()")
      return
    elseif moneyType == 2 then
      oprint("The Gold was not removed - Gold in not supported by your Framework")
      oprint("Please check jo_libs docs to add OWFramework.UserClass.removeThirdMoney()")
      return
    end
  end
end

---@param amount number amount to remove
---@param moneyType integer 0: money, 1: gold, 2: rol
function UserClass:addMoney(amount, moneyType)
  moneyType = moneyType or 0
  if jo.framework:is("RedEM2023") then
    if moneyType == 0 then
      self.data.AddMoney(amount)
    elseif moneyType == 1 then
      oprint("Gold in not supported by your Framework")
      oprint("Please check jo_libs docs to add OWFramework.UserClass.addSecondMoney()")
      return
    elseif moneyType == 2 then
      oprint("Gold in not supported by your Framework")
      oprint("Please check jo_libs docs to add OWFramework.UserClass.addThirdMoney()")
      return
    end
  elseif jo.framework:is("RedEM") then
    if moneyType == 0 then
      self.data.addMoney(amount)
    elseif moneyType == 1 then
      self.data.addGold(amount)
    elseif moneyType == 2 then
    end
  elseif jo.framework:is("QBR") or jo.framework:is("QR") then
    if moneyType == 0 then
      self.data.Functions.AddMoney("cash", amount)
    elseif moneyType == 1 then
      oprint("Gold in not supported by your Framework")
      oprint("Please check jo_libs docs to add OWFramework.UserClass.addSecondMoney()")
      return
    elseif moneyType == 2 then
      oprint("Gold in not supported by your Framework")
      oprint("Please check jo_libs docs to add OWFramework.UserClass.addThirdMoney()")
      return
    end
  end
end

---@param amount number amount of gold
function UserClass:giveGold(amount)
  self:addMoney(amount, 1)
end

function UserClass:getIdentifiers()
  if not self.data then return {} end

  if jo.framework:is("RedEM2023") then
    return {
      identifier = self.data.identifier,
      charid = self.data.charid
    }
  elseif jo.framework:is("RedEM") then
    return {
      identifier = self.data.getIdentifier(),
      charid = self.data.getSessionVar("charid")
    }
  elseif jo.framework:is("QBR") or jo.framework:is("QR") then
    return {
      identifier = self.data.PlayerData.citizenid,
      charid = 0
    }
  end
end

---@return string job
function UserClass:getJob()
  if jo.framework:is("RedEM2023") then
    return self.data.job
  elseif jo.framework:is("RedEM") then
    return self.data.getJob()
  elseif jo.framework:is("QBR") or jo.framework:is("QR") then
    return self.data.PlayerData.job.name
  end
  return ""
end

---@return string name
function UserClass:getRPName()
  if jo.framework:is("RedEM2023") or jo.framework:is("RedEM") then
    return ("%s %s"):format(self.data.firstname, self.data.lastname)
  elseif jo.framework:is("QBR") or jo.framework:is("QR") then
    return ("%s %s"):format(self.data.PlayerData.charinfo.firstname, self.data.PlayerData.charinfo.lastname)
  end
  return self.source .. ""
end

-------------
-- END USER CLASS
-------------

-------------
-- FRAMEWORK CLASS
-------------
---@class FrameworkClass : table FrameworkClass class
---@field name string shortname of the framework
---@field longName string long name of the framework
---@field core any Core functions of the framework
---@field inv any Inventory core of the framework
local FrameworkClass = {
  name = "",
  longName = "Undefined",
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
  if self:is("RedEM2023") then
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
  elseif self:is("QR") then
    bprint("QR detected")
    self.core = exports["qr-core"]:GetCoreObject()
    return
  elseif self:is("RPX") then
    bprint("RPX detected")
    self.inv = exports["rpx-inventory"]
  end
end

---@return string Name of the framework
function FrameworkClass:get()
  if self.name ~= "" then return self.name end


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
  if self:is("RedEM") or self:is("RedEM2023") then
    local itemData = self.inv.getItem(source, item)
    if itemData and itemData.ItemAmount >= amount then
      if remove then
        itemData.RemoveItem(amount)
      end
      return true
    end
  elseif self:is("QBR") or self:is("QR") then
    local Player = UserClass:get(source)
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
    if self:is("RedEM2023") or self:is("RedEM") then
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
    elseif self:is("QR") then
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
  if self:is("RedEM2023") or self:is("RedEM") then
    local ItemData = self.inv.getItem(source, item, meta) -- this give you info and functions
    return ItemData.AddItem(quantity, meta)
  elseif self:is("QBR") or self:is("QR") then
    local Player = UserClass:get(source)
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
  if self:is("RedEM") then
    self.inv.createLocker(invName, "empty")
  end
end

function FrameworkClass:removeInventory(invName)

end

---@param source integer sourceIdentifier
---@param invName string name of the inventory
function FrameworkClass:openInventory(source, invName)
  local name = self.inventories[invName].name
  local invConfig = self.inventories[invName].invConfig
  if self:is("RedEM2023") then
    TriggerClientEvent("redemrp_inventory:OpenStash", source, invName, invConfig.maxWeight)
    return
  end
  if self:is("RedEM") then
    TriggerClientEvent("redemrp_inventory:OpenLocker", source, invName)
    return
  end
  if self:is("QBR") or self:is("QR") then
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
  if self:is("QBR") or self:is("RPX") then
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
function FrameworkClass:getItemsFromInventory(invId)
  if self:is("QBR") or self:is("RPX") then
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
    if table.type(overlay) == "array" then
      overlay = clearOverlaysTable(overlay)
    else
      if overlay.opacity == 0 then
        overlays[layerName] = nil
      end
    end
  end
end

---@param data any the clothes data
---@return table
local function formatComponentData(data)
  if type(data) == "table" then
    if data.comp then
      data.hash = data.comp
      data.comp = nil
    end
    if not data.hash or data.hash == 0 or data.hash == -1 then return nil end
    if type(data.hash) == "table" then
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
  if table.type(object) == "hash" then
    return object
  end
  if table.type(object) == "array" then
    --convert the data from ctrl_clothshop
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
  end
  return {}
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
  if self:is("RedEM2023") or self:is("RedEM") then
    local user = self:getUserIdentifiers(source)
    clothes = MySQL.scalar.await("SELECT clothes FROM clothes WHERE identifier=? AND charid=?;", { user.identifier, user.charid })
  elseif self:is("QBR") then
    local user = self:getUserIdentifiers(source)
    clothes = MySQL.scalar.await("SELECT clothes FROM playerskins WHERE citizenid=? AND active=1", { user.identifier })
  elseif self:is("QR") then
    local user = self:getUserIdentifiers(source)
    clothes = MySQL.scalar.await("SELECT clothes FROM playerclothe WHERE citizenid=?", { user.identifier })
  elseif self:is("RPX") then
    local user = UserClass:get(source)
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
  if self:is("RedEM2023") or self:is("RedEM") then
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
  elseif self:is("QBR") then
    local identifiers = self:getUserIdentifiers(source)
    MySQL.scalar("SELECT clothes FROM playerskins WHERE citizenid=? ", { identifiers.identifier }, function(oldClothes)
      local decoded = UnJson(oldClothes)
      table.merge(decoded, clothes)
      MySQL.update("UPDATE playerskins SET clothes=? WHERE citizenid=?", { json.encode(decoded), identifiers.identifier })
    end)
  elseif self:is("RPX") then
    local user = UserClass:get(source)
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
  local user = UserClass:get(source)
  local skin = {}
  if not user then return {} end
  if self:is("RedEM2023") or self:is("RedEM") then
    local identifiers = user:getIdentifiers()
    skin = MySQL.scalar.await("SELECT skin FROM skins WHERE identifier=? AND charid=?;", { identifiers.identifier, identifiers.charid })
  elseif self:is("QBR") then
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
  if self:is("RedEM2023") or self:is("RedEM") then
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
  elseif self:is("QBR") then
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
    local user = UserClass:get(source)
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
  if self:is("RedEM2023") or self:is("RedEM") then
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

local function detectFramework()
  if GetConvar("jo_libs:customFramework", "false") ~= "false" then
    return GetConvar("jo_libs:customFramework", "false")
  end
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
      return framework
    end
  end
end

local frameworkName = detectFramework()

for _, resource in pairs(mainResourceFramework[frameworkName] or {}) do
  if resource:sub(1, 1) ~= "!" then
    while GetResourceState(resource) ~= "started" do
      bprint("Waiting start of " .. frameworkName)
      Wait(1000)
    end
  end
end

local frameworkFile = ("framework-bridge.%s.FrameworkClass"):format(frameworkName)
local userFile = ("framework-bridge.%s.UserClass"):format(frameworkName)

if not jo.file.isExist(frameworkFile) then
  eprint("Framework folder doesn't exist in `@jo_libs/modules/framework-bridge`: " .. tostring(frameworkName))
else
  local frameworkClass = jo.file.load(frameworkFile)
  table.merge(FrameworkClass, frameworkClass)
  local userClass = jo.file.load(userFile)
  table.merge(UserClass, userClass)
end

local cFrameworkFile = ("framework-bridge.custom.FrameworkClass"):format(frameworkName)
local cUserFile = ("framework-bridge.custom.UserClass"):format(frameworkName)

if jo.file.isExist(cFrameworkFile) then
  local cFrameworkClass = jo.file.load(cFrameworkFile)
  table.merge(FrameworkClass, cFrameworkClass)
end
if jo.file.isExist(cUserFile) then
  local cUserClass = jo.file.load(cUserFile)
  table.merge(UserClass, cUserClass)
end

jo.UserClass = UserClass
jo.framework = FrameworkClass:new()

bprint(jo.framework.longName .. " detected")
