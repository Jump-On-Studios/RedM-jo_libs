if not bprint then
  return print('^1NEED TO LOAD prints.lua FIRST !!!!!!^0')
end

Citizen.CreateThread(function()
  InitFramework()
end)

Framework = false
function GetFramework()
  if Framework ~= false then return Framework end

  if Config.Framework == "Custom" then
    Framework = Config.Framework
  elseif GetResourceState('vorp_core') == "started" then
    Framework = "VORP"
  elseif GetResourceState('redem') == "started" then
    Framework = "RedEM"
  elseif GetResourceState('redem_roleplay') == "started" then
    Framework = "RedEM2023"
  elseif GetResourceState('qbr-core') == "started" then
    Framework = "QBR"
  elseif GetResourceState('rsg-core') == "started" then
    Framework = "RSG"
  elseif GetResourceState('qr-core') == "started" then
    Framework = "QR"
  end
  return Framework
end

function IsFramework(name)
  return GetFramework() == name
end

InitFramework = function()
  if Config.InitFramework then
    return Config.InitFramework()
  end
  if GetFramework() == "VORP" then
    bprint('VORP detected')
    Wait(100)
    TriggerEvent("getCore", function(core)
      Core = core
      CoreInv = exports.vorp_inventory:vorp_inventoryApi()
    end)
    return
  end
  if GetFramework() == "RedEM2023" then
    bprint('RedEM:RP 2023 detected')
    Core = exports["redem_roleplay"]:RedEM()
    TriggerEvent("redemrp_inventory:getData",function(call)
      CoreInv = call
    end)
    return
  end
  if GetFramework() == "RedEM" then
    bprint('RedEM:RP OLD detected')
    TriggerEvent("redemrp_inventory:getData",function(call)
      CoreInv = call
    end)
    return
  end
  if GetFramework() == "QBR" then
    bprint('QBR detected')
    return
  end
  if GetFramework() == "RSG" then
    bprint('RSGCore detected')
    Core = exports['rsg-core']:GetCoreObject()
    return
  end
  if GetFramework() == "QR" then
    bprint('QR detected')
    Core = exports['qr-core']:GetCoreObject()
    return
  end
  eprint('No compatible Framework detected. Please contact JUMP ON studios on discord')
end

function CanBuy(source,price, moneyType)
  if Config.CanBuy then
    return Config.CanBuy(source,price,moneyType)
  elseif GetFramework() == "VORP" then
    local Character = Core.getUser(source).getUsedCharacter
		if moneyType == 0 and Character.money >= price then
			Character.removeCurrency(0, price)
			return true
		elseif moneyType == 1 and Character.gold >= price then
      Character.removeCurrency(1, price)
			return true
    end
  elseif GetFramework() == "RedEM2023" then
    local user = Core.GetPlayer(source)
    if moneyType == 1 then
      return Config.CanBuyWithGold(source,price)
    else
      local currentMoney = user.GetMoney()
      if currentMoney >= price then
        user.RemoveMoney(price)
        return true
      end
    end
  elseif GetFramework() == "RedEM" then
    local result = promise.new()
    TriggerEvent('redemrp:getPlayerFromId', source, function(user)
      if moneyType == 1 then
        if (user.getGold() > price) then
          user.removeGold(price)
          result:resolve(true)
        else
          result:resolve(false)
        end
      else
        if (user.getMoney() > price) then
          user.removeMoney(price)
          result:resolve(true)
        else
          result:resolve(false)
        end
      end
    end)
    return Citizen.Await(result)
  elseif GetFramework() == "QBR" then
    if moneyType == 1 then
      return Config.CanBuyWithGold(source,price)
    else
      local xPlayer = exports['qbr-core']:GetPlayer(source)
      if xPlayer.Functions.GetMoney('cash') >= price then
        xPlayer.Functions.RemoveMoney('cash', tonumber(price), 'clothing-store')
        return true
      end
    end
  elseif GetFramework() == "RSG" then
    if moneyType == 1 then
      return Config.CanBuyWithGold(source,price)
    else
      local Player = Core.Functions.GetPlayer(source)
      if Player.Functions.GetMoney('cash') >= price then
        Player.Functions.RemoveMoney("cash", price)
        return true
      end
    end
  elseif GetFramework() == "QR" then
    if moneyType == 1 then
      return Config.CanBuyWithGold(source,price)
    else
      local Player = Core.Functions.GetPlayer(source)
      if Player.Functions.GetMoney('cash') >= price then
        Player.Functions.RemoveMoney("cash", price)
        return true
      end
    end
  end
  return false
