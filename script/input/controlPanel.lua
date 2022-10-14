UiControls = {}


function getImgPath(str)
    return 'MOD/img/icon_' .. str .. '.png'
end

function createUiControl(name, icon, func, gb_key)

    local co = {
        name = name,
        keybind = {key1 = KEYS[name].key1, key2 = KEYS[name].key2},
        title = KEYS[name].title,
        icon = getImgPath(icon),
        func = func,
        bool = gb_key
    }

    table.insert(UiControls, co)

end

function initUiControlPanel()

    createUiControl(
        'runChain',
        'play',
        'toggleRunChain',
        'RUN_ITEM_CHAIN'
    )
    createUiControl(
        'camView',
        'eye_frame',
        'toggleViewCamera',
        'RUN_CAMERAS'
    )
    createUiControl(
        'restartChain',
        'restart',
        'initializeItemChain',
        ''
    )


    createUiControl(
        'prevCamera',
        'camera_prev',
        'PrevCamera',
        ''
    )
    createUiControl(
        'nextCamera',
        'camera_next',
        'NextCamera',
        ''
    )


    createUiControl(
        'prevEvent',
        'event_prev',
        'PrevEvent',
        ''
    )
    createUiControl(
        'nextEvent',
        'event_next',
        'NextEvent',
        ''
    )


    createUiControl(
        'detailedMode',
        'info',
        'toggleDetails',
        'UI_SHOW_DETAILS'
    )
    createUiControl(
        'drawCameras',
        'camera_classic',
        'toggleDrawCameras',
        'DRAW_CAMERAS'
    )
    createUiControl(
        'deleteAll',
        'deleteAll',
        'clearAllObjects',
        ''
    )


    createUiControl(
        'toggleUi',
        'toggleUi',
        'toggleShowUi',
        'UI_SHOW_OPTIONS'
    )
    createUiControl(
        'pinPanel',
        'pin',
        'togglePinControlPanel',
        'UI_PIN_CONTROL_PANEL'
    )

end


function toggleDrawCameras()
    DRAW_CAMERAS = not DRAW_CAMERAS
end
function togglePinControlPanel()
    UI_PIN_CONTROL_PANEL = not UI_PIN_CONTROL_PANEL
end
function toggleDetails()
    UI_SHOW_DETAILS = not UI_SHOW_DETAILS
end
function toggleShowUi()
    UI_SHOW_OPTIONS = not UI_SHOW_OPTIONS
end
function toggleViewCamera()
    RUN_CAMERAS = not RUN_CAMERAS
    validateItemChain()
end
function clearAllObjects()
    ITEM_OBJECTS = {}
    ITEM_CHAIN = {}
    EVENT_OBJECTS = {}
    CAMERA_OBJECTS = {}
end
function toggleRunChain()
    RUN_ITEM_CHAIN = not RUN_ITEM_CHAIN
    validateItemChain()
end


function shouldDisableControlPanel()
    return activeAssignment or activeNameAssignment
end