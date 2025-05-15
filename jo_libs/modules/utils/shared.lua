jo.utils = {}

--- A function to convert a value to table if it's not already a table
---@param value any (The value to move inside a table)
---@param key string (The key of the value inside the new table)
---@return table (The new table with {key = value})
function jo.utils.convertToTable(value, key)
  if type(value) == "table" then return value end
  return { [key] = value }
end
