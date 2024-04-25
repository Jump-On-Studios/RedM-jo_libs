---@param orig  table Table to copy
---@return table
table.copy = function(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
      copy = {}
      for orig_key, orig_value in next, orig, nil do
          copy[table.copy(orig_key)] = table.copy(orig_value)
      end
      setmetatable(copy, table.copy(getmetatable(orig)))
  else -- number, string, boolean, etc
      copy = orig
  end
  return copy
end

---@param  t1 table
---@param t2 table
---@return table
table.merge = function(t1, t2)
  for k,v in pairs(t2) do
    if type(v) == "table" then
      if type(t1[k] or false) == "table" then
          table.merge(t1[k] or {}, t2[k] or {})
      else
          t1[k] = v
      end
    else
      t1[k] = v
    end
  end
  return t1
end

---@param _table table
---@return boolean
table.isEmpty = function (_table)
	for _,_ in pairs (_table) do
		return false
	end
	return true
end