me = PlayerPedId()
meCoords = GetEntityCoords(me)

local function updateMe()
  me = PlayerPedId()
  meCoords = GetEntityCoords(me)
  SetTimeout(1000,updateMe)
end
SetTimeout(1000,updateMe)