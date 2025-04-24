local startOffsetY = 0.02
local offsetY = startOffsetY

--- Resets the text display offset to its starting position.
function jo.debugger.resetText()
  offsetY = startOffsetY
end

--- Draws text on the screen with specified parameters.
---@param text string (The text content to be displayed)
---@param x? number (The x-coordinate position on screen - default:0.01)
---@param y? number (The y-coordinate position on screen - if not provided, uses and increments the global offset)
function jo.debugger.drawText(text, x, y)
  SetTextScale(0.35, 0.35)
  SetTextColor(255, 255, 255, 255)
  SetTextCentre(false)
  SetTextDropshadow(1, 1, 1, 0, 200)
  SetTextFontForCurrentCommand(0)
  if not y then
    offsetY += 0.02
  end
  DisplayText(CreateVarString(10, "LITERAL_STRING", text), x or 0.01, y or offsetY)
end

--- Draws a 3D sphere at the specified coordinates.
---@param coords vector (The coordinates where the sphere will be drawn)
---@param size? vector (The size of the sphere in x,y,z dimensions - default:vec3(0.5, 0.5, 0.5))
---@param color? table (The color of the sphere)
--- color.r number (Red component 0-255 - default:255)
--- color.g number (Green component 0-255 - default:0)
--- color.b number (Blue component 0-255 - default:0)
--- color.a number (Alpha/transparency 0-255 - default:100)
function jo.debugger.drawSphere(coords, size, color)
  if not coords then return end
  size = size or vec3(0.5, 0.5, 0.5)
  color = color or { r = 255, g = 0, b = 0, a = 100 }
  DrawMarker(0x50638AB9, coords.x, coords.y, coords.z, .0, .0, .0, .0, .0, .0, size.x, size.y, size.z, color.r, color.g,
    color.b, color.a)
end
