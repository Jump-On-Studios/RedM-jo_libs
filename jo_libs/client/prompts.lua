prompts = {}
promptGroups = {}
promptName = ''
timerkey = {}
lastKey = 0
interactPrompt = 0

function IsPromptCompleted(group,key)
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

function DoesLastKeyIs(group,key)
	return lastKey == promptGroups[group].prompts[key]
end

function IsPromptEnabled(group,key)
  return UiPromptIsEnabled(promptGroups[group].prompts[key])
end

function GetPromptKey(group,key)
	if not IsPromptValid(group,key) then return 0 end
	return promptGroups[group].prompts[key]
end

function GetPromptProgress(group,key)
	return Citizen.InvokeNative(0x81801291806DBC50,GetPromptKey(group,key),Citizen.ResultAsFloat())
end

function CreatePromptButton(group, str, key, holdTime, page)
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

function CreateInteractPrompt(control,text,duration)
	if UiPromptIsValid(interactPrompt) then DeleteInteractPrompt() end
    interactPrompt = PromptRegisterBegin()
    PromptSetControlAction(interactPrompt, joaat(control))
    PromptSetText(interactPrompt, CreateVarString(10, 'LITERAL_STRING', text))
    PromptSetHoldMode(interactPrompt, duration or 100)
    PromptSetPriority(interactPrompt, 3)
    PromptSetEnabled(interactPrompt, true)
    PromptSetVisible(interactPrompt, true)
    PromptRegisterEnd(interactPrompt)
end

function IsInteractionPromptCompleted()
	return PromptHasHoldModeCompleted(interactPrompt)
end

function DeleteInteractPrompt()
	PromptDelete(interactPrompt)
end

function DeletePrompt(group,key)
	PromptDelete(promptGroups[group].prompts[key])
end

function DeleteGroupPrompt(group)
	if not promptGroups[group] then return end
	for _,prompt in pairs (promptGroups[group].prompts) do
		PromptDelete(prompt)
	end
end

function UiPromptIsActive(...)
 return Citizen.InvokeNative(0x546E342E01DE71CF,...)
end

function UiPromptGetProgress(...)
 return Citizen.InvokeNative(0x81801291806DBC50,...,Citizen.ResultAsFloat())
end

function UiPromptSetAttribute(...)
 return Citizen.InvokeNative(0x560E76D5E2E1803F,...)
end

function PromptSetType(...)
 return Citizen.InvokeNative(0xF4A5C4509BF923B1,...)
end

function EditPromptText(group,key,str)
  str = CreateVarString(10, 'LITERAL_STRING', str)
  PromptSetText(promptGroups[group].prompts[key], str)
end

function UiPromptIsValid(...)
 return Citizen.InvokeNative(0x347469FBDD1589A9,...)
end

function IsPromptValid(group,key)
	if not promptGroups[group] then return false end
	return UiPromptIsValid(promptGroups[group].prompts[key])
end

function UiPromptRestartModes(...)
 return Citizen.InvokeNative(0xDC6C55DFA2C24EE5,...)
end

function UiPromptDelete(...)
 return Citizen.InvokeNative(0x00EDE88D4D13CF59,...)
end

function UiPromptSetType(...)
 return Citizen.InvokeNative(0x00EDE88D4D13CF59,...)
end

function DisplayPrompt(group,str)
  local promptName  = CreateVarString(10, 'LITERAL_STRING', str)
  PromptSetActiveGroupThisFrame(promptGroups[group].group, promptName)
end

function UiPromptHasHoldMode(...)
  return Citizen.InvokeNative(0xB60C9F9ED47ABB76, ...)
end

function UiPromptDisablePromptTypeThisFrame(...)
  return Citizen.InvokeNative(0xFC094EF26DD153FA,...)
end

function UiPromptSetEnabled(...)
  return Citizen.InvokeNative(0x8A0FB4D03A630D21,...)
end

function UiPromptIsEnabled(...)
 return Citizen.InvokeNative(0x0D00EDDFB58B7F28,...)
end

function SetPromptVisible(group,key,value)
  UiPromptSetVisible(promptGroups[group].prompts[key],value)
  UiPromptSetEnabled(promptGroups[group].prompts[key],value)
end

function SetPromptEnabled(group,key,value)
  UiPromptSetEnabled(promptGroups[group].prompts[key],value)
end

function UiPromptEnablePromptTypeThisFrame(...)
 return Citizen.InvokeNative(0x06565032897BA861,...)
end