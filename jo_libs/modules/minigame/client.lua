jo.createModule("minigame")
jo.require("nui")

-- * ====================================
-- * VARIABLES
-- * ====================================

local NativeSendNUIMessage = SendNUIMessage
local nuiLoaded = false
local currentGameCallback = nil
local currentGame = nil
local previousFocus = false
local previousKeepInput = false

-- * ====================================
-- * NUI LOADING
-- * ====================================

CreateThread(function()
    Wait(100)
    if GetResourceMetadata(GetCurrentResourceName(), "ui_page") ~= "nui://jo_libs/nui/minigame/index.html" then
        jo.nui.load("jo_minigame", "nui://jo_libs/nui/minigame/index.html")
        Wait(1000)
    end
    nuiLoaded = true
end)

-- * ====================================
-- * DEFAULT CONFIG
-- * ====================================

local defaultConfig = {
    lockpick = {
        pins = 1,                -- Number of lockpicks available before failure
        pinHealth = 100,         -- Health of each lockpick
        pinDamage = 20,          -- Damage applied when forcing the lock at a wrong angle
        pinDamageInterval = 150, -- Minimum delay in milliseconds between two damage ticks
        solvePadding = 4,        -- Angle tolerance in degrees around the correct position
        maxDistFromSolve = 45,   -- Maximum angle distance used to calculate cylinder allowance
        cylRotSpeed = 3,         -- Cylinder rotation speed per tick while pushing
    }
}

-- * ====================================
-- * UTILS
-- * ====================================

-- Sends a message to the minigame NUI once it is loaded.
local function SendNUIMessage(data)
    while not nuiLoaded do
        Wait(100)
    end
    data.messageTargetUiName = "jo_minigame"
    NativeSendNUIMessage(data)
end

-- Restores the NUI focus state that was active before the minigame started.
local function resetFocus()
    SetNuiFocus(previousFocus, previousFocus)
    SetNuiFocusKeepInput(previousKeepInput)
    if jo.nui.isLoaded("jo_minigame") then
        jo.nui.resetFocus()
    end
end

-- Returns the effective config for a minigame by applying user values over defaults.
local function mergeConfig(game, config)
    local result = {}

    for key, value in pairs(defaultConfig[game] or {}) do
        result[key] = value
    end

    if type(config) == "table" then
        for key, value in pairs(config) do
            result[key] = value
        end
    end

    return result
end

-- * ====================================
-- * LOCKPICK MINIGAME
-- * ====================================

--- Starts the lockpick minigame.
---@param config? table (The lockpick configuration)
--- config.pins? integer             (Number of lockpicks available before failure; default: 1)
--- config.pinHealth? integer        (Health of each lockpick; default: 100)
--- config.pinDamage? integer        (Damage applied when forcing the lock at a wrong angle; default: 20)
--- config.pinDamageInterval? integer (Minimum delay in milliseconds between two damage ticks; default: 150)
--- config.solvePadding? number      (Angle tolerance in degrees around the correct position; default: 4)
--- config.maxDistFromSolve? number  (Maximum angle distance used to calculate cylinder allowance; default: 45)
--- config.cylRotSpeed? number       (Cylinder rotation speed per tick while pushing; default: 3)
---@param callback? function (Function called with the minigame result: `true` on success, `false` on failure. Can be passed as the first argument if no config is needed)
---@return boolean started `true` if the minigame was started.
function jo.minigame.lockpick(config, callback)
    if type(config) == "function" then
        callback = config
        config = nil
    end

    if currentGameCallback then
        return false, eprint("A minigame is already running")
    end

    currentGameCallback = callback or function() end
    currentGame = "lockpick"
    previousFocus = IsNuiFocused()
    previousKeepInput = IsNuiFocusKeepingInput()

    SetCursorLocation(0.5, 0.3)
    SendNUIMessage({
        type = "jo_minigame:show",
        data = {
            game = "lockpick",
            config = mergeConfig("lockpick", config)
        }
    })

    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    if jo.nui.isLoaded("jo_minigame") then
        jo.nui.forceFocus("jo_minigame")
    end

    return true
end

-- * ====================================
-- * NUI CALLBACKS
-- * ====================================

-- Receives the result sent by the active minigame NUI.
-- It closes the UI, restores the previous focus state and forwards the success boolean to the Lua callback.
RegisterNUICallback("jo_minigame:finished", function(data, cb)
    cb("ok")

    if not currentGameCallback then return end
    if data and data.game and data.game ~= currentGame then
        return eprint(("Received minigame result for %s while %s is running"):format(data.game, currentGame))
    end

    local callback = currentGameCallback
    currentGameCallback = nil
    currentGame = nil

    SendNUIMessage({
        type = "jo_minigame:hide"
    })

    resetFocus()
    callback(data and data.success == true)
end)
