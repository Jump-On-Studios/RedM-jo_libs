local delays = {}
jo.timeout = {}

jo.require("table")

---@class TimeoutClass : table Timeout class
local TimeoutClass = {
  msec = 1000,
  cb = function() end,
  id = 0,
  args = {},
  canceled = false,
}

---@param msec any timeout in ms/waiter function
---@param cb function
---@return TimeoutClass TimeoutClass class
function TimeoutClass:set(msec, cb, args)
  local t = table.copy(TimeoutClass)
  t.msec = msec
  t.cb = cb
  t.id = math.random()
  t.args = args or {}
  return t
end

function TimeoutClass:start()
  if (type(self.msec) == "number") then
    SetTimeout(self.msec, function()
      self:execute()
    end)
  elseif (type(self.msec) == "function") then
    CreateThread(function()
      self.msec()
      if self.canceled then
        return
      else
        CreateThread(function()
          self:execute()
        end)
      end
    end)
  end
end

function TimeoutClass:execute()
  if not self.canceled then
    self:clear()
    self.cb(table.unpack(self.args))
  end
  self = nil
end

function TimeoutClass:setCb(cb)
  self.cb = cb
end

function TimeoutClass:setMsec(msec)
  self.msec = msec
end

--- Cancel the timeout
function TimeoutClass:clear()
  self.canceled = true
end

function jo.timeout.set(msec, cb, ...)
  local args = table.pack(...)
  local t = TimeoutClass:set(msec, cb, args)
  t:start()
  return t
end

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

---@param id string identifier
---@param msec any function/integer the waiter
---@param cb function the function to execute after the waiter
function jo.timeout.delay(id, msec, cb, ...)
  if delays[id] then
    delays[id]:clear()
  end
  delays[id] = jo.timeout.set(msec, cb, ...)
  return delays[id]
end
