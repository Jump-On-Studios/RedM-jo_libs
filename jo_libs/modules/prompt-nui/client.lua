jo.promptNui = {}
jo.require("table")
jo.require("raw-keys")

local clockStart = GetGameTimer()
local NativeSendNUIMessage = SendNUIMessage
local function SendNUIMessage(data)
    if clockStart == GetGameTimer() then Wait(500) end
    data.messageTargetUiName = "jo_prompt"
    NativeSendNUIMessage(data)
end

CreateThread(function()
    Wait(100)
    if GetResourceMetadata(GetCurrentResourceName(), "ui_page") == "nui://jo_libs/nui/prompt/index.html" then
        return
    end
    jo.nui.load("jo_prompt", "nui://jo_libs/nui/prompt/index.html")
end)





-- * =============================================================================
-- * VARIABLES
-- * =============================================================================

local keysPressed = {}
local keysFired = {}
local createdGroupsAmount = 0
local currentGroupVisible = nil
local forcedHide = false
local nuiDriven = false
local nuiDrivenCompletedKeys = {}


-- * ===============================================================================
-- * RegisterNUICallback for NUI Driven
-- * ===============================================================================
RegisterNUICallback("keyCompleted", function(data, cb)
    if nuiDriven then
        local key = data.kkey:upper()
        nuiDrivenCompletedKeys[key] = true
    end
    cb({ ok = "ok" })
end)

RegisterNUICallback("keyUp", function(data, cb)
    if nuiDriven then
        local key = data.kkey:upper()
        nuiDrivenCompletedKeys[key] = nil
    end
    cb({ ok = "ok" })
end)

-- * =============================================================================
-- * HELPERS
-- * =============================================================================

-- Listens for key press and release events for a specified key.
-- Updates the keysPressed and keysFired tables based on the key state,
-- and sends an NUI message indicating whether the key was pressed or released.
-- @param key string: The key identifier to listen for.
-- @param holdTime number|nil: Duration (in milliseconds) the key must be held before triggering.
-- @return nil
local function listenKey(key, holdTime)
    jo.rawKeys.listen(key, function(isPressed)
        if isPressed then
            keysPressed[key] = GetGameTimer() + (holdTime or 0)
        else
            keysPressed[key] = nil
            keysFired[key] = nil
        end

        SendNUIMessage({
            type = isPressed and "keyDown" or "keyUp",
            data = {
                key = key
            }
        })
    end)
end

-- Removes key listeners and resets key states for all prompts on a specified page.
-- @param group table: The prompt group containing the page.
-- @param pageNumber number: The page number from which to remove key listeners.
-- @return nil
local function removePage(group, pageNumber)
    if not group.prompts[pageNumber] then return end
    for i = 1, #group.prompts[pageNumber] do
        local prompt = group.prompts[pageNumber][i]
        for j = 1, #prompt.keyboardKeys do
            local key = prompt.keyboardKeys[j]
            jo.rawKeys.remove(key)
            keysPressed[key] = nil
            keysFired[key] = nil
            SendNUIMessage({
                type = "keyUp",
                data = {
                    key = key
                }
            })
        end
    end
end

-- * =============================================================================
-- * PROMPT
-- * =============================================================================

local PromptClass = {
    label = "",
    keyboardKeys = {},
    holdTime = false,
    disabled = false,
    visible = true,
    page = -1,
    position = -1,
    groupId = -1
}

--- Refreshes the NUI interface for a prompt, updating a specific property. This update is only performed if the prompt belongs to the currently visible group.
--- @param property string (The property name to update (e.g., "label", "disabled").)
function PromptClass:refreshNUI(property)
    if currentGroupVisible?.id ~= self.groupId then
        return
    end
    SendNUIMessage({
        type = "updatePrompt",
        data = {
            page = self.page,
            position = self.position,
            property = property,
            value = self[property]
        }
    })
end

--- Sets the label text for the prompt.
--- @param label string (The text label to assign to the prompt.)
function PromptClass:setLabel(label)
    self.label = label
    self:refreshNUI("label")
end

--- Enables or disables the prompt and updates its associated key listeners.
--- @param enabled boolean (`true` to enable the prompt, `false` to disable it.)
function PromptClass:setEnabled(enabled)
    self.disabled = not enabled
    for i = 1, #self.keyboardKeys do
        if enabled then
            listenKey(self.keyboardKeys[i], self.holdTime)
        else
            jo.rawKeys.remove(self.keyboardKeys[i])
        end
    end
    self:refreshNUI("disabled")
end

--- Sets the visibility of the prompt and updates its enabled state accordingly.
--- @param visible boolean (`true` to show the prompt, `false` to hide it.)
function PromptClass:setVisible(visible)
    self.visible = visible
    self:setEnabled(visible)
    self:refreshNUI("visible")
