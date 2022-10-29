function Init_Sounds()
    sounds = {

        bullet = LoadSound("chopper-shoot0"),
        missile = LoadSound("MOD/snd/missile"),
        click  = LoadSound("warning-beep"),
        loop_stall_warning  = LoadLoop("MOD/snd/loop_stall_warning.ogg"),

        fire_small = LoadLoop("MOD/snd/fire_small.ogg"),
        fire_large = LoadLoop("MOD/snd/fire_large.ogg"),

        -- propellers
        prop_1 = LoadLoop("MOD/snd/prop_1-5.ogg"),
        prop_2 = LoadLoop("MOD/snd/prop_2-5.ogg"),
        prop_3 = LoadLoop("MOD/snd/prop_3-5.ogg"),
        prop_4 = LoadLoop("MOD/snd/prop_4-5.ogg"),
        prop_5 = LoadLoop("MOD/snd/prop_5-5.ogg"),


        -- jet engine
        jet_engine_loop_mig29 = LoadLoop("MOD/snd/jet_engine_loop_mig29.ogg"),
        jet_engine_loop = LoadLoop("MOD/snd/jet_engine_loop.ogg"),
        jet_engine_afterburner = LoadLoop("MOD/snd/jet_engine_afterburner.ogg"),

        bullet_mg1 = LoadSound("MOD/snd/bullet_mg1.ogg"),
        emg = LoadLoop("MOD/snd/weapon_emg.ogg"),
        mg = LoadLoop("MOD/snd/weapon_mg.ogg"),
        mg2 = LoadLoop("MOD/snd/weapon_mg2.ogg"),
        mg3 = LoadLoop("MOD/snd/weapon_mg3.ogg"),

        engine_deaths = {
            LoadSound("MOD/snd/engine_die1.ogg"),
            LoadSound("MOD/snd/engine_die2.ogg"),
            LoadSound("MOD/snd/engine_die3.ogg"),
            LoadSound("MOD/snd/engine_die4.ogg"),
        }

    }


    loops = {

        landing_gear = LoadLoop("MOD/snd/loop_landing_gear.ogg"),

        jets_distant = {
            LoadLoop("MOD/snd/jet_distant1.ogg"),
            LoadLoop("MOD/snd/jet_distant2.ogg"),
            LoadLoop("MOD/snd/jet_distant3.ogg"),
        }
    }

end