---@param str stringlib
---@return string str String with first letter in uppercase
function string:firstToUpper()
  if not self then return "" end
  return (self:gsub("^%l", string.upper))
end

function string:split(delimiter, pieces)
  return { string.strsplit(delimiter, self, pieces) }
end

function string:convertVersion()
  if not self then return 1 end
  local converted = 0
  if type(self) == "string" then
    local array = self:split("%.")
    log(array)
    local multiplicator = 1
    for i = #array, 1, -1 do
      converted = converted + multiplicator * (tonumber(array[i]) or 0)
      multiplicator = multiplicator * 1000
    end
  end
  return converted
end

-- Returns -1 if the version is older, 0 if it's the same and 1 if it's more recent
function string:compareVersionWith(version)
  if not self then return -1 end
  if not version then return 1 end

  local version1, version2 = self:split("."), version:split(".")
  local len = math.max(#version1, #version2)
  for i = 1, len do
    local p1, p2 = version1[i], version2[i]
    if p1 == nil and p2 ~= nil then
      if tonumber(p2) == nil then
        return 1
      else
        return -1
      end
    elseif p1 ~= nil and p2 == nil then
      return -1
    end
    local num1, num2 = tonumber(p1), tonumber(p2)
    --Compare version number
    if num1 and num2 then
      if num1 < num2 then
        return -1
      elseif num1 > num2 then
        return 1
      end
    elseif num1 and not num2 then
      return -1
    elseif not num1 and num2 then
      return 1
      --Compare string
    else
      if p1 < p2 then
        return -1
      elseif p1 > p2 then
        return 1
      end
    end
  end
  return 0
end

function string:trim()
  if not self then return "" end
  return self:match("^%s*(.-)%s*$")
end

function string:toHex()
  local number = tonumber(self:sub(3), 16) -- Convertit la chaîne hexadécimale en nombre
  if not number then return self end
  if number >= 0x80000000 then
    number = number - 0x100000000 -- Ajuster pour une valeur signée
  end
  return number
end

jo.string = {}