end

--- Configures the keyboard keys for the prompt. Ensures that the keys are stored in a table, converting a single key to uppercase if needed.
--- @param keyboardKeys table|string (A table of key strings or a single key string.)
function PromptClass:setKeyboardKeys(keyboardKeys)
    if type(keyboardKeys) == "table" then
        self.keyboardKeys = keyboardKeys
    else
        self.keyboardKeys = { string.upper(keyboardKeys) }
    end
end

--- Sets the key hold duration for the prompt.
--- @param holdTime number|boolean (Duration (in milliseconds) the key must be held before activation; `false` if not applicable.)
function PromptClass:setHoldTime(holdTime)
    self.holdTime = holdTime or false
    self:refreshNUI("holdTime")
end

-- * =============================================================================
-- * GROUP
-- * =============================================================================

local GroupClass = {
    id = -1,
    title = "",
    position = "bottom-right",
    prompts = {},
    visible = false,
    nextPageKey = "A",
    currentPage = 1,

}

--- Refreshes the NUI interface for the group by updating a specified property. This update is only sent if the group is currently visible.
--- @param property string (The group property to update (e.g., "title", "position",..).)
function GroupClass:refreshNUI(property)
    if not self.visible then return end
    SendNUIMessage({
        type = "updateGroup",
        data = {
            id = self.id,
            property = property,
            value = self[property]
        }
    })
end

--- Sets the title for the prompt group.
--- @param title string (The title to assign to the group.)
function GroupClass:setTitle(title)
    self.title = title
    self:refreshNUI("title")
end

--- Sets the display position for the prompt group.
--- @param position string (The screen position for the group. <br> Allowed values are : `"bottom-right"`,`"center-right"`,`"top-right"`,`"bottom-left"`,`"center-left"`,`"top-left"`)
function GroupClass:setPosition(position)
    self.position = position
    self:refreshNUI("position")
end

--- Sets the key used for navigating to the next page of prompts.
--- @param key string (The key string to be used for pagination.)
function GroupClass:setNextPageKey(key)
    self.nextPageKey = string.upper(key)
end

--- Returns whether the group is currently visible.
--- @return boolean (`true` if the group is visible, `false` otherwise)
function GroupClass:isVisible()
    return self.visible
end

--- Adds a new prompt to the group on a specified page. <br>Creates or initializes pages as necessary, assigns the prompt's position, and returns the new prompt.
--- @param key string|table (A key string or table of key strings for the prompt.)
--- @param label string (The descriptive label for the prompt.)
--- @param holdTime number|boolean (Duration to hold the key before the prompt triggers. <br> Set it to `false` if no hold time is required)
--- @param page? number (The page number to add the prompt to<br> defaults to 1.)
--- @return PromptClass (The newly created prompt object.)
function GroupClass:addPrompt(key, label, holdTime, page)
    local prompt = table.copy(PromptClass)
    key = key:upper()
    prompt.groupId = self.id
    prompt:setLabel(label)
    prompt:setKeyboardKeys(key)
    prompt:setHoldTime(holdTime)

    page = page or 1

    if not self.prompts[page] then
        for i = 1, page do
            self.prompts[i] = self.prompts[i] or {}
        end
    end

    table.insert(self.prompts[page], prompt)
    prompt.page = page
    prompt.position = #self.prompts[page]
    return prompt
end

-- Activates key listeners for all prompts on a specified page of a prompt group.
-- @param group table: The prompt group containing pages of prompts.
-- @param pageNumber number: The page number from which to activate key listeners.
-- @return nil
local function listenPage(group, pageNumber)
    if not group.prompts[pageNumber] then return end
    for i = 1, #group.prompts[pageNumber] do
        local prompt = group.prompts[pageNumber][i]
        if (not prompt.disabled) then
            for j = 1, #prompt.keyboardKeys do
                local key = prompt.keyboardKeys[j]
                listenKey(key, prompt.holdTime)
            end
        end
    end
end

local function isNuiDriven()
    if IsNuiFocused() and not IsNuiFocusKeepingInput() then return true end
    return false
end



local function isForcedHide()
    if IsPauseMenuActive() then return true end
    if IsScreenFadedOut() then return true end
    if IsScreenFadingOut() then return true end
    if IsScreenFadingIn() then return true end
    if IsLoadingScreenVisible() then return true end
    return false
end

