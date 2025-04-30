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
		Citizen.CreateThreadNow(function()
			jo.entity.fadeIn(entity, fadeDuration)
		end)
	end
	Entities[entity] = true
	return entity
end

--- Source: https://github.com/citizenfx/lua/blob/luaglm-dev/cfx/libs/scripts/examples/scripting_gta.lua
--- Credits to gottfriedleibniz
local glm = require "glm"

local glm_rad = glm.rad
local glm_quatEulerAngleZYX = glm.quatEulerAngleZYX
local glm_rayPicking = glm.rayPicking
local glm_up = glm.up()
local glm_forward = glm.forward()
local camFov = GetFinalRenderedCamFov()
local screenRatio = 16 / 9

function ScreenPositionToCameraRay(screenX, screenY)
	local pos = GetFinalRenderedCamCoord()
	local rot = glm_rad(GetFinalRenderedCamRot(2))

	local q = glm_quatEulerAngleZYX(rot.z, rot.y, rot.x)
	return pos, glm_rayPicking(
		q * glm_forward,
		q * glm_up,
		glm_rad(camFov),
		screenRatio,
		0.10000,       -- GetFinalRenderedCamNearClip(),
		1000.0,        -- GetFinalRenderedCamFarClip(),
		screenX * 2 - 1, -- scale mouse coordinates from [0, 1] to [-1, 1]
		screenY * 2 - 1
	)
end

local function screenToWorld(distance, flags, toIgnore)
	distance = distance or 100
	flags = flags or (1|2|8|16)
	toIgnore = toIgnore or PlayerPedId()

	-- Create a ray from the camera origin that extends through the mouse cursor
	local r_pos, r_dir = ScreenPositionToCameraRay(0.5, 0.5)
	local b = r_pos + distance * r_dir
	local rayHandle = StartShapeTestRay(r_pos, b, flags, toIgnore, 0)
	-- local rayHandle = StartExpensiveSynchronousShapeTestLosProbe(cam3DPos, direction, 1|2|8|16, toIgnore, 0)
	local a, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)
	return hit, endCoords, surfaceNormal, entityHit
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
	local screenResoX, screenResoY = GetScreenResolution()
	screenRatio = screenResoX / screenResoY

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

		local hit, targetCoord = screenToWorld(maxDistanceCreate)
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
