#include "umf.lua"
#include "util_color.lua"
#include "util_debug.lua"
#include "util_env.lua"
#include "util_lua.lua"
#include "util_math.lua"
#include "util_quat.lua"
#include "util_td.lua"
#include "util_timer.lua"
#include "util_tool.lua"
#include "util_ui.lua"
#include "util_umf.lua"
#include "util_vec.lua"
#include "util_vfx.lua"


--================================================================
--Teardown Scripting Utilities (TDSU)
--By: Cheejins
--================================================================


_BOOLS = {} -- Control variable used for functions like CallOnce()


---INIT Initialize the utils library.
function Init_Utils()

    InitDebug()
    InitColor()
    InitTool(Tool)
    InitEnv()


    print("TDSU initialized.")

end

---TICK Manage and run the utils library.
function Tick_Utils()

    TickDebug(DB, db)

end
