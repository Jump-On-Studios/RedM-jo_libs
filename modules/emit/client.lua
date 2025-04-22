jo.emit = {}

local eventsInProgress = {}

local msgpack_pack_args = msgpack.pack_args
local emitBps = GetConvarInt("jo_libs:emit:bps", 20000)

AddConvarChangeListener("jo_libs:emit:bps", function(value)
  bprint("New bit/s for emit module: ", value)
  emitBps = tonumber(value)
end)

--- A function to update the bit/s of emit module
---@param bps integer (bit/s)
function jo.emit.updateBps(bps)
  emitBps = tonumber(bps)
end

--- A function to trigger the server with limited bandwith
---@alias jo.emit.triggerServer.latent function
---@param eventName string (The event name)
---@param ... any (Other arguments)
local function triggerServerLatent(eventName, ...)
  local payload = msgpack_pack_args(...)
  local payloadLen = #payload

  TriggerLatentServerEventInternal(eventName, payload, payloadLen, emitBps)
end

--- A function to trigger the server
---@alias jo.emit.triggerServer function
---@param eventName string (The event name)
---@param ... any (Other arguments)
local function triggerServer(eventName, ...)
  local payload = msgpack_pack_args(...)
  local payloadLen = #payload

  TriggerServerEventInternal(eventName, payload, payloadLen)
end

jo.emit.triggerServer = setmetatable({
  latent = triggerServerLatent
}, {
  __call = triggerServer
})

function jo.emit.isEventInProgress(eventName)
  return eventsInProgress[eventName] or nil
end

RegisterNetEvent("jo_libs:client:emit:start", function(eventName)
  local handler
  local time = GetGameTimer()
  handler = AddEventHandler(eventName, function()
    eventsInProgress[eventName] = nil
    RemoveEventHandler(handler)
    dprint(("Emit: %s takes %dms"):format(eventName, GetGameTimer() - time))
  end)
end)
