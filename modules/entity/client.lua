jo.entity = {}
local Entities = {}

-------------
-- Auto delete when restart
-------------
jo.stopped(function()
	for entity, _ in pairs(Entities) do
		jo.entity.delete(entity)
	end
end)

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
	Entities[entity] = nil
end

---@param entity integer
---@param duration? integer (optional) integer fade in ms. default (1000)
function jo.entity.fadeAndDelete(entity, duration)
	duration = duration or 1000
	if not DoesEntityExist(entity) then return end
	if GetResourceState(jo.resourceName) == "stopped" then return jo.entity.delete(entity) end

	jo.entity.fadeOut(entity, duration)
	jo.entity.delete(entity)
end

---@param entity integer
---@param duration? integer duration in ms. default (1000)
function jo.entity.fadeIn(entity, duration)
	duration = duration or 1000
	if not DoesEntityExist(entity) then return end
	local startTime = GetGameTimer()
	local startAlpha = GetEntityAlpha(entity)
	local alpha = startAlpha
	while alpha < 255 do
		local time = GetGameTimer() - startTime
		local percent = time / duration
		alpha = startAlpha + (255 - startAlpha) * percent
		if alpha > 255 then alpha = 255 end
		SetEntityAlpha(entity, math.floor(alpha))
		if IsEntityAVehicle(entity) then
			for _, horse in pairs(horses) do
				SetEntityAlpha(horse, math.floor(alpha))
			end
		end
		Wait(10)
	end
end

---@param entity integer
---@param duration? integer duration in ms. default (1000)
function jo.entity.fadeOut(entity, duration)
	duration = duration or 1000
	local startTime = GetGameTimer()
	local startAlpha = GetEntityAlpha(entity)
	local alpha = startAlpha
	local horses = {}
	if IsEntityAVehicle(entity) then
		local model = GetEntityModel(entity)
		local horseCount = GetNumDraftVehicleHarnessPed(model)
		for i = 0, horseCount - 1 do
			horses[#horses + 1] = GetPedInDraftHarness(entity, i)
		end
		HideHorseReins(entity)
	end
	while alpha > 0 do
		local time = GetGameTimer() - startTime
		local percent = 1 - time / duration
		alpha = startAlpha * percent
		if alpha < 0 then alpha = 0 end
		SetEntityAlpha(entity, math.floor(alpha))
		if IsEntityAVehicle(entity) then
			for _, horse in pairs(horses) do
				SetEntityAlpha(horse, math.floor(alpha))
			end
		end
		Wait(10)
	end
end

---@param model string
---@param coords vec3
---@param heading float
---@param networked boolean
---@param fadeDuration integer duration of the fade in ms
function jo.entity.create(model, coords, heading, networked, fadeDuration)
	networked = networked or false
	fadeDuration = fadeDuration or 0
	local model = GetHashFromString(model)
	jo.utils.loadGameData(model, true)
	local entity
	if IsModelAPed(model) then
		entity = CreatePed(model, vec4(0, 0, 0, 0), networked)
		if model == joaat("mp_female") then
			EquipMetaPedOutfitPreset(entity, 7)
			ApplyShopItemToPed(entity, joaat('CLOTHING_ITEM_F_HEAD_001_V_001'), true, true, false) --head
			ApplyShopItemToPed(entity, joaat('CLOTHING_ITEM_F_BODIES_UPPER_001_V_001'), true, true, false)
			ApplyShopItemToPed(entity, joaat('CLOTHING_ITEM_F_BODIES_LOWER_001_V_001'), true, true, false)
			ApplyShopItemToPed(entity, joaat('CLOTHING_ITEM_F_EYES_001_TINT_001'), true, true, false)
		elseif model == joaat('mp_male') then
			EquipMetaPedOutfitPreset(entity, 4)
			ApplyShopItemToPed(entity, joaat('CLOTHING_ITEM_M_HEAD_001_V_001'), true, true, false) --head
			ApplyShopItemToPed(entity, joaat('CLOTHING_ITEM_M_BODIES_UPPER_001_V_001'), true, true, false)
			ApplyShopItemToPed(entity, joaat('CLOTHING_ITEM_M_BODIES_LOWER_001_V_001'), true, true, false)
			ApplyShopItemToPed(entity, joaat('CLOTHING_ITEM_M_EYES_001_TINT_001'), true, true, false)
		else
			SetRandomOutfitVariation(entity, true)
		end
		SetAttributeCoreValue(entity, 0, 100)
		SetEntityHealth(entity, 600, 1)
		SetAttributeCoreValue(entity, 1, 100)
		RestorePedStamina(entity, 1065330373)
	elseif IsModelAnObject(model) then
		entity = CreateObject(model, vec3(0, 0, 0), networked, true, false)
	end
	SetModelAsNoLongerNeeded(model)
	if fadeDuration > 0 then
		SetEntityAlpha(entity, 0)
	end
	SetEntityCoords(entity, coords.xyz)
	SetEntityHeading(entity, heading * 1.0)
	if fadeDuration > 0 then
		jo.entity.fadeIn(entity, fadeDuration)
	end
	Entities[entity] = true
	return entity
end

