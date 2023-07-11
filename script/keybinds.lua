function InitKeys()

    KEYS = util.structured_table("savegame.mod.keys", {

        -- Weapons
        shoot_primary = {
            title = { 'string', 'Shoot primary' },
            keys = {
                key = 'string', 'lmb',
                modifier = { 'string', ' ' }
            },
        },
        shoot_secondary = {
            title = { 'string', 'Shoot secondary' },
            keys = {
                key = 'string', 'rmb',
                modifier = { 'string', ' ' },
            },
        },


        -- Movement controls.
        thrust_add = {
            title = { 'string', 'Thrust increase' },
            keys = {
                key = 'string', 'w',
                modifier = { 'string', ' ' },
            },
        },
        thrust_sub = {
            title = { 'string', 'Thrust decrease' },
            keys = {
                key = 'string', 's',
                modifier = { 'string', ' ' },
            },
        },
        roll_left = {
            title = { 'string', 'Roll left' },
            keys = {
                key = 'string', 'up',
                modifier = { 'string', ' ' },
            },
        },
        roll_right = {
            title = { 'string', 'Roll right' },
            keys = {
                key = 'string', 'left',
                modifier = { 'string', ' ' },
            },
        },
        yaw_left = {
            title = { 'string', 'Yaw left' },
            keys = {
                key = 'string', 'a',
                modifier = { 'string', ' ' },
            },
        },
        yaw_right = {
            title = { 'string', 'Yaw right' },
            keys = {
                key = 'string', 'd',
                modifier = { 'string', ' ' },
            },
        },
        airbrake = {
            title = { 'string', 'Airbrake' },
            keys = {
                key = 'string', 'space',
                modifier = { 'string', ' ' },
            },
        },


        -- Camera
        freecam = {
            title = { 'string', 'Free camera (hold)' },
            keys = {
                key = 'string', 'lmb',
                modifier = { 'string', ' ' },
            },
        },
        resetCameraAlignment = {
            title = { 'string', 'Reset camera alignment' },
            keys = {
                key = 'string', 'lmb',
                modifier = { 'string', ' ' },
            },
        },


        -- Targeting
        changeTarget = {
            title = { 'string', 'Reset camera alignment' },
            keys = {
                key = 'string', 'lmb',
                modifier = { 'string', ' ' },
            },
        },
        toggleHoming = {
            title = { 'string', 'Toggle missile homing on/off' },
            keys = {
                key = 'string', 'lmb',
                modifier = { 'string', ' ' },
            },
        },

    })

    print(KEYS.shoot_primary.key)
    print('Done KEYS')

end

UiControls = {}


function createUiControl(name, func, gb_key)

    local co = {
        name = name,
        keybind = { key1 = KEYS[name].key1, key2 = KEYS[name].key2 },
        title = KEYS[name].title,
    }

    table.insert(UiControls, co)

end


function CreateKeyBind()

end