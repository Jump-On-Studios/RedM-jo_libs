jo.file.load("framework-bridge.overwrite-functions")

if not table.merge then
  jo.require("table")
end
if not string.convertVersion then
  jo.require("string")
end

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
local SkinCategoryBridge = {
  VORP = {
    Hat = "hats",
    Mask = "masks",
    Shirt = "shirts_full",
    Suspender = "suspenders",
    Vest = "vests",
    Coat = "coats",
    Poncho = "ponchos",
    Cloak = "cloaks",
    Glove = "gloves",
    RingRh = "jewelry_rings_right",
    RingLh = "jewelry_rings_left",
    Bracelet = "jewelry_bracelets",
    Gunbelt = "gunbelts",
    Belt = "belts",
    Buckle = "belt_buckles",
    Holster = "holsters_left",
    Pant = "pants",
    Chap = "chaps",
    Spurs = "boot_accessories",
    CoatClosed = "coats_closed",
    --Ties = "neckties",
    NeckTies = "neckties",
    Skirt = "skirts",
    Boots = "boots",
    EyeWear = "eyewear",
    NeckWear = "neckwear",
    Spats = "spats",
    GunbeltAccs = "gunbelt_accs",
    Gauntlets = "gauntlets",
    Loadouts = "loadouts",
    Accessories = "accessories",
    Satchels = "satchels",
    dresses = "dresses",
    Dress = "dresses",
    armor = "armor",
    Badge = "badges",
    bow = "hair_accessories",
    Hair = "hair",
    Beard = "beards_complete",
    Teeth = "teeth",
    sex = "model",
    HeadType = "headHash",  --To be confirm
    BodyType = "bodyBuild", --To be confirm
    LegsType = "bodyLower", --To be investig
    Eyes = "eyes",
    Legs = "bodyLower",
    Torso = "bodyUpper",
    Waist = "",
    Body = "",
    --Expressions
    HeadSize = "headWidth",
    FaceW = "faceWidth",
    FaceD = "eyebrowWidth",
    FaceS = "eyebrowHeight",
    NeckW = "neckWidth",
    NeckD = "neckDepth",
    EyeBrowH = "eyebrowHeight",
    EyeBrowW = "eyebrowWidth",
    EyeBrowD = "eyebrowDepth",
    EyeD = "eyesDepth",
    EyeAng = "eyesAngle",
    EyeDis = "eyesDistance",
    EyeH = "eyesHeight",
    EyeLidH = "eyelidHeight",
    EyeLidW = "eyelidWidth",
    EyeLidL = "eyelidLeft",
    EyeLidR = "eyelidRight",
    EarsW = "earsWidth",
    EarsA = "earsAngle",
    EarsH = "earsHeight",
    EarsD = "earlobes",
    CheekBonesH = "cheekbonesHeight",
    CheekBonesW = "cheekbonesWidth",
    CheekBonesD = "cheekbonesDepth",
    JawH = "jawHeight",
    JawW = "jawWidth",
    JawD = "jawDepth",
    ChinH = "chinHeight",
    ChinW = "chinWidth",
    ChinD = "chinDepth",
    NoseW = "noseWidth",
    NoseS = "noseSize",
    NoseH = "noseHeight",
    NoseAng = "noseAngle",
    NoseC = "noseCurvature",
    NoseDis = "nostrilsDistance",
    MouthW = "mouthWidth",
    MouthD = "mouthDepth",
    MouthX = "mouthX",
    MouthY = "mouthY",
    ULiphH = "upperLipHeight",
    ULiphW = "upperLipWidth",
    ULiphD = "upperLipDepth",
    LLiphH = "lowerLipHeight",
    LLiphW = "lowerLipWidth",
    LLiphD = "lowerLipDepth",
    MouthCLW = "mouthConerLeftWidth",
    MouthCRW = "mouthConerRightWidth",
    MouthCLD = "mouthConerLeftDepth",
    MouthCRD = "mouthConerRightDepth",
    MouthCLH = "mouthConerLeftHeight",
    MouthCRH = "mouthConerRightHeight",
    MouthCLLD = "mouthConerLeftLipsDistance",
    MouthCRLD = "mouthConerRightLipsDistance",
    ArmsS = "arms",
    ShouldersS = "shoulders",
    ShouldersT = "shoulderThickness",
    ShouldersM = "shoulderBlades",
    ChestS = "chest",
    WaistW = "waist",
    HipsS = "hip",
    LegsS = "thighs",
    CalvesS = "calves",
    Scale = "bodyScale"
  },
  RSG = {
    Hair = "hair",
    Beard = "beards_complete",
    Teeth = "teeth",
    sex = "model",
    HeadType = "headHash",  --To be confirm
    BodyType = "bodyBuild", --To be confirm
    LegsType = "bodyLower", --To be investig
    Eyes = "eyes",
    Legs = "bodyLower",
    Torso = "bodyUpper",
    Waist = "",
    Body = "",
    --Expressions
    HeadSize = "headWidth",
    FaceW = "faceWidth",
    FaceD = "eyebrowWidth",
    FaceS = "eyebrowHeight",
    NeckW = "neckWidth",
    NeckD = "neckDepth",
    EyeBrowH = "eyebrowHeight",
    EyeBrowW = "eyebrowWidth",
    EyeBrowD = "eyebrowDepth",
    EyeD = "eyesDepth",
    EyeAng = "eyesAngle",
    EyeDis = "eyesDistance",
    EyeH = "eyesHeight",
    EyeLidH = "eyelidHeight",
    EyeLidW = "eyelidWidth",
    EyeLidL = "eyelidLeft",
    EyeLidR = "eyelidRight",
    EarsW = "earsWidth",
    EarsA = "earsAngle",
    EarsH = "earsHeight",
    EarsD = "earlobes",
    CheekBonesH = "cheekbonesHeight",
    CheekBonesW = "cheekbonesWidth",
    CheekBonesD = "cheekbonesDepth",
    JawH = "jawHeight",
    JawW = "jawWidth",
    JawD = "jawDepth",
    ChinH = "chinHeight",
    ChinW = "chinWidth",
    ChinD = "chinDepth",
    NoseW = "noseWidth",
    NoseS = "noseSize",
    NoseH = "noseHeight",
    NoseAng = "noseAngle",
    NoseC = "noseCurvature",
    NoseDis = "nostrilsDistance",
    MouthW = "mouthWidth",
    MouthD = "mouthDepth",
    MouthX = "mouthX",
    MouthY = "mouthY",
    ULiphH = "upperLipHeight",
    ULiphW = "upperLipWidth",
    ULiphD = "upperLipDepth",
    LLiphH = "lowerLipHeight",
    LLiphW = "lowerLipWidth",
    LLiphD = "lowerLipDepth",
    MouthCLW = "mouthConerLeftWidth",
    MouthCRW = "mouthConerRightWidth",
    MouthCLD = "mouthConerLeftDepth",
    MouthCRD = "mouthConerRightDepth",
    MouthCLH = "mouthConerLeftHeight",
    MouthCRH = "mouthConerRightHeight",
    MouthCLLD = "mouthConerLeftLipsDistance",
    MouthCRLD = "mouthConerRightLipsDistance",
    ArmsS = "arms",
    ShouldersS = "shoulders",
    ShouldersT = "shoulderThickness",
    ShouldersM = "shoulderBlades",
    ChestS = "chest",
    WaistW = "waist",
    HipsS = "hip",
    LegsS = "thighs",
    CalvesS = "calves",
    Scale = "bodyScale"
  },
  RedEM = {
    beard = "beards_complete"
  },
  RedEM2023 = {
    beard = "beards_complete"
  }
}

