jo.gizmo = {}

jo.require("nui")
jo.require("prompt")

CreateThread(function()
    dprint("[GIZMO DEBUG] NUI loading thread started at:", GetGameTimer())
    Wait(100)
    local uiPage = GetResourceMetadata(GetCurrentResourceName(), "ui_page")
    dprint("[GIZMO DEBUG] Resource UI page:", uiPage)
    if uiPage == "nui://jo_libs/nui/gizmo/index.html" then
        dprint("[GIZMO DEBUG] UI page already set, skipping load")
        return
    end
    dprint("[GIZMO DEBUG] Loading NUI: jo_gizmo at nui://jo_libs/nui/gizmo/index.html")
    jo.nui.load("jo_gizmo", "nui://jo_libs/nui/gizmo/index.html")
    dprint("[GIZMO DEBUG] NUI load command completed")
end)
local NativeSendNUIMessage = SendNUIMessage
local clockStart = nil
local function SendNUIMessage(data)
    local currentTime = GetGameTimer()
    dprint("[GIZMO DEBUG] SendNUIMessage called at:", currentTime)
    dprint("[GIZMO DEBUG] clockStart:", clockStart or "undefined", "currentTime:", currentTime)
    if clockStart == GetGameTimer() then
        dprint("[GIZMO DEBUG] clockStart equals current time, waiting 100ms")
        Wait(100)
    end
    data.messageTargetUiName = "jo_gizmo"
    dprint("[GIZMO DEBUG] Sending NUI message:", json.encode(data))
    NativeSendNUIMessage(data)
    dprint("[GIZMO DEBUG] NUI message sent successfully")
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
    allowTranslateX = GetConvarBool("jo_libs:gizmo:allowTranslateX", true),                               -- Allow translation on X-axis
    allowTranslateY = GetConvarBool("jo_libs:gizmo:allowTranslateY", true),                               -- Allow translation on Y-axis
    allowTranslateZ = GetConvarBool("jo_libs:gizmo:allowTranslateZ", true),                               -- Allow translation on Z-axis
    allowRotateX = GetConvarBool("jo_libs:gizmo:allowRotateX", true),                                     -- Allow rotation on X-axis
    allowRotateY = GetConvarBool("jo_libs:gizmo:allowRotateY", true),                                     -- Allow rotation on Y-axis
    allowRotateZ = GetConvarBool("jo_libs:gizmo:allowRotateZ", true),                                     -- Allow rotation on Z-axis
    rotationSnap = GetConvarInt("jo_libs:gizmo:rotationSnap", 5),                                         -- Rotation snap value
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
        rotationSnap = GetConvarInt("jo_libs:gizmo:keys:rotationSnap", `INPUT_FRONTEND_Y`),               -- Rotation snap key
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
local allowTranslateX = true
local allowTranslateY = true
local allowTranslateZ = true
local allowRotateX = true
local allowRotateY = true
local allowRotateZ = true
local stored = nil
local hookedFunc = nil
local target = 0
local needUpdateCamNUI = false
local onMove = nil
local groupName = "interaction_GizmoPrompts"
local rotationSnap = nil

local function pointEntity()
    PointCamAtEntity(cam, target)
    needUpdateCamNUI = true
end

