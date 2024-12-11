local promptGroups = {}
local lastKey = 0
local promptHidden = {}

jo.prompt = {}

jo.require("timeout")

local function UiPromptHasHoldMode(...) return Citizen.InvokeNative(0xB60C9F9ED47ABB76, ...) end
local function UiPromptSetEnabled(...) return Citizen.InvokeNative(0x8A0FB4D03A630D21, ...) end
local function UiPromptIsEnabled(...) return Citizen.InvokeNative(0x0D00EDDFB58B7F28, ...) end
local function UiPromptGetProgress(...) return Citizen.InvokeNative(0x81801291806DBC50, ..., Citizen.ResultAsFloat()) end

---@param group string Name of the group
---@param title string Title of the prompt
function jo.prompt.displayGroup(group, title)
  if not jo.prompt.isGroupExist(group) then return end
  local promptName = CreateVarString(10, "LITERAL_STRING", title)
  PromptSetActiveGroupThisFrame(promptGroups[group].group, promptName)
end

function jo.prompt.isActive(group, key)
  if not jo.prompt.isExist(group, key) then return false end
  return UiPromptIsActive(promptGroups[group].prompts[key])
end

---@param group string Name of the group
---@param key string Input
function jo.prompt.isEnabled(group, key)
  if not jo.prompt.isActive(group, key) then return false end
  return UiPromptIsEnabled(promptGroups[group].prompts[key])
end

---@param group string Name of the group
---@param key string Input
---@param value boolean
function jo.prompt.setEnabled(group, key, value)
  if not jo.prompt.isExist(group, key) then return end
  UiPromptSetEnabled(promptGroups[group].prompts[key], value)
end

---@param group string Name of the group
---@param key string Input
---@param value boolean
function jo.prompt.setVisible(group, key, value)
  if not jo.prompt.isExist(group, key) then return end
  if not value then
    promptHidden[group .. key] = true
  else
    promptHidden[group .. key] = nil
  end
  UiPromptSetVisible(promptGroups[group].prompts[key], value)
end

function jo.prompt.isVisible(group, key)
  if promptHidden[group .. key] then
    return false
  end
  return true
end

---@param group string Name of the group
---@param key string Input
---@param label string Label of the prompt
function jo.prompt.editKeyLabel(group, key, label)
  if not jo.prompt.isExist(group, key) then return end
  local str = CreateVarString(10, "LITERAL_STRING", label)
  PromptSetText(promptGroups[group].prompts[key], str)
end

---@param group string Group of the prompt
---@param key string Input
---@param fireMultipleTimes? boolean (optional) fire true until another prompt is completed
---@return boolean
function jo.prompt.isCompleted(group, key, fireMultipleTimes)
  if fireMultipleTimes == nil then fireMultipleTimes = false end
  if not jo.prompt.isGroupExist(group) then return false end
  if fireMultipleTimes then
    if jo.prompt.doesLastCompletedIs(group, key) then
      return true
    end
  end
  if not jo.prompt.isEnabled(group, key) then return false end
  if not jo.prompt.isVisible(group, key) then return false end
  if UiPromptHasHoldMode(promptGroups[group].prompts[key]) then
    if PromptHasHoldModeCompleted(promptGroups[group].prompts[key]) then
      lastKey = promptGroups[group].prompts[key]
      jo.prompt.setEnabled(group, key, false)
      Citizen.CreateThread(function()
        local group = group
        local key = key
        while IsDisabledControlPressed(0, joaat(key)) or IsControlPressed(0, joaat(key)) do
          Wait(0)
        end
        lastKey = 0
        jo.prompt.setEnabled(group, key, true)
      end)
      return true
    end
  else
    if IsControlJustPressed(0, joaat(key)) then
      lastKey = key
      CreateThread(function()
        while IsControlPressed(0, joaat(key)) do
          Wait(0)
        end
        lastKey = 0
      end)
      return true
    elseif fireMultipleTimes and IsControlPressed(0, joaat(key)) then
      return true
    end
  end
  return false
end

---@param key string Input
function jo.prompt.waitRelease(key)
  while IsDisabledControlPressed(0, joaat(key)) or IsControlPressed(0, joaat(key)) do
    Wait(0)
  end
end

---@param group string Group of the prompt
---@param key string Input
---@return boolean
function jo.prompt.doesLastCompletedIs(group, key)
  if not jo.prompt.isExist(group, key) then return false end
  return lastKey == promptGroups[group].prompts[key]
