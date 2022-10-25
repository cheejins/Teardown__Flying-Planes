#include "Automatic.lua"
#include "script/ai_SAMS.lua"
#include "script/debug.lua"
#include "script/input/controlPanel.lua"
#include "script/input/input.lua"
#include "script/input/keybinds.lua"
#include "script/particles.lua"
#include "script/plane/PLANES_manage.lua"
#include "script/plane/plane_camera.lua"
#include "script/plane/plane_constructor.lua"
#include "script/plane/plane_functions.lua"
#include "script/plane/plane_hud.lua"
#include "script/plane/plane_physics.lua"
#include "script/plane/plane_physics_simple.lua"
#include "script/plane/plane_presets.lua"
#include "script/projectiles.lua"
#include "script/registry.lua"
#include "script/sounds.lua"
#include "script/ui/compass.lua"
#include "script/ui/draw.lua"
#include "script/ui/ui.lua"
#include "script/ui/uiModItem.lua"
#include "script/ui/uiOptions.lua"
#include "script/ui/uiPanes.lua"
#include "script/ui/uiTextBinding.lua"
#include "script/ui/uiTools.lua"
#include "script/umf.lua"
#include "script/utility.lua"
#include "script/weapons.lua"



----------------------------------------------------------------------------------------
-- THIS SCRIPT IS PRETTY OLD AND MESSY. I'M GOING TO BE RECREATING A LOT OF IT.
----------------------------------------------------------------------------------------


PLANES = {}

ShouldDrawIngameOptions = false


function init()

    SelectedCamera = CameraPositions[1]


    Init_Config()
    initSounds()
    initProjectiles()
    InitEnemies()

end


function tick()

    FlightMode = GetString("savegame.mod.FlightMode")
    FlightModeSet = GetBool("savegame.mod.flightmodeset")


    if not FlightModeSet then
        SetString("savegame.mod.FlightMode", FlightModes.simple)
        SetBool("savegame.mod.flightmodeset", true)
        print("backup flightmode simple")
    end


    if InputPressed(Config.toggleOptions) then
        ShouldDrawIngameOptions = not ShouldDrawIngameOptions
        SetBool("level.showedOptions", true)
    end


    Manage_DebugMode()
    Manage_Spawning()
    Manage_ActiveProjectiles()
    Manage_Enemies()
    Manage_SmallMapMode()


    -- Root of plane management.
    PLANES_Tick()


    plane_RunPropellers()

end

function update()
    PLANES_Update()
end



function Manage_Spawning()

    local planeVehicles = FindVehicles('planeVehicle', true)
    for key, vehicle in pairs(planeVehicles) do

        if not HasTag(vehicle, 'planeActive') then

            SetTag(vehicle, 'planeActive')
            local ID = GetTagValue(vehicle, "Plane_ID")
            local plane = createPlaneObject(ID)

            table.insert(PLANES, plane)

        end

    end

end
