jo.require("callback")

--- Calls the server filters from the client side
---@param name string (The name of the filter)
---@param value any (The value to filter)
---@param ...? any (Additional arguments which are passed on the functions hooked.)
function jo.hook.applyServerFilters(name, value, ...)
  if jo.debug then
    bprint("Server filter fired: %s", name)
  end
  return jo.callback.triggerServer(jo.resourceName .. "hook:callFilter", name, value, ...)
end
