jo.file.load("framework-bridge.overwrite-functions")

jo.require("table")
jo.require("string")

local mainResourceFramework = {
  VORP = { "vorp_core" },
  RedEM = { "redem" },
  RedEM2023 = { "!redem", "redem_roleplay" },
  QBR = { "qbr-core" },
  RSG = { "rsg-core" },
  QR = { "qr-core" },
}

---@return any Name of the framework
local function whichStarted()
  for framework, resources in pairs(mainResourceFramework) do
    local rightFramework = true
    for _, resource in pairs(resources) do
      if resource:sub(1, 1) == "!" then
        if GetResourceState(resource) ~= "missing" then
          rightFramework = false
          break
        end
      else
        if GetResourceState(resource) == "missing" then
          rightFramework = false
          break
        end
      end
    end
    if rightFramework then
      for _, resource in pairs(resources) do
        if resource:sub(1, 1) ~= "!" then
          while GetResourceState(resource) ~= "started" do
            bprint("Waiting start of " .. framework)
            Wait(1000)
          end
        end
      end
      return framework
    end
  end
  return false
end

---@param data any the clothes data
---@return table
local function formatComponentData(data)
  if type(data) == "table" then
    if data.comp then
      data.hash = data.comp
      data.comp = nil
    end
    if not data.hash or data.hash == 0 or data.hash == -1 then return nil end
    if type(data.hash) == "table" then --for VORP
      return data.hash
    end
    return data
  end
  if type(data) ~= "number" then data = tonumber(data) end
  if data == 0 or data == -1 or data == 1 or data == nil then
    return nil
  end
  return {
    hash = data
  }
end

local frameworkName = whichStarted()
local UserClass = jo.file.load(("framework-bridge.%s.UserClass"):format(frameworkName))
jo.User = UserClass
local FrameworkClass = jo.file.load(("framework-bridge.%s.FrameworkClass"):format(frameworkName))
jo.framework = FrameworkClass
jo.framework:init()
