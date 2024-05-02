jo.me = PlayerPedId()
jo.meCoords = GetEntityCoords(me)
jo.mePlayerId = PlayerId()
jo.meServerId = GetPlayerServerId(PlayerId())
jo.meIsMale =  IsPedMale(PlayerPedId())
local timer = 1000

---@param value integer the new interval to update me values
function jo.updateMeTimer(value)
  timer = value
end

function jo.forceUpdateMe()
  jo.me = PlayerPedId()
  jo.meCoords = GetEntityCoords(jo.me)
  jo.mePlayerId = PlayerId()
  jo.meServerId = GetPlayerServerId(jo.meServerId)
  jo.meIsMale =  IsPedMale(jo.me)
end

local function updateMe()
  jo.forceUpdateMe()
  SetTimeout(timer,updateMe)
end
SetTimeout(timer,updateMe)

return jo.me