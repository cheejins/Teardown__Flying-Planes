#include "Automatic.lua"
#include "script/ai_SAMS.lua"
#include "script/debug.lua"
#include "script/input/controlPanel.lua"
#include "script/input/input.lua"
#include "script/input/keybinds.lua"
#include "script/particles.lua"
#include "script/plane/camera.lua"
#include "script/plane/managePlanes.lua"
#include "script/plane/planeConstructor.lua"
#include "script/plane/planeFunctions.lua"
#include "script/plane/planeHud.lua"
#include "script/plane/planePresets.lua"
#include "script/plane/plane_physics.lua"
#include "script/plane/plane_physics_simple.lua"
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
#include "script/projectiles.lua"
#include "script/weapons.lua"



----------------------------------------------------------------------------------------
-- THIS SCRIPT IS PRETTY OLD AND MESSY. I'M GOING TO BE RECREATING A LOT OF IT.
----------------------------------------------------------------------------------------



PLANE_IDS = 0 -- Assigns unique plane ids.
planeObjectList = {}

scriptValid = false
hintsOff = false
isDemoMap = false
curPlane = nil


ShouldDrawIngameOptions = false


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

    print("FlightMode", FlightMode)
    print("FlightModeSet", FlightModeSet)


end

function init()

    Init_Config()

    Tick = 1


    -- Init core functions.
    initSounds()
    initPlanes()
    initProjectiles()

    SmallMapMode = false
    config_setSmallMapMode(SmallMapMode)

    InitEnemies()

end
function tick()

    local v = FindVehicles("Plane_ID", true)
    for _, vehicle in ipairs(v) do
        DrawBodyOutline(GetVehicleBody(vehicle), 1,1,1, 1)
    end

    FlightMode = GetString("savegame.mod.FlightMode")
    FlightModeSet = GetBool("savegame.mod.flightmodeset")


    -- if InputPressed("g") then
    --     ClearKey("savegame.mod")
    --     print("Reset reg...")
    -- end


    if not FlightModeSet then
        SetString("savegame.mod.FlightMode", FlightModes.simple)
        SetBool("savegame.mod.flightmodeset", true)
        print("backup flightmode simple")
    end


    -- DebugWatch("FlightMode", FlightMode)
    -- DebugWatch("FlightModeSet", FlightModeSet)


    if InputPressed(Config.toggleOptions) then
        ShouldDrawIngameOptions = not ShouldDrawIngameOptions
        SetBool("level.showedOptions", true)
    end

    manageConfig()
    manageSpawning()
    manageActiveProjectiles()

    -- Root of plane management.
    planesTick()


    local propellers = FindJoints('planePropeller', true)
    for key, propeller in pairs(propellers) do
        SetJointMotor(propeller, 15)
    end

    -- handlePlayerInWater()
    manageDebugMode()

    TickEnemies()

    Tick = Tick + 1

end
function update()
    planesUpdate()
end



function manageSpawning()

    local planeVehicles = FindVehicles('planeVehicle', true)
    for key, vehicle in pairs(planeVehicles) do

        if not HasTag(vehicle, 'planeActive') then

            local plane = createPlaneObject(GetTagValue(vehicle, "Plane_ID"))
            SetTag(vehicle, 'planeActive')
            dbp('Plane spawned. ' .. plane.id)

            table.insert(planeObjectList, plane)

        end

    end

end
function checkScriptValid()
    if FindVehicle("planeVehicle", true) == 0 then
        scriptValid = false
    else
        scriptValid = true
    end
end


function getCurrentPlane()
    return curPlane
end

function CompressRange(val, lower, upper)
    return (val-lower) / (upper-lower)
end

