#include "Settings_Table.lua"
#include "TDSU/tdsu.lua"


Settings_Path = "savegame.mod.settings"


---MAKE SURE TO CALL THIS IN init() and HandleQuickLoad(cmd)
function Init_Settings()

    Init_Settings_Table()
    Settings = util.structured_table(Settings_Path, st_table(Settings_Table))


    Valid_Keys = {} -- Indexed table of keys that lead to all st objects in Settings_Table and Settings.
    GetSharedTableKeyPaths(Settings_Table, Valid_Keys)


end

function GetSharedTableKeyPaths(tb_base, tb_output, n, d, _keys, _tb_keys_path)

    n = n or 1
    d = d or 1
    _keys = _keys or {}
    _tb_keys_path = _tb_keys_path or {}


    local indent = ""
    for i = 0, n - 1 do indent = indent .. "  " end


    for key, tb in pairs(tb_base) do

        if type(tb) == "table" then

            if (tb.type and tb.title) then -- Reached a valid st object.

                table.insert(_tb_keys_path, key)
                table.insert(tb_output, DeepCopy(_tb_keys_path))

                if tb.values then

                end

            else -- Keep traversing until a st object is reached.

                table.insert(_tb_keys_path, key) -- Add key to the list of keys that will be traversed.
                _keys[key] = GetSharedTableKeyPaths(tb, tb_output, n + 1, d, _keys[key], _tb_keys_path) -- Process the next nested table

            end

        end

        _tb_keys_path[#_tb_keys_path] = nil -- Backtrack to previous key.

    end

end




-- Used by the options ui to draw the correct component.
struct_table_types = {
    range    = "range",
    checkbox = "checkbox",
    segment  = "segment",  -- Similar to an iOS UISegmentedControl
    keybind  = "keybind"
}

struct_table_increments = {
    _001 = 1/100, -- 1/100
    _01  = 1,     -- 1/10
    _1   = 1,     -- 1
}




---Creates a range of floats with a min, max and default value.
function st_object_range(title, value, min, max, increment)
    return {
        title     = title,
        type      = struct_table_types.range,

        value     = value,
        min       = min,
        max       = max,
        increment = increment or struct_table_increments._100,
    }
end

---Creates a bool checkbox.
function st_object_checkbox(title, value, desc)
    return {
        title = title,
        type  = struct_table_types.checkbox,

        desc = desc or "",
        value = value,
    }
end


---Similar to an iOS UISegmentedControl
---@param tb_values table ipairs table of values {5, 10, 50, 100}
function st_object_segment(title, value, tb_values)

    local tb = {
        title = title,
        type  = struct_table_types.segment,

        value  = value,
        values = tb_values,
    }

    return tb

end

---@param title string
---@param tb_values table Array of valid keys.
---@return table
function st_object_keybind(tb_values, title)

    return {
        title = title,
        type  = struct_table_types.keybind,

        values = tb_values,
    }

end

---Shows a confirmation screen and runs a function if the user presses "yes"
function st_object_confirmation(message, func, tb_args)
end




function st_number(number) return { "number", number }  end
function st_boolean(bool)  return { "boolean", bool }   end
function st_string(string) return { "string", string }  end

function st_table(tb)
    local st_tb = {}
    for key, value in pairs(tb) do
        st_tb[key] = _G["st_" .. type(value)](value)
    end
    return st_tb
end




function KeybindPressed(setting_keybind)

    local keys = {
        setting_keybind.values.k1,
        ternary(setting_keybind.values.k2 == "none", nil, setting_keybind.values.k2),
        ternary(setting_keybind.values.k3 == "none", nil, setting_keybind.values.k3),
    }

    local pressed = false

    if #keys == 1 then

        return InputPressed(keys[1]) -- Only check for one key pressed.

    elseif #keys >= 2 then

        pressed = InputPressed(keys[1]) -- Check if main key pressed.

        for i = 2, #keys do -- Check if secondary keys are pressed down.
            pressed = pressed and InputDown(keys[i])
        end

    end

    return pressed

end

function KeybindReleased(setting_keybind)

    local keys = {
        setting_keybind.values.k1,
        ternary(setting_keybind.values.k2 == "none", nil, setting_keybind.values.k2),
        ternary(setting_keybind.values.k3 == "none", nil, setting_keybind.values.k3),
    }

    local pressed = false

    if #keys == 1 then

        return InputReleased(keys[1]) -- Only check for one key released.

    elseif #keys >= 2 then

        local released = InputReleased(keys[1]) -- Check if main key released.

        for i = 2, #keys do -- Check if secondary keys are pressed down.
            released = released and InputDown(keys[i])
        end

    end

    return released

end

function KeybindDown(setting_keybind)

    local keys = {
        setting_keybind.values.k1,
        ternary(setting_keybind.values.k2 == "none", nil, setting_keybind.values.k2),
        ternary(setting_keybind.values.k3 == "none", nil, setting_keybind.values.k3),
    }

    local down = true

    for index, key in ipairs(keys) do
        down = down and InputDown(key) -- = false if a key is not down.
    end

    return down

end
