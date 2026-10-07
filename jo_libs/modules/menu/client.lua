jo.menu.exports = {}
jo.require("timeout")
jo.require("nui")
jo.require("string")

local nuiLoaded = false
local menuNuiChangeInProgress = false

CreateThread(function()
  Wait(100)
  if GetResourceMetadata(GetCurrentResourceName(), "ui_page") == "nui://jo_libs/nui/menu/index.html" then
    nuiLoaded = true
    return
  end
  jo.nui.load("jo_menu", "nui://jo_libs/nui/menu/index.html")
  Wait(500)
  nuiLoaded = true
end)

local menus = {}
local menuCreators = {}
jo.menu.listeners = {}
local nuiShow = false
local softHidden = false
local timeoutClose = nil
local currentMinimapType = GetMinimapType()
local currentData = {}
local previousData = {}
local previousKeepingInput = false
local NativeSendNUIMessage = SendNUIMessage
local function SendNUIMessage(data)
  while not nuiLoaded do
    Wait(0)
  end
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
  if not item or not item.sliders then return end
  for i = 1, #item.sliders do
    local slider = item.sliders[i]
    if slider then
      if slider.type == "grid" then
        slider.value = {}
        slider.value[1] = slider.values[1] and math.floor(slider.values[1].current * 1000) / 1000 or nil
        slider.value[2] = slider.values[2] and math.floor(slider.values[2].current * 1000) / 1000 or nil
      elseif slider.type == "palette" then
        slider.value = slider.current
      elseif slider.values then
        slider.value = slider.values[slider.current]
      end
    end
  end
end

local function menuNUIChange(data)
  if not menus[data.menu] then return end
  -- if not menus[data.menu].items[data.item.index] then return end

  currentData.menu = data.menu
  if data.index then
    menus[data.menu].currentIndex = data.index
    menus[data.menu].items[data.index] = table.merge(menus[data.menu].items[data.index], data.item)
    currentData.item = menus[data.menu].items[data.index]
    currentData.index = menus[data.menu].currentIndex

    updateSliderCurrentValue(currentData.item)
  else
    currentData.index = 0
    currentData.item = {}
  end

  if not jo.menu.doesActiveButtonChange() and currentData.item.sliders then
    for i = 1, #currentData.item.sliders do
      local current = currentData.item.sliders[i].current
      local oldCurrent = previousData.item.sliders[i]?.current or 0
      currentData.item.sliders[i].changed = current ~= oldCurrent
    end
  end

  local waiter = function()
    while menuNuiChangeInProgress do Wait(10) end
  end

  if not currentData.item.bufferOnChange or table.find(currentData.item.sliders, function(slider) return slider.type == "grid" end) then
    waiter = function() while menuNuiChangeInProgress do Wait(0) end end
  end

  jo.timeout.noSpam("menuNUIChange", waiter, function()
    menuNuiChangeInProgress = true

    -- Snapshot: currentData is overwritten by newer NUI events while this
    -- callback yields, and previousData must match the data fired here
    local current = { menu = currentData.menu, index = currentData.index, item = currentData.item }

    local oldButton = false
    if previousData.menu then
      oldButton = previousData.item
    end

    if previousData.menu ~= current.menu or data.forceMenuEvent then
      if oldButton then
        jo.menu.fireEvent(oldButton, "onExit")
        jo.menu.fireEvent(menus[previousData.menu], "onExit")
      end
      jo.menu.fireEvent(menus[current.menu], "onEnter")
      jo.menu.fireEvent(current.item, "onActive")
    else
      if previousData.index ~= current.index or data.forceItemEvent then
        if oldButton then
          jo.menu.fireEvent(oldButton, "onExit")
        end
        jo.menu.fireEvent(current.item, "onActive")
      else
        jo.menu.fireEvent(current.item, "onChange")
      end
      jo.menu.fireEvent(menus[previousData.menu], "onChange")
    end

    for i = 1, #jo.menu.listeners do
      jo.menu.listeners[i].cb(current)
    end

    previousData = table.copy(current)
    menuNuiChangeInProgress = false
  end)
end

local function missingMenu(id)
  if not menuCreators[id] then
    return eprint("The menu is missing: %s", id)
  end
  CreateThreadNow(menuCreators[id])
end

local function clearDataForNui(data)
  local newData = table.clearForNui(data)
  newData.onBeforeEnter = data.onBeforeEnter and true or nil
  return newData
end

