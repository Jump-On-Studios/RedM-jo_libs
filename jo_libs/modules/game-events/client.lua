jo.gameEvents = {}

jo.gameEvents.eventListened = {}

function jo.gameEvents.listen(eventName, endCb)
    TriggerEvent('jo_libs:gameEvents:register', eventName)
    AddEventHandler('jo_libs:gameEvents:' .. eventName, endCb)
end

return jo.gameEvents
