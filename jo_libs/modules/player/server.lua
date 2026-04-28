if GetCurrentResourceName() == "jo_libs" then return end

jo.player = setmetatable({}, {
  __call = function()
    return jo.player
  end
})

local instanceChangedCallbacks = {}

-------------
-- FUNCTIONS
-------------

--- A function fired when a player's routing bucket (instance) changes
---@param cb function (function called with `(source, oldInstance, newInstance)`)
function jo.player.instanceChanged(cb)
  if not cb then return eprint("The callback function is nil") end
  instanceChangedCallbacks[#instanceChangedCallbacks + 1] = cb
end

AddEventHandler("jo_libs:player:instanceChanged", function(source, oldInstance, newInstance)
  for i = 1, #instanceChangedCallbacks do
    local status, err = pcall(instanceChangedCallbacks[i], source, oldInstance, newInstance)
    if not status then
      log("Error in jo.player.instanceChanged callback: %s", err)
    end
  end
end)

-------------
-- Shortcut
-------------
jo.pl = jo.player
