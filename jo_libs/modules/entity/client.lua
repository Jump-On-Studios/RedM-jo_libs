jo.require("utils")

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

--- Request control of an entity and wait until it's granted
---@param entity integer (The entity ID to request control of)
function jo.entity.requestControl(entity)
	while not NetworkHasControlOfEntity(entity) do
		NetworkRequestControlOfEntity(entity)
		Wait(100)
	end
end

--- Delete an entity if it exists
---@param entity integer (The entity ID to delete)
function jo.entity.delete(entity)
	if not DoesEntityExist(entity) then return end
	DeleteEntity(entity)
	Entities[entity] = nil
end

--- Fade out an entity and then delete it
---@param entity integer (The entity ID to fade and delete)
---@param duration? integer (Duration of the fade effect in ms <br> default:1000)
function jo.entity.fadeAndDelete(entity, duration)
	duration = duration or 1000
	if not DoesEntityExist(entity) then return end
	if GetResourceState(jo.resourceName) == "stopped" then return jo.entity.delete(entity) end

	jo.entity.fadeOut(entity, duration)
	jo.entity.delete(entity)
end

--- Fade in an entity from transparent to fully visible
---@param entity integer (The entity ID to fade in)
---@param duration? integer (Duration of the fade effect in ms <br> default:1000)
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

--- Fade out an entity from visible to transparent
---@param entity integer (The entity ID to fade out)
---@param duration? integer (Duration of the fade effect in ms - default:1000)
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

--- Create a new entity at specified location
--- - if coords is a vector4, heading is not required
---@param model string (The model name of the entity to create)
---@param coords vector3|vector4 (The coordinates where the entity will be created)
---@param heading? number (The heading direction for the entity if coords is vec3)
---@param networked? boolean (Whether the entity should be networked <br> default: `false`)
---@param fadeDuration? integer (Duration of the fade-in effect in ms <br> default: `0`)
---@return integer (The created entity ID)
function jo.entity.create(model, coords, ...)
	local args = { ... }
	local networked, fadeDuration = false, 0
	if type(coords) == vector4 then
		networked = GetValue(args[1], false)
		fadeDuration = GetValue(args[2], 0)
	else
		coords = vec4(coords.x, coords.y, coords.z, GetValue(args[1], 0))
		networked = GetValue(args[2], false)
		fadeDuration = GetValue(args[3], 0)
	end
	model = GetHashFromString(model)
	jo.utils.loadGameData(model, true)
	local entity
	if IsModelAPed(model) then
		entity = CreatePed(model, vec4(0, 0, 0, 0), networked)
		if model == joaat("mp_female") then
			EquipMetaPedOutfitPreset(entity, 7)
			ApplyShopItemToPed(entity, joaat("CLOTHING_ITEM_F_HEAD_001_V_001"), true, true, false) --head
			ApplyShopItemToPed(entity, joaat("CLOTHING_ITEM_F_BODIES_UPPER_001_V_001"), true, true, false)
			ApplyShopItemToPed(entity, joaat("CLOTHING_ITEM_F_BODIES_LOWER_001_V_001"), true, true, false)
			ApplyShopItemToPed(entity, joaat("CLOTHING_ITEM_F_EYES_001_TINT_001"), true, true, false)
		elseif model == joaat("mp_male") then
			EquipMetaPedOutfitPreset(entity, 4)
			ApplyShopItemToPed(entity, joaat("CLOTHING_ITEM_M_HEAD_001_V_001"), true, true, false) --head
			ApplyShopItemToPed(entity, joaat("CLOTHING_ITEM_M_BODIES_UPPER_001_V_001"), true, true, false)
			ApplyShopItemToPed(entity, joaat("CLOTHING_ITEM_M_BODIES_LOWER_001_V_001"), true, true, false)
			ApplyShopItemToPed(entity, joaat("CLOTHING_ITEM_M_EYES_001_TINT_001"), true, true, false)
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
	SetEntityHeading(entity, coords.w)
	if fadeDuration > 0 then
		CreateThreadNow(function()
			jo.entity.fadeIn(entity, fadeDuration)
		end)
	end
	Entities[entity] = true
	return entity
end

