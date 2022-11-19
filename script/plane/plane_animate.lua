---comment
---@param plane table
---@param controlsVec table Vec which contains data for pitch, yaw and roll.
function plane_Animate_AeroParts(plane, ignore_input)

    local sub_dir = Vec(0,0,0)
    if IsSimpleFlight() and plane.camera then
        if plane.camera.tr then

            local cam_dir = Vec(GetQuatEuler(plane.camera.tr.rot or Quat()))
            local plane_dir = Vec(GetQuatEuler(plane.tr.rot))
            sub_dir = VecSub(plane_dir, cam_dir)

            if plane.vehicle == GetPlayerVehicle() then
                DebugWatch("sub_dir", sub_dir)
            end

        end
    end

    local dead_zone = 5
    local w = InputDown("w") or (sub_dir[1] > dead_zone)
    local s = InputDown("s") or (sub_dir[1] < -dead_zone)

    local a = InputDown("a") or (sub_dir[3] > dead_zone)
    local d = InputDown("d") or (sub_dir[3] < -dead_zone)

    local c = InputDown("c") or (sub_dir[2] > dead_zone)
    local z = InputDown("z") or (sub_dir[2] < -dead_zone)


    -- Aero part animations.
    for parts_key, parts in pairs(plane.parts.aero) do
        for part_key, part in ipairs(parts) do

            if IsHandleValid(part.shape) then

                local aero_rate = 1.5
                local angle = 30

                local parentTr = TransformToParentTransform(plane.tr, part.localTr)
                local light_pivot = part.light_pivot
                local pivot_tr = GetLightTransform(light_pivot)

                ConstrainPosition(part.body, plane.body, pivot_tr.pos, parentTr.pos)
                -- ConstrainVelocity(part.body, plane.body, pivot_tr.pos, VecNormalize(plane.vel))
                -- ConstrainAngularVelocity(part.body, plane.body, plane.tr.)


                -- if part.body ~= plane.body then
                    -- SetBodyAngularVelocity(part.body, Vec(0,0,0))
                -- end

                if Config.debug then
                    DrawShapeOutline(part.shape, 1,0.5,0, 1)
                    DebugCross(pivot_tr.pos, 1,0,0, 1)
                    DebugCross(parentTr.pos, 0,1,0, 1)
                end


                ConstrainPosition(part.body, plane.body, pivot_tr.pos, parentTr.pos)
                plane_Animate_AeroParts_Paralell(plane, part, pivot_tr.rot, parentTr.rot, aero_rate)


                if not ignore_input then

                    if parts_key == "rudder"then

                        if z then -- Yaw left
                            plane_Animate_AeroParts_Paralell(plane, part, pivot_tr.rot, QuatRotateQuat(parentTr.rot, QuatEuler(0,0,-angle)), aero_rate)
                        elseif c then -- Yaw right
                            plane_Animate_AeroParts_Paralell(plane, part, pivot_tr.rot, QuatRotateQuat(parentTr.rot, QuatEuler(0,0,angle)), aero_rate)
                        else
                            plane_Animate_AeroParts_Paralell(plane, part, pivot_tr.rot, parentTr.rot, aero_rate)
                        end

                    end


                    if parts_key == "elevator" then

                        if w or s or a or d then

                            if w then -- Pitch down
                                plane_Animate_AeroParts_Paralell(plane, part, pivot_tr.rot, QuatRotateQuat(parentTr.rot, QuatEuler(0,0,-angle)), aero_rate)
                            elseif s then -- Pitch up
                                plane_Animate_AeroParts_Paralell(plane, part, pivot_tr.rot, QuatRotateQuat(parentTr.rot, QuatEuler(0,0,angle)), aero_rate)
                            end

                            if a then -- Roll left
                                plane_Animate_AeroParts_Paralell(plane, part, pivot_tr.rot, QuatRotateQuat(parentTr.rot, QuatEuler(0,0,GetPartSideSign(part) * -angle)), aero_rate)
                            elseif d then -- Roll right
                                plane_Animate_AeroParts_Paralell(plane, part, pivot_tr.rot, QuatRotateQuat(parentTr.rot, QuatEuler(0,0,GetPartSideSign(part) * angle)), aero_rate)
                            end

                        else
                            plane_Animate_AeroParts_Paralell(plane, part, pivot_tr.rot, parentTr.rot, aero_rate)
                        end

                    end


                    if parts_key == "aileron" then

                        if w or s or a or d then

                            if w then -- Pitch down
                                plane_Animate_AeroParts_Paralell(plane, part, pivot_tr.rot, QuatRotateQuat(parentTr.rot, QuatEuler(0,0,angle)), aero_rate)
                            elseif s then -- Pitch up
                                plane_Animate_AeroParts_Paralell(plane, part, pivot_tr.rot, QuatRotateQuat(parentTr.rot, QuatEuler(0,0,-angle)), aero_rate)
                            end

                            if a then -- Roll left
                                plane_Animate_AeroParts_Paralell(plane, part, pivot_tr.rot, QuatRotateQuat(parentTr.rot, QuatEuler(0,0,GetPartSideSign(part) * -angle)), aero_rate)
                            elseif d then -- Roll right
                                plane_Animate_AeroParts_Paralell(plane, part, pivot_tr.rot, QuatRotateQuat(parentTr.rot, QuatEuler(0,0,GetPartSideSign(part) * angle)), aero_rate)
                            end

                        else
                            plane_Animate_AeroParts_Paralell(plane, part, pivot_tr.rot, parentTr.rot, aero_rate)
                        end

                    end


                    if parts_key == "flap" then

                        if plane.flaps then
                            plane_Animate_AeroParts_Paralell(plane, part, pivot_tr.rot, QuatRotateQuat(parentTr.rot, QuatEuler(0,0,-angle)), aero_rate)
                        else
                            plane_Animate_AeroParts_Paralell(plane, part, pivot_tr.rot, parentTr.rot, aero_rate)
                        end

                    end

                end

            end

        end
    end


    -- Check whether to initiate landing gear transition.
    if plane.landing_gear.startTransition then
        plane.landing_gear.startTransition = false
        TimerResetTime(plane.landing_gear.retract_timer)
    end
    TimerRunTime(plane.landing_gear.retract_timer)


    if plane.vtol.startTransition then
        plane.vtol.startTransition = false
        TimerResetTime(plane.vtol.retract_timer)
    end
    TimerRunTime(plane.vtol.retract_timer)


    -- Landing gear constraints.
    for index, gear in ipairs(plane.parts.landing_gear) do

        if IsHandleValid(gear.vehicle) and IsHandleValid(gear.body) and IsHandleValid(gear.shape) then

            DriveVehicle(gear.vehicle, 0, 0, false)

            local parentTr = TransformToParentTransform(plane.tr, gear.localTr) -- Tr on plane body.
            local pivot_tr = GetLightTransform(gear.light)


            local gear_alive = GetShapeVoxelCount(gear.shape)/gear.voxels > 0.5
            if gear_alive then

                local phase = TimerGetPhase(plane.landing_gear.retract_timer)

                -- Which way to rotate the landing gear.
                local angle = Ternary(
                    plane.landing_gear.isDown,
                    -gear.angle * (1 - phase),
                    -gear.angle * phase)

                local gearRot = QuatRotateQuat(pivot_tr.rot, QuatEuler(0, 0, angle))

                plane_Animate_AeroParts_Paralell(plane, gear, gearRot, parentTr.rot, math.huge)
                ConstrainPosition(gear.body, plane.body, pivot_tr.pos, parentTr.pos)


                if not TimerConsumed(plane.landing_gear.retract_timer) then
                    PlayLoop(loops.landing_gear, pivot_tr.pos, 1.5)
                end


                -- local vTr = GetVehicleTransform(gear.vehicle) -- Top of gear (pivot point)
                -- local bTr = GetBodyTransform(gear.body) -- Bottom of gear (wheel)

                -- local tr = Transform(parentTr.pos, QuatTrLookDown(vTr))
                -- local dist = VecDist(vTr.pos, bTr.pos)
                -- local rchit, rcpos, rcdist = RaycastFromTransform(tr, dist, 0.1, plane.AllBodies, plane.AllShapes, true)
                -- if rchit then

                --     local rv = dist - rcdist
                --     local rv_totalVel = (dist - rcdist)/(plane.totalVel+1)
                --     local rv_inverse = 1/rcdist/dist


                --     if index == 1 then
                --         DebugWatch("rv ", rv)
                --         DebugWatch("rv_inverse ", rv_inverse)
                --         DebugWatch("rv_totalVel ", rv_totalVel)
                --     end


                --     local gear_pos_offset = VecAdd(pivot_tr.pos,Vec(0,-rv,0))
                --     DebugCross(gear_pos_offset, 1,0,0, 1)


                --     -- Hold pivot point of landing gear to plane body
                --     ConstrainPosition(gear.body, plane.body, VecAdd(pivot_tr.pos, Vec(0,-rv,0)), parentTr.pos)


                --     -- ConstrainVelocity(plane.body, GetWorldBody(), gear_pos_offset, Vec(0,1,0), rv_totalVel, 0)


                --     if Config.debug then
                --         DrawDot(rcpos, 1/3,1/3, 1,1,1, 1)
                --         DebugLine(tr.pos, rcpos, 1,1,1, 1)
                --     end


                -- else -- Wheels are not touching anything.

                --     ConstrainPosition(gear.body, plane.body, pivot_tr.pos, parentTr.pos)

                -- end


                if Config.debug then
                    DrawShapeOutline(gear.shape, 0,1,0, 1)
                    DebugCross(pivot_tr.pos, 0,1,0, 1)
                    DebugCross(parentTr.pos, 0,1,1, 1)
                end

            else

                if Config.debug then
                    DrawShapeOutline(gear.shape, 1,0,0, 1)
                end

            end

        end

    end


    -- VTOL constraints.
    for index, vtol in ipairs(plane.parts.vtol) do

        if IsHandleValid(vtol.body) and IsHandleValid(vtol.shape) then

            local parentTr = TransformToParentTransform(plane.tr, vtol.localTr) -- Tr on plane body.
            local pivot_tr = GetLightTransform(vtol.light)


            -- local vtol_alive = GetShapeVoxelCount(vtol.shape)/vtol.voxels > 0.5
            -- if vtol_alive then

                local phase = TimerGetPhase(plane.vtol.retract_timer)

                -- Which way to rotate the landing gear.
                local angle = Ternary(
                    plane.vtol.isDown,
                    -vtol.angle * (1 - phase),
                    -vtol.angle * phase)

                local gearRot = QuatRotateQuat(pivot_tr.rot, QuatEuler(0, 0, angle))

                plane_Animate_AeroParts_Paralell(plane, vtol, gearRot, parentTr.rot, math.huge)
                ConstrainPosition(vtol.body, plane.body, pivot_tr.pos, parentTr.pos)


                if not TimerConsumed(plane.vtol.retract_timer) then
                    PlayLoop(loops.landing_gear, pivot_tr.pos, 1.5)
                end

                if Config.debug then
                    DrawShapeOutline(vtol.shape, 0,0,1, 1)
                    DebugCross(pivot_tr.pos, 0,0,1, 1)
                    DebugCross(parentTr.pos, 0,0,1, 1)
                end

            -- end

        end

    end

end


function plane_Animate_AeroParts_Paralell(part, plane, part_rot, target_rot, rate)
    ConstrainOrientation(part.body, plane.body, target_rot, part_rot, rate)
end


function GetPartSideSign(part)
    if part.side == "right" then return 1 end
    return -1
end