-- Initializes UI focus, camera, and other misc
-- @param bool boolean
local function showNUI(bool)
    dprint("[GIZMO DEBUG] showNUI called with bool:", bool, "at", GetGameTimer())
    if bool then
        dprint("[GIZMO DEBUG] Setting NUI focus to true")
        SetNuiFocus(true, true)
        dprint("[GIZMO DEBUG] NUI focus set, checking IsNuiFocused:", IsNuiFocused())
        SetNuiFocusKeepInput(true)
        dprint("[GIZMO DEBUG] NUI focus keep input set, IsNuiFocusKeepingInput:", IsNuiFocusKeepingInput())

        if enableCam then
            dprint("[GIZMO DEBUG] Setting up camera, enableCam:", enableCam)
            local coords = GetGameplayCamCoord()
            local rot = GetGameplayCamRot(2)
            local fov = GetGameplayCamFov()
            dprint("[GIZMO DEBUG] Camera coords:", coords.x, coords.y, coords.z)
            dprint("[GIZMO DEBUG] Camera rotation:", rot.x, rot.y, rot.z)
            dprint("[GIZMO DEBUG] Camera FOV:", fov)

            cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
            dprint("[GIZMO DEBUG] Camera created, cam handle:", cam)

            SetCamCoord(cam, coords.x, coords.y, coords.z + 0.5)
            SetCamFov(cam, fov)
            RenderScriptCams(true, true, 500, true, true)
            FreezeEntityPosition(PlayerPedId(), true)
            dprint("[GIZMO DEBUG] Camera setup complete, focusEntity:", focusEntity)
            if focusEntity then
                pointEntity()
            end
            needUpdateCamNUI = true
        else
            dprint("[GIZMO DEBUG] Camera disabled, enableCam:", enableCam)
        end

        SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"), true)
        dprint("[GIZMO DEBUG] NUI setup complete, weapon set to unarmed")
    else
        dprint("[GIZMO DEBUG] Disabling NUI, setting focus to false")
        SetNuiFocus(false, false)
        dprint("[GIZMO DEBUG] NUI focus disabled, IsNuiFocused:", IsNuiFocused())
        SetNuiFocusKeepInput(IsNuiFocusKeepingInput())
        dprint("[GIZMO DEBUG] NUI focus keep input reset")
        FreezeEntityPosition(PlayerPedId(), false)
        dprint("[GIZMO DEBUG] Player unfrozen")

        if cam then
            dprint("[GIZMO DEBUG] Cleaning up camera, cam handle:", cam)
            RenderScriptCams(false, true, 500, true, true)
            SetCamActive(cam, false)
            DetachCam(cam)
            DestroyCam(cam, true)
            cam = nil
            dprint("[GIZMO DEBUG] Camera destroyed and reset")
        else
            dprint("[GIZMO DEBUG] No camera to clean up")
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
    dprint("[GIZMO DEBUG] showNUI complete, gizmoActive:", gizmoActive)
end

-- Disables controls, Radar, and Player Firing
local function disableControls()
    -- dprint("[GIZMO DEBUG] disableControls: Disabling INPUT_ATTACK")
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
    if focusEntity then
        -- dprint("[GIZMO DEBUG] rotations: Skipping rotation, focusEntity is true")
        return
    end
    local newX
    local rAxisX = GetControlNormal(0, `INPUT_LOOK_LR`)
    local rAxisY = GetControlNormal(0, `INPUT_LOOK_UD`)

    if rAxisX ~= 0 or rAxisY ~= 0 then
        dprint("[GIZMO DEBUG] rotations: Mouse movement detected - X:", rAxisX, "Y:", rAxisY)
    end

    if rAxisX == 0 and rAxisY == 0 then
        -- dprint("[GIZMO DEBUG] rotations: No rotation input, returning")
        return
    end

    local rot = GetCamRot(cam, 2)

    local yValue = rAxisY * 5
    local newZ = rot.z + (rAxisX * -10)
    local newXval = rot.x - yValue

    if (newXval >= minY) and (newXval <= maxY) then
        newX = newXval
    end

    if newX and newZ then
        dprint("[GIZMO DEBUG] rotations: Setting camera rotation to:", newX, rot.y, newZ)
        SetCamRot(cam, vector3(newX, rot.y, newZ), 2)
        needUpdateCamNUI = true
    else
        dprint("[GIZMO DEBUG] rotations: Rotation blocked - newX:", newX, "newZ:", newZ)
    end
end

