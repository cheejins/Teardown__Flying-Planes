local versions = {
    1,
    2,
}


function CheckRegInitialized()

    local version = GetInt("savegame.mod.version")

    if version < versions[#versions] then
        ClearKey("savegame.mod")
        SetInt("savegame.mod.version", versions[#versions])
        print("Reg reset version")
    end

end


function Init_Config()

    FlightMode = GetString("savegame.mod.FlightMode")
    FlightModeSet = GetBool("savegame.mod.flightmodeset")

    Config = util.structured_table("savegame.mod.keybinds", {

        changeTarget    = { "string", "q" },
        toggleOptions   = { "string", "o" },
        toggleHoming    = { "string", "h" },
        toggleSmallMap  = { "string", "m" },

        smallMapMode    = { "boolean", false },
        showOptions     = { "boolean", false },

    })

end


function Manage_SmallMapMode()

    if Config.smallMapMode then

        CONFIG = {
            smallMapMode = {
                turnMult = 1,
                liftMult = 0.1,
                dragMult = 2,
            }
        }

    else

        CONFIG = {
            smallMapMode = {
                turnMult = 1,
                liftMult = 1,
                dragMult = 1,
            }
        }

    end

end