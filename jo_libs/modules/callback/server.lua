local serverCallbacks = {}
local clientCallbacks = {}
local currentRequestId = 0

jo.callback = {}

---@param name string the name of the event
---@param cb function
function jo.callback.register(name, cb)
  serverCallbacks[name] = {
    cb = cb,
    resource = GetCurrentResourceName()
  }
end

--deprecated function
jo.registerServerCallback = jo.callback.register

local function FireServerCallback(name, source, cb, ...)
  cb(serverCallbacks[name].cb(source, ...))
end

RegisterServerEvent('jo_libs:triggerServerCallback', function(name, requestId,fromRessource, ...)
  local source = source
  if not serverCallbacks[name] then return end

  FireServerCallback(name, source, function(...)
    TriggerClientEvent('jo_libs:serverCallback', source, requestId,fromRessource, ...)
  end, ...)
end)

---@param name string Name of the callback event
---@param cb function return of the event
---@param ...? any
function jo.callback.triggerClient(name,source,cb, ...)
  local fromRessource = GetCurrentResourceName() or "unknown"
  if not GetPlayerIdentifier(source) then
    return eprint('Callback Module: Player is not connected - source: '..source)
  end
  clientCallbacks[currentRequestId] = cb

  TriggerClientEvent('jo_libs:triggerClientCallback', source, name, currentRequestId,fromRessource, ...)
  currentRequestId = currentRequestId < 65535 and currentRequestId + 1 or 0
end

RegisterNetEvent('jo_libs:clientCallback', function(requestId,fromRessource, ...)
  if fromRessource ~= GetCurrentResourceName() then return end
  if clientCallbacks[requestId] then
    clientCallbacks[requestId](...)
    clientCallbacks[requestId] = nil
  else
    print('[^1ERROR^7] Server Callback with requestId ^5'.. requestId ..'^7 Was Called by ^5'.. fromRessource .. '^7 but does not exist.')
  end
end)

return jo.callback