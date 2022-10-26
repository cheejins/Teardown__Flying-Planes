InputControlIncrement = 0.05
InputControls = {
    w = 0,
    a = 0,
    s = 0,
    d = 0,
    c = 0,
    z = 0,
}


--[[DEBUG]]
function plane_Debug(plane)
    dbw('plane.speed', sfn(plane.speed))
    dbw("plane.idealSpeedFactor", sfn(plane.idealSpeedFactor))
    dbw("plane.speedFac", sfn(plane.speedFac))
end



--[[Effects]]
function plane_Sound(plane)

    PlayLoop(sounds.fire_large, plane.tr.pos, 1 - plane.health + 0.25)


    if not plane.isAlive or not plane.engineOn then
        return
    end

    if plane.engineType == "jet" then

        PlayLoop(sounds.jet_engine_loop, plane.tr.pos, 2)
        PlayLoop(sounds.jet_engine_afterburner, plane.tr.pos, plane.thrust/50)

    elseif plane.engineType == "propeller" then

        if plane.thrust < 20 then
            PlayLoop(sounds.prop_5, plane.tr.pos, plane.engineVol * 3)
        elseif plane.thrust < 40 then
            PlayLoop(sounds.prop_4, plane.tr.pos, plane.engineVol * 3)
        elseif plane.thrust < 60 then
            PlayLoop(sounds.prop_3, plane.tr.pos, plane.engineVol * 3)
        elseif plane.thrust < 80 then
            PlayLoop(sounds.prop_2, plane.tr.pos, plane.engineVol * 3)
        elseif plane.thrust <= 100 then
            PlayLoop(sounds.prop_1, plane.tr.pos, plane.engineVol * 3)
        end

    end

end
function plane_VisualEffects(plane)

    for index, exhaust in pairs(plane.exhausts) do

        local tr = GetLightTransform(exhaust)

        local enginePower = plane.thrust/100 + 0.2
        local damageAlpha = 0.8 - plane.health

        local rdmSmokeVec = VecScale(Vec(math.random()-0.5,math.random()-0.5,math.random()-0.5), math.random(2,5))
        particle_blackSmoke(VecAdd(plane.tr.pos, rdmSmokeVec), damageAlpha*2, damageAlpha*2)


        if plane.engineOn then

            local rad = 0.5 - damageAlpha
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


    -- Spawn fire for a specified duration after death is triggered.
    if not plane.isAlive then

        local endPlaneDeathTime = plane.timeOfDeath + 20

        if endPlaneDeathTime >= GetTime() then

            local fireVolumeScale = 10

            local fireLarge = clamp(((endPlaneDeathTime - GetTime()) / endPlaneDeathTime), 0, 1)
            local fireSmall = clamp(1 - fireLarge, 0, 1)

            PlayLoop(sounds.fire_small, plane.tr.pos, fireSmall * fireVolumeScale)
            PlayLoop(sounds.fire_large, plane.tr.pos, fireLarge * fireVolumeScale)


            local amount = 1 - ((GetTime()/(endPlaneDeathTime)))

            local fireRdmVec = VecScale(Vec(math.random()-0.5,math.random()-0.5,math.random()-0.5), math.random(5,7) * amount)
            particle_fire(VecAdd(plane.tr.pos, fireRdmVec), math.random()*4 * amount)

            local damageAlpha = 1 - plane.health
            local rdmSmokeVec = VecScale(Vec(math.random()-0.5,math.random()-0.5,math.random()-0.5), math.random(2,5) * amount)
            particle_blackSmoke(VecAdd(plane.tr.pos, rdmSmokeVec), damageAlpha*2, damageAlpha*2 * amount)

        end
    end

end



--[[PLANE SYSTEMS]]
--- Accelerates towards the set thrust (simulates gradual engine wind up/down)
function plane_SetThrustOutput(plane)
    if plane.thrustOutput <= plane.thrust -1 then
        plane.thrustOutput = plane.thrustOutput + plane.thrustAcc
    elseif plane.thrustOutput >= plane.thrust + 1 then
        plane.thrustOutput = plane.thrustOutput - plane.thrustDecc
    end
end
--- Sets thrust between 0 and 1
function plane_SetThrust(sign)
    plane.thrust = plane.thrust + plane.thrustIncrement * sign
end
function plane_ProcessHealth(plane)

    plane.health = clamp(CompressRange(GetVehicleHealth(plane.vehicle), 0.5, 1), 0, 1)

    if plane.isAlive and plane.health <= 0 and not plane.justDied then

        plane.justDied = true
        plane.isAlive = false
        plane.timeOfDeath = GetTime()

        PlaySound(sounds.engine_deaths[3], plane.tr.pos, 3)
        PlaySound(sounds.engine_deaths[1], plane.tr.pos, 3)
        Explosion(plane.tr.pos, 1)

    else
        plane.isAlive = true
        plane.justDied = false
    end

end
function plane_ToggleEngine(plane)
end
function plane_LandingGear(plane)

    if InputPressed("g") then
        for index, shape in ipairs(FindShapes("gear", true)) do
            Delete(shape)
        end
    end

end
function plane_RunPropellers()
    local propellers = FindJoints('planePropeller', true)
    for key, propeller in pairs(propellers) do
        SetJointMotor(propeller, 15)
    end
end



--[[MISC]]
function plane_StateText(plane)
    plane.status = "-"
    if InputDown("space") then
        plane.status = "Air-Braking"
    end
end
function plane_CameraAimGroundSteering(plane)

    local vTr = GetVehicleTransform(plane.tr)
    local camFwd = TransformToParentPoint(GetCameraTransform(), Vec(0,0,-1))

    local pos = TransformToLocalPoint(vTr, camFwd)
    local steer = pos[1] / 10

    DriveVehicle(v, 0, steer, false)

