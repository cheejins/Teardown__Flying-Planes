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

            local thrustImpulseAmt = plane.getThrustFac(-plane.thrustImpulseAmount * ((plane.thrustOutput^1.3) / plane.thrust)) * CONFIG.smallMapMode.dragMult
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



    -- Roll
    if InputDown("a") or InputDown("d") then

        local yawSign = 1
        if InputDown("d") then yawSign = -1 end -- Determine yaw direction

        local yawAmt = yawSign * turnAmt * turnDiv / plane.rollVal * 2 * CONFIG.smallMapMode.turnMult

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

    -- Align with crosshair pos
    pTr.rot = MakeQuaternion(QuatCopy(pTr.rot))
    pTr.rot = pTr.rot:Approach(crosshairRot, turnAmt / plane.yawFac * CONFIG.smallMapMode.turnMult)


    SetBodyTransform(plane.body, pTr)

end



--[[Misc]]
function planeSound(plane)

    if plane.engineType == "jet" then
        PlayLoop(sounds.jet_engine_loop, plane.getPos(), plane.engineVol)
        PlayLoop(sounds.jet_engine_loop, GetCameraTransform().pos, 0.1)

    elseif plane.engineType == "propeller" then

        if plane.thrust < 20 then
            PlayLoop(sounds.prop_5, plane.getPos(), plane.engineVol * 2)
            PlayLoop(sounds.prop_5, GetCameraTransform().pos, 0.1)
        elseif plane.thrust < 40 then
            PlayLoop(sounds.prop_4, plane.getPos(), plane.engineVol * 2)
            PlayLoop(sounds.prop_4, GetCameraTransform().pos, 0.1)
        elseif plane.thrust < 60 then
            PlayLoop(sounds.prop_3, plane.getPos(), plane.engineVol * 2)
            PlayLoop(sounds.prop_3, GetCameraTransform().pos, 0.1)
        elseif plane.thrust < 80 then
            PlayLoop(sounds.prop_2, plane.getPos(), plane.engineVol * 2)
            PlayLoop(sounds.prop_2, GetCameraTransform().pos, 0.1)
        elseif plane.thrust <= 100 then
            PlayLoop(sounds.prop_1, plane.getPos(), plane.engineVol * 2)
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

    local v = GetPlayerVehicle()
    local vIsDeadPlane = v ~= 0 and HasTag(v, 'planeVehicle') and GetVehicleHealth(v) <= 0.5

    local respawnValid = vIsDeadPlane or IsPointInWater(GetPlayerTransform().pos)

    if InputPressed(respawnKey) and respawnValid then
        SetPlayerVehicle(0)
        RespawnPlayer()
    end

