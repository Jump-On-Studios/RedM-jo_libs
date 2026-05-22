jo.createModule("minigame")
jo.require("nui")

local NativeSendNUIMessage = SendNUIMessage
local nuiLoaded = false
local currentGameCallback = nil
local currentGame = nil
local previousFocus = false
local previousKeepInput = false

local function SendNUIMessage(data)
    while not nuiLoaded do
        Wait(100)
    end
    data.messageTargetUiName = "jo_minigame"
    NativeSendNUIMessage(data)
end

CreateThread(function()
    Wait(100)
    if GetResourceMetadata(GetCurrentResourceName(), "ui_page") ~= "nui://jo_libs/nui/minigame/index.html" then
        jo.nui.load("jo_minigame", "nui://jo_libs/nui/minigame/index.html")
        Wait(1000)
    end
    nuiLoaded = true
end)

local function resetFocus()
    SetNuiFocus(previousFocus, previousFocus)
    SetNuiFocusKeepInput(previousKeepInput)
    if jo.nui.isLoaded("jo_minigame") then
        jo.nui.resetFocus()
    end
end

--- Start the lockpick minigame.
---@param config? table The lockpick config sent to the NUI.
---@param callback? function Function called with the minigame result (`true` on success, `false` on failure).
---@return boolean started `true` if the minigame was started.
function jo.minigame.lockpick(config, callback)
    if currentGameCallback then
        return false, eprint("A minigame is already running")
    end

    currentGameCallback = callback or function() end
    currentGame = "lockpick"
    previousFocus = IsNuiFocused()
    previousKeepInput = IsNuiFocusKeepingInput()

    SendNUIMessage({
        type = "jo_minigame:show",
        data = {
            game = "lockpick",
            config = config or {}
        }
    })

    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    if jo.nui.isLoaded("jo_minigame") then
        jo.nui.forceFocus("jo_minigame")
    end

    return true
end

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
