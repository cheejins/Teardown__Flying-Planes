-- Get current environment properties and format it as a lua table, printed to the console.
function PrintEnv()

    for name, header in pairs(MenuItems) do

        print(name .. ' = {')

        for index, prop in pairs(header) do

            print('    ' .. index .. ' = {')

            local args = {GetEnvironmentProperty(index)}

            for i, val in ipairs(args) do

                if type(val) == 'string' then
                    val = '"' .. val .. '"'
                end

                print('        ' .. tostring(val) .. ',')

            end

            print('    },')

        end

        print('},')

    end

end



function env_type_string()
end

function env_type_float(min, max, def)
    return {
        type = "float",
        val = { def or 0.5 },
        min = min,
        max = max }
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

function env_type_dir(def)

    return {
        type = "euler",
        val = def or Vec(0,0,0),
        min = -1,
        max = 1
    }

end


function env_type_vec3(min, max)
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

        -- Fog = {
        --     fogParams = {
        --         { min = 0, max = 500},
        --         { min = 0, max = 500},
        --         { min = 0, max = 500},
        --         { min = 0, max = 500}},

        --     fogColor = {
        --         { min = 0, max = 1},
        --         { min = 0, max = 1},
        --         { min = 0, max = 1}},

        --     fogscale = {
        --         { min = 0, max = 100}},
        -- },

        -- Lighting = {
        --     nightlight = { {} },

        --     ambient = {
        --         { min = 0, max = 10}},

        --     constant = {
        --         { min = 0, max = 1},
        --         { min = 0, max = 1},
        --         { min = 0, max = 1}},

        --     brightness = {
        --         { min = 0, max = 10}},

        --     exposure = {
        --         { min = 0, max = 10},
        --         { min = 0, max = 10}},

        --     ambientexponent = {
        --         { min = 0, max = 1}}
        -- },

        -- Rain = {
        --     puddleamount = {
        --         { min = 0, max = 1}},
        --     rain = {
        --         { min = 0, max = 1}},
        --     wetness = {
        --         { min = 0, max = 1}},
        --     puddlesize = {
        --         { min = 0, max = 1}}
        -- },

        -- Misc = {
        --     slippery = {
        --         { min = 0, max = 1}},
        --     wind = {
        --         { min = 0, max = 100},
        --         { min = 0, max = 100},
        --         { min = 0, max = 100}},
        --     ambience = {
        --         "outdoor/field.ogg",
        --         { min = 0, max = 1}},
        --     waterhurt = {
        --         { min = 0, max = 1}}
        -- },

        -- Snow = {
        --     snowonground = {},
        --     snowamount = {0, 0},
        --     snowdir = {0, -1, 0, 0}
        -- }
    }

    return ENV_TEMPLATE

end

function InitEnv()

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

