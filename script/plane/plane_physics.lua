-- Apply engine/thrust impulse to move the plane forward.
function plane_Move(plane)

    plane_SetThrustOutput(plane)

    if plane.engineOn then

        -- Slow plane speed to thrust amout.
        if plane.speed > 1 and plane.speed/plane.topSpeed > plane.thrust/100 then

            -- ApplyBodyImpulse(
            --     plane.body,
            --     TransformToParentPoint(
            --         plane.tr, Vec(0, 0, -5)),
            --     plane_GetFwdPos(plane, plane.speed * plane.brakeImpulseAmt/2))

        elseif plane.speed < plane.topSpeed then


            if #plane.exhausts >= 1 then

                local exhaust_count = #plane.exhausts

                for index, exhaust_light in ipairs(plane.exhausts) do

                    local tr = GetLightTransform(exhaust_light)

                    local vtolImpulseMult = Ternary(plane.vtol.isDown, 2, 1)

                    local thrustImpulseAmt = plane.thrust * (-plane.thrustImpulseAmount * ((plane.thrustOutput^1.3) / plane.thrust))
                    thrustImpulseAmt = thrustImpulseAmt / exhaust_count * vtolImpulseMult -- Spread force evenly.

                    ApplyBodyImpulse(
                        plane.body,
                        plane.tr.pos,
                        TransformToParentPoint(tr, Vec(0, 0, thrustImpulseAmt)))

                end

            else

                local thrustImpulseAmt = plane.thrust * (-plane.thrustImpulseAmount * ((plane.thrustOutput^1.3) / plane.thrust))
                ApplyBodyImpulse(
                    plane.body,
                    plane.tr.pos,
                    TransformToParentPoint(plane.tr, Vec(0, 0, thrustImpulseAmt)))

            end

        end

    end

end


-- Apply aerodynamic impulses.
function plane_ApplyAerodynamics(plane)

    if plane.totalVel < 1 then
        return
    end

    local localVel = TransformToLocalVec(plane.tr, plane.vel)
    local FwdVel = (plane.topSpeed / clamp(math.abs(-localVel[3]), 1, plane.topSpeed)) * 2

    local x = 0
    local y = 0
    local z = 0

    x = GetRollAoA(plane.tr, plane.vel)
    y = GetPitchAoA(plane.tr, plane.vel)
    z = GetYawAoA(plane.tr, plane.vel)

    force_x = GetRollAoA(plane.tr, plane.vel) / FwdVel / 2
    force_y = GetPitchAoA(plane.tr, plane.vel) / FwdVel
    force_z = GetYawAoA(plane.tr, plane.vel) / FwdVel / 4


    local impMult = 2

    if IsSimpleFlight() then
        impMult = 3
        if Config.smallMapMode then
            impMult = 4
        end
    end

    local forces = Vec(force_x, force_y, force_z)
    plane.forces = VecScale(forces, clamp(plane.health, 0.5, 1))

    local impSpeedScale = 1 - (plane.speedFac / plane.topSpeed)
    local imp = GTZero(GetBodyMass(plane.body) * impSpeedScale) * 5 * impMult


    dbw("AERO X", sfn(x))
    dbw("AERO Y", sfn(y))
    dbw("AERO Z", sfn(z))
    dbw("AERO FORCE X", sfn(forces[1]))
    dbw("AERO FORCE Y", sfn(forces[2]))
    dbw("AERO FORCE Z", sfn(forces[3]))
    dbw("AERO LVEL", localVel)
    dbw("AERO IMP", imp)


    ApplyBodyImpulse(plane.body,
        plane.tr.pos,
        TransformToParentPoint(plane.tr, VecScale(Vec(force_x, 0, 0), imp)))

    ApplyBodyImpulse(plane.body,
        plane.tr.pos,
        TransformToParentPoint(plane.tr, VecScale(Vec(0, force_y, 0), imp)))

    ApplyBodyImpulse(
        plane.body,
        TransformToParentPoint(plane.tr, VecScale(Vec(0, 1, 0))),
        TransformToParentPoint(plane.tr, VecScale(Vec(force_z, 0, 0), imp)))


    local angDim = 1 - (plane.speedFac / plane.topSpeed * 6)
    angDim = clamp(angDim, 0, 1)
    SetBodyAngularVelocity(plane.body, VecScale(GetBodyAngularVelocity(plane.body), angDim)) -- Diminish ang vel


    if Config.debug and plane.totalVel > 2 then
        plane_draw_Forces(plane, x, y, z, 5, 20)
    end

