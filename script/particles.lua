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

    -- SpawnParticle('smoke', TransformToParentPoint(tr, Vec(0,0,-2)), VecScale(QuatToDir(tr.rot), -vel), 0.5)

 end