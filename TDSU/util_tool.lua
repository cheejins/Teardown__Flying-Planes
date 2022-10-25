TOOL = {} -- Game global tool.
Tool = {} -- Actual tool.


local id    = 'glowingSea'
local name  = 'Glowing Sea'
local file  = 'MOD/TDSU/tool/tool.vox'
local group = 6


function InitTool(Tool)

    -- Consctruct table values.
    Tool.setup = {
        id    = id,
        name  = name,
        file  = file,
        group = group,
    }

    -- -- Replace table functions with the root global functions
    -- for key, value in pairs(_G) do
    --     if string.sub(key, 1,5) == "Tool_" then
    --         Tool[key] = _G[key]
    --     end
    -- end

    Tool.isActive   = Tool_isActive
    Tool.startWith  = Tool_startWith
    Tool.switchTo   = Tool_switchTo
    Tool.lockScroll = Tool_lockScroll
    Tool.isEnabled  = Tool_setEnabled

    RegisterTool(Tool.setup.id, Tool.setup.name, Tool.setup.file, Tool.setup.group)
    SetBool('game.tool.'..Tool.setup.id..'.enabled', enabled or true)

end


function Tool_isActive(self, ignoreSafeMode)

    local isWeilding    = GetString('game.player.tool') == self.setup.id
    local inVehicle     = ignoreSafeMode or (GetPlayerVehicle() ~= 0)
    local isGrabbing    = ignoreSafeMode or GetString('game.player.grabbing') == self.setup.id

    return inVehicle and isWeilding and isGrabbing

end


---Called in tick().
function Tool_startWith(self)
    if TOOLSTART == nil then
        SetString('game.player.tool', self.setup.id)
        TOOLSTART = true -- Calls once only
    end
end
function Tool_switchTo(self)
    SetString('game.player.tool', self.setup.id)
end
function Tool_lockScroll(self)
    SetString('game.player.tool', self.setup.id)
end


function Tool_setEnabled(self, isEnabled)
    SetBool('game.tool.'..self.setup.id..'.enabled', isEnabled)
end


---Disable all tools except specified ones.
---@param allowTools table -- Table of strings (tool names) to ignore.
function DisableTools(allowTools)
    -- local toolNames = {sledge = 'sledge', spraycan = 'spraycan', extinguisher ='extinguisher', blowtorch = 'blowtorch'}
    local tools = ListKeys("game.tool")
    for i = 1, #tools do
        -- if tools[i] ~= toolNames[tools[i]] then
            SetBool("game.tool."..tools[i]..".enabled", false)
        -- end
    end
end
