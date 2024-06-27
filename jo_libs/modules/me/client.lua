jo.me = PlayerPedId()
jo.meCoords = GetEntityCoords(me)
jo.mePlayerId = PlayerId()
jo.meServerId = GetPlayerServerId(jo.mePlayerId)
jo.meIsMale =  IsPedMale(PlayerPedId())
local timer = 1000
local timeout

if not not IsModuleLoaded('timeout') then
  jo.require('timeout')
end

local function updateMe()
  jo.forceUpdateMe()
end
timeout = jo.timeout.loop(timer,updateMe)

---@param value integer the new interval to update me values
function jo.updateMeTimer(value)
  timer = value
  if timeout then
    timeout:clear()
  end
  if timer then
    timeout = jo.timeout.loop(timer,updateMe)
  end
end

function jo.forceUpdateMe()
  jo.me = PlayerPedId()
  jo.meCoords = GetEntityCoords(jo.me)
  jo.mePlayerId = PlayerId()
  jo.meServerId = GetPlayerServerId(jo.mePlayerId)
  jo.meIsMale =  IsPedMale(jo.me)
end

return jo.me