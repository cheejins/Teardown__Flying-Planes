--[[DEBUG COLOR]]


function InitColor()

    Colors = {

        white   = Vec(1,1,1),
        grey    = Vec(0.5,0.5,0.5),
        black   = Vec(0,0,0),

        red     = Vec(1,0,0),
        yellow  = Vec(1,1,0),
        blue    = Vec(0,0,1),

        purple  = Vec(1,0,1),
        green   = Vec(0,1,0),
        orange  = Vec(1,0.5,0),

        pink = Vec(1,0.75,0.75),
        auqua = Vec(0,0.75,0.75),

        light = { ---@table
            grey    = Vec(0.75,0.75,0.75),
            red     = Vec(1,0.5,0.5),
            yellow  = Vec(1,1,0.5),
            blue    = Vec(0.5,0.5,1),
            purple  = Vec(1,0.5,1),
            green   = Vec(0.5,1,0.5),
            orange  = Vec(1,0.75,0.5),
        },

        dark = { ---@table
            grey    = Vec(0.25,0.25,0.25),
            red     = Vec(0.75,0,0),
            yellow  = Vec(0.75,0.75,0),
            blue    = Vec(0,0,0.75),
            purple  = Vec(0.75,0,0.75),
            green   = Vec(0,0.75,0),
            orange  = Vec(0.75,1/3,0),
        }

    }

end



---Return r,g,b values of a Color sub-table.
---@param color table Color from Colors table.
function Color(color) return table.unpack(color) end