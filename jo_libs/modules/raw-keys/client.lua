jo.createModule("rawKeys")
jo.file.load("raw-keys.vk_qwerty")
jo.file.load("raw-keys.vk_azerty")

local alias = {
    backspace = "back",
    enter = "return",
    ctrl = "control",
    kanji = "hanja",
    esc = "escape",
    pageup = "prior",
    pagedown = "next",
    numpad_multiply = "multiply",
    numpad_add = "add",
    numpad_subtract = "subtract",
    numpad_decimal = "decimal",
    ["l shift"] = "lshift",
    ["r shift"] = "rshift",
    ["l ctrl"] = "lcontrol",
    ["r ctrl"] = "rcontrol",
    ["l alt"] = "lmenu",
    ["r alt"] = "rmenu",
    [";"] = "oem_1",
    ["+"] = "oem_plus",
    [","] = "oem_comma",
    ["-"] = "oem_minus",
    [";"] = "oem_period",
    ["/"] = "oem_2",
    ["`"] = "oem_3",
    ["["] = "oem_4",
    ["\\"] = "oem_5",
    ["]"] = "oem_6",
    ["'"] = "oem_7",
}

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
        reverseMap[vk] = key:lower()
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
    RegisterRawKeymap(jo.resourceName .. ":rawKeys:" .. key:lower(), function() keyDown(vk) end, function() keyUp(vk) end, vk, true)
end



--- Registers a listener for a specific key. When the key is pressed or released, the provided callback function is executed with a boolean value indicating the event state (true for pressed, false for released).
--- @param key string (The identifier of the key to listen for. This should correspond to one of the keys defined in the [keyboard mappings](#keyboard-keys-mapping) (e.g., "A", "B", "F1", etc.) or the numerical key code)
--- @param callback function (The function to be executed when the key event occurs. It receives one parameter: <br> _boolean_ — `true` when the key is pressed, `false` when it is released.)
function jo.rawKeys.listen(key, callback)
    if type(key) == "number" then
        key = reverseMap[key]
        if not key then return eprint("invalid vk key code") end
    end
    key = key:lower()
    if alias[key] then key = alias[key] end
    events[key] = events[key] or {}
    table.insert(events[key], callback)
end

--- Removes the listener associated with the specified key. Use this function to stop listening for events on a key when it is no longer needed.
--- @param key string (The identifier of the key for which the listener should be removed.)
function jo.rawKeys.remove(key)
    if type(key) == "number" then
        key = reverseMap[key]
        if not key then return eprint("invalid vk key code") end
    end
    key = key:lower()
    if alias[key] then key = alias[key] end
    if not events[key] then return end
    events[key] = nil
end
