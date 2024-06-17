jo.ui = {}

---@param level integer
---@param xp integer
---@param xpRequired integer
function jo.ui.updateRank(level, xp, xpRequired)
  local container = DatabindingAddDataContainerFromPath("", "mp_rank_bar")
  DatabindingAddDataString(container, "rank_text", tostring(level))
  DatabindingAddDataString(container, "rank_header_text", xp .. "/" .. xpRequired)
  DatabindingAddDataInt(container, "rank_header_text_alpha", 100)
  DatabindingAddDataInt(container, "xp_bar_minimum", 0)
  DatabindingAddDataInt(container, "xp_bar_maximum", xpRequired)
  DatabindingAddDataInt(container, "xp_bar_value", xp)
end

return jo.ui