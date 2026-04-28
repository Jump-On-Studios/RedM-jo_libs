jo.require("timeout")

-- Last known routing bucket per player source, used to detect changes between polls.
local playersInstances = {}

-------------
-- POLLING
-------------

-- Poll every player's routing bucket and broadcast a global event when it changes.
-- Consumer resources listen to `jo_libs:player:instanceChanged` from their scoped server.lua.
-- Callbacks are not fired on first observation (previous == nil) so a player joining
-- doesn't trigger a fake `nil -> 0` change.
local function getPlayersInstances()
  local players = GetPlayers()
  for i = 1, #players do
    local handle = players[i] -- string handle, kept for the native call
    local source = tonumber(handle)
    if source then
      local instance = GetPlayerRoutingBucket(handle)
      local previous = playersInstances[source]
      if previous ~= instance then
        playersInstances[source] = instance
        if previous ~= nil then
          TriggerEvent("jo_libs:player:instanceChanged", source, previous, instance)
        end
      end
    end
  end
end

jo.timeout.loop(2000, getPlayersInstances)

-------------
-- CLEANUP
-------------

-- Drop the cached instance so a reconnect under the same source doesn't compare against stale data.
AddEventHandler("playerDropped", function()
  local source = source
  playersInstances[source] = nil
end)
