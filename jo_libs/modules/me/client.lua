jo.me = PlayerPedId()
jo.meCoords = GetEntityCoords(me)
local timer = 1000

function jo.updateMeTimer(value)
  timer = value
end

function jo.forceUpdateMe()
  jo.me = PlayerPedId()
  jo.meCoords = GetEntityCoords(jo.me)

end

local function updateMe()
  jo.me = PlayerPedId()
  jo.meCoords = GetEntityCoords(jo.me)
  SetTimeout(timer,updateMe)
end
SetTimeout(timer,updateMe)