local Blips = {}
jo.createModule("blip")

jo.stopped(function()
  for _, blip in pairs(Blips) do
    RemoveBlip(blip)
  end
end)

--- Create a new blip
--- This function adds a blip at the specified location or on an entity with customizable properties.
---@param locationOrEntity vector3|integer The world coordinates or entity handle to attach the blip to
---@param name string The label displayed on the map for this blip
---@param sprite string|integer The sprite name or its hash ([Non exhaustive list](https://github.com/femga/rdr3_discoveries/tree/master/useful_info_from_rpfs/textures/blips))
---@param blipHash? integer The blip type hash - default: `BLIP_STYLE_PICKUP_WEAPON`
---@param color? string The color modifier name applied to the blip (resolved via `GetHashFromString`)
---@return integer|false blip The blip ID on success, or `false` if the entity does not exist
function jo.blip.create(locationOrEntity, name, sprite, blipHash, color)
  if not blipHash then blipHash = `BLIP_STYLE_PICKUP_WEAPON` end
  if type(sprite) == "string" then sprite = joaat(sprite) end

  local blip
  if type(locationOrEntity) == "number" then
    if not DoesEntityExist(locationOrEntity) then
      return false
    end
    blip = BlipAddForEntity(blipHash, locationOrEntity)
  else
    blip = BlipAddForCoords(blipHash, locationOrEntity.x, locationOrEntity.y, locationOrEntity.z)
  end

  SetBlipSprite(blip, sprite)
  SetBlipName(blip, name)
  if color then
    BlipAddModifier(blip, GetHashFromString(color))
  end
  Blips[#Blips + 1] = blip
  return blip
end
