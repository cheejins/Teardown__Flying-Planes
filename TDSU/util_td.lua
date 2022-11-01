function AimSteerVehicle()

    local v = GetPlayerVehicle()
    if v ~= 0 then AimSteerVehicle(v) end

    local vTr = GetVehicleTransform(v)
    local camFwd = TransformToParentPoint(GetCameraTransform(), Vec(0, 0, -1))

    local pos = TransformToLocalPoint(vTr, camFwd)
    local steer = pos[1] / 10

    DriveVehicle(v, 0, steer, false)

end


function RejectAllBodies(bodies) for i = 1, #bodies do QueryRejectBody(bodies[i]) end end
function RejectAllShapes(shapes) for i = 1, #shapes do QueryRejectShape(shapes[i]) end end


-- function CheckExplosions(cmd)

--     words = splitString(cmd, " ")
--     if #words == 5 then
--         if words[1] == "explosion" then

--             local strength = tonumber(words[2])
--             local x = tonumber(words[3])
--             local y = tonumber(words[4])
--             local z = tonumber(words[5])

--             -- DebugPrint('explosion: ')
--             -- DebugPrint('strength: ' .. strength)
--             -- DebugPrint('x: ' .. x)
--             -- DebugPrint('y: ' .. y)
--             -- DebugPrint('z: ' .. z)
--             -- DebugPrint('')

--         end
--     end

--     if #words == 8 then
--         if words[1] == "shot" then

--             local strength = tonumber(words[2])
--             local x = tonumber(words[3])
--             local y = tonumber(words[4])
--             local z = tonumber(words[5])
--             local dx = tonumber(words[6])
--             local dy = tonumber(words[7])
--             local dz = tonumber(words[8])

--             -- DebugPrint('shot: ')
--             -- DebugPrint('strength: ' .. strength)
--             -- DebugPrint('x: ' .. x)
--             -- DebugPrint('y: ' .. y)
--             -- DebugPrint('z: ' .. z)
--             -- DebugPrint('dx: ' .. dx)
--             -- DebugPrint('dy: ' .. dy)
--             -- DebugPrint('dz: ' .. dz)
--             -- DebugPrint('')

--         end
--     end

-- end


-- function SetShapeCollision()
    -- LAYER_A = 1 -- Default
    -- LAYER_B = 2
    -- LAYER_C = 4
    -- LAYER_D = 8
    -- LAYER_E = 16
    -- LAYER_F = 32
    -- LAYER_G = 64
    -- LAYER_H = 128
    -- EVERY_LAYER = 255

    -- -- shape in layer D, collide only with layer B and C
    -- SetShapeCollisionFilter(shape1, LAYER_D, LAYER_B + LAYER_C)
    -- -- shape in layer E, do not collide with layer B and C
    -- SetShapeCollisionFilter(shape2, LAYER_E, EVERY_LAYER - LAYER_B - LAYER_C)

    -- -- Example
    -- SetShapeCollisionFilter(engine, LAYER_B, EVERY_LAYER - LAYER_B)
    -- SetShapeCollisionFilter(propeller, LAYER_B, EVERY_LAYER - LAYER_B)
-- end
