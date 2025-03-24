jo.debugger = {}

local function now()
  return os and os.microtime() or GetGameTimer() * 1000
end

jo.debugger.perfomance = function(title, cb)
  return jo.debugger.perfomanceRepeat(title, 1, cb)
end

jo.debugger.perfomanceRepeat = function(title, numberRepeat, cb, waitBetweenRepeat)
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
