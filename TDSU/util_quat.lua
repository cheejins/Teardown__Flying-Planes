--[[QUAT]]
do

    -- Quat to normalized dir.
    function QuatToDir(quat) return VecNormalize(TransformToParentPoint(Transform(Vec(0,0,0), quat), Vec(0,0,-1))) end

    -- Normalized dir to quat.
    function DirToQuat(dir) return QuatLookAt(Vec(0,0,0), dir) end

    -- Normalized dir of two positions.
    function DirLookAt(eye, target) return VecNormalize(VecSub(target, eye)) end

    -- Angle between two vectors.
    function VecAngle(a,b) return math.deg(math.acos(VecDot({a[1], a[2], a[3]}, {b[1], b[2], b[3]}) / (VecLength(c) * VecLength(d)))) end

    -- Angle between two vectors.
    function QuatAngle(a,b)
        av = QuatToDir(a)
        bv = QuatToDir(b)
        local c = {av[1], av[2], av[3]}
        local d = {bv[1], bv[2], bv[3]}
        return math.deg(math.acos(VecDot(c, d) / (VecLength(c) * VecLength(d))))
    end

    function QuatLookUp() return DirToQuat(Vec(0, 1, 0)) end -- Quat facing world-up.
    function QuatLookDown() return DirToQuat(Vec(0, -1, 0)) end -- Quat facing world-down.

    function QuatTrLookUp(tr) return QuatLookAt(tr.pos, TransformToParentPoint(tr, Vec(0,1,0))) end -- Quat look above tr.
    function QuatTrLookDown(tr) return QuatLookAt(tr.pos, TransformToParentPoint(tr, Vec(0,-1,0))) end -- Quat look below tr.
    function QuatTrLookLeft(tr) return QuatLookAt(tr.pos, TransformToParentPoint(tr, Vec(-1,0,0))) end -- Quat look left of tr.
    function QuatTrLookRight(tr) return QuatLookAt(tr.pos, TransformToParentPoint(tr, Vec(1,0,0))) end -- Quat look right of tr.
    function QuatTrLookBack(tr) return QuatLookAt(tr.pos, TransformToParentPoint(tr, Vec(0,0,1))) end -- Quat look behind tr.

end
