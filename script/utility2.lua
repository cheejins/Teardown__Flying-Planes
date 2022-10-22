--[[VECTORS]]
do
    --- Distance between two vectors.
    function VecDist(a, b) return VecLength(VecSub(a, b)) end
    --- Divide a vector by another vector's components.
    function VecDiv(a, b) return Vec(a[1] / b[1], a[2] / b[2], a[3] / b[3]) end
    --- Add a table of vectors together.
    function VecAddAll(vtb) local v = Vec(0,0,0) for i = 1, #vtb do VecAdd(v, vtb[i]) end return v end
    --- Returns a vector with random values.
    function VecRdm(length)
        local v = VecNormalize(Vec(math.random(-100,100), math.random(-100,100), math.random(-100,100)))
        return VecScale(v, length)
    end
    --- Print QuatEulers or vectors.
    function VecPrint(vec, decimals, label)
        DebugPrint((label or "") ..
            "  " .. sfn(vec[1], decimals or 2) ..
            "  " .. sfn(vec[2], decimals or 2) ..
            "  " .. sfn(vec[3], decimals or 2))
    end
    function VecApproach(startPos, endPos, speed)
        local subtractedPos = VecScale(VecNormalize(VecSub(endPos, startPos)), speed)
        return VecAdd(startPos, subtractedPos)
    end
    function VecMult(vec1, vec2)
        local vec = Vec(0,0,0)
        for i = 1, 3 do vec[i] = vec1[i] * vec2[i] end
        return vec
    end
    function VecAvg(v1, v2)
        VecApproach(v1, v2, VecDist(v1,v2)/2)
    end


    getCrosshairWorldPos = function(rejectBodies)

        for key, b in pairs(rejectBodies) do QueryRejectBody(b) end

        local crosshairTr = getCrosshairTr()
        local crosshairHit, crosshairHitPos = RaycastFromTransform(crosshairTr, 300)
        if crosshairHit then
            return crosshairHitPos
        -- else
        --     return TransformToParentPoint(GetCameraTransform(), Vec(0,0,-1000))
        end

    end


    getCrosshairTr = function(pos, x, y)

        pos = pos or GetCameraTransform()

        local crosshairDir = UiPixelToWorld(UiCenter(), UiMiddle())
        local crosshairQuat = DirToQuat(crosshairDir)
        local crosshairTr = Transform(GetCameraTransform().pos, crosshairQuat)

        return crosshairTr

    end
end


--[[QUAT]]
do
    function QuatLookUp(pos) return QuatLookAt(pos, VecAdd(pos, Vec(0, 1, 0))) end
    function QuatLookDown(pos) return QuatLookAt(pos, VecAdd(pos, Vec(0, -1, 0))) end

    function QuatTrLookUp(tr) return QuatLookAt(tr.pos, TransformToParentPoint(tr, Vec(0,1,0))) end
    function QuatTrLookDown(tr) return QuatLookAt(tr.pos, TransformToParentPoint(tr, Vec(0,-1,0))) end
    function QuatTrLookLeft(tr) return QuatLookAt(tr.pos, TransformToParentPoint(tr, Vec(-1,0,0))) end
    function QuatTrLookRight(tr) return QuatLookAt(tr.pos, TransformToParentPoint(tr, Vec(1,0,0))) end
    function QuatTrLookBack(tr) return QuatLookAt(tr.pos, TransformToParentPoint(tr, Vec(0,0,1))) end


    -- -- Quat to normalized dir.
    -- function QuatToDir(quat)
    --     local x,y,z = GetQuatEuler(quat)
    --     return Vec(math.rad(x/math.pi),math.rad(y/math.pi),math.rad(z/math.pi))
    -- end

    -- Quat to normalized dir.
    -- function QuatToDir(quat)
    --     local dirPos = TransformToParentPoint(Transform(Vec(), quat), Vec(0,0,-1))
    --     return VecNormalize()

    -- end

    -- function QuatToDir(quat) return VecNormalize(TransformToParentPoint(Transform(Vec(), quat), Vec(0,0,-1))) end -- Quat to normalized dir.



    function DirToQuat(dir) return QuatEuler(math.deg(dir[1]),math.deg(dir[2]),math.deg(dir[3])) end -- Normalized dir to quat.
    function DirLookAt(eye, target) return VecNormalize(VecSub(eye, target)) end -- Normalized dir of two positions.

    function VecAngle(a,b) -- Angle between two vectors.
        local c = {a[1], a[2], a[3]}
        local d = {b[1], b[2], b[3]}
        return math.deg(math.acos(myDot(c, d) / (myMag(c) * myMag(d))))
    end

    function QuatAngle(a,b) -- Angle between two vectors.
        av = QuatToDir(a)
        bv = QuatToDir(b)
        local c = {av[1], av[2], av[3]}
        local d = {bv[1], bv[2], bv[3]}
        return math.deg(math.acos(myDot(c, d) / (myMag(c) * myMag(d))))
    end

