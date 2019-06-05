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

function Chara.set_player(c)
end

function Chara.vanquish(c)
end

function Chara.create(id, x, y)
   local data = require("internal.data")
   local map = require("internal.map")

   local proto = data["base.chara"][id]
   if proto == nil then return nil end

   local chara = map.get():create_object(proto, x, y)

   -- TODO remove
   chara.hp = chara.max_hp
   chara.batch_ind = 0
   chara.tile = chara.image

   return chara
end

return Chara
