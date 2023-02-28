#include "./TDSU/tdsu.lua"

function Init_Settings_Table()

	-- Default is simple mode becase everyone uses it.
	Settings_Table = {

		keybinds = {

			weapons = {
				[Actions.shoot_primary] 	= st_object_keybind(MakeKeybind("lmb"), 	"Shoot Primary."),
				[Actions.shoot_secondary] 	= st_object_keybind(MakeKeybind("rmb"), 	"Shoot secondary."),
				[Actions.homing_enabled] 	= st_object_keybind(MakeKeybind("h"), 		"Toggle missile homing on/off")},

			movement = {
				[Actions.thrust_increase]	= st_object_keybind(MakeKeybind("shift"), 	"Thrust increase"),
				[Actions.thrust_decrease]	= st_object_keybind(MakeKeybind("ctrl"), 	"Thrust decrease"),
				[Actions.pitch_up]			= st_object_keybind(MakeKeybind("s"), 		"Pitch up"),
				[Actions.pitch_down]		= st_object_keybind(MakeKeybind("w"), 		"Pitch down"),
				[Actions.roll_left]			= st_object_keybind(MakeKeybind("a"), 		"Roll left"),
				[Actions.roll_right]		= st_object_keybind(MakeKeybind("d"), 		"Roll right"),
				[Actions.yaw_left]			= st_object_keybind(MakeKeybind("z"), 		"Yaw left"),
				[Actions.yaw_right]			= st_object_keybind(MakeKeybind("c"), 		"Yaw right"),
				[Actions.airbrake]			= st_object_keybind(MakeKeybind("space"), 	"Airbrake")},

			camera = {
				[Actions.freecam]			= st_object_keybind(MakeKeybind("x"), 	"Free camera (hold)"),
				[Actions.change_camera]		= st_object_keybind(MakeKeybind("r"), 	"Switch to the next camera view")},

			targeting = {
				[Actions.next_target]		= st_object_keybind(MakeKeybind("q"), 	"Select next target")},

			misc = {
				[Actions.disable_input]		= st_object_keybind(MakeKeybind("k"), 	"Temporarily disable all plane inputs.")},

		},

	}

	-- keybinds = {
	-- 	blood_and_gore		= st_object_checkbox("Blood and Gore", true), -- Do not spawn blood voxels or gorey prefabs
	-- 	reload				= st_object_keybind("Reload", MakeKeybind("r")),
	-- 	foliage_percentage	= st_object_range("Foliage Density", 0.2, 0, 1, 0.01),
	-- },

end


function MakeKeybind(k1, k2, k3) return { k1 = k1 or "none", k2 = k2 or "none", k3 = k3 or "none" } end