-- Handle camera movement
local function movement()
    local moveX = getSmartControlNormal(config.keys.moveX)                        -- Left & Right
    local moveY = getSmartControlNormal(config.keys.moveY)                        -- Forward & Backward
    local moveZ = getSmartControlNormal(config.keys.moveUp, config.keys.moveDown) -- Up & Down

    if moveX ~= 0 or moveY ~= 0 or moveZ ~= 0 then
        dprint("[GIZMO DEBUG] movement: Movement input detected - X:", moveX, "Y:", moveY, "Z:", moveZ)
    end

    if moveX == 0 and moveY == 0 and moveZ == 0 then
        -- dprint("[GIZMO DEBUG] movement: No movement input, returning")
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

    local newPos = vec3(x, y, z)
    local playerPos = GetEntityCoords(PlayerPedId())
    local distance = #(playerPos - newPos)

    if distance <= maxCamDistance and (not hookedFunc or hookedFunc(newPos)) then
        dprint("[GIZMO DEBUG] movement: Moving camera to:", x, y, z, "Distance from player:", distance)
        SetCamCoord(cam, x, y, z)
        needUpdateCamNUI = true
    else
        dprint("[GIZMO DEBUG] movement: Camera movement blocked - Distance:", distance, "Max:", maxCamDistance, "HookFunc passed:", not hookedFunc or hookedFunc(newPos))
    end
end

-- Handle camera controls (movement & rotation)
local function camControls()
    rotations()
    movement()
end

