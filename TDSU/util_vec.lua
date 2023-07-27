--[[VECTORS]]
do
    --- Distance between two vectors.
    VecDist = function(v1, v2) return VecLength(VecSub(v1, v2)) end

    --- Divide a vector by another vector's components.
    VecDiv = function(v1, v2) return Vec(v1[1] / v2[1], v1[2] / v2[2], v1[3] / v2[3]) end

    VecMult = function(v1, v2)
        local v = Vec(0,0,0)
        for i = 1, 3 do v[i] = v1[i] * v2[i] end
        return v
    end

    --- Add a table of vectors together.
    VecAddAll = function(tb_vecs) local v = Vec(0,0,0) for i = 1, #tb_vecs do VecAdd(v, tb_vecs[i]) end return v end

    --- Returns a vector with random values.
    VecRandom = function(length)
        local v = VecNormalize(Vec(math.random(-10000000,10000000), math.random(-10000000,10000000), math.random(-10000000,10000000)))
        return VecScale(v, length)
    end

    -- Return each min component.
    function VecMin(v1, v2)
        local v = Vec(0,0,0)
        for i = 1, 3 do
            v[i] = math.min(v1[i], v2[i])
        end
        return v
    end

    -- Return each max component.
    function VecMax(v1, v2)
        local v = Vec(0,0,0)
        for i = 1, 3 do
            v[i] = math.max(v1[i], v2[i])
        end
        return v
    end

    --- Print QuatEulers or vectors.
    VecPrint = function(vec, label, decimals)

        local str = (label or "")

        str = string_append(str, sfn(vec[1], decimals))
        str = string_append(str, sfn(vec[2], decimals), ", ")
        str = string_append(str, sfn(vec[3], decimals), ", ")

        str = string_enclose(str, "{", " }")

        DebugPrint(str)
        print(str)

    end


    --- Returns a vector with random values.
    function VecRdm(length)
        local v = VecNormalize(Vec(math.random(-100,100), math.random(-100,100), math.random(-100,100)))
        return VecScale(v, length)
    end

    ---Move a point towards another point for a specified distance.
    VecApproach = function(vec_start, vec_end, dist)
        local sub_pos = VecScale(VecNormalize(VecSub(vec_end, vec_start)), dist)
        return VecAdd(vec_start, sub_pos)
    end

    ---Average vector between two vectors.
    VecAvg = function(v1, v2) return VecScale(VecAdd(v1, v2), 1/2) end

    ---Return the x value of a Vec.
    vx = function(v) return v[1] or v.x end

    ---Return the y value of a Vec.
    vy = function(v) return v[2] or v.y end

    ---Return the z value of a Vec.
    vz = function(v) return v[3] or v.z end

    ---Takes a table a like { x = 0, y = 0, z = 0 } and converts it to Vec(0,0,0)
    ToVec = function(v) return Vec(v.x, v.y, v.z) end

    ---Takes a Vec like and Vec(0,0,0) converts it to { x = 0, y = 0, z = 0 }
    ToCompVec = function(v) return { x = v[1], y = v[2], z = v[3] } end

    TransformAdd = function(tr1, tr2)
        return Transform(VecAdd(tr1.pos, tr2.pos), QuatRotateQuat(tr1.rot, tr2.rot))
    end

    TransformAdd = function(tr1, tr2)
        return Transform(VecAdd(tr1.pos, tr2.pos), QuatRotateQuat(tr1.rot, tr2.rot))
    end

end


