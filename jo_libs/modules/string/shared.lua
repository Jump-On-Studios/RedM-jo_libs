-- todo add usePostProcess=false

--- Return the string with the first letter in uppercase
---@return string (Return the string with the first letter in uppercase)
function string:firstToUpper()
  if not self then return "" end
  return (self:gsub("^%l", string.upper))
end

--- Split a string into parts based on a delimiter
---@param delimiter string (The character(s) to split the string on)
---@param pieces? number (The maximum number of pieces to split into)
---@return table (Array of string parts)
function string:split(delimiter, pieces)
  return { self:strsplit(delimiter, pieces) }
end

--- Convert a version string (like "1.2.3") to a numeric value
---@return number (The converted numeric version)
function string:convertVersion()
  if not self then return 1 end
  local converted = 0
  if type(self) == "string" then
    local array = self:split("%.")
    local multiplicator = 1
    for i = #array, 1, -1 do
      converted = converted + multiplicator * array[i]
      multiplicator = multiplicator * 1000
    end
  end
  return converted
end

--- Remove whitespace from both ends of a string
---@return string (The trimmed string)
function string:trim()
  if not self then return "" end
  return self:match("^%s*(.-)%s*$")
end

--- Convert a hexadecimal string to a number, handling signed values
---@return number (The converted numeric value)
function string:toHex()
  local number = tonumber(self:sub(3), 16) -- Convertit la chaîne hexadécimale en nombre
  if not number then return self end
  if number >= 0x80000000 then
    number = number - 0x100000000 -- Ajuster pour une valeur signée
  end
  return number
end

jo.string = {}
