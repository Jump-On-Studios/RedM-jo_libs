jo.require("table")

jo.component = {}

local function isValidValue(value)
  return value and value ~= 0 and value ~= -1 and value ~= 1
end

--- A function to format component data
---@param _data string|number|table (The component data)
---@return any data (The foormatted table for component data)
function jo.component.formatComponentData(_data)
  local data = table.copy(_data)
  if type(data) ~= "table" then
    data = { hash = data }
  end
  if table.type(data) == "array" then
    data = {
      hash = data[1] or 0,
      drawable = data[2],
      albedo = data[3],
      normal = data[4],
      material = data[5],
      palette = data[6],
      tint0 = data[7],
      tint1 = data[8],
      tint2 = data[9]
    }
  end
  if type(data.hash) == "table" then data = data.hash end --for VORP
  if data.hash == 0 or data.hash == false then
    data.remove = true
  end
  data.hash = isValidValue(data.hash) and data.hash or nil
  data.drawable = isValidValue(data.drawable) and data.drawable or nil
  data.palette = isValidValue(data.palette) and data.palette or nil

  if not data.hash and not data.drawable and not data.palette and not data.remove then
    return false
  end
  return data
end

TriggerEvent("print", GetHashFromString("HORSEFEATHERS"))
