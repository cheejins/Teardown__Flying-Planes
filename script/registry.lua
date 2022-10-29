local versions = {
    1,2,3,4,5,
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
        debug           = { "boolean", false },
        unbreakable_planes = { "boolean", false },

        sounds_stall_warning = { "boolean", true },
        spawn_aiplanes = { "boolean", true },

    })

end
