--- Performs linear interpolation between two values.
---@param a number (The starting value)
---@param b number (The ending value)
---@param t number (The interpolation factor, usually between 0 and 1)
---@return number (The interpolated value between a and b)
function math.lerp(a, b, t)
  return a + (b - a) * t
end

--- Rounds a number to the specified decimal precision.
---@param number number (The number to round)
---@param precision? number (The number of decimal places to round to <br> default:0)
---@return number (The rounded number)
function math.round(number, precision)
  if not precision or precision <= 0 then return math.floor(number) end
  return math.floor(number * 10 ^ precision) / 10 ^ precision
end

--- Clamps a number between a minimum and maximum value.
---@param x number (The number to clamp)
---@param min number (The minimum value)
---@param max number (The maximum value)
---@return number (The clamped number)
function math.clamp(x, min, max)
  return math.max(math.min(x, max), min)
end

--- Converts a number to hexadecimal string representation.
---@param n integer (The integer to convert)
---@param prefix? boolean (Add "0x" prefix, default: false)
---@return string (The hexadecimal string representation)
function math.toHex(n, prefix)
  if type(n) ~= "number" then return n end
  local hex = string.format("%X", n)
  return prefix and "0x" .. hex or hex
end

--- Converts a hexadecimal string to an integer.
---@param hex string (The hexadecimal string to convert, with or without "0x" prefix)
---@return integer (The integer representation)
function math.fromHex(hex)
  if type(hex) ~= "string" then return hex end
  return tonumber(hex, 16)
end

function math.toSigned(n)
  if type(n) ~= "number" then return n end
  if n >= 2147483648 then
    return n - 4294967296
  end
  return n
end

jo.createModule("math")
