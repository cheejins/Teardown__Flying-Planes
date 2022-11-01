Cameras = {}


function Camera_create(x, y, zoom)

	local camera = {
		cameraX = x or 0,
		cameraY = y or 0,
		zoom 	= zoom or 2,
	}

	camera.create = Camera_create

	return camera

end

function Camera_manage(self, body, height)

	local mx, my = InputValue("mousedx"), InputValue("mousedy")

	self.cameraX = self.cameraX - mx / 10
	self.cameraY = self.cameraY - my / 10
	self.cameraY = clamp(self.cameraY, -75, 75)

	local cameraRot = QuatEuler(self.cameraY, self.cameraX, 0)
	local cameraT = Transform(VecAdd(GetBodyTransform(body).pos, 5), cameraRot)

	zoom = zoom - InputValue("mousewheel") * 2.5
	zoom = clamp(zoom, 2, 20)

	local cameraPos = TransformToParentPoint(cameraT, Vec(0, (height or 2) + zoom/10, zoom))
	local camera = Transform(VecLerp(cameraPos, GetCameraTransform().pos, 0.5), cameraRot)

	SetCameraTransform(camera)

end


-- function GetCrosshairWorldPos(pos, rejectBodies)

--     local crosshairTr = GetCrosshairWorldPos()
--     RejectAllBodies(rejectBodies)
--     local crosshairHit, crosshairHitPos = RaycastFromTransform(crosshairTr, 500)
--     if crosshairHit then
--         return crosshairHitPos
--     else
--         return nil
--     end

-- end

-- function GetCrosshairCameraTr(pos, x, y)

--     pos = pos or GetCameraTransform()

--     local crosshairDir = UiPixelToWorld(x or UiCenter(), y or UiMiddle())
--     local crosshairQuat = DirToQuat(crosshairDir)
--     local crosshairTr = Transform(GetCameraTransform().pos, crosshairQuat)

--     return crosshairTr

-- end