jo.rawKeys = {}

local events = {}

--- Registers a listener for a specific key. When the key is pressed or released, the provided callback function is executed with a boolean value indicating the event state (true for pressed, false for released).
--- @param key string (The identifier of the key to listen for. This should correspond to one of the keys defined in the [keyboard mappings](#keyboard-keys-mapping) (e.g., "A", "B", "F1", etc.).)
--- @param callback function (The function to be executed when the key event occurs. It receives one parameter: <br> _boolean_ — `true` when the key is pressed, `false` when it is released.)
function jo.rawKeys.listen(key, callback)
    TriggerEvent("jo_libs:rawKeys:register", key)
    events[key] = events[key] or {}
    local event = AddEventHandler("jo_libs:rawKeys:" .. key, callback)
    table.insert(events[key], event)
end

--- Removes the listener associated with the specified key. Use this function to stop listening for events on a key when it is no longer needed.
--- @param key string (The identifier of the key for which the listener should be removed.)
function jo.rawKeys.remove(key)
    if not events[key] then return end
    TriggerEvent("jo_libs:rawKeys:remove", key)
    for i = 1, #events[key] do
        RemoveEventHandler(events[key][i])
    end
    events[key] = nil
end
