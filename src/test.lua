require("boot")

local s = require("api.gui.menu.FeatsMenu"):new()
local m = require("api.gui.menu.chara_make.CharaMakeWrapper"):new(s)
local input = require("internal.input")

m:focus()
m:relayout()

print("--------- press once")
input.keypressed(nil, "up")
input.keyreleased(nil, "up")

m:update()
m:update()
m:update()

print("--------- hold")
input.keypressed(nil, "up")

m:update()
input.keypressed(nil, "up", true)
m:update()
input.keypressed(nil, "up", true)
m:update()

print("--------- release")
input.keyreleased(nil, "up")

m:update()

input.keypressed(nil, "left")
input.keyreleased(nil, "left")

m:update()

input.keypressed(nil, "b")
input.keyreleased(nil, "b")
m:update()

print("--------- choose")
input.keypressed(nil, "*")
input.keyreleased(nil, "*")
input.keypressed(nil, "return")
input.keyreleased(nil, "return")

print(m:update())
m:draw()
