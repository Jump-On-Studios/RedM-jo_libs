if not _VERSION:find("5.4") then
  error("^1Lua 5.4 must be enabled in the resource manifest!^0", 2)
end

-------------
-- GLOBAL VARIABLES
-------------
CreateThreadNow = Citizen.CreateThreadNow
Await = Citizen.Await
InvokeNative = Citizen.InvokeNative
-------------
-- END GLOBAL VARIABLES
-------------

local resourceName = GetCurrentResourceName()
local jo_libs = "jo_libs"
local modules = { "table", "print", "file", "math", "trigger-event" }
local function noFunction() end
local LoadResourceFile = LoadResourceFile
local context = IsDuplicityVersion() and "server" or "client"
local moduleInLoading = {}
local moduleLoaded = {}
local globalModuleLoaded = {}

local alias = {
  framework = "framework-bridge",
  versionChecker = "version-checker",
  notif = "notification",
  pedTexture = "ped-texture",
  gameEvents = "game-events",
  triggerEvent = "trigger-event",
  promptNui = "prompt-nui"
}

local function getAlias(module)
  if module == "meCoords" or module == "mePlayerId" or module == "meServerId" then return "me" end
  if alias[module] then return module end
  for alia, name in pairs(alias) do
    if name == module then
      return alia
    end
  end
  return module
end

