local type = type
local setmetatable = setmetatable
local getmetatable = getmetatable
local pairs = pairs

--- Deep copies a table. Unlike "=", it doesn't keep the link between both tables.
---@param t table (The table you want to copy)
---@return table (The copy of the table)
function table.copy(t)
  if type(t) ~= "table" then
    return t
  end

  local copy = table.clone(t)
  for k, v in pairs(t) do
    if type(v) == "table" then
      copy[k] = table.copy(v)
    end
  end
  return setmetatable(copy, getmetatable(t))
end

--- Merges two tables together.
---@param t1 table (The main table)
---@param t2 table (The table to merge)
---@return table (The merged table. If the same key exists in both tables, only the value of t2 is kept)
function table.merge(t1, t2)
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

--- Merges the values of the second table sequentially into the first table.
---@param t1 table (The target table to merge into)
---@param t2 table (The table whose values will be appended)
---@return table (The merged table with values from t2 added at the end of t1)
function table.mergeAfter(t1, t2)
  t1 = t1 or {}
  if not t2 then return t1 end
  for _, v in pairs(t2 or {}) do
    t1[#t1 + 1] = v
  end
  return t1
end

--- Checks if a table is empty.
---@param t table (The table to check)
---@return boolean (Returns true if the table is empty)
function table.isEmpty(t)
  for _ in pairs(t or {}) do
    return false
  end
  return true
end

--- Counts the number of values inside a table.
---@param t table (The table to count elements in)
---@return integer (The number of values inside the table)
function table.count(t)
  if not t then return 0 end
  if type(t) ~= "table" then return error(("t is not a table. Type: %s"):format(type(t))) end
  local n = #t
  if n > 0 then return n end
  local counter = 0
  for _ in pairs(t) do
    counter += 1
  end
  return counter
end

--- Filters a table based on a callback function.
---@param t table (The table to filter)
---@param filterIter function (A function to execute for each element in the table. Should return `true` to keep the element. Called with (element, key, originalTable))
---@param keepKeyAssociation? boolean (Keep the original table keys instead of creating a sequential table <br> default:`false`)
---@return table (The filtered table)
function table.filter(t, filterIter, keepKeyAssociation)
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

--- Creates a new table populated with the results of calling a function on every element.
---@param t table (The table to map)
---@param func function (A function to transform each element. Called with (element, key, originalTable))
---@return table (The new mapped table)
function table.map(t, func)
  local new_table = {}
  for i, v in pairs(t or {}) do
    new_table[i] = func(v, i, t)
  end
  return table.copy(new_table)
end

--- Returns the first element in the table that satisfies the provided function.
---@param t table (The table to search in)
---@param func function (A function to test each element. Should return `true` when found. Called with (element, key, originalTable))
---@return any,any (The found value or `false` if not found , The key of the found value)
function table.find(t, func)
  for i, v in pairs(t or {}) do
    if func(v, i, t) then
      return v, i
    end
  end
  return false
end

--- Returns a copy of the table with all function values removed.
---@param t table (The table to clean)
---@return table (The table without function values)
function table.clearForNui(t)
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

--- Compares two tables for equality.
---@param table1 table (First table to compare)
---@param table2 table (Second table to compare)
---@param strict? boolean (If all keys should be in both tables <br> default:`true`)
---@param canMissInTable1? boolean (If table2 keys can miss in table1 <br> default:`false`)
---@param canMissInTable2? boolean (If table1 keys can miss in table2 <br> default:`false`)
---@return boolean (Returns `true` if tables are equal according to specified parameters)
function table.isEgal(table1, table2, strict, canMissInTable1, canMissInTable2)
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

--- Extracts a value from a table by key and removes that key from the table.
---@param t table (The table to extract from)
---@param key any (The key to extract)
---@return any (The extracted value)
function table.extract(t, key)
  local value = type(t[key]) == "table" and table.copy(t[key]) or t[key]
  t[key] = nil
  return value
end

jo.table = {}
