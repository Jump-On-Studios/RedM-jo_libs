jo.createModule("rawKeys")
jo.file.load("raw-keys.vk_qwerty")
jo.file.load("raw-keys.vk_azerty")

local events = {}

local keyboard_layout = GetConvar("jo_libs:keyboard_layout", "qwerty")
keyboard_layout = string.lower(keyboard_layout)

local reverseMap = {}
local function generateReverseMap()
    reverseMap = {}
    local list = vk_qwerty
    if keyboard_layout == "azerty" then
        list = table.merge(vk_qwerty, vk_azerty)
    end
    for key, vk in pairs(list) do
        reverseMap[vk] = key
    end
end
generateReverseMap()

AddConvarChangeListener("jo_libs:keyboard_layout", function()
    keyboard_layout = GetConvar("jo_libs:keyboard_layout", "qwerty")
    keyboard_layout = string.lower(keyboard_layout)
    generateReverseMap()
end)

local function keyDown(vk)
    local key = reverseMap[vk]
    for e = 1, #(events[key] or {}) do
        events[key][e](true)
    end
end

local function keyUp(vk)
    local key = reverseMap[vk]
    for e = 1, #(events[key] or {}) do
        events[key][e](false)
    end
end

for key, vk in pairs(vk_qwerty) do
    RegisterRawKeymap(jo.resourceName .. ":rawKeys:" .. key, function() keyDown(vk) end, function() keyUp(vk) end, vk, true)
end



--- Registers a listener for a specific key. When the key is pressed or released, the provided callback function is executed with a boolean value indicating the event state (true for pressed, false for released).
--- @param key string (The identifier of the key to listen for. This should correspond to one of the keys defined in the [keyboard mappings](#keyboard-keys-mapping) (e.g., "A", "B", "F1", etc.) or the numerical key code)
--- @param callback function (The function to be executed when the key event occurs. It receives one parameter: <br> _boolean_ — `true` when the key is pressed, `false` when it is released.)
function jo.rawKeys.listen(key, callback)
    events[key] = events[key] or {}
    table.insert(events[key], callback)
end

--- Removes the listener associated with the specified key. Use this function to stop listening for events on a key when it is no longer needed.
--- @param key string (The identifier of the key for which the listener should be removed.)
function jo.rawKeys.remove(key)
    if not events[key] then return end
    events[key] = nil
end
