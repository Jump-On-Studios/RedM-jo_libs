jo.createModule("text3d")

--- Draw a floating 3D text at world coordinates with a dark sprite background.
--- Must be called each frame (e.g. from a `CreateThread` draw loop) to stay visible.
--- Automatically skips drawing when the target coords are off-screen.
---@param options table Draw options
---| "x" # number — World X coordinate
---| "y" # number — World Y coordinate
---| "z" # number — World Z coordinate
---| "text" # string — Text to render
---| "scale" # number? — Text scale (default: 0.30)
---| "background_alpha" # integer? — Background opacity 0-255 (default: 180)
function jo.text3d.draw(options)
  local x, y, z = options.x, options.y, options.z
  local text = options.text
  if not x or not y or not z or not text then return end

  local scale = options.scale or 0.30
  local bg_alpha = options.background_alpha or 180

  local on_screen, sx, sy = GetScreenCoordFromWorldCoord(x, y, z + 0.5)
  if not on_screen then return end

  local str = CreateVarString(10, "LITERAL_STRING", text)

  SetTextScale(scale, scale)
  SetTextFontForCurrentCommand(9)
  SetTextColor(255, 255, 255, 255)
  SetTextCentre(1)
  DisplayText(str, sx, sy)

  local factor = #text / 225
  DrawSprite("feeds", "hud_menu_4a", sx, sy + 0.0125, 0.015 + factor, 0.03, 0.1, 0, 0, 0, bg_alpha, 0)
end
