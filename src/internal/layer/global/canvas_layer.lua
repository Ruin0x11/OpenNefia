local ILayer = require("api.gui.ILayer")
local draw = require("internal.draw")

local canvas_layer = class.class("canvas_layer", ILayer)

function canvas_layer:init()
end

function canvas_layer:default_z_order()
   return 100000
end

function canvas_layer:relayout()
end

function canvas_layer:draw()
   draw.draw_inner_canvas()
end

function canvas_layer:update()
end

return canvas_layer
