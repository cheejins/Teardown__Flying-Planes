-- Build the plane data object (entities and properties)
function createPlaneObject(ID)

    -- Default plane is a mig29


    local _vehicle = nil

    for index, v in ipairs(FindVehicles("Plane_ID", true)) do
        if GetTagValue(v, "Plane_ID") == ID then
            _vehicle = v
            -- print("found plane ", ID)
            break
        end
    end


    local plane = {

        -- references
            id = ID,
            vehicle = _vehicle,
            body = GetVehicleBody(_vehicle),
            model = GetTagValue(_vehicle, "planeModel"),
            engineType = GetTagValue(_vehicle, "planeType"),
            health = 1,
            isAlive = true,
            engineOn = true,
            flaps = false,

        -- const values
            speed = 0,
            topSpeed = 150, --- m/s
            acceleration = 1,
            engineVol = 50,
            gunPosOffset = Vec(0,-0.5,-16),

        -- misc
            status = "-",
            seatPosOffset = Vec(0,0,-10),
            brakeImpulseAmt = 500,
            timeOfDeath = 0,
            groundDist = 0,


        -- weapons
            isArmed = true,
        -- bullets
            bullets = {
                timer = 0,
                explosionSize = 0,
                rpm = 650,
                bulletTimer = 0,
                type = "mg"
            },
        -- missiles
            missiles = {
                timer = 0,
                explosionSize = 2.5,
                rpm = 80,
                bulletTimer = 0,
                firePos = "left",
            },

        -- thrust
            thrust = 1, --- Control value for UI. Between 0 and 100.
            thrustAcc = 0.4, --- Adds thrust until thrustOutput reaches thrust percentage.
            thrustDecc = 0.8,
            thrustOutput = 1, --- Realized output thrust.
            thrustIncrement = 2,--- Increment amt per frame.
            thrustImpulseAmount = 100, --- ApplyBodyImpulse() amt.

        -- drag
            fwdDragAmt = 1,

        -- steering
            pitchVal = 1,
            rollVal = 1,
            yawFac = 1,

        -- camera
            freecamDistance = 200,
            camBack = 20,
            camUp = 8,
            camPitch = -7,

        landing_gear = {
            isDown = true,
            rate = 1,
        }

    }


    plane.weap = {
        weaponObjects = GetWeaponLocations(plane),
        secondary_lastIndex = 1
    }

    plane.timers = {
        weap = {
            primary = {time = 0, rpm = 1200},
            secondary = {time = 0, rpm = 120},
            special = {time = 0, rpm = 1200},
        }
    }

    if plane.model == 'a10' then
        plane.timers = {
            weap = {
                primary = {time = 0, rpm = 800},
                secondary = {time = 0, rpm = 90},
                special = {time = 0, rpm = 1},
            }
        }
    end

    plane.targetting = {
        target = 0,
        lock = {
            enabled = true,
            timer = {time = 60/1.2, rpm = 60/1.2},
            locking = false,
            locked = false,
        },
        targetVehicles = {},
    }

    plane.camera = {
        cameraX = 0,
        cameraY = 0,
        zoom = 20,
    }

    plane.exhausts = {}
    local exhaustLights = FindLights('exhaust', true)
    for index, light in ipairs(exhaustLights) do
        local lightBody = GetShapeBody(GetLightShape(light))
        if lightBody == plane.body then
            table.insert(plane.exhausts, light)
        end
    end


    plane_UpdateProperties(plane)
    plane_ProcessHealth(plane)
    plane_AutoConvertToPreset(plane)
    plane_ManageTargetting(plane)
    plane_SetMinAltitude(plane)


    -- plane_builder.lua
    plane.parts = plane_CollectParts_Aero(plane)


    plane.allBodies = {}
    local planeShapes = FindShapes("Plane_ID", true)
    for index, shape in ipairs(planeShapes) do
        if GetTagValue(shape, "Plane_ID") == plane.id then
            table.insert(plane.allBodies, GetShapeBody(shape))
        end
    end


    SetTag(plane.vehicle, 'planeActive')

    return plane

end


function plane_UpdateProperties(plane)

    plane.tr = GetBodyTransform(plane.body)

    -- Velocity
    plane.vel = GetBodyVelocity(plane.body)
    plane.lvel = TransformToLocalVec(plane.tr, plane.vel)
    plane.speed = plane.lvel[3] * -1
    plane.angVel = GetBodyAngularVelocity(plane.body)
    plane.totalVel = math.abs(plane.vel[1]) + math.abs(plane.vel[2]) + math.abs(plane.vel[3])


    plane.playerInPlane = GetPlayerVehicle() == plane.vehicle
    plane.playerInUnbrokenPlane = plane.playerInPlane and plane.isAlive


    plane.forces = plane.forces or Vec(0,0,0)
    plane.speedFac = clamp(plane.speed, 1, plane.speed) / plane.topSpeed

    plane.idealSpeedFactor = clamp(math.sin(math.pi * (plane.speed / plane.topSpeed)), 0, 1)
    plane.liftSpeedFac = plane_getLiftSpeedFac(plane)

end


function plane_SetMinAltitude(plane)
    -- Lowest point ooint of the plane (light entity on the wheel)
    for index, light in ipairs(FindLights('ground', true)) do
        if GetBodyVehicle(GetShapeBody(GetLightShape(light))) == plane.vehicle then
            plane.groundDist = VecSub(
                GetLightTransform(light).pos,
                plane.tr.pos)[2]
            break
        end
    end
end
