local Blips = {}
jo.blip = {}

jo.stopped(function()
  for _, blip in pairs(Blips) do
    RemoveBlip(blip)
  end
end)

---@param location table the location of the blip
---@param name string name of the blip
---@param sprite string sprite of the blip
---@param blipHash? integer the type of blip
---@param color? string the blip color
---@return integer blip the blip ID
function jo.blip.create(location, name, sprite, blipHash, color)
  if not blipHash then blipHash = 1664425300 end
  if type(sprite) == "string" then sprite = joaat(sprite) end
  local blip = BlipAddForCoords(blipHash, location.x, location.y, location.z)
  SetBlipSprite(blip, sprite)
  SetBlipName(blip, name)
  if color then
    BlipAddModifier(blip, GetHashFromString(color))
  end
  Blips[#Blips + 1] = blip
  return blip
end
