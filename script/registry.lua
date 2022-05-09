function checkRegInitialized()

    if GetBool('savegame.mod.regInit') == false then

        SetBool('savegame.mod.options.showRespawnText', true)
        SetBool('savegame.mod.regInit', true)

    end

end
