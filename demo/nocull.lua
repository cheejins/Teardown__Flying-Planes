function init()
    for index, s in ipairs(FindShapes('', true)) do
        SetTag(s, 'nocull')
    end
end
