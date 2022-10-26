function drawTargets(plane)
    if #plane.targetting.targetVehicles >= 1 then

        -- Draw targets.
        if plane.isArmed then
            for key, vehicle in pairs(plane.targetting.targetVehicles) do
                if vehicle ~= plane.targetting.target and GetVehicleHealth(vehicle) > 0 then
                    drawTarget(plane, vehicle) -- Draw all targets.
                end
            end
        end

        drawTarget(plane, plane.targetting.target) -- Draw selected target on top level of ui

    end
end

--- Change target to a random vehicle in table v.
function changeTarget(plane, v)
    plane.targetting.target = GetRandomIndexValue(v)
    TimerResetTime(plane.targetting.lock.timer)
    plane.targetting.lock.locked = false
    plane.targetting.lock.locking = false
end

--- Draw a single target.
function drawTarget(plane, vehicle)

    do UiPush()

        vehiclePos = AabbGetBodyCenterPos(GetVehicleBody(vehicle))
        local vpx, vpy = UiWorldToPixel(vehiclePos)

        if TransformToLocalPoint(GetCameraTransform(), vehiclePos)[3] < 0 then

            UiTranslate(vpx, vpy)
            UiAlign('center middle')

            UiColor(0.5,1,0.5, 1)
            if vehicle == plane.targetting.target then

                UiPush()
                    UiColor(0.75,0.75,0.75, 1)
                    UiTranslate(-25, 0)
                    UiTextShadow(0,0,0,1,1,0.1)
                    UiAlign('right middle')
                    UiFont('bold.ttf', 21)
                    local distToTarget = VecDist(plane.tr.pos, vehiclePos)/1000
                    UiText(sfn(distToTarget) .. ' KM')
                UiPop()

                local c = Oscillate(0.9)
                if plane.targetting.lock.locked then

                    UiColor(1,0,0, 1)
                    DrawBodyOutline(GetVehicleBody(plane.targetting.target), 1,0,0, 0.5)
                    UiPush()
                        UiTranslate(21, 0)
                        UiTextShadow(0,0,0,1,1,0.1)
                        UiAlign('left middle')
                        UiFont('bold.ttf', 20)
                        UiText('LOCK')
                    UiPop()

                elseif plane.targetting.lock.locking then

                    UiColor(1,0.6,0.1, c)
                    DrawBodyOutline(GetVehicleBody(plane.targetting.target), 1,0.5,0, 0.5)

                else

                    UiColor(1,1,0.5, c)
                    DrawBodyOutline(GetVehicleBody(plane.targetting.target), 1,1,0.5, 0.5)

                end

            end

            UiImageBox('MOD/img/hud/hexagon.png', 40,40, 0,0) -- Draw target at vehicle pos.

        end

    UiPop() end

end


function plane_ManageTargetting(plane)

    if InputPressed(Config.toggleHoming) then
        beep()
        plane.targetting.lock.enabled = not plane.targetting.lock.enabled
    end

    worldVehicles = FindVehicles('', true)
    plane.targetting.targetVehicles = {}
    for key, tv in pairs(worldVehicles) do

        if plane.vehicle ~= tv and GetVehicleHealth(tv) > 0 then
            table.insert(plane.targetting.targetVehicles, tv)
        end

    end

    -- dbw('#targetVehicles', #plane.targetting.targetVehicles)

    if #plane.targetting.targetVehicles >= 1 then

        -- Manually change target.
        if InputPressed(Config.changeTarget) then

            -- Build table of targetable vehicles.
            local planesInfront = {}
            for key, v in ipairs(plane.targetting.targetVehicles) do

                if v ~= plane.vehicle and v ~= plane.targetting.target then

                    local camTr = GetCameraTransform()
                    local vTr = GetVehicleTransform(v)

                    local camRot = camTr.rot
                    local rotToVehicle = QuatLookAt(camTr.pos, vTr.pos)

                    local ang = QuatAngle(camRot, rotToVehicle)
                    if ang < 45 then
                        if ang < 20 then
                            planesInfront = {v} -- Select v looking directly at.
                            break
                        else
                            table.insert(planesInfront, v) -- Select random looking near.
                        end
                    end

                end

            end

            if #planesInfront >= 1 then
                changeTarget(plane, planesInfront)
                -- dbp('Manually changed to forward taget: ' .. plane.targetting.target)
                beep()
            else
                plane.targetting.target = nil
                beep()
            end

        end

        -- Auto change target.
        if plane.targetting.target == nil
        or not IsHandleValid(plane.targetting.target)
        or not IsHandleValid(GetVehicleBody(plane.targetting.target))
        or GetVehicleHealth(plane.targetting.target) <= 0
        then
            changeTarget(plane, plane.targetting.targetVehicles)
        end

    end

end
