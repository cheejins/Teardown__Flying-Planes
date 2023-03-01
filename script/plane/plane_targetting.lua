function plane_ManageTargetting(plane)

    local camTr = GetCameraTransform()

    plane.targetting.targetVehicles = {} -- Reset each tick.

    for key, vehicle in pairs(AllVehicles) do -- All vehicles in scene.
        if vehicle ~= plane.vehicle and GetVehicleHealth(vehicle) > 0 then

            if VehicleIsPlane(vehicle) then -- Alive planes

                if VehicleIsAlivePlane(vehicle) then
                    table.insert(plane.targetting.targetVehicles, vehicle)
                end

            elseif not HasTag(vehicle, "landing_gear") then -- Valid vehicle.

                table.insert(plane.targetting.targetVehicles, vehicle)

            end

        end
    end


    -- dbw('#targetVehicles', #plane.targetting.targetVehicles)

    if #plane.targetting.targetVehicles >= 1 then

        -- Manually change target.
        if InputPressed(Config.changeTarget) then

            -- Build table of targettable vehicles.
            local vehicleInfront = nil

            local minAngle = math.huge

            for key, vehicle in ipairs(plane.targetting.targetVehicles) do
                if vehicle ~= plane.targetting.target then

                    local ang = QuatAngle(camTr.rot, QuatLookAt(camTr.pos, GetVehicleTransform(vehicle).pos))

                    if ang < minAngle then
                        minAngle = ang
                        vehicleInfront = vehicle -- Find vehicle camera is point closest to.
                    end

                end
            end

            if vehicleInfront then
                changeTarget(plane, { vehicleInfront })
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
        or VehicleIsPlane(plane.targetting.target) and not VehicleIsAlivePlane(plane.targetting.target)
        then
            changeTarget(plane, plane.targetting.targetVehicles)
        end

    end

end


--- Change target to a random vehicle in table v.
function changeTarget(plane, v)
    plane.targetting.target = GetRandomIndexValue(v)
    TimerResetTime(plane.targetting.lock.timer)
    plane.targetting.lock.locked = false
    plane.targetting.lock.locking = false
end


function plane_CheckTargetLocked(plane)

    if plane.targetting.lock.enabled and plane.targetting.homingCapable then

        local planeTr = GetVehicleTransform(plane.vehicle)
        local targetTr = GetVehicleTransform(plane.targetting.target)

        local planeRot = QuatCopy(planeTr.rot)
        local targetDir = QuatLookAt(planeTr.pos, targetTr.pos)

        local ang = QuatAngle(planeRot, targetDir)
        if ang < 30 and VecDist(planeTr.pos, targetTr.pos) < 800 then -- Target in bounds.

            if TimerConsumed(plane.targetting.lock.timer) then -- Target locked.

                plane.targetting.lock.locked = true
                plane.targetting.lock.locking = false
                local shapes = GetBodyShapes((GetVehicleBody(plane.targetting.target)))
                plane.targetting.targetShape = shapes[GetRandomIndex(shapes)]

            else

                plane.targetting.lock.locking = true -- Target still locking.
                plane.targetting.targetShape = nil
                TimerRunTime(plane.targetting.lock.timer)

            end

        else

            TimerResetTime(plane.targetting.lock.timer)

            plane.targetting.lock.locking = false
            plane.targetting.lock.locked = false
            plane.targetting.targetShape = nil


        end
        dbw('Target timer', plane.targetting.lock.timer.time)
    else
        plane.targetting.lock.locked = false
        plane.targetting.lock.locking = false
        plane.targetting.targetShape = nil
        TimerResetTime(plane.targetting.lock.timer)
    end

end


function plane_draw_Targetting(plane)
    UiPush()
        if #plane.targetting.targetVehicles >= 1 then

            -- Draw targets.
            for key, vehicle in pairs(plane.targetting.targetVehicles) do
                if vehicle ~= plane.targetting.target then
                    plane_draw_Target(plane, vehicle) -- Draw all targets except selected target.
                end
            end

            plane_draw_Target(plane, plane.targetting.target) -- Draw selected target on top level of ui

        end
    UiPop()
end


--- Draw a single target.
function plane_draw_Target(plane, vehicle)
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

                    UiColor(1,PLANE_DEAD_HEALTH,0.1, c)
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
