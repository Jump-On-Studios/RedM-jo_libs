AddEventHandler('rsg-menubase:getData', function(cb)
    return cb(jo.menu.bridgeOldMenu)
end)

exports("GetMenuData", function()
    return jo.menu.bridgeOldMenu
end)
