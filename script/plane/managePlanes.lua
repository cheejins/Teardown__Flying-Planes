function initPlanes()

    -- Create objects for each existing plane.
    local planeVehicleList = FindVehicles("planeVehicle", true)
    for key, planeVehicle in pairs(planeVehicleList) do
        local plane = createPlaneObject(planeVehicle)
        plane_update(plane)
        table.insert(planeObjectList, plane)
    end

    dbpc(#planeObjectList .. ' planes initialized. ' .. sfnTime())

end

function planesUpdate()

    -- if curPlane == nil then curPlane = planeObjectList[1] end

    for key, plane in pairs(planeObjectList) do

        if GetPlayerVehicle() == plane.vehicle  then
        -- if GetPlayerVehicle() == plane.vehicle and plane.playerInUnbrokenPlane then

            print(plane.model)


            planeCamera(plane)
            plane_update(plane)

            crosshairPos = getCrosshairWorldPos({plane.body})
            dbdd(crosshairPos, 1,1, 1,0,0, 1)

            if InputPressed(toggleMissileLockKey) then
                beep()
                plane.targetting.lock.enabled = not plane.targetting.lock.enabled
            end

            curPlane = plane
            plane.status = '-'

            if camPos ~= 'vehicle' then
                planeSteer(plane)
            end
            planeMove(plane)
            plane.applyForces()

            manageTargetting(plane)

            planeShoot(plane)
            planeSound(plane)
            runEffects(plane)

            if GetBool('savegame.mod.debugMode') then
                planeDebug(plane)
            end

        else
            plane.respawnPlayer()
        end


        -- -- Spawn fire for a specified duration after death is triggered.
        -- if GetVehicleHealth(plane.vehicle) < 0.5 then
        --     if plane.isAlive then

        --         plane.isAlive = false
        --         plane.timeOfDeath = GetTime()

        --     end

        --     if plane.timeOfDeath + 30 > GetTime() then

        --         local bodyPos = plane.tr.pos
        --         particle_fire(bodyPos, math.random()*3)
        --         particle_blackSmoke(VecAdd(bodyPos, Vec(0,1,0)), math.random()*6)

        --     end
        -- end

    end

end

function planesTick()

    local vehicle = GetPlayerVehicle()
    for key, plane in pairs(planeObjectList) do
        if vehicle == plane.vehicle then
            planeChangeCamera()

            if camPos ~= camPositions[2] then
                -- AimSteerVehicle(plane.vehicle)
            end

        end
    end

end
