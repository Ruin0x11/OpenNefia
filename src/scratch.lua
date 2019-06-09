local Draw = require("api.Draw")

function cb(draw_x, draw_y)
   local x = math.random(0, 1600)
   for i=0,100 do
      Draw.set_color(255, 255, 255)
      Draw.text("dood", x, 1200 - i * 5)
      Draw.yield()
   end
end

for i=0,100 do
   Draw.add_async_callback(cb)
end