end

---@param group string Group of the prompt
---@param str string label of the prompt
---@param key any Input (string or list of strings)
---@param holdTime? integer (optional) time to complete
---@param page? integer (optional) page of the prompt
function jo.prompt.create(group, str, key, holdTime, page)
  --Check if group exist
  if not page then page = 0 end
  if not holdTime then holdTime = 0 end

  if key == nil or (type(key) == "table" and key[1] == nil) then
    return eprint("No key set for", group, str)
  end

  if (promptGroups[group] == nil) then
    if type(group) == "string" then
      promptGroups[group] = {
        group = GetRandomIntInRange(0, 0xffffff),
        prompts = {}
      }
    else
      promptGroups[group] = {
        group = group,
        prompts = {}
      }
    end
  end
  if type(key) == "table" then
    local keys = key
    key = keys[1]
    promptGroups[group].prompts[key] = PromptRegisterBegin()
    for _, k in pairs(keys) do
      promptGroups[group].prompts[k] = promptGroups[group].prompts[key]
      PromptSetControlAction(promptGroups[group].prompts[key], joaat(k))
    end
  else
    promptGroups[group].prompts[key] = PromptRegisterBegin()
    PromptSetControlAction(promptGroups[group].prompts[key], joaat(key))
  end
  str = CreateVarString(10, "LITERAL_STRING", str)
  PromptSetText(promptGroups[group].prompts[key], str)
  PromptSetPriority(promptGroups[group].prompts[key], 2)
  PromptSetEnabled(promptGroups[group].prompts[key], true)
  PromptSetVisible(promptGroups[group].prompts[key], true)
  if holdTime > 0 then
    PromptSetHoldMode(promptGroups[group].prompts[key], holdTime)
  end
  if type(group) ~= "string" or not group:find("interaction") then
    PromptSetGroup(promptGroups[group].prompts[key], promptGroups[group].group, page)
  end
  PromptRegisterEnd(promptGroups[group].prompts[key])
  jo.prompt.setVisible(group, key, true)
  return promptGroups[group].prompts[key]
end

function jo.prompt.deleteAllGroups()
  for group, _ in pairs(promptGroups) do
    jo.prompt.deleteGroup(group)
  end
end

---@param group string Group of the prompt
---@param key string Input
function jo.prompt.delete(group, key)
  if not jo.prompt.isExist(group, key) then return end
  PromptDelete(promptGroups[group].prompts[key])
end
jo.prompt.deletePrompt = jo.prompt.delete

---@param group string Group of the prompt
function jo.prompt.deleteGroup(group)
  if not promptGroups[group] then return end
  for _, prompt in pairs(promptGroups[group].prompts) do
    PromptDelete(prompt)
  end
  promptGroups[group] = nil
end

jo.stopped(function()
  for _, group in pairs(promptGroups) do
    for _, prompt in pairs(group.prompts) do
      PromptDelete(prompt)
    end
  end
end)

---@param group string the name of the group
function jo.prompt.isGroupExist(group)
  return promptGroups[group] and true or false
end

---@param group string the name of the group
---@param key string the input of the key
function jo.prompt.isExist(group, key)
  if not jo.prompt.isGroupExist(group) then return false end
  return promptGroups[group].prompts[key] and true or false
end

jo.prompt.isPromptExist = jo.prompt.isExist

---@param group string the name of the group
---@param key string the input of the key
function jo.prompt.getProgress(group, key)
  if not jo.prompt.isExist(group, key) then return 0 end
  return UiPromptGetProgress(promptGroups[group].prompts[key])
end
jo.prompt.getPromptProgress = jo.prompt.getProgress

---@param groups table groups of prompt
function jo.prompt.setGroups(groups)
  promptGroups = groups
end

---@return table promptGroups prompt registered
function jo.prompt.getAll()
  return promptGroups
end

---@param key string the input of the key
function jo.prompt.isPressed(key)
  return IsControlPressed(0, joaat(key))
end

---@param group string the name of the group
---@param key string the input of the key
---@return integer promptId The prompt ID
function jo.prompt.get(group, key)
  if not jo.prompt.isExist(group, key) then return false end
  return promptGroups[group].prompts[key]
end

exports("jo_prompt_get", function()
  return jo.prompt
end)
