function Draw_WriteMessage(message, fontSize)
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

function Draw_PlaneIDs()
    UiPush()

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

    UiPop()
end

function Draw_Controls()
    if IsSimpleFlight() then Draw_ControlsSimple()
    elseif IsSimulationFlight() then Draw_ControlsSimulation()
    end
end

function Draw_ControlsSimulation()
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

        UiText('Landing Gear = G')
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

function Draw_ControlsSimple()
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

        UiText('Landing Gear = G')
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

function Draw_MapCenter()

    local pos = Vec(0,0,0)
    local dist = VecDist(plane.tr.pos, pos)
    local a = (dist / 800) - 0.6

    UiColor(0.7,0.7,0.7, a)
    UiTextShadow(0,0,0, a)
    UiFont("bold.ttf", 20)

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