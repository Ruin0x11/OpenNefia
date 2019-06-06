local Pos = require("api.Pos")
local Map = require("api.Map")
local Log = require("api.Log")

local chara = require("internal.chara")
local data = require("internal.data")
local field = require("internal.field")

-- Functions for manipulating characters. These should be preferred to
-- setting the fields on character objects directly.
local Chara = {}

function Chara.at(x, y)
   return nil
end

function Chara.set_pos(c, x, y)
   if type(c) ~= "table" or not field:exists(c) then
      Log.warn("Chara.set_pos: Not setting position of %s to %d,%d", tostring(c), x, y)
      return false
   end

   if not Map.is_in_bounds(x, y) then
      return false
   end

   -- field.map:move_object(c, x, y)

   return true
end

function Chara.move(c, dx, dy)
   return Chara.set_pos(c, c.x + dx, c.y + dy)
end

function Chara.is_player(c)
   return field.player == c
end

function Chara.player()
   return field.player
end

function Chara.set_player(c)
   field.player = c
end

function Chara.vanquish(c)
end

function Chara.create(id, x, y)
   if field.map == nil then return nil end

   local proto = data["base.chara"][id]
   if proto == nil then return nil end

   local chara = field.map.create_object(proto, x, y)

   -- TODO remove
   chara.hp = chara.max_hp
   chara.batch_ind = 0
   chara.tile = chara.image

   return chara
end

return Chara
