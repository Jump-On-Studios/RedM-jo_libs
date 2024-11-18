jo.camera = {}

jo.require('math')

local marginFov = 0.01     --max gap between two fovs to accept them like same fov
local marginCoords = 0.001 --max gap between two coords to accept them like same coords
local cameras = {}

local camClass = {
  cam = 0,
  ease = 0,
  coords = vec3(0, 0, 0),
  fov = 30.0,
  status = "off",
  startMove = 0
}

local function getCurrentCam()
  if IsGameplayCamRendering() then
    return 0
  end
  return GetRenderingCam()
end

local function getCurrentCamFov()
  local cam = getCurrentCam()
  if cam == 0 then
    return GetGameplayCamFov()
  end
  return GetCamFov(cam)
end

local function getCurrentCamCoords()
  local cam = getCurrentCam()
  if cam == 0 then
    return GetGameplayCamCoord()
  end
  return GetCamCoord(cam)
end

function camClass:get()
  return self.cam
end

function camClass:setEase(ease)
  self.ease = ease or 0
end

function camClass:update()
  self.oldFov = getCurrentCamFov()
  self.oldCoords = getCurrentCamCoords()
  print(self.oldCoords)
  self.startMove = GetGameTimer()
  if self.status == "interpoling" then return end
  self.status = "interpoling"
  print('new interpoling')
  CreateThread(function()
    local deltaTime = 0
    local currentFov = self.oldFov
    local currentCoords = self.oldCoords
    local startOS = GetGameTimer()
    local totalFrame = 0
    while true do
      deltaTime = GetGameTimer() - self.startMove
      local t = math.min(deltaTime / self.ease, 1.0)
      print("t:", t)
      if currentFov ~= self.fov then
        currentFov = math.lerp(self.oldFov, self.fov, t)
        if t == 1.0 then
          currentFov = self.fov -- Evite les oscillations autour de la valeur cible
        end
        SetCamFov(self.cam, currentFov)
      end
      if #(currentCoords - self.coords) > marginCoords then
        currentCoords = vec3(
          math.lerp(self.oldCoords.x, self.coords.x, t),
          math.lerp(self.oldCoords.y, self.coords.y, t),
          math.lerp(self.oldCoords.z, self.coords.z, t)
        )
        if t == 1.0 then
          currentCoords = self.coords -- Evite les oscillations autour de la valeur cible
        end
        SetCamCoord(self.cam, currentCoords)
      end
      if t == 1.0 then break end
      Wait(0)
    end
    self.status = "on"
    print(GetGameTimer())
    print('DONE', GetGameTimer() - startOS, totalFrame)
  end)
end

function camClass:setFov(fov)
  if not fov then return eprint('camClass:setFov() -> fov is nil') end
  self.fov = fov
  if self.ease == 0 then
    SetCamFov(self.cam, self.fov)
    return
  end
  self:update()
end

function camClass:setCoords(coords)
  if not coords then return eprint('camClass:setCoords() -> coords is nil') end
  self.coords = coords
  if self.ease == 0 then
    SetCamCoord(self.cam, self.coords)
    return
  end
  self:update()
end

function camClass:render(easeDuration)
  easeDuration = easeDuration or 0
  SetCamActive(self.cam, true)
  RenderScriptCams(true, self.cam, easeDuration, true, true)
end

function camClass:destroy(easeDuration)
  if DoesCamExist(self.cam) then
    DestroyCam(self.cam)
  end
end

jo.camera.create = function(coords, fov)
  local cam = table.copy(camClass)
  cam.cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
  SetCamCoord(cam.cam, coords or GetEntityCoords(PlayerPedId()))
  SetCamFov(cam.cam, fov or 30.0)
  cameras[#cameras + 1] = cam
  return cam
end

jo.stopped(function()
  for _, cam in pairs(cameras) do
    cam:destroy()
  end
end)

return jo.camera
