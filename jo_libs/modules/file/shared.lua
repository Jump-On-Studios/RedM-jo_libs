jo.file = {}

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

---@param modname string file location
---@return any
function jo.file.load(modname)
  if type(modname) ~= "string" then return end
  dprint(modname, "~orange~: Start loading")

  local file, resource, modpath = jo.file.read(modname)

  if not file then
    return false, eprint(modname, ": Impossible to load. File doesn't exist.")
  end

  local fn, err = load(file, ("@@%s/%s.lua"):format(resource, modpath))

  if not fn or err then
    return error(("\n^1Error loading file (%s): %s^0"):format(modname, err), 3)
  end

  dprint(modname, "~green~: Loaded")

  local success, result = pcall(fn)

  if not success then return false, eprint("Error loading: " .. modname) end
  return result
end

function jo.file.read(...)
  local args = { ... }
  local resource, modpath
  if args[2] then
    resource, modpath = args[1], args[2]
  else
    resource, modpath = convertModName(args[1])
  end
  local file = LoadResourceFile(resource, ("%s.lua"):format(modpath))

  return file or false, resource, modpath
end

function jo.file.isExist(...)
  return jo.file.read(...) and true or false
end
