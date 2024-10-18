jo.animation = {}

jo.animation.easeIn = 4.0
jo.animation.easeOut = -4.

---@param dict string the dictionnary
---@param waiter? boolean need wait the loading. (default: false)
function jo.animation.load(dict, waiter)
  if HasAnimDictLoaded(dict) then return end
  RequestAnimDict(dict)
  while waiter and not HasAnimDictLoaded(dict) do
    Wait(10)
  end
end

---@param ped integer the entity who play the animation
---@param dict string the animation dictionnary
---@param name string the animation name
---@param duration? string the duration of the animation (default: -1)
---@param flag? integer the animation flag (default: 0)
---@param offset? number the animation percent where start the animation (default: 0.0)
function jo.animation.play(ped, dict, name, duration, flag, offset)
  if not duration then duration = -1 end
  if not flag then flag = 0 end
  if not offset then offset = 0.0 end
  jo.animation.load(dict, true)
  TaskPlayAnim(ped, dict, name, jo.animation.easeIn, jo.animation.easeOut, duration, flag, offset, false, false, false)
  return GetAnimDuration(dict, name) * 1000
end

---@param ped integer
---@param destination vector (vec3 or vec4)
---@param speed? number (default : 1.0)
---@param waiter? boolean (default: true if (destination == vec4) else false)
---@param distanceToStop? number Distance to accept the player is arrived
function jo.animation.goToCoords(ped, destination, speed, waiter, distanceToStop)
  speed = speed or 1.0
  if waiter or type(destination) == "vector4" then
    local sequence = OpenSequenceTask(math.random(1000))
    TaskGoToCoordAnyMeans(0, destination.xyz, speed, 0, 0, 0, 0.1)
    CloseSequenceTask(sequence)
    ClearPedTasks(ped)
    TaskPerformSequence(ped, sequence)
    ClearSequenceTask(sequence)

    Wait(500)
    repeat
      Wait(0)
    until GetSequenceProgress(ped) == -1 or (distanceToStop and #(GetEntityCoords(ped) - destination.xyz) < distanceToStop)

    if type(destination) == "vector4" then
      jo.animation.setDesiredHeading(ped, destination.w, true)
    end
  else
    TaskGoToCoordAnyMeans(ped, destination.xyz, speed, 0, 0, 0, 0.1)
  end
end

---@param ped integer
---@param heading number
---@param waiter? boolean default: true
function jo.animation.setDesiredHeading(ped, heading, waiter)
  if waiter == nil then waiter = true end
  TaskAchieveHeading(ped, heading % 360, 10000)

  if waiter then
    Wait(1000)
    while not IsPedStill(ped) do
      Wait(100)
    end
  end
end

return jo.animation
