jo.require("timeout")

local playersInstances = {}

local function getPlayersInstances()
    local players = GetPlayers()
    for i = 1, #players do
        local source = tonumber(players[i])
        local instance = GetPlayerRoutingBucket(source)
        if playersInstances[source] ~= instance then
            playersInstances[source] = instance
        end
    end
end

jo.timeout.loop(2000, getPlayersInstances)


AddEventHandler("playerDropped", function()
    local source = source
    playersInstances[source] = nil
end)
