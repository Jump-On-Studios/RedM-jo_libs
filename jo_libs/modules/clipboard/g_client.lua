jo.createModule("clipboard")

jo.require("nui")

local nuiLoaded = false

CreateThread(function()
    Wait(1000)
    local uiPage = GetResourceMetadata(GetCurrentResourceName(), "ui_page")
    if uiPage == "nui://jo_libs/nui/clipboard/index.html" then
        return
    end
    jo.nui.load("jo_clipboard", "nui://jo_libs/nui/clipboard/index.html")
    Wait(500)
    nuiLoaded = true
end)


exports("clipboard_copy", function(value)
    while not nuiLoaded do
        Wait(0)
    end
    SendNUIMessage({
        messageTargetUiName = "jo_clipboard",
        type = "copy",
        value = value

    })

    return true
end)
