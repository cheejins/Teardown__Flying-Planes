function draw()

    UiColor(1,1,1, 1)
    UiTextShadow(0,0,0, 1, 0.3, 0)
    UiFont("bold.ttf", 24)


    local uiW = 600
    local uiH = 650

    UiPush()

        if Config.showOptions then
            if FlightMode == FlightModes.simple then
                DrawControlsSimple()
            elseif FlightMode == FlightModes.simulation then
                DrawControlsSimulation()
            end
        end

        if ShouldDrawIngameOptions then

            DrawIngameOptions()

        else

            do UiPush()

                CAMERA = {}
                CAMERA.xy = {UiCenter(), UiMiddle()}
                local vehicle = GetPlayerVehicle()
                for i = 1, #PLANES do
                    if vehicle == PLANES[i].vehicle then

                        local plane = PLANES[i]

                        do UiPush()
                            planeDrawHud(plane, uiW + 200, uiH)
                        UiPop() end


                        if plane.playerInUnbrokenPlane then

                            do UiPush()
                                drawUiGyro(plane, uiW, uiH)
                            UiPop() end

                            do UiPush()
                                drawCompass(plane, uiW, uiH)
                            UiPop() end

                            do UiPush()
                                drawTargets(plane)
                            UiPop() end

                        end


                        do UiPush()

                            local pos = Vec(0,0,0)
                            local dist = VecDist(plane.tr.pos, pos)
                            local a = (dist / 800) - 0.6

                            UiColor(0.7,0.7,0.7, a)
                            UiTextShadow(0,0,0, a)
                            UiFont("bold.ttf", 20)


                            if Config.smallMapMode then

                                local isInfront = TransformToLocalPoint(GetCameraTransform(), pos)[3] < 0
                                if isInfront then

                                    local x,y = UiWorldToPixel(pos)

                                    UiTranslate(x,y)
                                    UiAlign("center middle")
                                    UiImageBox("MOD/img/dot.png", 10, 10, 0,0)

                                    do UiPush()
                                        UiTranslate(-15, 0)
                                        UiAlign("right middle")
                                        UiText('Map Center')
                                    UiPop() end

                                    do UiPush()
                                        UiTranslate(15, 0)
                                        UiAlign("left middle")
                                        UiText(sfn(dist, 0) .. ' m')
                                    UiPop() end

                                end

                            end

                        UiPop() end

                    end
                end

            UiPop() end

        end

    UiPop()


    if db then
        DrawPlaneIDs()
    end

    DrawFlightPaths()

end



function drawRespawnText()

    -- if showRespawnText then

    --     local v = GetPlayerVehicle()
    --     local vIsDeadPlane = v ~= 0 and HasTag(v, 'planeVehicle') and GetVehicleHealth(v) <= 0.5

    --     local drawText = vIsDeadPlane or IsPointInWater(GetPlayerTransform().pos)

    --     if drawText then
    --         UiPush()
    --         UiTranslate(UiCenter(), 200)
    --         UiAlign("center middle")
    --         UiFont("bold.ttf", 40)
    --         UiColor(1,1,1)
    --         UiText("Press \"".. respawnKey .."\" to respawn")
    --         UiPop()
    --     end

    -- end

end

function DrawControlsSimulation()
    UiPush()

        local fs = 28

        UiTranslate(50, UiHeight()-50)
        UiTextShadow(0,0,0, 1, 0.2)
        UiColor(1,1,1, 1)
        UiFont("regular.ttf", fs)
        UiAlign("left bottom")

        UiText('Change camera = X')
        UiTranslate(0, -fs)
        UiText('Change zoom = Mouse wheel')
        UiTranslate(0, -fs)
        UiText('Change Target = ' .. string.upper(Config.changeTarget))
        UiTranslate(0, -fs)
        UiText('Shoot = LMB/RMB')
        UiTranslate(0, -fs)
        UiTranslate(0, -fs)


        UiText('Yaw = Z/C')
        UiTranslate(0, -fs)
        UiText('Pitch = W/S')
        UiTranslate(0, -fs)
        UiText('Roll = A/D')
        UiTranslate(0, -fs)
        UiTranslate(0, -fs)

        UiText('Air brakes = SPACE')
        UiTranslate(0, -fs)
        UiText('Thrust = Shift/Ctrl')
        UiTranslate(0, -fs)

        UiTranslate(0, -fs)
        UiText('(FLIGHT MODE: SIMULATION)')
        UiTranslate(0, -fs)
        UiFont("regular.ttf", fs*1.5)
        UiText('CONTROLS')

    UiPop()
end

