require("boot")

local m = require("api.gui.menu.chara_make.SelectBalanceMenu"):new()
local input = require("internal.input")

m:focus()
m:relayout()

print("--------- press once")
input.keypressed(nil, "up")
input.keyreleased(nil, "up")

m:run_actions()
m:run_actions()
m:run_actions()

print("--------- hold")
input.keypressed(nil, "up")

m:run_actions()
input.keypressed(nil, "up", true)
m:run_actions()
input.keypressed(nil, "up", true)
m:run_actions()

print("--------- release")
input.keyreleased(nil, "up")

m:run_actions()

-- input.keypressed(nil, "left")
-- input.keyreleased(nil, "left")
--
-- m:run_actions()

input.keypressed(nil, "c")
input.keyreleased(nil, "c")
m:run_actions()

print("--------- choose")
input.keypressed(nil, "*")
input.keyreleased(nil, "*")
input.keypressed(nil, "return")
input.keyreleased(nil, "return")

m:run_actions()
m:update()
m:draw()

m:update()
