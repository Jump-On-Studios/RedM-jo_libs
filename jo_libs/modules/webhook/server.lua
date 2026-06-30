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

--- Return basic identity info for a player using native FiveM APIs only.
--- Extra identifiers (char ID, job, etc.) must be supplied by the caller
--- via `opts.player` on `buildPayload`, so this module stays independent
--- of the framework-bridge.
---@param source integer Server ID of the player
---@return table info `{ name, serverId, steam }`
function jo.webhook.getPlayerInfo(source)
  local info = {
    name = GetPlayerName(source) or "Unknown",
    serverId = tostring(source),
    steam = "Unknown",
  }

  local identifiers = GetPlayerIdentifiers(source) or {}
  for i = 1, #identifiers do
    local id = identifiers[i]
    if id:find("^steam:") then
      info.steam = id
      break
    end
  end

  return info
end

--- Build a ready-to-dispatch Discord payload with player identity fields
--- prepended to the embed fields. When `opts.player` is provided it is used
--- verbatim, so callers can inject framework-specific fields like `charId`
--- without creating a dependency from this module on framework-bridge.
---@param source integer Server ID of the player
---@param opts table
---| "title" # string? — Embed title
---| "description" # string? — Embed description
---| "color" # integer? — Embed color
---| "player" # table? — `{ name?, serverId?, steam?, charId?, ... }` overrides the native lookup
---| "extra_fields" # table? — Additional embed fields appended after the identity fields
---| "script_name" # string? — Override username/footer (default: current resource)
---| "avatar_url" # string? — Webhook avatar URL
---@return table payload
function jo.webhook.buildPayload(source, opts)
  local player = opts.player or jo.webhook.getPlayerInfo(source)
  local script_name = opts.script_name or GetCurrentResourceName()

  local fields = {}
  if player.name     then fields[#fields + 1] = { name = "Player",    value = tostring(player.name),     inline = true } end
  if player.serverId then fields[#fields + 1] = { name = "Server ID", value = tostring(player.serverId), inline = true } end
  if player.steam    then fields[#fields + 1] = { name = "Steam",     value = tostring(player.steam),    inline = true } end
  if player.charId   then fields[#fields + 1] = { name = "Char ID",   value = tostring(player.charId),   inline = true } end

  if opts.extra_fields then
    for i = 1, #opts.extra_fields do fields[#fields + 1] = opts.extra_fields[i] end
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
