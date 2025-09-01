---@class FrameworkClass
---@field core table (The link with the framework)
---@field inv table (The link with the inventory)
---@field inventoryItems table (The list of items)
jo.framework = {
  core = {},
  inv = {},
  inventoryItems = {},
}

local frameworkDetected

---@autodoc:config ignore:true
function jo.framework:getFrameworkDetected()
  return frameworkDetected
end

---@autodoc:config ignore:true
function jo.framework:loadFile(...)
  if not frameworkDetected then return false end
  local args = { ... }
  local folder = args[2] and args[1] or frameworkDetected.folder
  local name = args[2] or args[1]
  local path = ("framework-bridge.%s.%s"):format(folder, name)
  if jo.file.isExist(path) then
    return jo.file.load(path)
  end
  return false
end

jo.require("string")

local supportedFrameworks = {
  {
    id = "VORP",
    name = "VORP Framework",
    folder = "vorp",
    resources = { "vorp_core" },
  },
  {
    id = "RedEM",
    name = "RedEM:RP Old Framework",
    folder = "redemrp_old",
    resources = { "redem" },
  },
  {
    id = "RedEM2023",
    name = "RedEM:RP 2023 Framework",
    folder = "redemrp_2023",
    resources = { "!redem", "redem_roleplay" },
  },
  {
    id = "qbr",
    name = "QBCore RedM Edition",
    folder = "qbr",
    resources = { "qbr-core" },
  },
  {
    id = "rsg",
    name = "RSG V1 Framework",
    folder = "rsg",
    resources = { "rsg-core<2.0.0" },
  },
  {
    id = "rsg",
    name = "RSG V2 Framework",
    folder = "rsg_2",
    resources = { "rsg-core>=2.0.0" },
  },
  {
    id = "qr",
    name = "QRCore RedM:Re",
    folder = "qr",
    resources = { "qr-core" },
  },
  {
    id = "rpx",
    name = "RPX Framework",
    folder = "rpx",
    resources = { "rpx-core" }
  },
  {
    id = "tpzcore",
    name = "TPZ-CORE Framework",
    folder = "tpzcore",
    resources = { "tpz_core" }
  },
  {
    id = "frp",
    name = "FRP Framework",
    folder = "frp",
    resources = { "frp_core" }
  },
}

local function extractResourceData(str)
  local resource, version = str:match("^([%w%-_]+)%s*[<>=]=?%s*([0-9]+%.[0-9]+%.[0-9]+[%w%.]*)$")
  if not resource then return str end
  return resource, version
end


local function detectFramework()
  local frameworkConvarValue = GetConvar("jo_libs:framework", "false") -- Force the framework
  if frameworkConvarValue ~= "false" then
    return frameworkConvarValue
  end

  local frameworkDetected

  for i = 1, #supportedFrameworks do
    local framework = supportedFrameworks[i]
    local rightFramework = true

    for j = 1, #framework.resources do
      local value = framework.resources[j]
      local resource, version = extractResourceData(value)
      if resource:sub(1, 1) == "!" then
        if GetResourceState(resource) == "starting" or GetResourceState(resource) == "started" then
          rightFramework = false
          break
        end
      else
        if GetResourceState(resource) == "missing" or GetResourceState(resource) == "stopped" then
          rightFramework = false
          break
        else
          if version then
            local currentVersion = GetValue(GetResourceMetadata(resource, "version", 0), 1)
            local compare = currentVersion:compareVersionWith(version)
            if value:find("<=") then
              if not (compare <= 0) then
                rightFramework = false
                break
              end
            elseif value:find(">=") then
              if not (compare >= 0) then
                rightFramework = false
                break
              end
            elseif value:find("=") then
              if not (compare == 0) then
                rightFramework = false
                break
              end
            elseif value:find("<") then
              if not (compare < 0) then
                rightFramework = false
                break
              end
            elseif value:find(">") then
              if not (compare > 0) then
                rightFramework = false
                break
              end
            end
          end
        end
      end
    end

    if rightFramework then
      if not frameworkDetected then
        frameworkDetected = framework
      else
        eprint("=========== ERROR ===========")
        eprint("ERROR ! You have multiple frameworks on your server. Please use only once:")
        eprint(("- %s detected"):format(frameworkDetected.name))
        eprint(("- %s detected"):format(framework.name))
        eprint("=========== ERROR ===========")
        return false
      end
    end
  end

  return frameworkDetected
end

frameworkDetected = detectFramework()
if not frameworkDetected then
  eprint("IMPOSSIBLE to detect which framework is used on your server")
  return
end

if jo.isServerSide() then
  bprint(("%s detected"):format(frameworkDetected.name))
end

for i = 1, #frameworkDetected.resources do
  local resource = frameworkDetected.resources[i]
  if resource:sub(1, 1) ~= "!" then
    resource = extractResourceData(resource)
    while GetResourceState(resource) ~= "started" do
      bprint("Waiting start of " .. resource)
      Wait(1000)
    end
  end
end

local function waitInventoryItems()
  while table.isEmpty(jo.framework.inventoryItems) do Wait(10) end
end

jo.ready(function()
  Wait(1000)
  jo.framework.inventoryItems = exports.jo_libs:jo_framework_getInventoryItems()
end)

--- A function to get the list of items
---@return table (The list of items)
---@ignore
function jo.framework:getItems()
  waitInventoryItems()
  return jo.framework.inventoryItems
end

--- A function to get an item data
---@param item string (The name of the item)
---@return table|false (The item data or false if not found)
---@ignore
function jo.framework:getItemData(item)
  waitInventoryItems()
  if not jo.framework.inventoryItems[item] then
    eprint("Item %s not found", item)
    return
    {
      label = "Not exist"
    }
  end
  return jo.framework.inventoryItems[item]
end
