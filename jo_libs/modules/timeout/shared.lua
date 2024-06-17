local delays = {}

---@class TimeoutClass : table Timeout class
local TimeoutClass = {}

---@param msec any timeout in ms/waiter function
---@param cb function
---@return TimeoutClass TimeoutClass class
function TimeoutClass:set(msec,cb)
	local t = setmetatable({}, self)
	self.__index = self
  t:start(msec,cb)
	return t
end

---@param msec integer timeout in ms
---@param cb function
function TimeoutClass:start(msec,cb)
  self.msec = msec
  self.cb = cb
  self.id = math.random()
  self.canceled = false
  if (type(self.msec) == "number") then
    SetTimeout(self.msec, function()
      if self.canceled then
        return
      else
        self.cb()
      end
      self = nil
    end)
  elseif (type(self.msec) == "function") then
    CreateThread(function()
      self.msec()
      if self.canceled then
        return
      else
        self.cb()
      end
      self = nil
    end)
  end
end

--- Cancel the timeout
function TimeoutClass:clear()
  self.canceled = true
end

---@param id string identifier
---@param msec integer/function the waiter
---@param cb function the function to execute after the waiter
function TimeoutClass:delay(id,msec,cb)
  if delays[id] then
    delays[id]:clear()
  end
  delays[id] = jo.timeout:set(msec, cb)
end

jo.timeout = TimeoutClass

return jo.timeout