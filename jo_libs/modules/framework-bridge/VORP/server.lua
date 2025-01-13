local FrameworkClass = {
  name = "VORP",
  core = {},
  inv = {},
  inventories = {}
}

function FrameworkClass:init()
  bprint("VORP detected")
  Wait(100)
  TriggerEvent("getCore", function(core)
    self.core = core
    self.inv = exports.vorp_inventory
  end)
end

function FrameworkClass:get()
  return self.name
end

function FrameworkClass:is(value)
  return self.name == value
end

return FrameworkClass
