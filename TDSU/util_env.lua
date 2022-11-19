env_types = {
    string = "string",
    float = "float",
    int = "int",
    euler = "euler",
    vec_euler = "vec_euler",
    vec_rad = "vec_rad",
    vec_dir = "dir",
}



function env_type_string()
    return {
        type = "string",
        val = { def or "" }
    }
end

function env_type_float(min, max, def)
    return {
        type = "float",
        val = { def or 0.5 },
        min = min,
        max = max
    }
end

function env_type_int()
end

function env_type_euler(def)
    return {
        type = "float",
        val = { def or 0 },
        min = -180,
        max = 180 }
end

function env_type_vec_euler(def)

    return {
        type = "euler",
        val = def or Vec(0,0,0),
        min = -180,
        max = 180
    }

end

function env_type_vec_rad(def)

    return {
        type = "euler",
        val = def or Vec(0,0,0),
        min = 0,
        max = 1
    }

end

function env_type_vec_dir(def)

    return {
        type = "euler",
        val = def or Vec(0,0,0),
        min = -1,
        max = 1
    }

end



function Get_EnvironmentSettings()

    -- First env property is the type.
    local ENV_TEMPLATE = {

        Skybox = {

            -- skybox = {"cloudy.dds"},

            skyboxbrightness = env_type_float(0, 100, 10),

            skyboxtint = env_type_vec_rad(Vec(0.5, 0.5, 0.5)),

            skyboxrot = env_type_euler()

        },
        Sun = {
            sunDir = env_type_vec_rad(),

            sunBrightness = env_type_float(0, 100, 1),

            sunFogScale = env_type_float(0, 100, 1),

            sunSpread = env_type_float(0, 100, 1),

            sunLength = env_type_float(0, 100, 10),

            sunColorTint = env_type_vec_rad(Vec(0.5, 0.5, 0.5)),

            sunGlare = env_type_float(0, 100, 1),
        },
        Fog = {
            fogParams = {
                { min = 0, max = 500},
                { min = 0, max = 500},
                { min = 0, max = 500},
                { min = 0, max = 500}},

            fogColor = {
                { min = 0, max = 1},
                { min = 0, max = 1},
                { min = 0, max = 1}},

            fogscale = {
                { min = 0, max = 100}},
        },
        Lighting = {
            nightlight = { {} },

            ambient = {
                { min = 0, max = 10}},

            constant = {
                { min = 0, max = 1},
                { min = 0, max = 1},
                { min = 0, max = 1}},

            brightness = {
                { min = 0, max = 10}},

            exposure = {
                { min = 0, max = 10},
                { min = 0, max = 10}},

            ambientexponent = {
                { min = 0, max = 1}}
        },
        Rain = {
            puddleamount = {
                { min = 0, max = 1}},
            rain = {
                { min = 0, max = 1}},
            wetness = {
                { min = 0, max = 1}},
            puddlesize = {
                { min = 0, max = 1}}
        },
        Snow = {
            snowonground = {},
            snowamount = {0, 0},
            snowdir = {0, -1, 0, 0}
        },
        Misc = {
            slippery = {
                { min = 0, max = 1}},
            wind = {
                { min = 0, max = 100},
                { min = 0, max = 100},
                { min = 0, max = 100}},
            ambience = {
                "outdoor/field.ogg",
                { min = 0, max = 1}},
            waterhurt = {
                { min = 0, max = 1}}
        },
    }

    return ENV_TEMPLATE

end


function InitEnv()

    -- PrintTable(GetCurrentEnv())

    env_template = Get_EnvironmentSettings()

    env_menu = {
        selected_env_cat = "Skybox",
    }

end


