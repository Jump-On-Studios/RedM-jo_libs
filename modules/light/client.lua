jo.light = {}
local lightActives = {}

jo.require('table')
jo.require('math')
jo.require('timeout')

---@class Light : table Light class
local LightClass = {
  id = 1,
  coords = vec3(0,0,0),
  targetCoords = vec3(0,0,0),
  rgb = {255, 160, 122},
  range = 10.0,
  intensity = 0.0,
  targetIntensity = 1.0,
  ease = 1000,
  deleted = false
}

local function deleteLight(id)
  table.remove(lightActives, id)
  local lightCount = #lightActives
  for i = 1, lightCount do
    lightActives[i].id = i
  end
end

function LightClass:delete()
  self.deleted = true
  self:setIntensity(0)
  if not self.ease then
    deleteLight(self.id)
  end
end

function LightClass:setCoords(coords)
  self.targetCoords = coords
end

function LightClass:setIntensity(intensity)
  self.targetIntensity = intensity * 1.0
end

function LightClass:update(deltaTime)
  if self.intensity ~= self.targetIntensity then
    if not self.ease or self.ease == 0 then
      self.intensity = self.targetIntensity
    else
      local t = deltaTime / self.ease
      self.intensity = math.lerp(self.intensity, self.targetIntensity, t)
      if math.abs(self.intensity - self.targetIntensity) < 0.01 then
        self.intensity = self.targetIntensity -- Evite les oscillations autour de la valeur cible
      end
    end
  end
  if self.coords ~= self.targetCoords then
    if not self.ease or self.ease == 0 then
      self.coords = self.targetCoords
    else
      local t = deltaTime / self.ease
      local x = math.lerp(self.coords.x, self.targetCoords.x, t)
      local y = math.lerp(self.coords.y, self.targetCoords.y, t)
      local z = math.lerp(self.coords.z, self.targetCoords.z, t)
      self.coords = vec3(x,y,z)
      if #(self.coords - self.targetCoords) < 0.01 then
        self.coords = self.targetCoords
      end
    end
  end
end

function jo.light.create(coords,intensity,rgb,range,ease)
  local light = table.copy(LightClass)
  light.coords = coords
  light.targetCoords = coords
  light.rgb = rgb or light.rgb
  light.range = range or light.range
  light.intensity = light.intensity
  light.targetIntensity = intensity or light.targetIntensity
  light.ease = ease or light.ease

  if not light.ease then
    light.intensity = light.targetIntensity
  end

  table.insert(lightActives,light)

  light.id = #lightActives
  return light
end

CreateThread(function()
  local deltaTime,oldTime,counter = 0,GetGameTimer(),0
  while true do
    deltaTime = GetGameTimer() - oldTime
    oldTime = GetGameTimer()
    counter = 0
    for _,light in pairs (lightActives) do
      counter += 1
      light:update(deltaTime)
      DrawLightWithRange(light.coords.x,light.coords.y,light.coords.z,light.rgb[1], light.rgb[2], light.rgb[3], light.range, light.intensity)
      if light.deleted and light.intensity == 0 then
        deleteLight(light.id)
      end
    end
    Wait(counter == 0 and 100 or 0)
  end
end)
