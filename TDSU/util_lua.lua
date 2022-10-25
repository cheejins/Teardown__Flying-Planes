--[[TABLES]]
do

    ---Clone a table without any links to the original.
    function DeepCopy(tb_orig)
        local orig_type = type(tb_orig)
        local copy
        if orig_type == 'table' then
            copy = {}
            for orig_key, orig_value in next, tb_orig, nil do
                copy[DeepCopy(orig_key)] = DeepCopy(orig_value)
            end
            setmetatable(copy, DeepCopy(getmetatable(tb_orig)))
        else -- number, string, boolean, etc
            copy = tb_orig
        end
        return copy
    end

    ---Get a random index of a table (not the value).
    function GetRandomIndex(tb)
        local i = math.random(1, #tb)
        return i
    end

    ---Get a random index of a table (not the value).
    function  GetRandomIndexValue(tb)
        local i = math.random(1, #tb)
        return tb[i]
    end

    ---Get the next index of a table (not the value). Loop to first index if on the last index.
    function GetTableNextIndex(tb, i)
        if i + 1 > #tb then
            return 1
        else
            return i + 1
        end
    end

    ---Get the previous index of a table (not the value). Loop to first index if on the last index.
    function GetTablePreviousIndex(tb, i)
        if i - 1 <= 0 then
            return #tb
        else
            return i - 1
        end
    end

    ---Swap 2 values in a table.
    function TableSwapValue(tb, i1, i2)
        local temp = DeepCopy(tb[i1])
        tb[i1] = tb[i2]
        tb[i2] = temp
        return tb
    end

    function TableLength(tb)
        local s = 0
        for _ in pairs(tb) do s = s + 1 end
        return s
    end


end


--[[FORMATTING]]
do
    ---(String Format Number) return a rounded number as a string.
    function sfn(numberToFormat, dec) return string.format("%.".. (tostring(dec or 2)) .."f", numberToFormat) end

    ---(String Format Time) Returns the time rounded to decimal as a string.
    function sfnTime(dec) return sfn(' '..GetTime(), dec or 4) end

    ---(String Format Commas) Returns a number formatted with commas as a string.
    function sfnCommas(dec)
        return tostring(math.floor(dec)):reverse():gsub("(%d%d%d)","%1,"):gsub(",(%-?)$","%1"):reverse()
        -- https://stackoverflow.com/questions/10989788/format-integer-in-lua
    end

    ---(String Format Int) Returns a number formatted as an integer.
    function sfnInt(n)
        local s = tostring(n)
        local int = ''
        for i = 1, string.len(s) do
            local c = string.sub(s, i, i)
            if c == '.' then
                return int
            else
                int = int .. c
            end
        end
    end

    function sfnPadZeroes(n, pad) return string.format('%0' .. tostring(pad or 2) .. 'd', n) end

    function ternary ( cond , T , F ) if cond then return T else return F end end

    ---A helper function to print a table's contents.
    ---@param tbl table @The table to print.
    ---@param depth number @The depth of sub-tables to traverse through and print.
    ---@param n number @Do NOT manually set this. This controls formatting through recursion.
    function PrintTable(tbl, depth, n)
        n = n or 0;
        depth = depth or 10;

        if (depth == 0) then
            print(string.rep(' ', n).."...");
            return;
        end

        if (n == 0) then
            print(" ");
        end

        for key, value in pairs(tbl) do
            if (key and type(key) == "number" or type(key) == "string") then
                key = string.format("%s", key);

                if (type(value) == "table") then
                    if (next(value)) then
                        print(string.rep(' ', n)..key.." = {");
                        PrintTable(value, depth - 1, n + 4);
                        print(string.rep(' ', n).."},");
                    else
                        print(string.rep(' ', n)..key.." = {},");
                    end
                else
                    if (type(value) == "string") then
                        value = string.format("\"%s\"", value);
                    else
                        value = tostring(value);
                    end

                    print(string.rep(' ', n)..key.." = "..value..",");
                end
            end
        end

        if (n == 0) then
            print(" ");
        end
    end

end


function string_append(s, str, separator)
    return s .. (separator or " ") .. str
end

function string_enclose(s, str_left, str_right)
    return str_left .. s .. (str_right or str_left)
end


function IsStringInteger(data)
    for i = 1, #data do

        byte = string.byte(string.sub(data, i, i))

        if not (byte >= 48 and byte <= 57) then
            return false
        end

    end
    return true
end


-- function CallOnce()
-- end