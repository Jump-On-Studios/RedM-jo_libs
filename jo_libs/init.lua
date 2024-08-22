if not _VERSION:find('5.4') then
  error('^1Lua 5.4 must be enabled in the resource manifest!^0', 2)
end

local resourceName = GetCurrentResourceName()
local jo_libs = 'jo_libs'
local modules = {'table','print','file'}
local function noFunction() end
local LoadResourceFile = LoadResourceFile
local context = IsDuplicityVersion() and 'server' or 'client'

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
  local isLoaded = (rawget(jo,name) or jo.moduleInLoading[name]) and true or false
  return isLoaded
end

local function doesScopedFilesRequired(name)
  if name == "table" then return true end
  return resourceName ~= "jo_libs" or table.find(modules,function(_name) return _name == name end)
end

local function loadModule(self,module,needScoped)
  if needScoped == nil then needScoped = true end
  local folder = alias[module] or module
  local dir = ('modules/%s'):format(folder)
  local file = ""

  jo.moduleInLoading[module] = true

  if resourceName ~= "jo_libs" then
    exports.jo_libs:loadGlobalModule(module)
  end

  --load files in the right order
  for _,fileName in ipairs ({'shared','context'}) do
    --convert the name if it's context
    fileName = fileName == "context" and context or fileName
    --load scoped files
    if needScoped or doesScopedFilesRequired(module) then
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
    self[module] = result or self[module] or noFunction()
  else
    self[module] = noFunction
  end

  jo.moduleInLoading[module] = nil

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
  cache = {},
  moduleInLoading = {}
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

function jo.require(name,needScoped)
  needScoped = needScoped and true
  name = getAlias(name)
  if IsModuleLoaded(name) then return end
  local module = loadModule(jo,name,needScoped)
  if type(module) == 'function' then pcall(module) end
end

if resourceName == "jo_libs" then
  exports('loadGlobalModule', function (module)
    jo.require(module,false)
    return true
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

--Sort module by priority
local priorityModules = {table=1,print=2,file=3,hook=4}
table.sort(modules, function(a,b)
  local prioA = priorityModules[a]
  local prioB = priorityModules[b]
  if prioA and prioB then
    return prioA < prioB
  end
  if prioA then return true end
  if prioB then return false end
  return a < b
end)
-------------
-- LOAD REQUIRED MODULES
-------------

for _,name in ipairs (modules) do
  jo.require(name)
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
jo.libLoaded = true

local function onReady(cb)
	jo.waitLibLoading()

	return cb and cb() or true
end

function jo.ready(cb)
	Citizen.CreateThreadNow(function() onReady(cb) end)
end