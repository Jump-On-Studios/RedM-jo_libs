jo.hook = {}
-------------
-- Actions
-------------
local listActions = {}
---@param name string the name of the action
---@param fct function the function called
---@param priority? integer the priority of the action
function jo.hook.registerAction(name,fct,priority)
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
exports('registerAction',jo.hook.registerAction)
exports('RegisterAction',jo.hook.registerAction) --keep the compatibility with old export name

---@param name string the name of the action
---@param ...? any
function jo.hook.doActions(name,...)
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
function jo.hook.registerFilter(name,fct,priority)
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
exports('registerFilter',jo.hook.registerFilter)
exports('RegisterFilter',jo.hook.registerFilter) --keep the compatibility with old export name

---@param name string the name of the filter
---@param value any the value to filter
---@param ...? any
function jo.hook.applyFilters(name,value,...)
	if not listFilters[name] then return value end
	for _,filter in ipairs (listFilters[name]) do
		  local status,result = pcall(filter.cb,value,...)
      if status then
        value = result
      end
	end
  return value
end

return jo.hook