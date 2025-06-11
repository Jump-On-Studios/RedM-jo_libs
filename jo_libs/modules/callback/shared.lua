jo.require("emit")

if jo.resourceName ~= "jo_libs" then
  jo.callback = exports.jo_libs:getCallbackAPI()
end
