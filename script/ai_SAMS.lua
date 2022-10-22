EnemyAAs = {}
EnemyAAMGs = {}


AA_Types = {
    SAM = { title = "SAM", rpm = 20 },
    MG = { title = "MG", rpm = 1200 },
}


function InitEnemies()

    for _, v in ipairs(FindVehicles("AA", true)) do

<<<<<<< HEAD
        local AA_Type = GetTagValue(v, "AA_Type")

        local AA = {
            vehicle = v,
            body = GetVehicleBody(v),
            type = GetTagValue(v, "AA_Type"),

            timer = TimerCreate(0, AA_Types[AA_Type].rpm),
=======
        local SAM = {
            vehicle = SAM,
            body = GetVehicleBody(SAM),
            timer = TimerCreate(0, 1600),
>>>>>>> 7e5f2714410abadea29ee7d309c01f0a44f63bc4
            pauseTimer = TimerCreate(0, 60/2),
            shootTimer = TimerCreate(0, 60/5),
            shooting = true,

            targetPos = Vec(),
        }

        table.insert(EnemyAAs, AA)
        print("Created AA tank: " .. AA.type)

    end

end


function TickEnemies()

    for index, AA in ipairs(EnemyAAs) do

        if GetVehicleHealth(AA.vehicle) > 0 then

<<<<<<< HEAD
            local proj = DeepCopy(ProjectilePresets.bullets.aa)

            local shootPos = VecAdd(AabbGetBodyCenterTopPos(AA.body), Vec(0,4,0))
=======
            local shootPos = VecAdd(AabbGetBodyCenterTopPos(SAM.body), Vec(0,4,0))


            local proj = DeepCopy(ProjectilePresets.bullets.standard)
            proj.speed = 2.5
            proj.rcRad = 0.2
            proj.holeSize = clamp(math.random(), 0.5, math.random())
            proj.explosionSize = 0.5
>>>>>>> 7e5f2714410abadea29ee7d309c01f0a44f63bc4

            -- Set target
            AA.targetPos = GetPlayerTransform().pos

            -- Target player
            local playerVehicle = GetPlayerVehicle()
            if GetPlayerVehicle() ~= 0 then

                local targetVel = GetBodyVelocity(GetVehicleBody(playerVehicle))
                local targetDist = gtZero(VecDist(AA.targetPos, shootPos))/10
                -- local velScale = 1 / proj.speed * targetDist / 10
<<<<<<< HEAD
                local velScale = proj.speed/targetDist

                AA.targetPos = VecAdd(
                    GetBodyTransform(GetVehicleBody(playerVehicle)).pos,
                    VecScale(targetVel, velScale))
=======
                -- local velScale = targetDist/10*proj.speed/10

                -- SAM.targetPos = VecAdd(
                --     GetBodyTransform(GetVehicleBody(playerVehicle)).pos,
                --     VecScale(targetVel, velScale))

                SAM.targetPos = GetBodyTransform(GetVehicleBody(playerVehicle)).pos
>>>>>>> 7e5f2714410abadea29ee7d309c01f0a44f63bc4

            end


            -- Set up shooting.
            local shootTr = Transform(shootPos, QuatLookAt(shootPos, AA.targetPos))
            shootTr.rot = QuatRotateQuat(
                shootTr.rot,
                QuatEuler(
                    (math.random()+0.5)*12,
                    (math.random()+0.5)*12,
                    (math.random()+0.5)*12
                ))

            -- if AA.type == AA_Types.SAM.title then
            --     shootTr.rot = QuatLookAt()
            -- end


            local targetShape = nil

            if AA.type == AA_Types.MG.title then

                proj.explosionSize = 0.5

            elseif AA.type == AA_Types.SAM.title then

                proj = DeepCopy(ProjectilePresets.missiles.SAM)

                if IsHandleValid(GetPlayerVehicle()) then
                local vehicle = GetPlayerVehicle()
                local body = GetVehicleBody(vehicle)
                local shapes = GetBodyShapes(body)
                local shape = shapes[math.random(1, #shapes)]
                    targetShape = shape
                end

            end



            if AA.shooting then

                -- Shoot
                TimerRunTime(AA.timer)
                if playerVehicle and GetVehicleTransform(playerVehicle).pos[2] > 10 then

                    if TimerConsumed(AA.timer) then
                        TimerResetTime(AA.timer)

                        createProjectile(shootTr, Projectiles, proj, {AA.body}, targetShape)
                        PointLight(shootTr.pos, 1,0.25,1, 3)
                    end

                    PlayLoop(sounds.mg3, shootTr.pos, 100)

                end


                TimerRunTime(AA.shootTimer)
                if TimerConsumed(AA.shootTimer) then
                    TimerResetTime(AA.shootTimer)
                    AA.shootTimer.time = AA.shootTimer.time + ((math.random()-0.5)*1.5)
                    AA.shooting = false
                end

            else

                TimerRunTime(AA.pauseTimer)
                if TimerConsumed(AA.pauseTimer) then
                    TimerResetTime(AA.pauseTimer)
                    AA.pauseTimer.time = AA.pauseTimer.time + ((math.random()-0.5)*1.5)
                    AA.shooting = true
                end

            end

        end

    end

end
