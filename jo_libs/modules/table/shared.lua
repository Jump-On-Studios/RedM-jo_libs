---@param orig  table Table to copy
---@return table
table.copy = function(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == "table" then
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
  for k, v in pairs(t2 or {}) do
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

table.mergeAfter = function(t1, t2)
  t1 = t1 or {}
  if not t2 then return t1 end
  for _, v in pairs(t2 or {}) do
    t1[#t1 + 1] = v
  end
  return t1
end

---@param _table table
---@return boolean
table.isEmpty = function(_table)
  for _, _ in pairs(_table or {}) do
    return false
  end
  return true
end

---@param _table table
---@return integer
table.count = function(_table)
  local counter = 0
  for _, _ in pairs(_table or {}) do
    counter += 1
  end
  return counter
end

---@param t table the table to filter
---@param filterIter function the function to filter the table
---@param keepKeyAssociation boolean keep the table keys (default false)
---@return table out the filtered table
table.filter = function(t, filterIter, keepKeyAssociation)
  local out = {}
  if keepKeyAssociation == nil then keepKeyAssociation = false end
  for k, v in pairs(t) do
    if filterIter(v, k, t) then
      if keepKeyAssociation or type(k) ~= "number" then
        out[k] = v
      else
        out[#out + 1] = v
      end
    end
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
  return table.copy(new_table)
end

---@param t table the table to search in
---@param func function the function to test the value
---@return any value the found table
---@return any value the key of the value
table.find = function(t, func)
  for i, v in pairs(t or {}) do
    if func(v, i, t) then
      return v, i
    end
  end
  return false
end

---@param t table the table to clean
---@return table new_table the table without functions
table.clearForNui = function(t)
  local new_table = {}
  for key, data in pairs(t) do
    if type(data) == "function" then
    elseif type(data) == "table" then
      new_table[key] = table.clearForNui(data)
    else
      new_table[key] = data
    end
  end
  return new_table
end


---@param table1 table first table to compare
---@param table2 table second table to compare
---@param strict? boolean  if all keys should be in both table (default: true)
---@param canMissInTable1? any if table2 keys can miss in table1 (default: false)
---@param canMissInTable2? any if table1 keys can miss in table2 (default: false)
table.isEgal = function(table1, table2, strict, canMissInTable1, canMissInTable2)
  strict = strict ~= false                   -- strict est par défaut true, sauf si explicitement mis à false
  canMissInTable1 = canMissInTable1 or false -- par défaut false
  canMissInTable2 = canMissInTable2 or false -- par défaut false

  if type(table1) ~= "table" or type(table2) ~= "table" then
    return table1 == table2
  end

  for key, value in pairs(table1) do
    if not canMissInTable2 or table2[key] ~= nil then
      if not table.isEgal(value, table2[key], strict, canMissInTable1, canMissInTable2) then
        return false
      end
    end
  end

  if strict then
    for key, value in pairs(table2) do
      if not canMissInTable1 or table1[key] ~= nil then
        if not table.isEgal(value, table1[key], strict, canMissInTable1, canMissInTable2) then
          return false
        end
      end
    end
  end

  return true
end


jo.table = {}
