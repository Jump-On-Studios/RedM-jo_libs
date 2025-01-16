jo.require("framework-bridge")

RegisterNetEvent("jo_libs:server:applySkinAndClothes", function(ped, skin, clothes)
  local source = source
  ped = ped
  skin = jo.framework.standardizeSkin(UnJson(skin))
  clothes = jo.framework.standardizeClothes(UnJson(clothes))

  if clothes.teeth then
    skin.teeth = clothes.teeth.hash
    clothes.teeth = nil
  end

  TriggerClientEvent("jo_libs:client:applySkinAndClothes", source, ped, skin, clothes)
end)
