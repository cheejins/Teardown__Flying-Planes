function init()

    title = "ERROR: FLYING PLANES MOD NOT INSTALLED!"
    message = "Please ensure you are subscribed to the \"Flying Planes\" mod in the steam workshop and have it enabled in Teardown's mod manager to make aircraft work."
    close = "Press ctrl + c to hide this message"

    showMessage = false
    hideMessage = false
end

function tick()

    if GetBool('level.planeScriptActive') == false then
        Spawn('MOD/prefab/script.xml', Transform())
        SetBool('level.planeScriptActive', true)
    end

    local vehicle = GetPlayerVehicle()
    if HasTag(vehicle, 'planeVehicle') and not GetBool('level.planeScriptActive') and not hideMessage then

        showMessage = true

        if InputDown('ctrl') and InputDown('c') then
            hideMessage = true -- Hide message on key combo.
        end

    else
        showMessage = false -- Keep messade showing.
    end

end


function draw()

    if showMessage then

        do UiPush()

            w = UiCenter()
            h = UiMiddle()
            local m = 10 -- margin

            UiAlign("top left")
            UiColor(1,0,0,0.5)
            UiTranslate(UiCenter() * 0.75, UiMiddle() * 0.75 - 200)
            UiImageBox("ui/common/box-solid-6.png", w/2 + m, 550 + m, 6, 6)
            UiTranslate(w + m, 32)
            UiColor(1,1,1)
            UiTranslate(-w, 0)
            UiFont("bold.ttf", 24)
            UiAlign("left")

            -- Title
            do UiPush()
                c = oscillate(1)
                UiColor(c+0.5,c+0.5,c+0.5, c+0.5)
                UiText(title)
            UiPop() end
            UiTranslate(0, 32)

            -- Image
            local mult = 3.5
            local imgW = 120
            local imgH = 80
            do UiPush()
                UiAlign("center top")
                UiColor(1,1,1,0.95)
                UiTranslate(imgW*mult/2+(m*2), 0)
                UiImageBox("MOD/prefab/modImage.png", imgW*mult, imgH*mult, 0, 0)
            UiPop() end
            UiTranslate(0, imgH*mult + 48)

            -- Message
            UiFont("bold.ttf", 22)
            UiWordWrap(w/2)
            UiText(message)

            -- Hide
            UiTranslate(0, 112)
            UiWordWrap(w/2)
            UiText(close)

        UiPop() end

    end

end

function oscillate(time)
    local a = (GetTime() / (time or 1)) % 1
    a = a * math.pi
    return math.sin(a)
end