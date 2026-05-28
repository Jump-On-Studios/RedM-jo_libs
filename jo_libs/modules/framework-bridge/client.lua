-------------
-- VARIABLES
-------------
local myIdentifiers = {}

-------------
-- CORE
-------------
jo.framework:loadCoreFiles("client")

--- A function to get the user identifiers
function jo.framework:getMyIdentifiers()
  if table.isEmpty(myIdentifiers) then
    myIdentifiers = jo.callback.triggerServer(jo.resourceName .. ":server:framework:getPlayerIdentifiers")
  end
  return myIdentifiers
end

-------------
-- Inventories
-------------
jo.framework:loadInventoryFiles("client")
