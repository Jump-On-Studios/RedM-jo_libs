exports("GetMenuData", function()
  return jo.menu.bridgeOldMenu
end)

AddEventHandler('menuapi:getData', function(cb)
  cb(jo.menu.bridgeOldMenu)
end)

AddEventHandler("vorp_menu:getData", function(cb)
  return cb(jo.menu.bridgeOldMenu)
end)