AI_PLANES = {}
AI_PLANES_NOTSET = {}

local flightPath = {}

local plane_prefabs = {
    "MOD/prefab/Mig29.xml",
    "MOD/prefab/F15.xml",
    "MOD/prefab/A10.xml",
    "MOD/prefab/Harrier.xml",
}


function aiplanes_CreateFlightpaths()

    local radius = 1000
    local heightRange = {800,1000}

    -- Initial flight pos.
    table.insert(flightPath, CreateFlightPos(radius, heightRange))

    for i = 1, 4 do

        local pos = CreateFlightPos(radius, heightRange)

        local tries = 0
        while VecDist(flightPath[#flightPath], pos) < (radius / 4) or (tries < 5) do

            pos = CreateFlightPos(radius, heightRange)
            tries = tries + 1

        end

        table.insert(flightPath, pos)

    end

end

function CreateFlightPos(radius, heightRange)
    return VecAdd(GetMapCenter(), AutoVecSubsituteY(VecRandom(radius), math.random(heightRange[1], heightRange[2])))
end

function Init_AIPLANES()
    aiplanes_CreateFlightpaths()
end

function GetMapCenter()

    local min, max = Vec(), Vec()
    for index, shape in ipairs(FindShapes("", true)) do

        local sMin, sMax = GetShapeBounds()

        min = VecMin(min, sMin)
        max = VecMax(max, sMax)

    end

    return AutoVecSubsituteY(VecLerp(min, max), min[2])

end


function Tick_aiplanes()

    local alivePlanes = 1
    for index, plane in ipairs(AI_PLANES) do
        if plane.isAlive then
            alivePlanes = alivePlanes + 1
        end
    end

    if Config.spawn_aiplanes then
        for i = alivePlanes, 3 do
            local pos = AutoVecSubsituteY(VecRandom(800), math.random(400,600))
            local tr = Transform(pos)
            aiplane_SpawnPlane(tr)
        end
    end

    for _, plane in ipairs(AI_PLANES) do
        if IsPointInWater(plane.tr.pos) then
            plane.isAlive = false
            plane.isAlive = false
        end
        if plane.isAlive then
            aiplane_flyto(plane, flightPath[plane.ai.flight.targetPos])
            aiplane_sound(plane)
        end
    end

end



function aiplane_SpawnPlane(tr)

    local entities = Spawn(GetRandomIndexValue(plane_prefabs), tr)

    local id = nil
    for _, entity in ipairs(entities) do
        if GetEntityType(entity) == "vehicle" then
            id = GetTagValue(entity, "Plane_ID")
        end
    end

    aiplane = {}
    aiplane.id = id
    aiplane.ai_plane_set = false

    table.insert(AI_PLANES_NOTSET, aiplane)

    return id

end

function aiplane_BuildAiPlane(plane)

    plane.ai = {
        flight = {
            target_reached_dist = 100,
            targetPos = GetRandomIndex(flightPath)
        },
        sound_distant = GetRandomIndexValue(loops.jets_distant)
    }

    SetBodyVelocity(plane.body, VecScale(DirLookAt(plane.tr.pos, flightPath[plane.ai.flight.targetPos]), 100))

end

-- Assigns the plane the tick after it is spawned.
function aiplane_AssignPlanes()

    local planesToRemove = {}
    for _, aiplane in ipairs(AI_PLANES_NOTSET) do

        if not aiplane.ai_plane_set then -- Only consider aiplanes with no plane object.

            for _, plane in ipairs(PLANES) do

                if aiplane.id == plane.id then

                    print("Found AI plane", plane.id)
                    aiplane.ai_plane_set = true
                    aiplane_BuildAiPlane(plane)

                    if plane.model == "harrier" then
                        plane.vtol.isDown = false
                    end

                    table.insert(AI_PLANES, plane)

                end

            end

        end

    end

end



function aiplane_sound(plane)

    local velVol = CompressRange(plane.totalVel, 0, plane.topSpeed)
    PlayLoop(plane.ai.sound_distant, plane.tr.pos, 1000 * velVol)

end

function aiplane_flyto(plane, pos)

    plane.thrust = 70
    DriveVehicle(plane.vehicle, 0, 0, false)

    local rot = QuatLookAt(plane.tr.pos, pos)

    plane_Steer_Simple(plane, rot, true)

    if VecDist(plane.tr.pos, flightPath[plane.ai.flight.targetPos]) < plane.ai.flight.target_reached_dist then
        aiplane_nextFlightTarget(plane)
    -- else
        -- print("Heading to", plane.ai.flight.targetPos)
    end
    DebugLine(plane.tr.pos, pos, 0,1,0, 1)

end

function aiplane_nextFlightTarget(plane)

    for index, _ in ipairs(flightPath) do
        if plane.ai.flight.targetPos == index then
            plane.ai.flight.targetPos = GetTableNextIndex(flightPath, index)
            break
        end
    end

end



function aiplane_pursue_plane(plane, targetPlane)

    --[[

        Get behind target plane
            Level out
                Shoot
                    Circle back around.

        Check plane angle to target plane and dist
            Calculate shoot transform
        
    ]]

end


function Draw_AiplanesFlightPaths()

    for _, plane in ipairs(AI_PLANES) do
        UiPush()

            UiAlign("center middle")

            UiColor(0,0,0, 0.5)
            if plane.isAlive then
                UiColor(1,0,0, 1)
            end

            if IsInfrontOfTr(GetCameraTransform(), plane.tr.pos) then
                local x,y = UiWorldToPixel(plane.tr.pos)
                UiTranslate(x,y)
                UiImageBox("ui/common/box-outline-6.png", 50,50, 10,10)
                UiTranslate(0, 30)
                UiFont("regular.ttf", 24)
                UiAlign("center top")
                UiText(string.upper(plane.model))
            end

        UiPop()
    end

    for index, pos in ipairs(flightPath) do
        UiPush()

            DrawDot(pos, 30,30, 0,1,0, 1)

            if IsInfrontOfTr(GetCameraTransform(), pos) then

                UiFont("bold.ttf", 24)
                UiAlign("center middle")
                UiTextShadow(0,0,0, 1, 0.2,0.2)
                UiColor(1,1,1, 1)

                local x,y = UiWorldToPixel(pos)
                UiTranslate(x,y)
                UiText(index)

            end

        UiPop()
    end

end