jo.waiter = {}
local context = IsDuplicityVersion() and "server" or "client"

local function getTime()
  if context == "server" then
    return os.time() * 1000
  else
    return GetGameTimer()
  end
end

--- Execute a function repeatedly until a condition is met or a timeout occurs.
---@param condition function (The condition to stop the loop)
---@param executable? function (Function to execute after each test)
---@param loopSpeed? integer (The wait between each test in ms <br> default:0)
---@param maxDuration? integer (The max duration to wait in ms <br> default:5000)
---@return boolean (True if the condition was met, false if timeout occurred)
function jo.waiter.exec(condition, executable, loopSpeed, maxDuration)
  maxDuration = maxDuration or 5000
  loopSpeed = loopSpeed or 0
  local endLoop = getTime() + maxDuration
  while not condition() do
    if executable then executable() end
    Wait(loopSpeed)
    if getTime() > endLoop then
      return false
    end
  end
  return true
end
