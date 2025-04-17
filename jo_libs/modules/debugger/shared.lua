jo.debugger = {}

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
    local starTime = jo.isServerSide() and os.microtime() or GetNumberOfMicrosecondsSinceLastCall()
    cb()
    local endTime = jo.isServerSide() and os.microtime() or GetNumberOfMicrosecondsSinceLastCall()
    local duration = jo.isServerSide() and (endTime - starTime) or endTime
    sumDuration += duration
    if waitBetweenRepeat then
      Wait(waitBetweenRepeat)
    end
  end
  local duration = math.floor(sumDuration / numberRepeat)
  print(("%d, Performance average on %d repetition: %s -> %d μs"):format(jo.isServerSide() and os.microtime() or GetGameTimer(), numberRepeat, title, duration))
  return duration
end
