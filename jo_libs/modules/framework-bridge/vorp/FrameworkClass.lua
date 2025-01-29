-------------
-- FRAMEWORK CLASS
-------------
FrameworkClass = FrameworkClass or {}
FrameworkClass.name = "VORP"
FrameworkClass.core = exports.vorp_core:GetCore()
FrameworkClass.inv = exports.vorp_inventory

function FrameworkClass:init()
end

return FrameworkClass
