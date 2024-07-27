jo.file.load('framework-bridge.overwrite-functions')

if not table.merge then
  jo.require('table')
end

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
    return OWFramework.initFramework(self)
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
  elseif self:is('RSG') then
    return
  elseif self:is("RPX") then
    return
  end
end

jo.framework = FrameworkClass:new()
return jo.framework

