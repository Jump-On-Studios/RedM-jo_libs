jo.entity = {}

--- Delete an entity if it exists
---@param entity integer (The entity ID to delete)
function jo.entity.delete(entity)
  if not DoesEntityExist(entity) then return end
  DeleteEntity(entity)
end
