
globalConfig = {
        gravity = Vec(0,-9,0)
 }

weapon = {
	 weaponName 				= "grenade",
  	munitionType 			= "explosive",
  	explosionSize 		= 1,
  	fuze_time 				= 5,
    fuze_sensitivity = 0.25,
    reliability       = .25, -- (percentage deviation from expected explosion time)
    shrapnel_damage =  3,
    shrapnel_size     =0.2,
    spall_value = 200,
    jet_vel = 150,
    cone = 15,

  	Create 					= "elboydo",
}

spallHandler =
  {
    shellNum = 1,
    shells = {

    },
  defaultShell = {active=false, velocity=nil, direction =nil, currentPos=nil, timeLaunched=nil},
  velocity = 200,
  gravity = Vec(0,-25,0),
  shellWidth = 0.3,
  shellHeight = 0.3,
  }


boom_pos = nil


warhead_primed = false

active_spall = 0

total_spall = 0


function init( )
  munition  = FindShape(weapon.weaponName)
  body = GetShapeBody(munition)
  -- DebugWatch("body vel at init",VecLength(GetBodyVelocity(body)))

  last_vel_dir =  GetBodyVelocity(body)
  last_vel = VecLength(GetBodyVelocity(body))
  fuze = weapon.fuze_time + rnd(-weapon.fuze_time * weapon.reliability,weapon.fuze_time * weapon.reliability)
  added_cook_time = false

  exploded = false
  explosion_sound = LoadSound("MOD/snd/grenade_explosion.ogg")
  spalling_sprite =  LoadSprite("MOD/gfx/spalling.png")
  vehicle = GetPlayerVehicle()
  vehiclebody = GetVehicleBody(vehicle)
  local munition_body = GetShapeBody(munition)
  vehiclebodyvelocity = GetBodyVelocity(vehiclebody)
  SetBodyVelocity(munition_body, vehiclebodyvelocity)

end
function rnd(mi, ma)
  return math.random()*(ma-mi)+mi
end
function rndVec(length)
  local v = VecNormalize(Vec(math.random(-100,100), math.random(-100,100), math.random(-100,100)))
  return VecScale(v, length)
end
function tick(dt)
  -- if(boom_pos~=nil) then
  --   DebugCross(boom_pos)
  -- end
  -- DebugWatch("active spall ",active_spall)
  -- DebugWatch("total spall ",total_spall)

  -- DebugWatch("body vel in flight",VecLength(GetBodyVelocity(body)))

  if(not exploded) then


        local calibreCoef = 1
        local exaust_pos = TransformToParentPoint(GetShapeWorldTransform(munition),Vec(0,0.8,-0.3))
        local exaust_vec = VecSub(GetShapeWorldTransform(munition).pos, TransformToParentPoint(GetShapeWorldTransform(munition),Vec(0,1,-10)))
        SpawnParticle("fire",exaust_pos, exaust_vec,  1.1*calibreCoef, .15)
        SpawnParticle("smoke",exaust_pos, exaust_vec, 1.2*calibreCoef, .3)
        PointLight(exaust_pos, 0.8, 0.8, 0.5, math.random(1*calibreCoef,15*calibreCoef))
        local munition_body = GetShapeBody(munition)
        local speed_limit = 280
        if(VecLength(GetBodyVelocity(munition_body))<speed_limit) then

          local nose_pos = GetBodyCenterOfMass(GetShapeBody(munition))--TransformToParentPoint(GetShapeWorldTransform(munition),Vec(0,0.8,0.3))
          local munition_centre = Transform(nose_pos,QuatCopy(GetShapeWorldTransform(munition).rot))
          local thrust_vec = VecSub(munition_centre.pos,TransformToParentPoint(munition_centre,Vec(0,-160, -9)))--VecSub(GetShapeWorldTransform(munition).pos, TransformToParentPoint(GetShapeWorldTransform(munition),Vec(00,-10, 0)))
          SetBodyVelocity(munition_body,VecAdd(GetBodyVelocity(munition_body),VecScale(thrust_vec,dt)))
        else
          local body_vel = GetBodyVelocity(munition_body)
          SetBodyVelocity(munition_body,VecScale(body_vel,speed_limit/VecLength(body_vel)))
        end
        -- DebugWatch("MUNITION VEL",VecLength(GetBodyVelocity(munition_body)))
        --ApplyBodyImpulse(GetShapeBody(munition),nose_pos,VecScale(thrust_vec,80*dt))
        -- local pos = GetShapeWorldTransform(munition)
        -- local calibreCoef = 10
        -- ParticleReset()
        -- ParticleType("smoke")
        -- ParticleColor(0.7, 0.6, 0.5)
        -- --Spawn particle at world origo with upwards velocity and a lifetime of ten seconds
        -- SpawnParticle(Vec(0, 0, 0), Vec(0, 1, 0), 10.0)
        -- PointLight(pos, 0.8, 0.8, 0.5, math.random(1*calibreCoef,15*calibreCoef))


    if(warhead_primed) then
      if(fuze>0) then
        fuze = fuze - dt
        if(fuze_triggered(GetBodyVelocity(body))) then
          fuze = -1
        end
      else
        local pos = GetShapeWorldTransform(munition).pos
        local explode_pos = TransformToParentPoint(GetShapeWorldTransform(munition),Vec(0,0,0.5))
        Explosion(explode_pos,weapon.explosionSize)
        PlaySound(explosion_sound, pos,50)
        local shrapnel_pos = TransformToParentPoint(GetShapeWorldTransform(munition),Vec(0,1.6,0))
        boom_pos = shrapnel_pos
        pushshrapnel(Transform(shrapnel_pos))
        exploded = true
      end
    else

         if VecLength(GetBodyVelocity(body))> 10 and  fuze_triggered(GetBodyVelocity(body)) then
          warhead_primed = true
          last_vel_dir = GetBodyVelocity(body)
          last_vel = VecLength(GetBodyVelocity(body))
        end
    end
  elseif(active_spall>0) then
    spallingTick(dt)
  end