--- Displays the prompt group on the NUI interface and sets up key listeners for the active page. If the group has multiple pages, it also configures pagination using the nextPageKey.
--- @param page? number (The page number to display<br> defaults to the group's current page.)
function GroupClass:display(page)
    if currentGroupVisible then
        jo.rawKeys.remove(currentGroupVisible.nextPageKey)
        removePage(currentGroupVisible, currentGroupVisible.currentPage)
    end

    local lastGroupVisibleId = currentGroupVisible and currentGroupVisible.id or -1
    currentGroupVisible = self

    if lastGroupVisibleId ~= self.id then
        CreateThread(function()
            local wasNuiDriven = nuiDriven -- Initialize with current state

            -- Do an immediate check at the start
            nuiDriven = isNuiDriven()

            while true do
                if not currentGroupVisible or (currentGroupVisible.id ~= self.id) then break end

                local currentNuiState = isNuiDriven()
                if currentNuiState ~= nuiDriven then
                    -- State changed, update immediately
                    nuiDriven = currentNuiState

                    -- Reset nuiDrivenCompletedKeys when exiting nuiDriven mode
                    if wasNuiDriven and not nuiDriven then
                        nuiDrivenCompletedKeys = {}
                    end

                    wasNuiDriven = nuiDriven
                end

                -- Standard group display operations
                for i = 1, 12 do
                    UiPromptDisablePromptTypeThisFrame(i)
                end

                if isForcedHide() then
                    self:forceHide()
                    while isForcedHide() do
                        Wait(100)
                    end
                    Wait(650)
                    self:forceDisplay()
                end

                Wait(0)
            end
        end)
    end

    self.currentPage = page and math.min(page, #self.prompts) or self.currentPage
    self.visible = true
    SendNUIMessage({
        type = "setGroup",
        data = table.clearForNui(self)
    })

    listenPage(self, self.currentPage)

    if #self.prompts > 1 then
        jo.rawKeys.listen(self.nextPageKey, function(isPressed)
            if isPressed then
                SendNUIMessage({
                    type = "nextPage",
                })
                removePage(self, self.currentPage)
                self.currentPage = self.currentPage + 1
                if (self.currentPage > #self.prompts) then self.currentPage = 1 end
                listenPage(self, self.currentPage)
            end
            SendNUIMessage({
                type = isPressed and "keyDown" or "keyUp",
                data = {
                    key = self.nextPageKey
                }
            })
        end)
    end
end

function GroupClass:forceDisplay()
    forcedHide = false
    SendNUIMessage({
        type = "forceHide",
        data = { value = false }
    })
end

--- Hides the prompt group from the NUI interface and removes its active key listeners.
function GroupClass:hide()
    currentGroupVisible = nil
    self.visible = false
    SendNUIMessage({
        type = "setGroup",
        data = {
            prompts = {}
        }
    })
    jo.rawKeys.remove(self.nextPageKey)
    removePage(self, self.currentPage)
end

function GroupClass:forceHide()
    forcedHide = true
    SendNUIMessage({
        type = "forceHide",
        data = { value = true }
    })
end

-- * =============================================================================
-- * MODULE FUNCTIONS
-- * =============================================================================

--- Creates a new prompt group with a specified title and optional position.
--- @param title string|boolean (The title for the new prompt group. Set to `false` to have no title)
--- @param position? string (The screen position for the group. <br> Allowed values are : `"bottom-right"`,`"center-right"`,`"top-right"`,`"bottom-left"`,`"center-left"`,`"top-left"` <br> default : `"bottom-right"`)
--- @return GroupClass (A new instance of a prompt group.)
function jo.promptNui.createGroup(title, position)
    local group = table.copy(GroupClass)
    group:setTitle(title)
    createdGroupsAmount = createdGroupsAmount + 1
    group.id = createdGroupsAmount
    if position then group:setPosition(position) end

    return group
end

--- Checks whether a specified key has been held for the required duration to trigger an action.<br>Optionally ensures that the key does not trigger repeatedly unless explicitly allowed.
--- @param key string (The key identifier to check.)
--- @param fireMultipleTimes? boolean|nil (If true, allows the key to trigger multiple times<br> defaults to `false`.)
--- @return boolean (True if the key press is complete and valid, otherwise `false`.)
function jo.promptNui.isCompleted(key, fireMultipleTimes)
    fireMultipleTimes = fireMultipleTimes or false
    key = key:upper()
    if forcedHide then return false end


    -- Check for NUI-driven completed keys when in NUI mode
    if nuiDriven then
        if nuiDrivenCompletedKeys[key] then
            if not fireMultipleTimes then
                nuiDrivenCompletedKeys[key] = nil
            end
            return true
        end

        return false
    end

    if not keysPressed[key] then return false end

    if GetGameTimer() >= keysPressed[key] then
        if (not fireMultipleTimes and keysFired[key]) then return false end
        keysFired[key] = true
        return true
    end
    return false
end
