RegisterNetEvent("rsg-appearance:client:ApplyClothes", function(clothes, ped, skin)
  ped = ped or PlayerPedId()
  TriggerServerEvent("jo_libs:server:applySkinAndClothes", ped, skin, clothes)
end)
