function plane_applyTurbulence(plane)
end

-- forces
function plane_applyForces(plane)

    local localVel = TransformToLocalVec(plane.tr, plane.vel)
    local FwdVel = (plane.topSpeed / clamp(math.abs(-localVel[3]), 1, plane.topSpeed)) * 3

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
    if Config.flightMode == FlightModes.simple then
        impMult = 4
        if Config.smallMapMode then
            impMult = 6
        end
    end


    local forces = Vec(force_x, force_y, force_z)
    plane.forces = VecScale(forces, plane.health)

    local impSpeedScale = 1 - (plane.speedFac / plane.topSpeed)
    local imp = gtZero(GetBodyMass(plane.body) * impSpeedScale) * 5 * impMult



    dbw("AERO X", sfn(x))
    dbw("AERO Y", sfn(y))
    dbw("AERO Z", sfn(z))
    dbw("AERO FORCE X", sfn(forces[1]))
    dbw("AERO FORCE Y", sfn(forces[2]))
    dbw("AERO FORCE Z", sfn(forces[3]))
    dbw("AERO IMP", imp)
    dbw("AERO impSpeedScale", impSpeedScale)
    dbw("AERO LVEL", localVel)



    ApplyBodyImpulse(plane.body,
        plane.tr.pos,
        TransformToParentPoint(plane.tr, VecScale(Vec(force_x,0,0), imp)))

    ApplyBodyImpulse(plane.body,
        plane.tr.pos,
        TransformToParentPoint(plane.tr, VecScale(Vec(0,force_y,0), imp)))

    ApplyBodyImpulse(
        plane.body,
        TransformToParentPoint(plane.tr, VecScale(Vec(0,1,0))),
        TransformToParentPoint(plane.tr, VecScale(Vec(force_z,0,0), imp)))


    local angDim = 1 - (plane.speedFac / plane.topSpeed * 6)
    angDim = clamp(angDim, 0, 1)
    SetBodyAngularVelocity(plane.body, VecScale(GetBodyAngularVelocity(plane.body), angDim)) -- Diminish ang vel


    if Config.showOptions and plane.totalVel > 1 then
        DrawForces(plane, x,y,z, 5, 20)
    end

end


function DrawForces(plane, x,y,z, outness, scale)

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
    DebugLine(plane.tr.pos, VecAdd(plane.tr.pos, plane.vel) , 1,1,0, 1)
    DebugLine(plane.tr.pos, TransformToParentPoint(plane.tr, Vec(0,0,-20)) , 1,1,1, 1)

end