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

local completedKeys = {}        -- [key] = { consumedAt = number|nil }
local pressedKeys = {}          -- [key] = vk (raw keymap) or true (key received by the NUI while it has the focus)
local createdGroupsAmount = 0
local currentGroupVisible = nil -- GroupClass|nil
local forcedHide = false

-- * =============================================================================
-- * KEYS
-- * =============================================================================

local function getKeyVariants(key)
    local alias = jo.rawKeys.getAliasFromStandardKey(key)
    if alias ~= key then
        return { key, alias }
    end
    return { key }
end

local function resetCompletions()
    completedKeys = {}
end

local function doesKeyIsInVisiblePrompt(prompt, keys)
    if not prompt.visible then return false end
    if prompt.type == "separator" or not prompt.keyboardKeys then return false end
    for k = 1, #keys do
        if table.find(prompt.keyboardKeys, keys[k]) then
            return true, keys[k]
        end
    end
    return false
end

local function keyDown(key, vk)
    if not key then return end
    -- ignore the OS auto-repeat: the key is already down
    if pressedKeys[key] then return end
    local keys = getKeyVariants(key)
    for k = 1, #keys do
        pressedKeys[keys[k]] = vk or true
        -- a new press invalidates the previous completion of this key
        completedKeys[keys[k]] = nil
    end

    if not currentGroupVisible or forcedHide then return end
    local group = currentGroupVisible

    if #group.prompts > 1 and table.find(keys, group.nextPageKey) then
        SendNUIMessage({
            type = "nextPage",
        })
        group.currentPage = group.currentPage + 1
        if (group.currentPage > #group.prompts) then group.currentPage = 1 end
        resetCompletions()
        return true
    end

    local prompts = group.prompts[group.currentPage] or {}
    for p = 1, #prompts do
        local isValid, validKey = doesKeyIsInVisiblePrompt(prompts[p], keys)
        if isValid then
            SendNUIMessage({
                type = "keyDown",
                data = {
                    key = validKey
                }
            })
            return true
        end
    end
end

local function keyUp(key)
    if not key then return end
    local keys = getKeyVariants(key)
    for k = 1, #keys do
        pressedKeys[keys[k]] = nil
        SendNUIMessage({
            type = "keyUp",
            data = {
                key = keys[k]
            }
        })
    end
end

--- Releases the keys whose keyUp was never received (e.g. NUI focus taken or given back, or alt-tab while the key was held)
local function releaseStuckKeys()
    for key, vk in pairs(pressedKeys) do
        if vk == true then
            -- key received by the NUI: its keyUp can't come anymore once the NUI lost the focus
            if IsNuiFocused and not IsNuiFocused() then
                keyUp(key)
            end
        elseif IsRawKeyDown and not IsRawKeyDown(vk) then
            keyUp(key)
        end
    end
end

local keyListener
CreateThread(function()
    while not nuiLoaded do Wait(100) end
    keyListener = jo.rawKeys.listenAll(function(isPressed, key, vk)
        if isPressed then keyDown(key, vk) else keyUp(key) end
    end)
end)

jo.stopped(function()
    jo.rawKeys.removeListener(keyListener)
end)

-- * =============================================================================
-- * PROMPT
-- * =============================================================================

---@class PromptClass
---@field label string
---@field keyboardKeys string[]
---@field holdTime number|false
---@field price table|boolean
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
        price = false,
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
    -- the prompt is not attached to a page yet
    if self.page == -1 then return end
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

--- Sets the visibility of the prompt. A hidden prompt can't be triggered.
--- @param visible boolean (`true` to show the prompt, `false` to hide it.)
function PromptClass:setVisible(visible)
    self.visible = visible
    self:refreshNUI("visible")
end

--- Returns whether the prompt is currently visible.
--- @return boolean (`true` if the prompt is visible, `false` otherwise)
function PromptClass:isVisible()
    return self.visible
end

--- Configures the keyboard keys for the prompt. Ensures that the keys are stored in a table, converting them to lowercase.
--- @param keyboardKeys table|string (A table of key strings or a single key string.)
function PromptClass:setKeyboardKeys(keyboardKeys)
    if type(keyboardKeys) ~= "table" then
        keyboardKeys = { keyboardKeys }
    end
    local keys = {}
    for k = 1, #keyboardKeys do
        keys[k] = tostring(keyboardKeys[k]):lower()
    end
    self.keyboardKeys = keys
    self:refreshNUI("keyboardKeys")
end

--- Sets the key hold duration for the prompt.
--- @param holdTime number|boolean (Duration (in milliseconds) the key must be held before activation; `false` if not applicable.)
function PromptClass:setHoldTime(holdTime)
    self.holdTime = holdTime or false
    self:refreshNUI("holdTime")
end

--- Sets the prompt price and formats it with the shared pricing structure.
--- @param price table|integer|number|boolean|nil (The prompt price. Set it to `false` if no price is required)
function PromptClass:setPrice(price)
    jo.require("framework")
    jo.require("pricing")
    self.price = price and jo.framework:addItemDataToPrice(jo.pricing.new(price):getCosts()) or false
    self:refreshNUI("price")
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
---@field suppressNativePrompts boolean|integer[]
local GroupClass = {}
GroupClass.__index = GroupClass

function GroupClass:new()
    return setmetatable({
        id = -1,
        title = "",
        position = "bottom-right",
        prompts = {},
        visible = false,
        nextPageKey = "a",
        nextPageListener = nil,
        currentPage = 1,
        suppressNativePrompts = true,
    }, self)
end

--- Refreshes the NUI interface for the group by updating a specified property. This update is only sent if the group is currently visible.
--- @param property string (The group property to update (e.g., "title", "position",..).)
function GroupClass:refreshNUI(property)
    if currentGroupVisible ~= self then return end
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
    self.nextPageKey = string.lower(key)
    self:refreshNUI("nextPageKey")
end

--- Configures which native RedM prompt types are suppressed while this group is displayed.
--- Call without an argument or with `true` to suppress the default types 1 through 12.
--- Pass `false` or an empty table to suppress none, or an integer array to suppress only those types.
--- @param value? boolean|integer[]
function GroupClass:setSuppressNativePrompts(value)
    if value == nil or value == true then
        self.suppressNativePrompts = true
        return
    end

    if value == false then
        self.suppressNativePrompts = false
        return
    end

    if type(value) ~= "table" then
        return eprint("GroupClass:setSuppressNativePrompts > value must be nil, a boolean, or an integer array")
    end

    local amount = 0
    for index, promptType in pairs(value) do
        amount = amount + 1
        if type(index) ~= "number" or index < 1 or index % 1 ~= 0
            or type(promptType) ~= "number" or promptType % 1 ~= 0 then
            return eprint("GroupClass:setSuppressNativePrompts > value must be an integer array")
        end
    end

    if amount ~= #value then
        return eprint("GroupClass:setSuppressNativePrompts > value must be a contiguous integer array")
    end

    local promptTypes = {}
    local knownPromptTypes = {}
    for i = 1, #value do
        local promptType = value[i]
        if not knownPromptTypes[promptType] then
            knownPromptTypes[promptType] = true
            promptTypes[#promptTypes + 1] = promptType
        end
    end

    self.suppressNativePrompts = promptTypes
end

--- Returns whether the group is currently visible.
--- @return boolean (`true` if the group is visible, `false` otherwise)
function GroupClass:isVisible()
    return self.visible
end

--- Sends the whole group again to the NUI when it's displayed (e.g. after adding a prompt)
local function resendGroupIfVisible(group)
    if currentGroupVisible ~= group then return end
    SendNUIMessage({
        type = "setGroup",
        data = table.clearForNui(group)
    })
end

local function ensurePromptPage(group, page)
    if not group.prompts[page] then
        for i = 1, page do
            group.prompts[i] = group.prompts[i] or {}
        end
    end
end

--- Adds a new prompt to the group on a specified page. <br>Creates or initializes pages as necessary, assigns the prompt's position, and returns the new prompt.
--- @param key string (A key string for the prompt.)
--- @param label string (The descriptive label for the prompt.)
--- @param holdTime number|boolean (Duration to hold the key before the prompt triggers. <br> Set it to `false` if no hold time is required)
--- @param page? number (The page number to add the prompt to<br> defaults to 1.)
--- @param price? table|integer|number|boolean (The price to display next to the prompt label. Uses the shared pricing structure <br> defaults to false.)
--- @return PromptClass (The newly created prompt object.)
function GroupClass:addPrompt(key, label, holdTime, page, price)
    local prompt = PromptClass:new()
    key = key:lower()
    prompt.groupId = self.id
    prompt:setLabel(label)
    prompt:setKeyboardKeys(key)
    prompt:setHoldTime(holdTime)
    prompt:setPrice(price)

    page = page or 1

    ensurePromptPage(self, page)

    table.insert(self.prompts[page], prompt)
    prompt.page = page
    prompt.position = #self.prompts[page]
    resendGroupIfVisible(self)

    return prompt
end

--- Adds a visual separator to the group on a specified page.
--- @param page? number (The page number to add the separator to<br> defaults to 1.)
function GroupClass:addSeparator(page)
    page = page or 1
    ensurePromptPage(self, page)

    local separator = {
        type = "separator",
        visible = true,
        page = page,
        position = #self.prompts[page] + 1
    }
    table.insert(self.prompts[page], separator)
    resendGroupIfVisible(self)
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
            local suppressedNativePromptTypes = currentGroupVisible and currentGroupVisible.suppressNativePrompts
            if suppressedNativePromptTypes == true then
                for i = 1, 12 do
                    UiPromptDisablePromptTypeThisFrame(i)
                end
            elseif type(suppressedNativePromptTypes) == "table" then
                for i = 1, #suppressedNativePromptTypes do
                    UiPromptDisablePromptTypeThisFrame(suppressedNativePromptTypes[i])
                end
            end

            releaseStuckKeys()

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
    if currentGroupVisible ~= self then
        if currentGroupVisible then
            currentGroupVisible.visible = false
        end
        resetCompletions()
    end
    currentGroupVisible = self

    -- don't show the group over the pause menu or a fade: the loop will display it back
    if forcedHide and not isForcedHide() then
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
        resetCompletions()
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

    local keys = getKeyVariants(key)
    local completion
    for k = 1, #keys do
        completion = completion or completedKeys[keys[k]]
    end
    if not completion then
        return false
    end

    if fireMultipleTimes then
        -- true as long as the key is held after the completion
        for k = 1, #keys do
            if pressedKeys[keys[k]] then return true end
        end
        return false
    end

    -- the completion is consumed by the first read, but stays valid for every read done during the same game time
    local currentTime = GetGameTimer()
    if not completion.consumedAt then
        completion.consumedAt = currentTime
        return true
    end

    return completion.consumedAt == currentTime
end

function jo.promptNui.isDisplayed()
    return currentGroupVisible ~= nil
end

-- * ===============================================================================
-- * RegisterNUICallback for NUI Driven
-- * ===============================================================================
RegisterNUICallback("keyCompleted", function(data, cb)
    cb({ ok = "ok" })
    if type(data?.kkey) ~= "string" then return end
    if forcedHide then return end
    -- ignore the completions sent by a group that is not displayed anymore
    if not currentGroupVisible or currentGroupVisible.id ~= data.groupId then return end
    completedKeys[data.kkey:lower()] = {}
end)

-- Keys received by the NUI while it has the focus (e.g. a menu is open): the raw keymaps don't fire in that case
RegisterNUICallback("keyDown", function(data, cb)
    cb({ ok = "ok" })
    if type(data?.key) ~= "string" then return end
    keyDown(data.key:lower())
end)

RegisterNUICallback("keyUp", function(data, cb)
    cb({ ok = "ok" })
    if type(data?.key) ~= "string" then return end
    keyUp(data.key:lower())
end)
