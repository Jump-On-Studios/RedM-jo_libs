jo.require("table")
jo.require("string")

local supportedFrameworks = {
  {
    id = "VORP",
    name = "VORP Framework",
    folder = "vorp",
    resources = { "vorp_core" },
  },
  {
    id = "RedEM",
    name = "RedEM:RP Old Framework",
    folder = "redemrp_old",
    resources = { "redem" },
  },
  {
    id = "RedEM2023",
    name = "RedEM:RP 2023 Framework",
    folder = "redemrp_2023",
    resources = { "!redem", "redem_roleplay" },
  },
  {
    id = "qbr",
    name = "QBCore RedM Edition",
    folder = "qbr",
    resources = { "qbr-core" },
  },
  {
    id = "rsg",
    name = "RSG V1 RedM Framework",
    folder = "rsg",
    resources = { "rsg-core<2.0.0" },
  },
  {
    id = "rsg",
    name = "RSG V2 RedM Framework",
    folder = "rsg_2",
    resources = { "rsg-core>=2.0.0" },
  },
  {
    id = "qr",
    name = "QRCore RedM:Re",
    folder = "qr",
    resources = { "qr-core" },
  },
  {
    id = "rpx",
    name = "RPX Framework",
    folder = "rpx",
    resources = { "rpx-core" }
  },
  {
    id = "core",
    name = "Custom Framework",
    folder = "core",
    resources = { "core" },
  }
}

local function extractResourceData(str)
  local resource, version = str:match("^([%w%-_]+)%s*[<>=]=?%s*([0-9]+%.[0-9]+%.[0-9]+[%w%.]*)$")
  if not resource then return str end
  return resource, version
end

local function detectFramework()
  if GetConvar("jo_libs:framework", "false") ~= "false" then
    return GetConvar("jo_libs:framework", "false")
  end

  local frameworkDetected

  for i = 1, #supportedFrameworks do
    local framework = supportedFrameworks[i]
    local rightFramework = true

    for j = 1, #framework.resources do
      local value = framework.resources[j]
      local resource, version = extractResourceData(value)
      if resource:sub(1, 1) == "!" then
        if GetResourceState(resource) == "starting" or GetResourceState(resource) == "started" then
          rightFramework = false
          break
        end
      else
        if GetResourceState(resource) == "missing" or GetResourceState(resource) == "stopped" then
          rightFramework = false
          break
        else
          if version then
            local currentVersion = GetValue(GetResourceMetadata(resource, "version", 0), 1)
            local compare = currentVersion:compareVersionWith(version)
            if value:find("<=") then
              if not compare <= 0 then
                rightFramework = false
                break
              end
            elseif value:find(">=") then
              if not compare >= 0 then
                rightFramework = false
                break
              end
            elseif value:find("=") then
              if not compare == 0 then
                rightFramework = false
                break
              end
            elseif value:find("<") then
              if not compare < 0 then
                rightFramework = false
                break
              end
            elseif value:find(">") then
              if not compare > 0 then
                rightFramework = false
                break
              end
            end
          end
        end
      end
    end

    if rightFramework then
      if not frameworkDetected then
        frameworkDetected = framework
      else
        eprint("=========== ERROR ===========")
        eprint("ERROR ! You have multiple frameworks on your server. Please use only once:")
        eprint(("- %s detected"):format(frameworkDetected.name))
        eprint(("- %s detected"):format(framework.name))
        eprint("=========== ERROR ===========")
        return false
      end
    end
  end

  return frameworkDetected
end

local frameworkDetected = detectFramework()
if not frameworkDetected then
  eprint("IMPOSSIBLE to detect which framework is used on your server")
  return
end

bprint(("%s detected"):format(frameworkDetected.name))

for i = 1, #frameworkDetected.resources do
  local resource = frameworkDetected.resources[i]
  if resource:sub(1, 1) ~= "!" then
    resource = extractResourceData(resource)
    while GetResourceState(resource) ~= "started" do
      bprint("Waiting start of " .. resource)
      Wait(1000)
    end
  end
end

-------------
-- LOAD FRAMEWORK
-------------

local FrameworkClass = {}
local UserClass = {}

local userFile = ("framework-bridge.%s.UserClass"):format(frameworkDetected.folder)
local frameworkFile = ("framework-bridge.%s.FrameworkClass"):format(frameworkDetected.folder)