local listClothesCategory = {
  "ponchos",
  "cloaks",
  "hair_accessories",
  "dresses",
  "gloves",
  "coats",
  "coats_closed",
  "vests",
  "suspenders",
  "neckties",
  "neckwear",
  "shirts_full",
  "spats",
  "gunbelts",
  "gauntlets",
  "holsters_left",
  "loadouts",
  "belt_buckles",
  "belts",
  "skirts",
  "pants",
  "boots",
  "boot_accessories",
  "accessories",
  "satchels",
  "jewelry_rings_right",
  "jewelry_rings_left",
  "jewelry_bracelets",
  "aprons",
  "chaps",
  "badges",
  "gunbelt_accs",
  "eyewear",
  "armor",
  "masks",
  "masks_large",
  "hats",
  "hair",
  "beards_complete",
  "teeth"
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
    bprint("RSG detected")
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

---@param key string
local function isOverlayKey(key)
  local converter = {
    beardstabble_ = "beard",
    hair_ = "hair",
    scars_ = "scar",
    spots_ = "spots",
    disc_ = "disc",
    complex_ = "complex",
    acne_ = "acne",
    ageing_ = "ageing",
    freckles_ = "freckles",
    moles_ = "moles",
    shadows_ = "eyeshadow",
    eyebrows_ = "eyebrow",
    eyeliner_ = "eyeliner",
    blush_ = "blush",
    lipsticks_ = "lipstick",
    grime_ = "grime",
    foundation_ = "foundation",
    paintedmasks_ = "masks",
  }

  for search, layerName in pairs(converter) do
    if key:find(search) then
      return layerName
    end
  end
  return false
end

--- A function to standardize the category name
---@param category string the category name
local function standardizeSkinKey(category)
  local framName = jo.framework:get()
  if not SkinCategoryBridge[framName] then return category end
  if SkinCategoryBridge[framName][category] then return SkinCategoryBridge[framName][category] end
  local found, cat = table.find(SkinCategoryBridge[framName], function(cat, framCat) return framCat:lower() == category:lower() end)
  return found and SkinCategoryBridge[framName][cat] or category
end

--- A function to standardize a object of categories
local function standardizeSkinKeys(object)
  local objectStandardized = { overlays = {} }

  local layerNamesNotNeeded = {}
  local overlays = {}

  for catFram, data in pairs(object or {}) do
    local layerName = isOverlayKey(catFram)
    if layerName then
      overlays[layerName] = overlays[layerName] or {}
      if catFram:find("_visibility") then
        if data == 0 then
          layerNamesNotNeeded[layerName] = true
        end
      elseif catFram:find("_tx_id") then
        if layerName == "eyebrow" then
          local id = data - 1
          local sexe = "m"
          if data > 15 then
            data = data - 15
            sexe = "f"
          end
          overlays[layerName].id = id
          overlays[layerName].sexe = sexe
        elseif layerName == "hair" then
          if data == 1 then
            overlays[layerName].albedo = "mp_u_faov_m_hair_000"
          elseif data == 2 then
            overlays[layerName].albedo = "mp_u_faov_m_hair_002"
          elseif data == 3 then
            overlays[layerName].albedo = "mp_u_faov_m_hair_009"
          elseif data == 4 then
            overlays[layerName].albedo = "mp_u_faov_m_hair_shared_000"
          end
        else
          overlays[layerName].id = data - 1
        end
      elseif catFram:find("_opacity") then
        overlays[layerName].opacity = data
      elseif catFram:find("_palette_id") then
        overlays[layerName].sheetGrid = data
      elseif catFram:find("_color_primary") then
        overlays[layerName].tint0 = data
      elseif catFram:find("_color") then
        overlays[layerName].tint0 = data
      elseif catFram:find("_color_secondary") then
        overlays[layerName].tint1 = data
      elseif catFram:find("_color_tertiary") then
        overlays[layerName].tint2 = data
      end
    else
      objectStandardized[standardizeSkinKey(catFram)] = data
    end
  end
  for layerName, _ in pairs(layerNamesNotNeeded) do
    overlays[layerName] = nil
  end
  objectStandardized.overlays = table.merge(objectStandardized.overlays, overlays)

  if objectStandardized.hair and type(objectStandardized.hair) ~= "table" then
    objectStandardized.hair = {
      hash = objectStandardized.hair
    }
  end
  if objectStandardized.beards_complete and type(objectStandardized.beards_complete) ~= "table" then
    objectStandardized.beards_complete = {
      hash = objectStandardized.beards_complete
    }
  end

  return objectStandardized
end
FrameworkClass.standardizeSkinKeys = standardizeSkinKeys

--- A function to revert the category name
local function revertSkinKey(category)
  local framName = jo.framework:get()
  for catFram, catStandard in pairs(SkinCategoryBridge[framName] or {}) do
    if category == catStandard then
      return catFram
    end
  end
  return category
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
local function revertSkinKeys(object)
  local objectStandardized = {}
  for category, data in pairs(object) do
    objectStandardized[revertSkinKey(category)] = table.copy(data)
  end
  return objectStandardized
end
FrameworkClass.revertSkinKeys = revertSkinKeys

local function revertClothesKeys(object)
  local objectStandardized = {}
  for category, data in pairs(object) do
    objectStandardized[revertSkinKey(category)] = table.copy(formatComponentData(data) or { hash = 0 })
  end
  return objectStandardized
end
FrameworkClass.revertClothesKeys = revertClothesKeys

---@param clothesList table
local function cleanClothesTable(clothesList)
  local list = {}
  -- for _,cat in pairs (listClothesCategory) do
  --   list[cat] = 0
  -- end
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

local function standardizeClothesKeys(object)
  local objectStandardized = {}

  object = convertClothesTableToObject(object)

  for catFram, data in pairs(object or {}) do
    objectStandardized[standardizeSkinKey(catFram)] = data
  end

  objectStandardized = cleanClothesTable(objectStandardized)

  return objectStandardized
end
FrameworkClass.standardizeClothesKeys = standardizeClothesKeys

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

  local clothesStandardized = standardizeClothesKeys(clothes)

  return clothesStandardized
end

---@param source string
---@param _clothes table with key = category
---@param value? table
function FrameworkClass:updateUserClothes(source, _clothes, value)
  if value then
    _clothes = { [_clothes] = formatComponentData(value) }
  end
  local clothes = revertClothesKeys(_clothes)
  if OWFramework.updateUserClothes then
    return OWFramework.updateUserClothes(source, _clothes, value)
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

  local skinStandardized = standardizeSkinKeys(skin)

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
  local skin = revertSkinKeys(_skin)
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
  data.skin = revertSkinKeys(data.skin)
  data.comps = revertClothesKeys(data.comps)
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
