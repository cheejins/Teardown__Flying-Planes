function planeSteer_simple(plane)

    local pTr = plane.tr

    -- local ang = plane_getForwardVelAngle_old()/10

    local speed = plane.speed
    local speedClamped = (clamp(speed, 0.01, speed + 0.01))

    local divSpeed = speedClamped / plane.topSpeed
    local turnDiv = 50
    local turnAmt = math.abs(getQuadtratic(divSpeed) / turnDiv)

    if speedClamped > plane.topSpeed /2 then
        turnAmt = math.abs(1 / turnDiv)
    end



    -- Roll
    if InputDown("a") or InputDown("d") then
        local yawSign = 1
        if InputDown("d") then yawSign = -1 end -- Determine yaw direction
        local yawAmt = yawSign * turnAmt * turnDiv / plane.rollVal * 3 * CONFIG.smallMapMode.turnMult
        pTr.rot = QuatRotateQuat(pTr.rot, QuatEuler(0, 0, yawAmt))
    end
    if InputDown("z") then
        local yawSign = 1
        local yawAmt = yawSign * turnAmt * turnDiv / plane.rollVal * 2 * CONFIG.smallMapMode.turnMult
        pTr.rot = QuatRotateQuat(pTr.rot, QuatEuler(0, yawAmt, 0))
    end
    if InputDown("c") then
        local yawSign = -1
        local yawAmt = yawSign * turnAmt * turnDiv / plane.rollVal * 2 * CONFIG.smallMapMode.turnMult
        pTr.rot = QuatRotateQuat(pTr.rot, QuatEuler(0, yawAmt, 0))
    end




    local crosshairRot = QuatLookAt(plane.tr.pos, crosshairPos)

    -- Roll plane based on crosshair
    local rollAmt = VecNormalize(TransformToLocalPoint(plane.tr, crosshairPos))
    rollAmt[1] = rollAmt[1] * turnAmt * -350 / plane.rollVal
    pTr.rot = QuatRotateQuat(pTr.rot, QuatEuler(0, 0, rollAmt[1]))


    -- local crosshairRot = QuatLookAt(plane.tr.pos, crosshairPos)

    -- local camDir = QuatToDir(QuatEuler(plane.camera.cameraY, plane.camera.cameraX, 0))
    -- local planeDir = QuatToDir(plane.tr.rot)

    -- -- Roll plane based on crosshair
    -- local rollAmt = VecNormalize(TransformToLocalPoint(planeDir, camDir))
    -- rollAmt[1] = rollAmt[1] * -5
    -- dbw('rollAmt[1]', rollAmt[1])
    -- pTr.rot = QuatRotateQuat(pTr.rot, QuatEuler(0, 0, rollAmt[1]))


    -- Align with crosshair pos
    pTr.rot = MakeQuaternion(QuatCopy(pTr.rot))
    pTr.rot = pTr.rot:Approach(crosshairRot, turnAmt / plane.yawFac * CONFIG.smallMapMode.turnMult)

    SetBodyTransform(plane.body, pTr)


end


function planeMove_simple(plane)

    local speed = plane.speed

    if InputDown("shift") and plane.thrust + plane.thrustIncrement <= 101 then
        plane.thrust = plane.thrust + 1
    end
    if InputDown("ctrl") and plane.thrust - plane.thrustIncrement >= 0 then
        plane.thrust = plane.thrust - 1
    end

    if InputDown("space") then
        ApplyBodyImpulse(
            plane.body,
            TransformToParentPoint(
                plane.tr, Vec(0,0,-5)),
            plane.getFwdPos(speed*plane.brakeImpulseAmt))
        plane.status = 'Air Braking'
    end

    -- stall speed
    if speed < plane.topSpeed then

        plane.setThrustOutput()

        local thrustSpeed = plane.thrust/100
        local thrustSpeedMult = plane.speed < plane.topSpeed * thrustSpeed
        if thrustSpeedMult then

            local thrustImpulseAmt = plane.thrust * (-plane.thrustImpulseAmount * ((plane.thrustOutput^1.3) / plane.thrust)) * CONFIG.smallMapMode.dragMult
            ApplyBodyImpulse(
                plane.body,
                plane.tr.pos,
                TransformToParentPoint(plane.tr, Vec(0,0,thrustImpulseAmt)))
        end

    end

    -- local angVel = GetBodyAngularVelocity(plane.body)
    -- local turbulence = VecScale(Vec(math.random()-0.5, math.random()-0.5, math.random()-0.5), speed/500)
    -- turbulence = VecAdd(turbulence, angVel)
    -- SetBodyAngularVelocity(plane.body, turbulence)

