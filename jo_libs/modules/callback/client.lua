local currentRequestId = 0
local serverCallbacks = {}

---@param name string Name of the callback event
---@param cb function return of the event
---@param ...? any
function jo.triggerServerCallback(name, cb, ...)
  local fromRessource = GetCurrentResourceName() or "unknown"
  serverCallbacks[currentRequestId] = cb

  TriggerServerEvent('jo_libs:triggerServerCallback', name, currentRequestId,fromRessource, ...)
  currentRequestId = currentRequestId < 65535 and currentRequestId + 1 or 0
end

RegisterNetEvent('jo_libs:serverCallback', function(requestId,fromRessource, ...)
  if fromRessource ~= GetCurrentResourceName() then return end
  if serverCallbacks[requestId] then
    serverCallbacks[requestId](...)
    serverCallbacks[requestId] = nil
  else
    print('[^1ERROR^7] Server Callback with requestId ^5'.. requestId ..'^7 Was Called by ^5'.. fromRessource .. '^7 but does not exist.')
  end
end)