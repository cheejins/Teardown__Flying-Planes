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
    ParticleGravity(0 * math.random(0.5, 1.5))
    ParticleDrag(2)
    ParticleColor(0, 0, 0, 0.1, 0.1, 0.1)

    SpawnParticle(pos, Vec(2 * math.random(), 10 * math.random(), 2 * math.random()), 10)

end