UserClass = jo.file.load(userFile)
FrameworkClass = jo.file.load(frameworkFile)

-------------
-- END LOAD FRAMEWORK
-------------

-------------
-- POWER UP FUNCTIONS
-------------

---@param price number price
---@param moneyType integer 0: money, 1: gold, 2: rol
---@param removeIfCan? boolean remove the move if the player has enough (default: false)
---@return boolean removed `true` if the money is removed
function UserClass:canBuy(price, moneyType, removeIfCan)
  if not price then
    return false, eprint("Price value is nil")
  end
  price = math.abs(price)
  moneyType = GetValue(moneyType, 0)
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

---@param amount number amount of gold
function UserClass:giveGold(amount)
  return self:addMoney(amount, 1)
end

---@return string name the framework name
function FrameworkClass:get()
  return frameworkDetected.id
end

---@param name string Name of the framework
---@return boolean rightName `true` if it's the right framework
function FrameworkClass:is(name)
  return self:get() == name
end

---@param source integer source ID
---@return table UserClass
function FrameworkClass:getUser(source)
  local user = UserClass:get(source)
  return user
end

---@param source integer source ID
---@return table identifiers
function FrameworkClass:getUserIdentifiers(source)
  local user = UserClass:get(source)
  return user:getIdentifiers()
end

---@param source integer source ID
---@return string job Player's job
function FrameworkClass:getJob(source)
  local user = UserClass:get(source)
  return user:getJob()
end

---@param source integer source ID
---@return string name Player's name
function FrameworkClass:getRPName(source)
  local user = UserClass:get(source)
  return user:getRPName()
end

---@param source integer
---@param amount number
---@param moneyType? integer 0: money, 1: gold, 2: rol (default: 0)
---@param removeIfCan? boolean remove the move if the player has enough (default: false)
---@return boolean removed `true` if the money is removed
function FrameworkClass:canUserBuy(source, amount, moneyType, removeIfCan)
  local user = UserClass:get(source)
  return user:canBuy(amount, moneyType, removeIfCan)
end

---@param source integer
---@param amount number
---@param moneyType? integer 0: money, 1: gold, 2: rol (default: 0)
function FrameworkClass:addMoney(source, amount, moneyType)
  local user = UserClass:get(source)
  return user:addMoney(amount, moneyType)
end

---@param source integer
---@param amount number
---@param moneyType? integer 0: money, 1: gold, 2: rol (default: 0)
function FrameworkClass:removeMoney(source, amount, moneyType)
  local user = UserClass:get(source)
  return user:removeMoney(amount, moneyType)
end

---@param source integer source ID
---@param item string name of the item
---@param quantity integer quantity
---@param meta table metadata of the item
---@return boolean
function FrameworkClass:removeItem(source, item, quantity, meta)
  return self:canUseItem(source, item, quantity, meta, true)
end


function FrameworkClass:convertToPercent(value)
  value = tonumber(value)
  if not value then return 0 end
  if value > 1 or value < -1 then
    return value / 100
  end
  return value
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

local function clearOverlaysTable(overlays)
  if not overlays then return end
  for layerName, overlay in pairs(overlays) do
    if not overlay then
      overlays[layerName] = nil
    end
    if table.type(overlay) == "array" then
      overlay = clearOverlaysTable(overlay)
    else
      if overlay.opacity == 0 then
        overlays[layerName] = nil
      else
        if overlay.palette and table.count(overlay) == 1 then
          overlays[layerName] = nil
        end
      end
    end
  end
end

local function clearExpressionsTable(expressions)
  for key, expression in pairs(expressions) do
    if expression == 0 then
      expressions[key] = nil
    else
      expressions[key] = jo.framework:convertToPercent(expression)
    end
  end
end

local function clearClothesTable(clothesList)
  if not clothesList then return {} end
  for cat, data in pairs(clothesList) do
    clothesList[cat] = formatComponentData(data)
  end
  return clothesList
end


function FrameworkClass:extractComponentHashIfAlone(data)
  if type(data) ~= "table" then return data end
  if table.count(data) > 1 then return data end
  if not data.hash then return data end
  return data.hash
end


function FrameworkClass:standardizeClothes(clothes)
  clothes = table.copy(clothes)
  local standard = self:standardizeClothesInternal(clothes)

  if jo.debug then
    for key, value in pairs(clothes) do
      oprint("Clothes key not standardized", key, value)
    end
  end

  table.merge(standard, clothes)
  clearClothesTable(standard)

  return standard
