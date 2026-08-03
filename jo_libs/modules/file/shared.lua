jo.createModule("file")

local function convertModName(modname)
  local modpath = modname:gsub("%.", "/")
  local resource = ""

  if modpath:sub(1, 1) == "@" then
    for match in (modpath .. "/"):gmatch("(.-)" .. "/") do
      resource = match:sub(2)
      break
    end
    modpath = modpath:sub(resource:len() + 3)
  else
    resource = "jo_libs"
    modpath = "modules/" .. modpath
  end
  return resource, modpath
end

--- Loads and executes a Lua file
---@param modname string (The file location)
---@return any (The result of the executed file, or `false` if there was an error)
function jo.file.load(modname)
  if type(modname) ~= "string" then return end
  dprint(modname, "~orange~: Start loading")

  local file, resource, modpath = jo.file.read(modname)

  if not file then
    print(("\n^1Impossible to load. File doesn't exist: %s^0"):format(modname))
    return false
  end

  local fn, err = load(file, ("@@%s/%s.lua"):format(resource, modpath))

  if not fn or err then
    return error(("\n^1Error loading file (%s): %s^0"):format(modname, err), 3)
  end

  dprint(modname, "~green~: Loaded")

  local success, result = pcall(fn)

  if not success then
    print(("\n^1Error loading file (%s): %s^0"):format(modname, result))
    return false
  end
  return result
end

local function readFile(extension, ...)
  local args = { ... }
  local resource, modpath
  if args[2] then
    resource, modpath = args[1], args[2]
  else
    resource, modpath = convertModName(args[1])
  end
  local file = LoadResourceFile(resource, ("%s.%s"):format(modpath, extension))

  return file or false, resource, modpath
end

--- Read a file and return it if it's exist or `false`. The function accept one or two arguments.
--- One argument: the filepath
--- Two argument: the resource AND the filepath
---@param ... string (path of the file)
---@return file|boolean,resource|string,modpath|string
function jo.file.read(...)
  return readFile("lua", ...)
end

--- Read a JSON file and return its content if it's exist or `false`. The function accept one or two arguments.
--- One argument: the filepath
--- Two argument: the resource AND the filepath
---@param ... string (path of the file, without the `.json` extension)
---@return file|boolean,resource|string,modpath|string
function jo.file.readJson(...)
  return readFile("json", ...)
end

--- Loads a JSON file and returns it decoded
---@param ... string (path of the file, without the `.json` extension)
---@return table|boolean (The decoded content of the file, or `false` if there was an error)
function jo.file.loadJson(...)
  local modname = table.concat({ ... }, "/")
  dprint(modname, "~orange~: Start loading")

  local file = jo.file.readJson(...)

  if not file then
    print(("\n^1Impossible to load. File doesn't exist: %s.json^0"):format(modname))
    return false
  end

  local success, result = pcall(UnJson, file)

  if not success then
    print(("\n^1Error loading file (%s.json): %s^0"):format(modname, result))
    return false
  end

  dprint(modname, "~green~: Loaded")

  return result
end

--- Checks if a file exists
---@param modname string (The file location)
---@return boolean (Returns `true` if the file exists, `false` otherwise)
function jo.file.isExist(...)
  return jo.file.read(...) and true or false
end

