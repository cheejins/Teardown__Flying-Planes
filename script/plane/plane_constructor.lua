-- Build the plane data object (entities and properties)
function createPlaneObject(ID)

    -- Default plane is a mig29


    local _vehicle = nil

    for index, v in ipairs(FindVehicles("Plane_ID", true)) do
        if GetTagValue(v, "Plane_ID") == ID then
            _vehicle = v
            print("found plane ", ID)
            break
        end
    end


    local plane = {

        -- references
            id = ID,
            isAlive = true,
            model = GetTagValue(_vehicle, "planeModel"),

            vehicle = _vehicle,
            engineType = GetTagValue(_vehicle, "planeType"),
            body = GetVehicleBody(_vehicle),

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


    plane.getLiftSpeedFac = function()
        local x = plane.speed
        local b = plane.speed/3
        local result = (1/b)*(x^2)
        if x >= b then
            result = x
        end
        return result
    end


    plane_update(plane)


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
        }
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


    -- fwd pos
    plane.getFwdPos = function(distance)
        return TransformToParentPoint(GetBodyTransform(plane.body), Vec(0,0,distance or -500))
    end


    -- Returns the angle between the plane's direction and velocity
    plane.getForwardVelAngle = function()

        local lvel = TransformToLocalVec(plane.tr, plane.vel)
        lvel = 1 - math.rad(math.abs(lvel[1] + lvel[2]))
        lvel = clamp(lvel, 0, 1)

        return lvel

    end


        --- Returns the angle of attack of the chord line (used to calculate airfoil lift and drag)
    plane.getAoA = function()

        local lVel = TransformToLocalVec(plane.tr, plane.vel) -- local velocity
        local aoa =  (-(math.deg(math.atan2(lVel[3], lVel[2]))) - 90) * math.pi

        if plane.speed < 0 then
            aoa = 0.00001
        end

        return aoa
    end

    plane.getYawAoA = function()
        local lVel = TransformToLocalVec(plane.tr, plane.vel) -- local velocity
        local aoa =  (-(math.deg(math.atan2(lVel[1], -lVel[3])))) * math.pi
        if plane.speed < 0 then
            aoa = 0.00001
        end
        return aoa
    end

    plane.getRollAoA = function()
        local lVel = TransformToLocalVec(plane.tr, plane.vel) -- local velocity
        local aoa =  (-(math.deg(math.atan2(lVel[1], -lVel[2])))) * math.pi

        if plane.speed < 0 then
            aoa = 0.00001
        end

        return aoa
    end





    --- Sets thrust between 0 and 1
    plane.setThrust = function(sign)
        plane.thrust = plane.thrust + plane.thrustIncrement * sign
    end

    --- Accelerates towards the set thrust (simulates gradual engine wind up/down)
    plane.setThrustOutput = function()
        if plane.thrustOutput <= plane.thrust -1 then
            plane.thrustOutput = plane.thrustOutput + plane.thrustAcc
        elseif plane.thrustOutput >= plane.thrust + 1 then
            plane.thrustOutput = plane.thrustOutput - plane.thrustDecc
        end
    end

    convertPlaneToPreset(plane)

    -- Lowest point ooint of the plane (light entity on the wheel)
    for index, light in ipairs(FindLights('ground', true)) do
        if GetBodyVehicle(GetShapeBody(GetLightShape(light))) == plane.vehicle then
            plane.groundDist = VecSub(
                GetLightTransform(light).pos,
                plane.tr.pos)[2]
           break
        end
    end


    SetTag(plane.vehicle, 'planeActive')

    return plane
end


function plane_update(plane)

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
    plane.liftSpeedFac = plane.getLiftSpeedFac()

end



function GetPitchAoA(tr, vel)

    local lVel = TransformToLocalVec(tr, vel) -- local velocity
    local aoa = math.deg(math.atan2(-lVel[2], -lVel[3]))

    aoa = math.rad(aoa)
    aoa = math.sin(aoa)

    -- if aoa <= -0.999 then
    --     aoa = 0
    -- elseif aoa >= 0.999 then
    --     aoa = 0
    -- end
    return aoa

end

function GetYawAoA(tr, vel)

    local lVel = TransformToLocalVec(tr, vel) -- local velocity
    local aoa = math.deg(math.atan2(-lVel[1], -lVel[2]))

    aoa = math.rad(aoa)
    aoa = math.sin(aoa)

    -- if aoa <= -0.999 then
    --     aoa = 0
    -- elseif aoa >= 0.999 then
    --     aoa = 0
    -- end
    return aoa

end

function GetRollAoA(tr, vel)

    local lVel = TransformToLocalVec(tr, vel) -- local velocity
    local aoa = math.deg(math.atan2(-lVel[1], -lVel[3]))

    aoa = math.rad(aoa)
    aoa = math.sin(aoa)

    -- if aoa <= -0.999 then
    --     aoa = 0
    -- elseif aoa >= 0.999 then
    --     aoa = 0
    -- end
    return aoa

end
