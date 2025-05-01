local nextRequestId = 0
local responseCallback = {}
local registeredCallback = {}
local promise = promise
local await = Citizen.Await
local pack = table.pack
local unpack = table.unpack
local insert = table.insert

jo.callback = {}

local function isAFunction(cb)
  local cbType = type(cb)

  if cbType == "table" and getmetatable(cb)?.__call then
    return true
  end
  return false
end

--- A function to register a server callback
---@param name string (The name of the callback event)
---@param cb function (The function executed when the callback is triggered <br> ⚠️ `source` is always the first argument)
function jo.callback.register(name, cb)
  if registeredCallback[name] then return eprint("Callback already registered:", name) end
  registeredCallback[name] = {
    cb = cb,
    resource = GetInvokingResource()
  }
end

AddEventHandler("onResourceStop", function(resource)
  for name, callback in pairs(registeredCallback) do
    if callback.resource == resource then
      registeredCallback[name] = nil
    end
  end
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
  if not GetPlayerIdentifier(source) then
    return eprint("Callback Module: Player is not connected - source: " .. source)
  end

  local cbType = isAFunction(cb) and "function" or "other"

  local currentRequestId = nextRequestId
  local args = { ... }

  if cbType == "function" then
    responseCallback[currentRequestId] = cb
  else
    if cb then
      insert(args, 1, cb)
    end
    responseCallback[currentRequestId] = promise.new()
  end


  TriggerClientEvent("jo_libs:triggerCallback", source, name, currentRequestId, GetInvokingResource() or "unknown",
    unpack(args))

  nextRequestId = nextRequestId < 65535 and nextRequestId + 1 or 0
  if cbType == "function" then
    return
  end
  return unpack(await(responseCallback[currentRequestId]) or {})
end

local function executeCallback(name, ...)
  if not registeredCallback[name] then return false, eprint(("No callback for: %s"):format(name)) end
  return registeredCallback[name].cb(...)
end

--- A function to trigger a server callback
---@param name string (Name of the callback event)
---@param cb? function (Function to receive the result of the event)
---@param ...? mixed (The list of parameters to send to the callback event)
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

RegisterServerEvent("jo_libs:responseCallback", function(requestId, fromRessource, ...)
  if not responseCallback[requestId] then
    return eprint(("No callback response for: %d - Called from: %d"):format(
      requestId, fromRessource))
  end
  if isAFunction(responseCallback[requestId]) then
    responseCallback[requestId](...)
  else
    responseCallback[requestId]:resolve(pack(...))
  end
  responseCallback[requestId] = nil
end)

RegisterServerEvent("jo_libs:triggerCallback", function(name, requestId, fromRessource, ...)
  local source = source
  TriggerClientEvent("jo_libs:responseCallback", source, requestId, fromRessource, executeCallback(name, source, ...))
end)

exports("getCallbackAPI", function()
  return jo.callback
end)
