jo.triggerEvent = {}

function jo.triggerEvent.server(source, event, ...)
  TriggerClientEvent("jo_libs:trigger-event:client:receive", source, event, ...)
end
