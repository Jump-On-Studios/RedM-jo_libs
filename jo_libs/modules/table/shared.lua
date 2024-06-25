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
  t1 = t1 or {}
  if not t2 then return t1 end
  for k,v in pairs(t2 or {}) do
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
	for _,_ in pairs (_table or {}) do
		return false
	end
	return true
end

---@param _table table
---@return integer
table.count = function(_table)
  local counter = 0
  for _,_ in pairs (_table or {}) do
    counter += 1
  end
  return counter
end

---@param t table the table to filter
---@param filterIter function the function to filter the table
---@return table out the filtered table
table.filter = function(t, filterIter)
  local out = {}
  for k, v in pairs(t) do
    if filterIter(v, k, t) then out[k] = v end
  end
  return out
end

---@param t table the table to map
---@param func function the function to map the table
---@return table new_table the mapped table
table.map = function(t, func)
  local new_table = {}
  for i, v in pairs(t or {}) do
    new_table[i] = func(v, i, t)
  end
  return new_table
end

---@param t table the table to search in
---@param func function the function to test the value
---@return table new_table the found table
table.find = function(t, func)
  local new_table = {}
  for i, v in pairs(t or {}) do
    if func(v, i, t) then
        return v
    end
  end
  return false
end

---@param t table the table to clean
---@return table new_table the table without functions
table.clearForNui = function (t)
  local new_table = {}
  for key,data in pairs (t) do
    if type(data) == "function" then
    elseif type(data) == "table" then
      new_table[key] = table.clearForNui(data)
    else
      new_table[key] = data
    end
  end
  return new_table
end