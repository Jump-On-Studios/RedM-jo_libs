--- A function to load a game file
---@param name string|integer (The name of the file <br> Compatible with animation dictionaries, models (hashed or string), and texture dictionaries)
---@param waiter? boolean (If the function has to wait after the loading to be completed)
function jo.utils.loadGameData(name, waiter)
	local model = (type(name) == "string") and joaat(name) or name
	if IsModelValid(model) then
		if not HasModelLoaded(model) then
			RequestModel(model)
			while waiter and not HasModelLoaded(model) do
				Wait(0)
			end
		end
		return
	end
	if DoesAnimDictExist(name) then
		if not HasAnimDictLoaded(name) then
			RequestAnimDict(name)
			while waiter and not HasAnimDictLoaded(name) do
				Wait(0)
			end
		end
		return
	end
	if DoesStreamedTextureDictExist(name) then
		if not HasStreamedTextureDictLoaded(name) then
			RequestStreamedTextureDict(name, true)
			while waiter and not HasStreamedTextureDictLoaded(name) do
				Wait(0)
			end
		end
		return
	end
end

--- A function to release a game file
---@param name string|integer (The name of the file)
function jo.utils.releaseGameData(name)
	local model = (type(name) == "string") and joaat(name) or name
	if IsModelValid(model) then
		if HasModelLoaded(model) then
			SetModelAsNoLongerNeeded(model)
		end
		return
	end
	if DoesStreamedTextureDictExist(name) then
		if HasStreamedTextureDictLoaded(name) then
		end
		return
	end
	if DoesAnimDictExist(name) then
		if not HasAnimDictLoaded(name) then
			if HasAnimDictLoaded(name) then
				RemoveAnimDict(name)
			end
		end
	end
end

--- A function to wait after a satisfying condition with a waiting duration
---@param cb function (If the function returns `true` a new timer value is waited)
---@param maxDuration? integer (The maximum duration the function will wait <br> default: 1000)
---@param loopTimer? integer (The delay between tests of cb function in ms <br> default: 0)
---@return boolean (Returns `true` if the function is satisfied, `false` if the waiter was killed by the maxDuration value)
function jo.utils.waiter(cb, maxDuration, loopTimer)
	local endTimer = GetGameTimer() + (maxDuration or 1000)
	while cb() do
		Wait(loopTimer or 0)
		if endTimer < GetGameTimer() then
			return false
		end
	end
	return true
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
local width, height = GetCurrentScreenResolution()
local screenRatio = width / height

local function screenPositionToCameraRay(screenX, screenY)
	local pos = GetFinalRenderedCamCoord()
	local rot = glm_rad(GetFinalRenderedCamRot(2))

	local q = glm_quatEulerAngleZYX(rot.z, rot.y, rot.x)
	return pos, glm_rayPicking(
		q * glm_forward,
		q * glm_up,
		glm_rad(camFov),
		screenRatio,
		0.10000,   -- GetFinalRenderedCamNearClip(),
		1000.0,    -- GetFinalRenderedCamFarClip(),
		screenX * 2 - 1, -- scale mouse coordinates from [0, 1] to [-1, 1]
		screenY * 2 - 1
	)
end


--- Converts screen coordinates to world coordinates using camera raycasting
--- This function casts a ray from the camera through the specified screen position and returns information about what it hits in the 3D world
---@param distance? number (Maximum raycast distance in game units <br> default:`100`)
---@param flags? integer ([Flags](https://docs.fivem.net/natives/?_0x7EE9F5D83DD4F90E) for the raycast <br> default:`1|2|8|16`)
---@param toIgnore? integer (Entity to ignore in the raycast <br> default:`PlayerPedId()`)
---@param mouseX? number (X screen coordinate normalized between 0-1 <br> default:`0.5` screen center)
---@param mouseY? number (Y screen coordinate normalized between 0-1 <br> default:`0.5` screen center)
---@return boolean,vector3,vector3,integer (hit, endCoords, surfaceNormal, entityHit)
function jo.utils.screenToWorld(distance, flags, toIgnore, mouseX, mouseY)
	distance = distance or 100
	flags = flags or (1|2|8|16)
	toIgnore = toIgnore or PlayerPedId()
	mouseX = mouseX or 0.5 -- Default to screen center if not provided
	mouseY = mouseY or 0.5 -- Default to screen center if not provided

	-- Create a ray from the camera origin that extends through the mouse cursor
	local r_pos, r_dir = screenPositionToCameraRay(mouseX, mouseY)
	local b = r_pos + distance * r_dir
	if flags == 0 then return false, b, r_dir, 0 end
	local rayHandle = StartShapeTestRay(r_pos, b, flags, toIgnore, 0)
	local a, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)
	return hit, endCoords, surfaceNormal, entityHit
end
