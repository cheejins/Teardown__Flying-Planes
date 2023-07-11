function init_planes()
end

function Tick_PLANES(dt)

    PlayerInPlane = false

    for key, plane in pairs(PLANES) do

        -- No intercollisions, but leave world collision on.
        for _, shape in ipairs(plane.AllShapes) do
            SetShapeCollisionFilter(shape, 4, 1)
        end

        if plane.isValid then

            plane_UpdateProperties(plane)
            plane_Input(plane)


            -- Plane move.
            if plane.isAlive then

                plane_ApplyAerodynamics(plane)
                plane_ProcessHealth(plane)
                plane_Move(plane)

            end


            plane_VisualEffects(plane)
            plane_Sound(plane)


            -- Player in plane.
            if GetPlayerVehicle() == plane.vehicle then

                crosshairPos = GetCrosshairWorldPos(plane.AllBodies, true, plane.tr.pos)

                PlayerInPlane = true

                plane_camera_change_next()
                plane_CheckTargetLocked(plane)
                plane_ManageTargetting(plane)

                if not ShouldDrawIngameOptions then
                    plane_camera_manage(plane, dt)
                end

                if plane.isAlive then

                    if not ShouldDrawIngameOptions then

                        if IsSimpleFlight and SelectedCamera ~= 'Vehicle' then
                            plane_Steer_Simple(plane)
                        elseif IsSimulationFlight() then
                            plane_Steer(plane)
                        end

                    end

                    if not ShouldDrawIngameOptions then
                        plane_ManageShooting(plane)
                    end

                    if plane.brakeOn then
                        DriveVehicle(plane.vehicle, 0, 0, true)
                    end

                    if GetBool('savegame.mod.debugMode') then
                        plane_Debug(plane)
                    end


                    SetPlayerHealth(1)

                end

            end

        end

    end
end

function Update_PLANES(dt)
    for key, plane in pairs(PLANES) do

        if plane.isValid then

            if GetPlayerVehicle() == plane.vehicle then

                plane_Animate_AeroParts(plane)

                if not ShouldDrawIngameOptions then
                    plane_camera_manage(plane, dt)
                end

            else

                plane_Animate_AeroParts(plane, true)

            end

        end

    end
end

function Draw_PLANES()
    UiPush()

        local uiW = 800
        local uiH = 650


        if ShouldDrawIngameOptions then

            DrawIngameOptions()

        else

            if Config.smallMapMode then
                Draw_MapCenter()
            end

            if db then
                Draw_PlaneIDs()
            end

            if Config.spawn_aiplanes then
                Draw_AiplanesFlightPaths()
            end

            UiPush()
                for _, plane in ipairs(PLANES) do

                    if plane.isValid then

                        if GetPlayerVehicle() == plane.vehicle then

                            plane_draw_hud(plane, uiW + 200, uiH)

                            if plane.isAlive then
                                plane_draw_gyro(plane, uiW, uiH)
                            end

                        end

                    end

                end
            UiPop()

        end

        if ShouldDrawIngameOptions or Config.showOptions then
            Draw_Controls()
        end

    UiPop()
end
