local promptGroups = {}
local lastKey = 0
local promptHidden = {}

jo.prompt = {}

jo.require("timeout")

local function UiPromptHasHoldMode(...) return Citizen.InvokeNative(0xB60C9F9ED47ABB76, ...) end
local function UiPromptSetEnabled(...) return Citizen.InvokeNative(0x8A0FB4D03A630D21, ...) end
local function UiPromptIsEnabled(...) return Citizen.InvokeNative(0x0D00EDDFB58B7F28, ...) end
local function UiPromptGetProgress(...) return Citizen.InvokeNative(0x81801291806DBC50, ..., Citizen.ResultAsFloat()) end

--- A function to display a prompt group during this frame.
--- Needs to be called each frame.
---@param group string (The name of the prompt group to display this frame)
---@param title string (The title to display for this prompt group)
function jo.prompt.displayGroup(group, title)
  if not group then return end
  if not jo.prompt.isGroupExist(group) then return end
  local promptName = CreateVarString(10, "LITERAL_STRING", title)
  PromptSetActiveGroupThisFrame(promptGroups[group].group, promptName, promptGroups[group].nbrPage, 0)
end

--- A function to know if a prompt is active or not.
---@param group string (The name of the group)
---@param key string (The [input](https://github.com/femga/rdr3_discoveries/tree/a63669efcfea34915c53dbd29724a2a7103f822f/Controls) of the key)
---@param page? integer (The page of the prompt <br> default: current page)
---@return boolean (Return `true` if the prompt is active)
function jo.prompt.isActive(group, key, page)
  if not group or not key then return false end
  page = page or jo.prompt.getPage(group)
  if not jo.prompt.isExist(group, key, page) then return false end
  return UiPromptIsActive(promptGroups[group].prompts[page][key])
end

--- A function to know if the prompt is enabled.
---@param group string (The name of the group)
---@param key string (The [input](https://github.com/femga/rdr3_discoveries/tree/a63669efcfea34915c53dbd29724a2a7103f822f/Controls) of the key)
---@param page? integer (The page of the prompt <br> default: current page)
---@return boolean (Return `true` if the prompt is enabled)
function jo.prompt.isEnabled(group, key, page)
  if not group or not key then return false end
  page = page or jo.prompt.getPage(group)
  if not jo.prompt.isActive(group, key, page) then return false end
  return UiPromptIsEnabled(promptGroups[group].prompts[page][key])
end

--- A function to define if the prompt is enabled or not.
---@param group string (The name of the group)
---@param key string (The [input](https://github.com/femga/rdr3_discoveries/tree/a63669efcfea34915c53dbd29724a2a7103f822f/Controls) of the key)
---@param value boolean (If the prompt is enabled or not)
---@param page? integer (The page of the prompt <br> default: current page)
function jo.prompt.setEnabled(group, key, value, page)
  if not group or not key then return false end
  page = page or jo.prompt.getPage(group)
  if not jo.prompt.isExist(group, key, page) then return end
  UiPromptSetEnabled(promptGroups[group].prompts[page][key], value)
end

--- Turn on/off a prompt.
---@param group string (The name of the group)
---@param key string (The [input](https://github.com/femga/rdr3_discoveries/tree/a63669efcfea34915c53dbd29724a2a7103f822f/Controls) of the key)
---@param value boolean (If the prompt is visible or not)
---@param page? integer (The page of the prompt <br> default: current page)
function jo.prompt.setVisible(group, key, value, page)
  if not group or not key then return false end
  page = page or jo.prompt.getPage(group)
  if not jo.prompt.isExist(group, key, page) then return end
  if not value then
    promptHidden[group .. page .. key] = true
  else
    promptHidden[group .. page .. key] = nil
  end
  UiPromptSetVisible(promptGroups[group].prompts[page][key], value)
end

--- A function to check if a prompt is visible.
---@param group string (The name of the group)
---@param key string (The [input](https://github.com/femga/rdr3_discoveries/tree/a63669efcfea34915c53dbd29724a2a7103f822f/Controls) of the key)
---@param page? integer (The page of the prompt <br> default: current page)
---@return boolean (Return `true` if the prompt is visible)
function jo.prompt.isVisible(group, key, page)
  if not group or not key then return false end
  page = page or jo.prompt.getPage(group)
  if not jo.prompt.isExist(group, key, page) then return false end
  if promptHidden[group .. page .. key] then
    return false
  end
  return true
end

--- A function to edit the label of a key.
---@param group string (The name of the group)
---@param key string (The [input](https://github.com/femga/rdr3_discoveries/tree/a63669efcfea34915c53dbd29724a2a7103f822f/Controls) of the key)
---@param label string (The label of the key)
---@param page? integer (The page of the prompt <br> default: current page)
function jo.prompt.editKeyLabel(group, key, label, page)
  if not group or not key then return false end
  page = page or jo.prompt.getPage(group)
  if not jo.prompt.isExist(group, key, page) then return end
  local str = CreateVarString(10, "LITERAL_STRING", label)
  PromptSetText(promptGroups[group].prompts[page][key], str)
end

--- A function to test if the prompt is pressed and completed.
---@param group string (The name of the group)
---@param key string (The [input](https://github.com/femga/rdr3_discoveries/tree/a63669efcfea34915c53dbd29724a2a7103f822f/Controls) of the key)
---@param fireMultipleTimes? boolean (Fire true if the prompt is completed and until another prompt is completed  <br> default: false)
---@param page? integer (The page of the prompt <br> default: current page)
---@return boolean (Return `true` if the key is pressed and completed)
function jo.prompt.isCompleted(group, key, fireMultipleTimes, page)
  local keyHashed = GetHashFromString(key)
  if not group or not key then return false end
  if fireMultipleTimes == nil then fireMultipleTimes = false end
  if not jo.prompt.isGroupExist(group) then return false end
  page = page or jo.prompt.getPage(group)
  if fireMultipleTimes then
    if jo.prompt.doesLastCompletedIs(group, key, page) then
      return true
    end
  end
  if not jo.prompt.isEnabled(group, key, page) then return false end
  if not jo.prompt.isVisible(group, key, page) then return false end
  if UiPromptHasHoldMode(promptGroups[group].prompts[page][key]) then
    if PromptHasHoldModeCompleted(promptGroups[group].prompts[page][key]) then
      lastKey = promptGroups[group].prompts[page][key]
      jo.prompt.setEnabled(group, key, false, page)
      Citizen.CreateThread(function()
        local group = group
        local key = key
        local page = page
        while IsDisabledControlPressed(0, keyHashed) or IsControlPressed(0, keyHashed) do
          Wait(0)
        end
        lastKey = 0
        jo.prompt.setEnabled(group, key, true, page)
      end)
      return true
    end
  else
    if IsControlJustPressed(0, keyHashed) then
      lastKey = key
      CreateThread(function()
        while IsControlPressed(0, keyHashed) do
          Wait(0)
        end
        lastKey = 0
      end)
      return true
    elseif fireMultipleTimes and IsControlPressed(0, keyHashed) then
      return true
    end
  end
  return false
end

--- A function to wait for the release of pressed key.
---@param key string (The [input](https://github.com/femga/rdr3_discoveries/tree/a63669efcfea34915c53dbd29724a2a7103f822f/Controls) of the key)
function jo.prompt.waitRelease(key)
  if not key then return false end
  key = GetHashFromString(key)
  while IsDisabledControlPressed(0, key) or IsControlPressed(0, key) do
    Wait(0)
  end
end

--- A function that returns if it's the last prompt completed.
---@param group string (The name of the group)
---@param key string (The [input](https://github.com/femga/rdr3_discoveries/tree/a63669efcfea34915c53dbd29724a2a7103f822f/Controls) of the key)
---@param page? integer (The page of the prompt <br> default: current page)
---@return boolean (Return `true` if key is the last input completed)
function jo.prompt.doesLastCompletedIs(group, key, page)
  if not group or not key then return false end
  page = page or jo.prompt.getPage(group)
  if not jo.prompt.isExist(group, key, page) then return false end
  return lastKey == promptGroups[group].prompts[page][key]
end

--- A function to create a new prompt.
---@param group string (The name of the group. Use "interaction" to display the prompt without need to call jo.prompt.displayGroup every frame)
---@param str string (The label of the key)
---@param key string|table (Input (string or list of strings) <br> The [input](https://github.com/femga/rdr3_discoveries/tree/a63669efcfea34915c53dbd29724a2a7103f822f/Controls) of the key)
---@param holdTime? integer (Duration to complete the prompt in ms <br> Use `false` for classic prompt without holding timer <br> default: false)
---@param page? integer (The page of the prompt <br> default: 0)
---@return integer (The prompt ID)
function jo.prompt.create(group, str, key, holdTime, page)
  if not group or not key then return false end
  --Check if group exist
  page = page or 0
  holdTime = holdTime or 0

  if key == nil or (type(key) == "table" and key[1] == nil) then
    return eprint("No key set for", group, str)
  end

  promptGroups[group] = promptGroups[group] or {
    group = (type(group) == "string") and GetRandomIntInRange(0, 0xffffff) or group,
    prompts = {},
    nbrPage = 1
  }
  promptGroups[group].prompts[page] = promptGroups[group].prompts[page] or {}

  local _key = type(key) == "table" and key[1] or key
  if promptGroups[group].prompts[page][_key] then
    PromptDelete(promptGroups[group].prompts[page][_key])
  end
  local promptId = PromptRegisterBegin()
  promptGroups[group].prompts[page][_key] = promptId

  if type(key) == "table" then
    for _, k in pairs(key) do
      promptGroups[group].prompts[page][k] = promptId
      PromptSetControlAction(promptId, GetHashFromString(k))
    end
  else
    PromptSetControlAction(promptId, GetHashFromString(key))
  end
  str = CreateVarString(10, "LITERAL_STRING", str)
  PromptSetText(promptId, str)
  PromptSetPriority(promptId, 2)
  PromptSetEnabled(promptId, true)
  PromptSetVisible(promptId, true)
  if holdTime > 0 then
    PromptSetHoldMode(promptId, holdTime)
  end
  if type(group) ~= "string" or not group:find("interaction") then
    PromptSetGroup(promptId, promptGroups[group].group, page)
    promptGroups[group].nbrPage = math.max(promptGroups[group].nbrPage, page + 1)
  end
  PromptRegisterEnd(promptId)
  jo.prompt.setVisible(group, key, true)
  return promptId
end

--- A function to delete all prompts created
function jo.prompt.deleteAllGroups()
  for group, _ in pairs(promptGroups) do
    jo.prompt.deleteGroup(group)
  end
end

--- A function to delete a prompt.
---@param group string (The name of the group)
---@param key string (The [input](https://github.com/femga/rdr3_discoveries/tree/a63669efcfea34915c53dbd29724a2a7103f822f/Controls) of the key)
---@param page? integer (The page of the prompt <br> default: current page)
function jo.prompt.delete(group, key, page)
  page = page or jo.prompt.getPage(group)
  if not jo.prompt.isExist(group, key, page) then return end
  PromptDelete(promptGroups[group].prompts[page][key])
end

jo.prompt.deletePrompt = jo.prompt.delete

--- A function to delete a group and all its prompts.
---@param group string (The name of the group)
function jo.prompt.deleteGroup(group)
  if not promptGroups[group] then return end
  for _, prompts in pairs(promptGroups[group].prompts) do
    for _, prompt in pairs(prompts) do
      PromptDelete(prompt)
    end
  end
  promptGroups[group] = nil
end

jo.stopped(function()
  jo.prompt.deleteAllGroups()
end)

--- A function to know if a prompt group exists.
---@param group string (The name of the group)
---@return boolean (Return `true` if the group exists)
function jo.prompt.isGroupExist(group)
  return promptGroups[group] and true or false
end

--- A function to know if a prompt exists.
---@param group string (The name of the group)
---@param key string (The [input](https://github.com/femga/rdr3_discoveries/tree/a63669efcfea34915c53dbd29724a2a7103f822f/Controls) of the key)
---@param page? integer (The page of the prompt <br> default: current page)
---@return boolean (Return `true` if the prompt exists)
function jo.prompt.isExist(group, key, page)
  if not group or not key then return false end
  if not jo.prompt.isGroupExist(group) then return false end
  page = page or jo.prompt.getPage(group)
  return promptGroups[group].prompts[page][key] and true or false
end

jo.prompt.isPromptExist = jo.prompt.isExist

--- A function to return the progress of a prompt.
---@param group string (The name of the group)
---@param key string (The [input](https://github.com/femga/rdr3_discoveries/tree/a63669efcfea34915c53dbd29724a2a7103f822f/Controls) of the key)
---@param page? integer (The page of the prompt <br> default: current page)
---@return number (Return the percent of the prompt progress)
function jo.prompt.getProgress(group, key, page)
  if not group or not key then return 0 end
  page = page or jo.prompt.getPage(group)
  if not jo.prompt.isExist(group, key, page) then return 0 end
  return UiPromptGetProgress(promptGroups[group].prompts[page][key])
end

jo.prompt.getPromptProgress = jo.prompt.getProgress

--- A function to overwrite the prompt groups value.
---@param groups table (The prompt group value from other script get with jo.prompt.getAll())
function jo.prompt.setGroups(groups)
  promptGroups = groups
end

--- A function to get all registered prompts.
---@return table (All prompt registered)
function jo.prompt.getAll()
  return promptGroups
end

--- A function to know if a key is pressed.
---@param key string (The [input](https://github.com/femga/rdr3_discoveries/tree/a63669efcfea34915c53dbd29724a2a7103f822f/Controls) of the key)
---@return boolean (Return `true` if the key is pressed)
function jo.prompt.isPressed(key)
  return IsControlPressed(0, GetHashFromString(key))
end

--- A function to get the prompt ID.
---@param group string (The name of the group)
---@param key string (The [input](https://github.com/femga/rdr3_discoveries/tree/a63669efcfea34915c53dbd29724a2a7103f822f/Controls) of the key)
---@param page? integer (The page of the prompt <br> default: current page)
---@return integer|boolean (The prompt ID or `false`)
function jo.prompt.get(group, key, page)
  if not group or not key then return false end
  page = page or jo.prompt.getPage(group)
  if not jo.prompt.isExist(group, key, page) then return false end
  return promptGroups[group].prompts[page][key]
end

--- A function to get the group ID.
---@param group string (The name of the group)
---@return integer|boolean (The group ID or `false`)
function jo.prompt.getGroup(group)
  if not jo.prompt.isGroupExist(group) then return false end
  return promptGroups[group].group
end

--- A function to get the current page ID for a group.
---@param group string (The name of the group)
---@return integer (The page ID)
function jo.prompt.getPage(group)
  if not jo.prompt.isGroupExist(group) then return 0 end
  local page = PromptGetGroupActivePage(promptGroups[group].group)
  return page >= 0 and page or 0
end

exports("jo_prompt_get", function()
  return jo.prompt
end)
