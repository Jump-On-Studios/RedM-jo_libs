jo.createModule("network")

local doesNetworkIdExist = NetworkDoesNetworkIdExist
local doesEntityExist = DoesEntityExist
local getEntityFromNetd = NetworkGetEntityFromNetworkId
local isEntityNetworked = NetworkGetEntityIsNetworked

function jo.network.getNetIdFromEntity(entity)
  if not doesEntityExist(entity) then
    return 0
  end
  if jo.isClientSide() then
    if not isEntityNetworked(entity) then
      return 0
    end
  end
  return isEntityNetworked(entity)
end

function jo.network.isEntityNetworked(entity)
  return jo.network.getNetIdFromEntity(entity) ~= 0
end

function jo.network.getEntityFromNetId(netId)
  return getEntityFromNetd(netId)
end

function jo.network.getEntityFromStateBag(stateBag)
  if not bagName then return 0 end
	if type(bagName) ~= "string" then return 0 end
	if not bagName:find("entity:") then return 0 end
	local netId = tonumber(bagName:sub(8) or 0)
	jo.waiter.exec(function()
		return doesNetworkIdExist(netId)
	end, nil, 100)
	if not doesNetworkIdExist(netId) then
		if doesEntityExist(netId) then
			return netId
		end
		return 0
	end
	return getEntityFromNetd(netId)
end

-------------
-- Shortcut
-------------
jo.net = jo.network
