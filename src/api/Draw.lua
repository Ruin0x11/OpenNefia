local draw = require("internal.draw")

-- Functions for drawing things on the screen.
-- @module Draw
local Draw = {}

Draw.get_width = draw.get_width
Draw.get_height = draw.get_height
Draw.get_tiled_width = draw.get_tiled_width
Draw.get_tiled_height = draw.get_tiled_height
Draw.set_font = draw.set_font
Draw.set_color = draw.set_color
Draw.load_image = draw.load_image
Draw.load_shader = draw.load_shader
Draw.use_shader = draw.use_shader
Draw.text_width = draw.text_width
Draw.text_height = draw.text_height
Draw.wrap_text = draw.wrap_text
Draw.text = draw.text
Draw.filled_rect = draw.filled_rect
Draw.image = draw.image
Draw.image_region = draw.image_region
Draw.image_stretched = draw.image_stretched
Draw.image_region_stretched = draw.image_region_stretched
Draw.line = draw.line
Draw.set_root = draw.set_root
Draw.with_canvas = draw.with_canvas
Draw.clear = draw.clear

function Draw.add_async_callback(cb)
   if type(cb) ~= "function" then
      error("Callback must be a function.")
   end

   local field = require("game.field")
   if not field.is_active then
      error("Must be in-game.")
   end

   field:add_async_draw_callback(cb)
end

-- TODO: sanitize
Draw.yield = coroutine.yield

function Draw.text_shadowed(str, x, y, color, shadow_color)
   color = color or {255, 255, 255}
   shadow_color = shadow_color or {0, 0, 0}
   Draw.set_color(shadow_color[1], shadow_color[2], shadow_color[3], shadow_color[4])
   for dx=-1,1 do
      for dy=-1,1 do
         Draw.text(str, x + dx, y + dy)
      end
   end
   Draw.text(str, x, y, color)
end

function Draw.register_draw_layer(layer)
   local field = require("game.field")
   field:register_draw_layer(layer)
end

return Draw
