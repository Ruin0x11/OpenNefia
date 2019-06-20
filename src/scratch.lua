require("boot")
local BookMenu = require("api.gui.menu.BookMenu")

local t = [[
<color=#ffffaa><size=12>Haro
dood
<size=12>Haro
<color=#abcdef>Haro
]]

local bm = BookMenu:new(t)

bm:relayout(0, 0, 800, 600)
bm:update()
bm:draw()
