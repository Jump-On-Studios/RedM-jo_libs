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
local radarAlreadyHidden = false
local clockStart = GetGameTimer()
local currentData = {}
local previousData = {}
local NativeSendNUIMessage = SendNUIMessage
local function SendNUIMessage(data)
  if clockStart == GetGameTimer() then Wait(100) end
  NativeSendNUIMessage(data)
end

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
  translateTitle = false,
  translateSubtitle = false,
  currentItem = 0,
  items = {},
  numberOnScreen = 8,
  disableEscape = false,
  onEnter = function() end,
  onBack = function() end,
  onExit = function() end,
}

local MenuItem = {
  title = '',
  icon = false,
  iconRight = false,
  iconClass = '',
  child = false,
  sliders = false,
  price = false,
  priceTitle = false,
  priceRight = false,
  data = {},
  visible = true,
  description = '',
  translate = false,
  translateDescription = false,
  prefix = false,
  statistics = {},
  disabled = false,
  textRight = false,
  translateTextRight = false,
  previewPalette = true,
  onActive = function() end,
  onClick = function() end,
  onChange = function() end,
  onExit = function() end
}

---@param reset? boolean reset the selector to the first button (default: true)
function MenuClass:refresh(reset)
  reset = reset == nil and true or reset
  local datas = table.clearForNui(self)
  SendNUIMessage({
    event = 'updateMenu',
    reset = reset,
    menu = datas
  })
end

function MenuClass:addItem(item)
  item.index = #self.items + 1
  self.items[#self.items + 1] = table.merge(table.copy(MenuItem), item)
end

function MenuClass:addItems(items)
  for _, item in ipairs(items) do
    self:addItem(item)
  end
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

---@param show boolean if the menu is show or hiddeng
---@param keepInput? boolean if the game input has to be keep (default: true)
---@param hideRadar? boolean if the radar has to be hide (default: true)
function jo.menu.show(show, keepInput, hideRadar)
  CreateThread(function()
    keepInput = keepInput == nil and true or keepInput
    hideRadar = hideRadar == nil and true or hideRadar
    nuiShow = show
    if not nuiShow then
      SetNuiFocus(false, false)
    else
      SetNuiFocus(true, true)
      SetNuiFocusKeepInput(keepInput)
    end
    SendNUIMessage({ event = 'updateShow', show = show })
    if show then
      radarAlreadyHidden = IsRadarHidden()
    end
    if not radarAlreadyHidden and hideRadar then
      DisplayRadar(not show)
    end
  end)
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

function jo.menu.isOpen()
  return nuiShow
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

  jo.timeout:delay('menuNUIChange', 100, function()
    previousData = table.copy(currentData)

    if not menus[data.menu] then return end
    if not menus[data.menu].items[data.item.index] then return end

    currentData.menu = data.menu
    currentData.index = data.item.index
    currentData.item = menus[data.menu].items[data.item.index]

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

function MenuData.Open(type, namespace, name, data, submit, cancel, change, close)
  local menu = {}
  menu.id = name
  menu.title = data.title
  menu.subtitle = data.subtext
  local submit = submit or function() end
  local cancel = cancel or function() end
  local change = change or function() end
  local close = close or function() end
  menu.close = function()
    close(menu)
    if data.lastmenu and menus[data.lastmenu] then
      jo.menu.setCurrentMenu(data.lastmenu,false,false)
    else
      jo.menu.show(false)
      TriggerEvent("menuapi:closemenu")
    end
  end
  menu.onBack = function(data)
    cancel(menu)
  end
  menu.onExit = function(data)
    close(menu)
  end

  jo.menu.delete(name)

  local nuiMenu = jo.menu.create(name, menu)

  for _, element in pairs(data.elements) do
    local item = element
    item.title = item.label
    item.description = item.desc
    item.onActive = function(data)
      change({ current = data.item }, menu)
    end
    item.onChange = function(data)
      change({ current = data.item }, menu)
    end
    item.onClick = function(data)
      submit({ current = data.item }, menu)
    end
    nuiMenu:addItem(item)
  end

  menu.update = function(query, newData)
    nuiMenu:refresh(true)
  end

  menu.addNewElement = function(element)
    local item = element
    item.title = item.label
    item.description = item.desc
    item.onActive = function(data)
      change({ current = data.item }, menu)
    end
    item.onChange = function(data)
      change({ current = data.item }, menu)
    end
    nuiMenu:addItem(item)
    nuiMenu:refresh(true)
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
    nuiMenu:refresh(true)
  end

  menu.setElement = function(i, key, val)
    nuiMenu.items[i][key] = val
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

  nuiMenu:refresh(true)
  jo.menu.setCurrentMenu(name,false,true)
  jo.menu.show(true, false, false)
  return menu
end

function MenuData.Close(type, namespace, name)
  jo.menu.show(false)
end

function MenuData.CloseAll()
  nuiShow = false
  jo.timeout:delay('closeAllMenu', 100, function()
    if not nuiShow then
      jo.menu.show(false)
    end
  end)
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

jo.menu.bridgeVORP = MenuData

return jo.menu
