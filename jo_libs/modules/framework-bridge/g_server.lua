RegisterNetEvent('jo_libs:server:applySkinAndClothes', function(ped,skin,clothes)
  local source = source
  local ped = ped
  local skin = standardizeSkinKeys(skin)
  local clothes = standardizeClothesKeys(clothes)

  if clothes.teeth then
    skin.teeth = type(clothes.teeth) == "table" and clothes.teeth.hash or clothes.teeth
    clothes.teeth = nil
  end

  TriggerEvent("print",clothes,skin)
  TriggerClientEvent("jo_libs:client:applySkinAndClothes",source,ped,clothes,skin)
end)
