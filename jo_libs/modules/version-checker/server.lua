-------------
-- ONLY FOR Jump On Studios Scripts !
-------------

jo.require("string")

jo.versionChecker = {}

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

    local link = ("https://dashboard.jumpon-studios.com/api/checkVersion?package=%d&current_version=%s&server_name=%s&framework=%s"):format(packageID, currentVersion, serverName, framework or "")
    PerformHttpRequest(link, function(errorCode, resultData, resultHeaders, errorData)
      Wait(1000)
      if killed then return end
      if errorCode ~= 200 then
        return print("^3" .. myResource .. ": version checker API is offline. Impossible to check your version.^0")
      end
      resultData = json.decode(resultData)
      if not resultData.version then
        return print("^3" .. myResource .. ": error in the format of version checker. Impossible to check your version.^0")
      end
      local lastVersion = resultData.version:sub(2)
      if currentVersion:compareVersionWith(lastVersion) >= 0 then
        return print(("^3%s: \x1b[92mUp to date - Version %s^0"):format(myResource, currentVersion))
      end
      print("^3┌───────────────────────────────────────────────────┐^0")
      print("")
      print("^3" .. myResource .. ": ^5 Update found : Version " .. resultData.version .. "^0")
      print("^3" .. myResource .. ": ^1 Your Version : Version v" .. currentVersion .. "^0")
      print("^3Download it on ^0https://keymaster.fivem.net/asset-grants")
      print("")
      print("^3 Description of " .. resultData.version .. ":^0")
      print(resultData.body)
      print("")
      print("^3└───────────────── jumpon-studios.com ──────────────┘^0")
    end)

    local dependencies = GetResourceMetadata(myResource, "dependencies_version_min", 0)
    if dependencies then
      dependencies = dependencies:split(",")
      for _, dependency in ipairs(dependencies) do
        local data = dependency:split(":")
        local script = data[1]
        local minVersion = data[2]

        if GetResourceState(script) ~= "started" then
          eprint(script .. " is missing !")
        else
          local currentVersion = exports[script]:GetScriptVersion()
          if currentVersion:compareVersionWith(minVersion) < 0 then
            eprint(script .. " requires an update^0: Required version: " .. minVersion .. ", Your version: " .. currentVersion)
            eprint("Resource stopped")
            killed = true
            return TriggerEvent("jo_libs:kill:resource", GetCurrentResourceName())
          end
        end
      end
    end
  end)
end

jo.ready(function()
  CreateThread(jo.versionChecker.checkUpdate)
end)
