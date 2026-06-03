jo.require("string")
jo.require("resource")

---@class FrameworkClass
---@field core table (The link with the framework)
---@field inv table (The link with the inventory)
---@field inventoryItems table (The list of items)
jo.createModule("framework")
jo.framework.core = {}
jo.framework.inv = {}
jo.framework.inventoryItems = {}

local supportedCores = jo.file.load("framework-bridge.cores.detector_shared")
local supportedInventories = jo.file.load("framework-bridge.inventories.detector_shared")
local coresStarted = {}
local inventoriesStarted = {}

local function waitForResources(resources)
  for r = 1, #resources do
    local resource = resources[r]
    if resource:sub(1, 1) ~= "!" then
      resource = resource:extractConvarComparator()
      while GetResourceState(resource) ~= "started" do
        bprint("Waiting start of " .. resource)
        Wait(1000)
      end
    end
  end
end


local function isResourcesMatch(resources)
  for i = 1, #resources do
    if not jo.resource.isConvarMatching(resources[i]) then
      return false
    end
  end
  return true
end

local function getMatchedEntries(entries)
  local matchedEntries = {}
  for e = 1, #entries do
    local entry = entries[e]
    local isMatch = isResourcesMatch(entry.matchResources)
    if isMatch then
      waitForResources(entry.matchResources)
      matchedEntries[#matchedEntries + 1] = entry
      gprint(("%s detected"):format(entry.name))
    end
  end
  return matchedEntries
end

local function detectCores()
  if #coresStarted > 0 then return coresStarted end
  coresStarted = getMatchedEntries(supportedCores)

  if #coresStarted == 0 then
    eprint("=====================================")
    eprint("No compatible core found on your server")
    eprint("=====================================")
    return {}
  end

  if #coresStarted > 1 then
    oprint("=====================================")
    oprint("Warning: multiple cores are started on your server")
    oprint("=====================================")
  end
  return coresStarted
end

local function detectInventories()
  if #inventoriesStarted > 0 then return inventoriesStarted end
  inventoriesStarted = getMatchedEntries(supportedInventories)

  if #inventoriesStarted == 0 then
    eprint("=====================================")
    eprint("No compatible inventory found on your server")
    eprint("=====================================")
    return {}
  end

  if #inventoriesStarted > 1 then
    oprint("=====================================")
    oprint("Warning: multiple inventories are started on your server")
    oprint("=====================================")
  end
  return inventoriesStarted
end

---@autodoc:config ignore:true
function jo.framework:getFrameworkDetected()
  local cores = detectCores()
  if #cores == 0 then return false end
  return cores[1]
end

local function loadFile(...)
  local path = ("framework-bridge.%s.%s.%s"):format(...)
  if jo.file.isExist(path) then
    jo.file.load(path)
  end
end

local function loadFiles(mainFolder, folders, file)
  if #folders == 0 then return false end
  for f = 1, #folders do
    local folder = folders[f]
    loadFile(mainFolder, folder.folder, file)
  end
  loadFile(mainFolder, "_custom", file)
  return true
end

---@autodoc:config ignore:true
function jo.framework:loadCoreFiles(file)
  local cores = detectCores()
  if #cores == 0 then return false end
  return loadFiles("cores", cores, file)
end

function jo.framework:loadInventoryFiles(file)
  local inventories = detectInventories()
  if #inventories == 0 then return false end
  return loadFiles("inventories", inventories, file)
end

detectCores()
detectInventories()

local function waitInventoryItems()
  while table.isEmpty(jo.framework.inventoryItems) do Wait(10) end
end

if jo.resourceName ~= "jo_libs" then
  jo.ready(function()
    Wait(1000)
    jo.framework.inventoryItems = exports.jo_libs:jo_framework_getInventoryItems()
  end)
end

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

-------------
-- Shortcut
-------------
jo.fw = jo.framework