end


-- Apply turbulence based on velocity and aerodynamics.
function plane_ApplyTurbulence(plane)

    -- local turbImp = VecRdm(math.abs(plane.lvel[1] + plane.lvel[2]) * 10000)

    -- TURBULENCE = TURBULENCE
    -- if InputDown("f") then
    --     TURBULENCE = not TURBULENCE or false
    -- end

    -- if TURBULENCE then
    --     ApplyBodyImpulse(plane.body, VecAdd(plane.tr.pos, VecRdm(1)), turbImp)
    -- end

    -- dbw("TURB imp", turbImp)
    -- dbw("TURBULENCE", TURBULENCE)


end


-- Apply impulses to control the pitch, roll and yaw.
function plane_Steer(plane)

    local idealSpeedFactor = plane.idealSpeedFactor

    if idealSpeedFactor > 0 and ((math.abs(plane.speed) / plane.topSpeed)) > 0.75 then

        idealSpeedFactor = 0.5 -- Prevent plane from being too stiff to steer at highest speeds.

    elseif idealSpeedFactor < 0 then -- Moving backwards.

        if not plane_IsVtolCapable(plane) then -- Regular planes
            idealSpeedFactor = idealSpeedFactor / 10
        end

    end

    local imp = math.abs(idealSpeedFactor * GetBodyMass(plane.body) * clamp(plane.health, 0.5, 1) / 20)

    local nose = TransformToParentPoint(plane.tr, Vec(0, 0, -10))
    local wing = TransformToParentPoint(plane.tr, Vec(-10, 0, 0))

    local planeUp = DirLookAt(plane.tr.pos, TransformToParentPoint(plane.tr, Vec(0, 10, 0)))
    local planeLeft = DirLookAt(plane.tr.pos, TransformToParentPoint(plane.tr, Vec(10, 0, 0)))

    local ic = InputControls
    local inc = InputControlIncrement


    local w = InputDown("w")
    local s = InputDown("s")
    local a = InputDown("a")
    local d = InputDown("d")
    local c = InputDown("c")
    local z = InputDown("z")


    -- if camPos == "aligned" then

    --     if InputValue("mousedy") > 1 then
    --         s = true
    --         ic.s = InputValue("mousedy")/10
    --     end
    --     if InputValue("mousedy") < -1 then
    --         w = true
    --         ic.w = -InputValue("mousedy")/10
    --     end
    --     if InputValue("mousedx") > 1 then
    --         c = true
    --         ic.c = InputValue("mousedx")/10
    --     end
    --     if InputValue("mousedx") < -1 then
    --         z = true
    --         ic.z = -InputValue("mousedx")/10
    --     end

    -- end


    if w then
        ic.w = clamp(ic.w + inc, 0, 1)
        ApplyBodyImpulse(plane.body, nose, VecScale(planeUp, -imp * ic.w))
    else
        ic.w = clamp(ic.w - inc, 0, 1)
    end
    if s then
        ic.s = clamp(ic.s + inc, 0, 1)
        ApplyBodyImpulse(plane.body, nose, VecScale(planeUp, imp * ic.s))
    else
        ic.s = clamp(ic.s - inc, 0, 1)
    end


    if a then
        ic.a = clamp(ic.a + inc, 0, 1)
        ApplyBodyImpulse(plane.body, wing, VecScale(planeUp, -imp * ic.a * plane.rollVal))
    else
        ic.a = clamp(ic.a - inc, 0, 1)
    end
    if d then
        ic.d = clamp(ic.d + inc, 0, 1)
        ApplyBodyImpulse(plane.body, wing, VecScale(planeUp, imp * ic.d * plane.rollVal))
    else
        ic.d = clamp(ic.d - inc, 0, 1)
    end


    if z then
        ic.c = clamp(ic.c + inc, 0, 1)
        ApplyBodyImpulse(plane.body, nose, VecScale(planeLeft, -imp * ic.c))
    else
        ic.c = clamp(ic.c - inc, 0, 1)
    end
    if c then
        ic.z = clamp(ic.z + inc, 0, 1)
        ApplyBodyImpulse(plane.body, nose, VecScale(planeLeft, imp * ic.z))
    else
        ic.z = clamp(ic.z - inc, 0, 1)
    end


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
                plane.tr, Vec(0, 0, -5)),
            plane_GetFwdPos(plane, plane.speed * plane.brakeImpulseAmt))
        plane_StatusAppend(plane, "Air-Braking")
    end

