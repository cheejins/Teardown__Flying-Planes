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
                plane_StatusAppend(plane, "Air-Braking")
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


    local steerMult = 1
    if IsSimpleFlight() then
        if Config.smallMapMode then
            steerMult = 2
        end
    end


    local crosshairRot = rot or QuatLookAt(plane.tr.pos, crosshairPos)

    if plane_IsVtolCapable(plane) then

        if plane.vtol.isDown then

            pTr.rot = MakeQuaternion(QuatCopy(pTr.rot))
            pTr.rot = pTr.rot:Approach(crosshairRot, 0.012)

        else

            -- Roll plane based on crosshair
            local rollAmt = VecNormalize(TransformToLocalPoint(plane.tr, crosshairPos))
            rollAmt[1] = rollAmt[1] * turnAmt * -350 / (plane.rollVal or 1)
            pTr.rot = QuatRotateQuat(pTr.rot, QuatEuler(0, 0, rollAmt[1]))

            pTr.rot = MakeQuaternion(QuatCopy(pTr.rot))
            pTr.rot = pTr.rot:Approach(crosshairRot, turnAmt / (plane.yawFac or 1) * steerMult)

        end

    else

        -- Roll plane based on crosshair
        local rollAmt = VecNormalize(TransformToLocalPoint(plane.tr, crosshairPos))
        rollAmt[1] = rollAmt[1] * turnAmt * -350 / (plane.rollVal or 1)
        pTr.rot = QuatRotateQuat(pTr.rot, QuatEuler(0, 0, rollAmt[1]))

        -- Align with crosshair pos
        pTr.rot = MakeQuaternion(QuatCopy(pTr.rot))
        pTr.rot = pTr.rot:Approach(crosshairRot, turnAmt / (plane.yawFac or 1) * steerMult)

    end

    if plane.totalVel > 2 then
        SetBodyTransform(plane.body, pTr)
    end

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

            local thrustImpulseAmt = plane.thrust * (-plane.thrustImpulseAmount * ((plane.thrustOutput^1.3) / (plane.thrust or 1))) * CONFIG.smallMapMode.dragMult
            ApplyBodyImpulse(
                plane.body,
                plane.tr.pos,
                TransformToParentPoint(plane.tr, Vec(0,0,thrustImpulseAmt)))
        end

    end

end


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


function plane_getLiftSpeedFac(plane)
    local x = plane.speed
    local b = plane.speed/3
    local result = (1/b)*(x^2)
    if x >= b then
        result = x
    end
    return result
end