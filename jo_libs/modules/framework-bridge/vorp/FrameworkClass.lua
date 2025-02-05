-------------
-- FRAMEWORK CLASS
-------------
FrameworkClass = FrameworkClass or {}
FrameworkClass.name = "VORP"
FrameworkClass.longName = "VORP Framework"
FrameworkClass.core = exports.vorp_core:GetCore()
FrameworkClass.inv = exports.vorp_inventory

function FrameworkClass:init()
end

function FrameworkClass:get()
  return self.name
end

-------------
-- USER DATA
-------------

function FrameworkClass:getUser()
end

return FrameworkClass
