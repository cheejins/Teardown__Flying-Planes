FlightModes = {
    simple = "simple",
    simulation = "simulation",
}

InputControlIncrement = 0.05 -- Controls gradual steering impulse change.
InputControls = { w = 0, a = 0, s = 0, d = 0, c = 0, z = 0, }



--PLANE

    function plane_UpdateProperties(plane)

        plane.isValid = plane_isValid(plane)

        plane.tr = GetBodyTransform(plane.body)

        -- Velocity
        plane.vel = GetBodyVelocity(plane.body)
        plane.lvel = TransformToLocalVec(plane.tr, plane.vel)
        plane.speed = plane.lvel[3] * -1
        plane.angVel = GetBodyAngularVelocity(plane.body)
        plane.totalVel = math.abs(plane.vel[1]) + math.abs(plane.vel[2]) + math.abs(plane.vel[3])


        plane.playerInPlane = GetPlayerVehicle() == plane.vehicle
        plane.playerInUnbrokenPlane = plane.playerInPlane and plane.isAlive


        plane.forces = plane.forces or Vec(0,0,0)
        plane.speedFac = clamp(plane.speed, 1, plane.speed) / plane.topSpeed

        plane.idealSpeedFactor = clamp(math.sin(math.pi * (plane.speed / plane.topSpeed)), 0, 1)
        plane.liftSpeedFac = plane_getLiftSpeedFac(plane)

        plane.status = ''

    end

    --- Accelerates towards the set thrust (simulates gradual engine wind up/down)
    function plane_SetThrustOutput(plane)
        if plane.thrustOutput <= plane.thrust - 1 then
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

        plane.health = clamp(CompressRange(GetVehicleHealth(plane.vehicle), PLANE_DEAD_HEALTH, 1), 0, 1)

        if plane.isAlive and (plane.health <= 0 or IsPointInWater(plane.tr.pos)) and not plane.justDied then

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

    function plane_Input(plane)

        if GetPlayerVehicle() == plane.vehicle then

            if InputPressed("v") then
                plane.engineOn = not plane.engineOn
            end

            if InputPressed("f") then
                plane.flaps = not plane.flaps
            end

            if InputPressed(Config.toggleHoming) then
                plane.targetting.lock.enabled = not plane.targetting.lock.enabled
                beep()
            end


            if plane.isAlive then

                if InputPressed("g") then
                    plane.landing_gear.startTransition = true
                    plane.landing_gear.isDown = not plane.landing_gear.isDown
                    beep()
                end

            end


            if Config.debug then

                if InputPressed("f1") then
                    SetBodyVelocity(plane.body, Vec(0, 0, -100))
                    SetBodyTransform(plane.body, Transform(Vec(0, 300, 0)))
                    SetBodyAngularVelocity(plane.body, Vec(0, 0, 0))
                end

                if InputPressed("f2") then
                    SetBodyDynamic(plane.body, not IsBodyDynamic(plane.body))
                end

                if InputDown("f3") then
                    SetBodyTransform(plane.body, TransformAdd(plane.tr, Transform(Vec(0, 3, 0))))
                    SetBodyVelocity(plane.vel, Vec(0, 0, 0))
                end

                if InputDown("f4") then
                    SetBodyTransform(plane.body, Transform(plane.tr.pos, Quat()))
                    SetBodyAngularVelocity(plane.body, Vec())
                end

            end

        end


    end

    function plane_SetMinAltitude(plane)
        -- Lowest point ooint of the plane (light entity on the wheel)
        for index, light in ipairs(FindLights('ground', true)) do
            if GetBodyVehicle(GetShapeBody(GetLightShape(light))) == plane.vehicle then
                plane.groundDist = VecSub(
                    GetLightTransform(light).pos,
                    plane.tr.pos)[2]
                break
            end
        end
    end



--Effects

    function plane_Sound(plane)

        PlayLoop(sounds.fire_large, plane.tr.pos, 1 - plane.health + 0.25)

        if not plane.isAlive or not plane.engineOn then
            return
        end

        if plane.engineType == "jet" then

            if plane.model == "a10" or plane.model == "f15" then
                PlayLoop(sounds.jet_engine_loop_mig29, plane.tr.pos, 1.5)
                PlayLoop(sounds.jet_engine_afterburner, plane.tr.pos, plane.thrust / 60)
            else
                PlayLoop(sounds.jet_engine_loop, plane.tr.pos, 1.5)
                PlayLoop(sounds.jet_engine_afterburner, plane.tr.pos, plane.thrust / 60)
            end

        elseif plane.engineType == "propeller" then

            if plane.thrust < 20 then
                PlayLoop(sounds.prop_5, plane.tr.pos, plane.engineVol * 2)
            elseif plane.thrust < 40 then
                PlayLoop(sounds.prop_4, plane.tr.pos, plane.engineVol * 2)
            elseif plane.thrust < 60 then
                PlayLoop(sounds.prop_2, plane.tr.pos, plane.engineVol * 2)
            elseif plane.thrust < 80 then
                PlayLoop(sounds.prop_2, plane.tr.pos, plane.engineVol * 2)
            elseif plane.thrust <= 100 then
                PlayLoop(sounds.prop_1, plane.tr.pos, plane.engineVol * 2)
            end

        end

    end

    function plane_VisualEffects(plane)

        for index, exhaust in pairs(plane.exhausts) do

            local tr = GetLightTransform(exhaust)

            local enginePower = plane.thrust / 100 + 0.2
            local damageAlpha = 0.8 - plane.health

            local rdmSmokeVec = VecScale(Vec(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5), math.random(2, 5))
            particle_blackSmoke(VecAdd(plane.tr.pos, rdmSmokeVec), damageAlpha * 2, damageAlpha * 2)


            if plane.engineOn then

                local rad = 0.5 - damageAlpha
                local vel = 1.5 * enginePower ^ 2
                local alpha = enginePower + 0.1
                local emmissive = enginePower + 2

                exhaust_particle_afterburner(tr, rad, vel, alpha, emmissive)
                for i = 0.2, 1, 0.2 do
                    local exhaustTr = TransformCopy(tr)
                    exhaustTr.pos = TransformToParentPoint(tr, Vec(0, 0, 1 * i))
                    exhaust_particle_afterburner(exhaustTr, rad, vel, alpha, emmissive)
                end
                PointLight(tr.pos, 1, 0.5, 0, 3 * enginePower * math.random())

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


                local amount = 1 - ((GetTime() / (endPlaneDeathTime)))

                local fireRdmVec = VecScale(Vec(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5),
                    math.random(5, 7) * amount)
                particle_fire(VecAdd(plane.tr.pos, fireRdmVec), math.random() * 4 * amount)

                local damageAlpha = 1 - plane.health
                local rdmSmokeVec = VecScale(Vec(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5),
                    math.random(2, 5) * amount)
                particle_blackSmoke(VecAdd(plane.tr.pos, rdmSmokeVec), damageAlpha * 2, damageAlpha * 2 * amount)

            end
        end

    end


