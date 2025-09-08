jo.require("file")

jo.component = {}

-------------
-- COMPONENT LISTS
-------------

--- A function to get the list of clothes sorted by sex and category
---@return table clothes_list_sorted
local playerComponentsData = nil
function jo.component.getFullPedComponentList()
  if playerComponentsData then return playerComponentsData end
  playerComponentsData = jo.file.load("component.data.playerComponents")
  return playerComponentsData
end

--- A function to get the list of horse's components sorted by category
---@return table horseData
local horseComponentsData = nil
function jo.component.getFullHorseComponentList()
  if horseComponentsData then return horseComponentsData end
  horseComponentsData = jo.file.load("component.data.horseComponents")
  return horseComponentsData
end

-------------
-- END COMPONENT LISTS
-------------

-------------
-- FUNCTIONS
-------------
--- A function to format component data
---@param _data string|number|table (The component data)
---@param hashData boolean (Hash the value is true)
---@return any data (The foormatted table for component data)
function jo.component.formatComponentData(_data, hashData)
  hashData = GetValue(hashData, false)
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

  if hashData then
    for key, value in pairs(data) do
      data[key] = GetHashFromString(value)
    end
  end

  return data
end

--- A fonction to get the category hash from its string
---@param category string|integer (The category string)
---@return integer (The category hash)
function jo.component.getCategoryHash(category)
  if type(category) == "number" then return category end

  if category == "horse_feathers" then
    return -287556490
  end

  return joaat(category)
end

-------------
-- END FUNCTIONS
-------------

exports("jo_component_get", function()
  return jo.component
end)
