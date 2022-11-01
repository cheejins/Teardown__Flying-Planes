#include "../TDSU/tdsu.lua"

EnemyAAs = {}
EnemyAAMGs = {}


AA_Types = {
    SAM = { title = "SAM", rpm = 20 },
    MG = { title = "MG", rpm = 800 },
}


function Init_Enemies()

    Init_Utils()


    for _, v in ipairs(FindVehicles("AA", true)) do

        local AA_Type = GetTagValue(v, "AA_Type")

        local AA = {
            vehicle = v,
            body = GetVehicleBody(v),
            type = GetTagValue(v, "AA_Type"),

            timer = TimerCreateRPM(0, AA_Types[AA_Type].rpm),
            pauseTimer = TimerCreateRPM(0, 60/2),
            shootTimer = TimerCreateRPM(0, 60/5),
            shooting = true,

            targetPos = Vec(),
        }

        table.insert(EnemyAAs, AA)
        print("Created AA tank: " .. AA.type)

    end

end


function Manage_Enemies()

    Tick_Utils()

    if GetBool("level.enemies_disabled") then
        return
    end

    for index, AA in ipairs(EnemyAAs) do

        if GetVehicleHealth(AA.vehicle) > 0 then

            local proj = DeepCopy(ProjectilePresets.bullets.aa)

            local shootPos = VecAdd(AabbGetBodyCenterTopPos(AA.body), Vec(0,4,0))

            -- Set target
            AA.targetPos = GetPlayerTransform().pos

            -- Target player
            local playerVehicle = GetPlayerVehicle()
            if GetPlayerVehicle() ~= 0 then

                local targetVel = GetBodyVelocity(GetVehicleBody(playerVehicle))
                local targetDist = GTZero(VecDist(AA.targetPos, shootPos))/10
                -- local velScale = 1 / proj.speed * targetDist / 10
                local velScale = proj.speed/targetDist

                AA.targetPos = VecAdd(
                    GetBodyTransform(GetVehicleBody(playerVehicle)).pos,
                    VecScale(targetVel, velScale))

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
                if playerVehicle and GetVehicleTransform(playerVehicle).pos[2] > 25 then

                    if TimerConsumed(AA.timer) then
                        TimerResetTime(AA.timer)

                        if AA.type == AA_Types.SAM.title then
                            AA.timer.time = AA.timer.time * (math.random() + 1) -- offset timer.
                            PlaySound(sounds.missile, shootTr.pos, 100)
                        end

                        Projectiles_CreateProjectile(shootTr, Projectiles, proj, {AA.body}, targetShape)
                        PointLight(shootTr.pos, 1,0.25,1, 3)

                    end


                    if AA.type == AA_Types.MG.title then
                        PlayLoop(sounds.mg3, shootTr.pos, 100)
                    end


                end


                TimerRunTime(AA.shootTimer)
                if TimerConsumed(AA.shootTimer) then
                    TimerResetTime(AA.shootTimer)
                    AA.shootTimer.time = AA.shootTimer.time + ((math.random()-0.5)*2)
                    AA.shooting = false
                end

            else

                TimerRunTime(AA.pauseTimer)
                if TimerConsumed(AA.pauseTimer) then
                    TimerResetTime(AA.pauseTimer)
                    AA.pauseTimer.time = AA.pauseTimer.time + ((math.random()-0.5)*2)
                    AA.shooting = true
                end

            end

        end

    end

end
