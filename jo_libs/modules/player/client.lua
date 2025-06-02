if GetCurrentResourceName() == "jo_libs" then return end

local moveCallbacks = {}
local numberMoveCallback = 0
local lastCallDidMoveFunc = {}
local lastMoveEvent = 0

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
  exports.jo_libs:loadGlobalModule("player")
  exports.jo_libs:jo_player_update(function(values)
    local now = GetGameTimer()
    for i = 1, #values do
      local key, value = values[i][1], values[i][2]
      jo.player[key] = value
      if key == "coords" and numberMoveCallback > 0 then
        lastMoveEvent = now
        for c = 1, numberMoveCallback do
          local callback = moveCallbacks[c]
          if not callback.inProgress and (callback.lastExec + callback.interval) < now then
            CreateThreadNow(function()
              callback.lastExec = now
              callback.inProgress = true
              callback.cb()
              callback.inProgress = false
            end)
          end
        end
      end
    end
  end)
end

jo.ready(addUpdater)

AddEventHandler("onResourceStart", function(resourceName)
  if resourceName ~= "jo_libs" then return end
  addUpdater()
end)


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
    lastExec = GetGameTimer(),
    interval = interval or 0,
    inProgress = true
  }
  local currentMove = numberMoveCallback
  CreateThreadNow(function()
    cb()
    moveCallbacks[currentMove].inProgress = false
  end)
end

--- A function to know if the player moved since the last called of the function
---@param id string (Unique ID of call)
---@return boolean (`true` if the player moved since the last call)
function jo.player.didMoveSinceLastCall(id)
  local now = GetGameTimer()
  local move = false
  if (lastCallDidMoveFunc[id] or 0) <= lastMoveEvent then
    move = true
  end
  lastCallDidMoveFunc[id] = now
  return move
end

-------------
-- Shortcut
-------------
jo.pl = jo.player
