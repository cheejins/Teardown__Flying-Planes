#include "script.lua"
#include "script/input/keybinds.lua"


function init()

    OPTIONS = true

    if not GetBool("savegame.mod.bindsSet") then

        InitKeys()
        SetBool("savegame.mod.bindsSet", true)

        print("Binds initialized")

    else

        KEYS = util.shared_table("savegame.mod.keys", Keys)

        print("Binds loaded")

    end

    FS = 24

end

function tick()
    if ManageUiBinding() then
        -- InitKeys()
    end
end

function draw()

    uiSetFont(FS)
    UiButtonHoverColor(0.5,0.5,1, 1)

    UiHeader(50)
    UIResetBinds(75)

    -- UIDrawKeybinds()

    UICloseButton()

end


function UIDrawKeybinds()
    do UiPush()

        margin(UiCenter(), 150)

        for key, category in pairs(Keys) do

            do UiPush()
                uiSetFont(FS * 1.25)
                UiAlign("center middle")
                UiText(key)
            UiPop() end

            margin(0, FS * 1.75)

            for bindKey, bindData in ipairs(category) do

                UiAlign("right middle")
                UiText(bindData.title)

                UiAlign("left middle")

                do UiPush()
                    margin(FS, -15)
                    Ui_Option_Keybind(180, 30, 0, "",  Keys[key][bindKey].key, KEYS[key][bindKey], "key")
                    print(KEYS[key][bindKey]["key"])
                UiPop() end

                margin(0, FS + 4)

            end

            margin(0, FS)

        end

        margin(0, FS * 1.75)


    UiPop() end
end


function UiHeader(marginY)
    margin(0, marginY)
    do UiPush()

        -- Title.
        UiAlign('left top')
        uiSetFont(50)

        do UiPush()
            margin(UiCenter(), 0)
            UiAlign('center middle')
            UiText('Flying Planes - Options')
        UiPop() end

    UiPop() end
end

function UICloseButton()
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

function UIResetBinds(marginY)
    do UiPush()

        -- Draw keybind list.
        margin(UiCenter(), marginY)
        UiAlign('center middle')
        UiButtonImageBox('ui/common/box-outline-6.png', 10,10, 1,1,1, 1)
        if UiTextButton('Reset Keybinds', 300, 40) then

            ClearKey("savegame.mod.bindsSet")
            ClearKey("savegame.mod.keys")

            print("reset binds")

        end

    UiPop() end
end