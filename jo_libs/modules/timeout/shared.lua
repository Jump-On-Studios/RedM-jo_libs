local delays = {}
jo.createModule("timeout")

jo.require("table")

---@class TimeoutClass : table Timeout class
---@field id? string (The unique ID when registered in the delays list)
local TimeoutClass = {
  msec = 1000,
  cb = function() end,
  args = {},
  canceled = false,
}

--- Initialize a new timeout
---@param msec integer|function (The waiter of the function)
---@param cb function (The function to execute after waiter)
---@param args? table (Optional arguments to pass to the callback function)
---@return TimeoutClass (Return the timeout instance)
function TimeoutClass:set(msec, cb, args)
  local t = table.copy(TimeoutClass)
  t.msec = msec
  t.cb = cb
  t.args = args or {}
  return t
end

--- Start the timeout by initiating the waiting period
--- Either waits for msec milliseconds or executes the waiter function
function TimeoutClass:start()
  if (type(self.msec) == "number") then
    SetTimeout(self.msec, function()
      self:execute()
    end)
  elseif (type(self.msec) == "function") then
    CreateThreadNow(function()
      self.msec()
      if self.canceled then
        return
      else
        CreateThreadNow(function()
          self:execute()
        end)
      end
    end)
  end
end

--- Execute the callback function
--- Automatically clears the timeout and passes any stored arguments to the callback
function TimeoutClass:execute()
  if self.canceled then
    return false
  end
  self:clear()
  self.cb(table.unpack(self.args))
  if self.id and delays[self.id] == self then
    delays[self.id] = nil
  end
  return true
end

--- Change the callback function of the timeout
---@param cb function (The new callback function)
function TimeoutClass:setCb(cb)
  self.cb = cb
end

--- Change the timeout duration or waiter function
---@param msec integer|function (New timeout duration in ms or a new waiter function)
function TimeoutClass:setMsec(msec)
  self.msec = msec
end

--- Cancel the timeout
--- Prevents the callback from being executed
function TimeoutClass:clear()
  self.canceled = true
end

--- A function to set a timeout
---@param msec integer|function (If integer: wait duration in ms. If function: the function will be executed before cb)
---@param cb function (The function executed when waiter is done)
---@param ... any (Additional arguments to pass to the callback function)
---@return TimeoutClass (Return the timeout instance)
function jo.timeout.set(msec, cb, ...)
  local args = table.pack(...)
  local t = TimeoutClass:set(msec, cb, args)
  t:start()
  return t
end

--- Create a loop to execute the function at regular interval
---@param msec integer (The duration between two executions of cb)
---@param cb function (The function executed every msec ms)
---@param ... any (Additional arguments to pass to the callback function)
---@return TimeoutClass (Return the timeout instance)
function jo.timeout.loop(msec, cb, ...)
  local args = table.pack(...)
  local t = TimeoutClass:set(msec, cb, args)
  CreateThread(function()
    while not t.canceled do
      cb(table.unpack(args))
      Wait(t.msec)
    end
  end)
  return t
end

--- Create a timeout registered in the delays list BEFORE it starts,
--- so a callback executed synchronously can still be tracked by its id
local function registerDelay(id, msec, cb, args)
  local t = TimeoutClass:set(msec, cb, args)
  t.id = id
  delays[id] = t
  t:start()
  return t
end

--- A function to delay execution. If another delay is created with the same id, the previous one will be canceled
---@param id string (The unique ID of the delay)
---@param msec integer|function (The duration before execute cb or a waiter function)
---@param cb function (The function executed after msec)
---@param ... any (Additional arguments to pass to the callback function)
---@return TimeoutClass (Return the timeout instance)
function jo.timeout.delay(id, msec, cb, ...)
  if delays[id] then
    delays[id]:clear()
  end
  return registerDelay(id, msec, cb, table.pack(...))
end


--- A function to delay the second execution. If another delay is created with the same id, the previous one is canceled
---@param id string (The unique ID of the delay)
---@param msec integer|function (The duration before execute cb or a waiter function)
---@param cb function (The function executed after msec)
---@param ... any (Additional arguments to pass to the callback function)
---@return TimeoutClass (Return the timeout instance)
function jo.timeout.noSpam(id, msec, cb, ...)
  if delays[id] then
    delays[id]:clear()
    return registerDelay(id, msec, cb, table.pack(...))
  end
  -- Leading edge: register a placeholder BEFORE executing cb so calls fired
  -- while cb is still running (it can yield) are treated as "second" calls,
  -- then start the placeholder AFTER cb to keep the debounce window alive
  local t = TimeoutClass:set(msec, function() end, {})
  t.id = id
  delays[id] = t
  cb(...)
  t:start()
  return t
end