function Draw_EnvSettingsMenu()

    local dim_header = { w = 1000, h = 100}

    UiColor(1,1,1, 1)
    UiTextShadow(0,0,0, 1, 0.3, 0)
    UiFont("bold.ttf", 24)
    UiAlign("left top")
    UiTranslate(UiCenter() - dim_header.w/2, 20)

    if not InputDown("f") then
        UiMakeInteractive()
    end

    local env_settings = env_template

    do UiPush()
        -- Header
        AutoContainer(dim_header.w, dim_header.h)
        AutoSpreadRight()
            for key, env in pairs(env_settings) do

                if AutoButton(key, 24) then
                    env_menu.selected_env_cat = key
                end

            end
        AutoSpreadEnd()
    UiPop() end


    ScrollY = ScrollY or 0
    ScrollY = clamp(ScrollY - (InputValue("mousewheel") * 32), 0, math.huge)

    local ScrollH = #env_template[env_menu.selected_env_cat]

    UiPush()

        UiTranslate(0, dim_header.h)

        UiWindow(dim_header.w, 900, true)

        -- Content
        AutoContainer(dim_header.w, 900)
        AutoSpreadDown()

        UiTranslate(0, (-ScrollY))
            UiPush()

                    for key, env in pairs(env_template[env_menu.selected_env_cat]) do

                        for index, val in ipairs(env.val) do
                            AutoText(key .. "[" .. index .. "] = " .. env.val[index], 24)
                            env.val[index] = AutoSlider(val, env.min, env.max, env.max / 1000)
                            SetEnvironmentProperty(key, unpack(env.val))
                        end

                        UiTranslate(0, 60)

                    end

            UiPop()

        AutoSpreadEnd()

    UiPop()

    UiPush()

        UiTranslate(dim_header.w + 2, dim_header.h)

        AutoContainer(20, 900)

            UiTranslate(-30/2/2, ScrollY)
            AutoImage("ui/common/dot.png", 20, 30)


        AutoSpreadEnd()

    UiPop()

end

function ProcessEnvs()
end


