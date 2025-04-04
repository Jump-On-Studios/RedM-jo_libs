jo.utils = {}

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
