function margin(x,y) UiTranslate(x,y) end

function uiDrawSquare()
    do UiPush()
        UiAlign('center middle')
        UiColor(1,0.5,1, 1)
        UiRect(5,5)
    UiPop() end
end

function uiShowMessage(stringsTable)
    do UiPush()

        UiAlign('center middle')
        margin(UiCenter(), UiMiddle() + 200)

        for index, str in ipairs(stringsTable) do
            UiText(str)
            margin(0,50)
        end

    UiPop() end
end

function uiSetColor(c, a)
    UiColor(c[1], c[2], c[3], a or 1)
end

function uiSetFont(fs)
    UiFont('regular.ttf', fs or 32)
    UiTextShadow(0,0,0,1, 0.5,0.5)
    UiColor(1,1,1, 1)
end

-- Draw the outline and highlight of a shape
function uiDrawShape(s)
    DrawShapeOutline(s, 1,1,1, 1)
    DrawShapeHighlight(s, 0.25)
end


function createSlider(tb, key, title, valueText, min, max, w, h, fs)

    do UiPush()

        local v = tb[key]

        fs = fs or 24

        min = min or 0
        max = max or 300

        UiAlign('left middle')

        -- Text header
        UiColor(1,1,1, 1)
        UiFont('regular.ttf', fs)
        UiText(title)
        UiTranslate(0, fs)

        -- Slider BG
        UiColor(0.4,0.4,0.4, 1)
        local slW = w or 400
        UiRect(slW, h or 10)

        -- Convert to slider scale.
        v = ((v-min) / (max-min)) * slW

        -- Slider dot
        UiColor(1,1,1, 1)
        UiAlign('center middle')
        v, done = UiSlider("ui/common/dot.png", "x", v, 0, slW)

        local val = (v/slW) * (max-min) + min -- Convert to true scale.
        tb[key] = val

        -- Slider value
        do UiPush()
            UiAlign('left middle')
            UiTranslate(slW + 20, 0)
            local decimals = Ternary((v/slW) * (max-min) + min < 10, 3, 1)
            UiText(sfn((v/slW) * (max-min) + min, decimals) .. ' ' .. (valueText or ''))
        UiPop() end

        margin(w + fs*8, 0)

        -- Round button
        do UiPush()

            local text = 'RND'
            local len = string.len(text)

            UiAlign('right middle')
            UiButtonImageBox('ui/common/box-outline-6.png', 10,10, 1,1,1, 1)
            if UiTextButton('RND', fs*len, fs*1.25) then
                tb[key] = math.floor(tb[key])
            end

        UiPop() end

    UiPop() end

    if done then
        return true
    end

end

function DrawImage(path, pos, l, w, r, g, b, a, dt)
    local dot = LoadSprite(path)
    local spriteRot = QuatLookAt(pos, GetCameraTransform().pos)
    local spriteTr = Transform(pos, spriteRot)
    if dt == nil then dt = true end
    DrawSprite(dot, spriteTr, l or 0.2, w or 0.2, r or 1, g or 1, b or 1, a or 1, dt and true)
end

function UiLine(p1, p2, w, r,g,b, a) -- Draw a straight line.

    UiAlign('left middle')
    UiColor(r,g,b, a or 1)

    do UiPush()

        local uMinX, uMinZ = UiWorldToPixel(min)
        -- local uMaxX, uMaxZ = UiWorldToPixel(max)

        UiTranslate(uMinX, uMinZ)

        local dist = VecDist(p1, p2)
        local angle = VecAngle(p1, p2)

        margin(x1, y1)

        UiRotate(angle)
        UiRect(dist, w or 2) -- Draw line with the length of the hypotenuse.

    UiPop() end

end

function UiSplitText(title, value)
    UiPush()

        UiAlign("right top")
        UiText(title .. " = ")
        UiAlign("left top")

        if type(value) == "number" then
            UiText(sfn(value))
        else
            UiText(value)
        end

    UiPop()
end

function UiSplitTextBool(title, value, text_true, text_false)
    UiPush()

        UiAlign("right top")
        UiText(title .. " = ")
        UiAlign("left top")

        UiPush()
            UiColorBool(value)
            UiText(Ternary(value, text_true, text_false))
        UiPop()

    UiPop()
end

function UiColorBool(bool, white_false)
	if bool then
		UiColor(0,1,0, 1)
	elseif white_false then
		UiColor(1,1,1, 1)
	else
		UiColor(1,0,0, 1)
	end
end