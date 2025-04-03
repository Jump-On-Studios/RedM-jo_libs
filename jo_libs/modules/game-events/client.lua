jo.gameEvents = {}

jo.gameEvents.eventListened = {}

--- Register a listener for a specific game event
---@param eventName string (The name of the event to listen for, or "all" to listen for all events)
---@param callback function (The function that will be called when the event is triggered)
function jo.gameEvents.listen(eventName, callback)
    TriggerEvent("jo_libs:gameEvents:register", eventName)
    AddEventHandler("jo_libs:gameEvents:" .. eventName, callback)
end
