jo.waiter = {}
local context = IsDuplicityVersion() and "server" or "client"

local function getTime()
  if context == "server" then
    return os.time() * 1000
  else
    return GetGameTimer()
  end
end

---@param condition function the condition to stop the loop
---@param executable function function to execute after each test
---@param loopSpeed integer the wait between each test in ms
---@param maxDuration integer the max duration to wait in ms
---@return boolean result true if the condition is down or false
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
