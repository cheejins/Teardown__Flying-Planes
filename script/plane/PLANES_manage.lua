-- Run tick() functions for each plane.
function PLANES_Tick()
    for key, plane in pairs(planeObjectList) do

        DebugWatch(plane.id, plane.isAlive)

        plane_update(plane)

        if plane.isAlive then

            plane_ProcessHealth(plane)


            if FlightMode == FlightModes.simulation then
                plane_Move(plane)
            end

            plane_Sound(plane)

        end

        plane_VisualEffects(plane)


        if GetPlayerVehicle() == plane.vehicle then

            plane_ChangeCamera()

            if not ShouldDrawIngameOptions then
                plane_Camera(plane)
            end

            if plane.isAlive then

                SetPlayerHealth(1)


                crosshairPos = getCrosshairWorldPos({plane.body}, plane.tr.pos)
                -- dbdd(crosshairPos, 1,1, 1,0,0, 1)

                if InputPressed(Config.toggleHoming) then
                    beep()
                    plane.targetting.lock.enabled = not plane.targetting.lock.enabled
                end

                plane.status = '-'


                if not ShouldDrawIngameOptions then

                    if FlightMode == FlightModes.simple and SelectedCamera ~= 'Vehicle' then
                        plane_Steer_Simple(plane)
                    elseif FlightMode == FlightModes.simulation then
                        plane_Steer(plane)
                    end

                end

                if FlightMode == FlightModes.simple then
                    plane_Move_Simple(plane)
                    plane_ApplyForces_Simple(plane)
                elseif FlightMode == FlightModes.simulation then
                    plane_ApplyAerodynamics(plane)
                    plane_ApplyTurbulence(plane)
                end

                if FlightMode == FlightModes.simple then
                    plane_Move_Simple(plane)
                end

                manageTargetting(plane)

                if not ShouldDrawIngameOptions then
                    plane_Shoot(plane)
                end

                plane_LandingGear(plane)

                if GetBool('savegame.mod.debugMode') then
                    plane_Debug(plane)
                end

                if SelectedCamera ~= camPositions[2] then
                    -- AimSteerVehicle(plane.vehicle)
                end

            end

        end

    end
end

-- Run update() functions for each plane.
function PLANES_Update()
    for key, plane in pairs(planeObjectList) do
        if GetPlayerVehicle() == plane.vehicle then

            if not ShouldDrawIngameOptions then
                plane_Camera(plane)
            end

        end
    end
end