end
function planeDebug(plane)

    dbw('CAM camPos', camPos)
    dbw('CAM X', plane.camera.cameraX)
    dbw('CAM Y', plane.camera.cameraY)
    dbw('CAM zoom', plane.camera.zoom)

    dbw('PLANE Vel angle', sfn(plane.getForwardVelAngle()))
    dbw('PLANE Speed', sfn(plane.getSpeed()))
    dbw('PLANE Model', plane.model)
    dbw('PLANE Thrust', plane.thrust)

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

        local plTr = plane.getTransform()


        if InputDown('lmb') then

            if plane.model == 'a10' then
                PlayLoop(sounds.emg, GetBodyTransform(plane.body).pos, 10)
            else
                PlayLoop(sounds.mg, GetBodyTransform(plane.body).pos, 10)
            end

            if plane.timers.weap.primary.time <= 0 then

                TimerResetTime(plane.timers.weap.primary)

                for key, weap in pairs(plane.weap.weaponObjects.primary) do

                    local weapTr = GetLightTransform(weap.light)

                    -- Aim adjust. The shoot location is slightly higher than the weapon body.
                    -- Moves the aim pos just above where the crosshair (weapon body aligned) hits the world.
                    local shootTr = TransformCopy(weapTr)
                    -- local shootDir = QuatToDir(shootTr.rot)

                    -- local trueAimRot = QuatLookAt(shootTr.pos, crosshairPos)
                    -- local trueAimDir = QuatToDir(trueAimRot)
                    -- local shootRotAligned =  DirToQuat(Vec(shootDir[1], trueAimDir[2], shootDir[3]))
                    -- shootTr.rot = shootRotAligned

                    local projPreset = ProjectilePresets.bullets.standard
                    if plane.model == 'a10' then
                        projPreset = ProjectilePresets.bullets.emg
                    end


                    -- shootTr.rot = QuatLookAt(plTr.pos, TransformToParentPoint(plTr, Vec(0,0,-200)))
                    -- shootTr.rot = QuatLookAt(weapTr.pos, crosshairPos)



                    -- Shoot projectile.
                    createProjectile(shootTr, Projectiles, projPreset, {plane.body})


                    -- Apply recoil,
                    -- local vel_impulse = VecScale(QuatToDir(weapTr.rot), -4500)
                    -- ApplyBodyImpulse(robot.body, AabbGetBodyCenterPos(robot.body), vel_impulse)

                    -- Shoot particles,
                    -- SpawnParticle_aeon_weap_primary(shootTr)

                    -- Exhaust particles.
                    -- local exhaustTr = TransformCopy(weapTr)
                    -- exhaustTr.pos = TransformToParentPoint(weapTr, Vec(0,0,1.5))
                    -- exhaustTr.rot = QuatTrLookBack(weapTr)

                    -- SpawnParticle_aeon_weap_primary_exhaust(exhaustTr, 0)
                    -- SpawnParticle_aeon_weap_primary_exhaust(exhaustTr, 3)
                    -- SpawnParticle_aeon_weap_primary_exhaust(exhaustTr, 5)

                end

                -- local index = GetRandomIndex(Sounds.weap_primary.shoot)
                -- PlayRandomSound(Sounds.weap_primary.shoot, bodyTr.pos, 2, index)
                -- PlayRandomSound(Sounds.weap_primary.shoot, GetCameraTransform().pos, 0.5, index)

            end

        end


        local planeTr = GetVehicleTransform(plane.vehicle)
        local targetTr = GetVehicleTransform(plane.targetting.target)

        local planeDir = DirLookAt(planeTr.pos, TransformToParentPoint(planeTr, Vec(0,0,-1)))
        local targetDir = DirLookAt(planeTr.pos, targetTr.pos)

        local targetShape = nil
        local ang = VecAngle(planeDir, targetDir)
        if ang < 30 and VecDist(planeTr.pos, targetTr.pos) < 600 then
            targetShape = GetBodyShapes((GetVehicleBody(plane.targetting.target)))[1]
            plane.targetting.lock.locked = true
            beep()
        else
            plane.targetting.lock.locked = false
        end
        dbw('Lock Ang', ang)



        if InputDown('rmb') then

            if plane.timers.weap.secondary.time <= 0 then
                TimerResetTime(plane.timers.weap.secondary)

                if plane.weap.secondary_lastIndex + 1 > #plane.weap.weaponObjects.secondary then
                    plane.weap.secondary_lastIndex = 1
                else
                    plane.weap.secondary_lastIndex = plane.weap.secondary_lastIndex + 1
                end


                local weapTr = GetLightTransform(plane.weap.weaponObjects.secondary[plane.weap.secondary_lastIndex].light)
                local shootTr = TransformCopy(weapTr)
                shootTr.rot = QuatLookAt(plTr.pos, TransformToParentPoint(plTr, Vec(0,0,-300)))



                if plane.model == 'mig29-u' then
                    Spawn("MOD/prefabs/grenade.xml", shootTr)
                else
                    createProjectile(
                        shootTr,
                        Projectiles,
                        ProjectilePresets.missiles.standard,
                        {plane.body},
                        targetShape)
                end


                PlaySound(sounds.missile, shootTr.pos, 10)
                -- PlayRandomSound(Sounds.weap_secondary.shoot, bodyTr.pos)
                -- PlayRandomSound(Sounds.weap_secondary.hit, bodyTr.pos, 0.5)

            end

        end

    end

    TimerRunTime(plane.timers.weap.primary)
    TimerRunTime(plane.timers.weap.secondary)
    -- TimerRunTime(plane.timers.weap.special)

end
