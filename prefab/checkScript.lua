#include "../TDSU/tdsu.lua"

-- This script is ran for each plane that is spawned and is separate from the main script.

-- PLANE IDs
-- This script is responsible for processing plane parts and assigning a global ID to collection of parts.
-- In script.lua, the parts will be found using the assigned tags. The unique ID is stored in the registry.
-- It will be applied to the vehicle entity as a tag called ID and a value of an integer eg: ID=1, ID=6

------------------------------------------------------------------------------------------------------------


function init()

    -- Check whether the script instance is running.
    CheckScriptEnabled()


    -- This int can always be used as the current ID.
    ID = GetInt("level.Plane_ID")
    if ID == 0 then
        ID = 2
    end
    SetInt("level.Plane_ID", ID + 1)


    -- Tag name.
    IDTag = "Plane_ID"

    -- Apply IDs
    ApplyPlaneEntityIDs(ID)

    print("checkScript")

end


function ApplyPlaneEntityIDs(ID)

    AllEntities = {
        AllVehicles  = FindVehicles(""),
        AllBodies    = FindBodies(""),
        AllShapes    = FindShapes(""),
        AllLights    = FindLights(""),
        AllLocations = FindLocations(""),
        AllTriggers  = FindTriggers(""),
    }

    for _, entity_group in pairs(AllEntities) do
        for _, entity in ipairs(entity_group) do
            SetTag(entity, IDTag, ID)
        end
    end

end


function tick()
    for _, shape in ipairs(AllEntities.AllShapes) do
        -- DrawShapeOutline(shape, 1,0,1, 0.5)

        if GetShapeBody(shape) == GetWorldBody() then
            DebugCross(AabbGetShapeCenterPos(shape), 1,0,0, 1)
        end

    end

    -- DrawBodyOutline(GetWorldBody(), 1,0,0, 0.5)
end


function CheckScriptEnabled()
    if GetBool('level.planeScriptActive') == false then
        Spawn('MOD/prefab/script.xml', Transform())
        SetBool('level.planeScriptActive', true)
    end
end
