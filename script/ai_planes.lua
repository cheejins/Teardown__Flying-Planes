AI_PLANES = {}
AI_PLANES_NOTSET = {}


local flightPath = {}
for i = 1, math.random(5,7) do
    table.insert(flightPath, AutoVecSubsituteY(VecRandom(1000), math.random(400,700)))
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


function Tick_aiplanes()

    for index, body in ipairs(FindBodies("", true)) do
        if IsPointInWater(GetBodyTransform(body).pos) then
            SetBodyActive(body, false)
            SetBodyDynamic(body, false)
        end
    end

    local alivePlanes = 1
    for index, plane in ipairs(AI_PLANES) do
        if plane.isAlive then
            alivePlanes = alivePlanes + 1
        end
    end

    for i = alivePlanes, 3 do
        local pos = AutoVecSubsituteY(VecRandom(800), math.random(400,600))
        local tr = Transform(pos)
        aiplane_SpawnPlane(tr)
    end

    -- if InputPressed("f5") then
    --     local pos = Vec(0, 300, 0)
    --     local tr = Transform(pos)
    --     aiplane_SpawnPlane(tr)
    -- end

    for _, plane in ipairs(AI_PLANES) do
        if IsPointInWater(plane.tr.pos) then
            plane.isAlive = false
        end
        if plane.isAlive then
            aiplane_flyto(plane, flightPath[plane.ai.flight.targetPos])
            aiplane_sound(plane)
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


function DrawFlightPaths()

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
            end

        UiPop()
    end

    for _, pos in ipairs(flightPath) do
        DrawDot(pos, 25,25, 0,1,0, 1)
    end

end



function aiplane_nextFlightTarget(plane)

    print("next fucking target")

    for index, _ in ipairs(flightPath) do
        if plane.ai.flight.targetPos == index then
            plane.ai.flight.targetPos = GetTableNextIndex(flightPath, index)
            print("changed to next fucking target")
            break
        end
    end

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

                    table.insert(AI_PLANES, plane)

                end

            end

        end

    end

end


function aiplane_SpawnPlane(tr)

    local planes = {
        "MOD/prefab/Mig29.xml",
        "MOD/prefab/F15.xml",
        "MOD/prefab/A10.xml",
        "MOD/prefab/AC130.xml",
    }

    local entities = Spawn(GetRandomIndexValue(planes), tr)

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