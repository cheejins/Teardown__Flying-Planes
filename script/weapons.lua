
local sprites = {
    missile = LoadSprite("MOD/script/img/missile1.png"),
    mg = LoadSprite("MOD/script/img/bullet1.png"),
    mg_center = LoadSprite("MOD/script/img/bullet1_center.png"),
    emg = LoadSprite("MOD/script/img/bullet_emg.png")
}

--[[MISSILES]]

function createMissile(_transform, activeMissiles, isHoming, homingTargetBody, ignoreBody)
    --- Instantiates a missile and adds it to the activeMissiles table
    local missile = {
        isActive = true, -- Active when firing, inactive after exploded.
        transform = _transform,
        direction = _transform.rot,

        homing = {
            isHoming = isHoming or false,
            agility = 0.5,
            targetBody = homingTargetBody or nil
        },
        ignoreBody = ignoreBody,

        speed = 2,
        lifeLength = 5,
        hit = false,
        explosionSize = 2.5
    }
    table.insert(activeMissiles, missile)
end
function propelMissile(missile)

    missile.transform.pos = TransformToParentPoint(missile.transform, Vec(0,0,-missile.speed))

    DrawSprite(sprites.missile, Transform(missile.transform.pos, QuatRotateQuat(missile.transform.rot, QuatEuler(90,-90,0))), 2.5, 1, 1, 1, 1, 1)
    DrawSprite(sprites.missile, Transform(missile.transform.pos, QuatRotateQuat(missile.transform.rot, QuatEuler(0,-90,0))), 2.5, 1, 1, 1, 1, 1)
    SpawnParticle("fire", missile.transform.pos, Vec(0,0,0), 1.5, 0.2)
    SpawnParticle("smoke", missile.transform.pos, Vec(0,0,0), 0.8, 4)


    local hit, hitPos = RaycastFromTransform(missile.transform, missile.speed, 0.2)
    if hit then

        missile.hit = true

        Explosion(hitPos, 3)
        SpawnParticle("fire", hitPos, Vec(0,0,0), 6, 1)

    end

    -- hit water
    if IsPointInWater(missile.transform.pos) then
        missile.hit = true
        SpawnParticle("water", missile.transform.pos, Vec(0,0,0), 3, 1)
    end

    if missile.hit then
        missile.isActive = false
    else
        missile.isActive = true
        missile.transform.pos = TransformToParentPoint(missile.transform, Vec(0,-0.01,-missile.speed))
    end

end
function manageActiveMissiles(activeMissiles)
    if #activeMissiles >= 1 then

        local missilesToRemove = {} -- activeMissiles iterations.
        for i = 1, #activeMissiles do

            local missile = activeMissiles[i]
            if missile.isActive and missile.hit == false then

                propelMissile(missile)

                missile.lifeLength = missile.lifeLength - GetTimeStep()
                if missile.lifeLength <= 0 then
                    missile.isActive = false
                end

            elseif missile.isActive == false or missile.hit then -- if missile is inactive.
                table.insert(missilesToRemove, i)
                -- DebugPrint("Insert missile " .. i)
            end
        end

        for i = 1, #missilesToRemove do -- remove missile from active missiles after activeMissiles iterations.
            table.remove(activeMissiles, missilesToRemove[i]) -- remove active missiles
        end

    end
end


--[[BULLETS]]
function createBullet(_transform, activeBullets, type, ignoreBody)
    --- Instantiates a bullet and adds it to the activeBullets table
    local bullet = {
        isActive = true, -- Active when firing, inactive after hit.
        transform = _transform,
        ignoreBody = ignoreBody,
        speed = 12,
        lifeLength = 3,
        hit = false,
        type = type or "mg", -- mg = regular machine gun. emg = explosive machine gun.
        emg = {explosionSize = 1.2}
    }
    table.insert(activeBullets, bullet)
end
function manageActiveBullets(activeBullets)
    if #activeBullets >= 1 then

        local bulletsToRemove = {} -- activeBullets iterations.
        for i = 1, #activeBullets do

            local bullet = activeBullets[i]
            if bullet.isActive and bullet.hit == false then

                propelBullet(bullet)

                bullet.lifeLength = bullet.lifeLength - GetTimeStep()
                if bullet.lifeLength <= 0 then
                    bullet.isActive = false
                end

            elseif bullet.isActive == false or bullet.hit then -- if bullet is inactive.
                table.insert(bulletsToRemove, i)
                -- DebugPrint("Insert bullet " .. i)
            end
        end

        for i = 1, #bulletsToRemove do -- remove bullet from active bullets after activeBullets iterations.
            table.remove(activeBullets, bulletsToRemove[i]) -- remove active bullets
            -- DebugPrint("Removed bullet " .. i)
        end
    end

end
function propelBullet(bullet)

    local sprite = sprites.mg_center
    if bullet.type == "emg" then
        sprite = sprites.emg
    end

    DrawSprite(sprite, Transform(bullet.transform.pos, QuatRotateQuat(bullet.transform.rot, QuatEuler(90,-90,0))), 5, 0.9, 1, 1, 1, 1, true)
    DrawSprite(sprite, Transform(bullet.transform.pos, QuatRotateQuat(bullet.transform.rot, QuatEuler(45,-90,0))), 5, 0.9, 1, 1, 1, 1, true)
    DrawSprite(sprite, Transform(bullet.transform.pos, QuatRotateQuat(bullet.transform.rot, QuatEuler(0,-90,0))), 5, 0.9, 1, 1, 1, 1, true)
    DrawSprite(sprite, Transform(bullet.transform.pos, QuatRotateQuat(bullet.transform.rot, QuatEuler(-45,-90,0))), 5, 0.9, 1, 1, 1, 1, true)

    PointLight(bullet.transform.pos, 1,0.6,1, 1)

    local hit, hitPos = RaycastFromTransform(bullet.transform, bullet.speed, 0.2)
    if hit then

        SpawnParticle("smoke", bullet.transform.pos, Vec(0,0,0), 1.5, 1)
        MakeHole(hitPos, 1, 1, 1)

        if bullet.type == "emg" then
            Explosion(hitPos, bullet.emg.explosionSize)
            SpawnParticle("fire", hitPos, Vec(0,0,0), 6, 1)
        end

        bullet.hit = true

    end

    -- hit water
    if IsPointInWater(bullet.transform.pos) then
        bullet.hit = true
        SpawnParticle("water", bullet.transform.pos, Vec(0,0,0), 3, 1)
    end

    if bullet.hit then
        bullet.isActive = false
    else
        bullet.isActive = true
        bullet.transform.pos = TransformToParentPoint(bullet.transform, Vec(0,-0.01,-bullet.speed))
    end

end


--[[WEAPONS]]
activeMissiles = {}
--- Returns reference to the mod wide activeMissiles table.
function getActiveMissiles()
    return activeMissiles
end
activeBullets = {}
--- Returns reference to the mod wide activeBullets table.
function getActiveBullets()
    return activeBullets
end
