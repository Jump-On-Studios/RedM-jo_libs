jo.notif = {}

---@param source integer the source ID of the player
---@param text string The text of the notification
---@param dict string The dictonnary of the icon
---@param icon string he name of the icon
---@param color? string The color of the text
---@param duration? integer The duration of the notification in ms
---@param soundset_ref? string The dictionnary of the soundset
---@param soundset_name? string The name of the soundset
function jo.notif.right(source,text, dict, icon, color, duration,soundset_ref,soundset_name)
  TriggerClientEvent(GetCurrentResourceName()..":client:notif",source,text, dict, icon, color, duration,soundset_ref,soundset_name)
end

---@param source integer the source ID of the player
---@param title string the title of the notification
---@param text string The text of the notification
---@param dict string The dictonnary of the icon
---@param icon string he name of the icon
---@param color? string The color of the text
---@param duration? integer The duration of the notification in ms
---@param soundset_ref? string The dictionnary of the soundset
---@param soundset_name? string The name of the soundset
function jo.notif.left(source,title, text, dict, icon, color, duration,soundset_ref,soundset_name)
  TriggerClientEvent(GetCurrentResourceName()..":client:notifLeft",source,title, text, dict, icon, color, duration,soundset_ref,soundset_name)
end

---@param source integer the source ID of the player
---@param text string The text of the notification
function jo.notif.rightSuccess(source,text)
  jo.notif.right(source,text,"hud_textures","check","COLOR_GREEN")
end

---@param source integer the source ID of the player
---@param text string The text of the notification
function jo.notif.rightError(source,text)
  jo.notif.right(source,text,"menu_textures", "cross","COLOR_RED")
end

return jo.notif