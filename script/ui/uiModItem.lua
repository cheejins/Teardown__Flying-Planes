--- Modify item pane.
function uiMod_Item(item)

    do UiPush()

        UiFont('regular.ttf', 28)
        UiAlign('left top')


        if item.type ~= 'uninitialized' then

            do UiPush()
                UiText('Item: ')
                margin(100, 0)
                UiText(tostring(item.type))
            UiPop() end
            margin(0, 32)

            do UiPush()
                UiText('Type: ')
                margin(100, 0)
                UiText(tostring(item.item.type))
            UiPop() end
            margin(0, 32)

            do UiPush()
                UiText('Name: ')
                margin(100, 0)
                if uiTextField(300, 32, item.item, 'name') then
                    print('replaced def')
                    cam_replaceDef(item.item)
                end
            UiPop() end
            margin(0, 32)
        end

    UiPop() end


    margin(0, 32)
    margin(0, 32)
    margin(0, 32)
    margin(0, 32)


    if item.type == 'uninitialized' then

        uiMod_UninitializedItem(ITEM_CHAIN, UI_SELECTED_ITEM)

    elseif item.type == 'camera' then

        ui_Mod_Camera(item)

    elseif item.type == 'event' then

        ui_Mod_Event(item)

    end

end

-- Draw buttons that convert uninitialized item into
function uiMod_UninitializedItem(tb, index)
    do UiPush()

        local fs = 24
        local btnW = UiCenter()
        local btnH = 80

        itemType = nil
        itemSubType = nil

        UiFont('regular.ttf', fs)
        UiAlign('left top')

        do UiPush()
            margin(UiCenter(), fs*3)
            UiAlign('center top')
            UiFont('regular.ttf', fs*1.25)
            UiText('Select an item to create...')
        UiPop() end


        margin(0, fs*4)
        do UiPush()
            margin(0, fs)
            UiText('Cameras:')

            UiColor(0,0,0, 1)

            do UiPush()
                margin(pad/4, fs*1.5)
                UiButtonImageBox('ui/common/box-solid-6.png', 10,10, 1,1,1, 1)
                if UiTextButton('Camera', btnW - pad, btnH - pad) then
                    itemType = 'camera'
                    itemSubType = 'static'
                end
            UiPop() end


        UiPop() end


        margin(0, fs*2 + btnH*2)
        do UiPush()

            margin(0, fs*1.5)
            UiText('Event:')

            UiColor(0,0,0, 1)


            margin(pad/4, fs*1.5)
            do UiPush()
                UiButtonImageBox('ui/common/box-solid-6.png', 10,10, 1,1,1, 1)
                if UiTextButton('Wait', btnW - pad, btnH - pad) then
                    itemType = 'event'
                    itemSubType = 'wait'
                end
            UiPop() end


            margin(0, fs*3)
            do UiPush()
                UiButtonImageBox('ui/common/box-solid-6.png', 10,10, 1,1,1, 1)
                if UiTextButton('Lerp Timed', btnW - pad, btnH - pad) then
                    itemType = 'event'
                    itemSubType = 'lerpTimed'
                end
                margin(btnW, 0)
                UiButtonImageBox('ui/common/box-solid-6.png', 10,10, 1,1,1, 1)
                if UiTextButton('Lerp Const', btnW - pad, btnH - pad) then
                    itemType = 'event'
                    itemSubType = 'lerpConst'
                end
            UiPop() end

        UiPop() end


        -- Convert uninitialized item into valid item.
        if itemType then
            convertUninitializedItem(tb, index, itemType, itemSubType)
            validateItemChain()
        end

    UiPop() end
end

-- Draw event modification buttons and sliders.
function ui_Mod_Event(item)
    do UiPush()

        UiColor(0,0,0,1)

        UiFont('regular.ttf', 36)

        if item.item.type == 'lerpTimed' or item.item.type == 'wait' then

            if createSlider('Time', item.item.val, 'time', 's', 0, 120, UiWidth() - 200, 10, 24) then
                event_replaceDef(item.item)
            end
            UiTranslate(0, 50)

        elseif item.item.type == 'lerpConst' then

            if createSlider('Speed', item.item.val, 'speed', 'm/s', 0, 2, UiWidth() - 200, 10, 24) then
                event_replaceDef(item.item)
            end
            UiTranslate(0, 50)

        end

    UiPop() end
end

-- Draw item modification buttons.
function ui_Mod_Camera(item)
    do UiPush()

        local btnW = UiWidth()/3
        local btnWPad = btnW - pad

        UiFont('regular.ttf', 20)
        UiColor(0,0,0,1)

        UiButtonImageBox('ui/common/box-solid-6.png', 10,10, 1,1,1, 1)
        if UiTextButton('Set Camera View', btnWPad, 50) then
            UI_SET_CAMERA = true
        end
        UiTranslate(btnW, 0)


        if item.item.shape then
            UiButtonImageBox('ui/common/box-solid-6.png', 10,10, 0,1,0, 1)
        else
            UiButtonImageBox('ui/common/box-solid-6.png', 10,10, 1,1,1, 1)
        end


        if UiTextButton('Set Object', btnWPad, 50) then
            UI_SET_CAMERA_SHAPE = true
        end
        UiTranslate(btnW, 0)


        if item.item.shape then
            UiButtonImageBox('ui/common/box-solid-6.png', 10,10, 1,0,0, 1)
        else
            UiButtonImageBox('ui/common/box-solid-6.png', 10,10, 1,1,1, 1)
        end
        if UiTextButton('Remove Object', btnWPad, 50) then
            item.item.shape = nil
        end
        UiTranslate(btnW, 0)


    UiPop() end
end

-- Set the camera's viewTr.
function ui_Mod_Camera_Set(item)
    do UiPush()

        setTool()

        uiShowMessage({
            'Left click to set camera position.',
            'Right click to cancel.'
        })


        if InputPressed('lmb') then

            local cam = item.item

            cam.tr = GetCameraTransform()
            cam.viewTr = TransformCopy(cam.tr)

            if cam.shape then
                setCameraRelativeShape(cam, cam.shape)
            end

            cam_replaceDef(item.item)

            UI_SHOW_OPTIONS = true
            UI_SET_CAMERA = false

        elseif InputPressed('rmb') then

            UI_SHOW_OPTIONS = true
            UI_SET_CAMERA = false

        else

            UI_SHOW_OPTIONS = false

        end

    UiPop() end
end

-- Set the camera's shape
function ui_Mod_Camera_SetShape(item)
    do UiPush()

        setTool()

        uiShowMessage({
            'Left click to set object.',
            'Right click to cancel.'
        })

        local h, p, s = RaycastFromTransform(GetCameraTransform(), 400)
        if h then
            drawShape(s)
        end

        if h and InputPressed('lmb') then

            local cam = item.item

            cam.shape = s
            setCameraRelativeShape(cam, s)

            cam.viewTr = TransformCopy(cam.tr)
            cam_replaceDef(cam)

            UI_SHOW_OPTIONS = true
            UI_SET_CAMERA_SHAPE = false

        elseif InputPressed('rmb') then

            UI_SHOW_OPTIONS = true
            UI_SET_CAMERA_SHAPE = false

        else

            UI_SHOW_OPTIONS = false

        end

    UiPop() end
end
