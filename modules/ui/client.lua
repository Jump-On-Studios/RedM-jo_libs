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

-- Fonction pour formater le temps en minutes:secondes
local function formatTime(seconds)
    local minutes = math.floor(seconds / 60)
    seconds = seconds % 60
    return string.format("%02d:%02d", minutes, seconds)
end

-- Initialisation du TimerUI
function jo.ui.initTimer()
    jo.ui.TimerUI = {}
    jo.ui.TimerUI.data = {}
    jo.ui.TimerUI.data.uiFlowblock = Citizen.InvokeNative(0xC0081B34E395CE48, -119209833)

    local temp = 0
    while not UiflowblockIsLoaded(jo.ui.TimerUI.data.uiFlowblock) do
        temp = temp + 1
        if temp > 10000 then
            return
        end
        Citizen.Wait(1)
    end

    if not Citizen.InvokeNative(0x10A93C057B6BD944, jo.ui.TimerUI.data.uiFlowblock) then
        return
    end

    jo.ui.TimerUI.data.container = DatabindingAddDataContainerFromPath("", "centralInfoDatastore")
    DatabindingAddDataString(jo.ui.TimerUI.data.container, "timerMessageString", "")
    jo.ui.TimerUI.data.timer = DatabindingAddDataString(jo.ui.TimerUI.data.container, "timerString", "")
    jo.ui.TimerUI.data.show = DatabindingAddDataBool(jo.ui.TimerUI.data.container, "isVisible", false)

    UiflowblockEnter(jo.ui.TimerUI.data.uiFlowblock, `cTimer`)

    if UiStateMachineExists(1546991729) == 0 then
        jo.ui.TimerUI.data.stateMachine = UiStateMachineCreate(1546991729, jo.ui.TimerUI.data.uiFlowblock)
    end

    jo.ui.TimerUI.data.time = 0
    return jo.ui.TimerUI.data.stateMachine
end

-- Fonction pour arrêter le TimerUI
function jo.ui.stopTimer()
    if not jo.ui.TimerUI then return end
    jo.ui.TimerUI.data.time = 0
    DatabindingWriteDataBool(jo.ui.TimerUI.data.show, false)
end

-- Fonction pour démarrer le TimerUI
---@param time integer -- en secondes
---@param low? integer -- secondes à partir desquelles la couleur du timer devient rouge
function jo.ui.startTimer(time, low)
    if not jo.ui.TimerUI or UiStateMachineExists(1546991729) == 0 then return end
    DatabindingWriteDataBool(jo.ui.TimerUI.data.show, true)
    jo.ui.TimerUI.data.time = time or 60

    local function updateTimer()
        if jo.ui.TimerUI.data.time >= 0 then
            DatabindingWriteDataString(jo.ui.TimerUI.data.timer, formatTime(jo.ui.TimerUI.data.time))
            jo.ui.TimerUI.data.time = jo.ui.TimerUI.data.time - 1
            if low and jo.ui.TimerUI.data.time <= low then
                DatabindingAddDataBool(jo.ui.TimerUI.data.container, "isTimerLow", true)
            end
            jo.timeout.delay('updateTimer', 1000, updateTimer)
        else
            jo.ui.finishTimer()
        end
    end

    updateTimer()
end

-- Fonction pour terminer le TimerUI
function jo.ui.finishTimer()
    if not jo.ui.TimerUI then return end
    UiStateMachineDestroy(1546991729)
    if DatabindingIsEntryValid(jo.ui.TimerUI.data.container) then
        DatabindingRemoveDataEntry(jo.ui.TimerUI.data.container)
    end
    if DatabindingIsEntryValid(jo.ui.TimerUI.data.timer) then
        DatabindingRemoveDataEntry(jo.ui.TimerUI.data.timer)
    end
    if DatabindingIsEntryValid(jo.ui.TimerUI.data.show) then
        DatabindingRemoveDataEntry(jo.ui.TimerUI.data.show)
    end
end

return jo.ui