local function updateCamNUI()
    if not needUpdateCamNUI then
        -- dprint("[GIZMO DEBUG] updateCamNUI: needUpdateCamNUI is false, skipping")
        return
    end
    if getSmartControlNormal(`INPUT_ATTACK`) > 0 then
        dprint("[GIZMO DEBUG] updateCamNUI: INPUT_ATTACK pressed, skipping camera update")
        return
    end

    local camPos = GetFinalRenderedCamCoord()
    local camRot = GetFinalRenderedCamRot(0)
    dprint("[GIZMO DEBUG] updateCamNUI: Updating camera position - Pos:", camPos.x, camPos.y, camPos.z, "Rot:", camRot.x, camRot.y, camRot.z)

    SendNUIMessage({
        action = "SetCameraPosition",
        data = {
            position = camPos,
            rotation = camRot
        }
    })
    needUpdateCamNUI = false
    dprint("[GIZMO DEBUG] updateCamNUI: Camera position message sent")
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
--- cfg.allowTranslateX boolean (Allow translation on X-axis - default `true`)
--- cfg.allowTranslateY boolean (Allow translation on Y-axis - default `true`)
--- cfg.allowTranslateZ boolean (Allow translation on Z-axis - default `true`)
--- cfg.allowRotateX boolean (Allow rotation on X-axis - default `true`)
--- cfg.allowRotateY boolean (Allow rotation on Y-axis - default `true`)
--- cfg.allowRotateZ boolean (Allow rotation on Z-axis - default `true`)
--- cfg.rotationSnap number (Rotation snap value - default `5`)
--- cfg.onMove function (Optional function fired when the entity move with the gizmo)
---@param allowPlace? function (Optional callback to validate placement - receives proposed position as parameter)
---@return table|nil (Returns entity position and rotation data when completed, nil if already active)
function jo.gizmo.moveEntity(entity, cfg, allowPlace)
    dprint("[GIZMO DEBUG] *** jo.gizmo.moveEntity called at:", GetGameTimer(), "***")
    dprint("[GIZMO DEBUG] Current gizmoActive state:", gizmoActive)

    if gizmoActive then return edprint("Gizmo is already started") end
    if not entity then
        dprint("[GIZMO DEBUG] ERROR: No entity provided")
        return
    end

    if gizmoActive then
        dprint("[GIZMO DEBUG] WARNING: gizmoActive was true, showing NUI false")
        showNUI(false)
    end

    target = entity
    dprint("[GIZMO DEBUG] Target entity set to:", target)

    enableCam = cfg?.enableCam == nil and config.enableCam or cfg.enableCam
    maxDistance = cfg?.maxDistance == nil and config.maxDistance or cfg.maxDistance
    maxCamDistance = cfg?.maxCamDistance == nil and config.maxCamDistance or cfg.maxCamDistance
    minY = cfg?.minY == nil and config.minY or cfg.minY
    maxY = cfg?.maxY == nil and config.maxY or cfg.maxY
    movementSpeed = cfg?.movementSpeed == nil and config.movementSpeed or cfg.movementSpeed
    allowTranslateX = cfg?.allowTranslateX == nil and config.allowTranslateX or cfg.allowTranslateX
    allowTranslateY = cfg?.allowTranslateY == nil and config.allowTranslateY or cfg.allowTranslateY
    allowTranslateZ = cfg?.allowTranslateZ == nil and config.allowTranslateZ or cfg.allowTranslateZ
    allowRotateX = cfg?.allowRotateX == nil and config.allowRotateX or cfg.allowRotateX
    allowRotateY = cfg?.allowRotateY == nil and config.allowRotateY or cfg.allowRotateY
    allowRotateZ = cfg?.allowRotateZ == nil and config.allowRotateZ or cfg.allowRotateZ
    rotationSnap = (cfg?.rotationSnap == nil and config.rotationSnap or cfg.rotationSnap) * math.pi / 180
    mode = "translate"
    onMove = cfg?.onMove

    stored = {
        coords = GetEntityCoords(entity),
        rotation = GetEntityRotation(entity)
    }

    hookedFunc = allowPlace

    responseData = {}
    showNUI(true)
    DisplayHud(false)
    dprint("[GIZMO DEBUG] HUD disabled, waiting 500ms before sending initial message")

    Wait(500)
    dprint("[GIZMO DEBUG] Wait complete, current time:", GetGameTimer())

    dprint("[GIZMO DEBUG] About to send initial SetupGizmo message")
    dprint("[GIZMO DEBUG] Entity handle:", entity)
    dprint("[GIZMO DEBUG] Stored position:", json.encode(stored.coords))
    dprint("[GIZMO DEBUG] Stored rotation:", json.encode(stored.rotation))
    dprint("[GIZMO DEBUG] Initial gizmo mode:", mode)

    SendNUIMessage({
        action = "SetupGizmo",
        data = {
            handle = entity,
            position = stored.coords,
            rotation = stored.rotation,
            gizmoMode = mode,
            allowTranslateX = allowTranslateX,
            allowTranslateY = allowTranslateY,
            allowTranslateZ = allowTranslateZ,
            allowRotateX = allowRotateX,
            allowRotateY = allowRotateY,
            allowRotateZ = allowRotateZ,
            rotationSnap = rotationSnap
        }
    })

    dprint("[GIZMO DEBUG] Initial SetupGizmo message sent")

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
    jo.prompt.create(groupName, "Rotation snap", config.keys.rotationSnap)
    jo.prompt.setVisible(groupName, config.keys.rotationSnap, false)
    if (cam) then
        jo.prompt.create(groupName, "Move L/R", config.keys.moveX)
        jo.prompt.create(groupName, "Move F/B", config.keys.moveY)
        jo.prompt.create(groupName, "Move Up", config.keys.moveDown)
        jo.prompt.create(groupName, "Move Down", config.keys.moveUp)
    end

    dprint("[GIZMO DEBUG] Entering main prompt handling loop")
    local loopCount = 0
    while gizmoActive do
        loopCount = loopCount + 1
        if loopCount % 1000 == 0 then -- Every 1000 iterations (~10 seconds)
            dprint("[GIZMO DEBUG] Main loop iteration:", loopCount, "gizmoActive:", gizmoActive)
        end

        if jo.prompt.isCompleted(groupName, config.keys.switchMode) then
            local oldMode = mode
            mode = (mode == "translate" and "rotate" or "translate")
            dprint("[GIZMO DEBUG] Switching gizmo mode from", oldMode, "to", mode)
            SendNUIMessage({
                action = "SetGizmoMode",
                data = mode
            })
            jo.prompt.editKeyLabel(groupName, config.keys.switchMode,
                mode == "translate" and "Switch to Rotate mode" or "Switch to Translate mode")
            dprint("[GIZMO DEBUG] Gizmo mode switch complete")
            jo.prompt.setVisible(groupName, config.keys.rotationSnap, mode == "rotate")
        end

        if jo.prompt.isCompleted(groupName, config.keys.snapToGround) then
            dprint("[GIZMO DEBUG] Snapping entity to ground")
            PlaceObjectOnGroundProperly(entity)
            local newPos = GetEntityCoords(entity)
            local newRot = GetEntityRotation(entity)
            dprint("[GIZMO DEBUG] Entity snapped - New pos:", json.encode(newPos), "New rot:", json.encode(newRot))
            SendNUIMessage({
                action = "SetupGizmo",
                data = {
                    handle = entity,
                    position = newPos,
                    rotation = newRot,
                    gizmoMode = mode,
                    allowTranslateX = allowTranslateX,
                    allowTranslateY = allowTranslateY,
                    allowTranslateZ = allowTranslateZ,
                    allowRotateX = allowRotateX,
                    allowRotateY = allowRotateY,
                    allowRotateZ = allowRotateZ,
                    rotationSnap = rotationSnap
                }
            })
            dprint("[GIZMO DEBUG] Snap to ground message sent")
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

        if jo.prompt.isCompleted(groupName, config.keys.rotationSnap) then
            SendNUIMessage({
                action = "EnableRotationSnap",
                data = true
            })
            while jo.prompt.isCompleted(groupName, config.keys.rotationSnap, true) do
                Wait(0)
            end
            SendNUIMessage({
                action = "EnableRotationSnap",
                data = false
            })
        end

        Wait(10)
    end

    dprint("[GIZMO DEBUG] Exited main loop, cleaning up prompts")
    jo.prompt.deleteGroup(groupName)
    DisplayHud(true)
    dprint("[GIZMO DEBUG] Cleanup complete, returning response data:", json.encode(responseData))

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
    dprint("[GIZMO DEBUG] *** NUI CALLBACK RECEIVED *** at", GetGameTimer())
    dprint("[GIZMO DEBUG] Callback data received:", json.encode(data))

    local entity = data.handle
    local position = data.position
    local rotation = data.rotation

    dprint("[GIZMO DEBUG] Entity handle:", entity)
    dprint("[GIZMO DEBUG] Position:", position and json.encode(position) or "nil")
    dprint("[GIZMO DEBUG] Rotation:", rotation and json.encode(rotation) or "nil")
    dprint("[GIZMO DEBUG] Stored coords:", stored and json.encode(stored.coords) or "nil")
    dprint("[GIZMO DEBUG] MaxDistance:", maxDistance)
    dprint("[GIZMO DEBUG] HookedFunc exists:", hookedFunc ~= nil)

    if (maxDistance and #(vec3(position.x, position.y, position.z) - stored.coords) <= maxDistance) and (not hookedFunc or hookedFunc(position)) then
        dprint("[GIZMO DEBUG] Position validation passed, updating entity")
        SetEntityCoordsNoOffset(entity, position.x, position.y, position.z)
        SetEntityRotation(entity, rotation.x, rotation.y, rotation.z)
        needUpdateCamNUI = true
        dprint("[GIZMO DEBUG] Entity updated successfully")
        if onMove then
            onMove(position, rotation)
        end
        return cb({ status = "ok" })
    end

    dprint("[GIZMO DEBUG] Position validation failed, reverting to entity position")
    position = GetEntityCoords(entity)
    rotation = GetEntityRotation(entity)

    local response = {
        status = "Distance is too far",
        position = { x = position.x, y = position.y, z = position.z },
        rotation = { x = rotation.x, y = rotation.y, z = rotation.z }
    }
    dprint("[GIZMO DEBUG] Sending error response:", json.encode(response))
    cb(response)
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

        dprint(json.encode(data, { indent = true }))

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