---@class MenuClass : table Menu class
---@field id string Unique ID of the menu
---@field title string The big title of the menu
---@field subtitle string The subtitle of the menu
---@field type? string The menu type: `list` or `tile`
---@field items? MenuItemClass[] The list of items
---@field currentIndex? integer The index of the active item
---@field numberOnScreen? integer `list` menu: number of items displayed before the scroll
---@field distanceToClose? number|false Distance from where the menu closes itself
---@field onBeforeEnter? function Fired before the menu is displayed
---@field onEnter? function Fired when the menu becomes the current menu
---@field onBack? function Fired when Backspace or Escape is pressed
---@field onExit? function Fired when the menu is no longer the current menu
---@field onChange? function Fired when the active item or a slider changes in the menu
---@field onTick? function Fired every frame while the menu is the current menu
local MenuClass = {
  id = "",
  title = "Jump On",
  subtitle = "",
  type = "list",
  items = {},
  updatedValues = {},
  numberOnScreen = 8,
  currentIndex = 1,
  distanceToClose = false,
  onBeforeEnter = nil,
  onEnter = nil,
  onBack = nil,
  onExit = nil,
  onChange = nil
}

---@class MenuItemClass : table Menu item class
---@field index integer The position of the item in the menu
---@field title string The item label
---@field subtitle string The line displayed under the title
---@field footer string The text displayed at the bottom of the menu
---@field description string The text displayed in the description area
---@field child string|boolean The ID of the menu opened on click
---@field sliders table The list of sliders
---@field statistics table The list of statistics
---@field price table|boolean The price of the item
---@field data table Your own data
---@field visible boolean If the item is displayed
---@field disabled boolean If the item is greyed out
---@field prefix string|boolean The small icon before the title
---@field icon? string The icon on the left of the item
---@field iconRight? string The icon on the right of the item
---@field textRight string|boolean The text on the right of the item
---@field bufferOnChange boolean Group the fast `onChange` events
---@field onActive function Fired when the item becomes active
---@field onClick function Fired when the item is clicked
---@field onChange function Fired when a slider changes
---@field onExit function Fired when the item is no longer active
---@field onTick? function Fired every frame while the item is active
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

--- Format the price of the item
local function formatItemPrice(item)
  if not item.price then return end
  if type(item.price) ~= "table" then return end
  if table.type(item.price) ~= "array" then return end
  for i = 1, #item.price do
    local price = item.price[i]
    if price.item then
      jo.require("framework")
      local loaderOn = false
      if table.isEmpty(jo.framework.inventoryItems) then
        jo.menu.displayLoader()
        loaderOn = true
      end
      price = jo.menu.formatPrice(price)
      if loaderOn then
        SetTimeout(100, jo.menu.hideLoader)
      end
    end
  end
end

--- Update a property of the item. Call `MenuClass:push()` to send the changes to the NUI
--- Only works on an item returned by `MenuClass:addItem()`
---@param keys string|table (The property name, or the path to a nested property like `{"sliders", 1, "current"}`)
---@param value any (The new value)
function MenuItem:updateValue(keys, value)
  local menu = self:getParentMenu()
  if type(keys) ~= "table" then keys = { keys } end
  table.insert(keys, 1, self.index)
  table.insert(keys, 1, "items")
  menu:updateValue(keys, value)
  if not jo.menu.doesActiveButtonChange() then
    previousData = table.copy(currentData)
  end
end

--- Delete a property of the item. Call `MenuClass:push()` to send the changes to the NUI
--- Only works on an item returned by `MenuClass:addItem()`
---@param keys string|table (The property name, or the path to a nested property like `{"sliders", 2}`)
function MenuItem:deleteValue(keys)
  if type(keys) ~= "table" then keys = { keys } end
  local menu = self:getParentMenu()
  table.insert(keys, 1, self.index)
  table.insert(keys, 1, "items")
  menu:deleteValue(keys)
end

--- Get the menu the item belongs to
--- Only works on an item returned by `MenuClass:addItem()`
---@return MenuClass (The parent menu)
function MenuItem:getParentMenu()
  return {}
end

