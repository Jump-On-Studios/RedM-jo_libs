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

jo.math = {}
