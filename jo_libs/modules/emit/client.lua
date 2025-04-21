jo.emit = {}

local msgpack_pack_payload = msgpack.pack_payload
local bps = GetConvarInt("jo_libs:emit:bps", 5000)

AddConvarChangeListener("jo_libs:emit:bps", function(value)
  bprint("New bit/s for emit module: ", value)
  bps = tonumber(value)
end)

local function triggerServerLatent(eventName, ...)
  local payload = msgpack_pack_payload(...)
  local payloadLen = #payload

  TriggerLatentServerEventInternal(eventName, payload, payloadLen, bps)
end

local function triggerServer(name, ...)
  local payload = msgpack_pack_payload(...)
  local payloadLen = #payload

  TriggerServerEventInternal(name, payload, payloadLen)
end

jo.emit.triggerServer = setmetatable({
  latent = triggerServerLatent
}, {
  __call = triggerServer
})
