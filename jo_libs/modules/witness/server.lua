jo.require("framework-bridge")
jo.require("emit")

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

  local targets = jo.framework:getPlayersWithJobs(jobs)
  if #targets == 0 then return end

  jo.emit.triggerClient(
    "jo_libs:witness:alert",
    targets,
    title,
    message,
    coords,
    blipDuration or 600000
  )
end
