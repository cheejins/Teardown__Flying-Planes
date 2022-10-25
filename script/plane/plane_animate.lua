---comment
---@param plane table
---@param controlsVec table Vec which contains data for pitch, yaw and roll.
function plane_Animate_AeroParts(plane, controlsVec)


    local w = InputDown("w")
    local s = InputDown("s")
    local a = InputDown("a")
    local d = InputDown("d")
    local c = InputDown("c")
    local z = InputDown("z")


    for category_key, category in pairs(plane.parts) do
        for parts_key, parts in pairs(category) do
            for part_key, part in ipairs(parts) do

                local angle = 35

                local parentTr = TransformToParentTransform(plane.tr, part.localTr)
                local light_pivot = part.light_pivot
                local pivot_tr = GetLightTransform(light_pivot)

                ConstrainPosition(part.body, plane.body, pivot_tr.pos, parentTr.pos)
                SetBodyAngularVelocity(part.body, Vec(0,0,0))
                -- SetBodyVelocity(part.body, plane.vel)



                if GetPlayerVehicle() == plane.vehicle then

                    if parts_key == "rudder"then

                        if z then -- Yaw left
                            plane_Animate_AeroParts_Paralell(plane, part, pivot_tr, QuatRotateQuat(parentTr.rot, QuatEuler(0,0,-angle)))
                        elseif c then -- Yaw right
                            plane_Animate_AeroParts_Paralell(plane, part, pivot_tr, QuatRotateQuat(parentTr.rot, QuatEuler(0,0,angle)))
                        else
                            plane_Animate_AeroParts_Paralell(plane, part, pivot_tr, parentTr.rot)
                        end

                    end


                    if parts_key == "elevator" then

                        if w or s or a or d then

                            if w then -- Pitch down
                                plane_Animate_AeroParts_Paralell(plane, part, pivot_tr, QuatRotateQuat(parentTr.rot, QuatEuler(0,0,-angle)))
                            elseif s then -- Pitch up
                                plane_Animate_AeroParts_Paralell(plane, part, pivot_tr, QuatRotateQuat(parentTr.rot, QuatEuler(0,0,angle)))
                            end

                            if a then -- Roll left
                                plane_Animate_AeroParts_Paralell(plane, part, pivot_tr, QuatRotateQuat(parentTr.rot, QuatEuler(0,0,GetPartSideSign(part) * -angle)))
                            elseif d then -- Roll right
                                plane_Animate_AeroParts_Paralell(plane, part, pivot_tr, QuatRotateQuat(parentTr.rot, QuatEuler(0,0,GetPartSideSign(part) * angle)))
                            end

                        else
                            plane_Animate_AeroParts_Paralell(plane, part, pivot_tr, parentTr.rot)
                        end

                    end


                    if parts_key == "aileron" then

                        if w or s or a or d then

                            if w then -- Pitch down
                                plane_Animate_AeroParts_Paralell(plane, part, pivot_tr, QuatRotateQuat(parentTr.rot, QuatEuler(0,0,angle)))
                            elseif s then -- Pitch up
                                plane_Animate_AeroParts_Paralell(plane, part, pivot_tr, QuatRotateQuat(parentTr.rot, QuatEuler(0,0,-angle)))
                            end

                            if a then -- Roll left
                                plane_Animate_AeroParts_Paralell(plane, part, pivot_tr, QuatRotateQuat(parentTr.rot, QuatEuler(0,0,GetPartSideSign(part) * -angle)))
                            elseif d then -- Roll right
                                plane_Animate_AeroParts_Paralell(plane, part, pivot_tr, QuatRotateQuat(parentTr.rot, QuatEuler(0,0,GetPartSideSign(part) * angle)))
                            end

                        else
                            plane_Animate_AeroParts_Paralell(plane, part, pivot_tr, parentTr.rot)
                        end

                    end


                    if parts_key == "flap" then

                        if plane.flaps then
                            plane_Animate_AeroParts_Paralell(plane, part, pivot_tr, QuatRotateQuat(parentTr.rot, QuatEuler(0,0,-angle)))
                        else
                            plane_Animate_AeroParts_Paralell(plane, part, pivot_tr, parentTr.rot)
                        end

                    end

                else

                    ConstrainPosition(part.body, plane.body, pivot_tr.pos, parentTr.pos)
                    plane_Animate_AeroParts_Paralell(plane, part, pivot_tr, parentTr.rot)

                end

                if Config.showOptions then
                    DrawDot(pivot_tr.pos, 1/2,1/2, 1,0,0, 1)
                end

            end
        end
    end

end


function plane_Animate_AeroParts_Paralell(plane, part, part_tr, target_rot)
    ConstrainOrientation(part.body, plane.body, part_tr.rot, target_rot, 2)
end

function GetPartSideSign(part)
    if part.side == "right" then return 1 end
    return -1
end