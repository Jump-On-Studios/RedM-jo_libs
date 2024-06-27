jo.menu = {}

if not GetResourceMetadata(GetCurrentResourceName(), 'ui_page') then
  eprint('WARNING ! NUI page is not defined. To use JO Menu, add ui_page "nui://jo_libs/nui/menu/index.html" inside your fxmanifest.lua')
  eprint('WARNING ! NUI page is not defined. To use JO Menu, add ui_page "nui://jo_libs/nui/menu/index.html" inside your fxmanifest.lua')
  eprint('WARNING ! NUI page is not defined. To use JO Menu, add ui_page "nui://jo_libs/nui/menu/index.html" inside your fxmanifest.lua')
  eprint('WARNING ! NUI page is not defined. To use JO Menu, add ui_page "nui://jo_libs/nui/menu/index.html" inside your fxmanifest.lua')
  eprint('WARNING ! NUI page is not defined. To use JO Menu, add ui_page "nui://jo_libs/nui/menu/index.html" inside your fxmanifest.lua')
  eprint('WARNING ! NUI page is not defined. To use JO Menu, add ui_page "nui://jo_libs/nui/menu/index.html" inside your fxmanifest.lua')
  eprint('WARNING ! NUI page is not defined. To use JO Menu, add ui_page "nui://jo_libs/nui/menu/index.html" inside your fxmanifest.lua')
  eprint('WARNING ! NUI page is not defined. To use JO Menu, add ui_page "nui://jo_libs/nui/menu/index.html" inside your fxmanifest.lua')
  eprint('WARNING ! NUI page is not defined. To use JO Menu, add ui_page "nui://jo_libs/nui/menu/index.html" inside your fxmanifest.lua')
end

local menus = {}
local nuiShow = false
local timeoutClose = nil
local radarAlreadyHidden = false
local clockStart = GetGameTimer()
local currentData = {}
local previousData = {}
local NativeSendNUIMessage = SendNUIMessage
local function SendNUIMessage(data)
  if clockStart == GetGameTimer() then Wait(100) end
  NativeSendNUIMessage(data)
end
local disabledKeys = {
  `INPUT_SELECT_NEXT_WEAPON`,
  `INPUT_NEXT_WEAPON`,
  `INPUT_SELECT_PREV_WEAPON`,
  `INPUT_PREV_WEAPON`,
}

if not IsModuleLoaded('table') then
  jo.require('table')
end
if not IsModuleLoaded('timeout') then
  jo.require('timeout')
end

jo.file.load('menu.nui')

---@class MenuClass : table Menu class
local MenuClass = {
  id = "",
  title = "Jump On",
  subtitle = "",
  type = "list",
  items = {},
  numberOnScreen = 8,
  onEnter = function() end,
  onBack = function() end,
  onExit = function() end,
}

local MenuItem = {
  title = '',
  child = false,
  sliders = {},
  price = false,
  data = {},
  visible = true,
  description = '',
  prefix = false,
  statistics = {},
  disabled = false,
  textRight = false,
  onActive = function() end,
  onClick = function() end,
  onChange = function() end,
  onExit = function() end
}

