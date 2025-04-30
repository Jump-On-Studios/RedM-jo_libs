if GetCurrentResourceName() == "jo_libs" then return end

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

local function addUpdater()
  exports.jo_libs:jo_player_update(function(values)
    for i = 1, #values do
      local key, value = values[i][1], values[i][2]
      jo.player[key] = value
    end
  end)
end

function jo.player.forceUpdate()
  exports.jo_libs:jo_player_force_update()
end

jo.ready(addUpdater)

AddEventHandler("onResourceStart", function(resourceName)
  if resourceName ~= "jo_libs" then return end
  addUpdater()
end)

-------------
-- Shortcut
-------------
jo.pl = jo.player
