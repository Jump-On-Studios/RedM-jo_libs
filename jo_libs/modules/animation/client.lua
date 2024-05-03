jo.animation = {}

local function loadAnimDict(dict,waiter)
  while waiter and not HasAnimDictLoaded(dict) do
    RequestAnimDict(dict)
    Wait(10)
  end
end

function jo.animation.play(ped,dict,name,duration,flag,playbackRate)
  local waiter = promise.new()
  if not duration then duration = -1 end
  if not flag then flag = 0 end
  if not playbackRate then playbackRate = 0.0 end
  CreateThread(function()
    loadAnimDict(dict,true)
    TaskPlayAnim(ped, dict, name, 4.0, -4.0, duration, flag, offset, false, false, false)
    Wait(timer)
    RemoveAnimDict(dict)
    waiter:resolve(true)
  end)
  return waiter
end

return jo.animation