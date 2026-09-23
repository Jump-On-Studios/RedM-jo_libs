jo.createModule("rawKeys")
jo.file.load("raw-keys.vk_qwerty")
jo.file.load("raw-keys.vk_azerty")

local nextListenerId = 1

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
    ["."] = "oem_period",
    ["/"] = "oem_2",
    ["`"] = "oem_3",
    ["["] = "oem_4",
    ["\\"] = "oem_5",
    ["]"] = "oem_6",
    ["'"] = "oem_7",
}
local reverseAlias = {}
for alias, key in pairs(alias) do reverseAlias[key] = alias end

local events = {}
local anyKeyListeners = {}

local keyboard_layout = GetConvar("jo_libs:keyboard_layout", "qwerty")
keyboard_layout = string.lower(keyboard_layout)

local reverseMap = {}
local reverseMapQwerty = {}

--- When several names share the same vk, prefer readable names over `oem_*` ones, then the alphabetical order.
--- Keeps the result independent from the `pairs()` iteration order.
local function isBetterName(candidate, current)
    if not current then return true end
    local candidateIsOem = candidate:sub(1, 4) == "oem_"
    local currentIsOem = current:sub(1, 4) == "oem_"
    if candidateIsOem ~= currentIsOem then return not candidateIsOem end
    return candidate < current
end

local function addNames(map, list)
    for key, vk in pairs(list) do
        key = key:lower()
        if isBetterName(key, map[vk]) then
            map[vk] = key
        end
    end
end

addNames(reverseMapQwerty, vk_qwerty)

local function generateReverseMap()
    reverseMap = {}
    local list = table.clone(vk_qwerty)
    if keyboard_layout == "azerty" then
        table.merge(list, vk_azerty)
    end
    addNames(reverseMap, list)

    if keyboard_layout == "azerty" then
        -- the layout names always win for the vk they redefine
        local azertyMap = {}
        addNames(azertyMap, vk_azerty)
        for vk, key in pairs(azertyMap) do
            reverseMap[vk] = key
        end
    end
end
generateReverseMap()

AddConvarChangeListener("jo_libs:keyboard_layout", function()
    keyboard_layout = GetConvar("jo_libs:keyboard_layout", "qwerty")
    keyboard_layout = string.lower(keyboard_layout)
    generateReverseMap()
end)

local function dispatch(vk, isPressed)
    local key = reverseMap[vk]
    if not key then return end
    local listeners = events[alias[key] or key]
    for e = 1, #(listeners or {}) do
        listeners[e].callback(isPressed, key, vk)
    end
    for l = 1, #anyKeyListeners do
        anyKeyListeners[l].callback(isPressed, key, vk)
    end
end

local function keyDown(vk)
    dispatch(vk, true)
end

local function keyUp(vk)
    dispatch(vk, false)
end

-- one keymap per vk: some names share the same vk (e.g. KANA/HANGUL) and would fire twice
for vk, key in pairs(reverseMapQwerty) do
    RegisterRawKeymap(jo.resourceName .. ":rawKeys:" .. key, function() keyDown(vk) end, function() keyUp(vk) end, vk, true)
end

--- Registers a listener for a specific key. When the key is pressed or released, the provided callback function is executed with a boolean value indicating the event state (true for pressed, false for released).
--- @param key string (The identifier of the key to listen for. This should correspond to one of the keys defined in the [keyboard mappings](#keyboard-keys-mapping) (e.g., "A", "B", "F1", etc.) or the numerical key code)
--- @param callback function (The function fired when the key state changes. Arguments: `isPressed` boolean, resolved `key` string, raw `vk` number.)
--- @return integer (The unique identifier for the listener, which can be used to remove it later.)
function jo.rawKeys.listen(key, callback)
    nextListenerId += 1
    local id = nextListenerId
    if type(key) == "number" then
        key = reverseMapQwerty[key]
        if not key then return eprint("invalid vk key code") end
    end
    key = key:lower()
    if alias[key] then
        key = alias[key]
    end
    events[key] = events[key] or {}
    table.insert(events[key], { id = id, callback = callback })
    return id
end

--- Registers a listener fired for every key. The callback receives the key resolved with the current keyboard layout.
--- @param callback function (The function fired when any key state changes. Arguments: `isPressed` boolean, resolved `key` string, raw `vk` number.)
--- @return integer (The unique identifier for the listener, which can be used to remove it later.)
function jo.rawKeys.listenAll(callback)
    nextListenerId += 1
    local id = nextListenerId
    table.insert(anyKeyListeners, { id = id, callback = callback })
    return id
end

--- Removes all listeners associated with the specified key. Use this function to stop listening for events on a key when it is no longer needed.
---@deprecated since v2.9.0. Use jo.rawKeys.removeListener instead
--- @param key string (The identifier of the key for which the listener should be removed.)
function jo.rawKeys.remove(key)
    if type(key) == "number" then
        key = reverseMapQwerty[key]
        if not key then return eprint("invalid vk key code") end
    end
    key = key:lower()
    if alias[key] then key = alias[key] end
    if not events[key] then return end
    events[key] = nil
end

--- Removes the listener associated with the specified ID. Use this function to stop listening for events on a key when it is no longer needed.
---@param id string (The ID of the listener to remove.)
function jo.rawKeys.removeListener(id)
    if not id then return false end
    for l = 1, #anyKeyListeners do
        if anyKeyListeners[l].id == id then
            table.remove(anyKeyListeners, l)
            return true
        end
    end
    for _, listeners in pairs(events) do
        for l = 1, #listeners do
            if listeners[l].id == id then
                table.remove(listeners, l)
                return true
            end
        end
    end
    return false
end

function jo.rawKeys.getKeyFromVK(vk)
    local key = reverseMap[vk]
    return key
end

function jo.rawKeys.getAliasFromStandardKey(key)
    key = key:lower()
    return reverseAlias[key] or key
end

local vks
function jo.rawKeys.getAllVK()
    if vks then return vks end
    vks = {}
    local known = {}
    for _, vk in pairs(vk_qwerty) do
        if not known[vk] then
            known[vk] = true
            vks[#vks + 1] = vk
        end
    end
    return vks
end
