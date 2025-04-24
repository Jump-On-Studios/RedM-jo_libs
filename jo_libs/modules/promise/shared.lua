jo.promise = {}

--- Creates a new Promise that wraps a callback function
--- This utility transforms callback-style functions into Promise-returning functions
---@param cb function (The callback function to be wrapped in a Promise)
---@param ... mixed (Arguments to pass to the callback function)
---@return ... (The resolved values from the Promise)
function jo.promise.new(cb, ...)
  local waiter = promise.new()
  local resolver = function(...)
    waiter:resolve(table.pack(...))
  end
  local args = table.pack(...)
  local isAdded = false
  for index, arg in pairs(args) do
    if arg == "promiseReturnFunction" then
      isAdded = true
      args[index] = resolver
      break
    end
  end
  if not isAdded then
    args[#args + 1] = resolver
  end
  cb(table.unpack(args))
  return table.unpack(Citizen.Await(waiter))
end
