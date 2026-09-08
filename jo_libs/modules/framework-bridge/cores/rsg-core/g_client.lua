local RSGCore = exports["rsg-core"]:GetCoreObject()
jo.framework.core = RSGCore

AddEventHandler("RSGCore:Client:UpdateObject", function()
  RSGCore = exports["rsg-core"]:GetCoreObject()
  jo.framework.core = RSGCore
end)

RegisterNetEvent("rsg-clothes:ApplyClothes", function(clothes, ped, skin)
  ped = ped or PlayerPedId()
  TriggerServerEvent("jo_libs:server:applySkinAndClothes", ped, skin, clothes)
end)
