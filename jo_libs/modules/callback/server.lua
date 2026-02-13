jo.createModule("callback")

jo.callback.register = setmetatable({},
  {
    __index = function(_, key)
      if key == "latent" then
        return jo.callback.registerLatentCallback
      end
      return jo.callback["register" .. key]
    end,
    __call = function(_, ...)
      jo.callback.registerCallback(...)
    end,
  }
)
