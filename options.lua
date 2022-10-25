#include "script/utility.lua"
#include "script/umf.lua"
#include "script/registry.lua"
#include "script.lua"




activeAssignment = false
activePath = '.'
lastKeyPressed = '.'
font_size = 32


function init()

    CheckRegInitialized()

    Init_Config()

end

function tick()

    ManageUiBinding()

    if activeAssignment and InputLastPressedKey() ~= '' then

        SetString(activePath, string.lower(InputLastPressedKey()))
        activeAssignment = false
        activePath = ''

    end

end



function draw()

    UiColor(1,1,1,1)
    UiFont('regular.ttf', font_size)
    UiTranslate(UiCenter(), 0)

    do UiPush()

        -- Title
        do UiPush()
            UiTranslate(0, font_size)
            UiFont('regular.ttf', 64)
            UiAlign('center top')
            UiText('Flying Planes')

            UiTranslate(0, 64)
            UiFont('regular.ttf', 32)
            UiText('By: Cheejins')
        UiPop() end


        -- Button : Start Demo Map
        do UiPush()

            UiAlign('center middle')
            UiFont('regular.ttf', font_size*1.5)
            UiTranslate(0, 190)
            -- local c = oscillate(2)/3 + 2/3
            -- UiColor(c,c,1,1)
            -- UiButtonImageBox("ui/common/box-outline-6.png", 10,10)
            -- UiButtonHoverColor(0.5,0.5,1,1)
            -- if UiTextButton('Start Demo Map', 350, font_size*2.5) then
            --     StartLevel('', 'demo.xml', '')
            -- end

            UiTranslate(0, 80)
            UiColor(1,1,1,1)

            UiTranslate(0, font_size*2.5)
            Ui_Option_Keybind(250, font_size*2, 0, "Change Target", Config.changeTarget, Config, "changeTarget")

            UiTranslate(0, font_size*2.5)
            Ui_Option_Keybind(250, font_size*2, 0, "Toggle Missile Homing", Config.toggleHoming, Config, "toggleHoming")

            UiFont('regular.ttf', 32)
            UiTranslate(0, font_size*3)
            UiText("More keybinds coming soon.")

        UiPop() end


    UiPop() end


    do UiPush()

        UiTranslate(0, UiHeight() - 150)

        UiAlign('center middle')
        UiButtonImageBox('ui/common/box-outline-6.png', 10,10, 1, 1, 1, 1)
        if UiTextButton('Reset', 150, font_size*2) then
            ClearKey("savegame.mod")
        end

        UiTranslate(0, font_size*2.5)

        UiButtonImageBox("ui/common/box-outline-6.png", 10,10)
        UiButtonHoverColor(0.5,0.5,1,1)
        if UiTextButton('Close', 150, font_size*2) then
            Menu()
        end


    UiPop() end

end


-- function Ui_Option_Keybind(label, regPath)

--     do UiPush()

--         -- Label
--         UiFont('regular.ttf', font_size)
--         UiAlign('right middle')
--         UiTranslate(0, font_size)
--         UiText(label)

--         -- Bind button
--         UiTranslate(font_size, 0)
--         UiAlign('left middle')
--         UiButtonImageBox("ui/common/box-outline-6.png", 10,10)
--         UiButtonHoverColor(0.5,0.5,1,1)
--         if UiTextButton(GetString(regPath), font_size*6, font_size*2) then

--             if not activeAssignment then
--                 SetString(regPath, 'Press key...')
--                 activeAssignment = true
--                 activePath = regPath
--             end

--         end

--     UiPop() end

-- end


function ui_createToggleSwitch(title, registryPath)

    do UiPush()

        local value = GetBool(registryPath)

        UiAlign('right middle')

        -- Text header
        UiColor(1,1,1, 1)
        UiFont('regular.ttf', font_size)
        UiText(title)
        UiTranslate(font_size, -font_size/2)


        -- Toggle BG
        UiAlign('left top')
        UiColor(0.4,0.4,0.4, 1)
        local tglW = 130
        local tglH = 40
        UiRect(tglW, tglH)

        -- Render toggle
        do UiPush()

            local toggleText = 'ON'

            if value then
                UiTranslate(tglW/2, 0)
                UiColor(0,0.8,0, 1)
            else
                toggleText = 'OFF'
                UiColor(0.8,0,0, 1)
            end

            UiRect(tglW/2, tglH)

            do UiPush()
                UiTranslate(tglW/4, tglH/2)
                UiColor(1,1,1, 1)
                UiFont('bold.ttf', font_size)
                UiAlign('center middle')
                UiText(toggleText)
            UiPop() end

        UiPop() end

        UiButtonImageBox('ui/common/box-outline-6.png', 10,10, 0,0,0, a)
        if UiBlankButton(tglW, tglH) then
            SetBool(registryPath, not value)
            PlaySound(LoadSound('clickdown.ogg'), GetCameraTransform().pos, 1)
        end

    UiPop() end

end

