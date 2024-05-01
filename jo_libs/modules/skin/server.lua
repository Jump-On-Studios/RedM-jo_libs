if not IsModuleLoaded('skin') then
  jo.skin = {}
end

if not IsModuleLoaded('framework') then
  jo.require('framework-bridge')
end

---@param source integer
---@return {} table skin
function jo.skin.getUserSkin(source)
  return jo.framework:getUserSkin(source)
end

return jo.skin