end

function FrameworkClass:revertClothes(standard)
  standard = table.copy(standard)
  local clothes = self:revertClothesInternal(standard)

  if jo.debug then
    for key, value in pairs(standard) do
      dprint("Clothes key not reverted", key, value)
    end
  end

  table.merge(clothes, standard)
  return clothes
end

function FrameworkClass:standardizeSkin(skin)
  skin = table.copy(skin)
  local standard = self:standardizeSkinInternal(skin)

  table.merge(standard, skin)

  clearOverlaysTable(standard.overlays)
  clearOverlaysTable(skin.overlays)
  if table.count(skin.overlays) == 0 then
    skin.overlays = nil
  end
  clearExpressionsTable(standard.expressions)

  if standard.hair and type(standard.hair) ~= "table" then
    standard.hair = { hash = standard.hair }
  end
  if standard.beards_complete and type(standard.beards_complete) ~= "table" then
    standard.beards_complete = { hash = standard.beards_complete }
  end

  if jo.debug then
    if table.count(skin) > 0 then
      eprint("Skin keys not converted to standard")
      for key, value in pairs(skin) do
        print(key, type(value) == "table" and json.encode(value, { indent = true }) or value)
      end
    else
      gprint("All skin keys standardized")
    end
  end

  return standard
end

function FrameworkClass:revertSkin(standard)
  standard = table.copy(standard)
  local skin = self:revertSkinInternal(standard)

  for key, data in pairs(skin.overlays or {}) do
    if table.count(data) == 0 then
      skin.overlays[key] = nil
    end
  end

  if table.count(skin.overlays) == 0 then
    skin.overlays = nil
  end
  if table.count(skin.expressions) == 0 then
    skin.expressions = nil
  end

  if config and Config.debug then
    if table.count(standard) > 0 then
      eprint("Skin keys not reverted")
      for key, value in pairs(standard) do
        print(key, type(value) == "table" and json.encode(value) or value)
      end
    else
      gprint("All skin keys reverted")
    end
  end
  return skin
end

function FrameworkClass:updateUserClothes(source, _clothes, value)
  if value then
    _clothes = { [_clothes] = formatComponentData(value) }
  end
  local clothes = self:revertClothes(_clothes)
  self:updateUserClothesInternal(source, clothes)
end

function FrameworkClass:getUserClothes(source)
  local clothes = self:getUserClothesInternal(source)
  if table.isEmpty(clothes) then return {} end
  return self:standardizeClothes(clothes)
end

function FrameworkClass:getUserSkin(source)
  local skin = self:getUserSkinInternal(source)

  local skinStandardized = self:standardizeSkin(skin)

  if not skinStandardized.teethHash and not skinStandardized.teethIndex then
    local clothes = self:getUserClothes(source)
    if clothes.teeth then
      skinStandardized.teethHash = clothes.teeth?.hash
    end
  end

  return skinStandardized
end

function FrameworkClass:updateUserSkin(...)
  local args = { ... }
  local source, _skin, overwrite = args[1], {}, false

  if type(args[2]) == "string" then
    _skin = { [args[2]] = args[3] }
    overwrite = GetValue(args[math.max(4, #args)], overwrite)
  else
    _skin = args[2]
    overwrite = GetValue(args[math.max(3, #args)], overwrite)
  end
  local skin = self:revertSkin(_skin)

  self:updateUserSkinInternal(source, skin, overwrite)
end

-------------
-- END POWER UP FUNCTIONS
-------------

-------------
-- LOAD CUSTOM FUNCTIONS
-------------
userFile = ("framework-bridge._custom.UserClass")
frameworkFile = ("framework-bridge._custom.FrameworkClass")

if jo.file.isExist(userFile) then
  local userClass = jo.file.load(userFile)
  table.merge(UserClass, userClass)
end

if jo.file.isExist(frameworkFile) then
  local frameworkClass = jo.file.load(frameworkFile)
  table.merge(FrameworkClass, frameworkClass)
end

-------------
-- END LOAD CUSTOM FUNCTIONS
-------------

-------------
-- INIT jo VALUES
-------------

jo.framework = FrameworkClass
jo.framework.UserClass = UserClass

-------------
-- END INIT jo VALUES
-------------
