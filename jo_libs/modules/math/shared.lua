function math.lerp(a, b, t)
  return a + (b - a) * t
end

function math.round(number, precision)
  if not precision or precision <= 0 then return math.floor(number) end
  return math.floor(number * 10 ^ precision) / 10 ^ precision
end

jo.math = {}