--[[AABB]]
do
    AabbDimensions = function(min, max) return Vec(max[1] - min[1], max[2] - min[2], max[3] - min[3]) end
    AabbDraw = function(v1, v2, r, g, b, a)
        r = r or 1 g = g or 1 b = b or 1 a = a or 1
        local x1 = v1[1] local y1 = v1[2] local z1 = v1[3] local x2 = v2[1] local y2 = v2[2] local z2 = v2[3]
        -- x lines top
        DebugLine(Vec(x1,y1,z1), Vec(x2,y1,z1), r, g, b, a)
        DebugLine(Vec(x1,y1,z2), Vec(x2,y1,z2), r, g, b, a)
        -- x lines bottom
        DebugLine(Vec(x1,y2,z1), Vec(x2,y2,z1), r, g, b, a)
        DebugLine(Vec(x1,y2,z2), Vec(x2,y2,z2), r, g, b, a)
        -- y lines
        DebugLine(Vec(x1,y1,z1), Vec(x1,y2,z1), r, g, b, a)
        DebugLine(Vec(x2,y1,z1), Vec(x2,y2,z1), r, g, b, a)
        DebugLine(Vec(x1,y1,z2), Vec(x1,y2,z2), r, g, b, a)
        DebugLine(Vec(x2,y1,z2), Vec(x2,y2,z2), r, g, b, a)
        -- z lines top
        DebugLine(Vec(x2,y1,z1), Vec(x2,y1,z2), r, g, b, a)
        DebugLine(Vec(x2,y2,z1), Vec(x2,y2,z2), r, g, b, a)
        -- z lines bottom
        DebugLine(Vec(x1,y1,z2), Vec(x1,y1,z1), r, g, b, a)
        DebugLine(Vec(x1,y2,z2), Vec(x1,y2,z1), r, g, b, a)
    end
    AabbCheckOverlap = function(aMin, aMax, bMin, bMax)
        return
        (aMin[1] <= bMax[1] and aMax[1] >= bMin[1]) and
        (aMin[2] <= bMax[2] and aMax[2] >= bMin[2]) and
        (aMin[3] <= bMax[3] and aMax[3] >= bMin[3])
    end
    AabbCheckPointInside = function(aMin, aMax, pos)
        return
        (pos[1] <= aMax[1] and pos[1] >= aMin[1]) and
        (pos[2] <= aMax[2] and pos[2] >= aMin[2]) and
        (pos[3] <= aMax[3] and pos[3] >= aMin[3])
    end
    AabbClosestEdge = function(pos, shape)
        local shapeAabbMin, shapeAabbMax = GetShapeBounds(shape)
        local bCenterY = VecLerp(shapeAabbMin, shapeAabbMax, 0.5)[2]
        local edges = {}
        edges[1] = Vec(shapeAabbMin[1], bCenterY, shapeAabbMin[3]) -- a
        edges[2] = Vec(shapeAabbMax[1], bCenterY, shapeAabbMin[3]) -- b
        edges[3] = Vec(shapeAabbMin[1], bCenterY, shapeAabbMax[3]) -- c
        edges[4] = Vec(shapeAabbMax[1], bCenterY, shapeAabbMax[3]) -- d

        local closestEdge = edges[1] -- find closest edge
        local index = 1
        for i = 1, #edges do
            local edge = edges[i]

            local edgeDist = VecDist(pos, edge)
            local closesEdgeDist = VecDist(pos, closestEdge)

            if edgeDist < closesEdgeDist then
                closestEdge = edge
                index = i
            end
        end
        return closestEdge, index
    end
    --- Sort edges by closest to startPos and closest to endPos. Return sorted table.
    AabbSortEdges = function(startPos, endPos, edges)
        local s, startIndex = aabbClosestEdge(startPos, edges)
        local e, endIndex = aabbClosestEdge(endPos, edges)
        --- Swap first index with startPos and last index with endPos. Everything between stays same.
        edges = tableSwapIndex(edges, 1, startIndex)
        edges = tableSwapIndex(edges, #edges, endIndex)
        return edges
    end



    -- Shape center
    function AabbGetShapeCenterPos(shape)
        local mi, ma = GetShapeBounds(shape)
        return VecLerp(mi,ma,0.5)
    end
    -- Shape center top
    function AabbGetShapeCenterTopPos(shape, addY)
        addY = addY or 0
        local mi, ma = GetShapeBounds(shape)
        local v =  VecLerp(mi,ma,0.5)
        v[2] = ma[2] + addY
        return v
    end
    -- Shape center bottom
    function AabbGetShapeCenterBottomPos(shape, addY)
        addY = addY or 0
        local mi, ma = GetShapeBounds(shape)
        local v =  VecLerp(mi,ma,0.5)
        v[2] = mi[2] + addY
        return v
    end



    -- Body center
    function AabbGetBodyCenterPos(body)
        local mi, ma = GetBodyBounds(body)
        return VecLerp(mi,ma,0.5)
    end
    -- Body center top
    function AabbGetBodyCenterTopPos(body, addY)
        addY = addY or 0
        local mi, ma = GetBodyBounds(body)
        local v =  VecLerp(mi,ma,0.5)
        v[2] = ma[2] + addY
        return v
    end
    -- Body center top
    function AabbGetBodyCenterBottomPos(body, addY)
        addY = addY or 0
        local mi, ma = GetBodyBounds(body)
        local v =  VecLerp(mi,ma,0.5)
        v[2] = mi[2] + addY
        return v
    end

end

--[[OBB]]
do
    ObbDrawShape = function(shape)

        local shapeTr = GetShapeWorldTransform(shape)
        local shapeDim = VecScale(Vec(sx, sy, sz), 0.1)
        local maxTr = Transform(TransformToParentPoint(shapeTr, shapeDim), shapeTr.rot)

        for i = 1, 3 do

            local vec = Vec(0,0,0)

            vec[i] = shapeDim[i]

            DebugLine(shapeTr.pos, maxTr.pos)
            DebugLine(shapeTr.pos, TransformToParentPoint(shapeTr, vec), 0,1,0, 1)
            DebugLine(maxTr.pos, TransformToParentPoint(maxTr, VecScale(vec, -1)), 1,0,0, 1)

        end

    end
end

--[[PHYSICS]]
do
    -- Reduce the angular body velocity by a certain rate each frame.
    DiminishBodyAngVel = function(body, rate)
        local av = GetBodyAngularVelocity(body)
        local dRate = rate or 0.99
        local diminishedAngVel = Vec(av[1]*dRate, av[2]*dRate, av[3]*dRate)
        SetBodyAngularVelocity(body, diminishedAngVel)
    end
    IsMaterialUnbreakable = function(mat, shape)
        return mat == 'rock' or mat == 'heavymetal' or mat == 'unbreakable' or mat == 'hardmasonry' or
            HasTag(shape,'unbreakable') or HasTag(GetShapeBody(shape),'unbreakable')
    end
end


GetCrosshairWorldPos = function(rejectBodies, fwdPos, pos)

    for key, b in pairs(rejectBodies) do QueryRejectBody(b) end

    local crosshairTr = GetCrosshairCameraTr()
    if pos then
        crosshairTr.pos = pos
    end
    local crosshairHit, crosshairHitPos = RaycastFromTransform(crosshairTr, 500)
    if crosshairHit then
        return crosshairHitPos
    elseif not crosshairHit or fwdPos then
        return TransformToParentPoint(GetCameraTransform(), Vec(0,0,-500))
    end

end


GetCrosshairCameraTr = function(pos, x, y)

    pos = pos or GetCameraTransform()

    local crosshairDir = UiPixelToWorld(UiCenter(), UiMiddle())
    local crosshairQuat = DirToQuat(crosshairDir)
    local crosshairTr = Transform(GetCameraTransform().pos, crosshairQuat)

    return crosshairTr

end

DebugPath = function(tb_points, tb_color, a, dots, dots_size)
    if #tb_points >= 2 then
        for i = 1, #tb_points - 1 do -- Stop at the second last point.
            dbl(tb_points[i], tb_points[i+1], 1,1,1,1)
            if dots then
                DrawDot(tb_points[1], dots_size or 0.5, dots_size or 0.5, unpack(tb_color or Colors.white))
                DrawDot(tb_points[#tb_points], dots_size or 0.5, dots_size or 0.5, unpack(tb_color or Colors.white))
            end
        end
    end
end


function GetVecString(v)
    return (sfn(v[1]) .. ", " .. sfn(v[2]) .. ", " .. sfn(v[3]))
end

--- Must be called in draw()
function DebugCompass(font_size)
    UiPush()

        font_size = font_size or 24

        UiFont("regular.ttf", font_size)
        UiColor(1,1,1, 1)
        UiTextShadow(1,1,1, 1, 0.3, 0.1)
        UiAlign("left top")

        local hit, hitPos, shape = RaycastFromTransform(GetCameraTransform())
        if hit then

            DrawShapeOutline(shape, 1,1,1,1)
            DebugLine(hitPos, VecAdd(hitPos, Vec(3,0,0)), 1,0,0, 1)
            DebugLine(hitPos, VecAdd(hitPos, Vec(0,3,0)), 0,1,0, 1)
            DebugLine(hitPos, VecAdd(hitPos, Vec(0,0,3)), 0,0,1, 1)

            UiPush()

                local x,y = UiWorldToPixel(hitPos)

                UiTranslate(x,y)

                UiTranslate(0, font_size)
                UiColor(1,0,0, 1)
                UiText(sfn(hitPos[1], 1))

                UiTranslate(0, font_size)
                UiColor(0,1,0, 1)
                UiText(sfn(hitPos[2], 1))

                UiTranslate(0, font_size)
                UiColor(0,0,1, 1)
                UiText(sfn(hitPos[3], 1))

            UiPop()

        end

    UiPop()
end


function IsInfrontOfTr(tr, pos)
    return TransformToLocalPoint(tr, pos)[3] < 0
end