#include "Automatic.lua"
#include "TDSU/tdsu.lua"
#include "script/ai_SAMS.lua"
#include "script/ai_planes.lua"
#include "script/debug.lua"
#include "script/input/controlPanel.lua"
#include "script/input/input.lua"
#include "script/input/keybinds.lua"
#include "script/particles.lua"
#include "script/plane/plane_animate.lua"
#include "script/plane/plane_builder.lua"
#include "script/plane/plane_camera.lua"
#include "script/plane/plane_constructor.lua"
#include "script/plane/plane_functions.lua"
#include "script/plane/plane_hud.lua"
#include "script/plane/plane_targetting.lua"
#include "script/plane/plane_physics.lua"
#include "script/plane/plane_physics_simple.lua"
#include "script/plane/plane_presets.lua"
#include "script/plane/planes_manage.lua"
#include "script/projectiles.lua"
#include "script/registry.lua"
#include "script/sounds.lua"
#include "script/ui/ui.lua"
#include "script/ui/ui_compass.lua"
#include "script/ui/ui_draw.lua"
#include "script/ui/ui_options.lua"
#include "script/ui/ui_textBinding.lua"
#include "script/ui/ui_tools.lua"
#include "script/weapons.lua"




PLANES = {} -- plane objects.
PLANES_VEHICLES = {} -- Find plane object by vehicle id

ShouldDrawIngameOptions = false
PLANE_DEAD_HEALTH = 0.6



function init()

    Init_Utils()

    Init_PLANES()
    Init_AIPLANES()
    Init_Config()
    Init_Sounds()
    Init_Projectiles()
    Init_Enemies()
    Init_Draw()
    Manage_SmallMapMode()


    SelectedCamera = CameraPositions[1]

    SetString("hud.notification", "Note: The F-15 landing gear system is still in development.")

end

function tick()

    Tick_Utils()

    AllVehicles = FindVehicles("", true)

    FlightMode = GetString("savegame.mod.FlightMode")
    FlightModeSet = GetBool("savegame.mod.flightmodeset")

    if not FlightModeSet then
        SetString("savegame.mod.FlightMode", FlightModes.simple)
        SetBool("savegame.mod.flightmodeset", true)
        print("backup flightmode simple")
    end

    dbw("PlayerInPlane", PlayerInPlane)

    if PlayerInPlane and InputPressed(Config.toggleOptions) then

        ShouldDrawIngameOptions = not ShouldDrawIngameOptions
        SetBool("level.showedOptions", true)

    elseif not PlayerInPlane then

        ShouldDrawIngameOptions = false

    end


    -- Root of plane management.
    Tick_PLANES()

    Tick_aiplanes()
    Manage_Spawning()
    aiplane_AssignPlanes()
    Manage_DebugMode()
    Manage_SmallMapMode()
    Projectiles_Manage()
    Manage_Enemies()
    plane_RunPropellers()

end

function update()
    Update_PLANES()
end

function draw()

    UiColor(1,1,1, 1)
    UiTextShadow(0,0,0, 1, 0.3, 0)
    UiFont("bold.ttf", 24)

    Draw_PLANES()

    if Config.draw_projectiles then
        Projectiles_Draw(200, 500)
    end

end



function Manage_Spawning()

    local planeVehicles = FindVehicles('planeVehicle', true)
    for key, vehicle in pairs(planeVehicles) do

        if not HasTag(vehicle, 'planeActive') then

            SetTag(vehicle, 'planeActive')
            local ID = GetTagValue(vehicle, "Plane_ID")
            local plane = createPlaneObject(ID)

            table.insert(PLANES, plane)
            PLANES_VEHICLES[plane.vehicle] = PLANES[#PLANES]

        end

    end

end

function handleCommand(cmd)
    HandleQuickload(cmd)
end

function HandleQuickload(cmd)
    local words = splitString(cmd, " ")
    for index, word in ipairs(words) do
        if word == "quickload" then

            Init_Config()
            print("Loaded quicksave.")

        end
        break
    end
end

