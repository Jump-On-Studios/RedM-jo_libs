jo.utils = {}

---@param name string
---@param waiter? boolean need wait
function jo.utils.loadGameData(name,waiter)
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

---@param name string
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


---@param cb function the tester
---@param maxDuration integer (default: 1000)
---@param loopTimer integer (default: 0)
function jo.utils.waiter(cb,maxDuration,loopTimer)
	local endTimer = GetGameTimer()+ (maxDuration or 1000)
	while cb() do
		Wait(loopTimer or 0)
		if endTimer < GetGameTimer() then
			return false
		end
	end
	return true
end
