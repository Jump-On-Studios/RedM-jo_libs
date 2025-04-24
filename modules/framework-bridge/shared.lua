---@class FrameworkClass
jo.framework = {}

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
  }
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

local frameworkDetected = detectFramework()
if not frameworkDetected then
  eprint("IMPOSSIBLE to detect which framework is used on your server")
  return
end

bprint(("%s detected"):format(frameworkDetected.name))

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

---@autodoc:config ignore:true
function jo.framework:getFrameworkDetected()
  return frameworkDetected
end

---@autodoc:config ignore:true
function jo.framework:loadFile(...)
  local args = { ... }
  local folder = args[2] and args[1] or frameworkDetected.folder
  local name = args[2] or args[1]
  local path = ("framework-bridge.%s.%s"):format(folder, name)
  if jo.file.isExist(path) then
    return jo.file.load(path)
  end
  return false
end
