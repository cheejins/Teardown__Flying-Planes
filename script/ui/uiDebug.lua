function drawVideoDesc(text)

    if not text then
        return
    end

    UiAlign('center middle')
    UiFont('bold.ttf', 30)
    UiColor(0.75,0.75,0.75, 0.75)

    do UiPush()
        local rectW = 400
        local rectH = 350
        margin(rectW/2, rectH/2)
        margin(80, 80)
        UiColor(0.5,0.5,1, 0.75)
        UiRect(rectW + 50, rectH)
        UiWordWrap(rectW)
        UiColor(1,1,1, 1)
        UiText(text)
    UiPop() end

end


function drawItemChain()

    UiTextShadow(0,0,0,0.5, 0.5,0)

    do UiPush()

        UiAlign('left top')
        UiFont('bold.ttf', 22)
        UiColor(0,0,0, 0.9)

        -- Background
        UiRect(400, 750)

        margin(20, 20)
        UiColor(1,1,1, 1)
        UiText('ITEM CHAIN')

        UiColor(1,1,1, 0.5)
        margin(0, 30)
        UiText('Execution order')

        margin(0, 60)

        do UiPush()

            for index, item in ipairs(ITEM_CHAIN) do

                do UiPush()

                    if item.type == 'camera' and item.item.id == SELECTED_CAMERA then
                        UiColor(0.5,1,0.5,1)
                    elseif item.type == 'event' and item.item.id == SELECTED_EVENT then
                        UiColor(1,1,0,1)
                    end

                    UiText('['.. index ..'] ' .. item.type)
                    margin(120, 0)
                    UiText('' .. item.item.id)

                    margin(40, 0)
                    if item.type == 'event' then
                        UiText(sfn(item.item.val.time))
                    end

                    margin(70, 0)
                    UiText(item.item.type)

                UiPop() end

                margin(0, 50)

            end

        UiPop() end

    UiPop() end

end

function drawItemObjects()

    UiTextShadow(0,0,0,0.5, 0.5,0)

    do UiPush()

        UiAlign('left top')
        UiFont('bold.ttf', 22)
        UiColor(0,0,0, 0.9)

        -- Background
        UiRect(350, 750)

        margin(20, 20)
        UiColor(1,1,1, 1)
        UiText('ITEM OBJECTS')

        UiColor(1,1,1, 0.5)
        margin(0, 30)
        -- UiText('Execution order')

        margin(0, 60)

        do UiPush()

            for index, item in ipairs(ITEM_OBJECTS) do

                do UiPush()

                    if item.type == 'camera' and item.item.id == SELECTED_CAMERA then
                        UiColor(0.5,1,0.5,1)
                    elseif item.type == 'event' and item.item.id == SELECTED_EVENT then
                        UiColor(1,1,0,1)
                    end

                    UiText('['.. index ..'] ' .. item.type)
                    margin(120, 0)
                    UiText('' .. item.item.id)

                    margin(40, 0)
                    if item.type == 'event' then
                        UiText(sfn(item.item.val.time))
                    end

                    margin(70, 0)
                    UiText(item.item.type)

                UiPop() end

                margin(0, 50)

            end

        UiPop() end

    UiPop() end

end

function drawCameraList()

    UiTextShadow(0,0,0,0.5, 0.5,0)

    do UiPush()

        UiAlign('left top')
        UiFont('bold.ttf', 22)
        UiColor(0,0,0, 0.9)

        -- Background
        UiRect(350, 750)

        margin(20, 20)
        UiColor(1,1,1, 1)
        UiText('CAMERA OBJECTS')

        UiColor(1,1,1, 0.5)
        margin(0, 30)
        -- UiText('Execution order')

        margin(0, 60)

        do UiPush()

            for index, item in ipairs(CAMERA_OBJECTS) do

                do UiPush()

                    UiText('['.. index ..'] ' .. item.type)
                    margin(120, 0)

                    margin(40, 0)
                    UiText(item.id)

                UiPop() end

                margin(0, 50)

            end

        UiPop() end

    UiPop() end

end

function drawEventList()

    UiTextShadow(0,0,0,0.5, 0.5,0)

    do UiPush()

        UiAlign('left top')
        UiFont('bold.ttf', 22)
        UiColor(0,0,0, 0.9)

        -- Background
        UiRect(350, 750)

        margin(20, 20)
        UiColor(1,1,1, 1)
        UiText('EVENT OBJECTS')

        UiColor(1,1,1, 0.5)
        margin(0, 30)
        -- UiText('Execution order')

        margin(0, 60)

        do UiPush()

            for index, item in ipairs(EVENT_OBJECTS) do

                do UiPush()

                    UiText('['.. index ..'] ' .. item.type .. ' id:' .. item.id)
                    margin(120, 0)

                    margin(40, 0)
                    UiText(sfn(item.val.time))

                    margin(70, 0)
                    UiText(item.type)

                UiPop() end

                margin(0, 50)

            end

        UiPop() end

    UiPop() end

end
