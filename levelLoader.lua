function init()

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
    if GetBool('savegame.mod.debugMode') then
        if GetBool('savegame.mod.testMap') then
            StartLevel('', 'test.xml', '')
        else
            StartLevel('', 'demo.xml', '')
        end
    end
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
        UiText("Flying Planes 3.0 TEST (New Aerodynamics)")

    UiPop() end


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
                StartLevel('', 'MOD/test.xml', '')
            end
            UiTranslate(0, 250)
            UiText("Sandbox Map + Enemy AA")
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