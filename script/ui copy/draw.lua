pad = 20
pad2 = 40

--- Manages the whole UI.
function drawUi()

    UiAlign('center middle')
    UiFont('bold.ttf', 20)
    UiColor(0,0,0,1)


    if DRAW_CAMERAS then
        drawCameras()
    end

    -- Is wielding tool
    if UI_SHOW_DETAILS then

        do UiPush()

            margin(200, 10)
            drawItemChain()

            margin(500, 0)
            -- drawItemObjects()

            margin(400, 0)
            drawCameraList()

            margin(400, 0)
            drawEventList()

            -- drawItemChain()

        UiPop() end

    end

    -- Main UI
    ui_Panes()

    do UiPush()
        -- Update component properties.
        uiSetFont(48)
        if UI_SET_CAMERA then
            ui_Mod_Camera_Set(getUiSelectedItem())
        elseif UI_SET_CAMERA_SHAPE then
            ui_Mod_Camera_SetShape(getUiSelectedItem())
        end
    UiPop() end

    -- local videoDesc = '(Mod has not been released yet)\n\nThe mod now features a UI control panel which lets the user control the mod through buttons and keybinds. The keybinds for the mod can be easily configured with combo keys such as CTRL+C, SHIFT+C and so on.'
    -- drawVideoDesc(videoDesc)

end

function drawCameras()
    do UiPush()

        for key, cam in pairs(CAMERA_OBJECTS) do

            local item = getItemByCameraId(cam.id)
            local camItemIndex = getItemIndex(ITEM_CHAIN, getItemByCameraId(cam.id))

            local isSelectedCamera = cam.id == SELECTED_CAMERA
            local isSelectedItem = item == ITEM_CHAIN[UI_SELECTED_ITEM]

            -- Selected item alpha flashes.
            local a = ternary(isSelectedItem, osc, 1)


            local fs = 25 -- Font size.
            UiFont('bold.ttf', fs)


            -- Line from camera to camera target.
            DebugLine(cam.viewTr.pos, TransformToParentPoint(cam.viewTr, Vec(0,0,-5)), 1,1,1, a)

            -- Line from camera to camera target.
            if cam.shape then
                DebugLine(cam.tr.pos, AabbGetShapeCenterPos(cam.shape), 1,1,1, a)
            end

            -- If the camera is infront of the player cam.
            if TransformToLocalPoint(GetCameraTransform(), cam.viewTr.pos)[3] < 0 then

                -- Draw camera direction dot.
                do UiPush()
                    local pos = TransformToParentPoint(cam.viewTr, Vec(0,0,-5))
                    local x,y = UiWorldToPixel(pos)
                    margin(x,y)

                    UiColor(0,0,0, a)
                    UiImageBox('ui/hud/dot-small.png', 35,35, 0,0)

                    UiColor(1,1,1, a)
                    UiImageBox('ui/hud/dot-small.png', 32,32, 0,0)
                UiPop() end

                -- Draw camera viewTr icon.
                do UiPush()
                    local pos = cam.viewTr.pos
                    local x,y = UiWorldToPixel(pos)
                    margin(x,y)

                    UiColor(0,0,0, a)
                    UiImageBox('MOD/img/icon_camera_frame.png', 45,45, 0,0)

                    UiColor(1,1,1, a)
                    UiImageBox('MOD/img/icon_camera_frame.png', 42,42, 0,0)
                UiPop() end

            end

            -- If the camera is infront of the player cam.
            if TransformToLocalPoint(GetCameraTransform(), cam.tr.pos)[3] < 0 then

                -- Draw camera tr icon
                do UiPush()
                    local pos = cam.tr.pos
                    local x,y = UiWorldToPixel(pos)
                    margin(x,y)

                    UiColor(0,0,0, a)
                    UiImageBox('MOD/img/icon_camera_classic.png', 45,45, 0,0)

                    UiColor(0.4,0.4,0.4, 1)
                    if isSelectedCamera then

                        UiColor(0,0,1, 1)

                        if isSelectedItem then
                            UiColor(0,0,1, a)
                        end

                    elseif isSelectedItem then
                        UiColor(1,1,1, a)
                    end

                    UiImageBox('MOD/img/icon_camera_classic.png', 40,40, 0,0)
                UiPop() end

                -- Draw camera number
                do UiPush()
                    local x,y = UiWorldToPixel(cam.tr.pos)
                    margin(x,y-35)

                    UiColor(0,0,0, 0.5)
                    UiRect(fs, fs)

                    UiColor(1,1,1, 1)
                    UiText(camItemIndex)
                UiPop() end

            end


        end
    UiPop() end
end
