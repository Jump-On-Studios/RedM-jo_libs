-- -----------
-- INVENTORY
-- -----------

--- Checks if a player has the required quantity of a specific item in their inventory and optionally removes it
---@param source integer (The source ID of the player)
---@param item string (The name of the item need to use)
---@param amount integer (The quantity of the item)
---@param meta? table (The metadata of the item)
---@param remove? boolean (If the item has to be removed <br> default:`false`)
---@return boolean (Return `true` if the player has enough quantity of the item)
function jo.framework:canUseItem(source, item, amount, meta, remove)
  return false
end

--- Registers an item as usable and attaches a callback function that executes when the item is used
---@param item string (The name of the item)
---@param closeAfterUsed? boolean (If the inventory needs to be closed after using the item <br> default:`true`)
---@param callback function (The function fired after use the item <br> 1st argument: source <br> 2nd argument: metadata of the item)
function jo.framework:registerUseItem(item, closeAfterUsed, callback)
  return false
end

--- Adds an item to a player's inventory with optional metadata
---@param source integer (The source ID of the player)
---@param item string (The name of the item)
---@param quantity integer (The amount of the item to give)
---@param meta? table (The metadata of the item)
---@return boolean (Return `true` if the item is successfully given)
function jo.framework:giveItem(source, item, quantity, meta)
  return false
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
  return false
end

--- Removes an inventory from the *server cache*, useful for reloading inventory data from the database
---@param invName string (Unique id of the inventory)
function jo.framework:removeInventory(invName)
  return false
end

--- Opens a specific inventory
---@param source integer (The source ID of the player)
---@param invName string (The unique ID of the inventory)
function jo.framework:openInventory(source, invName)
  return false
end

--- Adds a specific item to a custom inventory with optional metadata and wait parameter
---@param source integer (The source ID of the player)
---@param invId string (The unique ID of the inventory)
---@param item string (The name of the item)
---@param quantity integer (The quantity of the item)
---@param metadata? table (The metadata of the item)
---@param needWait? boolean (If need to wait after the SQL insertion <br> default:`false`)
function jo.framework:addItemInInventory(source, invId, item, quantity, metadata, needWait)
  return false
end

--- Retrieves all items from a specific inventory with their quantities and metadata
---@param invId string (The unique ID of the inventory)
---@return table (Return the list of items with structure : <br> `item.amount` : *integer* - The amount of the item<br> `item.id` : *integer* - The id of the item<br>`item.item` : *string* - The name of the item<br>`item.metadata` : *table* - The metadata of the item<br>)
function jo.framework:getItemsFromInventory(invId)
  --[[ item structure
  {
    metadata = {},
    amount = 0,
    item = "itemName"
  }
  ]]
  return {}
end

-- -----------
-- END INVENTORY
-- -----------
