jo.animation = {}

jo.animation.easeIn = 4.0
jo.animation.easeOut = -4.

--- Load the dictionnary of animation
---@param dict string (The dictionnary of the animation)
---@param waiter? boolean (If need to wait the loading to end the function - default:false)
function jo.animation.load(dict, waiter)
  if HasAnimDictLoaded(dict) then return end
  RequestAnimDict(dict)
  while waiter and not HasAnimDictLoaded(dict) do
    Wait(10)
  end
end

--- Play animation. The function load automatically necessary resources.
---@param ped integer (The entity where the animation will be played)
---@param dict string (The dictionnary of the animation)
---@param name string (The name of the animation)
---@param duration? integer (Duration of the animation in ms - default:-1)
---@param flag? integer (The flag of the animation - default:0)
---@param offset? float (The offset of the animation 0.0 <> 1.0 - default: 0.0)
---@return number
function jo.animation.play(ped, dict, name, duration, flag, offset)
  if not duration then duration = -1 end
  if not flag then flag = 0 end
  if not offset then offset = 0.0 end
  jo.animation.load(dict, true)
  TaskPlayAnim(ped, dict, name, jo.animation.easeIn, jo.animation.easeOut, duration, flag, offset, false, false, false)
  return GetAnimDuration(dict, name) * 1000
end

--- Function to move a ped to a destination
---@param ped integer (The ped to move)
---@param coords vector (vec3 or vec4 - The coordinate of the destination <br> If vector4 is used, the ped will stop at the end and turn to the desired heading)
---@param speed? float (The speed of the walk - default:1.0)
---@param waiter? boolean (If need to wait the reach of location to end the function - default:false)
---@param distanceToStop? float (The distance between the ped and the destination to stop it - default:0.0)
function jo.animation.goToCoords(ped, coords, speed, waiter, distanceToStop)
  speed = speed or 1.0
  if waiter or type(coords) == "vector4" then
    local sequence = OpenSequenceTask(math.random(1000))
    TaskGoToCoordAnyMeans(0, coords.xyz, speed, 0, 0, 0, 0.1)
    CloseSequenceTask(sequence)
    ClearPedTasks(ped)
    TaskPerformSequence(ped, sequence)
    ClearSequenceTask(sequence)

    Wait(500)
    repeat
      Wait(0)
    until GetSequenceProgress(ped) == -1 or (distanceToStop and #(GetEntityCoords(ped) - coords.xyz) < distanceToStop)

    if type(coords) == "vector4" then
      jo.animation.setDesiredHeading(ped, coords.w, true)
    end
  else
    TaskGoToCoordAnyMeans(ped, coords.xyz, speed, 0, 0, 0, 0.1)
  end
end

--- Turn the ped to the desired heading
---@param ped integer (The ped to turn)
---@param heading number (The desired heading)
---@param waiter? boolean (If need to reach the heading to end the function - default:true)
function jo.animation.setDesiredHeading(ped, heading, waiter)
  waiter = GetValue(waiter, true)
  local isFrozen = IsEntityFrozen(ped) == 1
  if isFrozen then FreezeEntityPosition(ped, false) end
  TaskAchieveHeading(ped, heading % 360, 10000)

  local result = promise.new()

  CreateThread(function()
    Wait(1000)
    while not IsPedStill(ped) do Wait(100) end
    ClearPedTasks(ped)
    if isFrozen then FreezeEntityPosition(ped, true) end
    result:resolve()
  end)

  if waiter then
    Await(result)
  end
end

--- Turn the ped to face the target
---@param ped integer (The ped to turn)
---@param target integer (The target to face)
---@param waiter? boolean (If need to reach the heading to end the function - default:true)
function jo.animation.faceEntity(ped, target, waiter)
  waiter = GetValue(waiter, true)
  local isFrozen = IsEntityFrozen(ped) == 1
  if isFrozen then FreezeEntityPosition(ped, false) end
  TaskTurnPedToFaceEntity(ped, target, 10000)

  local result = promise.new()
  CreateThread(function()
    Wait(1000)
    while not IsPedStill(ped) do Wait(100) end
    ClearPedTasks(ped)
    if isFrozen then FreezeEntityPosition(ped, true) end
    result:resolve()
  end)

  if waiter then
    Await(result)
  end
end

function jo.animation.waitTaskEnd(ped, task)
  task = GetHashFromString(task)
  while GetScriptTaskStatus(ped, task) <= 1 do
    Wait(10)
  end
end
