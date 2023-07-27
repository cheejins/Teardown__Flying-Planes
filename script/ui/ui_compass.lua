function drawCompass(plane, uiW, uiH)

    UiTextShadow(0,0,0,0, 0,0)

    CompassDirections = {
        {'N', Vec(0,0,-1)},
        {'N/E', Vec(1,0,-1)},
        {'E', Vec(1,0,0)},
        {'S/E', Vec(1,0,1)},
        {'S', Vec(0,0,1)},
        {'S/W', Vec(-1,0,1)},
        {'W', Vec(-1,0,0)},
        {'N/W', Vec(-1,0,-1)},
    }

    UiTranslate(UiCenter() - uiW/2, 0)
    UiWindow(uiW, UiHeight(), true)

    UiTranslate(uiW/2, UiMiddle() - uiH/2 - 50)
    UiAlign('center bottom')
    UiFont('bold.ttf', 20)
    UiColor(1,1,1, 1)


    do UiPush()
        UiColor(0,0,0, 0.5)
        UiTranslate(0, 30)
        UiRect(4, 10)
    UiPop() end



    local camTr = GetCameraTransform()
    -- local camTr = plane.tr

    for i, dir in pairs(CompassDirections) do

        local ang = TransformToLocalPoint(camTr, VecAdd(camTr.pos, dir[2]))

        if ang[3] < 0 then -- Check if pos is infront of camera.
            do UiPush()

                UiTranslate(ang[1]/1.5 * uiW, -30)
                UiText(dir[1])

                UiTranslate(0, 30)
                UiRect(3, 10)

            UiPop() end
        end

    end

end

function drawUiGyro(plane, width, height)

    UiTranslate(UiCenter(), UiMiddle())


    UiAlign('center middle')
    UiFont('bold.ttf', 20)
    UiTextShadow(0,0,0,0, 0,0)

    local width = width or 600
    local height = height or 400

    UiWindow(width, height, true)
    UiTranslate(UiCenter(), UiMiddle())



    UiColor(0,0,0, 0.5)
    do UiPush()
        UiAlign("left middle")
        UiTranslate(-width/2, 0)
        UiRect(120, 6)
    UiPop() end
    do UiPush()
        UiAlign("right middle")
        UiTranslate(width/2, 0)
        UiRect(120, 6)
    UiPop() end


    -- local camTr = GetCameraTransform()
    local camTr = plane.tr
    local camDir = QuatToDir(camTr.rot)
    local camDirY = math.deg(camDir[2]) * math.pi / 2
    -- dbw('camDirY', camDirY)


    local s = 1

    local deg = 120
    local angIncrement = 2
    local points = deg / angIncrement

    local y = UiHeight() / points / s

    UiColor(1,1,1, 1)


    for i = 0, points do
        do UiPush()

            local val = i * angIncrement

            UiTranslate(0, camDirY * y)

            local w = 5

            local lineH = 3
            local drawText = false
            if val % 90 == 0 then
                w = 120
                drawText = true
            elseif val % 30 == 0 then
                w = 60
                drawText = true
            elseif val % 10 == 0 then
                w = 20
                drawText = true
            end


            drawGyroValue(1, val, width, w, y, drawText, lineH)
            drawGyroValue(-1, val, width, w, y, drawText, lineH)

        UiPop() end
    end

end


function drawGyroValue(sign, val, width, w, y, drawText, lineH)

    local text = Ternary(val == 0, 0, -sign * val)

    do UiPush()

        UiAlign('right middle')
        UiTranslate(width/2, sign * val * y)
        UiRect(w, lineH)

        if drawText then
            UiTranslate(-w - 10, 0)
            UiText(sfn(text, 0))
        end

    UiPop() end
    do UiPush()

        UiAlign('left middle')
        UiTranslate(-width/2, sign * val * y)
        UiRect(w, lineH)

        if drawText then
            UiTranslate(w + 10, 0)
            UiText(sfn(text, 0))
        end

    UiPop() end
end
