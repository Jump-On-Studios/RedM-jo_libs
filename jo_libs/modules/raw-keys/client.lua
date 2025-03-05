jo.rawKeys = {}


-- Function to listen for a key press
function jo.rawKeys.listen(key, callback)
    TriggerEvent('jo_libs:rawKeys:register', key) -- Ask to register the key in the global listenedKeys variable
    AddEventHandler('jo_libs:rawKeys:' .. key, callback) -- Listen for the global script to send the event, when received we fire the callback
end
