jo.emit = {}

local msgpack_pack_payload = msgpack.pack_payload
local bps = GetConvarInt("jo_libs:emit:bps", 5000)

AddConvarChangeListener("jo_libs:emit:bps", function(value)
  bprint("New bit/s for emit module: ", value)
  bps = tonumber(value)
end)

local function triggerClientLatent(eventName, source, ...)
  local payload = msgpack_pack_payload(...)
  local payloadLen = #payload

  if type(source) == "table" then
    if table.type(source) == "array" then
      for i = 1, #source do
        TriggerLatentClientEventInternal(eventName, source[i], payload, payloadLen, bps)
      end
      return
    elseif table.type(source) == "hash" then
      for _source, _ in pairs(source) do
        TriggerLatentClientEventInternal(eventName, _source, payload, payloadLen, bps)
      end
      return
    end
  end

  TriggerLatentClientEventInternal(eventName, source, payload, payloadLen, bps)
end

local function triggerClient(name, source, ...)
  local payload = msgpack_pack_payload(...)
  local payloadLen = #payload

  if type(source) == "table" then
    if table.type(source) == "array" then
      for i = 1, #source do
        TriggerClientEventInternal(name, source[i], payload, payloadLen)
      end
      return
    elseif table.type(source) == "hash" then
      for _source, _ in pairs(source) do
        TriggerClientEventInternal(name, _source, payload, payloadLen)
      end
      return
    end
  end

  TriggerClientEventInternal(name, source, payload, payloadLen)
end

jo.emit.triggerClient = setmetatable({
  latent = triggerClientLatent
}, {
  __call = triggerClient
})
