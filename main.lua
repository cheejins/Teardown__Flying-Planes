#include "script/camera.lua"
#include "script/config_smallMapMode.lua"
#include "script/debug.lua"
#include "script/draw.lua"
#include "script/managePlanes.lua"
#include "script/mod_config.lua"
#include "script/particles.lua"
#include "script/plane.lua"
#include "script/planeConstructor.lua"
#include "script/projectiles.lua"
#include "script/planeHud.lua"
#include "script/sounds.lua"
#include "script/umf.lua"
#include "script/utility.lua"
#include "script/weapons.lua"


PLANE_IDS = 0 -- Assigns unique plane ids.
planeObjectList = {}

scriptValid = false
hintsOff = false
isDemoMap = false
curPlane = nil

enemiesKey = "t"


function init()

    if GetString('savegame.mod.options.keys.respawn') == '' then
        SetString('savegame.mod.options.keys.respawn', 'y')
    end
    if GetString('savegame.mod.options.keys.smallMapMode') == '' then
        SetString('savegame.mod.options.keys.smallMapMode', 'o')
    end
    if GetString('savegame.mod.options.keys.toggleMissileLock') == '' then
        SetString('savegame.mod.options.keys.toggleMissileLock', 'c')
    end
    if GetString('savegame.mod.options.keys.changeTarget') == '' then
        SetString('savegame.mod.options.keys.changeTarget', 't')
    end
    respawnKey = GetString('savegame.mod.options.keys.respawn')
    smallMapModeKey = GetString('savegame.mod.options.keys.smallMapMode')
    toggleMissileLockKey = GetString('savegame.mod.options.keys.toggleMissileLock')
    changeTargetKey = GetString('savegame.mod.options.keys.changeTarget')

    initSounds()
    initPlanes()
    initProjectiles()

    SmallMapMode = false
    config_setSmallMapMode(SmallMapMode)

end
function tick()

    respawnKey = GetString('savegame.mod.options.keys.respawn')
    smallMapModeKey = GetString('savegame.mod.options.keys.smallMapMode')
    toggleMissileLockKey = GetString('savegame.mod.options.keys.toggleMissileLock')
    changeTargetKey = GetString('savegame.mod.options.keys.changeTarget')


    SetBool('level.planeScriptActive', true)

    manageConfig()
    manageSpawning()
    manageActiveProjectiles()

    -- Root of plane management.
    planesTick()

    local propellers = FindJoints('planePropeller', true)
    for key, propeller in pairs(propellers) do
        SetJointMotor(propeller, 15)
    end

    handlePlayerInWater()
    manageDebugMode()


    for key, plane in pairs(FindVehicles('planeVehicle', true)) do

        if GetVehicleHealth(plane) < 0.5 then
            local bodyPos = GetBodyTransform(GetVehicleBody(plane)).pos
            particle_fire(bodyPos, math.random()*3)
            particle_blackSmoke(VecAdd(bodyPos, Vec(0,1,0)), math.random()*6)
        end

    end

end
function update()
    planesUpdate()
end



function manageSpawning()

    local planeVehicles = FindVehicles('planeVehicle', true)
    for key, vehicle in pairs(planeVehicles) do

        if not HasTag(vehicle, 'planeActive') then

            local plane = createPlaneObject(vehicle, GetBodyVehicle(vehicle))
            SetTag(vehicle, 'planeActive')
            print('Plane spawned. ' .. plane.id)

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
    dbw("Script valid", scriptValid)
end
function getCurrentPlane()
    return curPlane
end