end
function plane_GetFwdPos(plane, distance)
    return TransformToParentPoint(GetBodyTransform(plane.body), Vec(0,0,distance or -500))
end



--[[Weapons]]
function plane_ChangeWeapon(plane)
    -- if InputPressed("f") then
    --     PlaySound(sounds.click, GetCameraTransform().pos, 1)
    --     if plane.weapon ~= plane.weapons[#plane.weapons] then
    --         -- plane.weapon = plane.weapons[]
    --     else
    --         plane.weapon = plane.weapons[1] -- loop to start
    --     end
    -- end
end
function plane_Shoot(plane)

    if plane.isArmed then

        local plTr = plane.tr


        if InputDown('lmb') and #plane.weap.weaponObjects.primary >= 1 then

            if plane.model == 'a10' then
                PlayLoop(sounds.emg, GetBodyTransform(plane.body).pos, 10)
                plane.timers.weap.primary.rpm = 600
            elseif plane.model == "spitfire" then
                PlayLoop(sounds.mg2, GetBodyTransform(plane.body).pos, 10)
                plane.timers.weap.primary.rpm = 900
            else
                PlayLoop(sounds.mg, GetBodyTransform(plane.body).pos, 10)
                plane.timers.weap.primary.rpm = 1200
            end

            if plane.timers.weap.primary.time <= 0 then

                TimerResetTime(plane.timers.weap.primary)

                for key, weap in pairs(plane.weap.weaponObjects.primary) do

                    local weapTr = GetLightTransform(weap.light)

                    -- Aim adjust. The shoot location is slightly higher than the weapon body.
                    -- Moves the aim pos just above where the crosshair (weapon body aligned) hits the world.
                    local shootTr = TransformCopy(weapTr)


                    local projPreset = ProjectilePresets.bullets.standard
                    if plane.model == 'a10' then
                        projPreset = ProjectilePresets.bullets.emg
                    end

                    local spread = projPreset.spread

                    shootTr.rot = QuatRotateQuat(shootTr.rot, QuatEuler(
                        math.deg((math.random() - 0.5) * spread),
                        math.deg((math.random() - 0.5) * spread),
                        math.deg((math.random() - 0.5) * spread)))

                    -- Shoot projectile.
                    createProjectile(shootTr, Projectiles, projPreset, {plane.body})



                    ParticleReset()
                    ParticleType("smoke")
                    ParticleRadius(1/2, math.random() + 2)
                    ParticleAlpha(0.5, 0)
                    ParticleColor(0.5, 0.5, 0.5, 0.9, 0.9, 0.9)
                    ParticleCollide(1)
                    local vel = QuatToDir(shootTr.rot)
                    SpawnParticle(shootTr.pos, vel, 3)

                    PointLight(shootTr.pos, 1, 0.5, 0, 1)

                end

            end

        end


        local targetShape = nil
        if plane.targetting.lock.enabled then

            local planeTr = GetVehicleTransform(plane.vehicle)
            local targetTr = GetVehicleTransform(plane.targetting.target)

            local planeRot = QuatCopy(planeTr.rot)
            local targetDir = QuatLookAt(planeTr.pos, targetTr.pos)

            local ang = QuatAngle(planeRot, targetDir)
            if ang < 30 and VecDist(planeTr.pos, targetTr.pos) < 800 then -- Target in bounds.

                if plane.targetting.lock.timer.time <= 0 then -- Target locked.
                    plane.targetting.lock.locked = true
                    plane.targetting.lock.locking = false
                    targetShape = GetBodyShapes((GetVehicleBody(plane.targetting.target)))[1]
                else
                    plane.targetting.lock.locking = true -- Target still locking.
                    TimerRunTime(plane.targetting.lock.timer)
                end

            else

                TimerResetTime(plane.targetting.lock.timer)

                plane.targetting.lock.locking = false
                plane.targetting.lock.locked = false

            end
            dbw('Target timer', plane.targetting.lock.timer.time)
        else
            plane.targetting.lock.locked = false
            plane.targetting.lock.locking = false
        end



        if InputDown('rmb') and #plane.weap.weaponObjects.secondary >= 1 then

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

        if #plane.weap.weaponObjects.special >= 1 then

            for key, weap in pairs(plane.weap.weaponObjects.special) do

                local tr = GetLightTransform(weap.light)
                tr.rot = QuatLookDown(tr.pos)

                local hit, pos, dist = RaycastFromTransform(tr, nil, nil, {plane.body})
                if hit and dist > 6 then

                    DrawDot(pos, 2,2, 0,1,0,0.5)

                    local planeLineTr = Transform(pos, QuatLookAt(Vec(), AutoVecSubsituteY(plane.vel, 0)))

                    DebugLine(planeLineTr.pos, TransformToParentPoint(planeLineTr, Vec(0,0,-300)), 0,1,0, 0.5)

                end


            end

            if InputDown('rmb') then

                if plane.timers.weap.special.time <= 0 then

                    TimerResetTime(plane.timers.weap.special)

                    for key, weap in pairs(plane.weap.weaponObjects.special) do

                        local tr = GetLightTransform(weap.light)
                        local bombTr = Transform(tr.pos, QuatLookDown(tr.pos))

                        createProjectile(bombTr, Projectiles, ProjectilePresets.bombs.standard, {plane.body})

                    end

                end

            end

        end

    end

    TimerRunTime(plane.timers.weap.primary)
    TimerRunTime(plane.timers.weap.secondary)
    TimerRunTime(plane.timers.weap.special)

end
