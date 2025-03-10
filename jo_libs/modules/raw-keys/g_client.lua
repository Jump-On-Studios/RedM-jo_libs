
jo.file.load("raw-keys.vk_qwerty")
jo.file.load("raw-keys.vk_azerty")

local listenedKeys = {}
local linkedResources = {}

local keyboard_layout = GetConvar('jo_libs:keyboard_layout','qwerty')
keyboard_layout = string.lower(keyboard_layout)

-- Listen if other scripts ask to register a new key to listen and add it to listenedKeys (multiple scripts can ask for the same key, so we increment a counter)
AddEventHandler("jo_libs:rawKeys:register", function(key)
    if not linkedResources[key] then
        linkedResources[key] = {}
    end
    local resource = GetInvokingResource()
    linkedResources[key][resource] = true

    for i = 1, #listenedKeys do
        if listenedKeys[i] == key then
            return
        end
    end

    table.insert(listenedKeys, key)
end)



local function removeScriptKeys(resource, key)
    if not linkedResources[key][resource] then return end
    linkedResources[key][resource] = nil

    for _, _ in pairs(linkedResources[key]) do
        return
    end

    linkedResources[key] = nil

    for i = 1, #listenedKeys do
        if listenedKeys[i] == key then
            table.remove(listenedKeys, i)
            return
        end
    end
end

AddEventHandler("jo_libs:rawKeys:remove", function(key)
    if not linkedResources[key] then return end
    local resource = GetInvokingResource()
    removeScriptKeys(resource, key)
end)

local function getVKValue(key)
    return  _G["vk_"..keyboard_layout]?[key] or vk_qwerty[key]
end


-- Listen for key pressed and fire an event if the pressed key is part of the listenedKeys table, true when pressed and false when release, which is then passed to the callback of jo_libs:rawKeys:XXX
CreateThread(function()
    while true do
        local length = #listenedKeys

        if (length == 0) then
            Wait(100)
        else
            for i = 1, length do
                local vk_key = listenedKeys[i]
                if IsRawKeyPressed(getVKValue(vk_key)) then
                    TriggerEvent("jo_libs:rawKeys:" .. vk_key, true)
                end
                if IsRawKeyReleased(getVKValue(vk_key)) then
                    TriggerEvent("jo_libs:rawKeys:" .. vk_key, false)
                end
            end
        end

        Wait(0)
    end
end)


AddConvarChangeListener("jo_libs:keyboard_layout",function()
    keyboard_layout = GetConvar('jo_libs:keyboard_layout','qwerty')
    keyboard_layout = string.lower(keyboard_layout)
    print(keyboard_layout)
end)

AddEventHandler("onResourceStop", function(resource)
    for key in pairs(linkedResources) do
        removeScriptKeys(resource, key)
    end
end)

-- debug
-- CreateThread(function()
--     while true do
--         for key,value in pairs(vk_qwerty) do
--             if IsRawKeyPressed(value) then print(key,value) end
--         end
--         Wait(0)
--     end
-- end)