jo.timeout = {}

local TimeoutCount = 0
local TimeoutInProgress = {}
local TimeoutCancelled = {}

---@param msec integer timeout in ms
---@param cb function
---@return integer id the ID of the timeout
function jo.timeout.set(msec, cb)
  local id = TimeoutCount + 1
  TimeoutInProgress[id] = true
  SetTimeout(msec, function()
    TimeoutInProgress[id] = nil
    if TimeoutCancelled[id] then
      TimeoutCancelled[id] = nil
    else
      cb()
    end
  end)
  TimeoutCount = id
  return id
end

---@param id integer the ID of the timeout
function jo.timeout.clear(id)
  if not TimeoutInProgress[id] then return end
  TimeoutCancelled[id] = true
end

return jo.timeout