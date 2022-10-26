-- AERO PARTS

    -- Part types
        -- center parts are universal, such as flaps and rudders which always align with the plane.
        -- Parts like ailerons should be left or right since they rotate in the opposite direction of one another.
        -- Parts like 2 parallel rudders (mig29, f15m, etc) should be tagged "rudder=center" since they rotate in the same direction.
        -- Aero parts will use the rotations they are spawned with as their default return position.

    -- Lights and Joints
        -- Make sure to use hinge joints with no limits. The limits and angling will be controlled by the script using constrain functions.
        -- Each joint should have a light entity placed at the same position as it in the shape. Since the API doesn't allow you to get the transform of joints,
        -- the lights will supplement their transforms so the script knows where to angle the part from.


PlaneParts = {

    aero = {
        rudder = {},
        elevator = {},
        aileron = {},
        flap = {},
    },

    -- system = {
    --     engine = {}
    -- }

}


---Builds a part object.
---@param shape number A part is a single shape.
function plane_BuildPart_Aero(plane, shape, side)

    local light_pivot = GetShapeLights(shape)
    for index, light in ipairs(light_pivot) do
        if HasTag(light, "pivot") then
            light_pivot = light
        end
    end

    local part = {

        shape = shape,
        body = GetShapeBody(shape),
        lights = GetShapeLights(shape),
        joints = GetShapeJoints(shape),
        light_pivot = light_pivot,
        side = side,

        localTr = TransformToLocalTransform(plane.tr, GetLightTransform(light_pivot)),

    }

    for index, joint in ipairs(part.joints) do
        Delete(joint)
    end


    return part

end


function plane_CollectParts_Aero(plane)

    local planeParts = DeepCopy(PlaneParts)


    AllVehicles  = FindVehicles("Plane_ID", true)
    AllBodies    = FindBodies("Plane_ID", true)
    AllShapes    = FindShapes("Plane_ID", true)
    AllLights    = FindLights("Plane_ID", true)
    AllLocations = FindLocations("Plane_ID", true)
    AllTriggers  = FindTriggers("Plane_ID", true)


    for _, shape in ipairs(AllShapes) do

        for part_category_name, part_category_table in pairs(planeParts) do
            for part_name, part_table in pairs(part_category_table) do

                if GetTagValue(shape, "Plane_ID") == plane.id and HasTag(shape, part_name) then -- Tag corresponds to key.

                    -- Example: part_name=center, aileron=left.
                    local part_side = GetTagValue(shape, part_name)

                    -- Insert into side table in part table in category table in parts table.
                    local builtPart = plane_BuildPart_Aero(plane, shape, part_side)
                    table.insert(part_table, builtPart)

                end

            end
        end

    end

    return planeParts

end
