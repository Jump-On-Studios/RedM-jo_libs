
if not IsModuleLoaded('framework')then
  jo.require('framework')
end

if not table.copy then
  jo.require('table')
end

---@param source integer
---@return {} table clothes
function jo.clothes.getUserClothes(source)
  local clothes = jo.framework:getUserClothes(source)

  if jo.framework:is('VORP') then
    local clothesVORP = table.copy(clothes)
    clothes = {}
    for catVORP,cat in pairs (jo.clothes.VORPCategories) do
      clothes[cat] = clothesVORP[catVORP] or 0
    end
  end

  if not clothes then return {} end
  clothes = UnJson(clothes)

  clothes = jo.clothes.cleanClothesTable(clothes)

  return clothes
end

function jo.clothes.revertClothesForFramework(clothesList)
  local list = {}
  for catVORP,cat in pairs (jo.clothes.VORPCategories) do
    list[catVORP] = clothesList[cat] or 0
  end
  return list
end

return jo.clothes