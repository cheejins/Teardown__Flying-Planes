Actions = {
    shoot_primary,
    shoot_secondary,
    homing,
    thrust_increase,
    thrust_decrease,
    pitch_up,
    pitch_down,
    roll_left,
    roll_right,
    yaw_left,
    yaw_right,
    airbrake,
    freecam,
    change_camera,
    next_target,
    disable_input,
}


Keys = {

    Weapons = {
        {
            key =     "lmb",
            action =  "shoot_primary",
            title =   "Shoot primary",
        },
        {
            key =     "rmb",
            action =  "shoot_secondary",
            title =   "Shoot secondary",
        },
        {
            key =     "h",
            action =  "homing",
            title =   "Toggle missile homing on/off",
        },
    },

    Movement = {
        {
            key =     "shift",
            action =  "thrust_increase",
            title =   "Thrust increase",
        },
        {
            key =     "ctrl",
            action =  "thrust_decrease",
            title =   "Thrust decrease",
        },
        {
            key =     "s",
            action =  "pitch_up",
            title =   "Pitch up",
        },
        {
            key =     "w",
            action =  "pitch_down",
            title =   "Pitch down",
        },
        {
            key =     "a",
            action =  "roll_left",
            title =   "Roll left",
        },
        {
            key =     "d",
            action =  "roll_right",
            title =   "Roll right",
        },
        {
            key =     "z",
            action =  "yaw_left",
            title =   "Yaw left",
        },
        {
            key =     "c",
            action =  "yaw_right",
            title =   "Yaw right",
        },
        {
            key =     "space",
            action =  "airbrake",
            title =   "Airbrake",
        },
    },

    Camera = {
        {
            key =     "x",
            action =  "freecam",
            title =   "Free camera (hold)",
        },
        {
            key =     "r",
            action =  "change_camera",
            title =   "Switch to the next camera view",
        },
    },

    Targeting = {
        {
            key =     "q",
            action =  "next_target",
            title =   "Select next target",
        },
    },

    Misc = {
        {
            key =     "k",
            action =  "disable_input",
            title =   "Temporarily disable all plane inputs.",
        },
    },

}


function InitKeys()

    KEYS = util.shared_table("savegame.mod.keys", Keys)

    -- -- Assign all updated keys.
    -- for key, category in pairs(Keys) do
    --     for bindKey, bindData in ipairs(category) do
    --         Actions[bindData.action] = KEYS[key][bindKey].key
    --     end
    -- end

    -- PrintTable(Actions)

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