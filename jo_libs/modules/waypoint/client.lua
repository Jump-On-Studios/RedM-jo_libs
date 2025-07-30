jo.waypoint = {}

jo.stopped(function()
    ClearGpsMultiRoute()
end)

--- Set a GPS waypoint to a given location
---@param location vector3 (The location to set the waypoint to)
---@param callback function (Optional callback to be called once the waypoint is reached)
---@param clearDist boolean (The distance to trigger the callback and clear the waypoint)
---@param autoClear boolean (Whether to automatically clear the waypoint when reached)
function jo.waypoint.set(location, callback, clearDist, autoClear)
  StartGpsMultiRoute(GetHashKey("COLOR_YELLOW"), true, true)
  AddPointToGpsMultiRoute(location.x, location.y, location.z)
  SetGpsMultiRouteRender(true)

  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(500)

      local playerPed = PlayerPedId()
      local playerPos = GetEntityCoords(playerPed)

      local dist = Vdist(playerPos.x, playerPos.y, playerPos.z, location.x, location.y, location.z)

      if dist < clearDist then
        if callback then
          callback()
        end
        if autoClear then
          jo.waypoint.clear()
        end
        break
      end
    end
  end)
end

--- Set a GPS waypoint to a blip's coordinates
---@param blip integer (The blip ID)
---@param callback function (Optional callback to be called once the waypoint is reached)
---@param autoClear boolean (Whether to automatically clear the waypoint when reached)
function jo.waypoint.setToBlip(blip, callback, autoClear)
  if DoesBlipExist(blip) then
    local x, y, z = GetBlipInfoIdCoord(blip)
    jo.waypoint.set(vector3(x, y, z), callback, autoClear)
  else
    print("Invalid blip ID or blip does not exist.")
  end
end

--- Clear any active GPS waypoints
function jo.waypoint.clear()
  ClearGpsMultiRoute()
end