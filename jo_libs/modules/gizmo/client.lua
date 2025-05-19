jo.gizmo = {}

jo.require("nui")
jo.require("prompt")

CreateThread(function()
    Wait(100)
    if GetResourceMetadata(GetCurrentResourceName(), "ui_page") == "nui://jo_libs/nui/gizmo/index.html" then
        return
    end
    jo.nui.load("jo_gizmo", "nui://jo_libs/nui/gizmo/index.html")
end)
local NativeSendNUIMessage = SendNUIMessage
local function SendNUIMessage(data)
    if clockStart == GetGameTimer() then Wait(100) end
    data.messageTargetUiName = "jo_gizmo"
    NativeSendNUIMessage(data)
end

-- =============================================================================
--
-- =============================================================================

local config = {
    enableCam = GetConvarBool("jo_libs:gizmo:enableCam", true),                                           -- Enable/Disable camera feature
    maxDistance = GetConvarInt("jo_libs:gizmo:maxDistance", 100),                                         -- Maximum distance entity can be moved from starting position (set to false to disable)
    maxCamDistance = GetConvarInt("jo_libs:gizmo:maxCamDistance", 80),                                    -- Maximum distance camera can be moved from player
    minY = GetConvarInt("jo_libs:gizmo:minY", -40),                                                       -- Minimum Y value for camera rotation
    maxY = GetConvarInt("jo_libs:gizmo:maxY", 40),                                                        -- Maximum Y value for camera rotation
    movementSpeed = GetConvarFloat("jo_libs:gizmo:movementSpeed", 0.1),                                   -- Default movement speed for camera
    maxMovementSpeed = GetConvarFloat("jo_libs:gizmo:maxMovementSpeed", 0.2),                             -- Maximum movement speed for camera
    minMovementSpeed = GetConvarFloat("jo_libs:gizmo:minMovementSpeed", 0.001),                           -- Minimum movement speed for camera
    movementSpeedIncrement = GetConvarFloat("jo_libs:gizmo:movementSpeedIncrement", 0.01),                -- Increment value when adjusting camera speed
    keys = {
        moveX = GetConvarInt("jo_libs:gizmo:keys:moveX", `INPUT_SCRIPTED_FLY_LR`),                        -- Move left/right
        moveY = GetConvarInt("jo_libs:gizmo:keys:moveY", `INPUT_SCRIPTED_FLY_UD`),                        -- Move forward/backward
        moveUp = GetConvarInt("jo_libs:gizmo:keys:moveUp", `INPUT_FRONTEND_X`),                           -- Move up
        moveDown = GetConvarInt("jo_libs:gizmo:keys:moveDown", `INPUT_FRONTEND_RUP`),                     -- Move down
        cancel = GetConvarInt("jo_libs:gizmo:keys:cancel", `INPUT_GAME_MENU_TAB_RIGHT_SECONDARY`),        -- Cancel operation
        switchMode = GetConvarInt("jo_libs:gizmo:keys:switchMode", `INPUT_RELOAD`),                       -- Switch between translate/rotate modes
        snapToGround = GetConvarInt("jo_libs:gizmo:keys:snapToGround", `INPUT_INTERACT_OPTION1`),         -- Snap entity to ground
        confirm = GetConvarInt("jo_libs:gizmo:keys:confirm", `INPUT_FRONTEND_ACCEPT`),                    -- Confirm placement
        focusEntity = GetConvarInt("jo_libs:gizmo:keys:focusEntity", `INPUT_SHOP_SPECIAL`),               -- Toggle focus on entity
        cameraSpeedUp = GetConvarInt("jo_libs:gizmo:keys:cameraSpeedUp", `INPUT_SELECT_PREV_WEAPON`),     -- Increase camera speed
        cameraSpeedDown = GetConvarInt("jo_libs:gizmo:keys:cameraSpeedDown", `INPUT_SELECT_NEXT_WEAPON`), -- Decrease camera speed
    }
}

-- =============================================================================
--
-- =============================================================================


local gizmoActive = false
local responseData = nil
local mode = "translate"
local cam = nil
local enableCam = false
local maxDistance = 0
local maxCamDistance = 0
local minY = 0
local maxY = 0
local focusEntity = true
local movementSpeed = 0
local stored = nil
local hookedFunc = nil
local target = 0
local needUpdateCamNUI = false
local groupName = "interaction_GizmoPrompts"

