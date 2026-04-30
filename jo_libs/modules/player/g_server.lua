jo.require("timeout")

-- Last known routing bucket per player source, used to detect changes between polls.
local playersInstances = {}

-------------
-- POLLING
-------------

-- Poll every player's routing bucket and broadcast a global event when it changes.
-- Consumer resources listen to `jo_libs:player:instanceChanged` from their scoped server.lua.
local function getPlayersInstances()
    local players = GetPlayers()
    for i = 1, #players do
        local handle = players[i]
        local source = handle
        if source then
            local instance = GetPlayerRoutingBucket(handle)
            local previous = playersInstances[source]
            if previous ~= instance then
                playersInstances[source] = instance
                TriggerEvent("jo_libs:player:instanceChanged", source, instance, previous)
                TriggerClientEvent("jo_libs:player:instanceChanged", tonumber(source) --[[@as integer]], instance, previous)
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
