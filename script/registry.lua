local versions = {
    1,
    2,
}

function checkRegInitialized()

    local version = GetInt("savegame.mod.version")

    if version < versions[#versions] then
        ClearKey("savegame.mod")
        SetInt("savegame.mod.version", versions[#versions])
        print("Reg reset version")
    end

end
