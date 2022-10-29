-- function TimerCreateSeconds(seconds, time)
--     time = time or 0
--     local timer = { time = 60/time, rpm = 60/seconds }
--     return timer
-- end

function TimerCreateRPM(time, rpm)

    local timer = { time = time or 0, rpm = rpm }

    return timer

end

---Run a timer and a table of functions.
---@param timer table -- = {time, rpm}
---@param funcs_and_args table -- Table of functions that are called when time = 0. functions = {{func = func, args = {args}}}
---@param runTime boolean -- Decrement time when calling this function.
function TimerRunTimer(timer, funcs_and_args, runTime)
    if timer.time <= 0 then
        TimerResetTime(timer)

        for i = 1, #funcs_and_args do
            funcs_and_args[i]()
        end

    elseif runTime then
        TimerRunTime(timer)
    end
end

-- Only runs the timer countdown if there is time left.
function TimerRunTime(timer)
    timer.time = timer.time - GetTimeStep()
end

-- Set time left to 0.
function TimerEndTime(timer)
    timer.time = 0
end

-- Reset time to start (60/rpm).
function TimerResetTime(timer)
    timer.time = 60/timer.rpm
end

function TimerConsumed(timer)
    return timer.time <= 0
end

-- Get the timer's completion fraction between 0 and 1.0. Timer consumed = 1.
function TimerGetPhase(timer)
    return clamp(((60/timer.rpm) - timer.time) / (60/timer.rpm), 0, 1)
end
