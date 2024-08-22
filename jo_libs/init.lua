if not _VERSION:find('5.4') then
  error('^1Lua 5.4 must be enabled in the resource manifest!^0', 2)
end

local resourceName = GetCurrentResourceName()
local jo_libs = 'jo_libs'
local modules = {'table','print','file'}

local alias = {
  framework = "framework-bridge",
  versionChecker = "version-checker",
  notif = "notification",
  pedTexture = 'ped-texture'
}
local function getAlias(module)
  for alias,name in pairs (alias) do
    if name == module then
      return alias
    end
  end
  return module
end

--list modules required
for i = 1, GetNumResourceMetadata(resourceName, 'jo_lib') do
  modules[#modules+1] = getAlias(GetResourceMetadata(resourceName, 'jo_lib', i - 1))
end



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
  local isLoaded = rawget(jo,name) and true or false
  return isLoaded
end

local function noFunction() end

local LoadResourceFile = LoadResourceFile
local context = IsDuplicityVersion() and 'server' or 'client'

local function doesScopedFilesRequired(name)
  if name == "table" then return true end
  return resourceName ~= "jo_libs" or table.find(modules,function(_name) return _name == name end)
end

local function loadModule(self,module)
  local folder = alias[module] or module
  local dir = ('modules/%s'):format(folder)
  local file = ""

  --load files in the right order
  for _,fileName in ipairs ({'shared','context'}) do
    --convert the name if it's context
    fileName = fileName == "context" and context or fileName
    --load scoped files
    if doesScopedFilesRequired(module) then
      local tempFile = LoadResourceFile(jo_libs, ('%s/%s.lua'):format(dir, fileName))
      if tempFile then
        file = file .. tempFile
      end
    end
    --load global files inside jo_libs
    if resourceName == "jo_libs" then
      fileName = "g_"..fileName
      local tempFile = LoadResourceFile(jo_libs, ('%s/%s.lua'):format(dir, fileName))
      if tempFile then
        file = file .. tempFile
      end
    end
  end

  if file then
    local fn, err = load(file, ('@@jo_libs/%s/%s.lua'):format(dir, context))

    if not fn or err then
      return error(('\n^1Error importing module (%s): %s^0'):format(dir, err), 3)
    end

    local result = fn()
    self[module] = self[module] or result or noFunction
  else
    self[module] = noFunction
  end

  return self[module]
end

local function call(self,index,...)
  if not index then return noFunction end
  if type(index) ~= "string" then return noFunction() end
  index = getAlias(index)

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

function jo.require(name)
  name = getAlias(name)
  if IsModuleLoaded(name) then return end
  local module = loadModule(jo,name)
  if type(module) == 'function' then pcall(module) end
end
jo.require('table')
jo.require('print')
jo.require('file')

if resourceName == "jo_libs" then
  AddEventHandler('jo_libs:loadGlobalModule', function (module)
    jo.require(module)
  end)
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

for _,name in ipairs (modules) do
  if name == "hook" then
    CreateExport('registerAction',jo.hook.registerAction)
    CreateExport('RegisterAction',jo.hook.RegisterAction)
    CreateExport('registerFilter',jo.hook.registerFilter)
    CreateExport('RegisterFilter',jo.hook.RegisterFilter)
  elseif name == "versionChecker" and context == "server" then
    CreateExport('GetScriptVersion', jo.versionChecker.GetScriptVersion)
    CreateExport('StopAddon', jo.versionChecker.stopAddon)
  end
end

-------------
-- LOAD REQUIRED MODULES
-------------

for _,name in ipairs (modules) do
  jo.require(name)
end
jo.libLoaded = true

local function onReady(cb)
	while GetResourceState('jo_libs') ~= 'started' or not jo.libLoaded do Wait(50) end

	return cb and cb() or true
end

function jo.ready(cb)
	Citizen.CreateThreadNow(function() onReady(cb) end)
end