end

function GiveMoney(source,amount)
  if Config.GiveMoney then
    return Config.GiveMoney(source,amount)
  end
  if GetFramework() == "VORP" then
    local Character = Core.getUser(source).getUsedCharacter
    Character.addCurrency(0, amount)
    return
	end
  if GetFramework() == "RedEM2023" then
    local user = Core.GetPlayer(source)
    user.AddMoney(amount)
    return
  end
  if GetFramework() == "RedEM" then
    TriggerEvent('redemrp:getPlayerFromId', source, function(user)
      user.addMoney(amount)
    end)
    return
  end
  if GetFramework() == "QBR" then
    local xPlayer = exports['qbr-core']:GetPlayer(source)
    xPlayer.Functions.AddMoney('cash', tonumber(amount), 'clothing-store')
    return
  end
  if GetFramework() == "RSG" then
    local Player = Core.Functions.GetPlayer(source)
    Player.Functions.AddMoney("cash", amount)
  end
  if GetFramework() == "QR" then
    local Player = Core.Functions.GetPlayer(source)
    Player.Functions.AddMoney("cash", amount)
  end
  return false
end

function GiveGold(source,amount)
  if Config.GiveGold then
    return Config.GiveGold(source,amount)
  end
  if GetFramework() == "VORP" then
    local Character = Core.getUser(source).getUsedCharacter
    Character.addCurrency(1, amount)
    return
	end
  if GetFramework() == "RedEM" then
    TriggerEvent('redemrp:getPlayerFromId', source, function(user)
      user.addGold(amount)
    end)
    return
  end
  return eprint('Config.GiveGold needs to be defined')
end

function GetIdentifier(source)
  if Config.GetIdentifier then
    Identifiers[source] = Config.GetIdentifier(source)
    return Identifiers[source]
  end
  if GetFramework() == "VORP" then
    local user = Core.getUser(source).getUsedCharacter
    if user then
      Identifiers[source] = {
        identifier = user.identifier,
        charid = user.charIdentifier
      }
      return Identifiers[source]
    end
  end
  if GetFramework() == "RedEM2023" then
    local user = Core.GetPlayer(source)
    if user then
      Identifiers[source] = {
        identifier = user.identifier,
        charid = user.charid
      }
      return Identifiers[source]
    end
  end
  if GetFramework() == "RedEM" then
    local waiter = promise.new()
    TriggerEvent('redemrp:getPlayerFromId', source, function(_user)
      if _user then
        Identifiers[source] = {identifier = _user.getIdentifier(), charid = _user.getSessionVar("charid")}
      end
      waiter:resolve(true)
    end)
    Citizen.Await(waiter)
    return Identifiers[source]
  end
  if GetFramework() == "QBR" then
    local user = exports['qbr-core']:GetPlayer(source)
    if user then
      Identifiers[source] = {
        identifier = user.PlayerData.citizenid,
        charid = 0
      }
      return Identifiers[source]
    end
  end
  if GetFramework() == "RSG" then
    local Player = Core.Functions.GetPlayer(source)
    if Player then
      local citizenid = Player.PlayerData.citizenid
      Identifiers[source] = {
        identifier = citizenid,
        charid = 0,
        license = Core.Functions.GetIdentifier(source, 'license')
      }
      return Identifiers[source]
    end
  end
  if GetFramework() == "QR" then
    local Player = Core.Functions.GetPlayer(source)
    if Player then
      local citizenid = Player.PlayerData.citizenid
      Identifiers[source] = {
        identifier = citizenid,
        charid = 0,
        license = Core.Functions.GetIdentifier(source, 'license')
      }
      return Identifiers[source]
    end
  end
  return false
end

