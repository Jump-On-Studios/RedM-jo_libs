if not _VERSION:find('5.4') then
  error('^1Lua 5.4 must be enabled in the resource manifest!^0', 2)
end

local resourceName = GetCurrentResourceName()
local jo_libs = 'jo_libs'

if GetResourceState(jo_libs) ~= 'started' and resourceName ~= 'jo_libs' then
  error('^1jo_libs must be started before this resource.^0', 0)
end


local LoadResourceFile = LoadResourceFile
local context = IsDuplicityVersion() and 'server' or 'client'

local function loadModule(module)
  local dir = ('modules/%s'):format(module)
  local file = LoadResourceFile(jo_libs, ('%s/%s.lua'):format(dir, context))
  local sharedFile = LoadResourceFile(jo_libs, ('%s/shared.lua'):format(dir))

  if sharedFile then
    file = (file and ('%s\n%s'):format(sharedFile, file)) or sharedFile
  end

  if file then
    local fn, err = load(file, ('@@jo_libs/modules/%s/%s.lua'):format(module, context))

    if not fn or err then
      return error(('\n^1Error importing module (%s): %s^0'):format(dir, err), 3)
    end

    return fn()
  end
end

local jo = {}
_ENV.jo = jo

-------------
-- default module
-------------
loadModule('print')
loadModule('require')

for i = 1, GetNumResourceMetadata(resourceName, 'jo_lib') do
  local name = GetResourceMetadata(resourceName, 'jo_lib', i - 1)

  local module = loadModule(name)
  if type(module) == 'function' then pcall(module) end
end
