enemiesList = {}
function getEnemiesList() return enemiesList end
function getEnemyBodies()
    local enemyBodies = {}
    for i = 1, #enemiesList do
        table.insert(enemyBodies, enemiesList[i].body)
    end
    return enemyBodies
end

enemiesHidden = false
function toggleEnemiesHidden(enemiesList)
    if InputPressed(enemiesKey) then enemiesHidden = not enemiesHidden end
    manageEnemies(enemiesList, enemiesHidden)
end
function getEnemiesHidden() return enemiesHidden end



function initEnemies()
    if scriptValid then
        local enemiesBodyList = FindBodies("enemy_ai", true) -- script instances of enemies.
        enemiesList = createEnemies(enemiesBodyList)
        hintsOff = GetBool("savegame.mod.hintsOff") or false
    end
end


function createEnemy(body, id)
    local enemy = {
        id = id,
        body = body,
        shapes = GetBodyShapes(body),
        type = GetTagValue(body, "enemy_type"),
        name = GetTagValue(body, "enemy_name"),
        bullets = {
            rpm = 800,
            timer = 0,
            shootDist = 500,
            spread = 0.2
        },
        missiles = {
            rpm = 60,
            timer = 0,
        },
        startHealth = GetBodyMass(body),
        startPos = GetBodyTransform(body).pos,
        startTr = GetBodyTransform(body),
        health = GetBodyMass(body),
        isAlive = true,
        justDied = false, -- single frame of death
        isHidden = false,
    }

    enemy.getPos = function()
        return GetBodyTransform(enemy.body).pos
    end

    enemy.getHealth = function ()
        return GetBodyMass(enemy.body)
    end

    enemy.getIsAlive = function ()
        if IsShapeBroken(enemy.shapes[1]) then
            enemy.isAlive = false
            return false
        end
        return true
    end

    enemy.setHidden = function(bool_hide)
        enemy.isHidden = bool_hide
        local tr = enemy.startTr
        if enemy.isHidden then
            SetBodyTransform(enemy.body, Transform(Vec(0,-10000, 0), tr.rot))
        elseif enemy.isHidden == false and enemy.isAlive then
            SetBodyTransform(enemy.body, tr)
        end
    end

    -- enemy.setCore = function ()
    --     for i = 1, #enemy.shapes do
    --         local shape = enemy.shapes[i]
    --         if HasTag(shape, "core") then
    --             enemy.shape_core = shape
    --             DebugPrint("core set")
    --         end
    --     end
    -- end

    enemy.freeze = function ()
        SetBodyVelocity(enemy.body, Vec(0,0,0))
        SetBodyAngularVelocity(enemy.body, Vec(0,0,0))
        SetBodyDynamic(enemy.body, false)
    end

    return enemy
end


--- Returns initialized enemies list.
function createEnemies(enemiesBodiesList)
    local enemiesList = {}
    for i=1, #enemiesBodiesList do
        local enemyBody = enemiesBodiesList[i]
        local enemy = createEnemy(enemyBody, i)
        table.insert(enemiesList, enemy)
        -- DebugPrint("enemy: " .. enemy.name .. ", id: " .. enemy.id)
    end
    return enemiesList
end


--- Manages all enemies per frame.
function manageEnemies(enemiesList, enemiesHidden)

    local plane = getCurrentPlane()
    for i = 1, #enemiesList do

        local enemy = enemiesList[i]
        if enemiesHidden then
            enemy.setHidden(true)
        else
            enemy.setHidden(false)
            if enemy.getIsAlive() then
                if plane.getHealth() > 0 then
                    enemyShoot(enemy)

                    if GetPlayerVehicle() == plane.vehicle then
                        DebugLine(plane.getPos(), enemy.getPos(), 1,0,0)
                    end

                end
            else
                SpawnParticle("darksmoke", VecAdd(enemy.startPos, Vec(0,1,0)), Vec(0,50,0), 6, 1)
                SetBodyTransform(enemy.body, Transform(Vec(0,-5000,0), QuatEuler(0,0,0)))
                SetShapeLocalTransform(enemy.shapes[1], Transform(Vec(0,-5000,0), QuatEuler(0,0,0)))
                enemy.freeze()
            end
        end

    end

    -- debugEnemies(enemiesList)
end


function enemyShoot(enemy)

    -- local plane = getCurrentPlane()
    -- local targetBody = plane.body

    if enemy.name == "frigate" then
        -- createMissile(, activeMissiles, isHoming, homingTargetBody)
    elseif enemy.name == "ptBoat" then
        enemyShootBullets(enemy)
    end

end


function enemyShootBullets(enemy)

    -- local plane = getCurrentPlane()
    -- local pos = enemy.getPos()

    -- -- local fwdPos = plane.getFwdPos(plane.getSpeed())
    -- local velSub = VecNormalize(VecSub(Vec(0,0,0),GetBodyVelocity(plane.body)))
    -- local velTr = Transform(plane.getPos(), velSub)
    -- -- local fwdVel = plane.getSpeed()/plane.getTotalVelocity()
    -- -- DebugLine(plane.getPos(), TransformToParentPoint(velTr, GetBodyVelocity(plane.body)), 1, fwdVel, fwdVel)

    -- if enemy.bullets.timer <= 0 then -- rpm bullets.timer
    --     enemy.bullets.timer = 60/enemy.bullets.rpm

    --     if plane ~= nil then
    --         if VecDist(pos, plane.getPos()) < enemy.bullets.shootDist then

    --             local aboveEnemy = Vec(0,5,0)
    --             -- local d = QuatLookAt(VecAdd(pos, aboveEnemy), TransformToParentPoint(velTr, GetBodyVelocity(plane.body)))

    --             local d = QuatLookAt(VecAdd(pos, aboveEnemy), plane.getFwdPos(-plane.getSpeed()/9))
    --             local spread = enemy.bullets.spread
    --             d[1] = d[1] + (math.random()-0.5)*spread
    --             d[2] = d[2] + (math.random()-0.5)*spread
    --             d[3] = d[3] + (math.random()-0.5)*spread

    --             local shootTr = Transform(VecAdd(pos, aboveEnemy), d)
    --             local activeBullets = getActiveBullets()
    --             local ignoreTags = {"enemy_ptBoat_shape"}
    --             createBullet(shootTr, activeBullets, "mg", ignoreTags)

    --             local sounds = getSounds()
    --             PlaySound(sounds.bullet_mg1, pos, 80)
    --         end
    --     end
    -- end

    -- if enemy.bullets.timer >= 0 then enemy.bullets.timer = enemy.bullets.timer - GetTimeStep() end
end


-- TODO homing missiles
-- function enemyShootMissiles(tr)
-- end

-- function debugEnemies(enemiesList)
--     local plane = getCurrentPlane()
--     for i=1, #enemiesList do
--         local enemy = enemiesList[i]
--         DebugLine(plane.getPos(), enemy.getPos(), 1,0,0)
--     end
-- end


function getNumberOfEnemiesAlive(enemiesList)
    local aliveEnemiesCount = 0
    for i=1, #enemiesList do
        local enemy = enemiesList[i]
        if enemy.isAlive then
            aliveEnemiesCount = aliveEnemiesCount + 1
        end
    end
    return aliveEnemiesCount
end