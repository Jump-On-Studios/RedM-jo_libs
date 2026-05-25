jo.createModule("minigame")
jo.require("nui")

-- * ====================================
-- * VARIABLES
-- * ====================================

local NativeSendNUIMessage = SendNUIMessage
local nuiLoaded = false
local currentGamePromise = nil
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
    },
    qte = {
        count = 4,                          -- Number of QTE rounds to complete
        keys = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z" }, -- Allowed keys
        targetStart = { min = 100, max = 300 }, -- Target segment start angle range
        targetSize = { min = 50, max = 60 },    -- Target segment size angle range
        duration = { min = 2000, max = 3000 },  -- Full circle duration range in milliseconds
        introDelay = 300,                       -- Delay in milliseconds before the indicator starts after the intro animation
        successDelay = 450,                     -- Delay in milliseconds before continuing after a successful round
        failureDelay = 550,                     -- Delay in milliseconds before closing after a failed round
        roundDelay = 100,                       -- Delay in milliseconds between a successful round and the next intro
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

-- Opens a minigame NUI with its merged config and waits for the final result.
local function startMinigame(game, config)
    if currentGamePromise then
        return false, eprint("A minigame is already running")
    end

    local gamePromise = promise.new()
    currentGamePromise = gamePromise
    currentGame = game
    previousFocus = IsNuiFocused()
    previousKeepInput = IsNuiFocusKeepingInput()

    SetCursorLocation(0.5, 0.3)
    SendNUIMessage({
        type = "jo_minigame:show",
        data = {
            game = game,
            config = mergeConfig(game, config)
        }
    })

    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    if jo.nui.isLoaded("jo_minigame") then
        jo.nui.forceFocus("jo_minigame")
    end

    return Await(gamePromise)
end

-- Closes the active minigame and resolves the waiting Lua call with the final result.
local function finishMinigame(success)
    if not currentGamePromise then return end

    local resultPromise = currentGamePromise
    currentGamePromise = nil
    currentGame = nil

    SendNUIMessage({
        type = "jo_minigame:hide"
    })

    resetFocus()
    resultPromise:resolve(success == true)
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
---@return boolean success `true` on success, `false` on failure or if another minigame is already running.
function jo.minigame.lockpick(config)
    return startMinigame("lockpick", config)
end

-- * ====================================
-- * QTE MINIGAME
-- * ====================================

--- Starts the QTE minigame.
---@param config? table (The QTE configuration)
--- config.count? integer      (Number of QTE rounds to complete; default: 4)
--- config.keys? string[]      (Allowed keys; default: A-Z)
--- config.targetStart? table  (Target segment start angle range in degrees)
---     config.targetStart.min? number (Minimum target start angle; default: 100)
---     config.targetStart.max? number (Maximum target start angle; default: 300)
--- config.targetSize? table   (Target segment size angle range in degrees)
---     config.targetSize.min? number (Minimum target size; default: 50)
---     config.targetSize.max? number (Maximum target size; default: 60)
--- config.duration? table     (Full circle duration range in milliseconds)
---     config.duration.min? integer (Minimum duration; default: 2000)
---     config.duration.max? integer (Maximum duration; default: 3000)
--- config.introDelay? integer   (Delay in milliseconds before the indicator starts after the intro animation; default: 300)
--- config.successDelay? integer (Delay in milliseconds before continuing after a successful round; default: 450)
--- config.failureDelay? integer (Delay in milliseconds before closing after a failed round; default: 550)
--- config.roundDelay? integer   (Delay in milliseconds between a successful round and the next intro; default: 100)
---@return boolean success `true` on success, `false` on failure or if another minigame is already running.
function jo.minigame.qte(config)
    return startMinigame("qte", config)
end

-- * ====================================
-- * NUI CALLBACKS
-- * ====================================

-- Receives the result sent by the active minigame NUI.
-- It closes the UI, restores the previous focus state and resolves the waiting Lua call.
RegisterNUICallback("jo_minigame:finished", function(data, cb)
    cb("ok")

    if not currentGamePromise then return end
    if data and data.game and data.game ~= currentGame then
        eprint(("Received minigame result for %s while %s is running"):format(data.game, currentGame))
        return finishMinigame(false)
    end

    finishMinigame(data and data.success == true)
end)
