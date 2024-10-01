local eventListened = {}
local groupListened = {}

jo.require('dataview')
jo.require('file')
jo.file.load('game-events.data')

local function GetEventData(...) return Citizen.InvokeNative(0x57EC5FA4D4D6AFCA, ...) end

local eventsData = {}
for _, data in pairs(AllGameEvents) do
  eventsData[joaat(data.name)] = data
end

AddEventHandler('jo_libs:gameEvents:register', function(eventName)
  local eventHash = GetHashFromString(eventName)
  local eventData = eventsData[eventHash]
  eventListened[eventHash] = true
  groupListened[eventData.group] = true
end)

local function getDataFromEvent(eventHash, index)
  local eventData = eventsData[eventHash]

  local datas = {}

  local size = eventData.size
  local dataStruct = DataView.ArrayBuffer(8 * size)
  for i = 0, size - 1 do
    local info = eventData.data[i + 1]
    if info.type == "int" then
      dataStruct:SetInt32(8 * i, 0)
    elseif info.type == "float" then
      dataStruct:SetFloat32(8 * i, 0)
    elseif info.type == "bool" then
      dataStruct:SetInt32(8 * i, 0)
    end
  end
  local isDataExist = GetEventData(eventData.group, index, dataStruct:Buffer(), size)
  if not isDataExist then return false end
  for i = 0, size - 1 do
    local info = eventData.data[i + 1]
    if info.type == "int" then
      datas[info.name] = dataStruct:GetInt32(8 * i)
    elseif info.type == "float" then
      datas[info.name] = dataStruct:GetFloat32(8 * i)
    elseif info.type == "bool" then
      datas[info.name] = dataStruct:GetInt32(8 * i)
    end
    datas['value_' .. i] = dataStruct:GetInt32(8 * i)
  end
  return datas
end

local function getEventNameFromHash(eventHash)
  return eventsData[eventHash].name
end

local function processEvent(groupId, index)
  local eventHash = GetEventAtIndex(groupId, index)
  if not eventListened[eventHash] then return end
  local data = getDataFromEvent(eventHash, index)
  if not data then return false end
  local eventData = eventsData[eventHash]
  TriggerEvent('jo_libs:gameEvents:' .. eventData.name, data)
end

local function listenEvents()
  for groupId, _ in pairs(groupListened) do
    local size = GetNumberOfEvents(tonumber(groupId))
    if size > 0 then
      for i = 0, size - 1 do
        processEvent(groupId, i)
      end
    end
  end
end

CreateThread(function()
  while true do
    listenEvents()
    Wait(0)
  end
end)
