jo.me = setmetatable({
  entity = PlayerPedId(),
  coords = GetEntityCoords(PlayerPedId()),
  playerId = PlayerId(),
  serverId = GetPlayerServerId(PlayerId()),
  timer = 1000
},
{
  __tostring = function(self)
    return self.entity
  end
})

---@param value integer the new interval to update me values
function jo.me.updateTimer(value)
  jo.me.timer = value
end

function jo.me.forceUpdate()
  jo.me.entity = PlayerPedId()
  jo.me.coords = GetEntityCoords(PlayerPedId())
  jo.me.playerId = PlayerId()
  jo.me.serverId = GetPlayerServerId(PlayerId())
end

local function updateMe()
  jo.me.forceUpdate()
  SetTimeout(jo.me.timer,updateMe)
end
SetTimeout(jo.me.timer,updateMe)

return jo.me