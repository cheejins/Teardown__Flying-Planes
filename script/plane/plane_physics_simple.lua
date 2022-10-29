-- Steer plane based on camera direction.
function plane_Steer_Simple(plane, rot, disable_input)

    local pTr = plane.tr

    local speed = plane.speed
    local speedClamped = (clamp(speed, 0.01, speed + 0.01))

    local divSpeed = speedClamped / plane.topSpeed
    local turnDiv = 50
    local turnAmt = math.abs(getQuadtratic(divSpeed) / turnDiv)

    if speedClamped > plane.topSpeed /2 then
        turnAmt = math.abs(1 / turnDiv)
    end


    if not disable_input then

        if InputDown("w") and plane.thrust + plane.thrustIncrement <= 101 then
            plane.thrust = plane.thrust + 1
        end
        if InputDown("s") and plane.thrust - plane.thrustIncrement >= 0 then
            plane.thrust = plane.thrust - 1
        end

        if InputDown("space") then
            ApplyBodyImpulse(
                plane.body,
                TransformToParentPoint(
                    plane.tr, Vec(0,0,-5)),
                plane_GetFwdPos(plane, speed*plane.brakeImpulseAmt))
            plane.status = 'Air Braking'
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
            local yawAmt = yawSign * turnAmt * turnDiv / plane.yawFac * 2 * CONFIG.smallMapMode.turnMult
            pTr.rot = QuatRotateQuat(pTr.rot, QuatEuler(0, yawAmt, 0))
        end
        if InputDown("c") then
            local yawSign = -1
            local yawAmt = yawSign * turnAmt * turnDiv / plane.yawFac * 2 * CONFIG.smallMapMode.turnMult
            pTr.rot = QuatRotateQuat(pTr.rot, QuatEuler(0, yawAmt, 0))
        end
    end



    local crosshairRot = rot or QuatLookAt(plane.tr.pos, crosshairPos)

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

-- Apply engine/thrust impulse to move the plane forward.
function plane_Move_Simple(plane)

    local speed = plane.speed

    -- stall speed
    if speed < plane.topSpeed then

        plane_SetThrustOutput(plane)

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

end

-- Apply basic lift and drag.
function plane_ApplyForces_Simple(plane)

--[LIFT]
    -- Lift determined by AoA and speed
    local aoa = plane_old_GetPitchAoA(plane)
    local speed = plane.speed + 1

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
    local aoa = NZero(plane_old_GetYawAoA(plane))
    local speed = GTZero(plane.speed)

    -- local yawSpeedInterval = plane.topSpeed/5
    local yawSpeed = GTZero(speed)
    local yawAmt = aoa * yawSpeed * 15 ^ 1.2
    -- DebugWatch("yawAmt", yawAmt)
    -- DebugWatch("rollAoA", plane_old_GetRollAoA(plane))

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
    local vel = GTZero(plane.totalVel) + 1
    local speed = GTZero(plane.speed) + 1

    -- low fwd vel angle * speed = min drag
    local fwdDragAmt = (plane_GetForwardVelAngle_old(plane) * plane.speed+10) * vel/plane.topSpeed/2
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

--
function plane_GetForwardVelAngle_old(plane)
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

    local angle = math.deg(math.acos(VecDot(c, d) / (VecLength(c) * VecLength(d))))
    if plane.speed < 0 then angle = 1 end

    return angle
end



function plane_old_GetPitchAoA(plane)
    local lVel = TransformToLocalVec(plane.tr, plane.vel) -- local velocity
    local aoa =  (-(math.deg(math.atan2(lVel[3], lVel[2]))) - 90) * math.pi

    if plane.speed < 0 then
        aoa = 0.00001
    end

    return aoa
end

function plane_old_GetYawAoA(plane)
    local lVel = TransformToLocalVec(plane.tr, plane.vel) -- local velocity
    local aoa =  (-(math.deg(math.atan2(lVel[1], -lVel[3])))) * math.pi
    if plane.speed < 0 then
        aoa = 0.00001
    end
    return aoa
end

function plane_old_GetRollAoA(plane)
    local lVel = TransformToLocalVec(plane.tr, plane.vel) -- local velocity
    local aoa =  (-(math.deg(math.atan2(lVel[1], -lVel[2])))) * math.pi

    if plane.speed < 0 then
        aoa = 0.00001
    end

    return aoa
end


function plane_getLiftSpeedFac(plane)
    local x = plane.speed
    local b = plane.speed/3
    local result = (1/b)*(x^2)
    if x >= b then
        result = x
    end
    return result
end