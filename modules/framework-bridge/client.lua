RegisterNetEvent(GetCurrentResourceName()..":client:openInventory", function(name,config)
  TriggerServerEvent("inventory:server:OpenInventory", "stash", name, { maxweight = config.maxWeight, slots = config.maxSlots })
  TriggerEvent("inventory:client:SetCurrentStash", name)
end)

AddEventHandler("vorp_stables:setClosedInv", function()
  TriggerServerEvent(GetCurrentResourceName()..":server:closeInventory")
end)

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
  table.merge(self,t or {})
  self:init()
	return self
end

function FrameworkClass:init()
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

