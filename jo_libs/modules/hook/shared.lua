-------------
-- Actions
-------------
local listActions = {}
---@param name string the name of the action
---@param fct function the function called
---@param priority? integer the priority of the action
function jo.registerAction(name,fct,priority)
	if not listActions[name] then listActions[name] = {} end
  local pos = 1
  priority = priority or 10
  for i,action in ipairs(listActions[name]) do
    if action.priority <= priority then
      pos = i + 1
    else
      break
    end
  end
	table.insert(listActions[name],pos,{
    cb = fct,
    priority = priority
  })
end
exports('registerAction',jo.registerAction)

---@param name string the name of the action
---@param ...? any
function jo.doActions(name,...)
	if not listActions[name] then return end
	for _,action in ipairs (listActions[name]) do
		pcall(action.cb,...)
	end
end

-------------
-- Filters
-------------
local listFilters = {}
---@param name string the name of the filter
---@param fct function the function called
---@param priority? integer the priority of the filter
function jo.registerFilter(name,fct,priority)
	if not listFilters[name] then listFilters[name] = {} end
  local pos = 1
  priority = priority or 10
  for i,filter in ipairs(listFilters[name]) do
    if filter.priority <= priority then
      pos = i + 1
    else
      break
    end
  end
	table.insert(listFilters[name],pos,{
    cb = fct,
    priority = priority
  })
end
exports('registerFilter',jo.registerFilter)

---@param name string the name of the filter
---@param value any the value to filter
---@param ...? any
function jo.applyFilters(name,value,...)
	if not listFilters[name] then return value end
	for _,filter in ipairs (listFilters[name]) do
		  local status,result = pcall(filter.cb,value,...)
      if status then
        value = result
      end
	end
  return value
end