--MISC

    function plane_StateText(plane)
        plane.status = "-"
        if InputDown("space") then
            plane.status = "Air-Braking"
        end
    end

    function plane_CameraAimGroundSteering(plane)

        local vTr = GetVehicleTransform(plane.tr)
        local camFwd = TransformToParentPoint(GetCameraTransform(), Vec(0, 0, -1))

        local pos = TransformToLocalPoint(vTr, camFwd)
        local steer = pos[1] / 10

        DriveVehicle(v, 0, steer, false)

    end

    function plane_GetFwdPos(plane, distance)
        return TransformToParentPoint(GetBodyTransform(plane.body), Vec(0, 0, distance or -500))
    end

    function plane_isValid(plane) return IsHandleValid(plane.body) and IsHandleValid(plane.vehicle) end

    function plane_Delete(plane)
        plane.isValid = false
        for _, body in ipairs(plane.AllBodies) do
            Delete(body)
        end
    end

    function VehicleIsPlane(vehicle) return PLANES_VEHICLES[vehicle] ~= nil end
    function VehicleIsAlivePlane(vehicle) return VehicleIsPlane(vehicle) and GetVehicleHealth(vehicle) >= PLANE_DEAD_HEALTH end

    function IsSimulationFlight() return FlightMode == FlightModes.simulation end
    function IsSimpleFlight() return FlightMode == FlightModes.simple end

    function Manage_SmallMapMode()

        local smm = Config.smallMapMode

        CONFIG = {
            smallMapMode = {
                turnMult = Ternary(smm, 1,   1),
                liftMult = Ternary(smm, 0.1, 1),
                dragMult = Ternary(smm, 2,   1),
            }
        }

    end


--Weapons

    function plane_ManageShooting(plane)

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
                        createProjectile(shootTr, Projectiles, projPreset, { plane.body })



                        ParticleReset()
                        ParticleType("smoke")
                        ParticleRadius(1 / 2, math.random() + 2)
                        ParticleAlpha(0.5, 0)
                        ParticleColor(0.5, 0.5, 0.5, 0.9, 0.9, 0.9)
                        ParticleCollide(1)
                        local vel = QuatToDir(shootTr.rot)
                        SpawnParticle(shootTr.pos, vel, 3)

                        PointLight(shootTr.pos, 1, 0.5, 0, 1)

                    end

                end

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
                    shootTr.rot = QuatLookAt(plTr.pos, TransformToParentPoint(plTr, Vec(0, 0, -300)))


                    if plane.model == 'mig29-u' then
                        Spawn("MOD/prefabs/grenade.xml", shootTr)
                    else
                        createProjectile(
                            shootTr,
                            Projectiles,
                            ProjectilePresets.missiles.standard,
                            { plane.body },
                            plane.targetting.targetShape)
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

                    local hit, pos, dist = RaycastFromTransform(tr, nil, nil, { plane.body })
                    if hit and dist > 6 then

                        DrawDot(pos, 2, 2, 0, 1, 0, 0.5)

                        local planeLineTr = Transform(pos, QuatLookAt(Vec(), AutoVecSubsituteY(plane.vel, 0)))

                        DebugLine(planeLineTr.pos, TransformToParentPoint(planeLineTr, Vec(0, 0, -300)), 0, 1, 0, 0.5)

                    end


                end

                if InputDown('rmb') then

                    if plane.timers.weap.special.time <= 0 then

                        TimerResetTime(plane.timers.weap.special)

                        for key, weap in pairs(plane.weap.weaponObjects.special) do

                            local tr = GetLightTransform(weap.light)
                            local bombTr = Transform(tr.pos, QuatLookDown(tr.pos))

                            createProjectile(bombTr, Projectiles, ProjectilePresets.bombs.standard, { plane.body })

                        end

                    end

                end

            end

        end

        TimerRunTime(plane.timers.weap.primary)
        TimerRunTime(plane.timers.weap.secondary)
        TimerRunTime(plane.timers.weap.special)

    end
    -- function plane_ChangeWeapon(plane)
    --     -- if InputPressed("f") then
    --     --     PlaySound(sounds.click, GetCameraTransform().pos, 1)
    --     --     if plane.weapon ~= plane.weapons[#plane.weapons] then
    --     --         -- plane.weapon = plane.weapons[]
    --     --     else
    --     --         plane.weapon = plane.weapons[1] -- loop to start
    --     --     end
    --     -- end
    -- end


--DEBUG

    function plane_Debug(plane)

    end
