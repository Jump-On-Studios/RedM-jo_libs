jo.component = {}

--- A function to get the head component hash from head index and skin tone
---@param ped integer (The entity ID)
---@param headIndex? integer (The head index, defaults to 1)
---@param skinTone? integer (The skin tone, defaults to 1)
---@return string (The head component hash string)
function jo.component.getHeadFromSkinTone(ped, headIndex, skinTone)
  local ped = ped or PlayerPedId()
  local sex = "M"
  if type(ped) == "string" then
    sex = "mp_male" and "M" or "F"
  else
    sex = IsPedMale(ped) and "M" or "F"
  end
  return ("CLOTHING_ITEM_%s_HEAD_%03d_V_%03d"):format(sex, headIndex or 1, skinTone or 1)
end

--- A function to get the lower body component hash from bodies index and skin tone
---@param ped integer|string (The entity ID or model name)
---@param bodiesIndex? integer (The bodies index, defaults to 1)
---@param skinTone? integer (The skin tone, defaults to 1)
---@return string (The lower body component hash string)
function jo.component.getBodiesLowerFromSkinTone(ped, bodiesIndex, skinTone)
  local ped = ped or PlayerPedId()
  local sex = "M"
  if type(ped) == "string" then
    sex = "mp_male" and "M" or "F"
  else
    sex = IsPedMale(ped) and "M" or "F"
  end
  return ("CLOTHING_ITEM_%s_BODIES_LOWER_%03d_V_%03d"):format(sex, bodiesIndex or 1, skinTone or 1)
end

--- A function to get the upper body component hash from bodies index and skin tone
---@param ped integer|string (The entity ID or model name)
---@param bodiesIndex? integer (The bodies index, defaults to 1)
---@param skinTone? integer (The skin tone, defaults to 1)
---@return string (The upper body component hash string)
function jo.component.getBodiesUpperFromSkinTone(ped, bodiesIndex, skinTone)
  local ped = ped or PlayerPedId()
  local sex = "M"
  if type(ped) == "string" then
    sex = "mp_male" and "M" or "F"
  else
    sex = IsPedMale(ped) and "M" or "F"
  end
  return ("CLOTHING_ITEM_%s_BODIES_UPPER_%03d_V_%03d"):format(sex, bodiesIndex or 1, skinTone or 1)
end

--- A function to get the eyes component hash from an index
---@param ped integer|string (The entity ID or model name)
---@param index? integer (The eyes index, defaults to 1)
---@return string (The eyes component hash string)
function jo.component.getEyesFromIndex(ped, index)
  local ped = ped or PlayerPedId()
  local sex = "M"
  if type(ped) == "string" then
    sex = "mp_male" and "M" or "F"
  else
    sex = IsPedMale(ped) and "M" or "F"
  end
  return ("CLOTHING_ITEM_%s_EYES_001_TINT_%03d"):format(sex, index or 1)
end

--- A function to get the teeth component hash from an index
---@param ped integer|string (The entity ID or model name)
---@param index? integer (The teeth index, defaults to 1)
---@return string (The teeth component hash string)
function jo.component.getTeethFromIndex(ped, index)
  local ped = ped or PlayerPedId()
  local sex = "M"
  if type(ped) == "string" then
    sex = "mp_male" and "M" or "F"
  else
    sex = IsPedMale(ped) and "M" or "F"
  end
  return ("CLOTHING_ITEM_%s_TEETH_%03d"):format(sex, index or 1)
end
