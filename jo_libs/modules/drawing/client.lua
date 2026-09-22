jo.createModule("drawing")

--- Draw a floating 3D text at world coordinates.
--- Must be called each frame (e.g. from a `CreateThread` draw loop) to stay visible.
--- Automatically skips drawing when the target coords are off-screen.
---@param coords vector3 (World coordinates where the text is anchored)
---@param text string (Text to render)
---@param useBackground? boolean (Draw a dark sprite background behind the text <br> default: `true`)
---@param scale? number (Font scale <br> default: `0.30`)
---@param autoScale? boolean (Scale the text down with the distance to the gameplay camera <br> default: `false`)
---@param font? integer (Font index <br> default: `9`)
---@param red? integer (Red color channel 0-255 <br> default: `255`)
---@param green? integer (Green color channel 0-255 <br> default: `255`)
---@param blue? integer (Blue color channel 0-255 <br> default: `255`)
---@param alpha? integer (Alpha channel 0-255 <br> default: `255`)
function jo.drawing.text3d(coords, text, useBackground, scale, autoScale, font, red, green, blue, alpha)
  if not coords or not text then return end

  if useBackground == nil then useBackground = true end
  scale = scale or 0.30
  font = font or 9
  red = red or 255
  green = green or 255
  blue = blue or 255
  alpha = alpha or 255

  if autoScale then
    local cam = GetGameplayCamCoords()
    local dist = #(cam - vector3(coords.x, coords.y, coords.z))
    if dist < 0.01 then dist = 0.01 end
    scale = scale * math.min(1.0, 4.0 / dist)
  end

  local on_screen, sx, sy = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z + 0.5)
  if not on_screen then return end

  local str = CreateVarString(10, "LITERAL_STRING", text)

  SetTextScale(scale, scale)
  SetTextFontForCurrentCommand(font)
  SetTextColor(red, green, blue, alpha)
  SetTextCentre(1)
  DisplayText(str, sx, sy)

  if useBackground then
    local factor = #text / 225
    DrawSprite("feeds", "hud_menu_4a", sx, sy + 0.0125, 0.015 + factor, 0.03, 0.1, 0, 0, 0, 180, 0)
  end
end
