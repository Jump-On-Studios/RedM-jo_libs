jo.require("framework-bridge")

jo.createModule("witness")

--- Broadcast a witness alert (notification + temporary map blip) to every online
--- player whose job matches the given list. The client-side handler is registered
--- automatically by `modules/witness/client.lua`.
---@param jobs string[] List of job names allowed to receive the alert (e.g. `{ "police", "sheriff" }`)
---@param title string Notification title (also used as blip label)
---@param message string Notification body text
---@param coords vector3 World position of the map blip
---@param blipDuration? integer Blip lifetime in ms (default: `600000` = 10 minutes)
function jo.witness.report(jobs, title, message, coords, blipDuration)
  if not jobs or #jobs == 0 then return end

  local jobSet = {}
  for _, j in ipairs(jobs) do jobSet[j] = true end

  local duration = blipDuration or 600000

  for _, playerId in ipairs(GetPlayers()) do
    local src = tonumber(playerId)
    local user = jo.framework:getUser(src)
    if user and type(user) == "table" then
      local job = user:getJob()
      if job and jobSet[job] then
        TriggerClientEvent("jo_libs:witness:alert", src, title, message, coords, duration)
      end
    end
  end
end
