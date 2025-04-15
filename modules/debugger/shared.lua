jo.debugger = {}

--- Returns the current time in microseconds.
---@return number (Current time in microseconds)
local function now()
  return os and os.microtime() or GetGameTimer() * 1000
end

--- Measures the performance of a callback function execution.
---@param title? string (Title for the performance measurement - default:"")
---@param cb function (The callback function to measure)
---@return number (Duration in microseconds)
function jo.debugger.perfomance(title, cb)
  return jo.debugger.perfomanceRepeat(title, 1, cb)
end

--- Measures the average performance of multiple executions of a callback function.
---@param title? string (Title for the performance measurement - default:"")
---@param numberRepeat? integer (Number of times to repeat the measurement - default:1)
---@param cb function (The callback function to measure)
---@param waitBetweenRepeat? integer (Time to wait between repetitions in ms - default:nil)
---@return number (Average duration in microseconds)
function jo.debugger.perfomanceRepeat(title, numberRepeat, cb, waitBetweenRepeat)
  local sumDuration = 0
  title = title or ""
  numberRepeat = math.max(numberRepeat or 1, 1)
  for i = 1, numberRepeat do
    local starTime = now()
    cb()
    local endTime = now()
    local duration = endTime - starTime
    sumDuration += duration
    if waitBetweenRepeat then
      Wait(waitBetweenRepeat)
    end
  end
  local duration = math.floor(sumDuration / numberRepeat)
  print(("%d, Performance average on %d repetition: %s -> %d μs"):format(now(), numberRepeat, title, duration))
  return duration
end
