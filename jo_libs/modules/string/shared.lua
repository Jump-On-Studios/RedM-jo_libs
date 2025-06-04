-- todo add usePostProcess=false
---@format disable-next
local accentMap = {
  ["Á"]="A",["À"]="A",["Â"]="A",["Ä"]="A",["á"]="a",["à"]="a",["â"]="a",["ä"]="a",
  ["É"]="E",["È"]="E",["Ê"]="E",["Ë"]="E",["é"]="e",["è"]="e",["ê"]="e",["ë"]="e",
  ["Í"]="I",["Ì"]="I",["Î"]="I",["Ï"]="I",["í"]="i",["ì"]="i",["î"]="i",["ï"]="i",
  ["Ó"]="O",["Ò"]="O",["Ô"]="O",["Ö"]="O",["ó"]="o",["ò"]="o",["ô"]="o",["ö"]="o",
  ["Ú"]="U",["Ù"]="U",["Û"]="U",["Ü"]="U",["ú"]="u",["ù"]="u",["û"]="u",["ü"]="u",
  ["Ñ"]="N",["ñ"]="n",["Ç"]="C",["ç"]="c",
}
local segmentCache = setmetatable({}, { __mode = "v" })


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
  return { string.strsplit(delimiter, self, pieces) }
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
      converted = converted + multiplicator * (tonumber(array[i]) or 0)
      multiplicator = multiplicator * 1000
    end
  end
  return converted
end

--- Compare two version strings
--- @param version string (The string version to compare to)
--- @return integer ( `-1` if the version is older, `0` if it's the same and `1` if it's more recent)
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

--- Remove whitespace from both ends of a string
---@return string (The trimmed string)
function string:trim()
  if not self then return "" end
  return self:strtrim()
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

--- Convert a integer|number to a spaced number
---@param number integer|number (The number to convert)
---@param decimal? integer (The number of decimal <br> default: 0)
function string.spaceNumber(number, decimal)
  local s = string.format("%." .. (decimal or 0) .. "f", number)
  local n, i, f = s:match("^(-?)(%d*)(.*)$")
  i = i and (i:reverse():gsub("(%d%d%d)", "%1 "):reverse()) or ""
  i = i:gsub("^(-?) ", "%1")
  return (n or "") .. i .. (f or "")
end

--- A function to remove all accent in a string
---@return string (A string without accent)
function string:removeAccent()
  return (self:gsub("[%z\1-\127\194-\244][\128-\191]*", accentMap))
end

local function getStringSegment(str, caseSensitive)
  caseSensitive = caseSensitive or false
  local s = str:removeAccent():trim()
  if not caseSensitive then
    s = s:lower()
  end
  local segs = {}
  local pos, len = 1, #s
  while pos <= len do
    local num = s:match("^(%d+)", pos)
    if num then
      segs[#segs + 1] = tonumber(num)
      pos = pos + #num
    else
      local txt = s:match("^[^%d]+", pos)
      segs[#segs + 1] = txt
      pos = pos + #txt
    end
  end
  return segs
end

--- A function to compare two strings
---@param a string (The 1st string)
---@param b string (The 2nd string)
---@param caseSensitive boolean (If the compare is case sensitive<br>default: `false`)
---@return integer (`-1` if `a` is previous, `0` if both are same and `1` if `a` is after)
function string.compare(a, b, caseSensitive)
  caseSensitive = caseSensitive or false
  a = tostring(a)
  b = tostring(b)
  if not a then return -1 end
  if not b then return 1 end
  if a == b then return 0 end
  local sa = segmentCache[a] or getStringSegment(a, caseSensitive)
  segmentCache[a] = sa
  local sb = segmentCache[b] or getStringSegment(b, caseSensitive)
  segmentCache[b] = sb

  local n = math.min(#sa, #sb)
  for i = 1, n do
    local va, vb = sa[i], sb[i]
    if va ~= vb then
      if type(va) == "number" and type(vb) == "number" then
        return va < vb and -1 or 1
      else
        return tostring(va) < tostring(vb) and -1 or 1
      end
    end
  end
  return #sa < #sb and -1 or 1
end

jo.string = {}
