local serverCallbacks = {}

---@param name string the name of the event
---@param cb function
function jo.registerServerCallback(name, cb)
  serverCallbacks[name] = {
    cb = cb,
    resource = GetCurrentResourceName()
  }
end

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