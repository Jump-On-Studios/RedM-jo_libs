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
  local column = jo.framework.extraComponentsColumn
  --the legacy format can only predate the column, so migrating on creation is enough
  if not jo.database.addColumn("characters", column, "LONGTEXT NULL DEFAULT NULL") then return end

  --table-shaped entries make 0xD3A7B003ED343FD9 fail since mr-947, and they hold the
  --extended data: move them instead of dropping them.
  --a healthy compPlayer is flat, so it holds a single `{`. skinPlayer can legitimately
  --nest `overlays` and `expressions`, so only Hair and Beard are looked at there.
  MySQL.query([[
    SELECT charidentifier, compPlayer, skinPlayer FROM characters
    WHERE compPlayer LIKE '%{%{%' OR skinPlayer LIKE '%"Hair":{%' OR skinPlayer LIKE '%"Beard":{%'
  ]], {}, function(rows)
    if not rows then return end

    local migrated = 0

    for i = 1, #rows do
      local row = rows[i]
      local comps = UnJson(row.compPlayer)
      local skin = UnJson(row.skinPlayer)
      --the column was just created, so it is NULL everywhere
      local extra = { clothes = {}, skin = {} }
      local dirty = false

      for category, value in pairs(comps) do
        if type(value) == "table" then
          dirty = true
          local hash = tonumber(value.hash) or 0
          extra.clothes[category] = jo.framework:extractExtraComponent(value, hash)
          comps[category] = hash
        end
      end

      for _, key in ipairs({ "Hair", "Beard" }) do
        if type(skin[key]) == "table" then
          dirty = true
          extra.skin[key] = skin[key]
          skin[key] = tonumber(skin[key].hash) or 0
        end
      end

      if dirty then
        MySQL.update(("UPDATE characters SET compPlayer = ?, skinPlayer = ?, `%s` = ? WHERE charidentifier = ?"):format(column),
          { json.encode(comps), json.encode(skin), json.encode(extra), row.charidentifier })
        migrated = migrated + 1
      end
    end

    if migrated > 0 then
      gprint(("%d character(s) migrated from the legacy format"):format(migrated))
    end
  end)
end)

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
