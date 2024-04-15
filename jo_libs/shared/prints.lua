function sprint(text)
  if IsDuplicityVersion() then
    return print("^1"..GetCurrentResourceName()..": "..text.."^0")
  end
  return print("^1"..text)
end

function eprint(text)
  if IsDuplicityVersion() then
    return print("^1"..GetCurrentResourceName()..": "..text.."^0")
  end
  return print("^1"..text)
end

function gprint(text)
  if IsDuplicityVersion() then
    return print("\x1b[92m"..GetCurrentResourceName()..": "..text.."\x1b[0m")
  end
  return print("^2"..text)
end

function oprint(text)
  if IsDuplicityVersion() then
    return print("\x1b[38;2;255;95;31m"..GetCurrentResourceName()..": "..text.."\x1b[0m")
  end
  return print("^3"..text)
end

function bprint(text)
  if IsDuplicityVersion() then
    return print("\x1b[96m"..GetCurrentResourceName()..": "..text.."\x1b[0m")
  end
  return print("^5"..text)
end

function dprint(...)
  if not Config.debug then return end
  print(...)
end
