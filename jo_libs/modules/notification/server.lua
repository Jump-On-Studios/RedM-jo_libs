jo.notif = {}

function jo.notif.right(source,text, dict, icon, color, duration,soundset_ref,soundset_name)
  TriggerClientEvent(GetCurrentResourceName()..":client:notif",source,text, dict, icon, color, duration,soundset_ref,soundset_name)
end

function jo.notif.left(source,title, subTitle, dict, icon, color, duration,soundset_ref,soundset_name)
  TriggerClientEvent(GetCurrentResourceName()..":client:notifLeft",source,title, subTitle, dict, icon, color, duration,soundset_ref,soundset_name)
end

function jo.notif.rightSuccess(source,text)
  jo.notif.right(source,text,"hud_textures","check","COLOR_GREEN")
end

function jo.notif.rightError(source,text)
  jo.notif.right(source,text,"menu_textures", "cross","COLOR_RED")
end