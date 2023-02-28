Projectiles = {}


function Init_Projectiles()

    ProjectilePresets = {

        bullets = {

            aa = {

                isActive = true, -- Active when firing, inactive after hit.
                hit = false,
                hitInitial = false,
                lifeLength = 3, --Seconds

                category = 'bullet',

                speed = 5,
                spread = 0.05,
                drop = 0,
                dropIncrement = 0,
                explosionSize = 0.5,
                rcRad = 0,
                force = 1,
                penetrate = false,
                holeSize = 0.3,

                effects = {
                    -- particle = 'aeon_secondary',
                    color = Vec(1,0.5,0.3),
                    sprite = 'MOD/img/bullet1.png',
                    sprite_dimensions = {7, 1},
                    sprite_facePlayer = false,
                },

                sounds = {
                    -- hit = Sounds.weap_secondary.hit,
                    hit_vol = 5,
                },

                homing = {
                    force = 0,
                    gain = 0,
                    max = 0,
                    targetShape = nil,
                    targetPos = Vec(),
                    targetPosRadius = 0,
                }
            },

            standard = {

                isActive = true, -- Active when firing, inactive after hit.
                hit = false,
                hitInitial = false,
                lifeLength = 3, --Seconds

                category = 'bullet',

                speed = 14,
                spread = 0.015,
                drop = 0,
                dropIncrement = 0,
                explosionSize = 0.75,
                rcRad = 0,
                force = 0,
                penetrate = false,
                holeSize = 0.2,

                effects = {
                    -- particle = 'aeon_secondary',
                    color = Vec(1,0.5,0.3),
                    sprite = 'MOD/img/bullet1.png',
                    sprite_dimensions = {7, 1},
                    sprite_facePlayer = false,
                },

                sounds = {
                    -- hit = Sounds.weap_secondary.hit,
                    hit_vol = 5,
                },

                homing = {
                    force = 0,
                    gain = 0,
                    max = 0,
                    targetShape = nil,
                    targetPos = Vec(),
                    targetPosRadius = 0,
                }
            },

            emg = {

                isActive = true, -- Active when firing, inactive after hit.
                hit = false,
                hitInitial = false,
                lifeLength = 5, --Seconds

                category = 'bullet',

                speed = 6,
                spread = 0.025,
                drop = 0,
                dropIncrement = 0,
                explosionSize = 3.2,
                rcRad = 0,
                force = 0,
                penetrate = false,
                holeSize = 1,

                effects = {
                    -- particle = 'aeon_secondary',
                    color = Vec(1,0,0),
                    sprite = 'MOD/img/bullet_emg.png',
                    sprite_dimensions = {9, 1},
                    sprite_facePlayer = false,
                },

                sounds = {
                    -- hit = Sounds.weap_secondary.hit,
                    hit_vol = 5,
                },

                homing = {
                    force = 0,
                    gain = 0,
                    max = 0,
                    targetShape = nil,
                    targetPos = Vec(),
                    targetPosRadius = 0,
                }
            }

        },

        missiles = {

            standard = {

                isActive = true, -- Active when firing, inactive after hit.
                hit = false,
                hitInitial = false,
                lifeLength = 15, --Seconds

                category = 'missile',

                speed = 4,
                spread = 0,
                drop = 0,
                dropIncrement = 0,
                explosionSize = 2,
                rcRad = 0,
                force = 0,
                penetrate = false,
                holeSize = 0,

                effects = {
                    particle = 'smoke',
                    color = Vec(1,0.5,0.3),
                    sprite = 'MOD/img/missile1.png',
                    sprite_dimensions = {5, 2},
                    sprite_facePlayer = false,
                },

                sounds = {
                    -- hit = Sounds.weap_secondary.hit,
                    hit_vol = 5,
                },

                homing = {
                    force = 0.02,
                    gain = 0,
                    max = 10,
                    targetShape = nil,
                    targetPos = Vec(),
                    targetPosRadius = 0,
                }
            },

            SAM = {

                isActive = true, -- Active when firing, inactive after hit.
                hit = false,
                hitInitial = false,
                lifeLength = 15, --Seconds

                category = 'missile',

                speed = 1.5,
                spread = 0,
                drop = 0,
                dropIncrement = 0,
                explosionSize = 1,
                rcRad = 0.1,
                force = 0,
                penetrate = false,
                holeSize = 0,

                effects = {
                    particle = 'smoke',
                    color = Vec(1,0.5,0.3),
                    sprite = 'MOD/img/missile1.png',
                    sprite_dimensions = {6, 2},
                    sprite_facePlayer = false,
                },

                sounds = {
                    -- hit = Sounds.weap_secondary.hit,
                    hit_vol = 5,
                },

                homing = {
                    force = 0.015,
                    gain = 0.0,
                    max = 0.015,
                    targetShape = nil,
                    targetPos = Vec(),
                    targetPosRadius = 0,
                }
            }

        },

        rockets = {

            standard = {

                isActive = true, -- Active when firing, inactive after hit.
                hit = false,
                hitInitial = false,
                lifeLength = 10, --Seconds

                category = 'rocket',

                speed = 3,
                spread = 0.035,
                drop = 0,
                dropIncrement = 0,
                explosionSize = 2.25,
                rcRad = 0,
                force = 0,
                penetrate = false,
                holeSize = 0,

                effects = {
                    particle = 'smoke',
                    color = Vec(1,0.5,0.3),
                    sprite = 'MOD/img/rocket.png',
                    sprite_dimensions = {2.2, 0.4},
                    sprite_facePlayer = false,
                },

                sounds = {
                    -- hit = Sounds.weap_secondary.hit,
                    hit_vol = 5,
                },

                homing = {
                    force = 0.0,
                    gain = 0,
                    max = 0,
                    targetShape = nil,
                    targetPos = Vec(),
                    targetPosRadius = 0,
                }
            },

        },

        bombs = {

            standard = {

                isActive = true, -- Active when firing, inactive after hit.
                hit = false,
                hitInitial = false,
                lifeLength = 15, --Seconds

                category = 'bomb',

                speed = 0.6,
                spread = 0.4,
                drop = 1,
                dropIncrement = 0,
                explosionSize = 4,
                rcRad = 0,
                force = 0,
                penetrate = false,
                holeSize = 0,

                effects = {
                    particle = 'smoke',
                    color = Vec(1,0.5,0.3),
                    sprite = 'MOD/img/bomb1.png',
                    sprite_dimensions = {2, 1},
                    sprite_facePlayer = false,
                },

                homing = {
                    force = 0,
                    gain = 0,
                    max = 0,
                    targetShape = nil,
                    targetPos = Vec(),
                    targetPosRadius = 0,
                }

            },

        }

    }

