jo.screen = {}

--- Fades the screen in with specified duration
---@param duration? integer (Duration of the fade in ms <br> default: 500)
---@param needWait? boolean (Wait for the end of the fade <br> default: false)
function jo.screen.fadeIn(duration, needWait)
  DoScreenFadeIn(duration or 500)
  while needWait and IsScreenFadingOut() do
    Wait(0)
  end
end

--- Fades the screen out with specified duration
---@param duration? integer (Duration of the fade in ms <br> default: 500)
---@param needWait? boolean (Wait for the end of the fade <br> default: true)
function jo.screen.fadeOut(duration, needWait)
  if (needWait == nil) then needWait = true end
  DoScreenFadeOut(duration or 500)
  while needWait and IsScreenFadingOut() do
    Wait(0)
  end
end
