#include "script/ai_SAMS.lua"
#include "script/config_smallMapMode.lua"
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
#include "script/registry.lua"
#include "script/sounds.lua"
#include "script/ui/compass.lua"
#include "script/ui/draw.lua"
#include "script/ui/draw.lua"
#include "script/ui/ui.lua"
#include "script/ui/uiDebug.lua"
#include "script/ui/uiModItem.lua"
#include "script/ui/uiOptions.lua"
#include "script/ui/uiPanes.lua"
#include "script/ui/uiPresetSystem.lua"
#include "script/ui/uiTextBinding.lua"
#include "script/ui/uiTools.lua"
#include "script/umf.lua"
#include "script/utility.lua"
#include "script/weapons/projectiles.lua"
#include "script/weapons/weapons.lua"



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


function init()

    Tick = 1

    checkRegInitialized()

    if GetString('savegame.mod.options.keys.respawn') == '' then
        SetString('savegame.mod.options.keys.respawn', 'y')
    end
    if GetString('savegame.mod.options.keys.smallMapMode') == '' then
        SetString('savegame.mod.options.keys.smallMapMode', 'o')
    end
    if GetString('savegame.mod.options.keys.toggleMissileLock') == '' then
        SetString('savegame.mod.options.keys.toggleMissileLock', 'x')
    end
    if GetString('savegame.mod.options.keys.changeTarget') == '' then
        SetString('savegame.mod.options.keys.changeTarget', 't')
    end
    respawnKey = GetString('savegame.mod.options.keys.respawn')
    smallMapModeKey = GetString('savegame.mod.options.keys.smallMapMode')
    toggleMissileLockKey = GetString('savegame.mod.options.keys.toggleMissileLock')
    changeTargetKey = GetString('savegame.mod.options.keys.changeTarget')
    showRespawnText = GetBool('savegame.mod.options.showRespawnText')

    -- Init core functions.
    initSounds()
    initPlanes()
    initProjectiles()

    SmallMapMode = false
    config_setSmallMapMode(SmallMapMode)

    InitEnemies()

end
function tick()

    if GetString('savegame.mod.options.flightmode') == "" then
        SetString("savegame.mod.options.flightmode", FlightModes.simulation)
    end

    Config = {
        flightMode = GetString('savegame.mod.options.flightmode')
    }

    if InputPressed(smallMapModeKey) then
        ShouldDrawIngameOptions = not ShouldDrawIngameOptions
        SetBool("level.showedOptions", true)
    end

    -- respawnKey = GetString('savegame.mod.options.keys.respawn')
    respawnKey = "-asd"
    smallMapModeKey = GetString('savegame.mod.options.keys.smallMapMode')
    toggleMissileLockKey = GetString('savegame.mod.options.keys.toggleMissileLock')
    changeTargetKey = GetString('savegame.mod.options.keys.changeTarget')

    manageConfig()
    manageSpawning()
    manageActiveProjectiles()

    -- Root of plane management.
    planesTick()
    planesUpdate()


    local propellers = FindJoints('planePropeller', true)
    for key, propeller in pairs(propellers) do
        SetJointMotor(propeller, 15)
    end

    handlePlayerInWater()
    manageDebugMode()

    TickEnemies()

    Tick = Tick + 1

end
function update()
end



function manageSpawning()

    local planeVehicles = FindVehicles('planeVehicle', true)
    for key, vehicle in pairs(planeVehicles) do

        if not HasTag(vehicle, 'planeActive') then

            local plane = createPlaneObject(vehicle)
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
    -- dbw("Script valid", scriptValid)
end
function getCurrentPlane()
    return curPlane
end



function CompressRange(val, lower, upper)
    return (val-lower) / (upper-lower)
end
