jo.notif = {}


--- Notification on the right with icon, color and sound
---@param source integer ((The source ID of the player))
---@param text string (The text of the notification)
---@param dict string (The dictionnary of the icon)
---@param icon string (The name of the icon)
---@param color? string (The color of the text <br> default : "COLOR_WHITE")
---@param duration? integer (The duration of the notification in ms <br> default: 3000)
---@param soundset_ref? string (The dictionnary of the soundset <br> default : "Transaction_Feed_Sounds")
---@param soundset_name? string (The name of the soundset <br> default : "Transaction_Positive")
function jo.notif.right(source, text, dict, icon, color, duration, soundset_ref, soundset_name)
  TriggerClientEvent(GetCurrentResourceName() .. ":client:notif", source, text, dict, icon, color, duration, soundset_ref,
    soundset_name)
end

--- Notification on the left with title, icon, color and sound
---@param source integer (The source ID of the player)
---@param title string (The title of the notification)
---@param text string (The text of the notification)
---@param dict string (The dictionnary of the icon)
---@param icon string (The name of the icon)
---@param color? string (The color of the text <br> default : "COLOR_WHITE")
---@param duration? integer (The duration of the notification in ms <br> default: 3000)
---@param soundset_ref? string (The dictionnary of the soundset <br> default : "Transaction_Feed_Sounds")
---@param soundset_name? string (The name of the soundset <br> default : "Transaction_Positive")
function jo.notif.left(source, title, text, dict, icon, color, duration, soundset_ref, soundset_name)
  TriggerClientEvent(GetCurrentResourceName() .. ":client:notifLeft", source, title, text, dict, icon, color, duration,
    soundset_ref, soundset_name)
end

--- A function to display a successful notification
---@param source integer (The source ID of the player)
---@param text string (The text of the notification)
---@return boolean (Always return `true`)
function jo.notif.rightSuccess(source, text)
  jo.notif.right(source, text, "hud_textures", "check", "COLOR_GREEN")
  return true
end

--- A function to display an error notification
---@param source integer (The source ID of the player)
---@param text string (The text of the notification)
---@return boolean (Always return `false`)
function jo.notif.rightError(source, text)
  jo.notif.right(source, text, "menu_textures", "cross", "COLOR_RED")
  return false
end

--- Notification on the top with big title and subtitle (native mission start/end)
---@param source integer (The source ID of the player)
---@param title string (The title of the notification)
---@param subtitle string (The text of the notification)
---@param duration? integer (The duration of the notification in ms <br> default : 3000)
function jo.notif.simpleTop(source, title, subtitle, duration)
  TriggerClientEvent(GetCurrentResourceName() .. ":client:simpleTop", source, title, subtitle, duration)
end

--- A function to print in the client console from the server side
---@param source integer (The source ID of the player)
---@param ... any (The data you want to print)
function jo.notif.print(source, ...)
  TriggerClientEvent(GetCurrentResourceName() .. ":client:notifPrint", source, ...)
end
