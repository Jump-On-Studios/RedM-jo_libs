jo.require("framework-bridge")

RegisterNetEvent("jo_libs:server:applySkinAndClothes", function(ped, skin, clothes)
  local source = source
  ped = ped
  skin = jo.framework.standardizeSkinKeys(UnJson(skin))
  clothes = jo.framework.standardizeClothesKeys(UnJson(clothes))

  if clothes.teeth then
    skin.teeth = clothes.teeth.hash
    clothes.teeth = nil
  end

  TriggerClientEvent("jo_libs:client:applySkinAndClothes", source, ped, skin, clothes)
end)

RegisterNetEvent("vorpcharacter:reloadedskinlistener", function()
  local source = source
  local skin = jo.framework:getUserSkin(source)
  local clothes = jo.framework:getUserClothes(source)
  TriggerClientEvent("jo_libs:client:applySkinAndClothes", source, nil, skin, clothes)
end)
