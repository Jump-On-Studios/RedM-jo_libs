jo.rawKeys = {}

local events = {};
-- Function to listen for a key press
function jo.rawKeys.listen(key, callback)
    TriggerEvent("jo_libs:rawKeys:register", key)
    events[key] = events[key] or {}
    local event = AddEventHandler("jo_libs:rawKeys:" .. key, callback)
    table.insert(events[key], event)
end

function jo.rawKeys.remove(key)
    if not events[key] then return end;
    TriggerEvent("jo_libs:rawKeys:remove", key)
    for i = 1, #events[key] do
        RemoveEventHandler(events[key][i])
    end
    events[key] = nil;
end