function GetJob(source)
  if Config.GetJob then
    return Config.GetJob(source)
  end
  if GetFramework() == "VORP" then
    local user = Core.getUser(source).getUsedCharacter
    return user.job
  end
  if GetFramework() == "RedEM2023" then
    local user = Core.GetPlayer(source)
    return user.job
  end
  if GetFramework() == "RedEM" then
    local waiter = promise.new()
    TriggerEvent('redemrp:getPlayerFromId', source, function(_user)
      waiter:resolve(_user.getJob())
    end)
    return Citizen.Await(waiter)
  end
  if GetFramework() == "QBR" then
    local user = exports['qbr-core']:GetPlayer(source)
    return user.PlayerData.job.name
  end
  if GetFramework() == "RSG" then
    local user = Core.Functions.GetPlayer(source)
    return user.PlayerData.job.name
  end
  if GetFramework() == "QR" then
    local user = Core.Functions.GetPlayer(source)
    return user.PlayerData.job.name
  end
  return false
end

function getRPName(source)
  if Config.GetRPName then
    return Config.GetRPName(source)
  end
  if GetFramework() == "VORP" then
    local Character = Core.getUser(source).getUsedCharacter
    return ("%s %s"):format(Character.firstname,Character.lastname)
	end
  if GetFramework() == "RedEM2023" then
    local user = Core.GetPlayer(source)
    return ("%s %s"):format(user.firstname,user.lastname)
  end
  if GetFramework() == "RedEM" then
    local waiter = promise.new()
    local name = ""
    TriggerEvent('redemrp:getPlayerFromId', source, function(_user)
      name = ("%s %s"):format(_user.firstname,_user.lastname)
      waiter:resolve(true)
    end)
    Citizen.Await(waiter)
    return name
  end
  if GetFramework() == "QBR" then
    local Player = exports['qbr-core']:GetPlayer(source)
    return ("%s %s"):format(Player.PlayerData.charinfo.firstname,Player.PlayerData.charinfo.lastname)
  end
  if GetFramework() == "RSG" then
     local Player = Core.Functions.GetPlayer(source)
    return ("%s %s"):format(Player.PlayerData.charinfo.firstname,Player.PlayerData.charinfo.lastname)
  end
  if GetFramework() == "QR" then
     local Player = Core.Functions.GetPlayer(source)
    return ("%s %s"):format(Player.PlayerData.charinfo.firstname,Player.PlayerData.charinfo.lastname)
  end
  return source
end

function UseItem(source,item,amount,meta,remove)
  if Config.UseItem then
    return Config.UseItem(source,item,amount,meta,remove)
  end
  if GetFramework() == "VORP" then
    local count = exports.vorp_inventory:getItemCount(source, nil, item)
    if count >= amount then
      if remove then
        exports.vorp_inventory:subItem(source, item, amount)
      end
      return true
    end
	end
  if GetFramework() == "RedEM" or GetFramework() == "RedEM2023" then
    local itemData = CoreInv.getItem(source, item)
    if itemData and itemData.ItemAmount >= amount then
      if remove then
        itemData.RemoveItem(amount)
      end
      return true
    end
  end
  if GetFramework() == "QBR" then
    local Player = exports['qbr-core']:GetPlayer(source)
    local itemData = Player.Functions.GetItemByName(item)
    if itemData and itemData.amount >= amount then
      if remove then
        Player.Functions.RemoveItem(item,amount)
      end
      return true
    end
  end
  if GetFramework() == "RSG" then
    local Player = Core.Functions.GetPlayer(source)
    local itemData = Player.Functions.GetItemByName(item)
    if itemData and itemData.amount >= amount then
      if remove then
        Player.Functions.RemoveItem(item,amount)
      end
      return true
    end
  end
  if GetFramework() == "QR" then
    local Player = Core.Functions.GetPlayer(source)
    local itemData = Player.Functions.GetItemByName(item)
    if itemData and itemData.amount >= amount then
      if remove then
        Player.Functions.RemoveItem(item,amount)
      end
      return true
    end
  end
  return false
end

