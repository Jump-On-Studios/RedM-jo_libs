jo.require("component")
jo.require("timeout")
jo.require("hook")
jo.require("ped-texture")
jo.require("waiter")

RegisterNetEvent("jo_libs:client:applySkinAndClothes", function(ped, skin, clothes)
  ped = ped or PlayerPedId()
  jo.timeout.delay("jo_libs:client:applySkinAndClothes:" .. ped, 100, function()
    skin = jo.hook.applyFilters("jo_libs:applySkinAndClothes:updateSkin", skin, clothes)
    clothes = jo.hook.applyFilters("jo_libs:applySkinAndClothes:updateClothes", clothes, skin)
    jo.hook.doActions("jo_libs:applySkinAndClothes:before", ped, skin, clothes)

    local isReady = jo.waiter.exec(function() return IsPedReadyToRender(ped) end)
    if not isReady then
      return eprint("This ped is not loaded:", ped)
    end

    for _, cat in ipairs(jo.component.order) do
      if clothes[cat] then
        jo.component.apply(ped, cat, clothes[cat])
      end
    end

    if IsPedMale(ped) then
      jo.component.apply(ped, "beards_complete", skin.beards_complete)
    else
      jo.component.apply(ped, "hair_accessories", clothes.hair_accessories)
    end
    jo.component.apply(ped, "hair", skin.hair)

    if skin.overlays then
      for category, overlay in pairs(skin.overlays) do
        if type(overlay) == "table" then
          local default = {
            id = 0,
            opacity = 0.0,
            category = category
          }
          if category == "hair" or category == "beard" then
            default.palette = "metaped_tint_hair"
            default.tint0 = 135
          end
          overlay = table.merge(default, overlay)
        end
      end
      jo.pedTexture.overwriteCategory(ped, "heads", skin.overlays, true)
    end
    jo.hook.doActions("jo_libs:applySkinAndClothes:after", ped, skin, clothes)
  end)
end)
