function DrawDot(pos, l, w, r, g, b, a, dt) DrawImage("ui/hud/dot-small.png", pos, l, w, r, g, b, a, dt) end

-- function DrawUiDot(pos, size, r,g,b,a, safemode)
--     local x,y = UiWorldToPixel(pos)
--     UiPush()
--         if safemode then
--             UiColor(r or 1, g or 1, b or 1, a or 1)
--         end
--         UiImageBox("ui/common/dot.png", size, size, 0, 0)
--         UiTranslate(x,y)
--     UiPop()
-- end

-- function DrawBodyOutline() end
