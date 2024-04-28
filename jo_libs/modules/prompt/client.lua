local promptGroups = {}
local lastKey = 0

jo.prompt = {}

local function UiPromptHasHoldMode(...) return Citizen.InvokeNative(0xB60C9F9ED47ABB76, ...) end
local function UiPromptSetEnabled(...) return Citizen.InvokeNative(0x8A0FB4D03A630D21,...) end
local function UiPromptIsEnabled(...) return Citizen.InvokeNative(0x0D00EDDFB58B7F28,...) end

local function IsPromptEnabled(group,key) return UiPromptIsEnabled(promptGroups[group].prompts[key]) end

---@param group string Name of the group
---@param key string Input
---@param value boolean
local function SetPromptEnabled(group,key,value)
  UiPromptSetEnabled(promptGroups[group].prompts[key],value)
end

---@param group string Name of the group
---@param title string Title of the prompt
function jo.prompt.displayGroup(group,title)
  local promptName  = CreateVarString(10, 'LITERAL_STRING', title)
  PromptSetActiveGroupThisFrame(promptGroups[group].group, promptName)
end

---@param group string Name of the group
---@param key string Input
---@param value boolean
function jo.prompt.setVisible(group,key,value)
  UiPromptSetVisible(promptGroups[group].prompts[key],value)
  UiPromptSetEnabled(promptGroups[group].prompts[key],value)
end

---@param group string Name of the group
---@param key string Input
---@param label string Label of the prompt
function jo.prompt.editKeyLabel(group,key,label)
  local str = CreateVarString(10, 'LITERAL_STRING', label)
  PromptSetText(promptGroups[group].prompts[key], str)
end

---@param group string Group of the prompt
---@param key string Input
---@return boolean
function jo.prompt.isCompleted(group,key)
	if not promptGroups[group] then return false end
  if not IsPromptEnabled(group,key) then return false end
  if UiPromptHasHoldMode(promptGroups[group].prompts[key]) then
    if PromptHasHoldModeCompleted(promptGroups[group].prompts[key]) then
			lastKey = promptGroups[group].prompts[key]
      SetPromptEnabled(group,key, false)
      Citizen.CreateThread(function()
        local group = group
        local key = key
        while IsDisabledControlPressed(0,joaat(key)) or IsControlPressed(0,joaat(key)) do
          Wait(0)
        end
        SetPromptEnabled(group,key, true)
      end)
      return true
    end
  else
    if IsControlJustPressed(0,joaat(key)) then
			lastKey = key
      return true
    end
  end
  return false
end

---@param key string Input
function jo.prompt.waitRelease(key)
  while IsDisabledControlPressed(0,joaat(key)) or IsControlPressed(0,joaat(key)) do
    Wait(0)
  end
end

---@param group string Group of the prompt
---@param key string Input
---@return boolean
function jo.prompt.isLastKey(group,key)
	return lastKey == promptGroups[group].prompts[key]
end

---@param group string Group of the prompt
---@param str string label of the prompt
---@param key string Input
---@param holdTime integer time to complete
---@param page integer page of the prompt
function jo.prompt.create(group, str, key, holdTime, page)
  --Check if group exist
	if not page then page = 0 end
	if not holdTime then holdTime = false end
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
    for _,k in pairs (keys) do
      promptGroups[group].prompts[k] = promptGroups[group].prompts[key]
      PromptSetControlAction(promptGroups[group].prompts[key], joaat(k))
    end
  else
    promptGroups[group].prompts[key] = PromptRegisterBegin()
    PromptSetControlAction(promptGroups[group].prompts[key], joaat(key))
  end
  str = CreateVarString(10, 'LITERAL_STRING', str)
  PromptSetText(promptGroups[group].prompts[key], str)
  PromptSetPriority(promptGroups[group].prompts[key], 2)
  PromptSetEnabled(promptGroups[group].prompts[key], true)
  PromptSetVisible(promptGroups[group].prompts[key], true)
  if holdTime then
    PromptSetHoldMode(promptGroups[group].prompts[key], holdTime)
  end
	if group ~= "interaction" then
  	PromptSetGroup(promptGroups[group].prompts[key], promptGroups[group].group,page)
	end
  PromptRegisterEnd(promptGroups[group].prompts[key])
end

---@param group string Group of the prompt
---@param key string Input
function jo.prompt.deletePrompt(group,key)
	PromptDelete(promptGroups[group].prompts[key])
end

---@param group string Group of the prompt
function jo.prompt.deleteGroup(group)
	if not promptGroups[group] then return end
	for _,prompt in pairs (promptGroups[group].prompts) do
		PromptDelete(prompt)
	end
end

AddEventHandler('onResourceStop', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then return end
  for _,group in pairs (promptGroups) do
		for _,prompt in pairs (group.prompts) do
			PromptDelete(prompt)
		end
	end
end)