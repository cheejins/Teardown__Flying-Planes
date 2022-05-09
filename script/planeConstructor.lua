function createPlaneObject(_vehicle)

    -- Default plane is a mig29

    PLANE_IDS = PLANE_IDS + 1

    local plane = {

        -- references
            id = PLANE_IDS,
            model = GetTagValue(_vehicle, "planeModel"),
            vehicle = _vehicle,
            engineType = GetTagValue(_vehicle, "planeType"),
            body = GetVehicleBody(_vehicle),
            transform = GetBodyTransform(_body),

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


    -- Properties
    do
        -- tr
        plane.getTransform = function() return GetBodyTransform(plane.body) end
        -- pos
        plane.getPos = function() return plane.getTransform().pos end
        -- vel
        plane.getVel = function() return GetBodyVelocity(plane.body) end
        -- vel scalar
        plane.getTotalVelocity = function ()
            local vel = plane.getVel()
            local totalVel =  math.abs(vel[1]) +  math.abs(vel[2]) +  math.abs(vel[3])
            return totalVel
        end
        -- speed
        plane.getSpeed = function()
            local vel = TransformToLocalVec(
                plane.getTransform(),
                plane.getVel())
            return -vel[3]
        end

        -- fwd vel
        plane.getFwdVel = function()
            if plane.getTotalVelocity() == 0 then return 0.00001 end
            local fwdVel = plane.getSpeed() / plane.getTotalVelocity()
            if fwdVel < 0.2 then return 0.2 end
            return fwdVel
        end

        -- fwd pos
        plane.getFwdPos = function(distance)
            return TransformToParentPoint(GetBodyTransform(plane.body), Vec(0,0,distance or -500))
        end

        plane.getFwdPosOffset = function(x,y,z)
            return TransformToParentPoint(GetBodyTransform(plane.body), Vec(x or 0, y or 0, z or -500))
        end

        --- Returns normalized direction vector. fwd distance is -z
        plane.getDirection = function(distance)
            return VecNormalize(VecSub(GetBodyTransform(plane.body).pos, TransformToParentPoint(GetBodyTransform(plane.body), Vec(0,0,distance or -500))))
        end

        --- Get direction with offset. Can be used for lift.
        plane.getDirectionOffset = function(v1,v2,v3)
            return VecNormalize(VecSub(
                plane.getPos(),
                TransformToParentPoint(
                    GetBodyTransform(
                        plane.body),
                        Vec(v1 or 0, v2 or 0, v3 or 0))))
        end

        plane.getForwardVelAngle = function()
            -- - Returns the angle between the plane's direction and velocity

            local velSub = VecNormalize(VecSub(Vec(0,0,0),GetBodyVelocity(plane.body)))
            local velTr = Transform(plane.getPos(), velSub)

            local VecVel =
                VecSub(
                    plane.getPos(),
                    TransformToParentPoint(velTr, VecScale(GetBodyVelocity(plane.body), -1)))

            local VecTr =
                VecSub(
                    plane.getPos(),
                    TransformToParentPoint(plane.getTransform(), Vec(0,0,1)))

            local c = {VecVel[1], VecVel[2], VecVel[3]}
            local d = {VecTr[1], VecTr[2], VecTr[3]}

            local angle = math.deg(math.acos(myDot(c, d) / (myMag(c) * myMag(d))))
            if plane.getSpeed() < 0 then angle = 1 end

            return angle
        end

        --- Returns the angle of attack of the chord line (used to calculate airfoil lift and drag)
        plane.getAoA = function()

            local lVel = TransformToLocalVec(plane.getTransform(), plane.getVel()) -- local velocity
            local aoa =  (-(math.deg(math.atan2(lVel[3], lVel[2]))) - 90) * math.pi

            if plane.getSpeed() < 0 then
                aoa = 0.00001
            end

            return aoa
        end

        plane.getYawAoA = function()
            local lVel = TransformToLocalVec(plane.getTransform(), plane.getVel()) -- local velocity
            local aoa =  (-(math.deg(math.atan2(lVel[1], -lVel[3])))) * math.pi
            if plane.getSpeed() < 0 then
                aoa = 0.00001
            end
            return aoa
        end

        -- plane.getRollAoA = function()
        --     local lVel = TransformToLocalVec(plane.getTransform(), plane.getVel()) -- local velocity
        --     local aoa =  (-(math.deg(math.atan2(lVel[1], -lVel[2])))) * math.pi

        --     if plane.getSpeed() < 0 then
        --         aoa = 0.00001
        --     end

        --     return aoa
        -- end


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
        plane.getIdealSpeedFactor = function(x)
            local s = x or plane.getSpeed()
            local m = plane.topSpeed*0.5
            local a = 2
            local lowOffset = 1.4 -- transform function right
            -- Plug this into desmos
            --[[ -1\cdot\left(\frac{\left(\left(\left(x-\frac{150}{1.5}\right)\cdot2\right)^{\ 2\ }\right)}{\left(40\right)}\right)+100]]
            local isf =
            -1*(-1*((((s-(m/lowOffset))*a)^2)/((m/10)^2))+101)/100

            if isf < 0 then return isf else return -0.3 end
        end

        plane.applyTurbulence = function()
        end

        -- forces
        plane.applyForces = function()

        --[LIFT]
            -- Lift determined by AoA and speed
            local aoa = plane.getAoA()
            local speed = plane.getSpeed()

            local liftSpeedInterval = plane.topSpeed/5 * CONFIG.smallMapMode.liftMult
            local liftSpeed = speed
            local liftMult = 0.004

            if speed < liftSpeedInterval and speed > 0 then
                liftSpeed = liftSpeed^0.2 -- (x^2)/100
            end
            local liftAmt = aoa * liftSpeed * liftMult

            -- Add upwards velocity
            local pTr = plane.getTransform()
            if aoa > -180 and aoa < 180 then
                ApplyBodyImpulse(
                    plane.body,
                    plane.getPos(),
                    TransformToParentPoint(
                        pTr,
                        Vec(
                            0,
                            plane.getLiftSpeedFac()*liftAmt*1000,
                            0)))
            end


            local vel = plane.getVel()

            -- Yaw determined by AoA and speed
            local aoa = nZero(plane.getYawAoA())
            local speed = gtZero(plane.getSpeed())

            -- local yawSpeedInterval = plane.topSpeed/5
            local yawSpeed = gtZero(speed)
            local yawAmt = aoa * yawSpeed * 15 ^ 1.2
            -- DebugWatch("yawAmt", yawAmt)
            -- DebugWatch("rollAoA", plane.getRollAoA())

            -- Add upwards velocity
            local pTr = plane.getTransform()
            ApplyBodyImpulse(
                plane.body,
                plane.getPos(),
                TransformToParentPoint(pTr, Vec(yawAmt, 0, 0)))

            local newVel = plane.getVel()
            local newVelY = VecScale(newVel, 0.1)
            newVelY = newVel[2]
            SetBodyVelocity(plane.body, Vec(newVel[1], newVelY, newVel[3]))

        -- [DRAG]

            -- fwdvel drag
            local vel = gtZero(plane.getTotalVelocity())
            local speed = gtZero(plane.getSpeed())

            -- low fwd vel angle * speed = min drag
            local fwdDragAmt = (plane.getForwardVelAngle() * plane.getSpeed()+10) * vel/plane.topSpeed/2
            local fwdDragDir = VecScale(plane.getVel(), -fwdDragAmt)

            plane.fwdDragAmt = 1.5 * CONFIG.smallMapMode.dragMult
            local fwdDragDirGrav = Vec(
                fwdDragDir[1],
                fwdDragDir[2] * speed / vel,
                fwdDragDir[3])
            ApplyBodyImpulse(plane.body, plane.getPos(), fwdDragDirGrav)
            -- DebugWatch("fwdDragAmt", sfn(fwdDragAmt))
            -- DebugWatch("fwdDragDir[2]", sfn(fwdDragDir[2] * speed / vel, 4))

            -- Diminish ang vel
            SetBodyAngularVelocity(plane.body,
                Vec(GetBodyAngularVelocity(plane.body)[1] * 0.985,
                    GetBodyAngularVelocity(plane.body)[2] * 0.985,
                    GetBodyAngularVelocity(plane.body)[3] * 0.985))

        end

        plane.getFwdDragAmt = function()
            return plane.fwdDragAmt
        end

        plane.getLiftSpeedFac = function()
            local x = plane.getSpeed()
            local b = plane.getSpeed()/3
            local result = (1/b)*(x^2)
            if x >= b then
                result = x
            end
            return result
        end

    end

    -- Health
    do
        plane.checkPlayerInUnbrokenPlane = function()
            if GetVehicleHealth(plane.vehicle) > 0.5 then return true end
        end
        plane.checkPlayerInPlane = function(_planeBody)
            local vehicle = GetPlayerVehicle()
            if vehicle ~= 0 and _planeBody == plane.body then return true end
        end
        plane.getHealth = function()
            return GetVehicleHealth(plane.vehicle)
        end
        plane.checkIsAlive = function()
            if plane.getHealth() < 0.5 then plane.isAlive = false end
        end
        plane.respawnPlayer = function ()
            if plane.getHealth() <= 0.5 then
                if InputPressed("y") then
                    SetPlayerVehicle(0)
                    RespawnPlayer()
                end
            end
        end
    end

    -- Convert plane
    do
        if plane.model == "spitfire" then
            convertPlaneToSpitfire(plane)
        elseif plane.model == "a10" then
            convertPlaneToA10(plane)
        elseif plane.model == "bombardierJet" then
            convertPlaneToBombardierJet(plane)
        elseif plane.model == "cessna172" then
            convertPlaneToCessna172(plane)
        elseif plane.model == "ac130" then
            convertPlaneToAC130(plane)
        elseif plane.model == "b2" then
            convertPlaneToB2(plane)
        end
    end

    SetTag(plane.vehicle, 'planeActive')

    return plane
end
