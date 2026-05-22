jo.createModule("minigame")

local NativeSendNUIMessage = SendNUIMessage
local nuiLoaded = false

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
