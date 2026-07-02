
function jo.framework:getInventoryItems()
  local itemsGM = exports.gm_inventory:Items()

  local items = {}
  for id, item in pairs(itemsGM) do
    items[id] = {
      item = id,
      label = item.label,
      description = item.description,
      image = "nui://gm_inventory/web/images/" .. item.name .. ".png"
    }
  end
  return items
end
