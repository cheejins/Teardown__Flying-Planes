#include "./TDSU/tdsu.lua"


local kbcats = { -- Keybind categories. Used for display order.
	weapons 	= "weapons",
	movement 	= "movement",
	camera 		= "camera",
	targeting 	= "targeting",
	misc 		= "misc",
}


function Init_Settings_Table()

	-- Default is simple mode becase everyone uses it.
	Settings_Table = {

		keybinds = {

			[kbcats.weapons] = {
				st_object_keybind(Actions.shoot_primary, 	MakeKeybind("lmb"), 	"Shoot Primary."),
				st_object_keybind(Actions.shoot_secondary, 	MakeKeybind("rmb"), 	"Shoot secondary."),
				st_object_keybind(Actions.homing_enabled, 	MakeKeybind("h"), 		"Toggle missile homing on/off")},

			[kbcats.movement] = {
				st_object_keybind(Actions.thrust_increase, 	MakeKeybind("shift"), 	"Thrust increase"),
				st_object_keybind(Actions.thrust_decrease, 	MakeKeybind("ctrl"), 	"Thrust decrease"),
				st_object_keybind(Actions.pitch_up, 		MakeKeybind("s"), 		"Pitch up"),
				st_object_keybind(Actions.pitch_down, 		MakeKeybind("w"), 		"Pitch down"),
				st_object_keybind(Actions.roll_left, 		MakeKeybind("a"), 		"Roll left"),
				st_object_keybind(Actions.roll_right, 		MakeKeybind("d"), 		"Roll right"),
				st_object_keybind(Actions.yaw_left, 		MakeKeybind("z"), 		"Yaw left"),
				st_object_keybind(Actions.yaw_right, 		MakeKeybind("c"), 		"Yaw right"),
				st_object_keybind(Actions.airbrake, 		MakeKeybind("space"), 	"Airbrake")},

			[kbcats.camera] = {
				st_object_keybind(Actions.freecam, 			MakeKeybind("x"), 		"Free camera (hold)"),
				st_object_keybind(Actions.change_camera, 	MakeKeybind("r"), 		"Switch to the next camera view")},

			[kbcats.targeting] = {
				st_object_keybind(Actions.next_target, 		MakeKeybind("q"), 		"Select next target")},

			[kbcats.misc] = {
				st_object_keybind(Actions.disable_input, 	MakeKeybind("k"), 		"Temporarily disable all plane inputs.")},

		},

	}

end


function MakeKeybind(k1, k2, k3) return { k1 = k1 or "none", k2 = k2 or "none", k3 = k3 or "none" } end
