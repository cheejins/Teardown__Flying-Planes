function PLANES_Init()
end


-- Run tick() functions for each plane.
function PLANES_Tick()
    for key, plane in pairs(PLANES) do

        plane_UpdateProperties(plane)


        if FlightMode == FlightModes.simulation then
            plane_ApplyAerodynamics(plane)
        end

        if FlightMode == FlightModes.simple then
            plane_Move_Simple(plane)
            plane_ApplyForces_Simple(plane)
        end


        -- Plane move.
        if plane.isAlive then

            plane_ProcessHealth(plane)

            if FlightMode == FlightModes.simulation then
                plane_Move(plane)
            end

        end


        plane_VisualEffects(plane)
        plane_Sound(plane)


        -- Player in plane.
        if GetPlayerVehicle() == plane.vehicle then

            plane_ChangeCamera()
            plane_CheckTargetLocked(plane)
            plane_ManageTargetting(plane)


            if InputPressed("f1") then
                SetBodyVelocity(plane.body, Vec(0,0,-100))
                SetBodyTransform(plane.body, Transform(Vec(0,300,0)))
                SetBodyAngularVelocity(plane.body, Vec(0,0,0))
            end

            if InputPressed("f2") then
                SetBodyDynamic(plane.body, not IsBodyDynamic(plane.body))
            end

            if InputDown("f3") then
                SetBodyTransform(plane.body, TransformAdd(plane.tr, Transform(Vec(0,3,0))))
                SetBodyVelocity(plane.vel, Vec(0,0,0))
            end

            if InputDown("f4") then
                SetBodyTransform(plane.body, Transform(plane.tr.pos, Quat()))
                SetBodyAngularVelocity(plane.body, Vec())
            end



            if InputPressed("v") then
                plane.engineOn = not plane.engineOn
            end

            if InputPressed("f") then
                plane.flaps = not plane.flaps
            end

            if InputPressed(Config.toggleHoming) then
                beep()
                plane.targetting.lock.enabled = not plane.targetting.lock.enabled
            end

            if not ShouldDrawIngameOptions then
                plane_Camera(plane)
            end

            if plane.isAlive then

                SetPlayerHealth(1)
                plane.status = '-'


                crosshairPos = GetCrosshairWorldPos(plane.AllBodies, plane.tr.pos)
                dbdd(crosshairPos, 1,1, 1,0,0, 1)



                if not ShouldDrawIngameOptions then

                    if FlightMode == FlightModes.simple and SelectedCamera ~= 'Vehicle' then
                        plane_Steer_Simple(plane)
                    elseif FlightMode == FlightModes.simulation then
                        plane_Steer(plane)
                    end

                end

                if not ShouldDrawIngameOptions then
                    plane_Shoot(plane)
                end

                plane_LandingGear(plane)

                if GetBool('savegame.mod.debugMode') then
                    plane_Debug(plane)
                end

                if InputPressed("g") then
                    plane.landing_gear.startTransition = true
                    plane.landing_gear.isDown = not plane.landing_gear.isDown
                    beep()
                end

                if SelectedCamera ~= CameraPositions[2] then
                    -- AimSteerVehicle(plane.vehicle)
                end

            end

        end

    end
end


-- Run update() functions for each plane.
function PLANES_Update()
    for key, plane in pairs(PLANES) do

        if GetPlayerVehicle() == plane.vehicle then

            plane_Animate_AeroParts(plane)

            if not ShouldDrawIngameOptions then
                plane_Camera(plane)
            end

        else

            plane_Animate_AeroParts(plane, true)

        end

    end
end
