-------------
-- Generic version-checker module. Defaults route to the JUMP ON Studios
-- release API and download portal; third-party script authors can override
-- any field by declaring metadata in their own `fxmanifest.lua`:
--
--   author "twinded.ca"                                     -- footer branding
--   version "1.0.0"                                         -- standard FiveM
--   versionEndpoint "https://your.domain/checkVersion?package=%d"
--   downloadUrl "https://your.domain/download"
--
-- All per-resource keys are optional; anything left out falls back to the
-- JUMP ON Studios defaults, so existing scripts keep their current behaviour.
-------------

jo.require("string")
jo.require("resource")

jo.createModule("versionChecker")

if GetCurrentResourceName() == "jo_libs" then
  AddEventHandler("jo_libs:kill:resource", function(resource)
    if tonumber(source) then return end
    while GetResourceState(resource) == "starting" do
      print(GetResourceState(resource))
      Wait(10)
    end
    Wait(100)
    eprint(resource .. " Stopped by jo_libs")
    StopResource(resource)
  end)
end

local function urlencode(str)
  if str then
    str = string.gsub(str, "\n", "\r\n")
    str = string.gsub(str, "([^%w ])", function(c)
      return string.format("%%%02X", string.byte(c))
    end)
    str = string.gsub(str, " ", "+")
  end
  return str
end

-------------
-- CONFIG
-------------

local defaultConfig = {
  apiUrl = "https://jumpon-studios.com/api/checkScriptVersion?package=%d",
  downloadUrl = function(packageID)
    if packageID < 1000 then
      return "https://github.com/Jump-On-Studios"
    end
    return "https://portal.cfx.re/assets/granted-assets"
  end,
  brandingName = "jumpon-studios.com",
  versionKey = "version",
  bodyKey = "body",
  stripPrefix = true,
}

-- Maps internal config keys to the fxmanifest metadata keys that override them.
-- Keys not listed here are not user-configurable from the fxmanifest.
local metadataKeys = {
  apiUrl = "versionEndpoint",
  downloadUrl = "downloadUrl",
  brandingName = "author",
}

local function getConfig(resource, key)
  local metaKey = metadataKeys[key]
  if metaKey then
    local value = GetResourceMetadata(resource, metaKey, 0)
    if value and value ~= "" then
      return value
    end
  end
  return defaultConfig[key]
end

local function resolveDownloadUrl(resource, packageID)
  local downloadUrl = getConfig(resource, "downloadUrl")
  if type(downloadUrl) == "function" then
    return downloadUrl(packageID)
  end
  return downloadUrl
end

local function buildFooter(brandingName)
  -- Preserve the original JUMP ON Studios footer byte-for-byte when the
  -- default branding is used, so no existing script's console diff changes.
  if brandingName == defaultConfig.brandingName then
    return "└───────────────── jumpon-studios.com ──────────────┘"
  end
  -- Generic: keep the same inner width (51 cols) and center the branding.
  local text = " " .. brandingName .. " "
  local innerWidth = 51
  local hyphens = innerWidth - #text
  if hyphens < 0 then hyphens = 0 end
  local left = math.floor(hyphens / 2)
  local right = hyphens - left
  return ("└%s%s%s┘"):format(string.rep("─", left), text, string.rep("─", right))
end

-------------
-- PUBLIC API
-------------

function jo.versionChecker.GetScriptVersion()
  return GetResourceMetadata(GetCurrentResourceName(), "version", 0) or 1
end

function jo.versionChecker.StopAddon(resource)
  CreateThread(function()
    StopResource(resource)
  end)
  return true
end

exports("StopAddon", function(resource)
  return jo.versionChecker.StopAddon(resource)
end)

function jo.versionChecker.checkUpdate()
  CreateThread(function()
    local killed = false
    local myResource = GetCurrentResourceName()
    local currentVersion = GetResourceMetadata(myResource, "version", 0)
    local packageID = tonumber(GetResourceMetadata(myResource, "package_id", 0))
    if not packageID or not currentVersion then
      return
    end

    local serverName = urlencode(GetConvar("sv_hostname", ""))

    -- local framework = urlencode("")
    -- if jo and jo.framework then
    --   framework = urlencode(jo.framework:get())
    -- end

    local apiUrl = getConfig(myResource, "apiUrl")
    local versionKey = getConfig(myResource, "versionKey")
    local bodyKey = getConfig(myResource, "bodyKey")
    local stripPrefix = getConfig(myResource, "stripPrefix")
    local brandingName = getConfig(myResource, "brandingName")

    local link = apiUrl:format(packageID)
    PerformHttpRequest(link, function(errorCode, resultData, resultHeaders, errorData)
      Wait(1000)
      if killed then return end
      if errorCode ~= 200 or not resultData then
        return print("^3" .. myResource .. ": version checker API is offline. Impossible to check your version.^0")
      end
      resultData = json.decode(resultData)
      local remoteVersion = resultData and resultData[versionKey]
      if not remoteVersion then
        return print("^3" .. myResource .. ": error in the format of version checker. Impossible to check your version.^0")
      end
      local lastVersion = stripPrefix and remoteVersion:sub(2) or remoteVersion
      if currentVersion:compareVersionWith(lastVersion) >= 0 then
        return print(("^3%s: \x1b[92mUp to date - Version %s^0"):format(myResource, currentVersion))
      end
      print("^3┌───────────────────────────────────────────────────┐^0")
      print("")
      print("^3" .. myResource .. ": ^5 Update found : Version " .. remoteVersion .. "^0")
      print("^3" .. myResource .. ": ^1 Your Version : Version v" .. currentVersion .. "^0")
      print(("^3Download it on ^0%s"):format(resolveDownloadUrl(myResource, packageID)))
      print("")
      print("^3 Description of " .. remoteVersion .. ":^0")
      print(resultData[bodyKey])
      print("")
      print("^3" .. buildFooter(brandingName) .. "^0")
    end)

    local dependencies = GetResourceMetadata(myResource, "dependencies_version_min", 0)
    if dependencies then
      dependencies = dependencies:split(",")
      for i = 1, #dependencies do
        local dependency = dependencies[i]:gsub(":", ">=")
        if not jo.resource.isConvarMatching(dependency) then
          local script, _, _, minVersion = dependency:extractConvarComparator()
          if GetResourceState(script) ~= "started" then
            eprint(script .. " is missing !")
          else
            local scriptVersion = GetResourceMetadata(script, "version", 0) or "1.0.0"
            eprint(script .. " requires an update^0: Required version: " .. minVersion .. ", Your version: " .. scriptVersion)
            eprint("Resource stopped")
            killed = true
            return TriggerEvent("jo_libs:kill:resource", GetCurrentResourceName())
          end
        end
      end
    end
  end)
end

jo.ready(jo.versionChecker.checkUpdate)
