camPositions = {"custom", "vehicle"}
camPos = camPositions[1]
function setCamPos(_campPos) camPos = _campPos end

function manageCamera(plane, disableRotation)

	local mx, my = InputValue("mousedx"), InputValue("mousedy")

	disableRotation = disableRotation or false
	if disableRotation then mx, my = 0,0 end

	plane.camera.cameraX = plane.camera.cameraX - mx / 10
	plane.camera.cameraY = plane.camera.cameraY - my / 10
	plane.camera.cameraY = clamp(plane.camera.cameraY, -89, 89)

	local cameraRot = QuatEuler(plane.camera.cameraY, plane.camera.cameraX, 0)
	local cameraT = Transform(VecAdd(GetBodyTransform(plane.body).pos, 5), cameraRot)

    local scale = 1
    -- if plane.model == 'ac130' then
    --     scale = 2
    -- end

	plane.camera.zoom = plane.camera.zoom - InputValue("mousewheel") * 2.5
	plane.camera.zoom = clamp(plane.camera.zoom, 5, 40) * scale

	local cameraPos = TransformToParentPoint(cameraT, Vec(0, 8 * scale + plane.camera.zoom/10, plane.camera.zoom))
	local camera = Transform(VecLerp(cameraPos, GetCameraTransform().pos, 0.5), cameraRot)

	-- local hit, p, s, b, d = RaycastFromTransform(camera)
	-- if hit then
	-- 	camera.pos = TransformToParentPoint(camera, Vec(0,0, 1.5))
	-- end

	SetCameraTransform(camera)
end

function planeCamera(plane)

    if camPos == 'freecam' then

    elseif camPos == 'custom' then
        manageCamera(plane)
    end

end
function planeChangeCamera()

    if InputPressed("r") then -- Iterate camera position.

        local camChanged = false
        for i=1, #camPositions do

            if camChanged == false then

                local currentCamPos = camPositions[i]
                if camPos == currentCamPos then

                    local nextCamPos = camPositions[i+1]
                    if nextCamPos == nil then
                        nextCamPos = camPositions[1] -- set next cam pos
                    else
                        nextCamPos = nextCamPos -- reset loop
                    end

                    setCamPos(nextCamPos) -- assign new camera
                    camChanged = true
                end

            end
        end
    end

end
