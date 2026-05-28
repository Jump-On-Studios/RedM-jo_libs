function jo.framework:getInventoryItems()
  local itemsRSG = self.core.Shared.Items
  local items = {}
  for id, item in pairs(itemsRSG) do
    local image = item.image or id
    if not image:match("%.%w+$") then
      image = image .. ".png"
    end
    items[id] = {
      item = id,
      label = item.label,
      type = item.type,
      description = item.description,
      image = "nui://rsg-inventory/html/images/" .. image
    }
  end
  return items
end
