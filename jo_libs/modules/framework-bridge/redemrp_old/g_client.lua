RegisterNetEvent("rdr_clothes_store:ApplyClothes", function(clothes, ped, skin)
  ped = ped or PlayerPedId()
  TriggerServerEvent("jo_libs:server:applySkinAndClothes", ped, skin, clothes)
end)

RegisterNetEvent("redemrp_clothing:load", function(clothes, ped, skin)
  ped = ped or PlayerPedId()
  TriggerServerEvent("jo_libs:server:applySkinAndClothes", ped, skin, clothes)
end)

RegisterNetEvent("rdr_creator:SkinLoaded", function(skin, ped, clothes)
  ped = ped or PlayerPedId()
  TriggerServerEvent("jo_libs:server:applySkinAndClothes", ped, skin, clothes)
end)