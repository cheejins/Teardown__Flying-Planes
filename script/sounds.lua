function initSounds()
    sounds = {
        bullet = LoadSound("chopper-shoot0"),
        missile = LoadSound("MOD/script/snd/missile"),
        click  = LoadSound("warning-beep"),

        -- propellers
        prop_1 = LoadLoop("MOD/script/snd/prop_1-5.ogg"),
        prop_2 = LoadLoop("MOD/script/snd/prop_2-5.ogg"),
        prop_3 = LoadLoop("MOD/script/snd/prop_3-5.ogg"),
        prop_4 = LoadLoop("MOD/script/snd/prop_4-5.ogg"),
        prop_5 = LoadLoop("MOD/script/snd/prop_5-5.ogg"),

        -- jet engine
        jet_engine_loop = LoadLoop("MOD/script/snd/jet_engine_loop.ogg"),
        jet_engine_afterburner = LoadLoop("MOD/script/snd/jet_engine_afterburner.ogg"),

        bullet_mg1 = LoadSound("MOD/script/snd/bullet_mg1.ogg"),
        emg = LoadLoop("MOD/script/snd/weapon_emg.ogg"),
        mg = LoadLoop("MOD/script/snd/weapon_mg.ogg"),
    }
end