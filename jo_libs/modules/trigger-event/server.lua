jo.triggerEvent = {}

--- Trigger an event on the server side
---@deprecated since v2.3.7. Use jo.emit.triggerServerWithSource instead
---@param source integer (The source player ID to send the event to)
---@param event string (The name of the event to trigger)
---@param ... any (Additional parameters to pass to the event)
function jo.triggerEvent.server(source, event, ...)
  TriggerClientEvent("jo_libs:trigger-event:client:receive", source, event, ...)
end
