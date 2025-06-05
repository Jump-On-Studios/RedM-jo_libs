RegisterNetEvent("vorpcharacter:reloadedskinlistener", function()
  local source = source

  if table.count(jo.framework:getUserIdentifiers(source)) == 0 then return end --Character not selected

  local skin = jo.framework:getUserSkin(source)
  local clothes = jo.framework:getUserClothes(source)

  TriggerClientEvent("jo_libs:client:applySkinAndClothes", source, nil, skin, clothes)
end)

function jo.framework:getItemsFromDBInternal()
  local itemsDB = MySQL.query.await("SELECT * FROM items")
  local items = {}
  for i = 1, #itemsDB do
    local item = itemsDB[i]
    items[item.item] = {
      item = item.item,
      label = item.label,
      type = item.type,
      description = item.description,
      image = "nui://vorp_inventory/html/img/items/" .. item.item .. ".png"
    }
  end
  return items
end
