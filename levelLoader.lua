#include "script.lua"

function init()

    CheckRegInitialized()

    Init_Config()

    if GetBool('savegame.mod.debugMode') then
        if GetBool('savegame.mod.testMap') then
            StartLevel('', 'test.xml', '')
        else
            StartLevel('', 'demo.xml', '')
        end
    end

    ui = {

        text = {
            size = {
                s = 12,
                m = 24,
                l = 48,
            },
        },

        container = {
            width = 1440,
            height = 240,
            margin = 240,
        },

        padding = {
            container = {
                width = UiWidth() * 0.2,
                height = UiHeight() * 0.1,
            },
        },

        bgColor = 0.12,
        fgColor = 0.4,
    }

end

function tick()

    if InputPressed("g") then
        ClearKey("savegame.mod")
        print("Reset reg level loader...")
    end

    if GetBool('savegame.mod.debugMode') then
        if GetBool('savegame.mod.testMap') then
            StartLevel('', 'test.xml', '')
        else
            StartLevel('', 'demo.xml', '')
        end
    end

    FlightMode = GetString("savegame.mod.FlightMode")
    FlightModeSet = GetBool("savegame.mod.flightmodeset")

end


function draw()

    UiColor(0,0,0,1)
    UiRect(UiWidth(), UiHeight())
    UiMakeInteractive()

    do UiPush()
        UiTranslate(UiCenter(), 50)

        UiColor(1, 1, 1)
        UiFont("regular.ttf", 50)

        -- Title
        UiAlign("center middle")
        UiFont("bold.ttf", ui.text.size.m * 2)
        UiText("Flying Planes + New Aerodynamics")

    UiPop() end


    if not FlightModeSet then
        draw_flightModeSelection()
    else
        draw_levelSelection()
    end

end



function draw_flightModeSelection()

    do UiPush()

        local c = 1
        UiColor(c,1,c,1)
        UiFont("regular.ttf",  48)
        UiAlign('center middle')


        UiTranslate(UiCenter(), UiMiddle()/2)
        UiText("Choose flight mode")

        UiTranslate(-275, 0)
        do UiPush()
            UiButtonHoverColor(0.5,0.5,0.5, 1)
            UiTranslate(0, 150)
            UiText("Simple")
            UiTranslate(0, 100)
            UiWordWrap(400)
            UiFont("regular.ttf",  24)
            UiText("Easy arcade style flight. Aim in the direction you would like to fly.")

            UiButtonImageBox("ui/common/box-outline-6.png", 10,10)
            if UiTextButton(' ', 500, 300) then
                SetString("savegame.mod.FlightMode", "simple")
                SetBool("savegame.mod.flightmodeset", true)
                print("level loader: simple")
            end
        UiPop() end

        UiTranslate(550, 0)
        do UiPush()
            UiButtonHoverColor(0.5,0.5,0.5, 1)
            UiTranslate(0, 150)
            UiText("Simulation")
            UiTranslate(0, 100)
            UiWordWrap(400)
            UiFont("regular.ttf",  24)
            UiText("Fly with realistic aerodynamics. Control pitch, roll and yaw manually.")

            UiButtonImageBox("ui/common/box-outline-6.png", 10,10)
            if UiTextButton(' ', 500, 300) then
                SetString("savegame.mod.FlightMode", "simulation")
                SetBool("savegame.mod.flightmodeset", true)
                print("level loader: simulation")
            end

        UiPop() end


    UiPop() end

end


function draw_levelSelection()

    -- Demo map
    do UiPush()
        UiTranslate(UiCenter(), UiMiddle())

        local c = 1
        UiColor(c,1,c,1)
        UiFont("regular.ttf",  48)
        UiAlign('center middle')

        UiTranslate(-350, 0)
        do UiPush()
            UiButtonImageBox("MOD/img/levels/sandbox.png", 10,10)
            UiButtonHoverColor(0.5,0.5,0.5, 1)
            if UiTextButton(' ', 600, 400) then
                StartLevel('', 'MOD/sandbox.xml', '')
            end
            UiTranslate(0, 250)
            UiText("Sandbox Map + Enemy AI")
            UiFont("regular.ttf",  22)
            UiTranslate(0, 30)
            UiTranslate(0, 30)
            UiColor(1/2,1/2,1/2,1)
            UiText("Press 'N' to enable/disable enemy ground AA.")
            UiTranslate(0, 30)
            UiTranslate(0, 30)
            UiText("AI planes fly from target to target.")
            UiTranslate(0, 30)
            UiText("They do not chase the player or shoot yet.")
        UiPop() end

        UiTranslate(700, 0)
        do UiPush()
            UiButtonImageBox("MOD/img/levels/airfield.png", 10,10)
            UiButtonHoverColor(0.5,0.5,0.5, 1)
            if UiTextButton(' ', 600, 400) then
                StartLevel('', 'MOD/demo.xml', '')
            end
            UiTranslate(0, 250)
            UiText("Keltoi Airfield")

        UiPop() end


    UiPop() end

end