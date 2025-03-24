local startOffsetY = 0.02
local offsetY = startOffsetY

function jo.debugger.resetText()
  offsetY = startOffsetY
end

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

function jo.debugger.drawSphere(coords, size, color)
  if not coords then return end
  size = size or vec3(0.5, 0.5, 0.5)
  color = color or { r = 255, g = 0, b = 0, a = 100 }
  DrawMarker(0x50638AB9, coords.x, coords.y, coords.z, .0, .0, .0, .0, .0, .0, size.x, size.y, size.z, color.r, color.g, color.b, color.a)
end
