jo.require("table")

local function encodeTable(...)
  local args = table.copy({ ... })
  for i = 1, #args do
    if type(args[i]) == "table" then
      args[i] = json.encode(args[i])
    end
  end
  return args
end

local function addColor(args, start, reset)
  table.insert(args, 1, start)
  if IsDuplicityVersion() then
    args[1] = args[1] .. GetCurrentResourceName() .. ":"
  end
  table.insert(args, reset or "^0")
end

local function addResourceName(args)
  if not IsDuplicityVersion() then return end
  args[1] = args[1] .. GetCurrentResourceName() .. ":"
end

function sprint(...)
  local args = encodeTable(...)
  addColor(args, "^1")
  addResourceName(args)
  return print(table.unpack(args))
end

function eprint(...)
  local args = encodeTable(...)
  addColor(args, "^1")
  addResourceName(args)
  return print(table.unpack(args))
end

function gprint(...)
  local args = encodeTable(...)
  if IsDuplicityVersion() then
    addColor(args, "\x1b[92m", "\x1b[0m")
  else
    addColor(args, "^2")
  end
  addResourceName(args)
  return print(table.unpack(args))
end

function oprint(...)
  local args = encodeTable(...)
  if IsDuplicityVersion() then
    addColor(args, "\x1b[38;2;255;95;31m", "\x1b[0m")
  else
    addColor(args, "^3")
  end
  return print(table.unpack(args))
end

wprint = oprint

function bprint(...)
  local args = encodeTable(...)
  if IsDuplicityVersion() then
    addColor(args, "\x1b[96m", "\x1b[0m")
  else
    addColor(args, "^5")
  end
  return print(table.unpack(args))
end

function dprint(...)
  local args = encodeTable(...)
  if not Config?.debug and not jo.debug then return end
  print(table.unpack(args))
end
