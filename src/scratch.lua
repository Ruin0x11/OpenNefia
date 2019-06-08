local Gui = require("api.Gui")
local Map = require("api.Map")

-- for i=5,Map.width() do
--    for j=5,Map.width() do
--       if i % 5 == 0 and j % 3 == 0 then
--          Map.set_tile(i, j, "base.wall")
--       end
--    end
-- end

Gui.update_screen()

local function count_charas()
   local c = 0
   for _, _ in Map.iter_charas() do
      c = c + 1
   end
   return c
end

for _, c in Map.iter_charas() do
   print(c.uid,c.time_this_turn)
end
print(require("game.field"):turn_cost())

return count_charas()
