RegisterNetEvent("vorpcharacter:reloadedskinlistener", function()
  local source = source

  if table.count(jo.framework:getUserIdentifiers(source)) == 0 then return end --Character not selected

  local skin = jo.framework:getUserSkin(source)
  local clothes = jo.framework:getUserClothes(source)

  TriggerClientEvent("jo_libs:client:applySkinAndClothes", source, nil, skin, clothes)
end)
