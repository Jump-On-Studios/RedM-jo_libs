if not gprint then
  return print('^1NEED TO LOAD prints.lua FIRST !!!!!!^0')
end

function addTableDB(tableName, tableStructure)
  local isExist = MySQL.single.await('SHOW TABLES LIKE @tableName',{tableName=tableName})
  if isExist then
    return false
  end
  MySQL.update.await("CREATE TABLE IF NOT EXISTS "..tableName.." ("..tableStructure..')')
  gprint('Database table created : '..tableName)
  return true
end

function addTriggerDB(triggerName,definition)
  local isExist = MySQL.single.await("SHOW TRIGGERS WHERE `Trigger` = ?",{triggerName})
  if isExist then
    return false
  end
  MySQL.query.await(definition)
  gprint('Database trigger created : '..triggerName)
  return true
end

function addColumnDB(tableName,name,definition)
  local isExist = MySQL.single.await("SHOW COLUMNS FROM "..tableName.." LIKE ?",{name})
  if isExist then
    return false
  end
  gprint('Database column '..name..' added to '..tableName)
  MySQL.update.await("ALTER TABLE `"..tableName.."` ADD `"..name.."` "..definition)
  return true
end