local delays = {}
jo.timeout = {}

if not IsModuleLoaded('table') then
  jo.require('table')
end

---@class TimeoutClass : table Timeout class
local TimeoutClass = {
  msec = 1000,
  cb = function() end,
  id = 0,
  canceled = false,
}

---@param msec any timeout in ms/waiter function
---@param cb function
---@return TimeoutClass TimeoutClass class
function TimeoutClass:set(msec,cb)
  local t = table.copy(TimeoutClass)
	local t = setmetatable(t, TimeoutClass)
	t.__index = table.copy(TimeoutClass)
  t.msec = msec
  t.cb = cb
  t.id = math.random()
	return t
end

function TimeoutClass:exec(...)
  local args = table.pack(...) or {}
  if (type(self.msec) == "number") then
    SetTimeout(self.msec, function()
      if self.canceled then
        return
      else
        self.cb(table.unpack(args))
      end
      self = nil
    end)
  elseif (type(self.msec) == "function") then
    CreateThread(function()
      self.msec()
      if self.canceled then
        return
      else
        CreateThread(function()
          self.cb(table.unpack(args))
          self = nil
        end)
      end
    end)
  end
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

function jo.timeout.set(msec,cb,...)
  local t = TimeoutClass:set(msec,cb)
  t:exec(...)
  return t
end

function jo.timeout.loop(msec,cb,...)
  local t = TimeoutClass:set(msec,cb)
  local args = table.pack(...)
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
function jo.timeout.delay(id,msec,cb,...)
  if delays[id] then
    delays[id]:clear()
  end
  delays[id] = jo.timeout.set(msec, cb, ...)
end

return jo.timeout