#include "script.lua"


function init()

    OPTIONS = true

    InitKeys()
    initUiControlPanel()

    TB = {name = 'text'}

end

function tick()

end

function draw()

    uiSetFont(24)
    UiButtonHoverColor(0.5,0.5,1, 1)


    local itemH = 35
    local col = {
        {'',            itemH + 20},
        {'',            180},
        {'Combo Key',   180},
        {'Main Key',    180},
    }
    local function colVal(index)
        return col[index][2]
    end

    local keybindsW = 0
    for index, value in ipairs(col) do
        keybindsW = keybindsW + value[2]
    end


    do UiPush()

        -- Title.
        UiAlign('left top')
        uiSetFont(50)

        margin(0, 50)
        do UiPush()
            margin(UiCenter(), 0)
            UiAlign('center middle')
            UiText('Advanced Camera - Options')
        UiPop() end


        -- Table headers.
        uiSetFont(24)
        margin(UiCenter() - keybindsW/2, 100)
        do UiPush()
            for index, value in ipairs(col) do
                UiText(string.upper(value[1]))
                margin(value[2], 0)
            end
        UiPop() end


        -- Draw keybind list.
        margin(0, 50)
        for index, value in ipairs(UiControls) do

            local key = UiControls[index].name

            for k, v in pairs(KEYS) do
                if k == key then
                    do UiPush()

                        UiImageBox(UiControls[index].icon, itemH, itemH, 0,0) -- Icon
                        margin(colVal(1), 0)

                        UiText(v.title)
                        margin(colVal(2), 0)

                        Ui_Option_Keybind_Combo(180, itemH, 200, v.title, convertKeyTitle(v.key1), v, 'key1') -- Combo key
                        margin(colVal(3), 0)

                        Ui_Option_Keybind(180, itemH, 200, ' ', convertKeyTitle(v.key2), v, 'key2') -- Key
                        margin(colVal(4), 0)

                    UiPop() end

                    margin(0, itemH * 1.5)
                end
            end

        end

        UiAlign('center middle')
        margin(keybindsW/2, 50)

        UiButtonImageBox('ui/common/box-outline-6.png', 10,10, 1,1,1, 1)
        if UiTextButton('Reset Keybinds', 300, 40) then

            ClearKey("savegame.mod.keys")
            InitKeys()

        end

    UiPop() end


    -- Close button.
    do UiPush()

        uiSetFont(36)
        UiAlign('center middle')
        margin(UiCenter(), UiHeight() - 100)

        UiButtonImageBox('ui/common/box-outline-6.png', 10,10, 1,1,1, 1)
        if UiTextButton('Close', 120, 50) then
            Menu()
        end

    UiPop() end

end