end

function Projectiles_CreateProjectile(transform, projectiles, projPreset, ignoreBodies, homingShape) --- Instantiates a proj and adds it to the projectiles table.

    local proj = DeepCopy(projPreset)
    proj.ignoreBodies = DeepCopy(ignoreBodies)

    proj.transform = transform

    proj.transform.rot = QuatRotateQuat(
        proj.transform.rot,
        QuatEuler(
            math.deg((math.random()-0.5) * proj.spread),
            math.deg((math.random()-0.5) * proj.spread),
            math.deg((math.random()-0.5) * proj.spread)
        ))

    if proj.homing.max > 0 and homingShape then

        proj.homing.targetShape = homingShape

        -- Find relative position.
        local b = GetShapeBody(proj.homing.targetShape)
        local centerPos = AabbGetBodyCenterPos(b)
        local hit, pos = GetBodyClosestPoint(b, centerPos)
        if hit then
            proj.homing.targetBodyRelPos = TransformToLocalPoint(GetBodyTransform(b), pos)
        else
            proj.homing.targetBodyRelPos = TransformToLocalPoint(GetBodyTransform(b), centerPos)
        end

    end

    table.insert(projectiles, proj)

end

function Projectiles_Manage()

    local projectilesToRemove = {} -- projectiles iterations.
    for i, proj in ipairs(Projectiles) do

        if proj.isActive then

            Projectiles_PropelProjectile(proj)

        else-- if proj is inactive.

            table.insert(projectilesToRemove, i)

        end

    end

    for i = 1, #projectilesToRemove do -- remove proj from active projs after projectiles iterations.
        table.remove(Projectiles, projectilesToRemove[i]) -- remove active projs
    end

