function TimerCreateSeconds(seconds, zeroStart)

    local timer = { rpm = seconds }
    if zeroStart then timer.time = 0 else timer.time = seconds end

    return timer

end

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
function TimerRunTime(timer, stopPoint)
    if timer.time > (stopPoint or 0) then
        timer.time = timer.time - GetTimeStep()
    end
end

-- Set time left to 0.
function TimerEndTime(timer)
    timer.time = 0
end

-- Reset time to start (60/rpm).
function TimerResetTime(timer)
    timer.time = timer.rpm
end

function TimerConsumed(timer)
    return timer.time <= 0
end