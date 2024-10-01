jo.me = PlayerPedId()
jo.meCoords = GetEntityCoords(jo.me)
jo.mePlayerId = PlayerId()
jo.meServerId = GetPlayerServerId(jo.mePlayerId)
jo.meIsMale = IsPedMale(PlayerPedId())

local valueUpdated = false

AddEventHandler('jo_me:updateMe', function(me, meCoords, mePlayerId, meServerId, meIsMale)
  jo.me = me
  jo.meCoords = meCoords
  jo.mePlayerId = mePlayerId
  jo.meServerId = meServerId
  jo.meIsMale = meIsMale
  valueUpdated = true
end)

---Deprecated
function jo.updateMeTimer()
end

function jo.forceUpdateMe()
  valueUpdated = false
  exports.jo_libs:jo_me_forceUpdateMe()
  while not valueUpdated do Wait(0) end
end
