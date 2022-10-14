function init()
    if GetBool('savegame.mod.testMap') then
        StartLevel('', 'test.xml', '')
        DebugPrint('test.xml')
    else
        StartLevel('', 'demo.xml', '')
        DebugPrint('demo.xml')
    end
end

function tick()
    if GetBool('savegame.mod.testMap') then
        StartLevel('', 'test.xml', '')
        DebugPrint('test.xml')
    else
        StartLevel('', 'demo.xml', '')
        DebugPrint('demo.xml')
    end
end

function draw()
    UiColor(0,0,0,0)
    UiRect(UiWidth(), UiHeight())
end