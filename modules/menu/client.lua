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
local menuCreators = {}
jo.menu.listeners = {}
local nuiShow = false
local timeoutClose = nil
local currentMinimapType = GetMinimapType()
local clockStart = GetGameTimer()
local currentData = {}
local previousData = {}
local previousKeepingInput = false
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
  `INPUT_OPEN_WHEEL_MENU`,
  `INPUT_PREV_WEAPON`,
  `INPUT_GAME_MENU_CANCEL`,
  `INPUT_FRONTEND_PAUSE_ALTERNATE`,
}

local function updateSliderCurrentValue(item)
  for i = 1, #item.sliders do
    local slider = item.sliders[i]
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
end

local function menuNUIChange(data)
  if not menus[data.menu] then return end
  if not menus[data.menu].items[data.item.index] then return end

  currentData.menu = data.menu
  currentData.index = data.item.index
  -- menus[data.menu].currentIndex = data.item.index
  menus[data.menu].items[data.item.index] = table.merge(menus[data.menu].items[data.item.index], data.item)
  currentData.item = menus[data.menu].items[data.item.index]

  updateSliderCurrentValue(currentData.item)

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

  previousData = table.copy(currentData)
end

local function missingMenu(id)
  if not menuCreators[id] then
    return eprint("The menu is missing: %s", id)
  end
  menuCreators[id]()
end

