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

--------------
-- DEPRECIATED
-------------
function jo.hook.RegisterFilter(...)
  jo.hook.registerFilter(...)
  CreateThread(function()
    Wait(3000)
    oprint('RegisterFilter with "R" in uppercase is depreciated. Use registerFilter with "r" in lowercase !')
  end)
end
function jo.hook.RegisterAction(...)
  jo.hook.registerAction(...)
  CreateThread(function()
    Wait(3000)
    oprint('RegisterAction with "R" in uppercase is depreciated. Use registerAction with "r" in lowercase !')
  end)
end

return jo.hook
