Cameras = {}


function camera_create(x, y, z, zoom)

	return {
		cameraX = x or 0,
		cameraY = y or 0,
		cameraZ = z or 0,
		zoom 	= zoom or 2,
	}

end

function camera_manage_auto(camera, body, height)

	local mx = InputValue("mousedx")
	local my = InputValue("mousedy")

	camera.cameraX = camera.cameraX - mx / 10
	camera.cameraY = camera.cameraY - my / 10
	camera.cameraY = clamp(camera.cameraY, -75, 75)

	local cameraRot = QuatEuler(camera.cameraY, camera.cameraX, 0)
	local cameraT = Transform(VecAdd(GetBodyTransform(body).pos, 5), cameraRot)

	zoom = zoom - InputValue("mousewheel") * 2.5
	zoom = clamp(zoom, 2, 20)

	local cameraPos = TransformToParentPoint(cameraT, Vec(0, (height or 2) + zoom/10, zoom))
	local camera = Transform(VecLerp(cameraPos, GetCameraTransform().pos, 0.5), cameraRot)

	SetCameraTransform(camera)

end


function camera_manage(plane, camera, dt, pos, rot, camDx, camDy, camDz, height)

	local mx = camDx
	local my = camDy
	-- local mz = camDz

	camera.cameraX = camera.cameraX - (mx / 10)
	camera.cameraY = camera.cameraY - (my / 10)
	-- camera.cameraZ = camera.cameraZ - (mz or 0) / 10
	-- camera.cameraY = clamp(camera.cameraY, -75, 75)

	local cameraRot = QuatEuler(camera.cameraY, camera.cameraX, 0)

	camera.zoom = camera.zoom - InputValue("mousewheel") * 2.5
	camera.zoom = clamp(camera.zoom, 0, 20)

	local cameraTr = Transform(
		VecLerp(pos, TransformToParentPoint(Transform(pos, cameraRot), Vec(0, 0, -1)), dt*20),
		QuatRotateQuat(rot, cameraRot))


	SetCameraTransform(cameraTr)

end
