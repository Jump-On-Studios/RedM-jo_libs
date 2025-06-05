jo.callback.register = setmetatable(
  { latent = jo.callback.registerLatentCallback },
  {
    __call = function(_, ...)
      jo.callback.registerCallback(...)
    end,
  }
)
