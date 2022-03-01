--[[Plane Physics]]
function planeMove(plane)

    local speed = plane.getSpeed()

    if InputDown("w") and plane.thrust + plane.thrustIncrement <= 101 then
        plane.thrust = plane.thrust + 1
    end
    if InputDown("s") and plane.thrust - plane.thrustIncrement >= 0 then
        plane.thrust = plane.thrust - 1
    end

    if InputDown("space") then
        ApplyBodyImpulse(
            plane.body,
            TransformToParentPoint(
                plane.getTransform(), Vec(0,0,-5)),
            plane.getFwdPos(speed*plane.brakeImpulseAmt))
        plane.status = 'Air Braking'
    end

    -- stall speed
    if speed < plane.topSpeed then

        plane.setThrustOutput()

        local thrustSpeed = plane.thrust/100
        local thrustSpeedMult = plane.getSpeed() < plane.topSpeed * thrustSpeed
        if thrustSpeedMult then

            local thrustImpulseAmt = plane.getThrustFac(-plane.thrustImpulseAmount * ((plane.thrustOutput^1.3) / plane.thrust))
            ApplyBodyImpulse(
                plane.body,
                plane.getPos(),
                plane.getFwdPos(thrustImpulseAmt))
        end

    end

end
function planeSteer(plane)

    local pTr = plane.getTransform()

    local speed = plane.getSpeed()
    local speedClamped = (clamp(speed, 0.01, speed+0.01))

    local divSpeed = speedClamped / plane.topSpeed
    local turnDiv = 50
    local turnAmt = math.abs(getQuadtratic(divSpeed) / turnDiv)

    -- dbw('divSpeed', sfn(divSpeed, 5))
    -- dbw('turnAmt', sfn(turnAmt, 5))

    -- Roll
    if InputDown("a") or InputDown("d") then

        local yawSign = 1
        if InputDown("d") then yawSign = -1 end -- Determine yaw direction

        local yawAmt = yawSign * turnAmt * turnDiv / plane.rollVal * 2

        -- local yawLowerLim = plane.topSpeed/3
        -- local yawUpperLim = plane.topSpeed - (plane.topSpeed/3)
        -- if plane.getSpeed() < yawLowerLim then
        --     yawAmt = yawAmt * (plane.getSpeed()/yawLowerLim)
        -- elseif plane.getSpeed() > plane.topSpeed/5 then
        --     yawAmt = yawAmt * (yawUpperLim/plane.getSpeed())
        -- end

        pTr.rot = QuatRotateQuat(pTr.rot, QuatEuler(0, 0, yawAmt))

    end


    local crosshairRot = QuatLookAt(plane.getTransform().pos, crosshairPos)

    -- Roll plane based on crosshair
    local rollAmt = VecNormalize(TransformToLocalPoint(plane.getTransform(), crosshairPos))
    rollAmt = rollAmt[1] * turnAmt * -350 / plane.rollVal
    pTr.rot = QuatRotateQuat(pTr.rot, QuatEuler(0, 0, rollAmt))
    dbw('rollAmt', sfn(rollAmt, 5))


    -- Align with crosshair pos
    pTr.rot = MakeQuaternion(QuatCopy(pTr.rot))
    pTr.rot = pTr.rot:Approach(crosshairRot, turnAmt / plane.yawFac)


    SetBodyTransform(plane.body, pTr)

end



--[[Misc]]
function planeSound(plane)

    if plane.engineType == "jet" then
        PlayLoop(sounds.jet_engine_loop, plane.getPos())
        PlayLoop(sounds.jet_engine_loop, GetCameraTransform().pos, 0.1)

        -- afterburner volume based on thrust amount.
        if plane.taxiModeEnabled then
            PlayLoop(sounds.jet_engine_afterburner, plane.getPos(), (plane.thrust/100) - 0.5)
        end

    elseif plane.engineType == "propeller" then

        if plane.thrust < 20 then
            PlayLoop(sounds.prop_5, plane.getPos(), plane.engineVol)
            PlayLoop(sounds.prop_5, GetCameraTransform().pos, 0.1)
        elseif plane.thrust < 40 then
            PlayLoop(sounds.prop_4, plane.getPos(), plane.engineVol)
            PlayLoop(sounds.prop_4, GetCameraTransform().pos, 0.1)
        elseif plane.thrust < 60 then
            PlayLoop(sounds.prop_3, plane.getPos(), plane.engineVol)
            PlayLoop(sounds.prop_3, GetCameraTransform().pos, 0.1)
        elseif plane.thrust < 80 then
            PlayLoop(sounds.prop_2, plane.getPos(), plane.engineVol)
            PlayLoop(sounds.prop_2, GetCameraTransform().pos, 0.1)
        elseif plane.thrust <= 100 then
            PlayLoop(sounds.prop_1, plane.getPos(), plane.engineVol)
            PlayLoop(sounds.prop_1, GetCameraTransform().pos, 0.1)
        end

    end
end
function planeStateText(plane)
    plane.status = "-"
    if InputDown("space") then
        -- DebugWatch("Plane: ", "air braking")
        plane.status = "Air-Braking"
    end
end
function planeToggleEngine(plane)
    if InputPressed("v") then
        plane.taxiModeEnabled = not plane.taxiModeEnabled
    end
