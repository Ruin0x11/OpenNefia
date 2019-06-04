local Pos = require("api.Pos")
local Map = require("api.Map")

-- Functions for manipulating characters. These should be preferred to
-- setting the fields on character objects directly.
local Chara = {}

function Chara.at(x, y)
   return nil
end

function Chara.set_pos(c, x, y)
   if Map.in_bounds(x, y) then
      c.x = x
      c.y = y
      return true
   end
   return false
end

function Chara.move(c, dx, dy)
   if type(dx) == "string" then
      dx, dy = Pos.unpack_direction(dx)
   end
   return Chara.set_pos(c, c.x + dx, c.y + dy)
end

function Chara.is_player(c)
   return true
end

return Chara