function DrawControlsSimple()
    UiPush()

        local fs = 28

        UiTranslate(50, UiHeight()-50)
        UiTextShadow(0,0,0, 1, 0.2)
        UiColor(1,1,1, 1)
        UiFont("regular.ttf", fs)
        UiAlign("left bottom")



        UiText('Change camera = X')
        UiTranslate(0, -fs)
        UiText('Change zoom = Mouse wheel')
        UiTranslate(0, -fs)
        UiText('Change Target = ' .. string.upper(Config.changeTarget))
        UiTranslate(0, -fs)
        UiText('Shoot = LMB/RMB')
        UiTranslate(0, -fs)
        UiTranslate(0, -fs)

        UiText('Yaw = Z/C')
        UiTranslate(0, -fs)
        UiText('Pitch/Roll = Mouse Aim')
        UiTranslate(0, -fs)
        UiTranslate(0, -fs)

        UiText('Air brakes = SPACE')
        UiTranslate(0, -fs)
        UiText('Thrust = W/S')
        UiTranslate(0, -fs)

        UiTranslate(0, -fs)
        UiText('(FLIGHT MODE: SIMPLE)')
        UiTranslate(0, -fs)
        UiFont("regular.ttf", fs*1.5)
        UiText('CONTROLS')


    UiPop()
end



function planeDrawHud(plane, uiW, uiH)

    local c = Vec(0.5,1,0.5)
    if plane.health <= 0 then c = Vec(1,0,0) end

    UiColor(1,1,1,1)
    UiFont("bold.ttf", 40)
    UiAlign("center middle")

    do UiPush()
        UiTranslate(UiCenter(), 50)
        UiColor(1,1,1, 1)
        UiTextShadow(0,0,0, 1, 0.2, 0.1)
        UiFont("regular.ttf", 32)

        if GetTime() < 30 or not GetBool("level.showedOptions") then
            UiText('Press "' .. Config.toggleOptions .. '" to show in-game options menu.')
        end

    UiPop() end


    do UiPush()

        local w = 50

        UiColor(0,0,0, 0.5)
        UiTranslate(UiCenter(), UiMiddle())
        UiImageBox("MOD/img/hud_crosshair_outer.png", w, w)

    UiPop() end


    do UiPush()

        UiColor(1,1,1, 0.5)

        local fwdVec = Vec(0,0,-300)
        local pTr = plane.tr
        local pos = TransformToParentPoint(pTr, fwdVec)

        local isInfront = TransformToLocalPoint(GetCameraTransform(), pos)[3] < 0
        if isInfront then
            local x,y = UiWorldToPixel(pos)
            UiTranslate(x,y)
            UiImageBox("MOD/img/dot.png", 20, 20, 0,0)
        end

    UiPop() end


    if plane.playerInUnbrokenPlane then

        do UiPush()

            local scale = 5
            local w = 1000 / scale
            local h = 400 / scale

            UiTranslate(UiCenter(), 0)

            -- hud OVERSPEED
            do UiPush()
                UiTranslate(0, 400)
                if plane.speed > plane.topSpeed * 0.7 then
                    UiColor(0.1, 0.1, 0.1, 0.15)
                    UiRect(w * 1.25, h * 1.25)
                    UiColor(1,1,1, Oscillate(0.5))
                    UiImageBox("MOD/img/hud_overspeed.png", w * 1.25, h * 1.25, 1,1)
                end
            UiPop() end

            -- hud STALL
            do UiPush()
                UiTranslate(0, 280)
                if plane.speed*2 < plane.totalVel and (plane.speed > 1 or plane.speed < -1) then
                    UiColor(0.1, 0.1, 0.1, 0.15)
                    UiRect(w,h)
                    UiColor(1,1,1, Oscillate(1/2))
                    UiImageBox("MOD/img/hud_stall.png", w, h, 1,1)

                    if Config.sounds_stall_warning then
                        PlayLoop(sounds.loop_stall_warning, GetCameraTransform().pos, 1/5)
                    end

                end
            UiPop() end

        UiPop() end

    end

    -- FWD VEL
     do UiPush()

        UiAlign("right middle")
        UiTranslate(UiCenter() - uiW/2, -150)

        local a = plane.speed+1 < plane.totalVel/1.8

        local fwdVel = math.abs(1 / (plane.speed / plane.totalVel+0.000001))
        if plane.totalVel <= 1 then
            fwdVel = 1
        end

        fwdVel = (fwdVel - 1) * 100

        do UiPush()
            UiTranslate(0, 720)
            UiTranslate(5, 5)
            UiColor(c[1], c[2], c[3])
            UiText("FWD VEL")
        UiPop() end

        do UiPush()
            UiTranslate(0, 770)
            UiText(sfn(fwdVel, 0) .. "%")
        UiPop() end

    UiPop() end




    do UiPush()
        -- hud STATUS
        UiTranslate(960, 900)
        UiFont("bold.ttf", 24)
        UiText('Homing Missiles: ' .. ternary(plane.targetting.lock.enabled, 'ON', 'OFF'))
        UiTranslate(0, 30)
        UiText("Camera: " .. SelectedCamera)
        UiTranslate(0, 30)
        UiText("Status: " .. plane.status)

    UiPop() end


    do UiPush()
        UiAlign("left top")
        UiTranslate(UiCenter() +  uiW / 2, 0)

        -- hud THRUST
        do UiPush()

            UiColor(c[1], c[2], c[3])
            UiTranslate(0, 450)

            UiText("THRUST ")
            UiTranslate(-0, -450)
            local lerpThrustColor = VecLerp(Vec(0,0,0),Vec(1,1,1), plane.thrust/100)
            UiColor(lerpThrustColor[1],lerpThrustColor[2],lerpThrustColor[3])
            UiTranslate(0, 500)

            UiText(plane.thrust .. "%")

        UiPop() end

        do UiPush()
            UiTranslate(275, 525)
            drawThrust(plane)
        UiPop() end

        -- hud SPEED
        do UiPush()
            local knots = string.format("%.0f", (plane.speed*1.94384))

            if knots == "-0" then knots = "0" end

            UiColor(c[1], c[2], c[3])
            UiTranslate(0, 700)
            -- UiImageBox("MOD/img/squareBg.png", 160, 90, 0, 0)

            UiText("SPEED")
            UiTranslate(-0, -700)
            UiColor(1,1,1)
            UiTranslate(0, 750)

            local speedC = 1 - ((plane.speed/plane.topSpeed) ^ 1.8)

            UiColor(1, speedC, speedC)
            UiText(knots .. " Knots")


            UiTranslate(275, 25)
            drawSpeed(plane)

        UiPop() end





    UiPop() end


    -- hud ALT
    do UiPush()
        UiAlign("right middle")
        UiTranslate(UiCenter() - uiW/2, 0)

        local alt = string.format("%.0f", (plane.tr.pos[2] + plane.groundDist) * 3.28084)
        do UiPush()
            UiTranslate(0, 720)
            UiTranslate(5, 5)
            UiColor(c[1], c[2], c[3])
            UiText("ALT")
        UiPop() end

        do UiPush()
            UiTranslate(0, 770)
            local gb = 1/(500/alt)
            UiColor(1, gb, gb, 1)
            UiText(alt .. " ft")
        UiPop() end

    UiPop() end

    -- Health
    do UiPush()

        UiAlign("center middle")
        UiTranslate(UiCenter() - uiW/2, 300)


        local colorVecs = {
            Vec(1, 0, 0),
            Vec(c[1], c[2], c[3]),
        }


        local frac = plane.health

        local a = 1
        -- if plane.health <= 0.5 and plane.health > 0 then
        --     a = Oscillate(1) + 1/2
        -- end

        local healthColor = VecLerp(colorVecs[1], colorVecs[2], frac)

        UiColor(healthColor[1], healthColor[2], healthColor[3], a)
        UiImageBox("MOD/img/hud/hud_plane.png", 150, 150, 0,0)
        UiTranslate(0, 150/1.5)

        UiColor(1,1,1, 1)
        UiText(sfn(frac * 100, 0) .. "%")


    UiPop() end



