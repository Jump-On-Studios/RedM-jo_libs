jo.component = {}

jo.require("file")

--- A function to get the list of clothes sorted by sex and category
---@return table clothes_list_sorted
function jo.component.getFullPedComponentList()
  if clothes_list_sorted then return clothes_list_sorted end
  jo.file.load("component.clothesList")
  return clothes_list_sorted
end

--- A function to get the list of horse's components sorted by category
---@return table HorseComponents
function jo.component.getFullHorseComponentList()
  if HorseComponents then return HorseComponents end
  jo.file.load("component.HorseComponents")
  return HorseComponents
end

for _, shortcut in pairs({ "clothes", "comp" }) do
  jo[shortcut] = setmetatable({}, {
    __index = function(self, key)
      return jo.component[key]
    end
  })
end