function MenuClass:addItem(item)
  item.index = #self.items + 1
  self.items[#self.items + 1] = table.merge(table.copy(MenuItem), item)
end

function MenuClass:addItems(items)
  for _, item in ipairs(items) do
    self:addItem(item)
  end
end

function MenuClass:refresh()
  local datas = table.clearForNui(self)
  SendNUIMessage({
    event = 'updateMenuData',
    menu = self.id,
    data = datas
  })
end

function MenuClass:reset()
  SendNUIMessage({
    event = "resetMenu",
    menu = self.id
  })
end

function MenuClass:send()
  local datas = table.clearForNui(self)
  SendNUIMessage({
    event = 'updateMenu',
    reset = true,
    menu = datas
  })
end

---@param id string Unique ID of the menu
---@param data? MenuClass
function jo.menu.create(id, data)
  if not id then
    return 'The `id` of the menu is missing'
  end
  menus[id] = table.merge(table.copy(MenuClass), data)
  menus[id] = setmetatable(menus[id], MenuClass)
  menus[id].__index = table.copy(MenuClass)
  menus[id].id = id
  menus[id]:send()
  return menus[id]
end

function jo.menu.delete(id)
  if menus[id] then
    menus[id] = nil
  end
  SendNUIMessage({
    event = "removeMenu",
    menu = id
  })
end

function jo.menu.isOpen()
  return nuiShow
end

---@param id string ID of the next menu
---@param keepHistoric? boolean Keep the menu historic (default: true)
---@param resetMenu? boolean Clear the menu before draw it (default: true)
function jo.menu.setCurrentMenu(id, keepHistoric, resetMenu)
  keepHistoric = (keepHistoric == nil) and true or keepHistoric
  resetMenu = (resetMenu == nil) and true or resetMenu
  SendNUIMessage({
    event = 'setCurrentMenu',
    menu = id,
    keepHistoric = keepHistoric,
    reset = resetMenu
  })
end

function LoopDisableKeys()
  while nuiShow do
    for _,key in pairs (disabledKeys) do
      DisableControlAction(0,key,true)
    end
    Wait(0)
  end
end
jo.timeout.loop(1000,LoopDisableKeys)

---@param show boolean if the menu is show or hiddeng
---@param keepInput? boolean if the game input has to be keep (default: true)
---@param hideRadar? boolean if the radar has to be hide (default: true)
function jo.menu.show(show, keepInput, hideRadar)
  CreateThread(function()
    keepInput = keepInput == nil and true or keepInput
    hideRadar = hideRadar == nil and true or hideRadar
    nuiShow = show
    if timeoutClose then
      timeoutClose:clear()
    end
    if not nuiShow then
      timeoutClose = jo.timeout.set(150, function()
        SetNuiFocus(false, false)
        SendNUIMessage({ event = 'updateShow', show = show })
      end)
    else
      SetNuiFocus(true, true)
      SetNuiFocusKeepInput(keepInput)
      SendNUIMessage({ event = 'updateShow', show = show })
    end
    if show then
      radarAlreadyHidden = IsRadarHidden()
    end
    if not radarAlreadyHidden and hideRadar then
      DisplayRadar(not show)
    end
  end)
end

-------------
-- NUI
-------------

RegisterNUICallback('click', function(data, cb)
  cb('ok')

  if not menus[data.menu] then return end
  if not menus[data.menu].items[data.item.index] then return end

  menus[data.menu].items[data.item.index].onClick(currentData)
end)

RegisterNUICallback('backMenu', function(data, cb)
  cb('ok')

  if not menus[data.menu] then return end

  menus[data.menu].onBack(currentData)
end)

RegisterNUICallback('updatePreview', function(data, cb)
  cb('ok')

  jo.timeout.delay('menuNUIChange', 100, function()
    previousData = table.copy(currentData)

    if not menus[data.menu] then return end
    if not menus[data.menu].items[data.item.index] then return end

    currentData.menu = data.menu
    currentData.index = data.item.index
    -- menus[data.menu].currentItem = data.item.index
    menus[data.menu].items[data.item.index] = table.merge(menus[data.menu].items[data.item.index], data.item)
    currentData.item = menus[data.menu].items[data.item.index]

    for _,slider in pairs (currentData.item.sliders) do
      if slider.type == "switch" then
        slider.value = slider.values[slider.current]
      elseif slider.type == "grid" then
        slider.value = {}
        slider.value[1] = slider.values[1] and slider.values[1].current or nil
        slider.value[2] = slider.values[2] and slider.values[2].current or nil
      else
        slider.value = slider.current
      end
    end

    local button = menus[currentData.menu].items[currentData.index]
    local oldButton = false
    if previousData.menu then
      oldButton = menus[previousData.menu].items[previousData.index]
    end

    if previousData.menu ~= currentData.menu then
      if oldButton then
        oldButton.onExit(currentData)
        menus[previousData.menu].onExit(currentData)
      end
      menus[currentData.menu].onEnter(currentData)
      button.onActive(currentData)
    else
      if previousData.index ~= currentData.index then
        if oldButton then
          oldButton.onExit(currentData)
        end
        button.onActive(currentData)
      else
        button.onChange(currentData)
      end
    end
  end)
end)

-------------
-- BRIDGE OTHER MENU
-------------
local MenuData = {}
local menusOpened = {}

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
    cancel(menu,menu)
    if (GetCurrentResourceName() == "vorp_menu") then
      submit({current = "backup",trigger = data.lastmenu})
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
        table.insert(values,{label = i, value = i})
      end
      if item.value == 0 then
        item.value = 1
      end
      item.sliders = {
        {
          type = 'switch',
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
        table.insert(values,{label = i, value = i})
      end
      nuiMenu.items[i].sliders[1].values = values
    else
      nuiMenu.items[i][key] = val
    end
  end
  -- override all elements
  menu.setElements = function(newElements)
    for _,element in pairs (newElements) do
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
  jo.menu.setCurrentMenu(name,true,true)
  jo.menu.show(true, true, false)
  return menu
end

function MenuData.Close(type, namespace, name)
  jo.menu.show(false)
end

function MenuData.CloseAll()
  jo.menu.show(false)
end

function MenuData.GetOpened(type, namespace, name)
  return {}
end

function MenuData.GetOpenedMenus()
  return {}
end

function MenuData.IsOpen(type, namespace, name)
  return jo.menu.isOpen()
end

function MenuData.ReOpen(oldMenu)
  MenuData.Open(oldMenu.type, oldMenu.namespace, oldMenu.name, oldMenu.data, oldMenu.submit, oldMenu.cancel,
    oldMenu.change, oldMenu.close)
end

jo.menu.bridgeOldMenu = MenuData

return jo.menu
