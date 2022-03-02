function draw()
    CAMERA = {}
    CAMERA.xy = {UiCenter(), UiMiddle()}
    local vehicle = GetPlayerVehicle()
    for i = 1, #planeObjectList do
        if vehicle == planeObjectList[i].vehicle then

            local plane = planeObjectList[i]

            do UiPush()
                planeDrawHud(plane)
            UiPop() end

            do UiPush()
                UiTranslate(UiCenter()*1.60, UiMiddle())
                drawThrust(plane)
            UiPop() end

            do UiPush()
                UiTranslate(UiCenter()*1.60, UiMiddle()+250)
                drawSpeed(plane)
            UiPop() end

            do UiPush()
                drawTargets(plane)
            UiPop() end

        end
    end
    drawRespawnText()
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

	local display = plane.getSpeed() / gtZero(plane.topSpeed) * 100
    UiAlign("center middle")

    UiColor(0.75,0.75,0.75,0.75)
    UiImageBox("MOD/img/mph.png", 200,200, 0,0)
    UiRotate(-display*1.8)

    UiColor(1,0,0,1)
    UiImageBox("MOD/img/needle.png", 200,200, 0,0)

end

function planeDrawHud(plane)

    local c = Vec(0.5,1,0.5)
    if plane.getHealth() <= 0.5 then c = Vec(1,0,0) end

    UiColor(1,1,1,1)
    UiFont("bold.ttf", 40)
    UiAlign("center middle")

    do UiPush()
        UiTranslate(UiCenter(), UiHeight()-50)
        UiColor(1,1,1, 1)
        UiFont("bold.ttf", 24)

        local smallMapModeEnabled = ternary(SmallMapMode, 'ON', 'OFF')
        UiText('Press '..smallMapModeKey..' to enable small-map mode. Small Map Mode: ' .. smallMapModeEnabled)

    UiPop() end

    do UiPush()
        UiColor(0,0,0, 0.5)
        UiTranslate(UiCenter(), UiMiddle())
        UiImageBox("MOD/script/img/hud_crosshair_outer.png", 50, 50, 0,0)
    UiPop() end


    do UiPush()

        UiColor(1,1,1, 0.5)

        local fwdVec = Vec(0,0,-300)
        local pTr = plane.getTransform()
        local pos = TransformToParentPoint(pTr, fwdVec)

        local isInfront = TransformToLocalPoint(GetCameraTransform(), pos)[3] < 0
        if isInfront then
            local x,y = UiWorldToPixel(pos)
            UiTranslate(x,y)
            UiImageBox("MOD/script/img/dot.png", 20, 20, 0,0)
        end

    UiPop() end


    do UiPush()

        local scale = 5
        local w = 1000 / scale
        local h = 400 / scale

        UiTranslate(UiCenter(), 0)

        -- hud OVERSPEED
        do UiPush()
            UiTranslate(0, 400)
            if plane.getSpeed() > plane.topSpeed * 0.7 then
                UiColor(0.1, 0.1, 0.1, 0.15)
                UiRect(w * 1.25, h * 1.25)
                UiColor(1,1,1, oscillate(0.5))
                UiImageBox("MOD/script/img/hud_overspeed.png", w * 1.25, h * 1.25, 1,1)
            end
        UiPop() end

        -- hud STALL
        do UiPush()
            UiTranslate(0, 280)
            if plane.getSpeed()*1.8 < plane.getTotalVelocity() then
                UiColor(0.1, 0.1, 0.1, 0.15)
                UiRect(w,h)
                UiColor(1,1,1, oscillate(0.75))
                UiImageBox("MOD/script/img/hud_stall.png", w, h, 1,1)
            end
        UiPop() end

    UiPop() end


    do UiPush()
        -- hud STATUS
        UiTranslate(960, 900)
        UiFont("bold.ttf", 36)
        UiText(plane.status)
    UiPop() end


    do UiPush()
        UiAlign("right top")
        UiTranslate(1400, 0)

        -- hud THRUST
        do UiPush()
        UiColor(c[1], c[2], c[3])
        UiTranslate(0, 450)
        -- UiImageBox("MOD/script/img/squareBg.png", 160, 90, 0, 0)

        UiText("THRUST ")
        UiTranslate(-0, -450)
        local lerpThrustColor = VecLerp(Vec(0,0,0),Vec(1,1,1), plane.thrust/100)
        UiColor(lerpThrustColor[1],lerpThrustColor[2],lerpThrustColor[3])
        UiTranslate(0, 500)

        UiText(plane.thrust .. "%")
        UiPop() end

        -- hud SPEED
        do UiPush()
            local knots = string.format("%.0f", (plane.getSpeed()*1.94384))

            if knots == "-0" then knots = "0" end

            UiColor(c[1], c[2], c[3])
            UiTranslate(0, 700)
            -- UiImageBox("MOD/script/img/squareBg.png", 160, 90, 0, 0)

            UiText("SPEED")
            UiTranslate(-0, -700)
            UiColor(1,1,1)
            UiTranslate(0, 750)

            local speedC = 1 - ((plane.getSpeed()/plane.topSpeed) ^ 1.8)

            UiColor(1, speedC, speedC)
            UiText(knots .. " Knots")
        UiPop() end
    UiPop() end


    -- hud ALT
    do UiPush()
        UiAlign("left top")
        UiTranslate(500, 0)

        local alt = string.format("%.0f", plane.getTransform().pos[2])
        do UiPush()
            UiTranslate(0, 720)
            -- UiImageBox("MOD/script/img/squareBg.png", 160, 90, 0, 0)
            UiTranslate(5, 5)
            UiColor(c[1], c[2], c[3])

            UiText("ALT")
        UiPop() end

        do UiPush()
            UiTranslate(0, 770)
            UiColor(1,1,1)

            UiText(alt .. " m")
        UiPop() end

    UiPop() end

end


function drawRespawnText()

    local v = GetPlayerVehicle()
    local vIsDeadPlane = v ~= 0 and HasTag(v, 'planeVehicle') and GetVehicleHealth(v) <= 0.5

    local drawText = vIsDeadPlane or IsPointInWater(GetPlayerTransform().pos)

    if drawText then
        UiPush()
        UiTranslate(UiCenter(), 200)
        UiAlign("center middle")
        UiFont("bold.ttf", 40)
        UiColor(1,1,1)
        UiText("Press \"".. respawnKey .."\" to respawn")
        UiPop()
    end

end