--- Add an item to the menu. Call `MenuClass:send()` to send the menu to the NUI
---@param index integer|table (The position of the item in the menu, or the item itself to add it at the end)
---@param item? table (The item to add, when `index` is a position)
--- item.title string (The item label. HTML is allowed)
--- item.subtitle? string (A second line displayed under the title)
--- item.description? string (The text displayed in the description area, under the list. HTML is allowed)
--- item.footer? string (The text displayed at the bottom of the menu. HTML is allowed)
--- item.child? string (The ID of the menu opened when the item is clicked <br> default: `false`)
--- item.visible? boolean (If `false`, the item is not displayed <br> default: `true`)
--- item.disabled? boolean (Grey out the item: it can't be clicked and its sliders are hidden <br> default: `false`)
--- item.data? table (Free storage for your own data, available in the callbacks with `currentData.item.data`)
--- item.icon? string (The icon on the left of the item: a filename of `nui/menu/assets/images/icons` (without `.png`) or a full image URL)
--- item.iconClass? string (CSS classes applied to the icon, like `fgold` or `bw`. See [CSS classes](./menus#css-classes))
--- item.iconSize? string (`"small"` to reduce the size of the icon <br> default: `"normal"`)
--- item.iconRight? string (An icon displayed on the right of the item. In a `tile` menu, it's displayed in the bottom right corner of the tile)
--- item.prefix? string (A small icon displayed before the title)
--- item.textRight? string (A text displayed on the right of the item)
--- item.textRightClass? string (CSS classes applied to `textRight`, like `tiny`)
--- item.image? string|table (An image displayed in the description area: a URL or `{url, width, height, radius, style}`)
--- item.color? string|table (The CSS color of the title, or a table `{title, background, accent, icon}`. See [Colors](./items#colors))
--- item.price? number|table (The price displayed under the description. See [Prices](./items#prices) <br> default: `false`)
--- item.priceTitle? string (Replace the "Price" label above the price)
--- item.priceRight? boolean|number|table (Display a price on the right of the item: `true` to display `item.price`, or a price value)
--- item.statistics? table (The list of statistics displayed in the description area. See [Statistics](./statistics))
--- item.sliders? table (The list of sliders of the item. See [Sliders](./sliders))
--- item.previewPalette? boolean (Display a square with the current color of the sliders on the right of the item <br> default: `false`)
--- item.quantity? number (In a `tile` menu, a number displayed in a circle in the top right corner of the tile)
--- item.quantityCircleClass? string (CSS classes applied to the quantity circle, like `fgold`)
--- item.quality? integer (In a `tile` menu, a quality from `1` to `3` displayed with stars)
--- item.qualityClass? string (CSS classes applied to the quality stars)
--- item.stars? table (In a `tile` menu, a row of stars: `{current, total}`)
--- item.starsClass? string (CSS classes applied to the row of stars)
--- item.tilePadding? number|string (In a `tile` menu, the space between the image and the edge of the tile: a number in vh, or a CSS length. `0` brings the image to the edge <br> default: `1.2`)
--- item.translate? boolean (Use `title` as a key of the translation strings. See [jo.menu.updateLang()](#jo-menu-updatelang) <br> default: `false`)
--- item.translateDescription? boolean (Use `description` as a key of the translation strings <br> default: `false`)
--- item.translateTextRight? boolean (Use `textRight` as a key of the translation strings <br> default: `false`)
--- item.bufferOnChange? boolean (Wait a few milliseconds between two `onChange` events of fast slider moves. `false` fires them on the next frame <br> default: `true`)
--- item.onActive? function (Fired when the item becomes the active item)
--- item.onClick? function (Fired when the item is clicked or Enter is pressed)
--- item.onChange? function (Fired when a slider of the item changes)
--- item.onExit? function (Fired when the item is no longer the active item)
--- item.onTick? function (Fired every frame while the item is active)
---@return MenuItemClass (The added item)
function MenuClass:addItem(index, item)
  if item == nil then
    item = index
    index = #self.items + 1
  end
  if item.tick then
    item.onTick = item.tick
  end
  item = table.merge(table.copy(MenuItem), item)
  item.index = index
  updateSliderCurrentValue(item)
  formatItemPrice(item)
  table.insert(self.items, index, item)
  if index < #self.items then
    for i = 1, #self.items do
      if type(self.items[i].index) == "number" then
        self.items[i].index = i
      end
    end
  end

  local menu = self

  ---@autodoc:config ignore:true
  function item:getParentMenu()
    return menu
  end

  return item
end

--- Add an item to a menu from its ID. Same as `MenuClass:addItem()`
---@param id string (The menu ID)
---@param p integer|table (The position of the item in the menu, or the item itself to add it at the end)
---@param item? table (The item to add, when `p` is a position. See [MenuClass:addItem()](#menuclass-additem) for the keys)
function jo.menu.addItem(id, p, item) menus[id]:addItem(p, item) end

--- Overwrite a property of an item from the menu ID. The NUI is not updated
---@deprecated since v2.3.0. Use MenuClass:updateValue() or MenuItem:updateValue() then MenuClass:push() instead
---@param id string (The menu ID)
---@param index integer (The index of the item to update)
---@param key string (The property name to update)
---@param value any (The new value for the property)
function jo.menu.updateItem(id, index, key, value) menus[id]:updateItem(index, key, value) end

--- Update a property of the menu or of one of its items. Call `MenuClass:push()` to send the changes to the NUI
--- `price` and `priceRight` values are formatted automatically
---@param keys string|table (The property name, or the path to a nested property like `{"items", 2, "title"}`)
---@param value any (The new value)
---@return boolean (Always `true`)
function MenuClass:updateValue(keys, value)
  if type(keys) ~= "table" then keys = { keys } end
  if keys[#keys] == "price" or (keys[#keys] == "priceRight" and type(value) ~= "boolean") then
    value = jo.menu.formatPrice(value)
  end
  local v = table.copy(value)
  table.upsert(self, keys, v)
  table.insert(self.updatedValues, {
    keys = keys,
    action = "update",
    value = v
  })
  return true
end

--- Delete a property of the menu or of one of its items. Call `MenuClass:push()` to send the changes to the NUI
--- `{"items", index}` deletes the item, like `MenuClass:deleteItem()`
---@param keys string|table (The property name, or the path to a nested property like `{"items", 2, "price"}`)
function MenuClass:deleteValue(keys)
  if type(keys) ~= "table" then keys = { keys } end
  if (#keys == 2 and keys[1] == "items") then
    self:deleteItem(keys[2])
    return
  end
  table.insert(self.updatedValues, {
    keys = keys,
    action = "delete"
  })
  table.deleteDeepValue(self, keys)
end

--- Delete an item of the menu and update the index of the next items. Call `MenuClass:push()` to send the changes to the NUI
---@param index integer (The index of the item to delete)
function MenuClass:deleteItem(index)
  table.remove(self.items, index)
  table.insert(self.updatedValues, {
    keys = { "items", index },
    action = "delete"
  })
  for i = index, #self.items do
    self.items[i].index = i
    table.insert(self.updatedValues, {
      action = "update",
      keys = { "items", i, "index" },
      value = i
    })
  end
  if (jo.menu.isCurrentMenu(self.id)) and self.currentIndex == index then
    table.insert(self.updatedValues, {
      keys = { "currentIndex" },
      action = "update",
      value = index
    })
  end
end

--- Send the whole menu to the NUI again, without changing the active item
--- Use it after big changes, like items added or sorted after `MenuClass:send()`
--- If the menu is the current menu, `onExit` and `onActive` of the active item are fired again
function MenuClass:refresh()
  local datas = clearDataForNui(self)
  datas.currentIndex = nil
  SendNUIMessage({
    event = "updateMenuData",
    menu = self.id,
    data = datas
  })
  if self.currentIndex > #self.items then
    self:setCurrentIndex(#self.items)
  end
  self.currentIndex = math.min(self.currentIndex, #self.items)
  if jo.menu.isCurrentMenu(self.id) then
    jo.menu.runRefreshEvents(false, true)
  end
end

--- Send to the NUI the changes made with `updateValue()`, `deleteValue()` and `deleteItem()`
function MenuClass:push()
  if not self.updatedValues then return end
  if table.isEmpty(self.updatedValues) then return end

  if jo.menu.isCurrentMenu(self.id) then
    local newIndex = math.min(self.currentIndex, #self.items)
    if newIndex ~= self.currentIndex then
      self.currentIndex = newIndex
      table.insert(self.updatedValues, {
        keys = { "currentIndex" },
        action = "update",
        value = newIndex
      })
    end
  end

  local updated = clearDataForNui(self.updatedValues)
  SendNUIMessage({
    event = "updateMenuValues",
    menu = self.id,
    updated = updated
  })

  self.updatedValues = {}
end

--- Refresh a menu from its ID. Same as `MenuClass:refresh()`
---@param id string (The menu ID)
function jo.menu.refresh(id) menus[id]:refresh() end

--- Move the cursor of the menu back to the first item
function MenuClass:reset()
  SendNUIMessage({
    event = "resetMenu",
    menu = self.id
  })
end

--- Reset a menu from its ID. Same as `MenuClass:reset()`
---@param id string (The menu ID)
function jo.menu.reset(id) menus[id]:reset() end

--- Sort the items alphabetically by title
--- Call `MenuClass:refresh()` (or `MenuClass:send()` if the menu has never been sent) to display the new order
---@param first? integer (The position of the first item to sort <br> default: `1`)
---@param last? integer (The position of the last item to sort <br> default: the last item)
function MenuClass:sort(first, last)
  local sCompare = string.compare
  local function sortFunc(i1, i2)
    return sCompare(i1.title, i2.title) < 0
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

--- Sort the items of a menu from its ID. Same as `MenuClass:sort()`
---@param id string (The menu ID)
---@param first? integer (The position of the first item to sort <br> default: `1`)
---@param last? integer (The position of the last item to sort <br> default: the last item)
function jo.menu.sort(id, first, last) menus[id]:sort(first, last) end

--- Send the menu to the NUI. Call it once the items are added
--- If the menu has already been sent, it's refreshed (see `MenuClass:refresh()`)
function MenuClass:send()
  if self.sentToNUI then
    self:refresh()
    return
  end
  local datas = clearDataForNui(self)
  SendNUIMessage({
    event = "updateMenu",
    menu = datas
  })
  self.sentToNUI = true
  if currentData.menu == self.id then
    currentData.item = self.items[currentData.index]
  end
end

--- Send a menu to the NUI from its ID. Same as `MenuClass:send()`
---@param id string (The menu ID)
function jo.menu.send(id) menus[id]:send() end

--- Set the menu as the current menu. Same as `jo.menu.setCurrentMenu()`
---@param keepHistoric? boolean (Keep the previous menu in the history, to go back to it with Backspace <br> default: `true`)
---@param resetMenu? boolean (Move the cursor back to the first item <br> default: `true`)
function MenuClass:use(keepHistoric, resetMenu)
  jo.menu.setCurrentMenu(self.id, keepHistoric, resetMenu)
end

--- Move the cursor to an item
---@param index integer (The index of the item)
function MenuClass:setCurrentIndex(index)
  self.currentIndex = index
  SendNUIMessage({
    event = "setCurrentIndex",
    menu = self.id,
    index = index
  })
end

--- Create a new menu. If a menu with the same ID exists, it's replaced
--- Add the items with `MenuClass:addItem()`, then send the menu to the NUI with `MenuClass:send()`
---@param id string (Unique ID of the menu)
---@param data table (The menu configuration)
--- data.title? string (The big title of the menu. HTML is allowed <br> default: `"Jump On"`)
--- data.subtitle? string (The subtitle of the menu, displayed above the items. HTML is allowed <br> default: `""`)
--- data.type? string (The type of menu: `list` or `tile` <br> default: `"list"`)
--- data.numberOnScreen? integer (`list` menu: number of items displayed before the scroll. Maximum `13` <br> default: `8`)
--- data.numberOnLine? integer (`tile` menu: number of tiles per line <br> default: `4`)
--- data.numberLineOnScreen? integer (`tile` menu: number of lines displayed before the scroll <br> default: `6`)
--- data.image? string|table (An image displayed above the items: a URL or `{url, width, height, radius, style}`)
--- data.displayBackButton? boolean (Display the back arrow next to the subtitle, even without history <br> default: `false`)
--- data.hideBackground? boolean (Hide the dark background behind the menu <br> default: `false`)
--- data.price? number|table (The price displayed when the active item has no price. See [Prices](./items#prices))
--- data.priceTitle? string (Replace the "Price" label of `data.price`)
--- data.distanceToClose? number (The menu closes itself when the player moves further than this distance <br> default: `false`)
--- data.translateTitle? boolean (Use `title` as a key of the translation strings <br> default: `false`)
--- data.translateSubtitle? boolean (Use `subtitle` as a key of the translation strings <br> default: `false`)
--- data.onBeforeEnter? function (Fired before the menu is displayed. The NUI waits for the end of the function)
--- data.onEnter? function (Fired when the menu becomes the current menu)
--- data.onBack? function (Fired when Backspace or Escape is pressed)
--- data.onExit? function (Fired when the menu is no longer the current menu)
--- data.onChange? function (Fired when the active item or a slider changes in the menu)
--- data.onTick? function (Fired every frame while the menu is the current menu)
---@return MenuClass (The new menu)
function jo.menu.create(id, data)
  if not id then
    return "The `id` of the menu is missing"
  end
  if menus[id] then
    if jo.menu.isOpen() and currentData.menu == id then
      jo.menu.fireAllLevelsEvent("onExit")
      -- previousData = {}
      -- currentData = {}
    end
    menus[id] = nil
  end
  if data.tick then
    data.onTick = data.tick
  end
  menus[id] = table.merge(table.copy(MenuClass), data)
  menus[id].numberOnScreen = math.min(data.numberOnScreen or 8, 13)
  menus[id].id = id
  -- menus[id]:send()
  return menus[id]
end

--- Create a new menu, only if no menu exists with this ID
--- Returns two values: the menu (the new one or the existing one) and `true` if the menu was created
---@param id string (Unique ID of the menu)
---@param data table (The menu configuration. See [jo.menu.create()](#jo-menu-create))
---@return MenuClass (The menu)
function jo.menu.createIfNotExist(id, data)
  if jo.menu.isExist(id) then
    return jo.menu.get(id), false
  end
  return jo.menu.create(id, data), true
end

--- Delete a menu, in Lua and in the NUI
---@param id string (The menu ID)
function jo.menu.delete(id)
  if menus[id] then
    menus[id] = nil
  end
  SendNUIMessage({
    event = "removeMenu",
    menu = id
  })
end

--- Check if a menu exists
---@param id string (The menu ID)
---@return boolean (Returns `true` if the menu exists)
function jo.menu.isExist(id)
  return menus[id] and true or false
end

--- Check if the menu is displayed
---@return boolean (Returns `true` if the menu is displayed)
function jo.menu.isOpen()
  return nuiShow
end

--- Set the current menu: the one displayed by `jo.menu.show()`
--- If the menu doesn't exist, the handler registered with `jo.menu.missingMenuHandler()` is called
---@param id string (The menu ID)
---@param keepHistoric? boolean (Keep the previous menu in the history, to go back to it with Backspace <br> default: `true`)
---@param resetMenu? boolean (Move the cursor back to the first item <br> default: `true`)
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

--- Show or hide the current menu
--- While the menu is displayed, the radar is hidden and the weapon wheel and pause menu controls are disabled
---@param show boolean (`true` to show the menu, `false` to hide it)
---@param keepInput? boolean (Keep the game controls active, to move the player while the menu is open <br> default: `true`)
---@param hideRadar? boolean (Unused: the radar is always hidden while the menu is displayed <br> default: `true`)
---@param playMenuAnimation? boolean (Play the open/close animation <br> default: `true`)
---@param hideCursor? boolean (Hide the mouse cursor <br> default: `false`)
function jo.menu.show(show, keepInput, hideRadar, playMenuAnimation, hideCursor)
  if show == nuiShow then return end
  CreateThread(function()
    keepInput = keepInput == nil and true or keepInput
    hideRadar = hideRadar == nil and true or hideRadar
    playMenuAnimation = playMenuAnimation == nil and true or playMenuAnimation
    hideCursor = hideCursor or false

    nuiShow = show
    if timeoutClose then
      timeoutClose:clear()
    end
    if not nuiShow then
      timeoutClose = jo.timeout.set(150, function()
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(previousKeepingInput)
        SendNUIMessage({ event = "updateShow", show = show, cancelAnimation = not playMenuAnimation })
      end)
    else
      previousKeepingInput = IsNuiFocusKeepingInput()
      SetNuiFocus(true, not hideCursor)
      SetNuiFocusKeepInput(keepInput)
      SendNUIMessage({ event = "updateShow", show = show, cancelAnimation = not playMenuAnimation })
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

--- Translate the texts of the menu
--- You can also add your own keys, used by the `translate*` options of the menus, items and sliders
---@param lang table (The translated strings, by key)
--- lang.of? string (The counter of the items and sliders. `%1` is the current position, `%2` the total <br> default: `"%1 of %2"`)
--- lang.price? string (The label above the price <br> default: `"Price"`)
--- lang.devise? string (The currency symbol <br> default: `"$"`)
--- lang.free? string (The text displayed when the price is `0` <br> default: `"Free"`)
--- lang.number? string (The title of an item without title. `%1` is the item position <br> default: `"Number %1"`)
function jo.menu.updateLang(lang)
  SendNUIMessage({
    event = "updateLang",
    lang = lang
  })
end

--- Set the volume of the menu sounds
---@param volume number (The volume, from `0.0` to `1.0` <br> default: `0.5`)
function jo.menu.updateVolume(volume)
  SendNUIMessage({
    event = "updateVolume",
    volume = volume
  })
end

--- Get a menu from its ID
---@param id string (The menu ID)
---@return MenuClass (The menu object)
function jo.menu.get(id)
  return menus[id]
end

--- Replace the menu stored with this ID
---@param id string (The menu ID)
---@param menu MenuClass (The menu)
function jo.menu.set(id, menu)
  menus[id] = menu
end

--- Get the current state of the menu: the data passed to all the callbacks
---@return table (`{menu = menuID, index = activeItemIndex, item = activeItem}`)
function jo.menu.getCurrentData()
  return currentData
end

--- Get the state of the menu before the last change
---@return table (`{menu = menuID, index = activeItemIndex, item = activeItem}`)
function jo.menu.getPreviousData()
  return previousData
end

--- Get the active item of the current menu
---@return MenuItemClass (The active item)
function jo.menu.getCurrentItem()
  return currentData.item
end

--- Get the current menu
---@return MenuClass (The current menu)
function jo.menu.getCurrentMenu()
  return menus[currentData.menu]
end

--- Check if the active item (or the menu) changed during the last update
--- Useful in `onChange` callbacks, to know if a slider moved or if the cursor moved
---@return boolean (Returns `true` if the active item changed)
function jo.menu.doesActiveButtonChange()
  return currentData.menu ~= previousData.menu or currentData.index ~= previousData.index
end

--- Go back to the previous menu of the history, like Backspace
function jo.menu.forceBack()
  SendNUIMessage({ event = "menuBack" })
end

--- Play a sound of the menu
---@param sound string (The sound name: `button`, `coins`, `menu_open`, `menu_close` or `selected`)
function jo.menu.playAudio(sound)
  SendNUIMessage({
    event = "startAudio",
    sound = sound
  })
end

--- Hide the menu during the execution of a function, then display it again
--- The function is executed synchronously: `jo.menu.softHide()` returns once the menu is displayed again
---@param cb function (The function executed while the menu is hidden)
---@param playMenuAnimation? boolean (Play the open/close animation <br> default: `true`)
---@param keepBackground? boolean (Keep the dark background of the menu while it's hidden <br> default: `false`)
function jo.menu.softHide(cb, playMenuAnimation, keepBackground)
  playMenuAnimation = GetValue(playMenuAnimation, true)
  keepBackground = GetValue(keepBackground, false)
  if not cb then return end
  softHidden = true
  local keepInput = IsNuiFocusKeepingInput()
  local hideCursor = false

  SetNuiFocus(false, false)
  SetNuiFocusKeepInput(false)
  SendNUIMessage({ event = "updateShow", show = false, cancelAnimation = not playMenuAnimation, keepBackground = keepBackground })

  cb()
  Wait(1)

  SetNuiFocus(true, not hideCursor)
  SetNuiFocusKeepInput(keepInput)
  SendNUIMessage({ event = "updateShow", show = true, cancelAnimation = not playMenuAnimation })
  softHidden = false
end

--- Check if the menu is hidden by `jo.menu.softHide()`
---@return boolean (Returns `true` during the execution of the `jo.menu.softHide()` function)
function jo.menu.isSoftHidden()
  return softHidden
end

--- Check if a menu is the current menu and is displayed
---@param id string (The menu ID)
---@return boolean (Returns `true` if the menu is displayed and is the current one)
function jo.menu.isCurrentMenu(id)
  if not jo.menu.isOpen() then return false end
  return jo.menu.getCurrentMenuId() == id
end

--- Get the index of the active item of the current menu
---@return integer (The index of the active item)
function jo.menu.getCurrentIndex()
  local menu = jo.menu.getCurrentMenu()
  return menu.currentIndex
end

--- Fire the events of the current menu again, as if it was just opened
---@param menuEvent? boolean (Fire `onExit` and `onEnter` of the menu, and `onExit` and `onActive` of the item <br> default: `false`)
---@param itemEvent? boolean (Fire `onExit` and `onActive` of the active item <br> default: `false`)
function jo.menu.runRefreshEvents(menuEvent, itemEvent)
  menuEvent = GetValue(menuEvent, false)
  itemEvent = GetValue(itemEvent, false)
  menuNUIChange({ menu = jo.menu.getCurrentMenuId(), index = jo.menu.getCurrentIndex(), forceMenuEvent = menuEvent, forceItemEvent = itemEvent })
end

--- Get the ID of the current menu
---@return string (The ID of the current menu)
function jo.menu.getCurrentMenuId()
  local menu = jo.menu.getCurrentMenu()
  return menu.id
end

--- Display a loading animation in the menu
---@param value? boolean (`false` to hide the loader <br> default: `true`)
function jo.menu.displayLoader(value)
  value = GetValue(value, true)
  SendNUIMessage({ event = "displayLoader", show = value })
end

--- Hide the loading animation
function jo.menu.hideLoader()
  jo.menu.displayLoader(false)
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

RegisterNUICallback("onBeforeEnter", function(data, cb)
  if menus[data.menu] then
    jo.menu.fireEvent(menus[data.menu], "onBeforeEnter")
  end
  cb("ok")
end)

RegisterNUICallback("messageReceived", function(data, cb)
  messageSending = false
  cb("ok")
end)

RegisterNUICallback("updatePreview", function(data, cb)
  cb("ok")
  menuNUIChange(data)
end)


--- Register a function to create a menu the first time it's needed
--- Called when `jo.menu.setCurrentMenu()` or an item `child` targets this menu ID and the menu doesn't exist
---@param id string (The menu ID)
---@param callback function (The function that creates the menu)
function jo.menu.missingMenuHandler(id, callback)
  menuCreators[id] = callback
end

--- Listen to all the changes of all the menus: active item, sliders, menu
--- The callback receives `{menu, index, item}`. It's unregistered when the resource stops
---@param cb function (The function fired on each change)
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

--- Fire an event of a menu or an item
--- The listeners receive the current data (see `jo.menu.getCurrentData()`) followed by the additional arguments
--- The client and server events defined with `<eventName>ClientEvent` and `<eventName>ServerEvent` keys are triggered too
---@param item table (The menu or the item)
---@param eventName string (The name of the event, like `onClick`)
---@param ...? any (Additional arguments for the listeners)
function jo.menu.fireEvent(item, eventName, ...)
  if not item then return end
  if item[eventName .. "ClientEvent"] then TriggerEvent(item[eventName .. "ClientEvent"], jo.menu.getCurrentData(), ...) end
  if item[eventName .. "ServerEvent"] then TriggerServerEvent(item[eventName .. "ServerEvent"], jo.menu.getCurrentData(), ...) end
  if item[eventName] then item[eventName](jo.menu.getCurrentData(), ...) end
end

--- Fire an event on the current menu, then on its active item
---@param eventName string (The name of the event, like `onTick`)
---@param ...? any (Additional arguments for the listeners)
function jo.menu.fireAllLevelsEvent(eventName, ...)
  jo.menu.fireEvent(jo.menu.getCurrentMenu(), eventName, ...)
  jo.menu.fireEvent(jo.menu.getCurrentItem(), eventName, ...)
end

--------------
-- DEPRECATED FUNCTIONS
-------------

---@deprecated since v2.3.0. Use MenuClass:updateValue() or MenuItem:updateValue() then MenuClass:push() instead
--- Overwrite a property of an item. The NUI is not updated
---@param index integer (The index of the item to update)
---@param key string (The property name to update)
---@param value any (The new value for the property)
function MenuClass:updateItem(index, key, value)
  self.items[index][key] = value
end

--- @autodoc:config ignore:true
---@deprecated since v2.4.0. Use MenuClass:addItem in a loop instead
function MenuClass:addItems(items)
  oprint("Warning : addItems has potential memory leak, use addItem in a loop instead")
  for i = 1, #items do
    local item = items[i]
    self:addItem(item)
  end
end

--- @autodoc:config ignore:true
---@deprecated since v2.4.0. Use MenuClass:addItem in a loop instead
function jo.menu.addItems(id, items) menus[id]:addItems(items) end

---@deprecated since v2.4.0. Use MenuClass:deleteItem() instead
--- Remove an item from the menu, in Lua only
---@param index integer (The index of the item to remove)
function MenuClass:removeItem(index)
  if not index then return eprint("MenuClass:removeItem > index can't be nil") end
  table.remove(self.items, index)
  if index < #self.items then
    for i = 1, #self.items do
      self.items[i].index = i
    end
  end
end

-------------
-- EXPORTS
-------------

exports("jo_menu_get", function()
  return jo.menu
end)

exports("jo_menu_get_current_data", function()
  return currentData
end)
