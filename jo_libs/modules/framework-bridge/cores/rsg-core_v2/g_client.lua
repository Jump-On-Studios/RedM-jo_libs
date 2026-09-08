local RSGCore = exports["rsg-core"]:GetCoreObject()
jo.framework.core = RSGCore

AddEventHandler("RSGCore:Client:UpdateObject", function()
  RSGCore = exports["rsg-core"]:GetCoreObject()
  jo.framework.core = RSGCore
end)

RegisterNetEvent("rsg-appearance:client:ApplyClothes", function(clothes, ped, skin)
  ped = ped or PlayerPedId()
  if skin and not clothes then
    return TriggerServerEvent("jo_libs:server:applySkin", ped, skin)
  end
  if clothes and not skin then
    return TriggerServerEvent("jo_libs:server:applyClothes", ped, clothes)
  end
  TriggerServerEvent("jo_libs:server:applySkinAndClothes", ped, skin, clothes)
end)
