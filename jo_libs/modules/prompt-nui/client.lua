jo.promptNui = {}
jo.require("table")
jo.require("raw-keys")

-- * =============================================================================
-- * VARIABLES
-- * =============================================================================

local keysPressed = {}
local keysFired = {}

-- * =============================================================================
-- * PROMPT
-- * =============================================================================

local PromptClass = {
    label = "",
    keyboardKeys = {},
    holdTime = false,
    disabled = false,
    visible = true
}


--- Sets the label for the prompt.
--- @param label string: The label to assign to the prompt.
--- @return nil
function PromptClass:setLabel(label)
    self.label = label
end

function PromptClass:setEnabled(enabled)
    self.enabled = enabled
end

function PromptClass:setVisible(visible)
    self.visible = visible
end

--- Sets the keyboard keys for the prompt.
--- Ensures the keys are stored in a table.
--- @param keyboardKeys table|string: A table of keys or a single key string.
--- @return nil
function PromptClass:setKeyboardKeys(keyboardKeys)
    -- ensure that keyboardKeys is always a table of keys
    if type(keyboardKeys) == "table" then
        self.keyboardKeys = keyboardKeys -- todo upper each keys in the table
    else
        self.keyboardKeys = { string.upper(keyboardKeys) }
    end
end

--- Sets the hold time for the prompt.
--- @param holdTime number|boolean: The duration to hold the key before triggering, or false if not applicable.
--- @return nil
function PromptClass:setHoldTime(holdTime)
    self.holdTime = holdTime or false
end

-- * =============================================================================
-- * GROUP
-- * =============================================================================

local GroupClass = {
    title = "",
    position = "bottom-right",
    prompts = {},
    visible = false,
    nextPageKey = "A",
    currentPage = 1
}

--- Sets the title of the group.
--- @param title string: The title to assign to the group.
--- @return nil
function GroupClass:setTitle(title)
    self.title = title
end

--- Sets the position of the group.
--- @param position string: The desired position (e.g., "bottom-right").
--- @return nil
function GroupClass:setPosition(position)
    self.position = position
end

--- @param key string:
--- @return nil
function GroupClass:setNextPageKey(key)
    self.nextPageKey = string.upper(key)
end

--- Adds a prompt to the group.
-- Creates or reuses the specified page and inserts the new prompt.
--- @param key string|table: The key or keys for the prompt.
--- @param label string: The label describing the prompt.
--- @param holdTime number|boolean: The duration the key must be held.
--- @param page number|nil: The page number to add the prompt to (default is 1).
--- @return nil
function GroupClass:addPrompt(key, label, holdTime, page)
    local prompt = table.copy(PromptClass)
    prompt:setLabel(label)
    prompt:setKeyboardKeys(key)
    prompt:setHoldTime(holdTime)

    page = page or 1

    -- create pages if not exists, or reuse them otherwise
    -- because prompts is a table of tables -> page[prompts[prompt]]
    if not self.prompts[page] then
        for i = 1, page do
            self.prompts[i] = self.prompts[i] or {}
        end
    end

    table.insert(self.prompts[page], prompt)
end

-- Listens for key events on a specified page of the group.
-- Sets up raw key listeners for each key defined in each prompt on that page.
--- @param group table: The group containing the prompts.
--- @param pageNumber number: The page number from which to listen to prompts.
--- @return nil
local function listenPage(group, pageNumber)
    -- Loop over all prompts in the specified page of the group.
    for i = 1, #group.prompts[pageNumber] do
        -- Retrieve the current prompt from the prompts list on the given page.
        local prompt = group.prompts[pageNumber][i]

        -- Loop over each keyboard key defined for the current prompt.
        for j = 1, #prompt.keyboardKeys do
            -- Get the specific key (as a string) from the prompt's keyboardKeys table.
            local key = prompt.keyboardKeys[j]

            -- Set up a listener for the key using jo.rawKeys.listen.
            jo.rawKeys.listen(key, function(isPressed)
                -- Check if the key is being pressed.
                if isPressed then
                    -- When pressed, record the current game time plus any hold time defined for the prompt.
                    -- This value in keysPressed indicates until when the key should be considered active.
                    keysPressed[key] = GetGameTimer() + (prompt.holdTime or 0)
                else
                    -- When the key is released, remove its entry from keysPressed.
                    keysPressed[key] = nil -- delete the key from the active keys table
                    -- Also reset its fired status in keysFired so it can be triggered again later.
                    keysFired[key] = nil
                end

                -- Send a message to the NUI to update the key state.
                -- The message type is "keyDown" if the key is pressed, otherwise "keyUp".
                SendNUIMessage({
                    type = isPressed and "keyDown" or "keyUp",
                    data = {
                        key = key -- Include the key identifier in the data sent.
                    }
                })
            end)
        end
    end
end

function removePage(group, pageNumber)
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

--- Displays the group by sending an NUI update with its title, position, and first page prompts.
-- Also initiates key listeners for the first page.
--- @return nil
function GroupClass:display(page)
    currentGroup = self
    self.currentPage = page or 1
    self.visible = true
    SendNUIMessage({
        type = "updateGroup",
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
                self.currentPage += 1
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

--- Hides the group by clearing its prompts from the NUI.
-- @return nil
function GroupClass:hide()
    currentGroup = nil
    self.visible = false
    SendNUIMessage({
        type = "updateGroup",
        data = {
            prompts = {}
        }
    })
    removePage(self, self.currentPage)
end

-- * =============================================================================
-- * MODULE FUNCTIONS
-- * =============================================================================

--- Creates a new prompt group.
--- @param title string: The title for the new group.
--- @param position string|nil: (Optional) The position for the group.
--- @return GroupClass: A new instance of GroupClass representing the prompt group.
function jo.promptNui.createGroup(title, position)
    local group = table.copy(GroupClass)
    group:setTitle(title)
    if position then group:setPosition(position) end

    return group
end

--- Checks if a specific key has been held long enough to be considered complete.
-- Optionally prevents the key from firing multiple times unless specified.
--- @param key string: The key identifier to check.
--- @param fireMultipleTimes boolean|nil: (Optional) If true, the key can fire multiple times (default is false).
--- @return boolean: True if the key press duration is complete and it hasn't already fired (unless allowed), otherwise false.
function jo.promptNui.isCompleted(key, fireMultipleTimes)
    fireMultipleTimes = fireMultipleTimes or false
    if not keysPressed[key] then return false end

    if GetGameTimer() >= keysPressed[key] then
        if (not fireMultipleTimes and keysFired[key]) then return false end
        keysFired[key] = true
        return true
    end
    return false
end