end


function fuze_triggered(t_vel)
  vel = VecLength(t_vel)
  -- DebugWatch("last vel",last_vel)

  -- DebugWatch("test vel",vel)
    if math.abs(1-(last_vel / vel))> weapon.fuze_sensitivity then
        return true
    else
      last_vel_dir = t_vel
        last_vel = vel
        return false
    end
end


function pushshrapnel(spallingLoc)

  local spallValue = weapon.spall_value
  -- DebugWatch("spall quant_1",spallValue)
  if(weapon.explosionSize) then
    spallValue = spallValue *  weapon.explosionSize
  end
  -- DebugWatch("spall quant",spallValue)
  local spallQuant = math.random(spallValue,spallValue*3)

  total_spall = spallQuant
  active_spall = total_spall
  for i=1, spallQuant do
    local damage_coef = rnd(weapon.shrapnel_damage*.5,weapon.shrapnel_damage*1.5)
    local spallingSizeCoef = math.random(1,4)/10
    local spallPos = TransformCopy(spallingLoc)
    local direction = rndVec(math.random(1,spallValue))
    local point1 = spallPos.pos
    spallHandler.shells[#spallHandler.shells+1] = DeepCopy(spallHandler.defaultShell)
    local currentSpall        = spallHandler.shells[#spallHandler.shells]
    currentSpall.active       = true
    currentSpall.shellType = {}
    currentSpall.cannonLoc      = spallPos
    currentSpall.point1     = point1
    currentSpall.predictedBulletVelocity = rndVec(math.random() * 200)
    currentSpall.shrapnel = true
    currentSpall.originPos    = spallPos
    currentSpall.maxTimeToLive = (3 *(spallingSizeCoef+0.2))*(math.random(50,100)/100)
    currentSpall.timeToLive   = currentSpall.maxTimeToLive
    currentSpall.dispersion     = 10
    currentSpall.shellType.bulletdamage = {}
    currentSpall.shellType.bulletdamage[1] = damage_coef * spallingSizeCoef
    currentSpall.shellType.bulletdamage[2] = damage_coef *.7 * spallingSizeCoef
    currentSpall.shellType.bulletdamage[3] = damage_coef *.5 * spallingSizeCoef
    currentSpall.shellType.caliber = (weapon.shrapnel_size * spallingSizeCoef)*0.3
    currentSpall.shellType.shellWidth = math.min(math.random(), 0.1)
    currentSpall.shellType.shellHeight = math.min(math.random(),0.1)
    currentSpall.penDepth = 0.1

    currentSpall.shellType.r = 2 + (math.random(0,5)/10)
    currentSpall.shellType.g = 1.7 + (math.random(0,5)/10)
    currentSpall.shellType.b = 1 + (math.random(0,10)/10)


    spallHandler.shellNum = (spallHandler.shellNum%#spallHandler.shells) +1

  end

end


function shrapnelOperations(projectile,dt )
    projectile.cannonLoc.pos = projectile.point1
    local shellHeight = projectile.shellType.shellHeight
    local shellWidth = projectile.shellType.shellWidth
    -- local spallDecay =  math.random()* (currentSpall.maxTimeToLive / currentSpall.timeToLive )
    local spallDecay = math.random()
    local r = projectile.shellType.r * spallDecay
    local g = projectile.shellType.g * spallDecay
    local b = projectile.shellType.b * spallDecay


    --- sprite drawing
    DrawSprite(spalling_sprite, projectile.cannonLoc,projectile.shellType.shellWidth,shellHeight , r, g, b, 1, 0, false)
    local altloc = TransformCopy(projectile.cannonLoc)
    altloc.rot = QuatRotateQuat(altloc.rot,QuatEuler(0, 90,0))
    DrawSprite(spalling_sprite, altloc, projectile.shellType.shellWidth, shellHeight, r, g, b, 1, 0, false)
    altloc.rot = QuatRotateQuat(projectile.cannonLoc.rot,QuatEuler(90, 0,0))
    DrawSprite(spalling_sprite, altloc, projectile.shellType.shellWidth, projectile.shellType.shellWidth, r, g, b, 1, 0, false)


    projectile.predictedBulletVelocity = VecScale(projectile.predictedBulletVelocity,0.8)

    local dispersion = Vec(math.random(-1,1)*projectile.dispersion,math.random(-1,1)*projectile.dispersion,math.random(-1,1)*projectile.dispersion)
    if(projectile.shellType.dispersionCoef) then
      dispersion=VecScale(dispersion,dispersionCoef)
    end
    projectile.predictedBulletVelocity = VecAdd(projectile.predictedBulletVelocity,(VecScale(dispersion,dt)))

      projectile.predictedBulletVelocity = VecAdd(projectile.predictedBulletVelocity,(VecScale(globalConfig.gravity,dt)))

    local point2 = VecAdd(projectile.point1,VecScale(projectile.predictedBulletVelocity,dt))
    QueryRequire("physical")
    local hit, dist1,norm1,shape1 = QueryRaycast(projectile.point1, VecNormalize(VecSub(point2,projectile.point1)),VecLength(VecSub(point2,projectile.point1)))

    projectile.cannonLoc.rot = QuatRotateQuat(QuatLookAt(point2,projectile.point1),QuatEuler(00, 90, 90))



      local hit_player =  inflict_player_damage(projectile,point2)

      if(hit or hit_player)then
        hitPos = VecAdd(projectile.point1, VecScale(VecNormalize(VecSub(point2,projectile.point1)),dist1))
        projectile.point1 = hitPos
         popSpalling(projectile,shape1)

      else
        projectile.point1 = point2
      end

end



function popSpalling(shell,hitTarget)


    local holeModifier = math.random(-15,15)/100
    local fireChance = math.random(0,100)/100
    local firethreshold = 0.96
    if(fireChance>firethreshold)then
      SpawnFire(shell.point1)
    end
    if shell.shellType.hit and shell.shellType.hit <3 then
      shell.shellType.bulletdamage = VecScale(shell.shellType.bulletdamage,
                                        VecLength(shell.predictedBulletVelocity)/VecLength(shell.initial_vel))
      if(shell.shellType.hit ==1)then
        MakeHole(shell.point1,shell.shellType.bulletdamage[1]*1.4)
      else
        MakeHole(shell.point1,shell.shellType.bulletdamage[1]*1.4,shell.shellType.bulletdamage[2]*1.2)
      end

    else
      MakeHole(shell.point1,shell.shellType.bulletdamage[1]*1.4,shell.shellType.bulletdamage[2]*1.2, shell.shellType.bulletdamage[3]*1.2)
    end

    shell.active = false
    active_spall  = active_spall -1
    for key,val in ipairs( shell ) do
      val = nil

    end
    shell = DeepCopy(spallHandler.defaultShell)

end


function spallingTick(dt)
      -- DebugWatch("shells",#spallHandler.shells  )
      for key,shell in ipairs( spallHandler.shells  )do
        if(shell.active)then
          if(shell.timeToLive > 0) then
            if(shell.shrapnel) then
              shrapnelOperations(shell,dt)

            else
              spallingOperations(shell,dt)
            end
            shell.timeToLive = shell.timeToLive - dt
          else
            shell.active = false
            active_spall  = active_spall -1
          end
        end
    end
end



function inflict_player_damage(projectile,point2)
  local t= Transform(projectile.point1,QuatLookAt(point2,projectile.point1))
  local p = TransformToParentPoint(t, Vec(0, 0, 1))
  local p2 = TransformToParentPoint(t, Vec(0, 0, 2))

  local d = VecNormalize(VecSub(projectile.point1,point2))

  hurt_dist = VecLength(VecSub(projectile.point1,point2))
  --Hurt player
  local player_cam_pos = GetPlayerCameraTransform().pos
  local player_pos = GetPlayerTransform().pos

  player_pos = VecLerp(player_pos,player_cam_pos,0.5)
  local toPlayer = VecSub(player_pos, t.pos)
  local distToPlayer = VecLength(toPlayer)
  local distScale = clamp(1.0 - distToPlayer / hurt_dist, 0.0, 1.0)
  -- DebugWatch("test",distScale)
  if distScale > 0 then
    -- DebugWatch("dist scale",distScale)
    toPlayer = VecNormalize(toPlayer)
    -- DebugWatch("dot to player",VecDot(d, toPlayer))
      -- DebugWatch("distToPlayer",distToPlayer)
    if VecDot(d, toPlayer) > 0.9 or distToPlayer < 1 then
      -- DebugWatch("player dist scale",distScale)
      -- DebugWatch("distToPlayer",distToPlayer)
      local hit = QueryRaycast(p, toPlayer, distToPlayer)
      if not hit or distToPlayer < 0.7 then
        -- DebugWatch("player would be hit",distToPlayer)
        SetPlayerHealth(GetPlayerHealth() - 0.035 * (projectile.shellType.bulletdamage[1] * (distScale*2)*25)*math.log(VecLength(projectile.predictedBulletVelocity)))
        return true
      end
    end
  end
  return false
end




function clamp(val, lower, upper)
    if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
    return math.max(lower, math.min(upper, val))
end


function DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[DeepCopy(orig_key)] = DeepCopy(orig_value)
        end
        setmetatable(copy, DeepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
