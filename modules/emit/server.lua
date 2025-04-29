jo.emit = {}

local msgpack_pack_args = msgpack.pack_args
local emitBps = GetConvarInt("jo_libs:emit:bps", 20000) --Default bit/s for latent events

AddConvarChangeListener("jo_libs:emit:bps", function(value)
  bprint("New bit/s for emit module: ", value)
  emitBps = tonumber(value)
end)

--- A function to update the bit/s of emit module
---@param bps integer (bit/s)
function jo.emit.updateBps(bps)
  emitBps = tonumber(bps)
end

local function fireClientEvent(eventName, source, payload, payloadLen, bps)
  TriggerClientEvent("jo_libs:client:emit:start", source, eventName)
  if bps then
    TriggerLatentClientEventInternal(eventName, source, payload, payloadLen, bps)
  else
    TriggerClientEventInternal(eventName, source, payload, payloadLen)
  end
end

--- A function to trigger a client(s) with a limited bandwith
---@alias jo.emit.triggerClient.latent function
---@param eventName string (The event name)
---@param source integer|table (The player ID or list of players ID)
---@param ... any (Other arguments)
local function triggerClientLatent(eventName, source, ...)
  local payload = msgpack_pack_args(...)
  local payloadLen = #payload

  if type(source) == "table" then
    if table.type(source) == "array" then
      for i = 1, #source do
        fireClientEvent(eventName, source[i], payload, payloadLen, emitBps)
      end
      return
    elseif table.type(source) == "hash" then
      for _source, _ in pairs(source) do
        fireClientEvent(eventName, _source, payload, payloadLen, emitBps)
      end
      return
    end
  end

  fireClientEvent(eventName, source, payload, payloadLen, emitBps)
end

--- A function to trigger a client(s)
---@alias jo.emit.triggerClient function
---@param eventName string (The event name)
---@param source integer|table (The player ID or list of players ID)
---@param ... any (Other arguments)
local function triggerClient(eventName, source, ...)
  local payload = msgpack_pack_args(...)
  local payloadLen = #payload

  if type(source) == "table" then
    if table.type(source) == "array" then
      for i = 1, #source do
        fireClientEvent(eventName, source[i], payload, payloadLen)
      end
      return
    elseif table.type(source) == "hash" then
      for _source, _ in pairs(source) do
        fireClientEvent(eventName, _source, payload, payloadLen)
      end
      return
    end
  end

  fireClientEvent(eventName, source, payload, payloadLen)
end

jo.emit.triggerClient = setmetatable({
  latent = triggerClientLatent
}, {
  __call = function(_, ...)
    triggerClient(...)
  end
})
