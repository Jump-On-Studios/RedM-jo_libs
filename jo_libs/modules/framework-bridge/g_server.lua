jo.require("framework-bridge")

jo.framework:loadFile("g_server")
jo.framework:loadFile("_custom", "g_server")

RegisterNetEvent("jo_libs:server:applySkinAndClothes", function(ped, skin, clothes)
  local source = source

  if jo.framework:is("VORP") then
    if table.count(jo.framework:getUserIdentifiers(source)) > 0 then return end --will be fired by vorpcharacter:reloadedskinlistener
  end

  ped = ped
  skin = jo.framework:standardizeSkin(UnJson(skin))
  clothes = jo.framework:standardizeClothes(UnJson(clothes))

  if clothes.teeth then
    skin.teeth = clothes.teeth.hash
    clothes.teeth = nil
  end

  TriggerClientEvent("jo_libs:client:applySkinAndClothes", source, ped, skin, clothes)
end)
