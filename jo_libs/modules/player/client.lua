if GetCurrentResourceName() == "jo_libs" then return end

local moveCallbacks = {}
local numberMoveCallback = 0
local lastCallDidMoveFunc = 0
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
jo.player.activePlayers = GetActivePlayers()

local function addUpdater()
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
  cb()
  moveCallbacks[numberMoveCallback].inProgress = false
end

--- A function to know if the player moved since the last called of the function
---@return boolean (`true` if the player moved since the last call)
function jo.player.didMoveSinceLastCall()
  local now = GetGameTimer()
  local move = false
  if lastCallDidMoveFunc < lastMoveEvent then
    move = true
  end
  lastCallDidMoveFunc = now
  return move
end

-- A function to return the closest CliendID of a player within a given radius
---@param radius number (radius to search) required
---@param ignoreSelf? boolean (if `true`, the function will not return the player itself)
function jo.player.getClosestPlayer(radius, ignoreSelf)
  if not radius then return eprint("Must supply a radius value") end

  local players = jo.player.activePlayers
  local closestPlayerDistance
  local closestClientId

  local playerPed = jo.player.ped
  local playerCoords = jo.player.coords

  for i = 1, #players do
    local targetPlayer = GetPlayerPed(players[i])

    if targetPlayer ~= playerPed then
      local checkDistance = #(GetEntityCoords(targetPlayer) - playerCoords)
      if checkDistance <= radius then
        if not closestPlayerDistance or checkDistance < closestPlayerDistance then
          closestClientId = players[i]
          closestPlayerDistance = checkDistance
        end
      end
    end
  end

  if closestClientId then
    return closestClientId, closestPlayerDistance
  end

  if ignoreSelf then
    return nil, nil
  end

  return jo.player.playerId, 0
end

-- A function to convert a clientId to a serverId
---@param id number (clientId to convert) required
function jo.player.getServerId(id)
  if not id then return eprint("Must supply a player id") end
  return GetPlayerServerId(id)
end

-------------
-- Shortcut
-------------
jo.pl = jo.player
