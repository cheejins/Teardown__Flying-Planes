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
                s = 24,
                m = 48,
                l = 64,
            },
        },
    }

    Pad = 10
    Pad2 = Pad*2

end

function tick()

    -- if InputPressed("g") then
    --     ClearKey("savegame.mod")
    --     print("Reset reg level loader...")
    -- end

    if GetBool('savegame.mod.debugMode') then
        if GetBool('savegame.mod.testMap') then
            StartLevel('', 'test.xml', '')
        else
            StartLevel('', 'demo.xml', '')
        end
    end

    FlightMode = GetString("savegame.mod.FlightMode")
    FlightModeSet = GetBool("savegame.mod.flightmodeset")

    if InputPressed("pause") then
        Menu()
    end

end


function draw()

    UiColor(0.7,0.7,0.7,1)
    UiRect(UiWidth(), UiHeight())
    UiMakeInteractive()

    uiSetFont(ui.text.size.m)

    draw_mainmenu_banner()

    if not FlightModeSet then
        draw_flightModeSelection()
    else
        draw_levelSelection()
    end

end


function draw_mainmenu_banner(w, h)
    UiPush()

        h = h or ui.text.size.l * 2
        w = w or UiWidth()

        -- BG
        UiAlign("top left")
        UiColor(0, 0, 0, 0.8)
        UiRect(w, h + Pad2)

        -- Thumbnail
        UiTranslate(Pad, Pad)
        UiColor(1, 1, 1, 1)
        UiImageBox("MOD/img/Preview.png", h,h, 0,0)
        UiTranslate(h+ Pad, 0)


        uiSetFont(ui.text.size.l)
        UiText("Flying Planes")

        UiTranslate(0, ui.text.size.l)
        uiSetFont(ui.text.size.m)
        UiText("By: Cheejins")

    UiPop()
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
            UiAlign("center middle")
            UiText("Easy arcade style flight but less realistic. Aim in the direction you would like to fly.")

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
            UiAlign("center middle")
            UiText("Fly with realistic aerodynamics. Control pitch, roll and yaw manually. A bit harder but more fun.")

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
        UiColor(0,0,0,1)
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
            UiText("Sandbox Map + Enemy Ground AA")
            UiFont("regular.ttf",  22)
            UiTranslate(0, 30)
            -- UiTranslate(0, 30)
            -- UiColor(1/2,1/2,1/2,1)
            -- UiText("Press 'M' to enable/disable enemy ground AA.")
            -- UiTranslate(0, 30)
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