MenuItems = {
    Skybox = {
        skybox = {
            type = "",
            name = "Skybox",
            desc = "The dds file used as skybox.\nSearch path is data/env.",
            string = true,
            dd = {
                "cannon_2k.dds", "cloudy.dds", "cold_dramatic_clouds.dds",
                "cold_sunny_evening.dds", "cold_sunset.dds",
                "cold_wispy_sky.dds", "cool_clear_sunrise.dds", "cool_day.dds",
                "day.dds", "industrial_sunset_2k.dds", "jk2.dds", "moonlit.dds",
                "night.dds", "night_clear.dds", "overcast_day.dds",
                "sunflowers_2k.dds", "sunset.dds",
                "sunset_in_the_chalk_quarry_2k.dds", "tornado.dds"
            }
        },
        skyboxtint = {
            type = "",
            name = "Skybox Tint",
            desc = "The skybox color tint",
            args = 3,
            color = true
        },
        skyboxbrightness = {
            type = "",
            name = "Skybox Brightness",
            desc = "The skybox brightness scale"
        },
        skyboxrot = {
            type = "",
            name = "Skybox Rotation",
            desc = "The skybox rotation around the y axis.\nUse this to determine angle of sun shadows."
        }
    },
    Sun = {
        sunBrightness = {
            type = "",
            name = "Sun Brightness",
            desc = "Light contribution by sun (gives directional shadows)"
        },
        sunColorTint = {
            type = "",
            name = "Sun Tint",
            desc = "Color tint of sunlight.\nMultiplied with brightest spot in skybox",
            args = 3,
            color = true
        },
        sunDir = {
            type = "",
            name = "Sun Direction",
            desc = "Direction of sunlight. A value of zero\nwill point from brightest spot in skybox",
            args = 3
        },
        sunSpread = {
            type = "",
            name = "Sun Spread",
            desc = "Divergence of sunlight as a fraction. A value\nof 0.05 will blur shadows 5 cm per meter"
        },
        sunLength = {
            type = "",
            name = "Sun Length",
            desc = "Maximum length of sunlight shadows.\nAS low as possible for best performance"
        },
        sunFogScale = {
            type = "",
            name = "Sun Fog Scale",
            desc = "Volumetic fog caused by sunlight"
        },
        sunGlare = {
            type = "",
            name = "Sun Glare",
            desc = "Sun glare scaling"}
    },
    Fog = {
        fogColor = {
            type = "",
            name = "Fog Color",
            desc = "Color used for distance fog",
            args = 3,
            color = true
        },
        fogParams = {
            type = "",
            name = "Fog Parameters",
            desc = "Four fog parameters: fog start, fog end, fog amount,\nfog exponent (higher gives steeper falloff along y axis)",
            args = 4
        },
        fogscale = {
            type = "",
            name = "Fog Scale",
            desc = "Scale fog value on all light sources with this amount"
        }
    },
    Lighting = {
        constant = {
            type = "",
            name = "Constant Light",
            desc = "Base light, always contributes no matter\nlighting conditions.",
            args = 3
        },
        ambient = {
            type = "",
            name = "Ambient Light",
            desc = "Determines how much the skybox will\nlight up the scene."
        },
        ambientexponent = {
            type = "",
            name = "Ambient Exponent",
            desc = "Determines ambient light falloff when occluded.\nHigher value = darker indoors."
        },
        exposure = {
            type = "",
            name = "Exposure Limits",
            desc = "Limits for automatic exposure, min max",
            args = 2
        },
        brightness = {
            type = "",
            name = "Brightness",
            desc = "Desired scene brightness that controls\nautomatic exposure. Set higher for brighter scene."
        },
        nightlight = {
            type = "",
            name = "Night Lights",
            desc = "If set to false, all lights tagged night will be removed.",
            bool = true
        }
    },
    Rain = {
        wetness = {
            type = "",
            name = "Wetness",
            desc = "Base wetness"},
        puddleamount = {
            type = "",
            name = "Puddle Amount",
            desc = "Puddle coverage. Fraction between zero and one"
        },
        puddlesize = {
            type = "",
            name = "Puddle Size",
            desc = "Puddle size"},
        rain = {
            type = "",
            name = "Rain Amount",
            desc = "Amount of rain"}
    },
    Snow = {
        snowdir = {
            type = "",
            name = "Snow Direction",
            desc = "Snow direction, x, y, z, and spread"
        },
        snowamount = {
            type = "",
            name = "Snow Amount",
            desc = "Snow particle amount (0-1)"},
        snowonground = {
            type = "",
            name = "Snow on Ground",
            desc = "Generate snow on ground",
            bool = true
        }
    },
    Misc = {
        ambience = {
            type = "",
            name = "Ambience",
            desc = "Environment sound path",
            string = true,
            dd = {
                "indoor/cave.ogg", "indoor/dansband.ogg", "indoor/factory.ogg",
                "indoor/factory0.ogg", "indoor/factory1.ogg",
                "indoor/factory2.ogg", "indoor/mall.ogg",
                "indoor/small_room0.ogg", "indoor/small_room1.ogg",
                "indoor/small_room2.ogg", "indoor/small_room3.ogg",
                "outdoor/caribbean.ogg", "outdoor/caribbean_ocean.ogg",
                "outdoor/field.ogg", "outdoor/forest.ogg", "outdoor/lake.ogg",
                "outdoor/lake_birds.ogg", "outdoor/night.ogg",
                "outdoor/ocean.ogg", "outdoor/rain_heavy.ogg",
                "outdoor/rain_light.ogg", "outdoor/wind.ogg",
                "outdoor/winter.ogg", "outdoor/winter_snowstorm.ogg",
                "woonderland/lee_woonderland_cabins.ogg",
                "woonderland/lee_woonderland_freefall.ogg",
                "woonderland/lee_woonderland_motorcycles.ogg",
                "woonderland/lee_woonderland_sea_side_swings.ogg",
                "woonderland/lee_woonderland_swanboats.ogg",
                "woonderland/lee_woonderland_tire_carousel.ogg",
                "woonderland/lee_woonderland_wheel_of_woo.ogg",
                "woonderland/lee_woonderland_woocars.ogg", "underwater.ogg"
            }
        },
        slippery = {
            type = "",
            name = "Slipperiness",
            desc = "Slippery road. Affects vehicles when outdoors"
        },
        waterhurt = {
            type = "",
            name = "Water Damage",
            desc = "Players take damage being in water. If above zero,\nhealth will decrease and not regenerate in water"
        },
        wind = {
            type = "",
            name = "Wind Strength",
            desc = "Wind direction and strength: x y z",
            args = 3
        } -- I dunno, don't ask?
    }
}



-- Get current environment properties and format it as a lua table, printed to the console.
function GetCurrentEnv()

    local env = {}

    for env_category, header in pairs(MenuItems) do

        -- print(title .. ' = {')

        env[env_category] = env[env_category] or {}

        for env_name, prop in pairs(header) do

            -- print('    ' .. env_name .. ' = {')

            local args = {GetEnvironmentProperty(env_name)}

            env[env_category][env_name] = env[env_category][env_name] or {}

            env[env_category][env_name].val = args

            -- for i, val in ipairs(args) do

            --     if type(val) == 'string' then
            --         val = '"' .. val .. '"'
            --     end

            --     print('        ' .. tostring(val) .. ',')

            -- end

            -- print('    },')

        end

        -- print('},')

    end

    return env

end