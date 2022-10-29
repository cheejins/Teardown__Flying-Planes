FlightModes = {
    simple = "simple",
    simulation = "simulation",
}


function DrawIngameOptions()

    UiMakeInteractive()

    UiFont("regular.ttf", 24)
    UiColor(1,1,1, 1)
    UiTextShadow(0,0,0, 1, 0.2)

    local w = UiCenter()
    local h = UiMiddle() + 100
    local w_center = w/2
    local btn_w = 250
    local marginY = 20
    local marginY2 = marginY*1.5



    margin(UiCenter()/2, UiMiddle()/2 - 100)
    UiPush()
        UiColor(0,0,0, 0.8)
        UiAlign("left top")
        UiRect(w, h)
    UiPop()


    -- Title
    margin(w_center, 0)
    UiPush()
        margin(0, -marginY)
        UiFont("regular.ttf", 48)
        UiAlign("center bottom")
        UiText("Options")
    UiPop()


    -- Close button
    UiPush()

        margin(0, h+marginY)

        UiAlign('center top')
        UiButtonImageBox('ui/common/box-outline-6.png', 10,10, 1, 1, 1, 1)
        if UiTextButton('Close', btn_w, marginY2*1.5) then
            ShouldDrawIngameOptions = false
        end

        margin(0, marginY2)
        margin(0, marginY2)
        UiButtonImageBox('ui/common/box-outline-6.png', 10,10, 1, 1, 1, 1)
        if UiTextButton('Reset', btn_w, marginY2*1.5) then
            ClearKey("savegame.mod")
        end

    UiPop()

    margin(0, marginY2)

    UiPush()
        UiFont("regular.ttf", 32)
        UiAlign("center top")
        UiText("Flight Mode")
    UiPop()

    margin(0, marginY2*2)

    UiPush()
        local c = boolColor(FlightMode == FlightModes.simulation)
        UiColor(c[1], c[2], c[3])
        margin(btn_w/2, 0)
        UiAlign('center middle')
        UiButtonImageBox('ui/common/box-outline-6.png', 10,10, c[1], c[2], c[3], 1)
        if UiTextButton('Simulation', btn_w, marginY2*1.5) then
            SetString("savegame.mod.FlightMode", FlightModes.simulation)
        end
    UiPop()

    UiPush()
        local c = boolColor(FlightMode == FlightModes.simple)
        UiColor(c[1], c[2], c[3])
        margin(-btn_w/2, 0)
        UiAlign('center middle')
        UiButtonImageBox('ui/common/box-outline-6.png', 10,10, c[1], c[2], c[3], 1)
        if UiTextButton('Simple', btn_w, marginY2*1.5) then
            SetString("savegame.mod.FlightMode", FlightModes.simple)
        end
    UiPop()

    margin(0, marginY2)
    if FlightMode == FlightModes.simple then

        UiPush()
            UiColor(0.5,0.5,0.5, 1)
            UiFont("regular.ttf", 24)
            UiAlign("center top")
            UiText("Fly in the direction you're looking.")
        UiPop()

    elseif FlightMode == FlightModes.simulation then

        UiPush()
            UiColor(0.5,0.5,0.5, 1)
            UiFont("regular.ttf", 24)
            UiAlign("center top")
            UiText("Realistic aerodynamics (work in progress, may contain bugs)")
        UiPop()

    end


    margin(0, marginY2*2)
    margin(0, marginY2*2)

    UiPush()
        local c = boolColor(Config.debug)
        UiColor(c[1], c[2], c[3])
        UiAlign('center middle')
        UiButtonImageBox('ui/common/box-outline-6.png', 10,10, c[1], c[2], c[3], 1)
        if UiTextButton('Debug Mode', btn_w, marginY2*1.5) then
            Config.debug = not Config.debug
        end
    UiPop()

    margin(0, marginY2*2)

    UiPush()
        local c = boolColor(Config.showOptions)
        UiColor(c[1], c[2], c[3])
        UiAlign('center middle')
        UiButtonImageBox('ui/common/box-outline-6.png', 10,10, c[1], c[2], c[3], 1)
        if UiTextButton('Show Controls', btn_w, marginY2*1.5) then
            Config.showOptions = not Config.showOptions
        end
    UiPop()

    margin(0, marginY2*2)

    UiPush()
        local c = boolColor(Config.spawn_aiplanes)
        UiColor(c[1], c[2], c[3])
        UiAlign('center middle')
        UiButtonImageBox('ui/common/box-outline-6.png', 10,10, c[1], c[2], c[3], 1)
        if UiTextButton('Spawn AI Planes', btn_w, marginY2*1.5) then
            Config.spawn_aiplanes = not Config.spawn_aiplanes
        end
    UiPop()

    margin(0, marginY2*2)

    UiPush()
        local c = boolColor(Config.unbreakable_planes)
        UiColor(c[1], c[2], c[3])
        UiAlign('center middle')
        UiButtonImageBox('ui/common/box-outline-6.png', 10,10, c[1], c[2], c[3], 1)
        if UiTextButton('Unbreakable Planes', btn_w, marginY2*1.5) then
            Config.unbreakable_planes = not Config.unbreakable_planes
        end
    UiPop()

    margin(0, marginY2*2)

    UiPush()
        local c = boolColor(Config.sounds_stall_warning)
        UiColor(c[1], c[2], c[3])
        UiAlign('center middle')
        UiButtonImageBox('ui/common/box-outline-6.png', 10,10, c[1], c[2], c[3], 1)
        if UiTextButton('Stall Warning Sound', btn_w, marginY2*1.5) then
            Config.sounds_stall_warning = not Config.sounds_stall_warning
        end
    UiPop()

    margin(0, marginY2*2)

    if FlightMode == FlightModes.simple then
        UiPush()
            local c = boolColor(Config.smallMapMode)
            UiColor(c[1], c[2], c[3])
            UiAlign('center middle')
            UiButtonImageBox('ui/common/box-outline-6.png', 10,10, c[1], c[2], c[3], 1)
            if UiTextButton('Small Map Mode', btn_w, marginY2*1.5) then
                Config.smallMapMode = not Config.smallMapMode
            end
        UiPop()
    end

UiPop()

end

function boolColor(bool)
    if bool then
        return Vec(0,1,0)
    else
        return Vec(0.5,0.5,0.5)
    end
end