end

function drawThrust(plane)

	local display = plane.thrust
    UiAlign("center middle")

    UiColor(0.75,0.75,0.75,0.75)
    UiImageBox("MOD/img/mph.png", 200,200, 0,0)
    UiRotate(-display*1.8)

    UiColor(1,0.5,0,1)
    UiImageBox("MOD/img/needle.png", 200,200, 0,0)

end

function drawSpeed(plane)

	local display = plane.speed / GTZero(plane.topSpeed) * 100
    UiAlign("center middle")

    UiColor(0.75,0.75,0.75,0.75)
    UiImageBox("MOD/img/mph.png", 200,200, 0,0)
    UiRotate(-display*1.8)

    UiColor(1,0,0,1)
    UiImageBox("MOD/img/needle.png", 200,200, 0,0)

end



function WriteMessage(message, fontSize)
    UiPush()

        fontSize = fontSize or 34
        local width = UiWidth()/2

        UiTranslate(UiCenter(), 0)
        UiTextShadow(0,0,0, 1, 0)
        UiFont("regular.ttf", fontSize)
        UiAlign("center top")
        UiWordWrap(width)

        UiColor(0,0,0, 0.5)
        UiRect(width, 6 * fontSize)

        UiColor(1,1,1, 1)
        UiText(message)

    UiPop()
end



function DrawPlaneIDs()

    UiColor(1,1,1, 1)
    UiTextShadow(0,0,0, 1, 0.2)
    UiAlign("center middle")
    UiFont("regular.ttf", 48)

    for _, plane in ipairs(PLANES) do
        UiPush()

            local pos = AabbGetBodyCenterTopPos(plane.body)
            local x, y = UiWorldToPixel(pos)

            UiTranslate(x,y)
            UiText(plane.id)

        UiPop()
    end

end