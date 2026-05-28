-- -----------
-- INVENTORY
-- -----------

local TPZInv = exports.tpz_inventory:getInventoryAPI()

jo.framework.inv = TPZInv

--- Checks if a player has the required quantity of a specific item in their inventory and optionally removes it
---@param source integer (The source ID of the player)
---@param item string (The name of the item need to use)
---@param amount integer (The quantity of the item)
---@param meta? table (The metadata of the item)
---@param remove? boolean (If the item has to be removed <br> default:`false`)
---@return boolean (Return `true` if the player has enough quantity of the item)
function jo.framework:canUseItem(source, item, amount, meta, remove)
  local count = TPZInv.getItemQuantity(source, item)

  if count >= amount then
    if remove then
      TPZInv.removeItem(source, item, amount, meta.itemId)
    end

    return true
  end
  return false
end

--- Registers an item as usable and attaches a callback function that executes when the item is used
---@param item string (The name of the item)
---@param closeAfterUsed? boolean (If the inventory needs to be closed after using the item <br> default:`true`)
---@param callback function (The function fired after use the item <br> 1st argument: source <br> 2nd argument: metadata of the item)
function jo.framework:registerUseItem(item, closeAfterUsed, callback)
  if type(closeAfterUsed) == "function" then
    callback = closeAfterUsed
    closeAfterUsed = true
  end
  CreateThread(function()
    if (closeAfterUsed == nil) then closeAfterUsed = true end

    TPZInv.registerUsableItem(item, "jo_libs", function(data)
      if closeAfterUsed then
        TPZInv.closeInventory(data.source)
      end
      return callback(data.source, { metadata = data.metadata })
    end)
  end)
end

--- Adds an item to a player's inventory with optional metadata
---@param source integer (The source ID of the player)
---@param item string (The name of the item)
---@param quantity integer (The amount of the item to give)
---@param meta? table (The metadata of the item)
---@return boolean (Return `true` if the item is successfully given)
function jo.framework:giveItem(source, item, quantity, meta)
  local canCarryItem = TPZInv.canCarryItem(source, item, quantity)

  if canCarryItem then
    return TPZInv.addItem(source, item, quantity, meta)
  end
end

--- Creates a custom inventory with configurable slots, weight limits, and item restrictions
---@param invName string (Unique id of the inventory)
---@param name string (Label of the inventory)
---@param invConfig table (Configuration of the inventory)
--- invConfig.maxSlots integer (Max slot of the inventory)
--- invConfig.maxWeight float (Max weight of the inventory)
--- invConfig.acceptWeapons? boolean (Whether the inventory accepts weapons)
--- invConfig.shared? boolean (If the inventory is shared between players)
--- invConfig.ignoreStackLimit? boolean (If the inventory can overcoming stack limits)
--- invConfig.whitelist? table (Restrict the list of items that can be put in the inventory)
--- invConfig.whitelistˌ_x_ˌitem string (Name of the whitelisted item)
--- invConfig.whitelistˌ_x_ˌlimit integer (Stack limit of this item)
function jo.framework:createInventory(invName, name, invConfig)
  -- @param containerName: requires a container name.
  -- @param containerWeight: requires the maximum container weight.
  -- @param insert : requires a boolean value (false / true) to insert to the containers database the new registered container inventory / not.
  -- @param contents: a non-required parameter which requires a table form (only experienced developers).
  TriggerEvent("tpz_inventory:registerContainerInventory", invName, invConfig.maxWeight, true)
end

--- Removes an inventory from the *server cache*, useful for reloading inventory data from the database
---@param invName string (Unique id of the inventory)
function jo.framework:removeInventory(invName)
  -- @param containerName: requires a container name.
  TriggerEvent("tpz_inventory:unregisterCustomContainerByName", invName)
end

--- Opens a specific inventory
---@param source integer (The source ID of the player)
---@param invName string (The unique ID of the inventory)
---@param header string (The header title of the inventory)
function jo.framework:openInventory(source, invName, header)
  if not header then
    header = "Storage"
  end

  TriggerClientEvent("tpz_inventory:openInventoryContainerByName", _source, invName, header)
end

--- Adds a specific item to a custom inventory with optional metadata and wait parameter
---@param source integer (The source ID of the player)
---@param invId string (The unique ID of the inventory)
---@param item string (The name of the item)
---@param quantity integer (The quantity of the item)
---@param metadata? table (The metadata of the item)
---@param needWait? boolean (If need to wait after the SQL insertion <br> default:`false`)
function jo.framework:addItemInInventory(source, invId, item, quantity, metadata, needWait)
  -- @param containerId : requires an existing container id (not name)
  -- @param item : requires an item name.
  -- @param quantity : requires a quantity.
  -- @param itemId : Required only if the item which is given already exists and has itemId.
  -- @param metadata : A non-required parameter.
  -- (!) metadata can hold multiple values (includes custom ones).
  -- For not showing durability to a non stackable item, set metadata.durability to -1.

  local itemId = nil

  if metadata then
    itemId = metadata.id
  end

  TPZInv.addContainerItem(invId, item, quantity, itemId, metadata)
end

--- Retrieves all items from a specific inventory with their quantities and metadata
---@param invId string (The unique ID of the inventory)
---@return table (Return the list of items with structure : <br> `item.amount` : *integer* - The amount of the item<br> `item.id` : *integer* - The id of the item<br>`item.item` : *string* - The name of the item<br>`item.metadata` : *table* - The metadata of the item<br>)
function jo.framework:getItemsFromInventory(invId)
  local newInventoryContents = {}
  local contents = TPZInv.getContainerInventoryContents(invId) or {}

  for k, v in pairs(contents) do
    local data = v
    data.amount = v.quantity

    table.insert(newInventoryContents, data)
  end

  return newInventoryContents
end

-- -----------
-- END INVENTORY
-- -----------
