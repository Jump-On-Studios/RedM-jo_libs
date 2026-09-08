RegisterNetEvent("vorpcharacter:reloadedskinlistener", function()
  local source = source

  if table.count(jo.framework:getUserIdentifiers(source)) == 0 then return end --Character not selected

  local skin = jo.framework:getUserSkin(source)
  local clothes = jo.framework:getUserClothes(source)

  TriggerClientEvent("jo_libs:client:applySkinAndClothes", source, nil, skin, clothes)
end)

-------------
-- EXTENDED COMPONENTS
-------------
--g_* files are loaded inside jo_libs only, so this runs once
jo.require("database")

MySQL.ready(function()
  jo.database.addColumn("characters", jo.framework.extraComponentsColumn, "LONGTEXT NULL DEFAULT NULL")
end)

--Move the table-shaped entries of `compPlayer` and `skinPlayer` into the extended column:
--they make 0xD3A7B003ED343FD9 fail since mr-947, and they hold the extended data.
--a healthy compPlayer is flat, so it holds a single `{`. skinPlayer legitimately nests
--`overlays`, so only the component keys are looked at there.
--the legacy format can only predate the column, so a single pass is enough: it rewrites
--`characters`, so it is left to the server owner instead of running on its own
RegisterCommand("jo_migrate_components", function(source)
  if source > 0 then return print("This command can only be run from the server console.") end
  if #GetPlayers() > 0 then return print("This command can only be run when no players are connected.") end

  local skinFilters = {}
  for i = 1, #jo.framework.skinComponents do
    skinFilters[i] = ([[skinPlayer LIKE '%%"%s":{%%']]):format(jo.framework.skinComponents[i])
  end

  local rows = MySQL.query.await(([[
      SELECT charidentifier, compPlayer, skinPlayer, `%s` AS extra FROM characters
      WHERE compPlayer LIKE '%%{%%{%%' OR %s
    ]]):format(jo.framework.extraComponentsColumn, table.concat(skinFilters, " OR ")), {}) or {}

  local migrated = 0

  for i = 1, #rows do
    local row = rows[i]
    local comps = UnJson(row.compPlayer)
    local skin = UnJson(row.skinPlayer)
    --the command can run on a character already holding extended data: keep it
    local extra = UnJson(row.extra)
    extra.clothes = extra.clothes or {}
    extra.skin = extra.skin or {}
    local dirty = false

    for category, value in pairs(comps) do
      if type(value) == "table" then
        dirty = true
        extra.clothes[category] = jo.cache.framework.extractExtraComponent(value)
        comps[category] = tonumber(value.hash)
      end
    end

    for j = 1, #jo.framework.skinComponents do
      local key = jo.framework.skinComponents[j]
      local data = skin[key]
      if type(data) == "table" then
        dirty = true
        extra.skin[key] = jo.cache.framework.extractExtraComponent(data)
        skin[key] = tonumber(data.hash) or 0
      end
    end

    if dirty then
      MySQL.update.await(("UPDATE characters SET compPlayer = ?, skinPlayer = ?, `%s` = ? WHERE charidentifier = ?"):format(jo.framework.extraComponentsColumn),
        { json.encode(comps), json.encode(skin), json.encode(extra), row.charidentifier })
      migrated = migrated + 1
    end
  end

  gprint(("%d character(s) migrated from the legacy format"):format(migrated))
end, true)

---Apply a character appearance read straight from the database, for the multicharacter
---selection screen where no character is used yet.
---`charid` comes from the client, so it is checked against the player identifier.
---@param charid integer (the character identifier to preview)
---@param ped? integer (the entity to dress, defaults to the player ped client-side)
RegisterNetEvent("jo_libs:server:vorp:applySkinAndClothes", function(charid, ped)
  local source = source
  charid = tonumber(charid)
  if not charid then return end

  local user = jo.framework.core.getUser(source)
  if not user then return end

  local skin, clothes = jo.framework:getCharacterAppearanceFromDatabase(charid, user.getIdentifier())
  if not skin then
    return eprint(("jo_libs:server:vorp:applySkinAndClothes -> character %s does not belong to source %s"):format(charid, source))
  end

  skin = jo.framework:standardizeSkin(skin)
  clothes = jo.framework:standardizeClothes(clothes)

  if clothes.teeth then
    skin.teeth = clothes.teeth.hash
    clothes.teeth = nil
  end

  TriggerClientEvent("jo_libs:client:applySkinAndClothes", source, ped, skin, clothes)
end)
