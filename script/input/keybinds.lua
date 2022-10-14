function InitKeys()

    KEYS = util.structured_table("savegame.mod.keys", {

        -- Weapons
        shoot_primary = {
            key =     {'string', 'lmb'},
            title =   {'string', 'Shoot primary'},
        },
        shoot_secondary = {
            key =     {'string', 'rmb'},
            title =   {'string', 'Shoot primary'},
        },


        -- Movement controls.
        thrust_add = {
            key =     {'string', 'w'},
            title =   {'string', 'Thrust increase'},
        },
        thrust_sub = {
            key =     {'string', 's'},
            title =   {'string', 'Thrust decrease'},
        },
        roll_left = {
            key =     {'string', 'a'},
            title =   {'string', 'Roll left'},
        },
        roll_right = {
            key =     {'string', 'd'},
            title =   {'string', 'Roll right'},
        },
        yaw_left = {
            key =     {'string', 'z'},
            title =   {'string', 'Yaw left'},
        },
        yaw_right = {
            key =     {'string', 'c'},
            title =   {'string', 'Yaw right'},
        },
        airbrake = {
            key =     {'string', 'space'},
            title =   {'string', 'Airbrake'},
        },


        -- Camera
        freecam = {
            key =     {'string', 'x'},
            title =   {'string', 'Free camera (hold)'},
        },
        resetCameraAlignment = {
            key =     {'string', 'mmb'},
            title =   {'string', 'Reset camera alignment'},
        },


        -- Targeting
        changeTarget = {
            key =     {'string', 'q'},
            title =   {'string', 'Reset camera alignment'},
        },
        toggleHoming = {
            key =     {'string', 'q'},
            title =   {'string', 'Toggle missile homing on/off'},
        },

    })


    PrintTable(ConvertSharedTable('savegame.mod.keys'))

end


function ConvertSharedTable(_path)

    local tb = {}

    local keys = ListKeys(_path)

    for index, key in ipairs(keys) do
        BuildSharedTableValue(tb, key, _path)
    end

    return tb

end
function BuildSharedTableValue(tb, key, _path)

    local pathConc = conc(_path, {key})
    local pathConcType = conc(pathConc, {'type'})
    local pathConcVal = conc(pathConc, {'val'})


    -- Get value type.
    local type = GetString(pathConcType)

    -- Assign simple value to tb key.
    if     type == 'boolean' then tb[key] = GetBool(pathConcVal)
    elseif type == 'number'  then tb[key] = GetFloat(pathConcVal)
    elseif type == 'string'  then tb[key] = GetString(pathConcVal)
    end


    -- Build nested table.
    if type == 'table' then

        tb[key] = {}

        local keys = ListKeys(pathConcVal)

        -- Check if all keys are integers.
        local indexes = false
        for i, k in ipairs(keys) do

            if IsStringInteger(k) then

                indexes = true

            end

        end

        if indexes then

            for i, k in ipairs(keys) do
                BuildSharedTableValue(tb[key], tonumber(k), pathConcVal)
            end

        else

            for i, k in ipairs(keys) do
                BuildSharedTableValue(tb[key], k, pathConcVal)
            end

        end

    end

end



--- Concat reg path and key.
function conc(path, k)

    if type(k) == 'table' then
        local str = path
        for index, s in ipairs(k) do
            str = str .. '.' .. tostring(s)
        end
        return str
    end

    return path .. '.' .. tostring(k)

end

function splitString(str, delimiter)
    local result = {}
    for word in string.gmatch(str, '([^'..delimiter..']+)') do
        result[#result+1] = trim(word)
    end
    return result
end
function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end