-- Build the plane data object (entities and properties)
function createPlaneObject(ID)

    -- Default plane is a mig29


    local _vehicle = nil

    for index, v in ipairs(FindVehicles("Plane_ID", true)) do
        if GetTagValue(v, "Plane_ID") == ID then
            _vehicle = v
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
            brakeOn = false,
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


    plane.targetting = {
        target = 0,
        targetShape = nil,
        homingCapable = true,
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


    plane_UpdateProperties(plane)
    plane_CollectParts_Aero(plane)
    plane_ProcessHealth(plane)
    plane_ManageTargetting(plane)
    plane_SetMinAltitude(plane)
    plane_AutoConvertToPreset(plane)
    plane_init_camera(plane)


    plane.landing_gear = {
        isDown = true,
        startTransition = false,
        rate = 1,
        retract_timer = TimerCreateRPM(0, 60/3)
    }

    plane.vtol = {
        isDown = plane_IsVtolCapable(plane),
        startTransition = false,
        rate = 1,
        retract_timer = TimerCreateRPM(0, 60/2)
    }


    plane.exhausts = {}
    for index, light in ipairs(plane.AllLights) do
        if HasTag(light, "exhaust") then
            table.insert(plane.exhausts, light)
        end
    end


    -- No intercollisions, but leave world collision on.
    for _, shape in ipairs(plane.AllShapes) do
        SetShapeCollisionFilter(shape, 4, 1)
    end


    SetTag(plane.vehicle, 'planeActive')

    return plane

end
