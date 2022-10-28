---comment
---@param plane table
---@param controlsVec table Vec which contains data for pitch, yaw and roll.
function plane_Animate_AeroParts(plane, ignore_input)


    local w = InputDown("w")
    local s = InputDown("s")
    local a = InputDown("a")
    local d = InputDown("d")
    local c = InputDown("c")
    local z = InputDown("z")

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
                    DrawShapeOutline(part.shape, 1,0.5,0, 0.5)
                    DrawDot(pivot_tr.pos, 1/3, 1/3, 1,0,0, 1/2)
                    DrawDot(parentTr.pos, 1/3, 1/3, 0,1,0, 1/2)
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


    -- Landing gear constraints.
    for _, gear in ipairs(plane.parts.landing_gear) do

        if IsHandleValid(gear.vehicle) and IsHandleValid(gear.shape) then

            local parentTr = TransformToParentTransform(plane.tr, gear.localTr)
            local pivot_tr = GetLightTransform(gear.light)
            local gear_rate = 0.5

            ConstrainPosition(gear.body, plane.body, pivot_tr.pos, parentTr.pos)


            if Config.debug then
                DrawShapeOutline(gear.shape, 0,1,0, 0.5)
                DrawDot(pivot_tr.pos, 1/3, 1/3, 0,1,0, 1/2)
                DrawDot(parentTr.pos, 1/3, 1/3, 0,1,1, 1/2)
            end


            if InputDown("g") then
                local gearUpRot = QuatRotateQuat(pivot_tr.rot, QuatEuler(0,0,-gear.angle))
                plane_Animate_AeroParts_Paralell(plane, gear, gearUpRot, parentTr.rot, gear_rate)
            else
                plane_Animate_AeroParts_Paralell(plane, gear, pivot_tr.rot, parentTr.rot, gear_rate)
            end

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