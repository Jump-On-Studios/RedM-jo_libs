jo.require("timeout")

-------------
-- FUNCTIONS
-------------

jo.player = setmetatable({}, {
  __call = function()
    return jo.player.ped
  end
})
jo.player.ped = PlayerPedId()
jo.player.coords = GetEntityCoords(jo.player.ped)
jo.player.playerId = PlayerId()
jo.player.serverId = GetPlayerServerId(jo.player.playerId)
jo.player.isMale = IsPedMale(jo.player.ped)

local function sendUpdate(values)
  if #values == 0 then return end
  TriggerEvent("jo_libs:player:update", values)
end

local function updateValues()
  local updated = {}
  local ped = PlayerPedId()
  if ped ~= jo.player.ped then
    jo.player.ped = ped
    jo.player.playerId = PlayerId()
    jo.player.isMale = IsPedMale(jo.player.ped)
    updated[#updated + 1] = { "ped", jo.player.ped }
    updated[#updated + 1] = { "playerId", jo.player.playerId }
    updated[#updated + 1] = { "isMale", jo.player.isMale }
  end
  local coords = GetEntityCoords(jo.player.ped)
  if #(coords - jo.player.coords) > 0.0001 then
    jo.player.coords = GetEntityCoords(jo.player.ped)
    updated[#updated + 1] = { "coords", jo.player.coords }
  end
  sendUpdate(updated)
end

exports("jo_player_force_update", updateValues)


jo.timeout.loop(100, updateValues)

function jo.player.forceUpdate()
  updateValues(true)
end

-------------
-- Shortcut
-------------
jo.pl = jo.player
