jo.require("framework-bridge")

jo.createModule("webhook")

-- When nil, `dispatch` falls back to reading `Config.Webhook` and the global
-- `SendScriptWebhook` from the consumer resource. Set explicitly via
-- `jo.webhook.setConfig(...)` for a cleaner integration.
local config = nil

--- Configure the webhook backend explicitly.
--- Call this once at startup (e.g. in your resource's server.lua) before
--- invoking `jo.webhook.dispatch`. When omitted, the module falls back
--- to `Config.Webhook` and the global `SendScriptWebhook` function.
---@param opts table
---| "type" # "discord"|"custom" — routing mode
---| "url" # string? — Discord webhook URL (required when type = "discord")
---| "customHandler" # fun(payload: table)? — called when type = "custom"
function jo.webhook.setConfig(opts)
  config = opts or {}
end

local function resolveConfig()
  if config then return config end
  if Config and Config.Webhook then
    return {
      type = Config.Webhook.type,
      url = Config.Webhook.url,
      customHandler = _G.SendScriptWebhook,
    }
  end
end

--- Dispatch a Discord-compatible payload using the active config.
--- Routes to the Discord URL when `type = "discord"`, or to the custom
--- handler when `type = "custom"`. Silently no-ops if no config is set
--- and no fallback exists.
---@param data table Discord webhook payload (e.g. `{ username, avatar_url, embeds }`)
function jo.webhook.dispatch(data)
  local cfg = resolveConfig()
  if not cfg then return end
  if cfg.type == "custom" then
    if cfg.customHandler then cfg.customHandler(data) end
    return
  end
  if not cfg.url or cfg.url == "" then return end
  local ok, body = pcall(json.encode, data)
  if not ok then return end
  PerformHttpRequest(cfg.url, function() end, "POST", body, { ["Content-Type"] = "application/json" })
end

--- Build a Discord embed with a consistent footer (script name + timestamp)
--- and an ISO-8601 timestamp.
---@param opts table
---| "title" # string? — Embed title
---| "description" # string? — Embed description
---| "color" # integer? — Embed color (default: `3066993` green)
---| "fields" # table? — Embed fields array
---| "script_name" # string? — Override footer resource name (default: current resource)
---@return table embed
function jo.webhook.buildEmbed(opts)
  local script_name = opts.script_name or GetCurrentResourceName()
  return {
    title = opts.title or "",
    description = opts.description or "",
    color = opts.color or 3066993,
    fields = opts.fields or {},
    footer = { text = script_name .. " • " .. os.date("%d/%m/%Y %H:%M:%S") },
    timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
  }
end

--- Return basic identity info for a player, useful as webhook embed fields.
---@param source integer Server ID of the player
---@return table info `{ name, serverId, steam, charId }`
function jo.webhook.getPlayerInfo(source)
  local info = {
    name = GetPlayerName(source) or "Unknown",
    serverId = tostring(source),
    steam = "Unknown",
    charId = "Unknown",
  }

  for _, id in ipairs(GetPlayerIdentifiers(source) or {}) do
    if id:find("^steam:") then
      info.steam = id
      break
    end
  end

  if jo.isModuleLoaded("framework-bridge", false) then
    local user = jo.framework:getUser(source)
    if type(user) == "table" then
      local ids = user:getIdentifiers()
      if ids then info.charId = tostring(ids.charid or "Unknown") end
    end
  end

  return info
end

--- Build a ready-to-dispatch Discord payload with player identity fields
--- (Player / Server ID / Steam) prepended to the embed fields.
---@param source integer Server ID of the player
---@param opts table
---| "title" # string? — Embed title
---| "description" # string? — Embed description
---| "color" # integer? — Embed color
---| "extra_fields" # table? — Additional embed fields appended after the identity fields
---| "script_name" # string? — Override username/footer (default: current resource)
---| "avatar_url" # string? — Webhook avatar URL
---@return table payload
function jo.webhook.buildPayload(source, opts)
  local player = jo.webhook.getPlayerInfo(source)
  local script_name = opts.script_name or GetCurrentResourceName()

  local fields = {
    { name = "Player",    value = player.name,     inline = true },
    { name = "Server ID", value = player.serverId, inline = true },
    { name = "Steam",     value = player.steam,    inline = true },
  }
  if opts.extra_fields then
    for _, f in ipairs(opts.extra_fields) do fields[#fields + 1] = f end
  end

  return {
    username = script_name,
    avatar_url = opts.avatar_url or "",
    embeds = {
      jo.webhook.buildEmbed({
        title = opts.title,
        description = opts.description,
        color = opts.color,
        fields = fields,
        script_name = script_name,
      }),
    },
  }
end
