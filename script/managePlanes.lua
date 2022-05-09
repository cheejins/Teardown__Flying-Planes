function initPlanes()

    -- Create objects for each existing plane.
    local planeVehicleList = FindVehicles("planeVehicle", true)
    for key, planeVehicle in pairs(planeVehicleList) do
        local plane = createPlaneObject(planeVehicle)
        table.insert(planeObjectList, plane)
    end

    dbpc(#planeObjectList .. ' planes initialized. ' .. sfnTime())

end

function planesUpdate()

    if curPlane == nil then curPlane = planeObjectList[1] end

    for key, plane in pairs(planeObjectList) do

        if GetPlayerVehicle() == plane.vehicle and plane.checkPlayerInUnbrokenPlane() then

            crosshairPos = getCrosshairWorldPos({plane.body})
            dbdd(crosshairPos, 1,1, 1,0,0, 1)

            if InputPressed(toggleMissileLockKey) then
                beep()
                plane.targetting.lock.enabled = not plane.targetting.lock.enabled
            end

            curPlane = plane
            plane.status = '-'

            if camPos == 'custom' then
                planeSteer(plane)
            end
            planeMove(plane)
            plane.checkIsAlive()
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

    end

end

function planesTick()

    local vehicle = GetPlayerVehicle()
    for key, plane in pairs(planeObjectList) do
        if vehicle == plane.vehicle then
            planeCamera(plane)
            planeChangeCamera()
        end
    end

end
