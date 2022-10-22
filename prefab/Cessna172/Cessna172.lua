function init()
	btn_navlight = FindShape("nl")
	btn_cabinlight = FindShape("cl")
	btn_instrumentlight = FindShape("ilb")

	light_instrument = FindLight("instrument")
	light_beacon = FindLight("beacon")
	light_cabin = FindLights("cabin")
	light_nav = FindLights("navlight")

	SetTag(btn_navlight, "interact", "Navigation lights")
	SetTag(btn_cabinlight, "interact", "Cabin lights")
	SetTag(btn_instrumentlight, "interact", "Instrument light")

	for i=1,#light_cabin do
		SetLightEnabled(light_cabin[i], false)
	end

	for i=1,#light_nav do
		SetLightEnabled(light_nav[i], false)
	end

	SetLightEnabled(light_instrument, false)
	SetLightEnabled(light_beacon, false)

	beacon = false
	timer = 0
end

function update(dt)

	if GetPlayerInteractShape() == btn_cabinlight and InputPressed("interact") then
		for i=1,#light_cabin do
			if IsLightActive(light_cabin[i]) == false then
				SetLightEnabled(light_cabin[i], true)
			else
				SetLightEnabled(light_cabin[i], false)
			end
		end
	end

	if GetPlayerInteractShape() == btn_navlight and InputPressed("interact") then
		if not beacon then
			beacon = true
		else
			beacon = false
		end

		for i=1,#light_nav do
			if IsLightActive(light_nav[i]) == false then
				SetLightEnabled(light_nav[i], true)
			else
				SetLightEnabled(light_nav[i], false)
			end
		end

	end

	if GetPlayerInteractShape() == btn_instrumentlight and InputPressed("interact") then
		if IsLightActive(light_instrument) == false then
			SetLightEnabled(light_instrument, true)
		else
			SetLightEnabled(light_instrument, false)
		end
	end

	if beacon then
	timer = timer + 1
		if timer == 80 then
			timer = timer * 0 + 1
		end
		if timer > 0 and timer < 10 then
			SetLightEnabled(light_beacon, true)
		end
		if timer >= 10 and timer < 20 then
			SetLightEnabled(light_beacon, false)
		end
		if timer >= 20 and timer < 30 then
			SetLightEnabled(light_beacon, true)
		end
		if timer >= 30 and timer < 80 then
			SetLightEnabled(light_beacon, false)
		end
	end

end