end
function runEffects(plane)

    for index, exhaust in pairs(plane.exhausts) do

        local tr = GetLightTransform(exhaust)

        local enginePower = plane.getThrustFac()/100 + 0.2

        local rad = 0.5
        local vel = 1.5*enginePower^2
        local alpha = enginePower + 0.1
        local emmissive = enginePower + 2

        exhaust_particle_afterburner(tr, rad, vel, alpha, emmissive)
        for i = 0.2, 1, 0.2 do
            local exhaustTr = TransformCopy(tr)
            exhaustTr.pos = TransformToParentPoint(tr, Vec(0,0,1*i))
            exhaust_particle_afterburner(exhaustTr, rad, vel, alpha, emmissive)
        end

        PointLight(tr.pos, 1,0.5,0, 3 * enginePower * math.random())

    end

end
function handlePlayerInWater()
    if IsPointInWater(GetPlayerPos()) then
        if InputPressed(respawnKey) then
            SetPlayerVehicle(0)
            RespawnPlayer()
        end
    end
end
function planeDebug(plane)

    dbw('CAM camPos', camPos)
    dbw('CAM X', plane.camera.cameraX)
    dbw('CAM Y', plane.camera.cameraY)
    dbw('CAM zoom', plane.camera.zoom)

    dbw('PLANE Vel angle', sfn(plane.getForwardVelAngle()))
    dbw('PLANE Speed', sfn(plane.getSpeed()))
    dbw('PLANE Model', plane.thrust)
    dbw('PLANE Thrust', plane.model)

end




--[[Weapons]]
function planeChangeWeapon(plane)
    if InputPressed("f") then
        PlaySound(sounds.click, GetCameraTransform().pos, 1)
        if plane.weapon ~= plane.weapons[#plane.weapons] then
            -- plane.weapon = plane.weapons[]
        else
            plane.weapon = plane.weapons[1] -- loop to start
        end
    end
end
function planeShoot(plane)

    if plane.isArmed then
        if InputDown("lmb") then
            planeShootBullet(plane)
        end
        if InputDown("rmb") and plane.model ~= "spitfire" and plane.model ~= 'cessna172' then
            planeShootMissile(plane)
        end
    end

    if plane.bullets.timer >= 0 then
        plane.bullets.timer = plane.bullets.timer - GetTimeStep()
    end

    if plane.missiles.timer >= 0 then
        plane.missiles.timer = plane.missiles.timer - GetTimeStep()
    end

end
function planeShootBullet(plane)

    local plTr = GetBodyTransform(plane.body) -- plane transform

    if plane.bullets.timer <= 0 then -- rpm timer
        plane.bullets.timer = 60/plane.bullets.rpm

        local shootTr = TransformCopy(GetBodyTransform(plane.body))
        shootTr.pos = TransformToParentPoint(shootTr, plane.gunPosOffset)

        local spread = 0.02
        shootTr.rot[1] = shootTr.rot[1] + (math.random()-0.5)*spread
        shootTr.rot[2] = shootTr.rot[2] + (math.random()-0.5)*spread
        shootTr.rot[3] = shootTr.rot[3] + (math.random()-0.5)*spread

        createBullet(shootTr, activeBullets, plane.bullets.type, plane.body)

        -- spirfire opposite wing
        if plane.model == "spitfire" or plane.model == 'cessna172' then

            local shootTr2 = GetBodyTransform(plane.body)
            shootTr2.pos = TransformToParentPoint(shootTr2, plane.gunPosOffset2)

            shootTr2.rot[1] = shootTr2.rot[1] + (math.random()-0.5)*spread
            shootTr2.rot[2] = shootTr2.rot[2] + (math.random()-0.5)*spread
            shootTr2.rot[3] = shootTr2.rot[3] + (math.random()-0.5)*spread

            createBullet(shootTr2, activeBullets, plane.bullets.type, plane.body)
        end
    end

    if plane.bullets.type == "mg" then
        PlayLoop(sounds.mg, plTr.pos, 40)
        PlayLoop(sounds.mg, GetPlayerPos(), 0.2)
    elseif plane.bullets.type == "emg" then
        PlayLoop(sounds.emg, plTr.pos, 40)
        PlayLoop(sounds.emg, GetPlayerPos(), 0.2)
    end
end
function planeShootMissile(plane)
    if plane.missiles.timer <= 0 then -- rpm timer
        plane.missiles.timer = 60/plane.missiles.rpm

        local fireVecOffset = nil
        if plane.missiles.firePos == "left" then
            fireVecOffset = Vec(3, -1 ,-1)
            plane.missiles.firePos = "right"
        elseif plane.missiles.firePos == "right" then
            fireVecOffset = Vec(-3, -1, -1)
            plane.missiles.firePos = "left"
        end

        local tr = Transform(
            TransformToParentPoint(plane.getTransform(), fireVecOffset),
            plane.getTransform().rot) -- shoot from below wing

        -- createMissile(tr, enemy_activeMissiles, false)
        if plane.model == 'mig29-u' then
            Spawn("MOD/prefabs/grenade.xml", tr)
        else
            createMissile(tr, activeMissiles, false, nil, plane.body)
        end
        PlaySound(sounds.missile, tr.pos, 5)
        PlaySound(sounds.missile, GetPlayerPos(), 0.1)
    end
end



--[[MISC]]
function myDot(a, b) return (a[1] * b[1]) + (a[2] * b[2]) + (a[3] * b[3]) end
function myMag(a) return math.sqrt((a[1] * a[1]) + (a[2] * a[2]) + (a[3] * a[3])) end
