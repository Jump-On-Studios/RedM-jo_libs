jo.gameEvents = {}

jo.gameEvents.eventListened = {}

function jo.gameEvents.listen(eventName, callback)
    TriggerEvent('jo_libs:gameEvents:register', eventName)
    AddEventHandler('jo_libs:gameEvents:' .. eventName, callback)
end
