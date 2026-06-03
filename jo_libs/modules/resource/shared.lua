jo.require("string")

jo.createModule("resource")

--- Check if a resource matches the expected state and version/convar condition
--- A "!" prefixed resource must NOT be running; otherwise the resource must be running and satisfy its condition
---@param str string ((resourceName:convar(< > <= >= ==)value) or "!resourceName")
---@return boolean (true if the resource matches)
function jo.resource.isConvarMatching(str)
  local resource, convar, comparator, value = str:extractConvarComparator()
  local state = GetResourceState(resource)

  -- "!" prefix: the resource must NOT be running
  if resource:sub(1, 1) == "!" then
    return state ~= "starting" and state ~= "started"
  end

  -- the resource must be running
  if state == "missing" or state == "stopped" then
    return false
  end

  -- optional version/convar condition (convar defaults to "version")
  if not comparator then return true end
  local currentValue = tostring(GetValue(GetResourceMetadata(resource, convar or "version", 0), 1))
  local compare = currentValue:compareVersionWith(value)
  if comparator == "<=" then
    return compare <= 0
  elseif comparator == ">=" then
    return compare >= 0
  elseif comparator == "==" or comparator == "=" then
    return compare == 0
  elseif comparator == "<" then
    return compare < 0
  elseif comparator == ">" then
    return compare > 0
  end
  return true
end
