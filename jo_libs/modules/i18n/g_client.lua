local allowSwitchLocale = GetConvar("jo_libs:i18n:allowSwitchLocale", "true") == "true" -- Allow switching locale
local localeCommand = GetConvar("jo_libs:i18n:localeCommand", "setLocale")              -- Command to switch locale

if allowSwitchLocale then
  TriggerEvent("chat:addSuggestion", "/" .. localeCommand, "Set the locale", {
    { name = "locale", help = "The locale to set" }
  })
  RegisterCommand(localeCommand, function(_, args)
    if #args < 1 then
      eprint("Usage: /" .. localeCommand .. " <locale>")
      return
    end

    local locale = args[1]
    SetResourceKvp("locale", locale)
    TriggerEvent("jo_libs:i18n:switchLocale", locale)
  end, false)
end
