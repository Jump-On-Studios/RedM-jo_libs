local Inventory

TriggerEvent("redemrp_inventory:getData", function(call)
  Inventory = call
  jo.framework.inv = Inventory
end)

-------------
-- INVENTORY
-------------

---@param source integer source ID
---@param item string name of the item
---@param amount integer amount to use
---@param meta table metadata of the item
---@param remove boolean if removed after used
function jo.framework:canUseItem(source, item, amount, meta, remove)
  local itemData = Inventory.getItem(source, item, meta)
  if itemData and itemData.ItemAmount >= amount then
    if remove then
      itemData.RemoveItem(amount)
    end
    return true
  end
  return false
end

---@param item string name of the item
---@param callback function function fired when the item is used
---@param closeAfterUsed boolean if inventory needs to be closes
---@return boolean
function jo.framework:registerUseItem(item, closeAfterUsed, callback)
  if type(closeAfterUsed) == "function" then
    callback = closeAfterUsed
    closeAfterUsed = true
  end
  local isExist = Inventory.getItemData(item)
  if not isExist then
    return false, eprint(item .. " < item does not exist in the inventory configuration")
  end
  AddEventHandler("RegisterUsableItem:" .. item, function(source, data)
    callback(source, { metadata = data.meta })
    if closeAfterUsed then
      TriggerClientEvent("redemrp_inventory:closeinv", source)
    end
  end)
  return true
end

---@param source integer source ID
---@param item string name of the item
---@param quantity integer quantity
---@param meta table metadata of the item
---@return boolean
function jo.framework:giveItem(source, item, quantity, meta)
  local ItemData = Inventory.getItem(source, item, meta) -- this give you info and functions
  return ItemData.AddItem(quantity, meta)
end

---@param invName string unique ID of the inventory
---@param name string name of the inventory
---@param invConfig table Configuration of the inventory
---@return boolean
function jo.framework:createInventory(invName, name, invConfig)
  return Inventory.createLocker(invName, "empty")
end

---@param invName string unique ID of the inventory
---@return boolean
function jo.framework:removeInventory(invName)
  return false
end

---@param source integer sourceIdentifier
---@param invName string name of the inventory
---@return boolean
function jo.framework:openInventory(source, invName)
  TriggerClientEvent("redemrp_inventory:OpenLocker", source, invName)
  return true
end

---@param invId string unique ID of the inventory
---@param item string name of the item
---@param quantity integer quantity
---@param metadata table metadata of the item
---@param needWait? boolean wait after the adding
---@return boolean
function jo.framework:addItemInInventory(source, invId, item, quantity, metadata, needWait)
  return Inventory.addItemLocker(item, quantity, metadata, invId)
end

---@param invId string name of the inventory
---@return table
function jo.framework:getItemsFromInventory(invId)
  local invItems = Inventory.getLocker(invId)
  if not invItems then return {} end
  local items = {}
  for i = 1, #invItems do
    items[i] = {
      metadata = invItems[i].meta,
      amount = invItems[i].amount,
      item = invItems[i].name
    }
  end
  return items
end

-------------
-- END INVENTORY
-------------
