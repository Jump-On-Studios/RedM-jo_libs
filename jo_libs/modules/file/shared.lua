jo.file = {}

function jo.file.load(modname)
  if type(modname) ~= "string" then return end
  local modpath = modname:gsub("%.", "/")

  local file = LoadResourceFile("jo_libs", ("modules/%s.lua"):format(modpath))

  if file then
    local fn, err = load(file, ("@@jo_libs/modules/%s.lua"):format(modpath))

    if not fn or err then
      return error(("\n^1Error loading file (%s): %s^0"):format(modpath, err), 3)
    end

    local status, result = pcall(fn)
    if status then
      return result
    else
      return false
    end
  else
    eprint("Impossible to load: " .. modname)
  end
end