---@class MenuClass : table Menu class
---@field id string Menu Unique ID
---@field title string Menu Title
---@field subtitle string Menu Subtitle
---@field type? string Menu type
---@field items? table list of items
---@field numberOnScreen? integer number of items displayed before the scroll
---@field onEnter? function Function fired when the item is pressed
---@field onBack? function Function fired when the backspace is pressed
---@field onExit? function Function fired when the menu is exit
---@field onChange? function Function fired when something is changed in the menu (scroll, switch,...)
local MenuClass = {
  id = "",
  title = "Jump On",
  subtitle = "",
  type = "list",
  items = {},
  numberOnScreen = 8,
  distanceToClose = false,
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

--- Add an item to a menu
---@param p integer|table (Position index or item table if used as single parameter)
---@param item? table (The item to add - if not provided, p is used as the item)
--- item.title string (The item label)
--- item.child? string (The menu to open when Enter is pressed <br> default: false)
--- item.visible? boolean (If the item is visible in the menu <br> default: true)
--- item.data? table (Variable to store custom data in the item)
--- item.description? string (Description text for the item)
--- item.prefix? string (The little icon before the title from `nui\menu\assets\images\icons` folder  ![prefix Icon](/images/previews/menu/prefixIcon.jpg))
--- item.icon? string (The left icon filename from `nui\menu\assets\images\icons` folder  ![Icon](/images/previews/menu/leftIcon.jpg))
--- item.iconRight? string (The right icon filename from `nui\menu\assets\images\icons` folder  ![icon right](/images/previews/menu/iconRight.jpg))
--- item.iconClass? string (CSS class for the icon)
--- item.price? table (The price of the item. Use 0 to display "free" <br> default: false  ![preview price](/images/previews/menu/price.jpg))
--- item.price.money? number (The price in $)
--- item.price.gold? number (The price in gold)
--- item.priceTitle? string (Replace the "Price" label)
--- item.priceRight? boolean (Display the price at the right of the item title  ![price to the right](/images/previews/menu/priceRight.jpg))
--- item.statistics? table (List of [statistics](#statistics) to display for the item)
--- item.disabled? boolean (If the item is disabled (grey) in the menu  ![disable item](/images/previews/menu/disableItem.jpg))
--- item.textRight? string (The label displayed at the right of the item  ![Right text](/images/previews/menu/rightText.jpg))
--- item.previewPalette? boolean (Display a color square at the right of the item <br> default: true  ![preview palette](/images/previews/menu/previewPalette.jpg))
--- item.sliders? table (List of [sliders](#sliders) for the item)
--- item.onActive? function (Fired when the item is selected)
--- item.onClick? function (Fired when Enter is pressed on the item)
--- item.onChange? function (Fired when a slider value changes)
--- item.onExit? function (Fired when the item is exited)
--- item.onTick? function (Fired every tick)
---@return table (The added item)
function MenuClass:addItem(p, item)
  if item == nil then
    item = p
    p = #self.items + 1
  end
  if item.tick then
    item.onTick = item.tick
  end
  item = table.merge(table.copy(MenuItem), item)
  item.index = p
  updateSliderCurrentValue(item)
  table.insert(self.items, p, item)
  if p < #self.items - 1 then
    for i = 1, #self.items do
      if type(self.items[i].index) == "number" then
        self.items[i].index = i
      end
    end
    menuNUIChange({ menu = self.id, item = { index = self.currentIndex } })
  end
  return item
end

--- Add an item to a menu by its ID
---@param id string (The menu ID)
---@param p integer|table (Position index or item table if used as single parameter)
---@param item? table (The item to add - if not provided, p is used as the item)
--- item.title string (The item label)
--- item.child? string (The menu to open when Enter is pressed <br> default: false)
--- item.visible? boolean (If the item is visible in the menu <br> default: true)
--- item.data? table (Variable to store custom data in the item)
--- item.description? string (Description text for the item)
--- item.prefix? string (The little icon before the title from `nui\menu\assets\images\icons` folder  ![prefix Icon](/images/previews/menu/prefixIcon.jpg))
--- item.icon? string (The left icon filename from `nui\menu\assets\images\icons` folder  ![Icon](/images/previews/menu/leftIcon.jpg))
--- item.iconRight? string (The right icon filename from `nui\menu\assets\images\icons` folder  ![icon right](/images/previews/menu/iconRight.jpg))
--- item.iconClass? string (CSS class for the icon)
--- item.price? table (The price of the item. Use 0 to display "free" <br> default: false  ![preview price](/images/previews/menu/price.jpg))
--- item.price.money? number (The price in $)
--- item.price.gold? number (The price in gold)
--- item.priceTitle? string (Replace the "Price" label)
--- item.priceRight? boolean (Display the price at the right of the item title  ![price to the right](/images/previews/menu/priceRight.jpg))
--- item.statistics? table (List of [statistics](#statistics) to display for the item)
--- item.disabled? boolean (If the item is disabled (grey) in the menu  ![disable item](/images/previews/menu/disableItem.jpg))
--- item.textRight? string (The label displayed at the right of the item  ![Right text](/images/previews/menu/rightText.jpg))
--- item.previewPalette? boolean (Display a color square at the right of the item <br> default: true  ![preview palette](/images/previews/menu/previewPalette.jpg))
--- item.sliders? table (List of [sliders](#sliders) for the item)
--- item.onActive? function (Fired when the item is selected)
--- item.onClick? function (Fired when Enter is pressed on the item)
--- item.onChange? function (Fired when a slider value changes)
--- item.onExit? function (Fired when the item is exited)
function jo.menu.addItem(id, p, item) menus[id]:addItem(p, item) end

--- @autodoc:config ignore:true
function MenuClass:addItems(items)
  oprint("Warning : addItems has potential memory leak, use addItem in a loop instead")
  for _, item in ipairs(items) do
    self:addItem(item)
  end
end

--- @autodoc:config ignore:true
function jo.menu.addItems(id, items) menus[id]:addItems(items) end

--- Update a specific property of a menu item
---@param index integer (The index of the item to update)
---@param key string (The property name to update)
---@param value any (The new value for the property)
function MenuClass:updateItem(index, key, value)
  self.items[index][key] = value
end

--- Update a specific property of a menu item by menu ID
---@param id string (The menu ID)
---@param index integer (The index of the item to update)
---@param key string (The property name to update)
---@param value any (The new value for the property)
function jo.menu.updateItem(id, index, key, value) menus[id]:updateItem(index, key, value) end

--- Refresh the menu display without changing the current state
--- Used when menu items have been modified
function MenuClass:refresh()
  local datas = table.clearForNui(self)
  datas.currentIndex = nil
  SendNUIMessage({
    event = "updateMenuData",
    menu = self.id,
    data = datas
  })
  if currentData.menu == self.id then
    currentData.item = self.items[currentData.index]
  end
end

--- Refresh a menu by its ID
---@param id string (The menu ID to refresh)
function jo.menu.refresh(id) menus[id]:refresh() end

--- Reset the menu to its initial state
--- Moves the cursor back to the first item
function MenuClass:reset()
  SendNUIMessage({
    event = "resetMenu",
    menu = self.id
  })
end

--- Reset a menu by its ID
---@param id string (The menu ID to reset)
function jo.menu.reset(id) menus[id]:reset() end

--- Sort menu items alphabetically by title
---@param first? integer (Position of the first element to sort <br> default: `1`)
---@param last? integer (Position of the last element to sort <br> default: `#self.items`)
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
    for i = first, last do
      table.insert(sortedTable, self.items[i])
      if i == self.currentIndex then
        sortedTable[#sortedTable].isCurrentIndex = true
      end
    end
  end
  table.sort(sortedTable, sortFunc)

  for i = first, last do
    self.items[i] = sortedTable[i - first + 1]
  end

  for i = 1, #self.items do
    self.items[i].index = i
    if self.items[i].isCurrentIndex then
      self.currentIndex = i
      self.items[i].iscurrentIndex = nil
    end
  end
end

--- Sort menu items alphabetically by title using menu ID
---@param id string (The menu ID)
---@param first? integer (Position of the first element to sort <br> default: `1`)
---@param last? integer (Position of the last element to sort <br> default: `#self.items`)
function jo.menu.sort(id, first, last) menus[id]:sort(first, last) end

--- Send the menu data to the NUI layer
function MenuClass:send()
  if self.sentToNUI then
    return error("Menu already sent, please use menu:refresh(): " .. self.id)
  end
  local datas = table.clearForNui(self)
  SendNUIMessage({
    event = "updateMenu",
    menu = datas
  })
  self.sentToNUI = true
  if currentData.menu == self.id then
    currentData.item = self.items[currentData.index]
  end
end

--- Send a menu to the NUI layer by its ID
---@param id string (The menu ID)
function jo.menu.send(id) menus[id]:send() end

--- Set this menu as the current active menu
---@param keepHistoric? boolean (Whether to keep navigation history <br> default: `true`)
---@param resetMenu? boolean (Whether to reset the menu state <br> default: `true`)
function MenuClass:use(keepHistoric, resetMenu)
  jo.menu.setCurrentMenu(self.id, keepHistoric, resetMenu)
end

--- Change the current active item index
--- @param index integer (The item index to switch to)
function MenuClass:setCurrentIndex(index)
  self.currentIndex = index
  SendNUIMessage({
    event = "setCurrentIndex",
    menu = self.id,
    index = index
  })
end

--- Create a new menu
---@param id string (Unique ID of the menu)
---@param data? table (Menu configuration data)
--- data.title string (The big title of the menu  ![The menu title](https://docs.jumpon-studios.com/images/previews/menu/bigTitle.jpg))
--- data.subtitle string (The subtitle of the menu  ![The subtitle](https://docs.jumpon-studios.com/images/previews/menu/subtitle.jpg))
--- data.numberOnScreen? integer (Maximum number of items visibles at the same time <br> default : `8`)
--- data.distanceToClose float (Distance at which the menu will self close if the player is moving away <br> default: `false` )
--- data.onEnter? function (Fired when the menu is opened)
--- data.onBack? function (Fired when the backspace/Escape is pressed)
--- data.onExit? function (Fired when the menu is exited)
--- data.onTick? function (Fired every tick)
---@return MenuClass (The newly created menu object)
function jo.menu.create(id, data)
  if not id then
    return "The `id` of the menu is missing"
  end
  if menus[id] then
    if jo.menu.isOpen() and currentData.menu == id then
      jo.menu.fireAllLevelsEvent("onExit")
      previousData = {}
      currentData = {}
    end
    menus[id] = nil
  end
  if data.tick then
    data.onTick = data.tick
  end
  menus[id] = table.merge(table.copy(MenuClass), data)
  menus[id].id = id
  -- menus[id]:send()
  return menus[id]
end

--- Delete a menu from memory
---@param id string (The menu ID to delete)
function jo.menu.delete(id)
  if menus[id] then
    menus[id] = nil
  end
  SendNUIMessage({
    event = "removeMenu",
    menu = id
  })
end

--- Check if a menu exist
---@param id string (the menu ID)
---@return boolean (Returns `true` if the menu exists)
function jo.menu.isExist(id)
  return menus[id] and true or false
end

--- Check if any menu is currently open
---@return boolean (Returns `true` if a menu is open)
function jo.menu.isOpen()
  return nuiShow
end

--- Set a menu as the current active menu
---@param id string (ID of the menu to activate)
---@param keepHistoric? boolean (Keep the menu navigation history <br> default: `true`)
---@param resetMenu? boolean (Clear and redraw the menu before displaying <br> default: `true`)
function jo.menu.setCurrentMenu(id, keepHistoric, resetMenu)
  if not menus[id] then
    return missingMenu(id)
  end
  keepHistoric = (keepHistoric == nil) and true or keepHistoric
  resetMenu = (resetMenu == nil) and true or resetMenu
  if not keepHistoric then
    previousData = {}
  end
  SendNUIMessage({
    event = "setCurrentMenu",
    menu = id,
    keepHistoric = keepHistoric,
    reset = resetMenu
  })
end

local function loopMenu()
  Wait(200)
  -- jo.menu.fireEvent(jo.menu.getCurrentMenu(), "onEnter")
  -- jo.menu.fireEvent(jo.menu.getCurrentItem(), "onActive")
  -- previousData = jo.menu.getCurrentData()
  local ped = PlayerPedId()
  local origin = GetEntityCoords(ped)
  CreateThread(function()
    while jo.menu.isOpen() do
      for i = 1, #disabledKeys do
        DisableControlAction(0, disabledKeys[i], true)
      end
      local menu = jo.menu.getCurrentMenu()
      if menu and menu.distanceToClose then
        if #(GetEntityCoords(ped) - origin) > menu.distanceToClose then
          jo.menu.show(false)
          break
        end
      end
      jo.menu.fireAllLevelsEvent("onTick")
      Wait(0)
    end
    jo.menu.fireAllLevelsEvent("onExit")
    currentData = {}
    previousData = {}
  end)
end

--- Show or hide a menu
---@param show boolean (Whether to show or hide the menu)
---@param keepInput? boolean (Whether to keep game input controls active <br> default: `true`)
---@param hideRadar? boolean (Whether to hide the radar when menu is shown <br> default: `true`)
---@param animation? boolean (Whether to use animation when showing/hiding the menu <br> default: `true`)
---@param hideCursor? boolean (Whether to hide the cursor <br> default: `false`)
function jo.menu.show(show, keepInput, hideRadar, animation, hideCursor)
  if show == nuiShow then return end
  CreateThread(function()
    keepInput = keepInput == nil and true or keepInput
    hideRadar = hideRadar == nil and true or hideRadar
    animation = animation == nil and true or animation
    hideCursor = hideCursor or false

    nuiShow = show
    if timeoutClose then
      timeoutClose:clear()
    end
    if not nuiShow then
      timeoutClose = jo.timeout.set(150, function()
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(previousKeepingInput)
        SendNUIMessage({ event = "updateShow", show = show, cancelAnimation = not animation })
      end)
    else
      previousKeepingInput = IsNuiFocusKeepingInput()
      SetNuiFocus(true, not hideCursor)
      SetNuiFocusKeepInput(keepInput)
      SendNUIMessage({ event = "updateShow", show = show, cancelAnimation = not animation })
      loopMenu()
    end
    if show then
      currentMinimapType = GetMinimapType()
      SetMinimapType(0)
    else
      SetMinimapType(currentMinimapType)
    end
  end)
end

jo.stopped(function()
  if jo.menu.isOpen() then
    SetMinimapType(currentMinimapType)
  end
end)

--- Update menu language text
---@param lang table (List of translated strings)
--- lang.of? string (The bottom right text displaying current item number <br> default : `"%1 of %2"`)
--- lang.selection? string (The "Selection" text <br> default : `"Selection"`)
--- lang.devise? string (The devise text <br> default : `"$"`)
--- lang.number? string (The number text <br> default : `"Number %1"`)
--- lang.free? string (The "Free" text <br> default : `"Free"`)
--- lang.variation? string (The variatio, text <br> default : `"Variation"`)
function jo.menu.updateLang(lang)
  SendNUIMessage({
    event = "updateLang",
    lang = lang
  })
end

--- Set the volume level for menu sound effects
---@param volume number (Volume of sound effects 0.0 to 1.0)
function jo.menu.updateVolume(volume)
  SendNUIMessage({
    event = "updateVolume",
    volume = volume
  })
end

--- Get a menu instance by its ID
---@param id string (The menu ID)
---@return MenuClass (The menu object)
function jo.menu.get(id)
  return menus[id]
end

--- Set or replace a menu instance
---@param id string (The menu ID)
---@param menu MenuClass (The menu object to set)
function jo.menu.set(id, menu)
  menus[id] = menu
end

--- Get data about the current menu state
---@return table (Current menu data including menu ID and selected item)
function jo.menu.getCurrentData()
  return currentData
end

--- Get data about the previous menu state
---@return table (Previous menu data including menu ID and selected item)
function jo.menu.getPreviousData()
  return previousData
end

--- Get the currently selected menu item
---@return table (The currently selected item)
function jo.menu.getCurrentItem()
  return currentData.item
end

--- Get the currently active menu
---@return MenuClass (The currently active menu)
function jo.menu.getCurrentMenu()
  return menus[currentData.menu]
end

--- Check if the active button has changed since last update
---@return boolean (Returns `true` if the active button has changed)
function jo.menu.doesActiveButtonChange()
  return currentData.menu ~= previousData.menu or currentData.index ~= previousData.index
end

--- Force the menu to go back to the previous menu
function jo.menu.forceBack()
  SendNUIMessage({ event = "menuBack" })
end

--- A function to play a NUI sound
---@param sound string sound name from nui/menu/sounds folder
function jo.menu.playAudio(sound)
  SendNUIMessage({
    event = "startAudio",
    sound = sound
  })
end

--- A function to hide temporary the menu and do action
---@param cb function (Action executed before show again the menu)
---@param animation? boolean (Whether to use animation when showing/hiding the menu <br> default: `true`)
function jo.menu.softHide(cb, animation)
  animation = GetValue(animation, true)
  if not cb then return end
  local keepInput = IsNuiFocusKeepingInput()
  local hideCursor = false

  SetNuiFocus(false, false)
  SetNuiFocusKeepInput(false)
  SendNUIMessage({ event = "updateShow", show = false, cancelAnimation = not animation })

  cb()

  SetNuiFocus(true, not hideCursor)
  SetNuiFocusKeepInput(keepInput)
  SendNUIMessage({ event = "updateShow", show = true, cancelAnimation = not animation })
end

-------------
-- NUI
-------------

RegisterNUICallback("click", function(data, cb)
  cb("ok")

  if not menus[data.menu] then return eprint("Menu doesn't exist", data.menu) end
  if not menus[data.menu].items[data.item.index] then return eprint("Item doesn't exist", data.item.index) end

  jo.menu.fireEvent(jo.menu.getCurrentItem(), "onClick")
end)

RegisterNUICallback("backMenu", function(data, cb)
  cb("ok")

  if not menus[data.menu] then return end

  jo.menu.fireEvent(menus[data.menu], "onBack")
end)

RegisterNuiCallback("missingMenu", function(data, cb)
  cb("ok")

  missingMenu(data.menu)
end)

--- Register a handler for missing menu error
---@param id string (The menu ID)
---@param callback function (The handler function)
function jo.menu.missingMenuHandler(id, callback)
  menuCreators[id] = callback
end

--- Register a callback function for menu change events
---@param cb function (The callback function to register)
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

--- Fire an event for a specific menu item
---@param item table (The item to trigger the event on)
---@param eventName string (The name of the event to fire)
---@param ...? any (Additional arguments to pass to the event handler)
function jo.menu.fireEvent(item, eventName, ...)
  if not item then return end
  if item[eventName .. "ClientEvent"] then TriggerEvent(item[eventName .. "ClientEvent"], currentData, ...) end
  if item[eventName .. "ServerEvent"] then TriggerServerEvent(item[eventName .. "ServerEvent"], currentData, ...) end
  if item[eventName] then item[eventName](currentData, ...) end
end

--- Fire an event across all menu levels (current menu and current item)
---@param eventName string (The name of the event to fire)
---@param ...? any (Additional arguments to pass to the event handlers)
function jo.menu.fireAllLevelsEvent(eventName, ...)
  jo.menu.fireEvent(jo.menu.getCurrentMenu(), eventName, ...)
  jo.menu.fireEvent(jo.menu.getCurrentItem(), eventName, ...)
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

jo.menu.bridgeOldMenu = MenuData

exports("jo_menu_get", function()
  return jo.menu
end)
exports("jo_menu_get_current_data", function()
  return currentData
end)
