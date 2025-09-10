-------------
-- BRIDGE OTHER MENU
-------------
local MenuData = {}
local menusOpened = {}

--- @autodoc:config ignore:true
function MenuData.Open(type, namespace, name, data, submit, cancel, change, close)
  local menu = {}
  menu.id = name
  menu.title = data.title
  menu.subtitle = data.subtext
  menu.data = data
  submit = submit or function() end
  cancel = cancel or function() end
  change = change or function() end
  close = close or function() end
  menu.close = function()
    menusOpened[name] = nil
    close(menu)
    if table.count(menusOpened) == 0 then
      jo.menu.show(false)
      TriggerEvent("menuapi:closemenu")
    end
  end
  menu.onBack = function()
    menu.data.elements = menus[name].items
    cancel(menu, menu)
    if (GetCurrentResourceName() == "vorp_menu") then
      submit({ current = "backup", trigger = data.lastmenu })
    end
  end
  menu.onExit = function()
    --menu.close()
  end

  jo.menu.delete(name)

  local nuiMenu = jo.menu.create(name, menu)

  local function convertElement(element)
    local item = element
    item.title = item.label
    item.description = item.desc
    if element.type == "slider" then
      local values = {}
      local min = (element.min < 0) and 0 or element.min
      local max = (element.max)
      for i = min, max, element.hop or 1 do
        table.insert(values, { label = i, value = i })
      end
      if item.value == 0 then
        item.value = 1
      end
      item.sliders = {
        {
          type = "switch",
          current = item.value or 1,
          values = values
        }
      }
    end
    item.onActive = function(data)
      menu.data.elements = menus[name].items
      change({ current = menu.data.elements[data.index] }, menu)
    end
    item.onChange = function(data)
      menu.data.elements = menus[name].items
      if #menu.data.elements[data.index].sliders > 0 then
        menu.data.elements[data.index].value = menu.data.elements[data.index].sliders[1].value.value
      end
      change({ current = menus[name].items[data.index] }, menu)
      submit({ current = menus[name].items[data.index] }, menu)
    end
    item.onClick = function(data)
      menu.data.elements = menus[name].items
      submit({ current = menus[name].items[data.index] }, menu)
    end
    nuiMenu:addItem(item)
  end

  for _, element in pairs(data.elements) do
    convertElement(element)
  end

  menu.update = function(query, newData)
    nuiMenu:refresh(false)
  end

  menu.addNewElement = function(element)
    convertElement(element)
  end

  menu.removeElementByValue = function(value, stop)
    for i = 1, #nuiMenu.items, 1 do
      if nuiMenu.items[i].value == value then
        table.remove(nuiMenu.items, i)
        if stop then
          break
        end
      end
    end
  end

  menu.removeElementByIndex = function(index, stop)
    table.remove(nuiMenu.items, index)
  end

  menu.refresh = function()
    nuiMenu:refresh(false)
  end

  menu.setElement = function(i, key, val)
    if key == "label" then key = "title" end
    if key == "desc" then key = "description" end
    if key == "value" and nuiMenu.items[i].type == "slider" then
      if val <= 0 then val = 1 end
      nuiMenu.items[i].sliders[1].current = val
    end
    if key == "max" and nuiMenu.items[i].type == "slider" then
      local values = {}
      for i = 1, val, 1 do
        table.insert(values, { label = i, value = i })
      end
      nuiMenu.items[i].sliders[1].values = values
    else
      nuiMenu.items[i][key] = val
    end
  end
  -- override all elements
  menu.setElements = function(newElements)
    for _, element in pairs(newElements) do
      menu.addNewElement(element)
    end
  end

  -- change the title of the current menu
  menu.setTitle = function(val)
    nuiMenu.title = val
  end

  menu.removeElement = function(query)
    for i = 1, #nuiMenu.items, 1 do
      for k, v in pairs(query) do
        if nuiMenu.items[i] then
          if nuiMenu.items[i][k] == v then
            nuiMenu.items[i] = nil
            break
          end
        end
      end
    end
  end

  menusOpened[name] = true
  nuiMenu:refresh(true)
  jo.menu.setCurrentMenu(name, true, true)
  jo.menu.show(true, true, false)
  return menu
end

--- @autodoc:config ignore:true
function MenuData.Close(type, namespace, name)
  jo.menu.show(false)
end

--- @autodoc:config ignore:true
function MenuData.CloseAll()
  jo.menu.show(false)
end

--- @autodoc:config ignore:true
function MenuData.GetOpened(type, namespace, name)
  return {}
end

--- @autodoc:config ignore:true
function MenuData.GetOpenedMenus()
  return {}
end

--- @autodoc:config ignore:true
function MenuData.IsOpen(type, namespace, name)
  return jo.menu.isOpen()
end

--- @autodoc:config ignore:true
function MenuData.ReOpen(oldMenu)
  MenuData.Open(oldMenu.type, oldMenu.namespace, oldMenu.name, oldMenu.data, oldMenu.submit, oldMenu.cancel,
    oldMenu.change, oldMenu.close)
end

exports("GetMenuData", function()
  return MenuData
end)

AddEventHandler("menuapi:getData", function(cb)
  cb(MenuData)
end)

AddEventHandler("vorp_menu:getData", function(cb)
  return cb(MenuData)
end)
