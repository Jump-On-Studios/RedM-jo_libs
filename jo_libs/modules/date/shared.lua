jo.date = {}

function jo.date.convertMsToInterval(ms, lang)
  lang = lang or {
    ms = "ms",
    s = "s",
    min = "min",
    h = "h",
    d = "day",
    ds = "days"
  }

  local ms_in_day = 86400000 -- 24 * 60 * 60 * 1000
  local ms_in_hour = 3600000 -- 60 * 60 * 1000
  local ms_in_minute = 60000 -- 60 * 1000
  local ms_in_second = 1000  -- 1000 ms = 1 second
  local string = ""

  if lang.d then
    local days = math.floor(ms / ms_in_day)
    ms = ms % ms_in_day
    if days > 0 then string = ('%d %s'):format(days, days > 1 and lang.ds or lang.d) end
  end

  if lang.h then
    local hours = math.floor(ms / ms_in_hour)
    ms = ms % ms_in_hour
    if hours > 0 then
      string = string .. ('%s%d %s'):format(string:len() > 0 and ', ' or '', hours, lang.h)
    end
  end

  if lang.min then
    local minutes = math.floor(ms / ms_in_minute)
    ms = ms % ms_in_minute
    if minutes > 0 then
      string = string .. ('%s%d %s'):format(string:len() > 0 and ', ' or '', minutes, lang.min)
    end
  end

  if lang.s then
    local seconds = math.floor(ms / ms_in_second)
    ms = ms % ms_in_second
    if seconds > 0 then
      string = string .. ('%s%d %s'):format(string:len() > 0 and ', ' or '', seconds, lang.s)
    end
  end

  if lang.ms then
    local milliseconds = ms
    if milliseconds > 0 then
      string = string .. ('%s%d %s'):format(string:len() > 0 and ', ' or '', milliseconds, lang.ms)
    end
  end

  if string == "" then string = "now" end

  return string
end