local function pointEntity()
    PointCamAtEntity(cam, target)
    needUpdateCamNUI = true
end

-- Initializes UI focus, camera, and other misc
-- @param bool boolean
local function showNUI(bool)
    if bool then
        SetNuiFocus(true, true)
        SetNuiFocusKeepInput(true)

        if enableCam then
            local coords = GetGameplayCamCoord()
            local rot = GetGameplayCamRot(2)
            local fov = GetGameplayCamFov()

            cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

            SetCamCoord(cam, coords.x, coords.y, coords.z + 0.5)
            SetCamFov(cam, fov)
            RenderScriptCams(true, true, 500, true, true)
            FreezeEntityPosition(PlayerPedId(), true)
            if focusEntity then
                pointEntity()
            end
            needUpdateCamNUI = true
        end

        SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"), true)
    else
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(IsNuiFocusKeepingInput())
        FreezeEntityPosition(PlayerPedId(), false)

        if cam then
            RenderScriptCams(false, true, 500, true, true)
            SetCamActive(cam, false)
            DetachCam(cam)
            DestroyCam(cam, true)
            cam = nil
        end

        stored = nil
        hookedFunc = nil

        SendNUIMessage({
            action = "SetupGizmo",
            data = {
                handle = nil,
            }
        })
    end

    gizmoActive = bool
end

-- Disables controls, Radar, and Player Firing
local function disableControls()
    DisableControlAction(0, `INPUT_ATTACK`, true)
end

-- Get the normal value of a control(s) used for movement & rotation
-- @param control number | table
-- @return number
local function getSmartControlNormal(control, control2)
    if control2 then
        local normal1 = GetDisabledControlNormal(0, control)
        local normal2 = GetDisabledControlNormal(0, control2)
        return normal1 - normal2
    end

    return GetDisabledControlNormal(0, control)
end

-- Handle camera rotations
local function rotations()
    if focusEntity then return end
    local newX
    local rAxisX = GetControlNormal(0, `INPUT_LOOK_LR`)
    local rAxisY = GetControlNormal(0, `INPUT_LOOK_UD`)

    if rAxisX == 0 and rAxisY == 0 then return end

    local rot = GetCamRot(cam, 2)

    local yValue = rAxisY * 5
    local newZ = rot.z + (rAxisX * -10)
    local newXval = rot.x - yValue

    if (newXval >= minY) and (newXval <= maxY) then
        newX = newXval
    end

    if newX and newZ then
        SetCamRot(cam, vector3(newX, rot.y, newZ), 2)
        needUpdateCamNUI = true
    end
end

-- Handle camera movement
local function movement()
    local moveX = getSmartControlNormal(config.keys.moveX)                        -- Left & Right
    local moveY = getSmartControlNormal(config.keys.moveY)                        -- Forward & Backward
    local moveZ = getSmartControlNormal(config.keys.moveUp, config.keys.moveDown) -- Up & Down

    if moveX == 0 and moveY == 0 and moveZ == 0 then
        return
    end

    local x, y, z = table.unpack(GetCamCoord(cam))
    local rot = GetCamRot(cam, 2)

    local dx = math.sin(-rot.z * math.pi / 180) * movementSpeed
    local dy = math.cos(-rot.z * math.pi / 180) * movementSpeed

    local dx2 = math.sin(math.floor(rot.z + 90.0) % 360 * -1.0 * math.pi / 180) * movementSpeed
    local dy2 = math.cos(math.floor(rot.z + 90.0) % 360 * -1.0 * math.pi / 180) * movementSpeed

    if moveX ~= 0.0 then
        x -= dx2 * moveX
        y -= dy2 * moveX
    end

    if moveY ~= 0.0 then
        x -= dx * moveY
        y -= dy * moveY
    end

    if moveZ ~= 0.0 then
        z += moveZ * movementSpeed
    end

    if #(GetEntityCoords(PlayerPedId()) - vec3(x, y, z)) <= maxCamDistance and (not hookedFunc or hookedFunc(vec3(x, y, z))) then
        SetCamCoord(cam, x, y, z)
        needUpdateCamNUI = true
    end
end

-- Handle camera controls (movement & rotation)
local function camControls()
    rotations()
    movement()
end

