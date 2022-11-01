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

-- LANDING GEAR

    -- Each landing gear compound is a vehicle (required to use a wheel). It's parts are:
        -- body = holds the wheel entity and the single landing gear shape.
        -- shape = within the body and holds the light entity, similar to the aero parts. Only one shape is allowed and must contain the pivot light.
        -- light = has the tag "pivot" with a value that represents the total degrees the landing gear contracts/expands. Example: pivot=90.



PlaneParts = {

    aero = {
        rudder = {},
        elevator = {},
        aileron = {},
        flap = {},
    },

    landing_gear = {},

    vtol = {},

    systems = {
        engines = {}
    }

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


    local AllVehicles  = FindVehicles("Plane_ID", true)
    local AllBodies    = FindBodies("Plane_ID", true)
    local AllShapes    = FindShapes("Plane_ID", true)
    local AllLights    = FindLights("Plane_ID", true)
    local AllLocations = FindLocations("Plane_ID", true)
    local AllTriggers  = FindTriggers("Plane_ID", true)


    plane.AllVehicles  = ExtractAllEntitiesByTagValue(AllVehicles,   "Plane_ID", plane.id)
    plane.AllBodies    = ExtractAllEntitiesByTagValue(AllBodies,     "Plane_ID", plane.id)
    plane.AllShapes    = ExtractAllEntitiesByTagValue(AllShapes,     "Plane_ID", plane.id)
    plane.AllLights    = ExtractAllEntitiesByTagValue(AllLights,     "Plane_ID", plane.id)
    plane.AllLocations = ExtractAllEntitiesByTagValue(AllLocations,  "Plane_ID", plane.id)
    plane.AllTriggers  = ExtractAllEntitiesByTagValue(AllTriggers,   "Plane_ID", plane.id)


    if Config.unbreakable_planes then
        for index, shape in ipairs(plane.AllShapes) do
            SetTag(shape, "unbreakable")
        end
    end


    -- Aero parts
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


    -- Landing gear
    for index, vehicle in ipairs(AllVehicles) do

        local isLandingGear = HasTag(vehicle, "landing_gear")
        local isSamePlane = GetTagValue(vehicle, "Plane_ID") == plane.id

        if isLandingGear and isSamePlane then -- Find landing_gear vehicle entities.

            local body = GetVehicleBody(vehicle)
            local shape = GetBodyShapes(body)[1]
            local light = GetShapeLights(shape)[1]

            if HasTag(light, "pivot") then -- Find pivot light in landing_gear vehicle.

                if vehicle == vehicle then

                    local gear = {
                        light = light,
                        shape = shape,
                        body = body,
                        vehicle = vehicle,
                        voxels = GetShapeVoxelCount(shape),
                        angle = GetTagValue(light, "pivot"),
                        localTr = TransformToLocalTransform(plane.tr, GetLightTransform(light)),
                    }

                    table.insert(planeParts.landing_gear, gear)

                end

            end

        end
    end


    -- VTOL thrusters
    for index, shape in ipairs(AllShapes) do

        if GetTagValue(shape, "Plane_ID") == plane.id and HasTag(shape, "vtol") then

            local body = GetShapeBody(shape)

            local light_pivot = nil
            for index, light in ipairs(GetShapeLights(shape)) do
                if HasTag(light, "pivot") then
                    light_pivot = light
                    break
                end
            end

            local vtol = {
                body = body,
                shape = shape,
                light = light_pivot,
                localTr = TransformToLocalTransform(plane.tr, GetLightTransform(light_pivot)),
                angle = GetTagValue(light_pivot, "pivot"),
                voxels = GetShapeVoxelCount(shape),
            }

            table.insert(planeParts.vtol, vtol)

        end
    end


    -- Find shapes to delete.
    local deleteShapes = {}
    for index, shape in ipairs(plane.AllShapes) do
        if HasTag(shape, "delete") then
            table.insert(deleteShapes, shape)
            Delete(shape)
        end
    end
    -- Safe delete shapes.
    for _, deleteShape in ipairs(deleteShapes) do
        for index, shape in ipairs(plane.AllShapes) do
            if shape == deleteShape then
                table.remove(plane.AllShapes, index)
                break
            end
        end
    end

    plane.parts = planeParts

end




-- Find entities of a specific type (shape, body etc...) with the relevant id tag.
function ExtractAllEntitiesByTagValue(entity_table, tag, tag_value)

    local entities = {}

    for _, entity in ipairs(entity_table) do
        if GetTagValue(entity, tag) == tag_value then
            table.insert(entities, entity)
        end
    end

    return entities

end

function ExtractAllEntitiesByTag(entities, tag)
    local e = {}
    for _, entity in ipairs(entities) do
        if HasTag(entity, tag) then
            table.insert(e, entity)
        end
    end
    return e
end

function ExtractEntityByTag(entities, tag)
    for _, entity in ipairs(entities) do
        if HasTag(entity, tag) then
            return entity
        end
    end
    print("Entity: " .. tag .. " not found.")
end