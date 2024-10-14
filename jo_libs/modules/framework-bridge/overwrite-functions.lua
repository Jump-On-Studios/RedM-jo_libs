-------------
-- Add your Framework function here
-------------
OWFramework = {}
OWFramework.User = {}

-------------
-- SERVER SIDE
-------------
if IsDuplicityVersion() then

  function OWFramework.get()
    return "RedEM2023"
  end

  function OWFramework.initFramework(self)
    bprint('fd_core detected')
    self.core= exports["fd_core"]:FDCore()
    TriggerEvent("fd_inventory:getData",function(call)
      self.inv = call
    end)
  end

  function OWFramework.openInventory(source, invName, name, invConfig)
    TriggerClientEvent("fd_inventory:OpenStash", source, invName, invConfig.maxWeight)
  end

end
OWFramework.User = {}