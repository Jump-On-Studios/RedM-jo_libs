jo.database = {}

jo.file.load("@oxmysql.lib.MySQL")

--- A function to create a table if not exist
---@param tableName string (The name of the table)
---@param definition string (The definition of the table)
---@return boolean (Return `true` if the table is created, `false` otherwise)
function jo.database.addTable(tableName, definition)
  local isExist = MySQL.single.await("SHOW TABLES LIKE ?", { tableName })
  if isExist then
    return false
  end

  MySQL.update.await("CREATE TABLE IF NOT EXISTS " .. tableName .. " (" .. definition .. ")")
  gprint("Database table created: " .. tableName)
  return true
end

--- A function to create a trigger if not exist
---@param triggerName string (The name of the trigger)
---@param definition string (The definition of the trigger)
---@return boolean (Return `true` if the trigger is created, `false` otherwise)
function jo.database.addTrigger(triggerName, definition)
  local isExist = MySQL.single.await("SHOW TRIGGERS WHERE `Trigger` = ?", { triggerName })
  if isExist then
    return false
  end
  MySQL.query.await("CREATE TRIGGER `" .. triggerName .. "` " .. definition)
  gprint("Database trigger created: " .. triggerName)
  return true
end

--- A function to create a column in a specific table if not exist
---@param tableName string (The name of the table)
---@param name string (The name of the column)
---@param definition string (The definition of the column)
---@return boolean (Return `true` if the column is created, `false` otherwise)
function jo.database.addColumn(tableName, name, definition)
  local tableExists = MySQL.single.await("SHOW TABLES LIKE ?", { tableName })
  if not tableExists then
    error("Table " .. tableName .. " does not exist")
    return false
  end

  local isExist = MySQL.single.await("SHOW COLUMNS FROM " .. tableName .. " LIKE ?", { name })
  if isExist then
    return false
  end

  gprint("Database column " .. name .. " added to " .. tableName)
  MySQL.update.await("ALTER TABLE `" .. tableName .. "` ADD `" .. name .. "` " .. definition)
  return true
end
