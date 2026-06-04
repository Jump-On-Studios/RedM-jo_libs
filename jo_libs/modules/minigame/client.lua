jo.createModule("minigame")
jo.require("table")
jo.require("nui")

-- * ====================================
-- * VARIABLES
-- * ====================================

local NativeSendNUIMessage = SendNUIMessage
local nuiLoaded = false
local currentGamePromise = nil
local currentGame = nil
local currentGameConfig = nil
local currentAnimPostFx = nil
local previousFocus = false
local previousKeepInput = false
local defaultAnimPostFx = "PauseMenuIn"

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
        pins = 1,                       -- Number of lockpicks available before failure
        pinHealth = 100,                -- Health of each lockpick
        pinDamage = 20,                 -- Damage applied when forcing the lock at a wrong angle
        pinDamageInterval = 150,        -- Minimum delay in milliseconds between two damage ticks
        solvePadding = 4,               -- Angle tolerance in degrees around the correct position
        maxDistFromSolve = 45,          -- Maximum angle distance used to calculate cylinder allowance
        cylRotSpeed = 3,                -- Cylinder rotation speed per tick while pushing
        animPostFx = defaultAnimPostFx, -- AnimPostFX effect to play while the minigame is open, or false to disable it
    },
    qte = {
        roundCount = 4,                                                                                                                                     -- Number of QTE rounds to complete
        allowedKeys = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z" }, -- Allowed keys
        rotationCount = 1,                                                                                                                                  -- Number of full indicator rotations allowed per round
        targetStartAngle = { min = 100, max = 300 },                                                                                                        -- Target segment start angle range
        targetArcSize = { min = 50, max = 60 },                                                                                                             -- Target segment size angle range
        rotationDuration = { min = 2000, max = 3000 },                                                                                                      -- Full rotation duration range in milliseconds
        introDelay = 200,                                                                                                                                   -- Delay in milliseconds before the indicator starts after the intro animation
        successDelay = 450,                                                                                                                                 -- Delay in milliseconds before continuing after a successful round
        failureDelay = 550,                                                                                                                                 -- Delay in milliseconds before closing after a failed round
        roundDelay = 100,                                                                                                                                   -- Delay in milliseconds between a successful round and the next intro
        animPostFx = defaultAnimPostFx,                                                                                                                     -- AnimPostFX effect to play while the minigame is open, or false to disable it
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
    config = type(config) == "table" and config or {}
    return table.merge(false, table.copy(defaultConfig[game] or {}), config)
end

-- Opens a minigame NUI with its merged config and waits for the final result.
local function startMinigame(game, config)
    if currentGamePromise then
        eprint("A minigame is already running")
        return "busy"
    end

    local gamePromise = promise.new()
    currentGamePromise = gamePromise
    currentGame = game
    previousFocus = IsNuiFocused()
    previousKeepInput = IsNuiFocusKeepingInput()
    local mergedConfig = mergeConfig(game, config)
    currentGameConfig = mergedConfig
    local nuiConfig = table.clearForNui(mergedConfig)

    SendNUIMessage({
        type = "jo_minigame:show",
        data = {
            game = game,
            config = nuiConfig
        }
    })

    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    if type(mergedConfig.animPostFx) == "string" and mergedConfig.animPostFx ~= "" then
        currentAnimPostFx = mergedConfig.animPostFx
        AnimpostfxPlay(currentAnimPostFx)
    end
    if jo.nui.isLoaded("jo_minigame") then
        jo.nui.forceFocus("jo_minigame")
    end

    return Await(gamePromise)
end

-- Closes the active minigame and resolves the waiting Lua call with the final result.
local function finishMinigame(status)
    if not currentGamePromise then return end

    local resultPromise = currentGamePromise
    local animPostFx = currentAnimPostFx
    currentGamePromise = nil
    currentGame = nil
    currentGameConfig = nil
    currentAnimPostFx = nil

    SendNUIMessage({
        type = "jo_minigame:hide"
    })

    resetFocus()
    if animPostFx then
        AnimpostfxStop(animPostFx)
    end
    resultPromise:resolve(status)
end

local function getResultStatus(data)
    local status = data and data.status
    if status == "success" or status == "failed" or status == "canceled" then
        return status
    end

    return "failed"
end

-- * ====================================
-- * PUBLIC API
-- * ====================================

--- Cancels the currently running minigame.
---@return boolean canceled `true` if a minigame was canceled, `false` if no minigame was running.
function jo.minigame.cancel()
    if not currentGamePromise then return false end

    finishMinigame("canceled")
    return true
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
--- config.onPinBroken? function     (Called each time a lockpick pin breaks)
--- config.animPostFx? string|false  (AnimPostFX effect to play while the minigame is open; default: "PauseMenuIn"; use false to disable)
---@return "success"|"failed"|"canceled"|"busy" status `"success"` on success, `"failed"` on failure, `"canceled"` on NUI cancel, `"busy"` if another minigame is already running.
function jo.minigame.lockpick(config)
    SetCursorLocation(0.5, 0.3)
    return startMinigame("lockpick", config)
end

-- * ====================================
-- * QTE MINIGAME
-- * ====================================

--- Starts the QTE minigame.
---@param config? table (The QTE configuration)
--- config.roundCount? integer      (Number of QTE rounds to complete; default: 4)
--- config.allowedKeys? string[]    (Allowed keys; default: A-Z)
--- config.rotationCount? integer   (Number of full indicator rotations allowed per round; default: 1)
--- config.targetStartAngle? table  (Target segment start angle range in degrees)
---     config.targetStartAngle.min? number (Minimum target start angle; default: 100)
---     config.targetStartAngle.max? number (Maximum target start angle; default: 300)
--- config.targetArcSize? table     (Target segment size angle range in degrees)
---     config.targetArcSize.min? number (Minimum target size; default: 50)
---     config.targetArcSize.max? number (Maximum target size; default: 60)
--- config.rotationDuration? table  (Full rotation duration range in milliseconds)
---     config.rotationDuration.min? integer (Minimum duration; default: 2000)
---     config.rotationDuration.max? integer (Maximum duration; default: 3000)
--- config.introDelay? integer   (Delay in milliseconds before the indicator starts after the intro animation; default: 200)
--- config.successDelay? integer (Delay in milliseconds before continuing after a successful round; default: 450)
--- config.failureDelay? integer (Delay in milliseconds before closing after a failed round; default: 550)
--- config.roundDelay? integer   (Delay in milliseconds between a successful round and the next intro; default: 100)
--- config.animPostFx? string|false (AnimPostFX effect to play while the minigame is open; default: "PauseMenuIn"; use false to disable)
---@return "success"|"failed"|"canceled"|"busy" status `"success"` on success, `"failed"` on failure, `"canceled"` on NUI cancel, `"busy"` if another minigame is already running.
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
        return finishMinigame("failed")
    end

    finishMinigame(getResultStatus(data))
end)

-- Receives a lockpick pin break event from the NUI and triggers the optional Lua callback.
RegisterNUICallback("jo_minigame:lockpick:pinBroken", function(_data, cb)
    cb("ok")

    if not currentGamePromise then return end
    if currentGame ~= "lockpick" then return end
    if type(currentGameConfig) ~= "table" then return end
    if type(currentGameConfig.onPinBroken) ~= "function" then return end

    local success, err = pcall(currentGameConfig.onPinBroken)
    if not success then
        eprint(("Error in lockpick onPinBroken callback: %s"):format(err))
    end
end)
