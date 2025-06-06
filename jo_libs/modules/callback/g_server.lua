local nextRequestId = 0
local responseCallback = {}
local registeredCallback = {}
local promise = promise
local pack = table.pack
local unpack = table.unpack
local insert = table.insert
jo.require("emit")

jo.callback = {}

local function isAFunction(cb)
  local cbType = type(cb)

  if cbType == "table" and getmetatable(cb)?.__call then
    return true
  end
  return false
end

--- A function to register a server callback
---@alias jo.callback.register function
---@param name string (The name of the callback event)
---@param cb function (The function executed when the callback is triggered <br> ⚠️ `source` is always the first argument)
function jo.callback.registerCallback(name, cb, latent)
  if registeredCallback[name] then return eprint("Callback already registered:", name) end
  registeredCallback[name] = {
    cb = cb,
    resource = GetInvokingResource(),
    latent = latent or false
  }
end

--- A function to register a latent server callback
---@alias jo.callback.registerLatent function
---@param name string (The name of the callback event)
---@param cb function (The function executed when the callback is triggered <br> ⚠️ `source` is always the first argument)
function jo.callback.registerLatentCallback(name, cb)
  jo.callback.registerCallback(name, cb, true)
end

AddEventHandler("onResourceStop", function(resource)
  for name, callback in pairs(registeredCallback) do
    if callback.resource == resource then
      registeredCallback[name] = nil
    end
  end
end)

local function executeCallback(name, ...)
  if not registeredCallback[name] then return false, eprint(("No callback for: %s"):format(name)) end
  return registeredCallback[name].cb(...)
end

--- A function to trigger a server callback
---@param name string (Name of the callback event)
---@param cb? function (Function to receive the result of the event)
---@param ...? any (The list of parameters to send to the callback event)
function jo.callback.triggerServer(name, cb, ...)
  if not registeredCallback[name] then return false, eprint("No server callback for:", name) end

  local cbType = isAFunction(cb) and "function" or "other"
  local args = { ... }

  if cbType == "function" then
    cb(executeCallback(name, unpack(args)))
  else
    if cb then
      insert(args, 1, cb)
    end
    return executeCallback(name, unpack(args))
  end
end

RegisterServerEvent("jo_libs:triggerCallback", function(name, requestId, fromRessource, ...)
  local source = source
  if not registeredCallback[name] then return eprint("No server callback for:", name) end

  local trigger = registeredCallback[name].latent and jo.emit.triggerClient.latent or TriggerClientEvent

  trigger(generateEventName("response", requestId), source, fromRessource, executeCallback(name, source, ...))
end)

--- A function to trigger a client callback
---@param name string (The name of the callback event)
---@param source integer (The source of the client to trigger)
---@param cb? function (Function to receive the result of the event)
---@param ...? any (The list of parameters to send to the callback event)
function jo.callback.triggerClient(name, source, cb, ...)
  if not source then
    return eprint("Source value is missing in your callback: ", name)
  end
  if not GetPlayerIdentifier(source, 1) then
    return eprint("Callback Module: Player is not connected - source: " .. source)
  end

  local cbType = isAFunction(cb) and "function" or "other"

  local currentRequestId = nextRequestId
  local args = { ... }
  local responseCallback

  if cbType == "function" then
    responseCallback = cb
  else
    if cb then
      insert(args, 1, cb)
    end
    responseCallback = promise.new()
  end

  local handler
  handler = RegisterNetEvent(generateEventName("response", currentRequestId), function(fromResource, ...)
    dprint("Response received for request ID: %d from resource: %s", currentRequestId, fromResource)
    if isAFunction(responseCallback) then
      responseCallback(...)
    else
      responseCallback:resolve(pack(...))
    end
    RemoveEventHandler(handler)
  end)


  TriggerClientEvent("jo_libs:triggerCallback", source, name, currentRequestId, GetInvokingResource() or "unknown", unpack(args))

  nextRequestId = nextRequestId < 65535 and nextRequestId + 1 or 0
  if cbType == "function" then
    return
  end
  return unpack(Await(responseCallback) or {})
end

exports("getCallbackAPI", function()
  return jo.callback
end)
