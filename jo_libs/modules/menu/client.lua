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
  type = "list",
  translateTitle = true,
  currentItem = 0,
  items = {},
  numberOnScreen = 8,
  disableEscape = false,
  onEnter = function() end,
  onBack = function() end,
  onExit = function() end,
}

local MenuItem = {
  title = '';
  icon = false;
  iconRight = false;
  iconClass = '';
  child = false;
  sliders = false;
  price = false;
  priceTitle = false;
  priceRight = false;
  data = {};
  visible = true;
  description = '';
  translate = true;
  translateDescription = true;
  prefix = false;
  statistics = {};
  disabled = false;
  textRight = false;
  translateTextRight = true;
  previewPalette = true;
  onActive = function() end,
  onClick = function() end,
  onChange = function() end,
  onExit = function() end
}

---@param reset? boolean reset the selector to the first button (default: true)
function MenuClass:refresh(reset)
  reset = reset == nil and true or reset
  local items = {}
  for _,item in ipairs (self.items) do
    items[#items+1] = table.map(item, function(value)
      if type(value) == "function" then
        return nil
      end
      return value
    end)
  end
  SendNUIMessage({
    event='updateMenu',
    reset = reset,
    menu= {
      id= self.id,
      title= self.title,
      items= items
    }
  })
end

function MenuClass:addItem(item)
  item.index = #self.items+1
  self.items[#self.items+1] = table.merge(table.copy(MenuItem),item)
end

function MenuClass:addItems(items)
  for _,item in ipairs(items) do
    self:addItem(item)
  end
end

---@param id string Unique ID of the menu
---@param data? MenuClass
function jo.menu.create(id,data)
  if not id then
    return 'The `id` of the menu is missing'
  end
  menus[id] = table.merge(table.copy(MenuClass),data)
  menus[id] = setmetatable(menus[id], MenuClass)
  menus[id].__index = table.copy(MenuClass)
  menus[id].id = id
  return menus[id]
end

---@param show boolean if the menu is show or hiddeng
---@param keepInput? boolean if the game input has to be keep (default: true)
---@param hideRadar? boolean if the radar has to be hide (default: true)
function jo.menu.show(show,keepInput,hideRadar)
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
    SendNUIMessage({event='updateShow',show= show})
    if show then
      radarAlreadyHidden = IsRadarHidden()
    end
    if not radarAlreadyHidden and hideRadar then
      DisplayRadar(not show)
    end
  end)
end

---@param id string ID of the next menu
---@param keepHistoric boolean Keep the menu historic (default: true)
---@param resetMenu boolean Clear the menu before draw it (default: true)
function jo.menu.setCurrentMenu(id,keepHistoric,resetMenu)
  keepHistoric = (keepHistoric == nil) and true or keepHistoric
  resetMenu = (resetMenu == nil) and true or resetMenu
  SendNUIMessage({
    event='setCurrentMenu',
    menu= id,
    keepHistoric = keepHistoric,
    reset = resetMenu
  })
end

-------------
-- NUI
-------------

RegisterNUICallback('close', function(data,cb)
  cb('ok')

end)

RegisterNUICallback('click', function(data,cb)
  cb('ok')

  if not menus[data.menu] then return end
  if not menus[data.menu].items[data.item.index] then return end

  menus[data.menu].items[data.item.index].onClick(data)
end)

RegisterNUICallback('backMenu', function(data,cb)
  cb('ok')

  if not menus[data.menu] then return end

  menus[data.menu].onBack(data)
end)

RegisterNUICallback('updatePreview', function(data,cb)
  cb('ok')

  jo.timeout:delay('menuNUIChange',100,function()
    previousData = table.copy(currentData)

    if not menus[data.menu] then return end
    if not menus[data.menu].items[data.item.index] then return end

    currentData.menu = data.menu
    currentData.index = data.item.index
    
    local button = menus[currentData.menu].items[currentData.index]
    local oldButton = false
    if previousData.menu then
      oldButton = menus[previousData.menu].items[previousData.index]
    end

    if previousData.menu ~= currentData.menu then
      if oldButton then
        oldButton.onExit(data)
        menus[previewData.menu].onExit(data)
      end
      menus[currentData.menu].onEnter(data)
      button.onActive(data)
    else
      if previousData.index ~= currentData.index then
        if oldButton then
          oldButton.onExit(data)
        end
        button.onActive(data)
      else
        button.onChange(data)
      end
    end
  end)
end)

return jo.menu