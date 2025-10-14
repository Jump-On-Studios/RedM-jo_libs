jo.require("emit", true)

RegisterServerEvent("jo_libs:server:emit:dispatch", function(eventName, src, ...)
    jo.emit.triggerClient(eventName, src, ...)
end)