--list modules required
for i = 1, GetNumResourceMetadata(resourceName, "jo_lib") do
  modules[#modules + 1] = getAlias(GetResourceMetadata(resourceName, "jo_lib", i - 1))
end

if jo and jo.name == jo_libs then
  error(("jo_libs is already loaded.\n\tRemove any duplicate entries from '@%s/fxmanifest.lua'"):format(resourceName))
end

function GetHashFromString(value)
  if type(value) == "string" then
    local number = tonumber(value)
    if number then return math.toSigned(number) end
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

---Set a default value if the value is nil
---@param value any your value
---@param default any the default value
---@return any
function GetValue(value, default)
  if default == nil then
    return value
  end
  if default == false then
    return value or false
  end
  return value == nil and default or value
end

local function isModuleLoaded(name, needLocal)
  needLocal = GetValue(needLocal, true)
  if needLocal and not (moduleLoaded[name] == "local") then return false end
  if moduleInLoading[name] then return true end
  if moduleLoaded[name] then return true end
  return false
end

local function loadGlobalModule(module)
  if resourceName == "jo_libs" then return end
  while GetResourceState("jo_libs") ~= "started" do Wait(0) end
  exports.jo_libs:loadGlobalModule(module)
end

local function doesScopedFilesRequired(name)
  if name == "table" then return true end
  return resourceName ~= "jo_libs" or table.find(modules, function(_name) return _name == name end)
end

local function readAndLoadFile(path)
  local file = LoadResourceFile("jo_libs", path)
  if not file then
    return false
  end

  local fn, err = load(file, ("@@jo_libs/%s.lua"):format(path))

  if not fn or err then
    return false, error(("\n^1Error importing module (%s):\n^1%s^0"):format(path, err), 3)
  end

  local success, err = pcall(fn)

  if not success then
    return false, error(("\n^1Error importing module (%s):\n^1%s^0"):format(path, err), 3)
  end
  return success
end

local function addDebugListener(module)
  if jo.debugModules[module] ~= nil then return end
  local convarDebugName = resourceName .. ":debug:" .. module
  local globalDebugName = "all:debug:" .. module

  jo.debugModules[module] = (GetConvar(globalDebugName, "off") == "on") or (GetConvar(convarDebugName, "off") == "on")

  if jo.debugModules[module] then
    oprint(("/!\\ %s module '%s' is in debug mode /!\\"):format(resourceName, module))
    oprint("Don't use this in production!")
  end

  for _, name in ipairs({ convarDebugName, globalDebugName }) do
    AddConvarChangeListener(name, function()
      jo.debugModules[module] = GetConvar(name, "off") == "on"
      if jo.debugModules[module] then
        oprint(("/!\\ %s module '%s' is in debug mode /!\\"):format(resourceName, module))
        oprint("Don't use this in production!")
      else
        oprint(("/!\\ %s module '%s' debug mode turned OFF /!\\"):format(resourceName, module))
      end
    end)
  end
end

local function loadModule(name, needLocal)
  if needLocal == nil then needLocal = true end
  local folder = alias[name] or name
  local dir = ("modules/%s"):format(folder)

  moduleInLoading[folder] = true
  moduleInLoading[name] = true
  moduleLoaded[folder] = needLocal and "local" or "global"
  moduleLoaded[name] = needLocal and "local" or "global"


  loadGlobalModule(name)

  --load files in the right order
  for _, fileName in ipairs({ "shared", "context" }) do
    --convert the name if it's context
    fileName = fileName == "context" and context or fileName
    local link = ("%s/%s.lua"):format(dir, fileName)
    --load scoped files
    if needLocal or doesScopedFilesRequired(name) then
      readAndLoadFile(link)
    end
    --load global files inside jo_libs
    if resourceName == "jo_libs" then
      local globalLink = ("%s/%s.lua"):format(dir, "g_" .. fileName)
      if not globalModuleLoaded[globalLink] then
        globalModuleLoaded[globalLink] = true
        readAndLoadFile(globalLink)
      end
    end
  end

  moduleInLoading[name] = nil
  moduleInLoading[folder] = nil

  addDebugListener(folder)

  return true
end

local function call(_, name, ...)
  if not name then return noFunction end
  if type(name) ~= "string" then return noFunction() end
  name = getAlias(name)

  local module = rawget(jo, name)

  if not module then
    loadModule(name)
  end

  while moduleInLoading[name] do Wait(0) end

  return rawget(jo, name)
end

local jo = setmetatable({
  libLoaded = false,
  debug = false,
  debugModules = {},
  name = jo_libs,
  resourceName = resourceName,
  context = context,
  cache = {},
  isServerSide = function()
    return context == "server"
  end,
  isClientSide = function()
    return context == "client"
  end
}, {
  __index = call,
  __call = noFunction
})

function jo.waitLibLoading()
  while not jo.libLoaded do
    Wait(0)
  end
end

function jo.isModuleLoaded(name, needLocal)
  name = getAlias(name)
  return isModuleLoaded(name, needLocal)
end

local function onReady(cb)
  jo.waitLibLoading()
  Wait(1000)

  return cb and cb() or true
end

function jo.ready(cb)
  CreateThreadNow(function() onReady(cb) end)
end

function jo.stopped(cb)
  AddEventHandler("onResourceStop", function(resource)
    if resource ~= resourceName then return end
    cb()
  end)
end

-------------
-- ASYNC
-------------
--- Wraps a function to run inside a thread and return a promise
local function asyncWrap(func)
  return function(...)
    local args = { ... }
    local waiter = promise.new()
    CreateThread(function()
      local results = { pcall(func, table.unpack(args)) }
      local ok = results[1]
      if ok then
        -- Pack results to return multiple values
        waiter:resolve({ table.unpack(results, 2) })
      else
        waiter:reject(results[2])
      end
    end)

    -- Wrap the promise to add .next() and .await() methods
    return setmetatable({}, {
      __index = function(_, key)
        if key == "next" then
          return function(_, callback, errorCallback)
            return waiter:next(function(results)
              return callback(table.unpack(results))
            end, errorCallback)
          end
        elseif key == "await" then
          return function()
            local results = Citizen.Await(waiter)
            return table.unpack(results)
          end
        else
          -- Proxy all other methods to the original promise
          return waiter[key]
        end
      end
    })
  end
end

local wrapValue
local createAsyncProxy
--- Creates a lazy async proxy for a table/module
function createAsyncProxy(tbl)
  return setmetatable({}, {
    __index = function(proxy, key)
      local value = rawget(tbl, key)
      if value == nil then
        value = tbl[key]
      end
      return wrapValue(proxy, key, value)
    end
  })
end

--- Wraps values into async proxies (caches wrapped functions/proxies in the parent proxy)
function wrapValue(proxy, key, value)
  if not value then return end

  local valueType = type(value)
  if valueType == "function" then
    local wrapped = asyncWrap(value)
    rawset(proxy, key, wrapped)
    return wrapped
  elseif valueType == "table" then
    local nested = createAsyncProxy(value)
    rawset(proxy, key, nested)
    return nested
  end
end

--- Global jo.async namespace (looks up jo.* first, then _G.*)
jo.async = setmetatable({}, {
  __index = function(proxy, key)
    local value = rawget(jo, key)
    if value == nil then
      value = rawget(_G, key)
    end
    return wrapValue(proxy, key, value)
  end
})

_ENV.jo = jo


if GetResourceState(jo_libs) ~= "started" and resourceName ~= "jo_libs" then
  error("^1jo_libs must be started before this resource.^0", 0)
end

-------------
-- DEFAULT MODULES
-------------

function jo.require(name, needLocal)
  needLocal = GetValue(needLocal, true)
  name = getAlias(name)
  if isModuleLoaded(name, needLocal) then return end
  return loadModule(name, needLocal)
end

if resourceName == "jo_libs" then
  exports("loadGlobalModule", function(name)
    while not jo.libLoaded do Wait(0) end
    jo.require(name, false)
    return true
  end)
  AddEventHandler("jo_libs:loadGlobalModule", function(name, cb)
    jo.require(name, false)
    cb()
    return true
  end)
end

jo.require("print")

if GetConvar(resourceName .. ":debug", "off") == "on" then
  oprint(("/!\\ %s is in debug mode /!\\"):format(resourceName))
  oprint("Don't use this in production!")
  jo.debug = true
end

AddConvarChangeListener(resourceName .. ":debug", function()
  jo.debug = GetConvar(resourceName .. ":debug", "off") == "on"
  if jo.debug then
    oprint(("/!\\ %s is in debug mode /!\\"):format(resourceName))
    oprint("Don't use this in production!")
  else
    oprint(("/!\\ %s debug mode turned OFF /!\\"):format(resourceName))
  end
end)

-------------
-- EXPORTS (prevent call before initializes)
-------------
local function createExport(name, cb)
  exports(name, function(...)
    jo.waitLibLoading()
    return cb(...)
  end)
end

--Sort module by priority
local priorityModules = { table = 1, print = 2, file = 3, math = 4, hook = 5 }
table.sort(modules, function(a, b)
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
for i = 1, #modules do
  local name = modules[i]
  jo.require(name)
  if name == "hook" then
    createExport("registerAction", jo.hook.registerAction)
    createExport("RegisterAction", jo.hook.RegisterAction)
    createExport("registerFilter", jo.hook.registerFilter)
    createExport("RegisterFilter", jo.hook.RegisterFilter)
  elseif name == "versionChecker" and context == "server" then
    -- createExport("GetScriptVersion", jo.versionChecker.GetScriptVersion)
    createExport("StopAddon", jo.versionChecker.stopAddon)
  end
end
jo.libLoaded = true
