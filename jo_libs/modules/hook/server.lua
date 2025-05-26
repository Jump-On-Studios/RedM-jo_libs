jo.require("callback")

jo.callback.register(jo.resourceName .. "hook:callFilter", function(source, name, value, ...)
  return jo.hook.applyFilters(name, value, source, ...)
end)
