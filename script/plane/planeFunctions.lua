InputControlIncrement = 0.05
InputControls = {
    w = 0,
    a = 0,
    s = 0,
    d = 0,
    c = 0,
    z = 0,
}

--[[Plane Physics]]
function planeMove(plane)

    local speed = plane.speed

    if InputDown("shift") and plane.thrust + plane.thrustIncrement <= 101 then
        plane.thrust = plane.thrust + 1
    end
    if InputDown("ctrl") and plane.thrust - plane.thrustIncrement >= 0 then
        plane.thrust = plane.thrust - 1
    end

    if InputDown("alt") then
        ApplyBodyImpulse(
            plane.body,
            TransformToParentPoint(
                plane.tr, Vec(0,0,-5)),
            plane.getFwdPos(speed*plane.brakeImpulseAmt))
        plane.status = 'Air Braking'
    end

    -- stall speed
    if speed < plane.topSpeed then

        plane.setThrustOutput()

        local thrustSpeed = plane.thrust/100
        local thrustSpeedMult = plane.speed < plane.topSpeed * thrustSpeed
        if thrustSpeedMult then

            local thrustImpulseAmt = plane.getThrustFac(-plane.thrustImpulseAmount * ((plane.thrustOutput^1.3) / plane.thrust)) / 2
            ApplyBodyImpulse(
                plane.body,
                plane.tr.pos,
                plane.getFwdPos(thrustImpulseAmt))
        end

    end

end
function planeSteer(plane)

    local angDim = plane.speedFac / (plane.topSpeed) * 100 * plane.getForwardVelAngle()

    local imp = 1000 * angDim * GetBodyMass(plane.body)/10000
    dbw("steer angDim", angDim)


    local nose = TransformToParentPoint(plane.tr, Vec(0,0,-10))
    local wing = TransformToParentPoint(plane.tr, Vec(-10,0,0))

    local planeUp = DirLookAt(plane.tr.pos, TransformToParentPoint(plane.tr, Vec(0,10,0)))
    local planeLeft = DirLookAt(plane.tr.pos, TransformToParentPoint(plane.tr, Vec(10,0,0)))

    local ic = InputControls
    local inc = InputControlIncrement


    local w = InputDown("w")
    local s = InputDown("s")
    local a = InputDown("a")
    local d = InputDown("d")
    local z = InputDown("z")
    local c = InputDown("c")


    -- if camPos == "aligned" then

    --     if InputValue("mousedy") > 1 then
    --         s = true
    --         ic.s = InputValue("mousedy")/10
    --     end
    --     if InputValue("mousedy") < -1 then
    --         w = true
    --         ic.w = -InputValue("mousedy")/10
    --     end
    --     if InputValue("mousedx") > 1 then
    --         c = true
    --         ic.c = InputValue("mousedx")/10
    --     end
    --     if InputValue("mousedx") < -1 then
    --         z = true
    --         ic.z = -InputValue("mousedx")/10
    --     end

    -- end


    if w then
        ic.w = clamp(ic.w + inc, 0, 1)
        ApplyBodyImpulse(plane.body, nose, VecScale(planeUp, imp * ic.w))
    else
        ic.w = clamp(ic.w - inc, 0, 1)
    end
    if s then
        ic.s = clamp(ic.s + inc, 0, 1)
        ApplyBodyImpulse(plane.body, nose, VecScale(planeUp, -imp * ic.s))
    else
        ic.s = clamp(ic.s - inc, 0, 1)
    end


    if a then
        ic.a = clamp(ic.a + inc, 0, 1)
        ApplyBodyImpulse(plane.body, wing, VecScale(planeUp, imp/1.5 * ic.a))
    else
        ic.a = clamp(ic.a - inc, 0, 1)
    end
    if d then
        ic.d = clamp(ic.d + inc, 0, 1)
        ApplyBodyImpulse(plane.body, wing, VecScale(planeUp, -imp/1.5 * ic.d))
    else
        ic.d = clamp(ic.d - inc, 0, 1)
    end


    if z then
        ic.z = clamp(ic.z + inc, 0, 1)
        ApplyBodyImpulse(plane.body, nose, VecScale(planeLeft, imp * ic.z))
    else
        ic.z = clamp(ic.z - inc, 0, 1)
    end
    if c then
        ic.c = clamp(ic.c + inc, 0, 1)
        ApplyBodyImpulse(plane.body, nose, VecScale(planeLeft, -imp * ic.c))
    else
        ic.c = clamp(ic.c - inc, 0, 1)
    end

end



--[[Misc]]
function planeSound(plane)

    if plane.engineType == "jet" then
        PlayLoop(sounds.jet_engine_loop, plane.tr.pos, 2)
        PlayLoop(sounds.jet_engine_afterburner, plane.tr.pos, plane.thrust/50)
        PlayLoop(sounds.jet_engine_loop, GetCameraTransform().pos, 0.1)

    elseif plane.engineType == "propeller" then

        if plane.thrust < 20 then
            PlayLoop(sounds.prop_5, plane.tr.pos, plane.engineVol * 3)
            PlayLoop(sounds.prop_5, GetCameraTransform().pos, 0.1)
        elseif plane.thrust < 40 then
            PlayLoop(sounds.prop_4, plane.tr.pos, plane.engineVol * 3)
            PlayLoop(sounds.prop_4, GetCameraTransform().pos, 0.1)
        elseif plane.thrust < 60 then
            PlayLoop(sounds.prop_3, plane.tr.pos, plane.engineVol * 3)
            PlayLoop(sounds.prop_3, GetCameraTransform().pos, 0.1)
        elseif plane.thrust < 80 then
            PlayLoop(sounds.prop_2, plane.tr.pos, plane.engineVol * 3)
            PlayLoop(sounds.prop_2, GetCameraTransform().pos, 0.1)
        elseif plane.thrust <= 100 then
            PlayLoop(sounds.prop_1, plane.tr.pos, plane.engineVol * 3)
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
    -- if InputPressed("v") then
    --     plane.taxiModeEnabled = not plane.taxiModeEnabled
    -- end
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

    dbw('CAM', camPos)
    dbw('PLANE Speed', sfn(plane.speed))
    dbw("PLANE IdealSpeedFactor", plane.getIdealSpeedFactor())
    dbw("PLANE ForwardVelAngle", plane.getForwardVelAngle())
    dbw("PLANE plane.speedFac", plane.speedFac)

end
function planeLandingGear(plane)

    if InputPressed("g") then
        for index, shape in ipairs(FindShapes("gear", true)) do
            Delete(shape)
        end
    end

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

                    local spread = 0.025

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

            local planeDir = DirLookAt(planeTr.pos, TransformToParentPoint(planeTr, Vec(0,0,-1)))
            local targetDir = DirLookAt(planeTr.pos, targetTr.pos)

            local ang = VecAngle(planeDir, targetDir)
            if ang < 30 and VecDist(planeTr.pos, targetTr.pos) < 600 then -- Target in bounds.

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
