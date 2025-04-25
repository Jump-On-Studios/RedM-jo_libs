jo.require("table")

-- todo document this file

local colors = {
  red = {
    start = "^1",
    reset = "^0",
  },
  green = {
    start = IsDuplicityVersion() and "\x1b[92m" or "^2",
    reset = IsDuplicityVersion() and "\x1b[97m" or "^0",
  },
  orange = {
    start = IsDuplicityVersion() and "\x1b[38;2;255;95;31m" or "^3",
    reset = IsDuplicityVersion() and "\x1b[97m" or "^0",
  },
  blue = {
    start = IsDuplicityVersion() and "\x1b[96m" or "^5",
    reset = IsDuplicityVersion() and "\x1b[97m" or "^0",
  },
}

local function getColorCode(color)
  return colors[color]?.start or ""
end

local function getColorResetCode(color)
  return colors[color]?.reset or "^0"
end

local function encodeTable(...)
  local args = table.copy({ ... })
  for i = 1, #args do
    if type(args[i]) == "table" then
      args[i] = json.encode(args[i])
    end
  end
  return args
end

local function convertColor(args)
  for i = 1, #args do
    if type(args[i]) == "string" and args[i]:find("~") then
      for color, _ in pairs(colors) do
        if args[i]:find(("~%s~"):format(color)) then
          args[i] = args[i]:gsub(("~%s~"):format(color), getColorCode(color)) .. getColorResetCode(color)
        end
      end
    end
  end
end

local function printWithColor(...)
  local args = { ... }
  convertColor(args)
  for i = 1, #args do
    if type(args[i]) == "string" then
      local _, count = args[i]:gsub("%%[%d%.]*[sdf]", "")
      if count > 0 then
        local formatValues = table.slice(args, i + 1, i + count)
        if #formatValues <= count then
          args[i] = args[i]:format(table.unpack(formatValues))
          for c = 1, count do
            table.remove(args, i + 1)
          end
        end
      end
    end
  end
  print(table.unpack(args))
end

function log(...)
  local args = { ... }
  for i = 1, #args do
    if type(args[i]) == "table" then
      args[i] = json.encode(args[i], { indent = true })
    end
  end
  printWithColor(table.unpack(args))
end

local function addColor(args, color)
  -- local start = getColorCode(color)
  -- local reset = getColorResetCode(color)
  for i = 1, #args do
    if type(args[i]) == "string" then
      args[i] = ("~%s~%s"):format(color, args[i])
    end
  end
end

local function addResourceName(args)
  if not IsDuplicityVersion() then return end
  args[1] = GetCurrentResourceName() .. ": " .. args[1]
end


function sprint(...)
  local args = encodeTable(...)
  addColor(args, "red")
  addResourceName(args)
  return printWithColor(table.unpack(args))
end

eprint = sprint

function gprint(...)
  local args = encodeTable(...)
  if IsDuplicityVersion() then
    addResourceName(args)
  end
  addColor(args, "green")
  return printWithColor(table.unpack(args))
end

function oprint(...)
  local args = encodeTable(...)
  if IsDuplicityVersion() then
    addResourceName(args)
  end
  addColor(args, "orange")
  return printWithColor(table.unpack(args))
end

wprint = oprint

function bprint(...)
  local args = encodeTable(...)
  if IsDuplicityVersion() then
    addResourceName(args)
  end
  addColor(args, "blue")
  return printWithColor(table.unpack(args))
end

function dprint(cb, ...)
  if not Config?.debug and not jo.debug then return end
  local args = encodeTable(...)
  local printFunc = printWithColor
  if type(cb) == "function" then
    printFunc = cb
  else
    table.insert(args, 1, cb)
  end
  printFunc(table.unpack(args))
end
