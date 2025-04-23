local nextRequestId = 0
local responseCallback = {}
local registeredCallback = {}
local promise = promise
local await = Citizen.Await
local pack = table.pack
local unpack = table.unpack
local insert = table.insert

jo.callback = {}

-- Function to check if a variable is a callable function.
-- Checks both direct functions and tables with __call metamethod.
--@param cb any (The variable to check)
--@return boolean (True if the variable is a function or callable, false otherwise)
local function isAFunction(cb)
  local cbType = type(cb)

  if cbType == "table" and getmetatable(cb)?.__call then
    return true
  end
  return false
end

--- A function to register a client callback
---@param name string (The name of the callback event)
---@param cb function (The function executed when the callback is triggered)
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

--- A function to trigger a server callback
---@param name string (Name of the callback event)
---@param cb? function (Function to receive the result of the event)
---@param ...? mixed (The list of parameters to send to the callback event)
function jo.callback.triggerServer(name, cb, ...)
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

  TriggerServerEvent("jo_libs:triggerCallback", name, currentRequestId, GetInvokingResource() or "unknown", unpack(args))

  nextRequestId = nextRequestId < 65535 and nextRequestId + 1 or 0

  if cbType == "function" then
    return
  end
  return unpack(await(responseCallback[currentRequestId]) or {})
end

--deprecated function
jo.triggerServerCallback = jo.callback.triggerServer


-- Execute a registered callback by name.
-- Internal function that runs the callback and returns its results.
--@param name string (The name of the registered callback to execute)
--@param ...? any (Parameters to pass to the callback)
--@return any (Return values from the executed callback)
local function executeCallback(name, ...)
  if not registeredCallback[name] then return false, eprint(("No callback for: %s"):format(name)) end
  return registeredCallback[name].cb(...)
end

--- A function to trigger a client callback
---@param name string (The name of the callback event)
---@param cb? function|nil (Function to receive the result of the event)
---@param ...? mixed (The list of parameters to send to the callback event)
function jo.callback.triggerClient(name, cb, ...)
  if not registeredCallback[name] then return false, eprint("No client callback for:", name) end

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

RegisterNetEvent("jo_libs:responseCallback", function(requestId, fromRessource, ...)
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

RegisterNetEvent("jo_libs:triggerCallback", function(name, requestId, fromRessource, ...)
  TriggerServerEvent("jo_libs:responseCallback", requestId, fromRessource, executeCallback(name, ...))
end)

exports("getCallbackAPI", function()
  return jo.callback
end)