local function updateCamNUI()
    if not needUpdateCamNUI then return end
    if getSmartControlNormal(`INPUT_ATTACK`) > 0 then return end


    SendNUIMessage({
        action = "SetCameraPosition",
        data = {
            position = GetFinalRenderedCamCoord(),
            rotation = GetFinalRenderedCamRot(0)
        }
    })
    needUpdateCamNUI = false
end

local function refreshSpeedPrompt()
    jo.prompt.editKeyLabel(groupName, config.keys.cameraSpeedUp, ("Camera speed: x%.3f"):format(movementSpeed))
end

--- Setup a gizmo interface to move an entity in 3D space
--- Allows for precise positioning and rotation of entities through a visual interface
--- Uses a camera system for better manipulation when enabled
---@param entity integer (The entity to move)
---@param cfg? table (Configuration options to override [defaults](#default-configuration))
--- cfg.enableCam boolean (Enable/disable camera feature - default based on config)
--- cfg.maxDistance number (Max distance the entity can be moved from starting position - default based on config)
--- cfg.maxCamDistance number (Max distance the camera can be moved from player - default based on config)
--- cfg.minY number (Min Y value from starting position for camera - default based on config)
--- cfg.maxY number (Max Y value from starting position for camera - default based on config)
--- cfg.movementSpeed number (Movement speed for camera - default based on config)
---@param allowPlace? function (Optional callback to validate placement - receives proposed position as parameter)
---@return table|nil (Returns entity position and rotation data when completed, nil if already active)
function jo.gizmo.moveEntity(entity, cfg, allowPlace)
    if gizmoActive then return eprint("Gizmo is already started") end
    if not entity then return end

    if gizmoActive then
        showNUI(false)
    end

    target = entity

    enableCam = cfg?.enableCam == nil and config.enableCam or cfg.enableCam
    maxDistance = cfg?.maxDistance == nil and config.maxDistance or cfg.maxDistance
    maxCamDistance = cfg?.maxCamDistance == nil and config.maxCamDistance or cfg.maxCamDistance
    minY = cfg?.minY == nil and config.minY or cfg.minY
    maxY = cfg?.maxY == nil and config.maxY or cfg.maxY
    movementSpeed = cfg?.movementSpeed == nil and config.movementSpeed or cfg.movementSpeed
    mode = "translate"


    stored = {
        coords = GetEntityCoords(entity),
        rotation = GetEntityRotation(entity)
    }

    hookedFunc = allowPlace

    responseData = {}
    showNUI(true)
    DisplayHud(false)

    Wait(500)

    SendNUIMessage({
        action = "SetupGizmo",
        data = {
            handle = entity,
            position = stored.coords,
            rotation = stored.rotation,
            gizmoMode = mode
        }
    })

    CreateThread(function()
        while gizmoActive do
            disableControls()
            if cam then
                camControls()
            end
            updateCamNUI()
            Wait(0)
        end
    end)


    jo.prompt.create(groupName, "Cancel", config.keys.cancel)
    jo.prompt.create(groupName, "Confirm", config.keys.confirm)
    jo.prompt.create(groupName, "Switch to Rotate Mode", config.keys.switchMode)
    jo.prompt.create(groupName, "Snap to Ground", config.keys.snapToGround)
    jo.prompt.create(groupName, "Finish", config.keys.enter)
    jo.prompt.create(groupName, "Free cam", config.keys.focusEntity)
    jo.prompt.create(groupName, ("Camera speed: x%.3f"):format(movementSpeed),
        { config.keys.cameraSpeedUp, config.keys.cameraSpeedDown })

    if (cam) then
        jo.prompt.create(groupName, "Move L/R", config.keys.moveX)
        jo.prompt.create(groupName, "Move F/B", config.keys.moveY)
        jo.prompt.create(groupName, "Move Up", config.keys.moveDown)
        jo.prompt.create(groupName, "Move Down", config.keys.moveUp)
    end


    while gizmoActive do
        if jo.prompt.isCompleted(groupName, config.keys.switchMode) then
            mode = (mode == "translate" and "rotate" or "translate")
            SendNUIMessage({
                action = "SetGizmoMode",
                data = mode
            })
            jo.prompt.editKeyLabel(groupName, config.keys.switchMode,
                mode == "translate" and "Switch to Rotate mode" or "Switch to Translate mode")
        end

        if jo.prompt.isCompleted(groupName, config.keys.snapToGround) then
            PlaceObjectOnGroundProperly(entity)
            SendNUIMessage({
                action = "SetupGizmo",
                data = {
                    handle = entity,
                    position = GetEntityCoords(entity),
                    rotation = GetEntityRotation(entity)
                }
            })
        end

        if jo.prompt.isCompleted(groupName, config.keys.cameraSpeedUp) then
            movementSpeed = math.min(config.maxMovementSpeed, movementSpeed + config.movementSpeedIncrement)
            refreshSpeedPrompt()
        end

        if jo.prompt.isCompleted(groupName, config.keys.cameraSpeedDown) then
            movementSpeed = math.max(config.minMovementSpeed, movementSpeed - config.movementSpeedIncrement)
            refreshSpeedPrompt()
        end

        if jo.prompt.isCompleted(groupName, config.keys.focusEntity) then
            focusEntity = not focusEntity
            jo.prompt.editKeyLabel(groupName, config.keys.focusEntity, focusEntity and "Free cam" or "Focus entity")
            if focusEntity then
                pointEntity()
            else
                StopCamPointing(cam)
            end
            Wait(10) --fix the refresh of the gizmo
            needUpdateCamNUI = true
        end

        if jo.prompt.isCompleted(groupName, config.keys.confirm) then
            local coords = GetEntityCoords(entity)
            responseData = {
                entity = entity,
                coords = coords,
                position = coords, -- Alias
                rotation = GetEntityRotation(entity)
            }

            showNUI(false)
            break
        end

        if jo.prompt.isCompleted(groupName, config.keys.cancel) then
            responseData = {
                canceled = true,
                entity = entity,
                coords = stored.coords,
                position = stored.coords, -- Alias
                rotation = stored.rotation
            }

            SetEntityCoordsNoOffset(entity, stored.coords.x, stored.coords.y, stored.coords.z)
            SetEntityRotation(entity, stored.rotation.x, stored.rotation.y, stored.rotation.z)

            showNUI(false)
            break
        end

        Wait(10)
    end
    jo.prompt.deleteGroup(groupName)
    DisplayHud(true)

    return responseData
end

--- Cancels the currently active gizmo interface
function jo.gizmo.cancel()
    showNUI(false)
end

-- Register NUI Callback for updating entity position and rotation
-- @param data table
-- @param cb function
RegisterNUICallback("gizmo:UpdateEntity", function(data, cb)
    local entity = data.handle
    local position = data.position
    local rotation = data.rotation

    if (maxDistance and #(vec3(position.x, position.y, position.z) - stored.coords) <= maxDistance) and (not hookedFunc or hookedFunc(position)) then
        SetEntityCoordsNoOffset(entity, position.x, position.y, position.z)
        SetEntityRotation(entity, rotation.x, rotation.y, rotation.z)
        needUpdateCamNUI = true
        return cb({ status = "ok" })
    end

    position = GetEntityCoords(entity)
    rotation = GetEntityRotation(entity)

    cb({
        status = "Distance is too far",
        position = { x = position.x, y = position.y, z = position.z },
        rotation = { x = rotation.x, y = rotation.y, z = rotation.z }
    })
end)

--- If DevMode is enabled, register a command to spawn a crate for testing
if jo.debug then
    local tempEntity = nil
    RegisterCommand("gizmo", function()
        RequestModel("p_crate14x")

        while not HasModelLoaded("p_crate14x") do
            Wait(100)
        end

        local ped = PlayerPedId()
        local offset = GetOffsetFromEntityInWorldCoords(ped, 0., 3., 0.)
        tempEntity = CreateObject(joaat("p_crate14x"), offset.x, offset.y, offset.z, true, true, true)

        while not DoesEntityExist(tempEntity) do
            Wait(100)
        end

        local data = jo.gizmo.moveEntity(tempEntity, {
            enableCam = true
        })

        print(json.encode(data, { indent = true }))

        if tempEntity then
            DeleteEntity(tempEntity)
            tempEntity = nil
        end
    end)

    jo.stopped(function()
        if tempEntity then
            DeleteEntity(tempEntity)
            tempEntity = nil
        end
    end)
end

jo.stopped(function()
    if gizmoActive then
        showNUI(false)
    end
end)
