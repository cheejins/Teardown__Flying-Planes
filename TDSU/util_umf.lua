--================================================================
-- Functions for Thomasims' UMF Unofficial Modding Framework)
--================================================================



---Convert a umf shared table to a regular lua table. Mainly used to interate over the table. If there are no string keys the converted table will have numerical indicies.
---@param _path string Path to the table in the regsitry.
---@return table tb Converted table.
function ConvertSharedTable(_path)

    local tb = {}
    local keys = ListKeys(_path) -- Registry keys of the shared table.

    for index, key in ipairs(keys) do
        BuildSharedTableValue(tb, key, _path) -- Recursively build each table value.
    end

    return tb -- Converted table.

end


---Build a single value from a umf shared table. Called recursively in ConvertSharedTable().
---@param tb table Table with values to build. Can be a nested table inside of an already built value.
---@param key string Key of the table in the registry (can be an index or key)
---@param _path string Path to the specified shared table index in the registry.
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

        -- Check if the table has indecies or keys.
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
