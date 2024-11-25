jo.database = {}

---@param tableName string the name of the table
---@param definition string the definition of the table
function jo.database.addTable(tableName, definition)
  local isExist = MySQL.single.await('SHOW TABLES LIKE @tableName',{tableName=tableName})
  if isExist then
    return false
  end
  MySQL.update.await("CREATE TABLE IF NOT EXISTS "..tableName.." ("..definition..')')
  gprint('Database table created : '..tableName)
  return true
end

---@param triggerName string the name of the trigger
---@param definition string the definition of the trigger
function jo.database.addTrigger(triggerName,definition)
  local isExist = MySQL.single.await("SHOW TRIGGERS WHERE `Trigger` = ?",{triggerName})
  if isExist then
    return false
  end
  MySQL.query.await("CREATE TRIGGER `"..triggerName.."` "..definition)
  gprint('Database trigger created : '..triggerName)
  return true
end

---@param tableName string the name of the table
---@param name string the name of the column
---@param definition string the definition of the column
function jo.database.addColumn(tableName,name,definition)
  local isExist = MySQL.single.await("SHOW COLUMNS FROM "..tableName.." LIKE ?",{name})
  if isExist then
    return false
  end
  gprint('Database column '..name..' added to '..tableName)
  MySQL.update.await("ALTER TABLE `"..tableName.."` ADD `"..name.."` "..definition)
  return true
end