end

function Projectiles_PropelProjectile(proj)

    --+ Move proj forward.
    proj.transform.pos = TransformToParentPoint(proj.transform, Vec(0,0,-proj.speed))


    proj.lifeLength = proj.lifeLength - GetTimeStep()
    if proj.lifeLength <= 0 then
        proj.hit = true
    end

    -- --+ Ignore bodies
    -- if proj.ignoreBodies ~= nil then
    --     for i = 1, #proj.ignoreBodies do
    --         QueryRejectBody(proj.ignoreBodies[i])
    --     end
    -- end

    --+ Raycast
    local rcHit, hitPos = RaycastFromTransform(proj.transform, proj.speed, 0, proj.ignoreBodies, nil, true)
    if rcHit then

        proj.hitInitial = true
        proj.hit = true

        --+ Hit Action
        -- ApplyBodyImpulse(GetShapeBody(hitShape), hitPos, VecScale(QuatToDir(proj.transform.rot), proj.force))

        if proj.explosionSize > 0 then
            Explosion(hitPos, proj.explosionSize)
        end

        MakeHole(hitPos, proj.holeSize, proj.holeSize, proj.holeSize, proj.holeSize)

    end

    -- if proj.penetrate then
        -- proj.hit = false
        -- if VecDist(robot.transform.pos, proj.transform.pos) > proj.holeSize * 2 then
        --     MakeHole(proj.transform.pos, proj.holeSize,proj.holeSize,proj.holeSize,proj.holeSize)
        -- end
    -- end

    --+ Proj hit water.
    if IsPointInWater(proj.transform.pos) then
        proj.hit = true
        SpawnParticle("water", proj.transform.pos, Vec(0,0,0))
    end

    --+ Proj life.
    if proj.hit then
        proj.isActive = false
    else
        proj.isActive = true
    end


    --+ Proj homing.
    if proj.homing.max > 0 and proj.homing.targetShape ~= nil then

        local targetBody = GetShapeBody(proj.homing.targetShape)
        local targetBodyTr = GetBodyTransform(targetBody)
        local targetPos = TransformToParentPoint(targetBodyTr, proj.homing.targetBodyRelPos)
        local targetVel = GetBodyVelocity(targetBody)

        dbl(proj.transform.pos, targetPos, 1,0,0, 0.5)
        dbcr(targetPos, 1,0,0, 1)
        dbcr(proj.transform.pos, 1,0,0, 1)
        dbray(proj.transform, 30, 0,1,1, 1)

        proj.transform.rot = MakeQuaternion(proj.transform.rot)
        proj.transform.rot = proj.transform.rot:Approach(QuatLookAt(proj.transform.pos, targetPos), proj.homing.force) -- Rotate towards homing target.

        if proj.homing.force < proj.homing.max then -- Increment homing strength.
            proj.homing.force = proj.homing.force + proj.homing.gain
        end


        local guidance = proportional_navigation_guidance(
            targetPos, targetVel,
            proj.transform.pos, VecScale(quat_to_dir(proj.transform.rot), proj.speed),
            1)

        DebugWatch("guidance", guidance)

    end


    --+ Draw sprite
    if proj.effects.sprite_facePlayer then
        DrawSprite(LoadSprite(proj.effects.sprite), Transform(proj.transform.pos, QuatLookAt(proj.transform.pos, GetCameraTransform().pos)), proj.effects.sprite_dimensions[1], proj.effects.sprite_dimensions[2], 1, 1, 1, 1, true)
    else
        DrawSprite(LoadSprite(proj.effects.sprite), Transform(proj.transform.pos, QuatRotateQuat(proj.transform.rot, QuatEuler(math.random(88,92),-math.random(88,92),0))), proj.effects.sprite_dimensions[1], proj.effects.sprite_dimensions[2], 1, 1, 1, 1, true)
        DrawSprite(LoadSprite(proj.effects.sprite), Transform(proj.transform.pos, QuatRotateQuat(proj.transform.rot, QuatEuler(0,-math.random(88,92),0))), proj.effects.sprite_dimensions[1], proj.effects.sprite_dimensions[2], 1, 1, 1, 1, true)
    end


    --+ Particles
    if proj.category == 'missile' then
        particle_missileSmoke(proj.transform, proj.speed)
    elseif proj.category == 'rocket' then
        particle_rocketSmoke(proj.transform, proj.speed)
    end


    local c = proj.effects.color
    PointLight(proj.transform.pos, c[1], c[2], c[3], math.random()+1)

