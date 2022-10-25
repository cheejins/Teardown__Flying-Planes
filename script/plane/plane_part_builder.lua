-- AERO PARTS
-- center parts are universal, such as flaps and rudders which always align with the plane.
-- Parts like ailerons should be left or right since they rotate in the opposite direction of one another.
-- Parts like 2 parallel rudders (mig29, f15m, etc) should be tagged "rudder=center" since they rotate in the same direction.
-- Aero parts will use the rotations they are spawned with as their default return position.


PlaneParts = {

    aero = {

        rudder = {
            center = {},
            left = {},
            right = {},
        },

        elevator = {
            center = {},
            left = {},
            right = {},
        },

        aileron = {
            center = {},
            left = {},
            right = {},
        },

        flap = {
            center = {},
            left = {},
            right = {},
        },

    },

    system = {

        engines = {
            center = {},
            left = {},
            right = {},
        }

    }

}


function plane_BuildParts(plane)

    local Plane_ID = plane

    -- Find all
    AllVehicles = FindVehicles(Plane_ID, true)
    AllBodies = FindBodies(Plane_ID, true)
    AllShapes = FindShapes(Plane_ID, true)
    AllLights = FindLights(Plane_ID, true)
    AllLocations = FindLocations(Plane_ID, true)
    AllTriggers = FindTriggers(Plane_ID, true)

    for index, value in ipairs(AllEntities) do

    end

end