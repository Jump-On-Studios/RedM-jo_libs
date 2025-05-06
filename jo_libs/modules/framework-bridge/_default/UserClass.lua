-------------
-- USER CLASS
-------------

--- Creates and returns a new User instance for the specified player
---@param source integer (The source ID of the player)
---@return UserClass (Return a User class object containing player data and methods)
function jo.framework.UserClass:get(source)
  self = table.copy(jo.framework.UserClass)
  self.source = tonumber(source)
  self.data = {}
  return self
end

--- Gets the amount of money a player has of the specified type
---@param moneyType integer (The type of currency: `0`: dollar, `1`: gold, `2`: rol )
---@return number (Return the amount for this kind of money)
function jo.framework.UserClass:getMoney(moneyType)
  return 0
end

--- Removes money from the player
---@param amount number (The amount of money to remove)
---@param moneyType integer (The type of currency: `0`: dollar, `1`: gold, `2`: rol )
function jo.framework.UserClass:removeMoney(amount, moneyType)
  return false
end

--- Adds money to the player
---@param amount number (The amount of money to add)
---@param moneyType integer (The type of currency: `0`: dollar, `1`: gold, `2`: rol)
function jo.framework.UserClass:addMoney(amount, moneyType)
  return false
end

--- Retrieves all identifiers associated with the player
---@return table (Return the player's identifiers <br> `identifiers.identifier` - Unique identifier of the player <br> `identifiers.charid` - Unique id of the player)
function jo.framework.UserClass:getIdentifiers()
  return {
    identifier = "",
    charid = 0
  }
end

--- Returns the current job assigned to a player
---@return string (Returns the job name of the player)
function jo.framework.UserClass:getJob()
  return ""
end

--- Returns the roleplay name (first and last name) of the player
---@return string (Returns the formatted first and last name of the player)
function jo.framework.UserClass:getRPName()
  return ""
end
