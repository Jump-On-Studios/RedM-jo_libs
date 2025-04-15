local Blips = {}
jo.blip = {}

jo.stopped(function()
  for _, blip in pairs(Blips) do
    RemoveBlip(blip)
  end
end)

--- Create a new blip
--- This function adds a blip at the specified location with customizable properties.
---@param location vector3 (The blip location)
---@param name string (The blip name)
---@param sprite string (The name of the sprite ([Non exhaustive list](https://github.com/femga/rdr3_discoveries/tree/master/useful_info_from_rpfs/textures/blips)))
---@param blipHash? integer (The blip type - default: 1664425300)
---@param color? string (The color of the blip)
---@return integer (Return the blip ID)
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
