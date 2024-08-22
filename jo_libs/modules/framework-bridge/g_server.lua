print('================> LOAD GLOBAL')

RegisterNetEvent('jo_libs:client:applySkinAndClothes', function(ped,skin,clothes)
  local source = source
  local skin = standardizeSkinKeys(skin)
  local standardizeClothes = standardizeClothesKeys(clothes)

  if standardizeClothes.teeth then
    skin.teeth = type(standardizeClothes.teeth) == "table" and standardizeClothes.teeth.hash or standardizeClothes.teeth
    standardizeClothes.teeth = nil
  end

  TriggerEvent("print",standardizeClothes,skin)
end)