EnemySAMs = {}
EnemyAAMGs = {}


function InitEnemies()

    for _, SAM in ipairs(FindVehicles("cfg", true)) do

        local SAM = {
            vehicle = SAM,
            body = GetVehicleBody(SAM),
            timer = TimerCreate(0, 500),
            pauseTimer = TimerCreate(0, 60/2),
            shootTimer = TimerCreate(0, 60/2),
            shooting = true,
            targetPos = Vec(),
        }

        table.insert(EnemySAMs, SAM)
        print("Created SAM")

    end

end


function TickEnemies()

    for index, SAM in ipairs(EnemySAMs) do

        if GetVehicleHealth(SAM.vehicle) > 0 then

            -- Set target
            SAM.targetPos = GetPlayerTransform().pos

            -- Target player
            local playerVehicle = GetPlayerVehicle()
            if GetPlayerVehicle() ~= 0 then
                SAM.targetPos = VecAdd(
                    GetVehicleTransform(playerVehicle).pos,
                    VecScale(GetBodyVelocity(GetVehicleBody(playerVehicle)), math.random(5,10)/10 )
                )
            end

            -- Set up shooting.
            local shootPos = VecAdd(AabbGetBodyCenterTopPos(SAM.body), Vec(0,1,0))
            local shootTr = Transform(shootPos, QuatLookAt(shootPos, SAM.targetPos))
            shootTr.rot = QuatRotateQuat(
                shootTr.rot,
                QuatEuler(
                    math.random()-0.5 * 3,
                    math.random()-0.5 * 3,
                    math.random()-0.5 * 3
                ))


            if SAM.shooting then

                -- Shoot
                TimerRunTime(SAM.timer)
                if playerVehicle and GetVehicleTransform(playerVehicle).pos[2] > 10 then

                    if TimerConsumed(SAM.timer) then
                        TimerResetTime(SAM.timer)

                        local proj = DeepCopy(ProjectilePresets.bullets.standard)
                        proj.speed = 2
                        proj.explosionSize = 0

                        createProjectile(shootTr, Projectiles, proj, {SAM.body})
                        PointLight(shootTr.pos, 1,0.25,1, 3)
                    end

                    PlayLoop(sounds.mg3, shootTr.pos, 100)

                end


                TimerRunTime(SAM.shootTimer)
                if TimerConsumed(SAM.shootTimer) then
                    TimerResetTime(SAM.shootTimer)
                    SAM.shootTimer.time = SAM.shootTimer.time + ((math.random()-0.5)*1.5)
                    SAM.shooting = false
                end

            else

                TimerRunTime(SAM.pauseTimer)
                if TimerConsumed(SAM.pauseTimer) then
                    TimerResetTime(SAM.pauseTimer)
                    SAM.pauseTimer.time = SAM.pauseTimer.time + ((math.random()-0.5)*1.5)
                    SAM.shooting = true
                end

            end

        end

    end

end
