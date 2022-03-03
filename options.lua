#include "script/utility.lua"


function init()

    if GetString('savegame.mod.options.keys.respawn') == '' then
        SetString('savegame.mod.options.keys.respawn', 'y')
    end
    if GetString('savegame.mod.options.keys.smallMapMode') == '' then
        SetString('savegame.mod.options.keys.smallMapMode', 'o')
    end
    if GetString('savegame.mod.options.keys.toggleMissileLock') == '' then
        SetString('savegame.mod.options.keys.toggleMissileLock', 'c')
    end
    if GetString('savegame.mod.options.keys.changeTarget') == '' then
        SetString('savegame.mod.options.keys.changeTarget', 't')
    end

    activeAssignment = false
    activePath = '.'
    lastKeyPressed = '.'

    font_size = 32

end

function tick()

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
            UiTranslate(0, 250)
            local c = oscillate(2)/3 + 2/3
            UiColor(c,c,1,1)
            UiButtonImageBox("ui/common/box-outline-6.png", 10,10)
            UiButtonHoverColor(0.5,0.5,1,1)
            if UiTextButton('Start Demo Map', 350, font_size*2.5) then
                StartLevel('', 'demo.xml', '')
            end

            UiTranslate(0, 100)
            UiColor(1,1,1,1)

            UiTranslate(0, font_size*2.5)
            Ui_Option_Keybind('Respawn', 'savegame.mod.options.keys.respawn')

            UiTranslate(0, font_size*2.5)
            Ui_Option_Keybind('Small-Map Mode', 'savegame.mod.options.keys.smallMapMode')

            UiTranslate(0, font_size*2.5)
            Ui_Option_Keybind('Toggle homing-missiles', 'savegame.mod.options.keys.toggleMissileLock')

            UiTranslate(0, font_size*2.5)
            Ui_Option_Keybind('Change target', 'savegame.mod.options.keys.changeTarget')

        UiPop() end


    UiPop() end


    do UiPush()

        UiTranslate(0, UiHeight() - 100)

        UiAlign('center middle')
        UiButtonImageBox("ui/common/box-outline-6.png", 10,10)
        UiButtonHoverColor(0.5,0.5,1,1)
        if UiTextButton('Close', 150, font_size*2) then
            Menu()
        end

    UiPop() end

end


function Ui_Option_Keybind(label, regPath)

    do UiPush()

        -- Label
        UiFont('regular.ttf', font_size)
        UiAlign('right middle')
        UiTranslate(0, font_size)
        UiText(label)

        -- Bind button
        UiTranslate(font_size, 0)
        UiAlign('left middle')
        UiButtonImageBox("ui/common/box-outline-6.png", 10,10)
        UiButtonHoverColor(0.5,0.5,1,1)
        if UiTextButton(GetString(regPath), font_size*6, font_size*2) then

            if not activeAssignment then
                SetString(regPath, 'Press key...')
                activeAssignment = true
                activePath = regPath
            end

        end

    UiPop() end

end