end


-- Draw aerodynamic forces debug lines.
function plane_draw_Forces(plane, x, y, z, outness, scale)

    local outness = outness or 5
    local sc = scale or 5

    DebugLine(
        TransformToParentPoint(plane.tr, Vec(0, 0, -outness)),
        TransformToParentPoint(plane.tr, Vec(x * sc, 0, -outness)),
        0, 0, 1, 1)
    DebugLine(
        TransformToParentPoint(plane.tr, Vec(0, 0, outness)),
        TransformToParentPoint(plane.tr, Vec(-x * sc, 0, outness)),
        0, 0, 1, 1)

    DebugLine(
        TransformToParentPoint(plane.tr, Vec(0, 0, -outness)),
        TransformToParentPoint(plane.tr, Vec(0, y * sc, -outness)),
        0, 1, 0, 1)
    DebugLine(
        TransformToParentPoint(plane.tr, Vec(0, 0, outness)),
        TransformToParentPoint(plane.tr, Vec(0, -y * sc, outness)),
        0, 1, 0, 1)

    DebugLine(
        TransformToParentPoint(plane.tr, Vec(outness, 0, 0)),
        TransformToParentPoint(plane.tr, Vec(outness, z * sc, 0)),
        1, 0, 0, 1)
    DebugLine(
        TransformToParentPoint(plane.tr, Vec(-outness, 0, 0)),
        TransformToParentPoint(plane.tr, Vec(-outness, -z * sc, 0)),
        1, 0, 0, 1)

    -- DebugLine(plane.tr.pos, TransformToParentPoint(plane.tr, forces) , 1,1,0, 1)
    DebugLine(plane.tr.pos, VecAdd(plane.tr.pos, plane.vel), 1, 1, 0, 1)
    DebugLine(plane.tr.pos, TransformToParentPoint(plane.tr, Vec(0, 0, -20)), 1, 1, 1, 1)

end




function GetPitchAoA(tr, vel)

    local lVel = TransformToLocalVec(tr, vel)
    local aoa = math.deg(math.atan2(-lVel[2], -lVel[3]))

    aoa = math.rad(aoa)
    aoa = math.sin(aoa)

    return aoa

end

function GetYawAoA(tr, vel)

    local lVel = TransformToLocalVec(tr, vel)
    local aoa = math.deg(math.atan2(-lVel[1], -lVel[2]))

    aoa = math.rad(aoa)
    aoa = math.sin(aoa)

    return aoa

end

function GetRollAoA(tr, vel)

    local lVel = TransformToLocalVec(tr, vel)
    local aoa = math.deg(math.atan2(-lVel[1], -lVel[3]))

    aoa = math.rad(aoa)
    aoa = math.sin(aoa)

    return aoa

end
