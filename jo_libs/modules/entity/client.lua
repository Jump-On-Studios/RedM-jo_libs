jo.entity = {}

if not IsModuleLoaded('utils') then
end

---@param entity integer
function jo.entity.requestControl(entity)
  while not NetworkHasControlOfEntity(entity) do
    NetworkRequestControlOfEntity(entity)
    Wait(100)
  end
end

---@param entity integer
function jo.entity.delete(entity)
  if not DoesEntityExist(entity) then return end
  DeleteEntity(entity)
end

---@param entity integer
---@param duration? integer (optional) integer fade in ms
function jo.entity.fadeAndDelete(entity,duration)
	duration = duration or 1000
	if not DoesEntityExist(entity) then return end
	local horses = {}
	if IsEntityAVehicle(entity) then
		local model = GetEntityModel(entity)
		local horseCount = GetNumDraftVehicleHarnessPed(model)
		for i = 0, horseCount-1 do
			horses[#horses+1] = GetPedInDraftHarness(entity,i)
		end
		HideHorseReins(entity)
	end

	local startTime = GetGameTimer()
	local startAlpha = GetEntityAlpha(entity)
	local alpha = startAlpha
	while alpha > 0 do
		local time = GetGameTimer()-startTime
		local percent = 1-time/duration
		alpha = startAlpha*percent
		if alpha < 0 then break end
		SetEntityAlpha(entity,math.floor(alpha))
		if IsEntityAVehicle(entity) then
			for _,horse in pairs (horses) do
				SetEntityAlpha(horse,math.floor(alpha))
			end
		end
		Wait(10)
	end
	jo.entity.delete(entity)
end

function jo.entity.create(model,coords,heading,networked)
	local model = GetHashFromString(model)
	jo.utils.loadGameData(model,true)
	local entity = CreatePed(model,vec4(0,0,0,0),networked)
	SetModelAsNoLongerNeeded(model)
	if model == joaat("mp_female") then
		EquipMetaPedOutfitPreset(entity, 7)
		ApplyShopItemToPed(entity,joaat('CLOTHING_ITEM_F_HEAD_001_V_001'), true, true, false) --head
		ApplyShopItemToPed(entity,joaat('CLOTHING_ITEM_F_BODIES_UPPER_001_V_001'), true, true, false)
		ApplyShopItemToPed(entity,joaat('CLOTHING_ITEM_F_BODIES_LOWER_001_V_001'), true, true, false)
		ApplyShopItemToPed(entity,joaat('CLOTHING_ITEM_F_EYES_001_TINT_001'), true, true, false)
	elseif model == joaat('mp_male') then
		EquipMetaPedOutfitPreset(entity, 4)
		ApplyShopItemToPed(entity,joaat('CLOTHING_ITEM_M_HEAD_001_V_001'), true, true, false) --head
		ApplyShopItemToPed(entity,joaat('CLOTHING_ITEM_M_BODIES_UPPER_001_V_001'), true, true, false)
		ApplyShopItemToPed(entity,joaat('CLOTHING_ITEM_M_BODIES_LOWER_001_V_001'), true, true, false)
		ApplyShopItemToPed(entity,joaat('CLOTHING_ITEM_M_EYES_001_TINT_001'), true, true, false)
	else
		SetRandomOutfitVariation(entity,true)
	end
	SetEntityCoords(entity,coords.xyz)
	SetEntityHeading(entity,heading*1.0)
	SetAttributeCoreValue(entity, 0, 100)  --_SET_ATTRIBUTE_CORE_VALUE
	SetEntityHealth(entity, 600, 1)
	SetAttributeCoreValue(entity, 1, 100)  --_SET_ATTRIBUTE_CORE_VALUE
	RestorePedStamina(entity, 1065330373)
	return entity
end

return jo.entity