if not _VERSION:find('5.4') then
  error('^1Lua 5.4 must be enabled in the resource manifest!^0', 2)
end

local resourceName = GetCurrentResourceName()
local jo_libs = 'jo_libs'

local alias = {
  framework = "framework-bridge",
  versionChecker = "version-checker",
  notif = "notification",
  pedTexture = 'ped-texture'
}


if jo and jo.name == jo_libs then
  error(("jo_libs is already loaded.\n\tRemove any duplicate entries from '@%s/fxmanifest.lua'"):format(resourceName))
end

function GetHashFromString(value)
  if type(value) == "string" then
    return joaat(value)
  end
  return value
end

function UnJson(value)
  if not value then return {} end
  if value == "null" then return {} end
  if type(value) == "string" then
    return json.decode(value)
  end
  return value
end

function IsModuleLoaded(name)
  return rawget(jo,name)
end

local LoadResourceFile = LoadResourceFile
local context = IsDuplicityVersion() and 'server' or 'client'

local function loadModule(self,module)
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

    local result = fn()
    self[module] = result or noFunction
    return self[module]
  end
end

function noFunction() end

local function call(self,index,...)
  if not index then return noFunction end
  if type(index) ~= "string" then return noFunction() end
  if alias[index] then index = alias[index] end

  local module = rawget(self,index)

  if not module then
    self[index] = noFunction
    module = loadModule(self,index)
  end

  return module
end

local jo = setmetatable ({
  libLoaded = false,
  name = jo_libs,
  context = context,
  cache = {}
}, {
  __index = call,
  __call = noFunction
})

function jo.waitLibLoading()
  while not jo.libLoaded do
    Wait(0)
  end
end
_ENV.jo = jo


if GetResourceState(jo_libs) ~= 'started' and resourceName ~= 'jo_libs' then
  error('^1jo_libs must be started before this resource.^0', 0)
end

-------------
-- DEFAULT MODULES
-------------
loadModule(jo,'print')
loadModule(jo,'file')

function jo.require(name)
  if IsModuleLoaded(name) then return end
  local module = loadModule(jo,name)
  if type(module) == 'function' then pcall(module) end
end

-------------
-- EXPORTS (prevent call before initializes)
-------------
local function CreateExport(name,cb)
  exports(name, function(...)
    jo.waitLibLoading()
    return cb(...)
  end)
end

for i = 1, GetNumResourceMetadata(resourceName, 'jo_lib') do
  local name = GetResourceMetadata(resourceName, 'jo_lib', i - 1)
  if name == "hook" then
    CreateExport('registerAction',jo.hook.registerAction)
    CreateExport('RegisterAction',jo.hook.RegisterAction)
    CreateExport('registerFilter',jo.hook.registerFilter)
    CreateExport('RegisterFilter',jo.hook.RegisterFilter)
  elseif name == "version-checker" and context == "server" then
    CreateExport('GetScriptVersion', jo.versionChecker.GetScriptVersion)
    CreateExport('StopAddon', jo.versionChecker.stopAddon)
  end
end

-------------
-- LOAD REQUIRED MODULES
-------------

for i = 1, GetNumResourceMetadata(resourceName, 'jo_lib') do
  local name = GetResourceMetadata(resourceName, 'jo_lib', i - 1)
  jo.require(name)
end
jo.libLoaded = true

local function onReady(cb)
	while GetResourceState('jo_libs') ~= 'started' or not jo.libLoaded do Wait(50) end

	return cb and cb() or true
end

jo.ready = setmetatable({}, {
	__call = function(_, cb)
		Citizen.CreateThreadNow(function() onReady(cb) end)
	end,
})