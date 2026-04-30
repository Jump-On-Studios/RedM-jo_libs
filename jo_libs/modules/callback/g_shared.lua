function generateEventName(action, requestId)
    return "jo_callback:" .. action .. ":" .. requestId
end

function jo.callback.trigger(name, cb, latent)
    local func = jo.isClientSide() and jo.callback.triggerClient or jo.callback.triggerServer
    func(name, cb, latent)
end
