jo.hook = {}

if not table.filter then
  jo.require('table')
end

-------------
-- Actions
-------------
local listActions = {}
---@param name string the name of the action
---@param fct function the function called
---@param priority? integer the priority of the action
function jo.hook.registerAction(name, fct, priority)
  if not listActions[name] then listActions[name] = {} end
  local pos = 1
  priority = priority or 10
  for i, action in ipairs(listActions[name]) do
    if action.priority <= priority then
      pos = i + 1
    else
      break
    end
  end
  table.insert(listActions[name], pos, {
    cb = fct,
    priority = priority,
    resource = GetInvokingResource() or GetCurrentResourceName()
  })
end
exports('registerAction', jo.hook.registerAction)

---@param name string the name of the action
---@param ...? any
function jo.hook.doActions(name, ...)
  if not listActions[name] then return end
  for _, action in ipairs(listActions[name]) do
    pcall(action.cb, ...)
  end
end

-------------
-- Filters
-------------
local listFilters = {}
---@param name string the name of the filter
---@param fct function the function called
---@param priority? integer the priority of the filter
function jo.hook.registerFilter(name, fct, priority)
  if not listFilters[name] then listFilters[name] = {} end
  local pos = 1
  priority = priority or 10
  for i, filter in ipairs(listFilters[name]) do
    if filter.priority <= priority then
      pos = i + 1
    else
      break
    end
  end
  table.insert(listFilters[name], pos, {
    cb = fct,
    priority = priority,
    resource = GetInvokingResource() or GetCurrentResourceName()
  })
end

---@param name string the name of the filter
---@param value any the value to filter
---@param ...? any
function jo.hook.applyFilters(name, value, ...)
  if not listFilters[name] then return value end
  for _, filter in ipairs(listFilters[name]) do
    local status, result = pcall(filter.cb, value, ...)
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

-------------
-- CLEAR Filters & Actions when script stopped
-------------
AddEventHandler('onResourceStop', function(resourceName)
  local currentResource = GetCurrentResourceName()

  if currentResource == resourceName then return end

  local removed = 0
  for _, filters in pairs(listFilters) do
    local i = 1
    while i <= #filters do
      if filters[i].resource == resourceName then
        table.remove(filters, i)
        removed += 1
      else
        i += 1
      end
    end
  end

  if removed > 0 then
    print(('%d filters removed before stop %s in %s'):format(removed, resourceName, GetCurrentResourceName()))
  end

  removed = 0
  for _, actions in pairs(listActions) do
    local i = 1
    while i <= #actions do
      if actions[i].resource == resourceName then
        table.remove(actions, i)
        removed += 1
      else
        i += 1
      end
    end
  end

  if removed > 0 then
    print(('%d actions removed before stop %s in %s'):format(removed, resourceName, GetCurrentResourceName()))
  end
end)

