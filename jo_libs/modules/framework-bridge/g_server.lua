RegisterNetEvent('jo_libs:server:applySkinAndClothes', function(ped,skin,clothes)
  local source = source
  local ped = ped
  local skin = standardizeSkinKeys(skin)
  local clothes = standardizeClothesKeys(clothes)

  if clothes.teeth then
    skin.teeth = clothes.teeth.hash
    clothes.teeth = nil
  end

  TriggerClientEvent("jo_libs:client:applySkinAndClothes",source,ped,skin,clothes)
end)
