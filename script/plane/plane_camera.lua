CameraPositions = {
    "Orbit",
    -- "Aligned",
    "Vehicle",
    -- "Seat"
}


function plane_ManageCamera(plane, disableRotation)

	local mx, my = InputValue("mousedx"), InputValue("mousedy")

	disableRotation = disableRotation or false
	if disableRotation then mx, my = 0,0 end

	plane.camera.cameraX = plane.camera.cameraX - mx / 10
	plane.camera.cameraY = plane.camera.cameraY - my / 10
	-- plane.camera.cameraY = clamp(plane.camera.cameraY, -89, 89)

	local cameraRot = QuatEuler(plane.camera.cameraY, plane.camera.cameraX, 0)
	local cameraT = Transform(VecAdd(GetBodyTransform(plane.body).pos, 5), cameraRot)

    local scale = 1

	plane.camera.zoom = plane.camera.zoom - InputValue("mousewheel") * plane.camera.zoom/5
	plane.camera.zoom = clamp(plane.camera.zoom, 10, 500) * scale


    local camAddHeight = 4
    if plane.model == 'ac130' then
        camAddHeight = 12
    end
    camH = camAddHeight * scale + plane.camera.zoom/10

	local cameraPos = TransformToParentPoint(cameraT, Vec(0, camH, plane.camera.zoom))
	local camera = Transform(VecLerp(cameraPos, GetCameraTransform().pos, 0.5), cameraRot)

    local zoomFOV = ternary(InputDown("mmb"), 30 , nil)


	SetCameraTransform(camera, zoomFOV)

end


function plane_Camera(plane)

    if SelectedCamera == 'Aligned' then

        local camPos = TransformToParentPoint(plane.tr, Vec(0, 10, 30))
        -- local camRot = QuatRotateQuat(plane.tr.rot, DirToQuat(plane.forces[1], plane.forces[2], plane.forces[3]))
        -- local camRot = QuatRotateQuat(plane.tr.rot, DirToQuat(Vec(math.rad(plane.forces[2]), 0, 0)))
        local camTr = Transform(camPos, camRot)

        SetCameraTransform(camTr)

    elseif SelectedCamera == 'Orbit' then

        plane_ManageCamera(plane)

    end

end


function plane_ChangeCamera()

    if InputPressed("x") then -- Iterate camera position.

        local index = 1
        for i = 1, #CameraPositions do
            if CameraPositions[i] == SelectedCamera then
                index = GetTableNextIndex(CameraPositions, i)
            end
        end

        SelectedCamera = CameraPositions[index]

    end

end
