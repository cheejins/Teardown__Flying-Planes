function GetWeaponLocations(plane)

    -- Find lights
    local lights_weap_primary = FindLights('weap_primary', true)
    local lights_weap_secondary = FindLights('weap_secondary', true)
    local lights_weap_special = FindLights('weap_special', true)


    local weaponObjects = {
        primary = {},
        secondary = {},
        special = {},
    }


    for key, light in pairs(lights_weap_primary) do

        local lightBody = GetShapeBody(GetLightShape(light))
        if plane.body == lightBody then

            local lightObj = getLightObject(light)
            lightObj.lightLocalPos = TransformToLocalPoint(GetBodyTransform(lightObj.body), lightObj.tr) -- Light pos rel to body.

            table.insert(weaponObjects.primary, lightObj)
        end

    end

    for key, light in pairs(lights_weap_secondary) do

        local lightBody = GetShapeBody(GetLightShape(light))
        if plane.body == lightBody then

            local lightObj = getLightObject(light)
            lightObj.lightLocalPos = TransformToLocalPoint(GetBodyTransform(lightObj.body), lightObj.tr) -- Light pos rel to body.

            table.insert(weaponObjects.secondary, lightObj)
        end

    end

    for key, light in pairs(lights_weap_special) do

        local lightBody = GetShapeBody(GetLightShape(light))
        if plane.body == lightBody then

            local lightObj = getLightObject(light)
            lightObj.lightLocalPos = TransformToLocalPoint(GetBodyTransform(lightObj.body), lightObj.tr) -- Light pos rel to body.

            table.insert(weaponObjects.special, lightObj)
        end

    end

    return weaponObjects

end

--- Returns the light, its shape and body.
function getLightObject(light)

    local l = {}

    l.light = light
    l.shape = GetLightShape(light)
    l.body = GetShapeBody(l.shape)
    l.tr = GetLightTransform(light)
    l.relPos = TransformToLocalPoint(GetBodyTransform(l.body), l.tr)

    return l

end
