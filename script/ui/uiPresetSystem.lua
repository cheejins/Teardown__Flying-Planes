Preset_temp = {}
PRESET_ID = 0

SAVE_NAME = false

presetCanvasScroll = 0

function initPresets()

    Presets = util.shared_table('savegame.mod.presets')

end


function drawPresetCanvas(w,h, listItemH)

    UiWindow(w, h)
    UiAlign('left top')

    local contH = UiHeight() - 100
    local buttonsH = 100


    -- List
    do UiPush()

        local rowH = listItemH * 0.7
        uiSetFont(24)

        UiWindow(w, contH - buttonsH/2, true)
        UiImageBox('ui/common/box-outline-6.png', UiWidth(), UiHeight(), 10,10)

        if UiIsMouseInRect(UiWidth(), UiHeight()) then
            presetCanvasScroll = presetCanvasScroll + (InputValue('mousewheel') * listItemH * 0.7)
        end
        presetCanvasScroll = clamp(presetCanvasScroll, -#ListKeys('savegame.mod.presets') * listItemH * 0.7, 0)

        margin(0, presetCanvasScroll)

        local keys = ListKeys("savegame.mod.presets")

        for index, k in ipairs(keys) do

            local preset = Presets[k]

            do UiPush()

                UiImageBox('ui/common/box-outline-6.png', w, listItemH, 10,10)

                UiAlign('left middle')

                margin(0, listItemH/2)
                do UiPush()

                    margin(10, 0)
                    UiButtonImageBox('MOD/img/icon_deleteAll.png', 0,0)
                    if UiTextButton(' ', rowH, rowH) then
                        preset_Delete(preset) -- Delete preset
                    end

                    margin(rowH + 10, 0)
                    UiText(preset.id)

                    margin(rowH + 10, 0)
                    UiText(preset.name)

                UiPop() end

                do UiPush()

                    UiAlign('right middle')

                    margin(w-10, 0)
                    UiButtonImageBox('ui/common/box-outline-6.png', 10,10, 1,1,1, 1)
                    if UiTextButton('Load', 80, rowH) then
                        preset_Load(k) -- Load preset
                    end

                UiPop() end

            UiPop() end

            margin(0, listItemH)

        end

    UiPop() end

    -- Button panel.
    do UiPush()

        UiWindow(w, buttonsH)

        margin(0, contH - 100)
        do UiPush()
            UiAlign('center top')
            margin(w/2, 50)
            UiColor(1,0,0,0.75)
            UiWordWrap(w)
            UiText('CAUTION: Mod updates may corrupt presets until the final version of the mod is released.')
        UiPop() end


        UiAlign('left top')
        margin(0, 100)
        UiColor(1,1,1,1)
        if SAVE_NAME then
            preset_save_window(w, buttonsH, Preset_temp)
        else
            drawPresetButtons(w, buttonsH)
        end

    UiPop() end

end

function drawPresetButtons(w, h)

    do UiPush()

        UiWindow(w, h)

        local btnW = w/3

        do UiPush()

            margin(w/2, 0)

            UiAlign('center top')
            UiButtonImageBox('ui/common/box-outline-6.png', 10,10, 1,1,1, 1)
            if UiTextButton('Save Preset', btnW, UiHeight()) then
                preset_Save()
            end

        UiPop() end

    UiPop() end

end


function preset_Save()
    SAVE_NAME = true
    Preset_temp = createPreset('', ITEM_CHAIN, EVENT_OBJECTS, CAMERA_OBJECTS)
    enableTextField(Preset_temp, 'name')
end
function preset_Load(key)

    local preset_path = 'savegame.mod.presets'

    print(preset_path)


    local tb = ConvertSharedTable(preset_path)[key]

    ITEM_CHAIN = tb.ic
    CAMERA_OBJECTS = tb.co
    EVENT_OBJECTS = tb.eo

    ITEM_IDS = tb.ii
    CAMERA_IDS = tb.ci
    EVENT_IDS = tb.ei


    initializeItemChain()

    for index, item in ipairs(ITEM_CHAIN) do

        if item.type == 'event' then

            item.item = getEventById(item.item.id)

            event_replaceDef(item.item)

        elseif item.type == 'camera' then

            item.item = getCameraById(item.item.id)
            item.item.viewTr = TransformCopy(item.item.tr)

            cam_replaceDef(item.item)

        end

    end

end
function preset_Delete(preset)
    ClearKey('savegame.mod.presets.'..preset.name)
end


function preset_save_window(w, h, preset)

    local presetValid = isPresetValid(preset)


    local labelW = 80
    local textW = w - labelW

    local saveW = 100
    local cancelW = 100

    -- Name text field
    do UiPush()

        UiAlign('left middle')
        uiSetFont(28)

        do UiPush()
            margin(0, h/4)
            UiText('Name: ')
        UiPop() end

        margin(labelW, 2)

        uiTextField(textW, h/2, preset, 'name')

    UiPop() end

    margin(w/2 - 100, 0)
    UiAlign('left bottom')
    UiButtonHoverColor(1,1,1,1)

    -- Save button
    margin(0, h)
    if presetValid then
        UiButtonImageBox('ui/common/box-outline-6.png', 10,10, 0,1,0, 1)
    else
        UiButtonImageBox('ui/common/box-outline-6.png', 10,10, 1,0,0, 1)
    end
    if UiTextButton('Save', saveW, h/2.5) then

        if presetValid then

            Presets[preset.name] = DeepCopy(preset)
            SAVE_NAME = false

        end

    end

    -- Cancel button
    margin(saveW, 0)
    UiButtonImageBox('ui/common/box-outline-6.png', 10,10, 1,1,1, 1)
    if UiTextButton('Cancel', cancelW, h/2.5) then
        SAVE_NAME = false
    end

end


--- Creates a preset containing a snapshot of the current item and component objects.
---@param name string Name of the preset.
---@param IC table Item chain.
---@param EO table Event objects.
---@param CO table Camera objects.
---@return table
function createPreset(name, IC, EO, CO)

    PRESET_ID = PRESET_ID + 1

    local preset = {
        id = PRESET_ID,
        name = name,

        ic = DeepCopy(IC),
        eo = DeepCopy(EO),
        co = DeepCopy(CO),

        ii = ITEM_IDS,
        ci = CAMERA_IDS,
        ei = EVENT_IDS,
    }

    return preset

end
function isPresetValid(preset)
    if preset.name == '' or preset.name == nil or Presets[preset.name] then
        return false
    end
    return true
end
