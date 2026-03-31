jo.createModule("promptNui")
jo.require("table")
jo.require("raw-keys")

local NativeSendNUIMessage = SendNUIMessage
local nuiLoaded = false

local function SendNUIMessage(data)
    while not nuiLoaded do
        Wait(100)
    end
    data.messageTargetUiName = "jo_prompt"
    NativeSendNUIMessage(data)
end

CreateThread(function()
    Wait(100)
    if GetResourceMetadata(GetCurrentResourceName(), "ui_page") ~= "nui://jo_libs/nui/prompt/index.html" then
        jo.nui.load("jo_prompt", "nui://jo_libs/nui/prompt/index.html")
        Wait(1000)
    end
    nuiLoaded = true
end)

-- * =============================================================================
-- * VARIABLES
-- * =============================================================================

local keysCompleted = {}
local createdGroupsAmount = 0
local currentGroupVisible = nil -- GroupClass|nil
local forcedHide = false

-- * =============================================================================
-- * KEYS
-- * =============================================================================

local function doesKeyIsInVisiblePrompt(prompt, keys)
    if not prompt.visible then return false end
    for k = 1, #keys do
        if table.find(prompt.keyboardKeys, keys[k]) then
            return true, keys[k]
        end
    end
    return false
end

local function keyDown(vk)
    if not currentGroupVisible then return end
    local group = currentGroupVisible
    local page = group.currentPage
    local prompts = group.prompts[page]
    local key = jo.rawKeys.getKeyFromVK(vk)
    if not key then return end
    local alias = jo.rawKeys.getAliasFromStandardKey(key)
    local keys = { key }
    if alias ~= key then
        keys[#keys + 1] = alias
    end
    for p = 1, #prompts do
        local prompt = prompts[p]
        local isValid, validKey = doesKeyIsInVisiblePrompt(prompt, keys)
        if isValid then
            SendNUIMessage({
                type = "keyDown",
                data = {
                    key = validKey
                }
            })
            if validKey == group.nextPageKey then
                SendNUIMessage({
                    type = "nextPage",
                })
                group.currentPage = group.currentPage + 1
                if (group.currentPage > #group.prompts) then group.currentPage = 1 end
            end
            return true
        end
    end
end

local function keyUp(vk)
    local key = jo.rawKeys.getKeyFromVK(vk)
    SendNUIMessage({
        type = "keyUp",
        data = {
            key = key
        }
    })
    local alias = jo.rawKeys.getAliasFromStandardKey(key)
    if alias == key then return end
    SendNUIMessage({
        type = "keyUp",
        data = {
            key = alias
        }
    })
end

local vks = jo.rawKeys.getAllVK()
local vk_listener = {}
CreateThread(function()
    while not nuiLoaded do Wait(100) end
    for k = 1, #vks do
        local vk = vks[k]
        local listener = jo.rawKeys.listen(vk, function(isPressed)
            if isPressed then keyDown(vk) else keyUp(vk) end
        end)
        table.insert(vk_listener, listener)
    end
end)

jo.stopped(function()
    for l = 1, #vk_listener do
        jo.rawKeys.removeListener(vk_listener[l])
    end
end)

-- * =============================================================================
-- * PROMPT
-- * =============================================================================

---@class PromptClass
---@field label string
---@field keyboardKeys string[]
---@field holdTime number|false
---@field disabled boolean
---@field visible boolean
---@field page number
---@field position number
---@field groupId number
---@field listener integer|nil
local PromptClass = {}
PromptClass.__index = PromptClass

function PromptClass:new()
    return setmetatable({
        label = "",
        keyboardKeys = {},
        holdTime = false,
        disabled = false,
        visible = true,
        page = -1,
        position = -1,
        groupId = -1,
        listener = nil
    }, self)
end

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

--- Get the label text for the prompt.
--- @return string (The text label assigned to the prompt.)
function PromptClass:getLabel()
    return self.label
end

--- Enables or disables the prompt and updates its associated key listeners.
--- @param enabled boolean (`true` to enable the prompt, `false` to disable it.)
function PromptClass:setEnabled(enabled)
    self.disabled = not enabled
    self:refreshNUI("disabled")
end

--- Sets the visibility of the prompt and updates its enabled state accordingly.
--- @param visible boolean (`true` to show the prompt, `false` to hide it.)
function PromptClass:setVisible(visible)
    self.visible = visible
    self:setEnabled(visible)
    self:refreshNUI("visible")
end

--- Returns whether the prompt is currently visible.
--- @return boolean (`true` if the prompt is visible, `false` otherwise)
function PromptClass:isVisible()
    return self.visible
end

--- Configures the keyboard keys for the prompt. Ensures that the keys are stored in a table, converting a single key to uppercase if needed.
--- @param keyboardKeys table|string (A table of key strings or a single key string.)
function PromptClass:setKeyboardKeys(keyboardKeys)
    if type(keyboardKeys) == "table" then
        self.keyboardKeys = keyboardKeys
    else
        self.keyboardKeys = { keyboardKeys }
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

---@class GroupClass
---@field id integer
---@field title string
---@field position string
---@field prompts table<number, PromptClass[]>
---@field visible boolean
---@field nextPageKey string
---@field nextPageListener integer|nil
---@field currentPage number
local GroupClass = {}
GroupClass.__index = GroupClass

function GroupClass:new()
    return setmetatable({
        id = -1,
        title = "",
        position = "bottom-right",
        prompts = {},
        visible = false,
        nextPageKey = "A",
        nextPageListener = nil,
        currentPage = 1,
    }, self)
end

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
--- @param key string (A key string for the prompt.)
--- @param label string (The descriptive label for the prompt.)
--- @param holdTime number|boolean (Duration to hold the key before the prompt triggers. <br> Set it to `false` if no hold time is required)
--- @param page? number (The page number to add the prompt to<br> defaults to 1.)
--- @return PromptClass (The newly created prompt object.)
function GroupClass:addPrompt(key, label, holdTime, page)
    local prompt = PromptClass:new()
    key = key:lower()
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

local function isForcedHide()
    if IsPauseMenuActive() then return true end
    if IsScreenFadedOut() then return true end
    if IsScreenFadingOut() then return true end
    if IsScreenFadingIn() then return true end
    if IsLoadingScreenVisible() then return true end
    return false
end

local loopStarted = false
local function startLoop()
    if loopStarted then return end
    loopStarted = true
    CreateThread(function()
        while jo.promptNui.isDisplayed() do
            -- Standard group display operations
            for i = 1, 12 do
                UiPromptDisablePromptTypeThisFrame(i)
            end

            if currentGroupVisible and isForcedHide() then
                currentGroupVisible:forceHide()
                while isForcedHide() do
                    Wait(100)
                end
                Wait(650)
                if currentGroupVisible then
                    currentGroupVisible:forceDisplay()
                end
            end

            Wait(0)
        end
        loopStarted = false
    end)
end

--- Displays the prompt group on the NUI interface and sets up key listeners for the active page. If the group has multiple pages, it also configures pagination using the nextPageKey.
--- @param page? number (The page number to display<br> defaults to the group's current page.)
function GroupClass:display(page)
    currentGroupVisible = self

    if forcedHide then
        forcedHide = false
        SendNUIMessage({
            type = "forceHide",
            data = { value = false }
        })
    end

    self.currentPage = page and math.min(page, #self.prompts) or self.currentPage
    self.visible = true
    SendNUIMessage({
        type = "setGroup",
        data = table.clearForNui(self)
    })
    startLoop()
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
    self.visible = false

    -- Only clear the global state if this group is still the active one
    if currentGroupVisible == self then
        currentGroupVisible = nil
        keysCompleted = {}
        SendNUIMessage({
            type = "setGroup",
            data = {
                prompts = {}
            }
        })
    end
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
    local group = GroupClass:new()
    group:setTitle(title)
    createdGroupsAmount = createdGroupsAmount + 1
    group.id = createdGroupsAmount
    if position then group:setPosition(position) end

    return group
end

--- Checks whether a specified key has been held for the required duration to trigger an action.<br>Optionally ensures that the key does not trigger repeatedly unless explicitly allowed.
--- @param group GroupClass|string (The prompt group to validate against. Retrocompatible: can be the key string.)
--- @param key string|boolean|nil (The key identifier to check. Retrocompatible: can be `fireMultipleTimes`.)
--- @param fireMultipleTimes? boolean|nil (If true, allows the key to trigger multiple times<br> defaults to `false`.)
--- @return boolean (True if the key press is complete and valid, otherwise `false`.)
function jo.promptNui.isCompleted(group, key, fireMultipleTimes)
    -- Retrocompat with old signature: isCompleted(key, fireMultipleTimes)
    if forcedHide then return false end

    if type(key) ~= "string" then
        fireMultipleTimes = key
        key = group
        group = nil
    end

    if type(key) ~= "string" then return false end

    fireMultipleTimes = GetValue(fireMultipleTimes, false)
    key = key:lower()

    -- When a group is provided, only allow completion checks for the currently visible group.
    if group then
        if not jo.promptNui.isDisplayed() then return false end

        if type(group) == "table" then
            if currentGroupVisible.id ~= group.id then return false end
        elseif currentGroupVisible.id ~= group then
            return false
        end
    end

    if not keysCompleted[key] then
        return false
    end

    if fireMultipleTimes then
        return true
    end

    local currentTime = GetGameTimer()
    if keysCompleted[key] ~= currentTime then
        return false
    end

    return true
end

function jo.promptNui.isDisplayed()
    return currentGroupVisible ~= nil
end

-- * ===============================================================================
-- * RegisterNUICallback for NUI Driven
-- * ===============================================================================
RegisterNUICallback("keyCompleted", function(data, cb)
    -- log("keyCompleted", data)
    local key = data.kkey:lower()
    keysCompleted[key] = GetGameTimer()
    cb({ ok = "ok" })
end)

RegisterNUICallback("keyUp", function(data, cb)
    -- log("keyCompleted", data)
    local key = data.kkey:lower()
    keysCompleted[key] = nil
    cb({ ok = "ok" })
end)

RegisterNUICallback("keyDown", function(data, cb)
    -- log("keyCompleted", data)
    local key = data.kkey:lower()
    keysCompleted[key] = nil
    cb({ ok = "ok" })
end)
