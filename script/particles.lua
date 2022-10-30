function exhaust_particle_afterburner(tr, amt, vel, alpha, emmissive)

    -- Flame particles.
    ParticleReset()
    ParticleType("smoke")
    local g = clamp(alpha/2, 0.4, 0.6)
    ParticleColor(1.0,g,0.2, 0.3,0.1,0.1)
    ParticleRadius(amt, amt/5, "linear")
    ParticleTile(5)
    ParticleGravity(0.5)
    ParticleEmissive(emmissive, emmissive/4, "easein")
    ParticleRotation(0, 0, "linear")
    ParticleStretch(5)
    ParticleCollide(1)
    ParticleDrag(0.2)
    ParticleAlpha(alpha)

    SpawnParticle(tr.pos, VecScale(QuatToDir(tr.rot), -vel), 0.09)

 end


 function particle_fire(pos, rad)

    ParticleReset()

    ParticleType("smoke")
    ParticleColor(86.0,0.4-(math.random()/6),0.1, 1,0.3,0.1)
    ParticleRadius(rad, rad*3, "linear")
    ParticleTile(5)
    ParticleGravity(0.5)
    ParticleEmissive(4.0, 1, "easein")
    ParticleRotation(math.random(), 0, "linear")
    ParticleStretch(5)
    ParticleCollide(0.5)

    SpawnParticle(pos, Vec(0, 3, 0), 2)

end

function particle_blackSmoke(pos, rad, a)

    ParticleReset()

    ParticleType("smoke")
    ParticleRadius(rad, rad*2)
    ParticleAlpha(a, 0, "constant", 0.1, 0.5)
    ParticleGravity(0 * math.random(0.5, 5))
    ParticleDrag(2)

    local offset = math.random()/8
    ParticleColor(
        1-(a/2) + (offset),
        1-(a/2) + (offset),
        1-(a/2) + (offset),
        1-(a/2) + (offset),
        1-(a/2) + (offset),
        1-(a/2) + (offset))

    SpawnParticle(pos, Vec(2 * math.random(), 10 * math.random(), 2 * math.random()), math.random(3,5))

end

function particle_missileSmoke(tr, speed)

    ParticleReset()

    ParticleType("smoke")
    ParticleRadius(1, 5)
    ParticleAlpha(1, 0.5)
    ParticleGravity(-0.5)
    ParticleDrag(1)
    ParticleStretch(1, 1)

    local offset = math.random()/7
    ParticleColor(
        1-(1/2) + (offset),
        1-(1/2) + (offset),
        1-(1/2) + (offset),
        1-(1/2) + (offset),
        1-(1/2) + (offset),
        1-(1/2) + (offset))

    local vel = VecScale(QuatToDir(tr.rot), -speed)
    local pos = VecAdd(tr.pos, VecRdm(0.1))
    SpawnParticle(pos, vel, 10)
    SpawnParticle(pos, vel, 10)

end

function particle_rocketSmoke(tr, speed)

    ParticleReset()

    ParticleType("smoke")
    ParticleRadius(0.5, 1)
    ParticleAlpha(0.5, 0.3)
    ParticleGravity(-0.5)
    ParticleDrag(0.25)
    ParticleStretch(1, 1)

    local offset = math.random()/7
    ParticleColor(
        1-(0.8) + (offset),
        1-(0.8) + (offset),
        1-(0.8) + (offset),
        1-(0.8) + (offset),
        1-(0.8) + (offset),
        1-(0.8) + (offset))

    local vel = VecScale(QuatToDir(tr.rot), -speed)
    local pos = VecAdd(tr.pos, VecRdm(0.1))
    SpawnParticle(pos, vel, 2)

end
