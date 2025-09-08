local RSGCore = exports["rsg-core"]:GetCoreObject()
jo.framework.core = RSGCore

function jo.framework:getInventoryItems()
  local itemsRSG = self.core.Shared.Items
  local items = {}
  for id, item in pairs(itemsRSG) do
    items[id] = {
      item = id,
      label = item.label,
      type = item.type,
      description = item.description,
      image = "nui://rsg_inventory/html/imgages/" .. item.image .. ".png"
    }
  end
  return items
end
