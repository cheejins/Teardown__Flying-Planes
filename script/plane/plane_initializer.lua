-- #include "../TDSU/tdsu.lua"



-- -- This script is ran for each plane that is spawned.


-- -- PLANE IDs
-- -- This script is responsible for processing plane parts and assigning a global ID to collection of parts.
-- -- In script.lua, the parts will be found using the assigned tags.
-- -- The unique ID is stored in the registry. It will be applied to the vehicle entity as a tag called ID and a value of an integer eg: ID=1, ID=6


-- function init()

--     -- Check whether the script instance is running.
--     CheckScriptEnabled()


--     -- Tag name.
--     IDTag = "Plane_ID"

--     -- This int can always be used as the current ID.
--     ID = GetString("level.Plane_ID")
--     if ID == "" then
--         ID = 0
--     end
--     SetString("level.Plane_ID", tonumber(ID) + 1)


--     -- Apply IDs
--     ApplyPlaneEntityIDs(ID)

-- end


-- function tick()

-- end


-- function ApplyPlaneEntityIDs(ID)

--     AllEntities = {
--         AllVehicles  = FindVehicles("", false),
--         AllBodies    = FindBodies("", false),
--         AllShapes    = FindShapes("", false),
--         AllLights    = FindLights("", false),
--         AllLocations = FindLocations("", false),
--         AllTriggers  = FindTriggers("", false),
--     }

--     for _, entity_group in pairs(AllEntities) do
--         for _, entity in ipairs(entity_group) do
--             SetTag(entity, IDTag, ID)
--         end
--     end

--     for index, shape in ipairs(AllEntities.AllShapes) do
--         SetShapeCollisionFilter(shape, 3, 1)
--     end


-- end


-- function CheckScriptEnabled()

--     if GetBool('level.planeScriptActive') == false then
--         Spawn('MOD/prefab/script.xml', Transform())
--         SetBool('level.planeScriptActive', true)
--         print("Created script.lua")
--     end

-- end
