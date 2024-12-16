jo.menu = {}
jo.menu.exports = {}

jo.require("table")
jo.require("timeout")
jo.require("nui")

CreateThread(function()
  Wait(100)
  if GetResourceMetadata(GetCurrentResourceName(), "ui_page") == "nui://jo_libs/nui/menu/index.html" then
    return
  end
  jo.nui.load("jo_menu", "nui://jo_libs/nui/menu/index.html")
end)

local menus = {}
jo.menu.listeners = {}
local nuiShow = false
local timeoutClose = nil
local radarAlreadyHidden = false
local clockStart = GetGameTimer()
local currentData = {}
local previousData = {}
local NativeSendNUIMessage = SendNUIMessage
local function SendNUIMessage(data)
  if clockStart == GetGameTimer() then Wait(100) end
  data.messageTargetUiName = "jo_menu"
  NativeSendNUIMessage(data)
end
local disabledKeys = {
  `INPUT_SELECT_NEXT_WEAPON`,
  `INPUT_NEXT_WEAPON`,
  `INPUT_SELECT_PREV_WEAPON`,
  `INPUT_PREV_WEAPON`,
}

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
  onChange = function() end
}

local MenuItem = {
  title = "",
  subtitle = "",
  footer = "",
  child = false,
  sliders = {},
  price = false,
  data = {},
  visible = true,
  description = "",
  prefix = false,
  statistics = {},
  disabled = false,
  textRight = false,
  bufferOnChange = true,
  onActive = function() end,
  onClick = function() end,
  onChange = function() end,
  onExit = function() end
}

function MenuClass:addItem(p, item)
  if item == nil then
    item = p
    p = #self.items + 1
  end
  item = table.merge(table.copy(MenuItem), item)
  item.index = p
  table.insert(self.items, p, item)
  return item
end
function jo.menu.addItem(id, p, item) menus[id]:addItem(p, item) end

--- Warning, potential memory leak with addItems methods. Need the be investigate
function MenuClass:addItems(items)
  for _, item in ipairs(items) do
    self:addItem(item)
  end
end
function jo.menu.addItems(id, items) menus[id]:addItems(items) end

function MenuClass:updateItem(index, key, value)
  self.items[index][key] = value
end
function jo.menu.updateItem(id, index, key, value) menus[id]:updateItem(index, key, value) end

function MenuClass:refresh()
  local datas = table.clearForNui(self)
  SendNUIMessage({
    event = "updateMenuData",
    menu = self.id,
    data = datas
  })
  if currentData.menu == self.id then
    currentData.item = self.items[currentData.index]
  end
end
function jo.menu.refresh(id) menus[id]:refresh() end

function MenuClass:reset()
  SendNUIMessage({
    event = "resetMenu",
    menu = self.id
  })
end
function jo.menu.reset(id) menus[id]:reset() end

---@param first? integer pos of the first element to sort (default: 1)
---@param last? integer pos of the last element to sort (default: n)
function MenuClass:sort(first, last)
  local sortFunc = function(i1, i2)
    local title1 = i1.title
    local title2 = i2.title
    return title1 < title2
  end

  first = math.max(1, first or 1)
  last = math.min(#self.items, last or #self.items)

  local sortedTable = {}
  if first == 1 and last == #self.items then
    sortedTable = self.items
  else
    local index = 1
    for i = first, last do
      sortedTable[index] = self.items[i]
      index += 1
    end
  end
  table.sort(sortedTable, sortFunc)

  for i = first, last do
    self.items[i] = sortedTable[i - first + 1]
  end

  for i, item in pairs(self.items) do
    item.index = i
  end
end
function jo.menu.sort(id, first, last) menus[id]:sort(first, last) end

function MenuClass:send(reset)
  local datas = table.clearForNui(self)
  if reset == nil then
    reset = true
  end
  SendNUIMessage({
    event = "updateMenu",
    reset = reset,
    menu = datas
  })
  if currentData.menu == self.id then
    currentData.item = self.items[currentData.index]
  end
end
function jo.menu.send(id) menus[id]:send() end

function MenuClass:use(keepHistoric, resetMenu)
  jo.menu.setCurrentMenu(self.id, keepHistoric, resetMenu)
end

---@param id string Unique ID of the menu
---@param data? MenuClass
function jo.menu.create(id, data)
  if not id then
    return "The `id` of the menu is missing"
  end
  if menus[id] then menus[id] = nil end
  menus[id] = table.merge(table.copy(MenuClass), data)
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
    event = "setCurrentMenu",
    menu = id,
    keepHistoric = keepHistoric,
    reset = resetMenu
  })
end

function LoopDisableKeys()
  while nuiShow do
    for _, key in pairs(disabledKeys) do
      DisableControlAction(0, key, true)
    end
    Wait(0)
  end
end
jo.timeout.loop(1000, LoopDisableKeys)

local function loopMenu()
  CreateThread(function()
    while jo.menu.isOpen() do
      jo.menu.fireAllLevelsEvent("tick")
      jo.menu.fireAllLevelsEvent("onTick")
      Wait(0)
    end
  end)
end

---@param show boolean if the menu is show or hiddeng
---@param keepInput? boolean if the game input has to be keep (default: true)
---@param hideRadar? boolean if the radar has to be hide (default: true)
---@param animation? boolean if the menu has to be show/hide with animation (default: true)
function jo.menu.show(show, keepInput, hideRadar, animation)
  CreateThread(function()
    keepInput = keepInput == nil and true or keepInput
    hideRadar = hideRadar == nil and true or hideRadar
    animation = animation == nil and true or animation
    nuiShow = show
    if timeoutClose then
      timeoutClose:clear()
    end
    if not nuiShow then
      timeoutClose = jo.timeout.set(150, function()
        SetNuiFocus(false, false)
        SendNUIMessage({ event = "updateShow", show = show, cancelAnimation = not animation })
      end)
    else
      SetNuiFocus(true, true)
      SetNuiFocusKeepInput(keepInput)
      SendNUIMessage({ event = "updateShow", show = show, cancelAnimation = not animation })
      loopMenu()
    end
    if show then
      radarAlreadyHidden = IsRadarHidden()
    end
    if not radarAlreadyHidden and hideRadar then
      DisplayRadar(not show)
    end
  end)
