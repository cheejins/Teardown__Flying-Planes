local timer_auto_center = { time = 0, rpm = 60/3 } -- Time before beginning auto centering.


CameraPositions = {
    "Orbit",
    "Aligned",
    "Vehicle",
    -- "Seat"
}


function plane_ManageCamera(plane, auto_center_delay)

    -- Get mouse input.
	local mx, my = InputValue("mousedx"), InputValue("mousedy")


    -- Reset auto center delay if mouse input.
    if auto_center_delay ~= nil and (math.abs(mx) > 1 or math.abs(my) > 1) then

        timer_auto_center.rpm = 60/auto_center_delay
        TimerResetTime(timer_auto_center)

    end
    TimerRunTime(timer_auto_center)


	plane.camera.cameraX = plane.camera.cameraX - mx / 10
	plane.camera.cameraY = plane.camera.cameraY - my / 10
	plane.camera.cameraZ = plane.camera.cameraZ or 0

    if IsSimpleFlight() then
        plane.camera.cameraY = clamp(plane.camera.cameraY, -89, 89)
    end

    -- Lerp camera towards plane rot
    if auto_center_delay and TimerConsumed(timer_auto_center) then

        local camRot = QuatEuler(
            plane.camera.cameraY,
            plane.camera.cameraX,
            plane.camera.cameraZ)

        local rotDiff = QuatSlerp(camRot, plane.tr.rot, 0.05)

        local x,y,z = GetQuatEuler(rotDiff)
        plane.camera.cameraX = y
        plane.camera.cameraY = x
        plane.camera.cameraZ = z

    end


	local cameraRot = QuatEuler(plane.camera.cameraY, plane.camera.cameraX, plane.camera.cameraZ)
	local cameraT = Transform(VecAdd(GetBodyTransform(plane.body).pos, 5), cameraRot)
    local scale = 1

	plane.camera.zoom = plane.camera.zoom - InputValue("mousewheel") * plane.camera.zoom/5
	plane.camera.zoom = clamp(plane.camera.zoom, 10, 500) * scale


    local camAddHeight = 2
    if plane.model == 'ac130' then
        camAddHeight = 12
    end
    camH = camAddHeight * scale + plane.camera.zoom/10

	local cameraPos = TransformToParentPoint(cameraT, Vec(0, camH, plane.camera.zoom))
	local camera = Transform(VecLerp(cameraPos, GetCameraTransform().pos, 0.5), cameraRot)

    local zoomFOV = Ternary(InputDown("mmb"), 45 , nil)


	SetCameraTransform(camera, zoomFOV)

end


function plane_Camera(plane)

    if SelectedCamera == 'Aligned' then

        plane_ManageCamera(plane, 2)

    elseif SelectedCamera == 'Orbit' then

        plane_ManageCamera(plane)
        plane.camera.cameraZ = 0

    end

end


function plane_ChangeCamera()

    if InputPressed("x") then -- Iterate camera position.

        local index = 1
        for i = 1, #CameraPositions do
            if CameraPositions[i] == SelectedCamera then -- Find current camera.
                index = GetTableNextIndex(CameraPositions, i) -- Find next camera.
                break
            end
        end

        SelectedCamera = CameraPositions[index]

    end

    -- Simple mode cannot use aligned camera since steering depends on camera rotation.
    if SelectedCamera == "Aligned" and IsSimpleFlight() then
        plane_ChangeCamera()
    end

end

function camera_LerpToRot()

end