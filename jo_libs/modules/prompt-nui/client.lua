jo.promptNui = {}
jo.require("table")
jo.require("raw-keys")
-- =============================================================================
-- PROMPT
-- =============================================================================

local PromptClass={
    label="",
    keyboardKeys={},
    holdTime=false,
}

function PromptClass:setLabel(label)
    self.label=label
end

function PromptClass:setKeyboardKeys(keyboardKeys)
    -- ensure that keyboardKeys is always a table of keys
    if type(keyboardKeys)=="table" then
        self.keyboardKeys=keyboardKeys -- todo upper each keys in the table
    else
        self.keyboardKeys={string.upper(keyboardKeys)}
    end
end

function PromptClass:setHoldTime(holdTime)
    self.holdTime=holdTime or false
end


-- =============================================================================
-- GROUP
-- =============================================================================

local GroupClass={
    title="",
    position="bottom-right",
    prompts={},
    visible=false
}

function GroupClass:setTitle(title)
    self.title=title

end

function GroupClass:setPosition(position)
    self.position=position
end


function GroupClass:addPrompt(key,label,holdTime,page)
    local prompt=table.copy(PromptClass);
    prompt:setLabel(label)
    prompt:setKeyboardKeys(key)
    prompt:setHoldTime(holdTime)

    page = page or 1

    -- create pages if not exists, or reuse them otherwise
    -- because prompts is a table of tables -> page[prompts[prompt]]
    if not self.prompts[page] then
        for i = 1, page do
            self.prompts[i]=self.prompts[i] or {}
        end
    end

    table.insert(self.prompts[page],prompt)

end

function GroupClass:display()
    self.visible=true;
    SendNUIMessage({
        type="updateGroup",
        -- data=table.clearForNui(self)
        data={
            title=self.title,
            position=self.position,
            prompts=table.clearForNui(self.prompts[1])
        }
    })

    -- todo loop through each prompt and each keyboardKeys and listen

    -- jo.rawKeys.listen("VK_G", function(isPressed)
    --     print("Key " .. (isPressed and "pressed" or "released"))
    --   end)

end


function GroupClass:hide()
    self.visible=false;
    SendNUIMessage({
        type="updateGroup",
        data={
            prompts={}
        }
    })
end

---@param title string desc
---@return GroupClass GroupClass class
function jo.promptNui.createGroup(title,position)

    local group=table.copy(GroupClass);
    group:setTitle(title);
    if position then group:setPosition(position) end

    return group;
end


-- =============================================================================
-- 
-- =============================================================================

function jo.promptNui.isCompleted(key)

end