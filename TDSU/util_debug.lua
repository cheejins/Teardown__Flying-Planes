db_groups = {
    override = false, -- Force all db functions on.
    mod = true,
}


function InitDebug()
    DB = GetBool('savegame.mod.debugModeMaster')
    db = GetBool('savegame.mod.debugMode')
end


---Handles the toggling of debug mode.
---@param DB boolean Debug debugger.
---@param db boolean Debug mod.
function TickDebug(DB, db)

    DB = GetBool('savegame.mod.debugModeMaster')
    if InputDown('pgup') and InputPressed('f1') then
        ToggleDB()
    end

    db = GetBool('savegame.mod.debugMode')
    if InputDown('pgup') and InputPressed('f2') then
        ToggleDb()
    end

end


function ToggleDb()
    SetBool('savegame.mod.debugMode', not GetBool('savegame.mod.debugMode'))
    db = GetBool('savegame.mod.debugMode')
    print("db mode: " .. ternary(db, 'on\t', 'off\t') .. sfnTime())
    -- ternary(db, beepOn, beepOff)()
end

function ToggleDB()
    SetBool('savegame.mod.debugModeMaster', not GetBool('savegame.mod.debugModeMaster'))
    DB = GetBool('savegame.mod.debugModeMaster')
    print("DB mode: " .. ternary(DB, 'on\t', 'off\t') .. sfnTime())
    -- ternary(DB, beepOn, beepOff)()
end


---Run a function if db is true.
---@param func function The global function to run.
---@param tb_args table Table of arguements for the function.
function dbfunc(func, tb_args) if db then func(table.unpack(tb_args)) end end


--[[DEBUG CONSOLE]]
function dbw(str, value) if db then DebugWatch(str, value) end end -- DebugWatch()
function dbp(str) if db then print(str .. '(' .. sfnTime() .. ')') end end -- DebugPrint()
function dbpc(str, newLine) if db then print(str .. ternary(newLine, '\n', '')) end end -- DebugPrint() to external console window only.
function dbpt(tb) if db then PrintTable(tb) end end -- PrintTable() to external console window.


--[[DEBUG 3D]]
function dbl(p1, p2, r,g,b,a, dt) if db then DebugLine(p1, p2, r,g,b,a, dt) end end -- DebugLine()
function dbdd(pos, w,l, r,g,b,a, dt) if db then DrawDot(pos,w,l,r,g,b,a,dt) end end -- Draw a dot sprite at the specified position.
function dbray(tr, dist, r,g,b,a) dbl(tr.pos, TransformToParentPoint(tr, Vec(0,0,-dist)), c1, c2, c3, a) end -- Debug a ray segement from a transform.
function dbcr(pos, r,g,b, a) if db then DebugCross(pos, r or 1, g or 1, b or 1, a or 1) end end -- DebugCross() at a specified position.

function dbpath(tb_points, tb_color, a, dots) --- Draw the lines between an ipair table of points. Gradient between tables tb_rgba1 and tb_rgba2.
    DebugPath(tb_points, tb_color, a, dots)
end


function DebugRay(tr, dist, r,g,b,a) DebugLine(tr.pos, TransformToParentPoint(tr, Vec(0,0,-dist)), r or 1, g or 1, b or 1, a or 1) end -- Debug a ray segement from a transform.




--[[DEBUG SOUNDS]]
function beep(pos, vol) PlaySound(LoadSound("warning-beep"),    pos or GetCameraTransform().pos, vol or 0.5) end
function buzz(pos, vol) PlaySound(LoadSound("light/spark0"),    pos or GetCameraTransform().pos, vol or 0.5) end
function chime(pos, vol) PlaySound(LoadSound("elevator-chime"), pos or GetCameraTransform().pos, vol or 0.5) end
function shine(pos, vol) PlaySound(LoadSound("valuable.ogg"),   pos or GetCameraTransform().pos, vol or 0.5) end

function beepOn(pos, vol) PlaySound(LoadSound("MOD/TDSU/snd/beep-on.ogg"),   pos or GetCameraTransform().pos, vol or 0.3) end
function beepOff(pos, vol) PlaySound(LoadSound("MOD/TDSU/snd/beep-off.ogg"),   pos or GetCameraTransform().pos, vol or 0.3) end
