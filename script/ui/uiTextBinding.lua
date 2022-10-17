activeAssignment = false
activeNameAssignment = false
activeTable = {tb = '', key = ''}
lastKeyPressed = ''
font_size = 28

backspaceTimer = 0


function isActiveTableKey(tb, key) return tb == activeTable.tb and activeTable.key == key end
function resetActiveTable() activeTable = {tb = '', key = ''} end

function enableTextField(tb, key)
    activeNameAssignment = true
    activeTable = {tb = tb, key = key}
end
function disableTextField()
    activeNameAssignment = false
end


function uiTextField(w, h, tb, key)

    do UiPush()

        local w_key = w - h

        -- Label.
        UiFont('regular.ttf', h * 0.8)
        UiAlign('left top')

        -- Bind button.
        UiButtonImageBox("ui/common/box-outline-6.png", 10,10)
        UiButtonHoverColor(0.5,0.5,1,1)

        local lab = tb[key]

        if activeNameAssignment and activeTable.tb == tb and activeTable.key == key then
            local time = math.floor(GetTime())
            local flash = ternary(GetTime() - time > 0.5, '', '_')
            lab = lab..flash
        end

        if UiTextButton(' ' .. lab, w_key,h) then
            if not activeNameAssignment then
                activeNameAssignment = true
                activeTable = { tb = tb, key = key }
            end
        end

        if activeNameAssignment and activeTable.tb == tb and activeTable.key == key then

            margin(w_key + 10, 0)

            UiButtonImageBox("MOD/img/icon_deleteAll.png")
            UiButtonHoverColor(0.5,0.5,1,1)
            if UiTextButton(' ', h,h) then
                activeNameAssignment = false
                resetActiveTable()
            end

        end

        if InputPressed('lmb') and not UiIsMouseInRect(w_key, h) and activeTable.tb == tb and activeTable.key == key then
            activeNameAssignment = false
            resetActiveTable()
        end

    UiPop() end
end

function uiNumberField(w, h, tb, key)

    do UiPush()

        local w_key = w - h

        -- Label.
        UiFont('regular.ttf', h * 0.8)
        UiAlign('left top')

        -- Bind button.
        UiButtonImageBox("ui/common/box-outline-6.png", 10,10)
        UiButtonHoverColor(0.5,0.5,1,1)

        local lab = tb[key]

        if activeNameAssignment and activeTable.tb == tb and activeTable.key == key then
            local time = math.floor(GetTime())
            local flash = ternary(GetTime() - time > 0.5, '', '_')
            lab = lab..flash
        end

        if UiTextButton(' ' .. lab .. ' ', w_key,h) then
            if not activeNameAssignment then
                activeNameAssignment = true
                activeTable = { tb = tb, key = key }
            end
        end

        if activeNameAssignment and activeTable.tb == tb and activeTable.key == key then

            margin(w_key + 10, 0)

            UiButtonImageBox("MOD/img/icon_deleteAll.png")
            UiButtonHoverColor(0.5,0.5,1,1)
            if UiTextButton(' ', h,h) then
                activeNameAssignment = false
                resetActiveTable()
            end

        end

        if InputPressed('lmb') and not UiIsMouseInRect(w_key, h) and activeTable.tb == tb and activeTable.key == key then
            activeNameAssignment = false
            resetActiveTable()
        end

    UiPop() end
end

function Ui_Option_Keybind(w, h, marginX, title, label, tb, key)
    do UiPush()

        local w_key = w - h

        -- Label.
        UiFont('regular.ttf', font_size)
        UiAlign('left top')
        -- UiText(title)

        -- Bind button.
        -- UiTranslate(marginX + font_size, 0)
        UiButtonImageBox("ui/common/box-outline-6.png", 10,10)
        UiButtonHoverColor(0.5,0.5,1,1)

        local lab = ternary(isActiveTableKey(tb, key), 'Press key...', label) -- If active assignment key, then show "Press key" label

        if UiTextButton(string.upper(lab), w_key,h) then
            if not activeAssignment then
                activeAssignment = true
                activeTable = { tb = tb, key = key }
            end
        end

        if activeAssignment and activeTable.tb == tb and activeTable.key == key then

            margin(w_key + 10, 0)

            UiButtonImageBox("ui/terminal/map_x.png")
            UiButtonHoverColor(0.5,0.5,1,1)
            if UiTextButton(' ', h,h) then
                activeAssignment = false
                resetActiveTable()
            end

        end

    UiPop() end
end

function Ui_Option_Keybind_Combo(w, h, marginX, title, label, tb, key)
    do UiPush()

        local w_key = w - h

        -- Label.
        UiFont('regular.ttf', font_size)
        UiAlign('left top')
        -- UiText(title)

        -- Bind button.
        UiButtonImageBox("ui/common/box-outline-6.png", 10,10)
        UiButtonHoverColor(0.5,0.5,1, 1)

        local comboValid = tb[key] ~= '-'
        local lab = tb[key]

        if UiTextButton(string.upper(lab), w_key,h) then

            for index, value in ipairs(comboKeys) do
                if tb[key] == value then
                    tb[key] = comboKeys[GetTableNextIndex(comboKeys, index)] -- Set the combo key to the next item in the comboKeys table.
                    break
                end
            end

        end

        if comboValid then
            margin(w_key + h/4, h/4)
            UiColor(0.5,0.5,0.5, 1)
            UiImageBox('MOD/img/icon_plus.png', h/2, h/2)
        end


    UiPop() end
end

--- Manage keybinds and textfields.
function ManageUiBinding()

    local bindTriggered = false


    lastKeyPressed = string.lower(InputLastPressedKey())


    -- Manage keybinding.
    if activeAssignment and isKeyValid(lastKeyPressed) then

        activeTable.tb[activeTable.key] = lastKeyPressed

        resetActiveTable()
        activeAssignment = false

        bindTriggered = true

    end

    -- Manage text field binding.
    if activeNameAssignment then

        if isCharValid(lastKeyPressed) then

            local text = lastKeyPressed
            if InputDown('shift') then
                text = string.upper(text)
            end

            if text == 'space' then
                text = ' '
            end

            activeTable.tb[activeTable.key] = activeTable.tb[activeTable.key] .. text

        end

        backspaceTimer = backspaceTimer - GetTimeStep()
        if InputDown('backspace') and backspaceTimer < 0 then -- Remove last char from string.

            backspaceTimer = 0.2

            local str = activeTable.tb[activeTable.key]
            local len = string.len(str)
            local strNew = string.sub(str, 1, len-1)

            activeTable.tb[activeTable.key] = strNew

        end

        if InputPressed('return') then
            activeNameAssignment = false
            resetActiveTable()
        end

    end


    return bindTriggered

end


-- function uiBinding_backspaceTimer()

--     TimerRunTime(backspaceTimer)

--     if TimerConsumed(backspaceTimer) then
--         TimerResetTime(backspaceTimer)

--         return true

--     end

--     return false

-- end
