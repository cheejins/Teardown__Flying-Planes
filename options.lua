#include "script/utility.lua"

function init()

    activeAssignment = false
    activePath = '.'
    lastKeyPressed = '.'

    font_size = 32

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


        do UiPush()

            UiTranslate(0, 200)
            UiAlign('center middle')
            UiFont('regular.ttf', font_size*1.5)


            -- Spawning warning
            if not HasVersion("0.9.3") then

                UiTranslate(0, 100)
                UiColor(1,0,0,1)
                UiAlign('center middle')
                UiFont('regular.ttf', font_size)
                UiTranslate(0, font_size*2)

                UiText('Spawning unavailable!')
                UiTranslate(0, font_size*1.5)
                UiText('Please switch to the Teardown experimental beta in Steam to enable spawning.')

            end

            -- Demo map
            UiTranslate(0, 100)
            local c = oscillate(2)/3 + 2/3
            UiColor(c,c,1,1)
            UiButtonImageBox("ui/common/box-outline-6.png", 10,10)
            UiButtonHoverColor(0.5,0.5,1,1)
            if UiTextButton('Start Demo Map', 350, font_size*2.5) then
                StartLevel('', 'demo.xml', '')
            end

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

