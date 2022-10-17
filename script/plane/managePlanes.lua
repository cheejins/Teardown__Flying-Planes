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

        plane_update(plane)
        plane_ProcessHealth(plane)

        planeMove(plane)
        planeSound(plane)
        runEffects(plane)

        if GetPlayerVehicle() == plane.vehicle then

            planeCamera(plane)

            if plane.isAlive then

                SetPlayerHealth(1)

                crosshairPos = getCrosshairWorldPos({plane.body})
                -- dbdd(crosshairPos, 1,1, 1,0,0, 1)

                if InputPressed(toggleMissileLockKey) then
                    beep()
                    plane.targetting.lock.enabled = not plane.targetting.lock.enabled
                end

                curPlane = plane
                plane.status = '-'

                planeSteer(plane)
                plane.applyForces()


                manageTargetting(plane)

                planeShoot(plane)
                planeLandingGear(plane)

                if GetBool('savegame.mod.debugMode') then
                    planeDebug(plane)
                end

            end

        end

        -- Spawn fire for a specified duration after death is triggered.
        if not plane.isAlive then
            if plane.timeOfDeath + 30 >= GetTime() then

                local amount = 1 - ((GetTime()/(plane.timeOfDeath + 30)))

                local fireRdmVec = VecScale(Vec(math.random()-0.5,math.random()-0.5,math.random()-0.5), math.random(3,6) * amount)
                particle_fire(VecAdd(plane.tr.pos, fireRdmVec), math.random()*4 * amount)

                local damageAlpha = 1 - plane.health
                local rdmSmokeVec = VecScale(Vec(math.random()-0.5,math.random()-0.5,math.random()-0.5), math.random(2,5) * amount)
                particle_blackSmoke(VecAdd(plane.tr.pos, rdmSmokeVec), damageAlpha*2, damageAlpha*2 * amount)

            end
        end

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

function plane_ProcessHealth(plane)

    plane.health = GetVehicleHealth(plane.vehicle)

    if plane.isAlive and plane.health < 0.5 and not plane.justDied then
        plane.justDied = true
        plane.isAlive = false
        plane.timeOfDeath = GetTime()

        PlaySound(sounds.engine_deaths[3], plane.tr.pos, 3)
        PlaySound(sounds.engine_deaths[1], plane.tr.pos, 3)

    else
        plane.isAlive = true
        plane.justDied = false
    end

end
