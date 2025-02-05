local startOffsetY = 0.02
local offsetY = startOffsetY

function jo.debug.resetText()
  offsetY = startOffsetY
end

function jo.debug.drawText(text, x, y)
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
