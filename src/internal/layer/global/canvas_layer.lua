local ILayer = require("api.gui.ILayer")
local draw = require("internal.draw")
local Draw = require("api.Draw")

local canvas_layer = class.class("canvas_layer", ILayer)

function canvas_layer:init()
end

function canvas_layer:default_z_order()
   return 100000
end

function canvas_layer:relayout()
end

function canvas_layer:draw()
   Draw.set_color(255, 255, 255, 255)
   draw.draw_inner_canvas()
end

function canvas_layer:update(dt)
end

return canvas_layer
