if IsDuplicityVersion() then --server side
  ServerCallbacks = {}

  function RegisterServerCallback(name, cb)
    ServerCallbacks[name] = {
      cb = cb,
      resource = GetCurrentResourceName()
    }
  end

  function FireServerCallback(name, source, cb, ...)
    cb(ServerCallbacks[name].cb(source, ...))
  end

  RegisterServerEvent('jo:triggerServerCallback', function(name, requestId,fromRessource, ...)
    local source = source
    if not ServerCallbacks[name] then return end

    FireServerCallback(name, source, function(...)
      TriggerClientEvent('jo:serverCallback', source, requestId,fromRessource, ...)
    end, ...)
  end)
else
  CurrentRequestId = 0
  ServerCallbacks = {}

  function TriggerServerCallback(name, cb, ...)
    local fromRessource = GetCurrentResourceName() or "unknown"
    ServerCallbacks[CurrentRequestId] = cb

    TriggerServerEvent('jo:triggerServerCallback', name, CurrentRequestId,fromRessource, ...)
    CurrentRequestId = CurrentRequestId < 65535 and CurrentRequestId + 1 or 0
  end

  RegisterNetEvent('jo:serverCallback', function(requestId,fromRessource, ...)
    if fromRessource ~= GetCurrentResourceName() then return end
    if ServerCallbacks[requestId] then
      ServerCallbacks[requestId](...)
      ServerCallbacks[requestId] = nil
    else
      print('[^1ERROR^7] Server Callback with requestId ^5'.. requestId ..'^7 Was Called by ^5'.. fromRessource .. '^7 but does not exist.')
    end
  end)
end