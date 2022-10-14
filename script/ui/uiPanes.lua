function ui_Panes()

    local paneWidths = {0.25, 0.45, 0.3}

    local fs_title = 32

    local marginControlPanelY = 200
    local paneAH = UiHeight() - marginControlPanelY
    local paneBH = 130

    local mouseInUi = false

    UiAlign('left top')
    UiColor(0,0,0, 0.82)

    -- Draw main UI
    if UI_SHOW_OPTIONS then

        UiMakeInteractive()

        do UiPush()

            -- PANE 1
            do UiPush()

                UiButtonHoverColor(0.5, 0.5, 1, 1)

                margin(pad, pad)
                UiImageBox('ui/common/box-solid-6.png', UiWidth() * paneWidths[1] - pad2, paneAH - pad2, 10,10)
                mouseInUi = mouseInUi or UiIsMouseInRect(UiWidth() * paneWidths[1] - pad2, paneAH - pad2)
                UiWindow(UiWidth() * paneWidths[1] - pad2, paneAH - pad2, true)

                UiColor(1,1,1, 0.8)
                do UiPush()
                    UiAlign('center top')
                    UiFont('regular.ttf', fs_title)
                    margin(UiCenter(), pad)
                    UiText('PRESETS')
                UiPop() end
                margin(pad/2,70)

                UiWindow(UiWidth() - pad, paneAH - 120)
                drawPresetCanvas(UiWidth(), UiHeight(), 50)

            UiPop() end
            margin(UiWidth() * paneWidths[1], 0)


            -- PANE 2
            do UiPush()

                do UiPush()
                    margin(pad, pad)
                    UiImageBox('ui/common/box-solid-6.png', UiWidth() * paneWidths[2] - pad2, paneAH - pad2, 10,10)
                    mouseInUi = mouseInUi or UiIsMouseInRect(UiWidth() * paneWidths[2] - pad2, paneAH - pad2)
                    UiWindow(UiWidth() * paneWidths[2] - pad2, paneAH - pad2, true)

                    UiColor(1,1,1, 0.8)
                    do UiPush()
                        UiAlign('center top')
                        UiFont('regular.ttf', fs_title)
                        margin(UiCenter(), pad)
                        UiText('ITEM CHAIN')
                    UiPop() end
                    margin(pad/2,70)

                    if UiIsMouseInRect(UiWidth(), UiHeight()) then
                        scrolly = scrolly + (InputValue('mousewheel') * -30)
                        scrolly = clamp(scrolly, 0, #ITEM_CHAIN * 40)
                    end

                    UiColor(0,0,0, 1)
                    UiWindow(UiWidth(), UiHeight() - 100, true)
                    margin(0, -scrolly)
                    drawItemListMenu()
                UiPop() end

            UiPop() end
            margin(UiWidth() * paneWidths[2], 0)


            -- PANE 3
            do UiPush()

                margin(pad, pad)
                UiImageBox('ui/common/box-solid-6.png', UiWidth() * paneWidths[3] - pad2, paneAH - pad2, 10,10)
                mouseInUi = mouseInUi or UiIsMouseInRect(UiWidth() * paneWidths[3] - pad2, paneAH - pad2)
                UiWindow(UiWidth() * paneWidths[3] - pad2, paneAH - pad2, true)
                UiWindow(UiWidth() - pad/2, UiHeight() - pad, true)

                UiColor(1,1,1, 0.8)
                do UiPush()
                    UiAlign('center top')
                    UiFont('regular.ttf', fs_title)
                    margin(UiCenter(), pad)
                    UiText('MODIFY ITEM')
                UiPop() end
                margin(pad/2,70)

                if #ITEM_CHAIN >= 1 then
                    local item = ITEM_CHAIN[UI_SELECTED_ITEM] or ITEM_CHAIN[1]
                    uiMod_Item(item)
                end

            UiPop() end

        UiPop() end

    end


    -- Draw control panel.
    if UI_SHOW_OPTIONS or UI_PIN_CONTROL_PANEL then
        do UiPush()

            -- PANE 2B
            do UiPush()

                local w = UiWidth()/1.25

                margin(UiCenter() - w/2, paneAH + pad)
                UiWindow(w + pad2, paneBH, true)
                mouseInUi = mouseInUi or UiIsMouseInRect(UiWidth(), paneBH)

                uiDrawControlPanel(UiWidth()-pad2, paneBH/2, paneBH)

            UiPop() end

        end UiPop()
    end


    -- Close UI if mouse is clicked off of a panel.
    if InputPressed('lmb') and UI_SHOW_OPTIONS and not mouseInUi then
        UI_SHOW_OPTIONS = not UI_SHOW_OPTIONS
    end

end