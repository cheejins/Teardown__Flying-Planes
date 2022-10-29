function Init_PLANES()
end

function Tick_PLANES()
    for key, plane in pairs(PLANES) do

        if plane.isValid then

            plane_UpdateProperties(plane)
            plane_Input(plane)

            if IsSimulationFlight() then
                plane_ApplyAerodynamics(plane)
            end

            if IsSimpleFlight() then
                plane_Move_Simple(plane)
                plane_ApplyForces_Simple(plane)
            end


            -- Plane move.
            if plane.isAlive then

                plane_ProcessHealth(plane)

                if IsSimulationFlight() then
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

                if not ShouldDrawIngameOptions then
                    plane_Camera(plane)
                end

                if plane.isAlive then

                    plane_LandingGear(plane)


                    crosshairPos = GetCrosshairWorldPos(plane.AllBodies, plane.tr.pos)
                    dbdd(crosshairPos, 1, 1, 1, 0, 0, 1)


                    if not ShouldDrawIngameOptions then

                        if IsSimpleFlight() and SelectedCamera ~= 'Vehicle' then
                            plane_Steer_Simple(plane)
                        elseif IsSimulationFlight() then
                            plane_Steer(plane)
                        end

                    end

                    if not ShouldDrawIngameOptions then
                        plane_ManageShooting(plane)
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

function Update_PLANES()
    for key, plane in pairs(PLANES) do

        if plane.isValid then

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
end

function Draw_PLANES()
    UiPush()

        local uiW = 600
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
