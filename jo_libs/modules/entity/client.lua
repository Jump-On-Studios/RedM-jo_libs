jo.entity = {}

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

return jo.entity