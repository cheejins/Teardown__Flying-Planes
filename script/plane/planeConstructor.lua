function createPlaneObject(_vehicle)

    -- Default plane is a mig29

    PLANE_IDS = PLANE_IDS + 1

    local body = GetVehicleBody(_vehicle)

    local plane = {

        -- references
            id = PLANE_IDS,
            model = GetTagValue(_vehicle, "planeModel"),

            vehicle = _vehicle,
            engineType = GetTagValue(_vehicle, "planeType"),
            body = body,

            bodyShapes = GetBodyShapes(_body),
            partsShapes = {
                engine      = FindShape("plane_engine", true),
                wings = {
                    left    = FindShape("plane_wing_left", true),
                    right   = FindShape("plane_wing_right", true),
                },
                tail        = FindShape("plane_tail", true),
                elevators   = FindShape("plane_elevators", true),
                rudder      = FindShape("plane_rudder", true),
            },

        -- const values
            topSpeed = 150, --- m/s
            acceleration = 1,
            engineVol = 50,
            gunPosOffset = Vec(0,-0.5,-16),

        -- misc
            status = "-",
            taxiModeEnabled = true,
            seatPosOffset = Vec(0,0,-10),
            brakeImpulseAmt = 500,
            isAlive = true,
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

    plane.dirs = {Vec()}


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



    -- fwd vel
    plane.getFwdVel = function()
        if plane.totalVel == 0 then return 0.00001 end
        local fwdVel = plane.speed / plane.totalVel
        if fwdVel < 0.2 then return 0.2 end
        return fwdVel
    end

    -- fwd pos
    plane.getFwdPos = function(distance)
        return TransformToParentPoint(GetBodyTransform(plane.body), Vec(0,0,distance or -500))
    end

    -- Returns normalized direction vector. fwd distance is -z
    plane.getDirection = function(distance)
        return VecNormalize(VecSub(GetBodyTransform(plane.body).pos, TransformToParentPoint(GetBodyTransform(plane.body), Vec(0,0,distance or -500))))
    end

    -- Get direction with offset. Can be used for lift.
    plane.getDirectionOffset = function(v1,v2,v3)
        return VecNormalize(VecSub(
            plane.tr.pos,
            TransformToParentPoint(
                GetBodyTransform(
                    plane.body),
                    Vec(v1 or 0, v2 or 0, v3 or 0))))
    end

    -- Returns the angle between the plane's direction and velocity
    plane.getForwardVelAngle = function()

        local angle = QuatAngle(plane.tr.rot, DirToQuat(plane.vel))
        angle = clamp(angle, 1, angle)

        return angle

    end

    -- Returns the angle of attack of the chord line (used to calculate airfoil lift and drag)
    plane.getPitchAoA = function()

        local lVel = TransformToLocalVec(plane.tr, plane.vel) -- local velocity
        local aoa =  (-(math.deg(math.atan2(lVel[3], lVel[2]))) - 90) * math.pi

        return aoa

    end

    plane.getYawAoA = function()

        local lVel = TransformToLocalVec(plane.tr, plane.vel) -- local velocity
        local aoa =  (-(math.deg(math.atan2(lVel[1], -lVel[3]))) - 90) * math.pi

        return aoa

    end

    plane.getRollAoA = function()

        local lVel = TransformToLocalVec(plane.tr, plane.vel) -- local velocity
        local aoa =  (-(math.deg(math.atan2(lVel[1], -lVel[2]))) - 90) * math.pi

        return aoa

    end



    -- - plane.thrust*amt. amt+ = larger output.
    plane.getThrustFac = function(amt)
        return plane.thrust * (amt or 1)
    end
    --- 0 <= thrust <= 100
    plane.setThrust = function(sign)
        plane.thrust = plane.thrust + plane.thrustIncrement * sign
    end

    --- acc/decc until plane.thrustOutput = plane.thrust
    plane.setThrustOutput = function()
        if plane.thrustOutput <= plane.thrust -1 then
            plane.thrustOutput = plane.thrustOutput + plane.thrustAcc
        elseif plane.thrustOutput >= plane.thrust + 1 then
            plane.thrustOutput = plane.thrustOutput - plane.thrustDecc
        end
    end

    --- Returns the ideal turn speed, which is closest to plane.topSpeed/2. Exponential approach to ideal val.
    plane.getIdealSpeedFactor = function(x, upperLim)
        local s = x or plane.speed
        local m = plane.topSpeed*0.5
        local a = 2
        local lowOffset = 1.4 -- transform function right
        -- Plug this into desmos
        --[[ -1\cdot\left(\frac{\left(\left(\left(x-\frac{150}{1.5}\right)\cdot2\right)^{\ 2\ }\right)}{\left(40\right)}\right)+100]]
        local isf =
        (-1*((((s-(m/lowOffset))*a)^2)/((m/10)^2))+101)/100

        if upperLim and s > m then
            return isf * 2
        end

        return isf
    end

    plane.applyTurbulence = function()
    end

    -- forces
    plane.applyForces = function()

    -- --[LIFT]
    --     -- Lift determined by AoA and speed
    --     local aoa = plane.getPitchAoA()
    --     local speed = plane.speed

    --     local liftSpeedInterval = plane.topSpeed/5 * CONFIG.smallMapMode.liftMult
    --     local liftSpeed = speed
    --     local liftMult = 0.004

    --     if speed < liftSpeedInterval and speed > 0 then
    --         liftSpeed = liftSpeed^0.2 -- (x^2)/100
    --     end
    --     local liftAmt = aoa * liftSpeed * liftMult

    --     -- Add upwards velocity
    --     local pTr = plane.tr
    --     if aoa > -180 and aoa < 180 then
    --         ApplyBodyImpulse(
    --             plane.body,
    --             plane.tr.pos,
    --             TransformToParentPoint(
    --                 pTr,
    --                 Vec(
    --                     0,
    --                     plane.getLiftSpeedFac()*liftAmt*1000,
    --                     0)))
    --     end


    --     local vel = plane.vel

    --     -- Yaw determined by AoA and speed
    --     local aoa = nZero(plane.getYawAoA())
    --     local speed = gtZero(plane.speed)

    --     -- local yawSpeedInterval = plane.topSpeed/5
    --     local yawSpeed = gtZero(speed)
    --     local yawAmt = aoa * yawSpeed * 15 ^ 1.2
    --     -- DebugWatch("yawAmt", yawAmt)
    --     -- DebugWatch("rollAoA", plane.getRollAoA())

    --     -- Add upwards velocity
    --     local pTr = plane.tr
    --     ApplyBodyImpulse(
    --         plane.body,
    --         plane.tr.pos,
    --         TransformToParentPoint(pTr, Vec(yawAmt, 0, 0)))

    --     -- local newVel = plane.vel
    --     -- local newVelY = VecScale(newVel, 0.1)
    --     -- newVelY = newVel[2]
    --     -- SetBodyVelocity(plane.body, Vec(newVel[1], newVelY, newVel[3]))


        if VecLength(plane.vel) >= 1 or VecLength(plane.vel) <= -1 then


            local x = 0
            local y = 0
            local z = 0

            local x = math.deg(GetRollAoA(plane.tr, plane.vel))
            local y = math.deg(GetPitchAoA(plane.tr, plane.vel))
            -- local z = math.deg(GetYawAoA(plane.tr, plane.vel))

            local speedFac = clamp(plane.speed, 0.00000001, plane.speed) / plane.topSpeed


            dbw("AERO FORCE X", sfn(x))
            dbw("AERO FORCE Y", sfn(y))
            dbw("AERO FORCE Z", sfn(z))
            dbw("SPEED FAC", speedFac)


            local forces = Vec(x,y,z)
            local imp = GetBodyMass(plane.body)/20 * speedFac

            -- imp = imp * plane.getIdealSpeedFactor()
            -- imp = clamp(imp, 0, imp)

            dbw("imp", imp)


            ApplyBodyImpulse(plane.body, plane.tr.pos, TransformToParentPoint(plane.tr, VecScale(forces, imp)))


            DebugLine(plane.tr.pos, TransformToParentPoint(plane.tr, forces) , 1,1,0, 1)
            DebugLine(plane.tr.pos, VecAdd(plane.tr.pos, plane.vel) , 1,0.25,0, 1)
            DebugLine(plane.tr.pos, TransformToParentPoint(plane.tr, Vec(0,0,-10)) , 1,1,1, 1)

        end


        -- Diminish ang vel
        SetBodyAngularVelocity(plane.body, VecScale(GetBodyAngularVelocity(plane.body), 0.98))

    end

    plane.getFwdDragAmt = function()
        return plane.fwdDragAmt
    end

    plane.getLiftSpeedFac = function()
        local x = plane.speed
        local b = plane.speed/3
        local result = (1/b)*(x^2)
        if x >= b then
            result = x
        end
        return result
    end


    function plane.respawnPlayer ()
        if plane.health <= 0.5 then
            if InputPressed("y") then
                SetPlayerVehicle(0)
                RespawnPlayer()
            end
        end
    end

    convertPlaneToPreset(plane)

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
    plane.speed = TransformToLocalVec(plane.tr, plane.vel)[3] * -1
    plane.angVel = GetBodyAngularVelocity(plane.body)
    plane.totalVel = math.abs(plane.vel[1]) + math.abs(plane.vel[2]) + math.abs(plane.vel[3])


    -- Health
    plane.health = GetVehicleHealth(plane.vehicle)
    plane.isAlive = plane.health > 0.5
    plane.playerInPlane = GetPlayerVehicle() == plane.vehicle
    plane.playerInUnbrokenPlane = plane.playerInPlane and plane.isAlive


    -- local x,y,z = GetQuatEuler(GetBodyTransform(plane.body).rot)
    -- plane.dirs[#plane.dirs + 1] = Vec(x,y,z)
    plane.dirs[#plane.dirs + 1] = MakeQuaternion()


    plane.angleChange = VecAngle(
        -- plane.dirs[#plane.dirs],
        -- plane.dirs[#plane.dirs-1] or plane.dirs[#plane.dirs])
        plane.dirs[#plane.dirs],
        plane.dirs[#plane.dirs-1] or plane.dirs[#plane.dirs])


    print(sfn(plane.angleChange))

end



-- Very smooth brain of doing this but it works pretty well.
function GetPitchAoA(tr, vel)

    local lVel = TransformToLocalVec(tr, vel) -- local velocity
    local aoa = math.deg(math.atan2(-lVel[2], -lVel[3]))

    aoa = math.rad(aoa)
    aoa = math.sin(aoa)

    return aoa

end

-- Very smooth brain of doing this but it works pretty well.
function GetYawAoA(tr, vel)

    local lVel = TransformToLocalVec(tr, vel) -- local velocity
    local aoa = math.deg(math.atan2(-lVel[1], -lVel[2]))

    aoa = math.rad(aoa)
    aoa = math.sin(aoa)

    return aoa

end

-- Very smooth brain of doing this but it works pretty well.
function GetRollAoA(tr, vel)

    local lVel = TransformToLocalVec(tr, vel) -- local velocity
    local aoa = math.deg(math.atan2(-lVel[1], -lVel[3]))

    aoa = math.rad(aoa)
    aoa = math.sin(aoa)

    return aoa

end




    -- if aoa >= -90 and aoa <= -45 then -- -z to y

    --     print("7", sfn(aoa))
    --     aoa = -(aoa % 45)

    -- elseif aoa >= 45 and aoa <= 90 then -- y to z

    --     print("", sfn(aoa))
    --     aoa = -(aoa % -45)

    -- elseif aoa >= 90 and aoa <= 135 then

    --     print("", sfn(aoa))
    --     aoa = -(aoa % 45)

    -- elseif aoa >= 135 and aoa <= 180 then

    --     print("", sfn(aoa))
    --     aoa = -(45 - (aoa - 135))

    -- elseif aoa >= -135 and aoa <= -90 then

    --     print("", sfn(aoa))
    --     aoa = -(aoa + 90)

    -- elseif aoa >= -180 and aoa <= -135 then

    --     print("", sfn(aoa))
    --     aoa = (aoa + 180)

    -- end
