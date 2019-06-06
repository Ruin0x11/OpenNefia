local Gui = require("api.Gui")
local Map = require("api.Map")


for i=5,30 do
   for j=5,30 do
      if i % 5 == 0 and j % 5 == 0 then
         Map.set_tile("base.wall", i, j)
      end
   end
end


Gui.redraw_screen()
