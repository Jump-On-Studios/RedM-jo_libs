jo.require("hook")

local dict = {}

jo.i18n = {
  locale = GetConvar("jo_libs:i18n:locale", "en"), -- Default locale
  initialized = false
}

if jo.isClientSide() then
  local playerLocale = GetExternalKvpString("jo_libs", "locale")
  if playerLocale and playerLocale ~= "" then
    jo.i18n.locale = playerLocale
  end
end

local function formatKeys(source, target, prefix)
  for key, value in pairs(source) do
    local fullKey = prefix and (prefix .. "." .. key) or key

    if type(value) == "table" then
      formatKeys(value, target, fullKey)
    else
      target[fullKey] = value
    end
  end

  return target
end

local function loadLocale(locale)
  local strings = jo.file.load(("@%s.locales.%s"):format(jo.resourceName, locale))
  if not strings then
    return {}
  end
  return formatKeys(strings, {})
end

--- Returns the current locale
---@return string (The current locale)
function jo.i18n.getLocale()
  return jo.i18n.locale
end

--- Load a locale
---@param locale string (The locale to load)
function jo.i18n.loadLocale(locale)
  local strings = loadLocale("en")
  if locale ~= "en" then
    table.merge(strings, loadLocale(locale))
  end
  dict = strings
end

--- Initialize the i18n module
function jo.i18n.init()
  jo.i18n.loadLocale(jo.i18n.locale)
  jo.i18n.initialized = true
end

--- Set the current locale
---@param locale string (The locale to set)
function jo.i18n.setLocale(locale)
  jo.i18n.locale = locale
  jo.i18n.loadLocale(jo.i18n.locale)
  jo.hook.doActions("jo_i18n_locale_changed", locale)
end

--- Register a callback to be called when the locale changes
---@param callback function (The callback to register)
---@param priority number (The priority of the callback)
function jo.i18n.onLocaleChanged(callback, priority)
  jo.hook.registerAction("jo_i18n_locale_changed", callback, priority)
end
exports("onLocaleChanged", jo.i18n.onLocaleChanged)

--- Find missing keys in a locale
---@param locale string (The locale to check)
function jo.i18n.findMissingKeys(locale)
  local refStrings = loadLocale("en")
  if locale == "en" then return print("Cannot compare 'en' with 'en'") end
  local strings = loadLocale(locale)

  for key, _ in pairs(refStrings) do
    if not strings[key] then
      print(("Missing key '%s' in '%s'"):format(key, locale))
    end
  end
end

--- Add a single entry to the i18n dictionary
---@param key string (The key to add)
---@param value string (The value to add)
function jo.i18n.addEntry(key, value)
  dict[key] = value
end
exports("addEntry", jo.i18n.addEntry)

--- Add multiple entries to the i18n dictionary
---@param entries table (The entries to add)
function jo.i18n.addEntries(entries)
  local strings = formatKeys(entries, {})
  table.merge(dict, strings)
end
exports("addEntries", jo.i18n.addEntries)

--- Get all entries
---@return table (The entries)
function jo.i18n.getEntries()
  if not jo.i18n.initialized then
    jo.i18n.init()
  end
  return dict
end
exports("getEntries", jo.i18n.getEntries)

--- Translate a key
---@param key string (The key to translate)
---@return string (The translated key)
function jo.i18n.__(key)
  if not jo.i18n.initialized then
    jo.i18n.init()
  end
  return dict[key] or ("#%s"):format(key)
end
exports("__", jo.i18n.__)

--- Export the i18n module
_G.__ = jo.i18n.__
