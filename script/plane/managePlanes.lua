function initPlanes()

    -- Create objects for each existing plane.
    local planeVehicleList = FindVehicles("planeVehicle", true)
    for key, planeVehicle in pairs(planeVehicleList) do
        local plane = createPlaneObject(planeVehicle)
        plane_update(plane)
        table.insert(planeObjectList, plane)
    end

    dbpc(#planeObjectList .. ' planes initialized. ' .. sfnTime())

end

function planesUpdate()

    for key, plane in pairs(planeObjectList) do
        if GetPlayerVehicle() == plane.vehicle then

            if not ShouldDrawIngameOptions then
                planeCamera(plane)
            end

        end
    end

end

function planesTick()


    for key, plane in pairs(planeObjectList) do

        plane_update(plane)

        if plane.isAlive then

            plane_ProcessHealth(plane)

            if FlightMode == FlightModes.simple then
                -- planeMove_simple(plane)
            elseif FlightMode == FlightModes.simulation then
                planeMove(plane)
            end


            planeSound(plane)

        end

        runEffects(plane)

        if GetPlayerVehicle() == plane.vehicle then

            planeChangeCamera()

            if not ShouldDrawIngameOptions then
                planeCamera(plane)
            end

            if plane.isAlive then

                SetPlayerHealth(1)


                crosshairPos = getCrosshairWorldPos({plane.body}, plane.tr.pos)
                -- dbdd(crosshairPos, 1,1, 1,0,0, 1)

                if InputPressed(Config.toggleHoming) then
                    beep()
                    plane.targetting.lock.enabled = not plane.targetting.lock.enabled
                end

                curPlane = plane
                plane.status = '-'


                if not ShouldDrawIngameOptions then

                    if FlightMode == FlightModes.simple and camPos ~= 'Vehicle' then
                        planeSteer_simple(plane)
                    elseif FlightMode == FlightModes.simulation then
                        planeSteer(plane)
                    end

                end

                if FlightMode == FlightModes.simple then
                    planeMove_simple(plane)
                    plane_applyForces_simple(plane)
                elseif FlightMode == FlightModes.simulation then
                    plane_applyForces(plane)
                    plane_applyTurbulence(plane)
                end


                manageTargetting(plane)

                if not ShouldDrawIngameOptions then
                    planeShoot(plane)
                end

                planeLandingGear(plane)

                if GetBool('savegame.mod.debugMode') then
                    planeDebug(plane)
                end

            end

        end

    end

    -- local vehicle = GetPlayerVehicle()
    -- for key, plane in pairs(planeObjectList) do
    --     if vehicle == plane.vehicle then

    --         if camPos ~= camPositions[2] then
    --             -- AimSteerVehicle(plane.vehicle)
    --         end

    --     end
    -- end

end

function plane_ProcessHealth(plane)

    plane.health = clamp(CompressRange(GetVehicleHealth(plane.vehicle), 0.5, 1), 0, 1)

    if plane.isAlive and plane.health <= 0 and not plane.justDied then

        plane.justDied = true
        plane.isAlive = false
        plane.timeOfDeath = GetTime()

        PlaySound(sounds.engine_deaths[3], plane.tr.pos, 3)
        PlaySound(sounds.engine_deaths[1], plane.tr.pos, 3)
        Explosion(plane.tr.pos, 1)

    else
        plane.isAlive = true
        plane.justDied = false
    end

end