end

function Projectiles_Draw(minDist, maxDist)
    UiPush()

        for index, proj in ipairs(Projectiles) do

            UiPush()

            if IsInfrontOfTr(GetCameraTransform(), proj.transform.pos) then

                local dist = VecDist(proj.transform.pos, GetCameraTransform().pos)

                local a = clamp(1/dist*350, 0, 1)
                local s = 4

                -- if dist > minDist and dist < maxDist then

                    -- local phase = maxDist - minDist

                    -- print()

                    local x,y = UiWorldToPixel(proj.transform.pos)
                    UiTranslate(x,y)

                    UiColor(1,0.75,0.25, a)
                    UiImageBox("ui/common/dot.png", s,s, 0,0)

                -- end

            end

            UiPop()

        end

    UiPop()
end



-- Source: OpenAI
-- Calculates the 3D proportional navigation guidance command
function proportional_navigation_guidance(target_pos, target_vel, own_pos, own_vel, time_to_impact)
    -- target_pos: table representing the target position with fields x, y, and z
    -- target_vel: table representing the target velocity with fields x, y, and z
    -- own_pos: table representing the ownship position with fields x, y, and z
    -- own_vel: table representing the ownship velocity with fields x, y, and z
    -- time_to_impact: estimated time to impact in seconds

    local rel_pos = Vec(target_pos[1] - own_pos[1], target_pos[2] - own_pos[2], target_pos[3] - own_pos[3])
    local rel_vel = Vec(target_vel[1] - own_vel[1], target_vel[2] - own_vel[2], target_vel[3] - own_vel[3])

    -- Calculate magnitude of relative position and velocity vectors
    local range = math.sqrt(rel_pos[1] ^ 2 + rel_pos[2] ^ 2 + rel_pos[3] ^ 2)
    local closing_speed = (rel_pos[1] * rel_vel[1] + rel_pos[2] * rel_vel[2] + rel_pos[3] * rel_vel[3]) / range

    -- Check for divide by zero
    if closing_speed == 0 then
        return Vec(0, 0, 0)
    end

    -- Calculate proportional gain and navigation constant
    local proportional_gain = 3 / time_to_impact -- Proportional gain
    local gamma = proportional_gain / closing_speed -- Navigation constant

    -- Calculate navigation command
    local vel_perp = Vec(
        rel_vel[2] * rel_pos[3] - rel_vel[3] * rel_pos[2],
        rel_vel[3] * rel_pos[1] - rel_vel[1] * rel_pos[3],
        rel_vel[1] * rel_pos[2] - rel_vel[2] * rel_pos[1])

    local vel_perp_mag = math.sqrt(vel_perp[1] ^ 2 + vel_perp[2] ^ 2 + vel_perp[3] ^ 2)
    local guidance = Vec(
        gamma * vel_perp[1] / vel_perp_mag,
        gamma * vel_perp[2] / vel_perp_mag,
        gamma * vel_perp[3] / vel_perp_mag)


    return guidance

end
