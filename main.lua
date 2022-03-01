-- #include "script/ai_enemy_navy.lua"
#include "script/debug.lua"
#include "script/draw.lua"
#include "script/camera.lua"
#include "script/mod_config.lua"
#include "script/plane.lua"
#include "script/planeConstructor.lua"
#include "script/particles.lua"
#include "script/planeHud.lua"
#include "script/sounds.lua"
#include "script/managePlanes.lua"
#include "script/umf.lua"
#include "script/utility.lua"
#include "script/weapons.lua"


PLANE_IDS = 0 -- Assigns unique plane ids.
planeObjectList = {}

scriptValid = false
hintsOff = false
isDemoMap = false
curPlane = nil

respawnKey = "y"
enemiesKey = "t"


function init()
    initSounds()
    initPlanes()
end
function tick()

    SetBool('level.planeScriptActive', true)

    manageSpawning()
    manageActiveMissiles(activeMissiles)
    manageActiveBullets(activeBullets)

    -- Root of plane management.
    planesTick()

    local propellers = FindJoints('planePropeller', true)
    for key, propeller in pairs(propellers) do
        SetJointMotor(propeller, 15)
    end

    handlePlayerInWater()
    manageDebugMode()

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
