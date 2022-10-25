function plane_Animate_AeroParts(plane)

    for category_key, category in pairs(plane.parts) do
        for parts_key, parts in pairs(category) do
            for part_key, part in ipairs(parts) do

                local parentTr = TransformToParentTransform(plane.tr, part.localTr)
                local light_pivot = part.light_pivot
                local pivot_tr = GetLightTransform(light_pivot)

                ConstrainPosition(part.body, plane.body, pivot_tr.pos, parentTr.pos)


                local angle = 35
                if Config.showOptions then
                    DrawDot(pivot_tr.pos, 1/2,1/2, 1,0,0, 1)
                end


                if parts_key == "rudder"then

                    if InputDown("ctrl") then
                        plane_Animate_AeroParts_Paralell(plane, part, pivot_tr, QuatRotateQuat(parentTr.rot, QuatEuler(0,0,-angle)))
                    elseif InputDown("alt") then
                        plane_Animate_AeroParts_Paralell(plane, part, pivot_tr, QuatRotateQuat(parentTr.rot, QuatEuler(0,0,angle)))
                    else
                        plane_Animate_AeroParts_Paralell(plane, part, pivot_tr, parentTr.rot)
                    end

                end


                if parts_key == "elevator" then

                    if InputDown("w") or InputDown("s") or InputDown("a") or InputDown("d") then

                        if InputDown("w") then
                            plane_Animate_AeroParts_Paralell(plane, part, pivot_tr, QuatRotateQuat(parentTr.rot, QuatEuler(0,0,-angle)))
                        elseif InputDown("s") then
                            plane_Animate_AeroParts_Paralell(plane, part, pivot_tr, QuatRotateQuat(parentTr.rot, QuatEuler(0,0,angle)))
                        end

                        if InputDown("a") then
                            plane_Animate_AeroParts_Paralell(plane, part, pivot_tr, QuatRotateQuat(parentTr.rot, QuatEuler(0,0,GetPartSideSign(part) * -angle)))
                        elseif InputDown("d") then
                            plane_Animate_AeroParts_Paralell(plane, part, pivot_tr, QuatRotateQuat(parentTr.rot, QuatEuler(0,0,GetPartSideSign(part) * angle)))
                        end

                    else
                        plane_Animate_AeroParts_Paralell(plane, part, pivot_tr, parentTr.rot)
                    end

                end


                if parts_key == "aileron" then

                    if InputDown("w") or InputDown("s") or InputDown("a") or InputDown("d") then

                        if InputDown("w") then
                            plane_Animate_AeroParts_Paralell(plane, part, pivot_tr, QuatRotateQuat(parentTr.rot, QuatEuler(0,0,angle)))
                        elseif InputDown("s") then
                            plane_Animate_AeroParts_Paralell(plane, part, pivot_tr, QuatRotateQuat(parentTr.rot, QuatEuler(0,0,-angle)))
                        end

                        if InputDown("a") then
                            plane_Animate_AeroParts_Paralell(plane, part, pivot_tr, QuatRotateQuat(parentTr.rot, QuatEuler(0,0,GetPartSideSign(part) * -angle)))
                        elseif InputDown("d") then
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

            end
        end
    end

end


function plane_Animate_AeroParts_Paralell(plane, part, part_tr, target_rot)

    ConstrainOrientation(part.body, plane.body, part_tr.rot, target_rot, 2)

end

function GetPartSideSign(part)
    if part.side == "right" then
        return 1
    end
    return -1
end