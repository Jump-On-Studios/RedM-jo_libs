jo.file = {}

local function convertModName(modname)
  local modpath = modname:gsub("%.", "/")
  local resource = ""

  if modpath:sub(1, 1) == "@" then
    function splitString(input, delimiter)
      local result = {}
      for match in (input .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
      end
      return result
    end
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

  local resource, modpath = convertModName(modname)

  local file = LoadResourceFile(resource, ("%s.lua"):format(modpath))

  if file then
    local fn, err = load(file, ("@@%s/%s.lua"):format(resource, modpath))

    if not fn or err then
      return error(("\n^1Error loading file (%s): %s^0"):format(modname, err), 3)
    end

    dprint(modname, "~green~: Loaded")

    local success, result = pcall(fn)

    if not success then return false, eprint("Error loading: " .. modname) end
    return result
  else
    return false, eprint(modname, ": Impossible to load. File doesn't exist.")
  end
end

function jo.file.isExist(modname)
  local resource, modpath = convertModName(modname)
  local file = LoadResourceFile(resource, ("%s.lua"):format(modpath))

  return file and true or false
end
