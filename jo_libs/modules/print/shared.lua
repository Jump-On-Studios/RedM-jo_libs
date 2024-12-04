function sprint(...)
  if IsDuplicityVersion() then
    return print("^1" .. GetCurrentResourceName() .. ":", ..., "^0")
  end
  return print("^1", ...)
end

function eprint(...)
  if IsDuplicityVersion() then
    return print("^1" .. GetCurrentResourceName() .. ":", ..., "^0")
  end
  return print("^1", ...)
end

function gprint(...)
  if IsDuplicityVersion() then
    return print("\x1b[92m" .. GetCurrentResourceName() .. ":", ..., "\x1b[0m")
  end
  return print("^2", ...)
end

function oprint(...)
  if IsDuplicityVersion() then
    return print("\x1b[38;2;255;95;31m" .. GetCurrentResourceName() .. ":", ..., "\x1b[0m")
  end
  return print("^3", ...)
end

function bprint(...)
  if IsDuplicityVersion() then
    return print("\x1b[96m" .. GetCurrentResourceName() .. ":", ..., "\x1b[0m")
  end
  return print("^5", ...)
end

function dprint(...)
  if not Config?.debug then return end
  print(...)
end