end


-- forces
function plane_applyForces_simple(plane)

--[LIFT]
    -- Lift determined by AoA and speed
    local aoa = plane.getAoA()
    local speed = plane.speed

    local liftSpeedInterval = plane.topSpeed/5 * CONFIG.smallMapMode.liftMult
    local liftSpeed = speed
    local liftMult = 0.004

    if speed < liftSpeedInterval and speed > 0 then
        liftSpeed = liftSpeed^0.2 -- (x^2)/100
    end
    local liftAmt = aoa * liftSpeed * liftMult

    -- Add upwards velocity
    local pTr = plane.tr
    if aoa > -180 and aoa < 180 then
        ApplyBodyImpulse(
            plane.body,
            plane.tr.pos,
            TransformToParentPoint(
                pTr,
                Vec(
                    0,
                    plane.liftSpeedFac*liftAmt*1000,
                    0)))
    end


    -- Yaw determined by AoA and speed
    local aoa = nZero(plane.getYawAoA())
    local speed = gtZero(plane.speed)

    -- local yawSpeedInterval = plane.topSpeed/5
    local yawSpeed = gtZero(speed)
    local yawAmt = aoa * yawSpeed * 15 ^ 1.2
    -- DebugWatch("yawAmt", yawAmt)
    -- DebugWatch("rollAoA", plane.getRollAoA())

    -- Add upwards velocity
    local pTr = plane.tr
    ApplyBodyImpulse(
        plane.body,
        plane.tr.pos,
        TransformToParentPoint(pTr, Vec(yawAmt, 0, 0)))

    local newVel = GetBodyVelocity(plane.body)
    local newVelY = VecScale(newVel, 0.1)
    newVelY = newVel[2]
    SetBodyVelocity(plane.body, Vec(newVel[1], newVelY, newVel[3]))

-- [DRAG]

    -- fwdvel drag
    local vel = gtZero(plane.totalVel)
    local speed = gtZero(plane.speed)

    -- low fwd vel angle * speed = min drag
    local fwdDragAmt = (plane_getForwardVelAngle_old(plane) * plane.speed+10) * vel/plane.topSpeed/2
    local fwdDragDir = VecScale(plane.vel, -fwdDragAmt)

    plane.fwdDragAmt = 1.7 * CONFIG.smallMapMode.dragMult
    local fwdDragDirGrav = Vec(
        fwdDragDir[1],
        fwdDragDir[2] * speed / vel,
        fwdDragDir[3])
    ApplyBodyImpulse(plane.body, plane.tr.pos, fwdDragDirGrav)


    -- Diminish ang vel
    SetBodyAngularVelocity(plane.body,
        Vec(GetBodyAngularVelocity(plane.body)[1] * 0.97,
            GetBodyAngularVelocity(plane.body)[2] * 0.97,
            GetBodyAngularVelocity(plane.body)[3] * 0.97))

end


function plane_getForwardVelAngle_old(plane)
    -- - Returns the angle between the plane's direction and velocity

    local velSub = VecNormalize(VecSub(Vec(0,0,0),GetBodyVelocity(plane.body)))
    local velTr = Transform(plane.tr.pos, velSub)

    local VecVel =
        VecSub(
            plane.tr.pos,
            TransformToParentPoint(velTr, VecScale(GetBodyVelocity(plane.body), -1)))

    local VecTr =
        VecSub(
            plane.tr.pos,
            TransformToParentPoint(plane.tr, Vec(0,0,1)))

    local c = {VecVel[1], VecVel[2], VecVel[3]}
    local d = {VecTr[1], VecTr[2], VecTr[3]}

    local angle = math.deg(math.acos(myDot(c, d) / (myMag(c) * myMag(d))))
    if plane.speed < 0 then angle = 1 end

    return angle
end