PlaneControls = {
    shoot_primary     = nil,
    shoot_secondary   = nil,
    next_target       = nil,
    homing            = nil,

    thrust_increase   = nil,
    thrust_decrease   = nil,
    yaw_left          = nil,
    yaw_right         = nil,
    pitch_up          = nil,
    pitch_down        = nil,
    roll_left         = nil,
    roll_right        = nil,

    airbrake          = nil,
    wheelbrake        = nil,
    engine            = nil,
    vtolToggle        = nil,
    flaps             = nil,
    landing_gear      = nil,

    change_camera     = nil,
    freecam           = nil,
    disable_input     = nil,
}

function Init_FlightControls()

    ClearKey('savegame.mod.controls')

    PlaneControls = nil

    if FlightMode == FlightModes.simple then

        PlaneControls = util.structured_table('savegame.mod.plane_controls_simple', {
            shoot_primary      = { 'string', 'space' },
            shoot_secondary    = { 'string', 'ctrl' },
            next_target        = { 'string', 'q' },
            homing             = { 'string', 'h' },

            thrust_increase    = { 'string', 'w' },
            thrust_decrease    = { 'string', 's' },
            yaw_left           = { 'string', 'a' },
            yaw_right          = { 'string', 'd' },
            pitch_up           = { 'string', 'uparrow' },
            pitch_down         = { 'string', 'downarrow' },
            roll_left          = { 'string', 'leftarrow' },
            roll_right         = { 'string', 'rightarrow' },

            airbrake           = { 'string', 'shift' },
            wheelbrake         = { 'string', 'b' },
            engine             = { 'string', 'x' },
            vtolToggle         = { 'string', 'v' },
            flaps              = { 'string', 'f' },
            landing_gear       = { 'string', 'g' },

            change_camera      = { 'string', 'c' },
            freecam            = { 'string', 'r' },
            disable_input      = { 'string', 'z' },
        })

    elseif FlightMode == FlightModes.simulation then

        PlaneControls = util.structured_table('savegame.mod.plane_controls_simulation', {
            shoot_primary      = { 'string', 'space' },
            shoot_secondary    = { 'string', 'ctrl' },
            next_target        = { 'string', 'q' },
            homing             = { 'string', 'h' },

            thrust_increase    = { 'string', 'w' },
            thrust_decrease    = { 'string', 's' },
            yaw_left           = { 'string', 'a' },
            yaw_right          = { 'string', 'd' },
            pitch_up           = { 'string', 'uparrow' },
            pitch_down         = { 'string', 'downarrow' },
            roll_left          = { 'string', 'leftarrow' },
            roll_right         = { 'string', 'rightarrow' },

            airbrake           = { 'string', 'shift' },
            wheelbrake         = { 'string', 'b' },
            engine             = { 'string', 'x' },
            vtolToggle         = { 'string', 'v' },
            flaps              = { 'string', 'f' },
            landing_gear       = { 'string', 'g' },

            change_camera      = { 'string', 'c' },
            freecam            = { 'string', 'r' },
            disable_input      = { 'string', 'z' },
        })

    end

    return PlaneControls

end

function draw_options_controls()

end
