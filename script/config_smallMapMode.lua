function manageConfig()

    config_setSmallMapMode(Config.smallMapMode)

end

function config_setSmallMapMode(enabled)

    if enabled then
        CONFIG = {
            smallMapMode = {
                turnMult = 1,
                liftMult = 0.01,
                dragMult = 6,
            }
        }
    else
        CONFIG = {
            smallMapMode = {
                turnMult = 1,
                liftMult = 1,
                dragMult = 1,
            }
        }
    end

end
