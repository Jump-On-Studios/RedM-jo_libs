if GetCurrentResourceName() == "jo_libs" then return end

local moveCallbacks = {}
local numberMoveCallback = 0

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
    local now = GetGameTimer()
    for i = 1, #values do
      local key, value = values[i][1], values[i][2]
      jo.player[key] = value
      if key == "coords" and numberMoveCallback > 0 then
        for c = 1, numberMoveCallback do
          local callback = moveCallbacks[c]
          if (callback.lastExec + callback.interval) < now then
            callback.lastExec = now
            callback.cb()
          end
        end
      end
    end
  end)
end

--- A function to force the update of module value
function jo.player.forceUpdate()
  exports.jo_libs:jo_player_force_update()
end

--- A function fired when the player move every 100ms
---@param cb function (function to fired when the player moves)
---@param interval? integer (minimal duration in ms between two executions. Can't be lower than 100ms)
function jo.player.move(cb, interval)
  if not cb then return eprint("The callback function is nil") end
  numberMoveCallback += 1
  moveCallbacks[numberMoveCallback] = {
    cb = cb,
    lastExec = 0,
    interval = interval or 0
  }
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
