

function plane_draw_gyro(plane, uiW, uiH)
    do UiPush()
        drawUiGyro(plane, uiW, uiH)
    UiPop() end

    do UiPush()
        drawCompass(plane, uiW, uiH)
    UiPop() end

    do UiPush()
        plane_draw_Targetting(plane)
    UiPop() end
end

function plane_draw_hud(plane, uiW, uiH)
    do UiPush()

        plane_draw_hud_control_panel(plane)


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

            local hit, hitPos = RaycastFromTransform(TransformToParentTransform(plane.tr, Transform(Vec(0,0,-10))), 1000, 0, plane.AllBodies)
            if hit then
                local x,y = UiWorldToPixel(hitPos)
                UiTranslate(x,y)
                UiColor(1,0,0, 1)
                UiImageBox("MOD/img/hud_crosshair_shootpos.png", 25, 25, 0,0)
            else
                local x,y = UiWorldToPixel(pos)
                UiTranslate(x,y)
                UiImageBox("MOD/img/dot.png", 15, 15, 0,0)
            end


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
                if plane.speed > plane.topSpeed * 0.9 then
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

                    if not plane.vtol.isDown and Config.sounds_stall_warning then
                        PlayLoop(sounds.loop_stall_warning, GetCameraTransform().pos, 1/4)
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


    -- hud STATUS
    do UiPush()
        UiTranslate(960, 850)
        UiFont("bold.ttf", 22)
        UiSplitText("Camera", SelectedCamera)
        UiTranslate(0, 30)
        UiSplitText("Status", plane.status)
        UiTranslate(0, 30)
        UiSplitTextBool('Engine', plane.engineOn, 'ON', 'OFF')
        UiTranslate(0, 30)
        UiSplitTextBool("Landing Gear", plane.landing_gear.isDown, "DOWN", "UP")
        UiTranslate(0, 30)
        UiSplitTextBool('Wheel Brake', plane.brakeOn, 'Engaged', 'Released')
        UiTranslate(0, 30)
        UiSplitTextBool('Missile Homing', plane.targetting.lock.enabled, 'ON', 'OFF')
        if plane_IsVtolCapable(plane) then
            UiTranslate(0, 30)
            UiSplitText('VTOL', Ternary(plane.vtol.isDown, 'DOWN', 'FORWARD'))
        end
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
            plane_draw_Thrust(plane)
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
            plane_draw_Speed(plane)

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


UiPop() end

end

function plane_draw_Thrust(plane)

	local display = plane.thrust
    UiAlign("center middle")

    UiColor(0.75,0.75,0.75,0.75)
    UiImageBox("MOD/img/mph.png", 200,200, 0,0)
    UiRotate(-display*1.8)

    UiColor(1,0.5,0,1)
    UiImageBox("MOD/img/needle.png", 200,200, 0,0)

end

function plane_draw_Speed(plane)

	local display = plane.speed / GTZero(plane.topSpeed) * 100
    UiAlign("center middle")

    UiColor(0.75,0.75,0.75,0.75)
    UiImageBox("MOD/img/mph.png", 200,200, 0,0)
    UiRotate(-display*1.8)

    UiColor(1,0,0,1)
    UiImageBox("MOD/img/needle.png", 200,200, 0,0)

end


function plane_draw_hud_control_panel(plane, w, h)

    --todo
    --[[
        Consider vtol
        horizontal span of icons with keybind under
    ]]


    local iconData = {
        { icon = "MOD/img/hud/icon_brakes.png"          , state = plane.brakeOn             , title = "Engine"       , keybind = "B" },
        { icon = "MOD/img/hud/icon_engine.png"          , state = plane.engineOn            , title = "Landing Gear" , keybind = "N" },
        { icon = "MOD/img/hud/icon_landing_gear.png"    , state = plane.landing_gear.isDown , title = "Wheel Brake"  , keybind = "G" },
        { icon = "MOD/img/hud/icon_homing_missiles.png" , state = plane.landing_gear.isDown , title = "Wheel Brake"  , keybind = "H" },
    }

    if plane_IsVtolCapable(plane) then
        table.insert(iconData, { icon = "MOD/img/hud/icon_vtol.png" , plane.vtol.isDown , title = "VTOL"  , keybind = "V" })
    end


    UiPush()

        UiTranslate(UiCenter(), UiHeight() - 300)

        local iconSize = 50 -- Icon size.

        UiTranslate(-1 * ((#iconData*iconSize)/2), 0)

        for _, data in ipairs(iconData) do
            UiTranslate(iconSize, 0)
            UiImageBox(data.icon, iconSize, iconSize, 0, 0)
        end

    UiPop()


end