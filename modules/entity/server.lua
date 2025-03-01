jo.entity = {}

---@param entity integer
function jo.entity.delete(entity)
  if not DoesEntityExist(entity) then return end
  DeleteEntity(entity)
end