local spriteDimensions = nil
--- Raycast from the camera through the screen center and return what was hit
--- Displays a small crosshair sprite at screen center
--- Must be called each frame to render the crosshair
---@param distance? number (Maximum raycast distance <br> default:`100`)
---@param flags? integer ([Flags](https://docs.fivem.net/natives/?_0x7EE9F5D83DD4F90E) for the raycast <br> default:`16`)
---@param toIgnore? integer (Entity to ignore in the raycast <br> default:`PlayerPedId()`)
---@return boolean,vector3,integer (Hit status, hit coordinates, hit entity)
function jo.entity.getEntityInCrosshair(distance, flags, toIgnore)
	if not flags then flags = 16 end
	if not spriteDimensions then
		spriteDimensions = {}
		local width, height = GetCurrentScreenResolution()
		spriteDimensions.width = 9.6 / width
		spriteDimensions.height = 8.1 / height
	end

	jo.utils.loadGameData("hud_textures", true)
	DrawSprite("hud_textures", "breadcrumb", 0.5, 0.5, spriteDimensions.width, spriteDimensions.height, 0.0, 255, 255, 255, 240, false)
	local hit, endCoords, _, entityHit = jo.utils.screenToWorld(distance, flags, toIgnore, 0.5, 0.5)
	return hit, endCoords, entityHit
end

--- Create an entity that follows the mouse cursor for placement
---@param model string (The model name of the entity to create)
---@param keepEntity? boolean (Whether to keep the entity after placement <br> default:true)
---@param networked? boolean (Whether the entity should be networked <br> default:false)
---@return integer,vector3,number (The created entity ID, final position, final heading)
function jo.entity.createWithMouse(model, keepEntity, networked)
	networked = networked or false
	if keepEntity == nil then keepEntity = true end
	model = GetHashFromString(model)
	camFov = GetFinalRenderedCamFov()


	local origin = GetOffsetFromEntityInWorldCoords(jo.me, 0.0, 5.0, 0.0)
	local previousCoord = origin
	local heading = 0
	local entity = jo.entity.create(model, origin, heading, false)
	local maxDistanceCreate = 10

	SetEntityCompletelyDisableCollision(entity, false, false)
	SetEntityAlpha(entity, 200, false)

	local groupPrompt = "interaction_mouse"

	jo.prompt.create(groupPrompt, "Rotate", { "INPUT_SELECT_NEXT_WEAPON", "INPUT_SELECT_PREV_WEAPON" })
	jo.prompt.create(groupPrompt, "Place", "INPUT_CONTEXT_RT", 1500)
	jo.prompt.create(groupPrompt, "Cancel", "INPUT_CONTEXT_LT", 1500)

	while true do
		DisableControlAction(0, `INPUT_ATTACK`, true)
		DisableControlAction(0, `INPUT_AIM`, true)

		local hit, targetCoord = jo.utils.screenToWorld(maxDistanceCreate)
		origin = GetEntityCoords(jo.me)

		if hit and #(targetCoord - origin) <= maxDistanceCreate and #(previousCoord - targetCoord) > 0.025 then
			previousCoord = targetCoord
			SetEntityCoords(entity, targetCoord)
		end

		if IsControlPressed(0, `INPUT_SELECT_PREV_WEAPON`) then
			heading = (heading - 5 + 360) % 360
			SetEntityHeading(entity, heading * 1.0)
		end
		if IsControlPressed(0, `INPUT_SELECT_NEXT_WEAPON`) then
			heading = (heading + 5) % 360
			SetEntityHeading(entity, heading * 1.0)
		end

		if jo.prompt.isCompleted(groupPrompt, "INPUT_CONTEXT_RT") then
			break
		end

		if jo.prompt.isCompleted(groupPrompt, "INPUT_CONTEXT_LT") then
			previousCoord = false
			break
		end
		Wait(0)
	end
	jo.prompt.deleteGroup(groupPrompt)

	jo.entity.delete(entity)
	if keepEntity then
		entity = jo.entity.create(model, previousCoord, heading, networked)
	end

	return entity, previousCoord, heading
end

--- Delete all scenarios from an entity
---@param entity integer (The entity ID to delete scenarios from)
---@param size? number (The size of the area to search for scenarios <br> default:2.0)
---@param maxScenario? number (The maximum number of scenarios to search for <br> default:8)
---@param maxAttempt? number (The maximum number of attempts to delete scenarios <br> default:10)
---@param waitTime? number (The time to wait between attempts to delete scenarios <br> default:100)
function jo.entity.deleteScenariosFromEntity(entity, size, maxScenario, maxAttempt, waitTime)
	if not DoesEntityExist(entity) then return eprint("Entity does not exist", entity) end
	size = size or 2.0
	maxScenario = maxScenario or 8
	maxAttempt = maxAttempt or 10
	waitTime = waitTime or 100
	CreateThreadNow(function()
		for attempt = 1, maxAttempt do
			local coordinates = GetEntityCoords(entity)
			local data = DataView.ArrayBuffer(8 * (maxScenario + 2))
			local get = GetScenarioPointsInArea(coordinates, size, data:Buffer(), maxScenario)
			if get then
				local find = false
				for j = 1, maxScenario + 2 do
					local value = data:GetInt32(j * 8 - 8)
					if (value ~= 0) then
						local scenarioEntity = GetScenarioPointEntity(value)
						if entity == scenarioEntity then
							SetScenarioPointActive(value, false)
							find = true
						end
					end
				end
				if find then return end
			end
			Wait(waitTime)
		end
	end)
end