end

jo.stopped(function()
  if jo.menu.isOpen() then
    if not radarAlreadyHidden then
      DisplayRadar(true)
    end
  end
end)

---@param lang table list of translated strings
function jo.menu.updateLang(lang)
  SendNUIMessage({
    event = "updateLang",
    lang = lang
  })
end

---@param volume number volume of sound effect 0.0 <> 1.0
function jo.menu.updateVolume(volume)
  SendNUIMessage({
    event = "updateVolume",
    volume = volume
  })
end

function jo.menu.get(id)
  return menus[id]
end

function jo.menu.set(id, menu)
  menus[id] = menu
end

function jo.menu.getCurrentData()
  return currentData
end

function jo.menu.getPreviousData()
  return previousData
end

function jo.menu.getCurrentItem()
  return currentData.item
end

function jo.menu.getCurrentMenu()
  return menus[currentData.menu]
end

function jo.menu.doesActiveButtonChange()
  return currentData.menu ~= previousData.menu or currentData.index ~= previousData.index
end

function jo.menu.forceBack()
  SendNUIMessage({ event = "menuBack" })
end

-------------
-- NUI
-------------

RegisterNUICallback("click", function(data, cb)
  cb("ok")

  if not menus[data.menu] then return end
  if not menus[data.menu].items[data.item.index] then return end

  jo.menu.fireEvent(jo.menu.getCurrentItem(), "onClick")
end)

RegisterNUICallback("backMenu", function(data, cb)
  cb("ok")

  if not menus[data.menu] then return end

  jo.menu.fireEvent(menus[data.menu], "onBack")
end)

function jo.menu.onChange(cb)
  table.insert(jo.menu.listeners, {
    resource = GetInvokingResource() or GetCurrentResourceName(),
    cb = cb
  })
end

AddEventHandler("onResourceStop", function(resourceName)
  local i = 1
  while i <= #jo.menu.listeners do
    if jo.menu.listeners[i].resource == resourceName then
      table.remove(jo.menu.listeners, i)
    else
      i += 1
    end
  end
end)

---@param item table the item to fired
---@param eventName string the name of the event to fired
---@param ... any the argument to send
function jo.menu.fireEvent(item, eventName, ...)
  if not item then return end
  if item[eventName .. "ClientEvent"] then TriggerEvent(item[eventName .. "ClientEvent"], currentData, ...) end
  if item[eventName .. "ServerEvent"] then TriggerServerEvent(item[eventName .. "ServerEvent"], currentData, ...) end
  if item[eventName] then item[eventName](currentData, ...) end
end

function jo.menu.fireAllLevelsEvent(eventName, ...)
  jo.menu.fireEvent(jo.menu.getCurrentMenu(), eventName, ...)
  jo.menu.fireEvent(jo.menu.getCurrentItem(), eventName, ...)
end

local function menuNUIChange(data)
  previousData = table.copy(currentData)

  if not menus[data.menu] then return end
  if not menus[data.menu].items[data.item.index] then return end

  currentData.menu = data.menu
  currentData.index = data.item.index
  -- menus[data.menu].currentItem = data.item.index
  menus[data.menu].items[data.item.index] = table.merge(menus[data.menu].items[data.item.index], data.item)
  currentData.item = menus[data.menu].items[data.item.index]

  for _, slider in pairs(currentData.item.sliders) do
    if slider.type == "grid" then
      slider.value = {}
      slider.value[1] = slider.values[1] and math.floor(slider.values[1].current * 1000) / 1000 or nil
      slider.value[2] = slider.values[2] and math.floor(slider.values[2].current * 1000) / 1000 or nil
    elseif slider.type == "palette" then
      slider.value = slider.current
    else
      slider.value = slider.values[slider.current]
    end
  end

  local oldButton = false
  if previousData.menu then
    oldButton = menus[previousData.menu].items[previousData.index]
  end

  if previousData.menu ~= currentData.menu then
    if oldButton then
      jo.menu.fireEvent(oldButton, "onExit")
      jo.menu.fireEvent(menus[previousData.menu], "onExit")
    end
    jo.menu.fireEvent(menus[currentData.menu], "onEnter")
    jo.menu.fireEvent(currentData.item, "onActive")
  else
    if previousData.index ~= currentData.index then
      if oldButton then
        jo.menu.fireEvent(oldButton, "onExit")
      end
      jo.menu.fireEvent(currentData.item, "onActive")
    else
      jo.menu.fireEvent(currentData.item, "onChange")
    end
    jo.menu.fireEvent(menus[previousData.menu], "onChange")
  end

  for _, listener in ipairs(jo.menu.listeners) do
    listener.cb(currentData)
  end
end

RegisterNUICallback("updatePreview", function(data, cb)
  cb("ok")

  if not menus[data.menu] then return end
  if not menus[data.menu].items[data.item.index] then return end

  local item = menus[data.menu].items[data.item.index]
  if not item.bufferOnChange or table.find(data.item.sliders, function(slider) return slider.type == "grid" end) then
    return menuNUIChange(data)
  end
  jo.timeout.delay("menuNUIChange", 100, function()
    menuNUIChange(data)
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

exports("jo_menu_get", function()
  return jo.menu
end)
exports("jo_menu_get_current_data", function()
  return currentData
end)