end

--[[AABB]]
do
    function AabbDimensions(min, max) return Vec(max[1] - min[1], max[2] - min[2], max[3] - min[3]) end
    function AabbDraw(v1, v2, r, g, b, a)
        r = r or 1
        g = g or 1
        b = b or 1
        a = a or 1
        local x1 = v1[1]
        local y1 = v1[2]
        local z1 = v1[3]
        local x2 = v2[1]
        local y2 = v2[2]
        local z2 = v2[3]
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
    function AabbCheckOverlap(aMin, aMax, bMin, bMax)
        return
        (aMin[1] <= bMax[1] and aMax[1] >= bMin[1]) and
        (aMin[2] <= bMax[2] and aMax[2] >= bMin[2]) and
        (aMin[3] <= bMax[3] and aMax[3] >= bMin[3])
    end
    function AabbCheckPointInside(aMin, aMax, pos)
        return
        (pos[1] <= aMax[1] and pos[1] >= aMin[1]) and
        (pos[2] <= aMax[2] and pos[2] >= aMin[2]) and
        (pos[3] <= aMax[3] and pos[3] >= aMin[3])
    end
    function AabbClosestEdge(pos, shape)

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
    function AabbSortEdges(startPos, endPos, edges)
        local s, startIndex = aabbClosestEdge(startPos, edges)
        local e, endIndex = aabbClosestEdge(endPos, edges)
        --- Swap first index with startPos and last index with endPos. Everything between stays same.
        edges = tableSwapIndex(edges, 1, startIndex)
        edges = tableSwapIndex(edges, #edges, endIndex)
        return edges
    end
    function AabbGetShapeCenterPos(shape)
        local mi, ma = GetShapeBounds(shape)
        return VecLerp(mi,ma,0.5)
    end
    function AabbGetBodyCenterPos(body)
        local mi, ma = GetBodyBounds(body)
        return VecLerp(mi,ma,0.5)
    end
    function AabbGetShapeCenterTopPos(shape, addY)
        addY = addY or 0
        local mi, ma = GetShapeBounds(shape)
        local v =  VecLerp(mi,ma,0.5)
        v[2] = ma[2] + addY
        return v
    end
    function AabbGetBodyCenterTopPos(body, addY)
        addY = addY or 0
        local mi, ma = GetBodyBounds(body)
        local v =  VecLerp(mi,ma,0.5)
        v[2] = ma[2] + addY
        return v
    end
end

--[[OBB]]
do
    function ObbDrawShape(shape)

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

--[[TABLES]]
do
    function TableSwapIndex(t, i1, i2)
        local temp = t[i1]
        t[i1] = t[i2]
        t[i2] = temp
        return t
    end
    function TableClone(tb)
        local tbc = {}
        for k,v in pairs(tb) do tbc[k] = v end
        return tbc
    end

    function DeepCopy(orig)
        local orig_type = type(orig)
        local copy
        if orig_type == 'table' then
            copy = {}
            for orig_key, orig_value in next, orig, nil do
                copy[DeepCopy(orig_key)] = DeepCopy(orig_value)
            end
            setmetatable(copy, DeepCopy(getmetatable(orig)))
        else -- number, string, boolean, etc
            copy = orig
        end
        return copy
    end


    ---@param t table -- table to print
    ---@param n number -- recursion depth (leave as 0)
    function printTable(t, n)

        n = n or 0

        if n == 0 then
            print('--- --- --- --- --- --- --- --- ---\n')
        end

        local tabs = ''
        for i = 1, n do
            tabs = tabs .. '  '
        end

        for index, value in pairs(t) do

            n = n + 1

            if type(value) == 'table' then

                print(index)
                printTable(value, n)

                n = n - 1

            else

                print(tabs .. index .. ' = ' .. value)

            end

        end

        print('')

    end

    function GetRandomIndex(tb)
        return math.random(1, #tb)
    end

    function GetRandomIndexValue(tb)
        return tb[math.random(1, #tb)]
    end


    ---A helper function to print a table's contents.
    ---@param tbl table @The table to print.
    ---@param depth number @The depth of sub-tables to traverse through and print.
    ---@param n number @Do NOT manually set this. This controls formatting through recursion.
    function PrintTable(tbl, depth, n)
        n = n or 0;
        depth = depth or 10;

        if (depth == 0) then
            print(string.rep(' ', n).."...");
            return;
        end

        if (n == 0) then
            print(" ");
        end

        for key, value in pairs(tbl) do
            if (key and type(key) == "number" or type(key) == "string") then
                key = string.format("%s", key);

                if (type(value) == "table") then
                    if (next(value)) then
                        print(string.rep(' ', n)..key.." = {");
                        PrintTable(value, depth - 1, n + 4);
                        print(string.rep(' ', n).."},");
                    else
                        print(string.rep(' ', n)..key.." = {},");
                    end
                else
                    if (type(value) == "string") then
                        value = string.format("\"%s\"", value);
                    else
                        value = tostring(value);
                    end

                    print(string.rep(' ', n)..key.." = "..value..",");
                end
            end
        end

        if (n == 0) then
            print(" ");
        end
    end


end


--[[QUERY]]
do
    ---Raycast from a transform.
    ---@param tr table -- Source transform.
    ---@param dist number -- Max raycast distance. Default is 300.
    ---@param rad number -- Raycast radius/thickness.
    ---@param rejectBodies table -- Table of bodies to query reject.
    ---@param rejectShapes table -- Table of shapes to query reject.
    ---@param returnNil bool -- If true, return nil if no raycast hit. If false, return the end point of the raycast based on the transfom and distance.
    ---@return h boolean hit
    ---@return p table hit position
    ---@return d number hit dist
    ---@return s number hit shape
    ---@return b number hit body
    ---@return n table normal
    function RaycastFromTransform(tr, dist, rad, rejectBodies, rejectShapes, returnNil)

        dist = dist or 300

        if rejectBodies ~= nil then for i = 1, #rejectBodies do QueryRejectBody(rejectBodies[i]) end end
        if rejectShapes ~= nil then for i = 1, #rejectShapes do QueryRejectShape(rejectShapes[i]) end end

        returnNil = returnNil or false

        local direction = QuatToDir(tr.rot)
        local h, d, n, s = QueryRaycast(tr.pos, direction, dist, rad)
        if h then

            local p = TransformToParentPoint(tr, Vec(0, 0, d * -1))
            local b = GetShapeBody(s)
            return h, p, d, s, b, n

        elseif returnNil then
            return nil
        else
            return TransformToParentPoint(tr, Vec(0,0,-dist))
        end

    end
end



--[[PHYSICS]]
do
    -- Reduce the angular body velocity by a certain rate each frame.
    function DiminishBodyAngVel(body, rate)
        local angVel = GetBodyAngularVelocity(body)
        local dRate = rate or 0.99
        local diminishedAngVel = Vec(angVel[1]*dRate, angVel[2]*dRate, angVel[3]*dRate)
        SetBodyAngularVelocity(body, diminishedAngVel)
    end
    function IsMaterialUnbreakable(mat, shape)
        return mat == 'rock' or mat == 'heavymetal' or mat == 'unbreakable' or mat == 'hardmasonry' or
            HasTag(shape,'unbreakable') or HasTag(GetShapeBody(shape),'unbreakable')
    end
end


--[[VFX]]
do
    colors = {
        white = Vec(1,1,1),
        black = Vec(0,0,0),
        grey = Vec(0,0,0),
        red = Vec(1,0,0),
        blue = Vec(0,0,1),
        yellow = Vec(1,1,0),
        purple = Vec(1,0,1),
        green = Vec(0,1,0),
        orange = Vec(1,0.5,0),
    }
    function DrawDot(pos, l, w, r, g, b, a, dt)
        local dot = LoadSprite("ui/hud/dot-small.png")
        local spriteRot = QuatLookAt(pos, GetCameraTransform().pos)
        local spriteTr = Transform(pos, spriteRot)
        if dt == nil then dt = true end
        DrawSprite(dot, spriteTr, l or 0.2, w or 0.2, r or 1, g or 1, b or 1, a or 1, dt and true)
    end
end



--[[SOUND]]
do
    function beep(pos, vol) PlaySound(LoadSound("warning-beep"), pos or GetCameraTransform().pos, vol or 0.3) end
    function buzz(pos, vol) PlaySound(LoadSound("light/spark0"), pos or GetCameraTransform().pos, vol or 0.3) end
    function chime(pos, vol) PlaySound(LoadSound("elevator-chime"), pos or GetCameraTransform().pos, vol or 0.3) end
    function shine(pos, vol) PlaySound(LoadSound("valuable.ogg"), pos or GetCameraTransform().pos, vol or 0.3) end
end



--[[MATH]]
do
    function round(n, dec) local pow = 10^dec return math.floor(n * pow) / pow end
    --- return number if > 0, else return 0.00000001
    function gtZero(n) if n <= 0 then return 0.00000001 end return n end
    --- return number if not = 0, else return 0.00000001
    function nZero(n) if n == 0 then return 0.00000001 end return n end

    function rdm(min, max)
        return math.random(min, max-1) + math.random()
    end
    function clamp(value, mi, ma)
        if value < mi then value = mi end
        if value > ma then value = ma end
        return value
    end
    function oscillate(time)
        local a = ((-1/2) * math.cos(2 * math.pi * GetTime()/(time or 1))) + 0.5
        return a
    end

    ---Returns a convex parabola starting at x=0, ending at x=1 and its center vertex at y=1.
    ---@param n number A number between 0 and 1.
    ---@return number
    function getQuadtratic(n)
        return -4 * ( n -0.5) ^ 2 + 1
    end

    ---@param x number
    ---@param hScale number
    function GetParabola(x, hScale)
        local h = 1
        local w = 0
        local s = 1
        local y = (-(4*h-w) * (x-(1/2)*s)^2 + (4*h/4)) * hScale
        return y
    end

    function DrawParabola()
        local scale = 3
        local hScale = 4
        local denisty = 10 * scale
        for i = 0, 1, 1/denisty do
            local pos = Vec(i, 0, 0)
            pos[2] = GetParabola(i, hScale)
            pos = VecScale(pos, scale)

            DrawDot(pos, 0.2,0.2, 0,1,1, 1, false)
        end
    end

    function Round(x, n)
        n = math.pow(10, n or 0)
        x = x * n
        if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
        return x / n
    end
end

--[[MISC]]
function myDot(a, b) return (a[1] * b[1]) + (a[2] * b[2]) + (a[3] * b[3]) end
function myMag(a) return math.sqrt((a[1] * a[1]) + (a[2] * a[2]) + (a[3] * a[3])) end



--[[LOGIC]]
do
    function ternary ( cond , T , F )
        if cond then return T else return F end
    end
end




--[[FORMATTING]]
do
    --- string format. default 2 decimals.
    function sfn(numberToFormat, dec)
        local s = (tostring(dec or 2))
        return string.format("%."..s.."f", numberToFormat)
    end
    function sfnTime(dec) return sfn(' '..GetTime(), dec or 4) end
    function sfnCommas(dec)
        return tostring(math.floor(dec)):reverse():gsub("(%d%d%d)","%1,"):gsub(",(%-?)$","%1"):reverse()
        -- https://stackoverflow.com/questions/10989788/format-integer-in-lua
    end
end




--[[TIMERS]]
do

    function TimerCreate(time, rpm)
        return { time = time, rpm = rpm }
    end

    ---Run a timer and a table of functions.
    ---@param timer table -- = {time, rpm}
    ---@param functions table -- Table of functions that are called when time = 0.
    ---@param runTime boolean -- Decrement time when calling this function.
    function TimerRunTimer(timer, functions, runTime)
        if timer.time <= 0 then
            TimerResetTime(timer)

            for i = 1, #functions do
                functions[i]()
            end

        elseif runTime then
            TimerRunTime(timer)
        end
    end

    -- Only runs the timer countdown if there is time left.
    function TimerRunTime(timer)
        timer.time = timer.time - GetTimeStep()
    end

    -- Set time left to 0.
    function TimerEndTime(timer)
        timer.time = 0
    end

    -- Reset time to start (60/rpm).
    function TimerResetTime(timer)
        timer.time = 60/timer.rpm
    end

    function TimerConsumed(timer)
        return timer.time <= 0
    end

end



--[[TOOL]]
---Disable all tools except specified ones.
---@param allowTools table -- Table of strings (tool names) to not disable.
function disableTools(allowTools)
    local toolNames = {sledge = 'sledge', spraycan = 'spraycan', extinguisher ='extinguisher', blowtorch = 'blowtorch'}
    local tools = ListKeys("game.tool")
    for i=1, #tools do
        if tools[i] ~= toolNames[tools[i]] then
            SetBool("game.tool."..tools[i]..".enabled", false)
        end
    end
end



GetCrosshairWorldPos = function(rejectBodies)

    local crosshairTr = getCrosshairTr()
    local crosshairHit, crosshairHitPos = RaycastFromTransform(crosshairTr, 200, 0, rejectBodies)
    if crosshairHit then
        return crosshairHitPos
    else
        return nil
    end

end

GetCrosshairCameraTr = function(pos, x, y)

    pos = pos or GetCameraTransform()

    local crosshairDir = UiPixelToWorld(x or UiCenter(), y or UiMiddle())
    local crosshairQuat = DirToQuat(crosshairDir)
    local crosshairTr = Transform(GetCameraTransform().pos, crosshairQuat)

    return crosshairTr

end