function RegisterUseItem(item,callback,closeAfterUsed)
  if (closeAfterUsed == nil) then closeAfterUsed = true end
  MySQL.ready(function()
    SetTimeout(5000,function()
      if Config.RegisterUseItem then
        return Config.RegisterUseItem(item,callback)
      end
      if GetFramework() == "VORP" then
        exports.vorp_inventory:getItemDB(item, function(itemData)
          if not itemData then
            return eprint(item .. " < item configuration is missing")
          end
          exports.vorp_inventory:registerUsableItem(item, function(data)
            if closeAfterUsed then
              exports.vorp_inventory:closeInventory(data.source)
            end
            return callback(data.source,{metadata = data.item.metadata})
          end)
        end)
      elseif GetFramework() == "RedEM2023" or GetFramework() == "RedEM" then
        local itemData = CoreInv.getItemData(item)
        if not itemData then
          return eprint(item .. " < item configuration is missing")
        end
        RegisterServerEvent("RegisterUsableItem:"..item)
        AddEventHandler("RegisterUsableItem:"..item, function(source,data)
          callback(source,{metadata = data.meta})
          if closeAfterUsed then
            TriggerClientEvent("redemrp_inventory:closeinv", source)
          end
        end)
      elseif GetFramework() == "QBR" then
        if exports['qbr-core']:AddItem(item,nil) then
          return eprint(item .. " < item configuration is missing")
        end
        exports['qbr-core']:CreateUseableItem(item,function(source,data)
          callback(source,{metadata = data.info})
        end)
      elseif GetFramework() == "RSG" then
        if Core.Functions.AddItem(item,nil) then
          return eprint(item .. " < item configuration is missing")
        end
        Core.Functions.CreateUseableItem(item,function(source,data)
          callback(source,{metadata = data.info})
        end)
      elseif GetFramework() == "QR" then
        if Core.Functions.AddItem(item,nil) then
          return eprint(item .. " < item configuration is missing")
        end
        Core.Functions.CreateUseableItem(item,function(source,data)
          callback(source,{metadata = data.info})
        end)
      end
    end)
  end)
end

function GiveItem(source,item,quantity,meta)
  local description
  if meta.hash then
    description = Lang.itemDesc:format(__(meta.sexe),meta.index,meta.variation)
  elseif meta.outfit then
    description = Lang.outfitDesc:format(__(meta.sexe),meta.name)
  end

  meta = ApplyFilters('editItemMeta',meta,source,item)

  if Config.GiveItem then
    return Config.GiveItem(source,item,quantity,meta)
  end

  if GetFramework() == "VORP" then
    meta.description = description
    if exports.vorp_inventory:canCarryItem(source, item, quantity) then
      exports.vorp_inventory:addItem(source, item, quantity, meta)
      return true
    end
  elseif GetFramework() == "RedEM2023" or GetFramework() == "RedEM" then
    local ItemData = CoreInv.getItem(source, item, meta) -- this give you info and functions
    return ItemData.AddItem(quantity,meta)
  elseif GetFramework() == "QBR" then
    local Player = exports['qbr-core']:GetPlayer(source)
    meta.costs = description
    return Player.Functions.AddItem(item, quantity, false, meta)
  elseif GetFramework() == "RSG" then
    local Player = Core.Functions.GetPlayer(source)
    meta.costs = description
    return Player.Functions.AddItem(item, quantity, false, meta)
  elseif GetFramework() == "QR" then
    local Player = Core.Functions.GetPlayer(source)
    meta.costs = description
    return Player.Functions.AddItem(item, quantity, false, meta)
  elseif GetFramework() == "RPX" then
    return exports['rpx-inventory']:AddItem(source, item, quantity, meta)
  end

  return false
end

function OpenInventory(source,invName,name,invConfig, whitelist)
  if GetFramework() == "VORP" then
    --id, name, limit, acceptWeapons, shared, ignoreItemStackLimit, whitelistItems,UsePermissions, UseBlackList, whitelistWeapons
    exports.vorp_inventory:registerInventory({
      id = invName,
      name = name,
      limit = invConfig.maxSlots,
      acceptWeapons =  invConfig.acceptWeapons,
      shared = true,
      ignoreItemStackLimit = true,
      whitelistItems = true,
    })
    for _,data in pairs (whitelist or {}) do
      exports.vorp_inventory:setCustomInventoryItemLimit(invName, data.item, data.limit)
    end
    exports.vorp_inventory:openInventory(source,invName)
    return
  end
  if GetFramework() == "RedEM2023" then
    TriggerClientEvent("redemrp_inventory:OpenStash", source, name, invConfig.maxWeight)
    return
  end
  if GetFramework() == "RedEM" then
    TriggerClientEvent("redemrp_inventory:OpenLocker",source,name)
    return
  end
  if GetFramework() == "RSG" or GetFramework() == "QBR" or GetFramework() == "QR" then
    TriggerClientEvent("kd_stable:client:openSaddlebag",source,name,invConfig)
    return
  end
end