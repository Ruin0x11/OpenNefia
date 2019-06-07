local Pos = require("api.Pos")
local Map = require("api.Map")
local Log = require("api.Log")

local chara = require("internal.chara")
local data = require("internal.data")
local field = require("game.field")

-- Functions for manipulating characters.
local Chara = {}

function Chara.at(x, y)
   local objs = field.map:objects_at("base.chara", x, y)
   assert(#objs <= 1)
   return objs[1]
end

function Chara.set_pos(c, x, y)
   if type(c) ~= "table" or not field:exists(c) then
      Log.warn("Chara.set_pos: Not setting position of %s to %d,%d", tostring(c), x, y)
      return false
   end

   if not Map.is_in_bounds(x, y) then
      return false
   end

   if Chara.at(x, y) then
      return false
   end

   field.map:move_object(c, x, y)

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

function Chara.delete(c)
   field.map:remove_object(c)
end

function Chara.kill(c)
   -- Persist based on character type.
   c.state = "Dead"
end

function Chara.is_alive(c)
   -- Persist based on character type.
   return type(c) == "table" and c.state == "Alive"
end

local function init_chara(chara)
   -- TODO remove and place in schema as defaults
   chara.hp = chara.max_hp
   chara.batch_ind = 0
   chara.tile = chara.image
   chara.state = "Alive"
   chara.time_this_turn = 0
   chara.turns_alive = 0

   chara.stats = {}
   chara.stats["base.speed"] = {
      level = 100,
      original_level = 100
   }
end

function Chara.create(id, x, y)
   if field.map == nil then return nil end

   local proto = data["base.chara"][id]
   if proto == nil then return nil end

   assert(type(proto) == "table")

   local chara = field.map:create_object(proto, x, y)

   -- TODO remove
   init_chara(chara)

   return chara
end

-- Gets the level of a stat after applying modifiers.
function Chara.stat(c, stat_id)
   if not Chara.is_alive(c) then
      return 0
   end
   local stat = c.stats[stat_id]
   if stat == nil then
      return 0
   end

   -- TODO: determine how stats are calculated.
   --
   -- It is probably complex to keep a system of chainable expiring
   -- modifiers. We could keep Elona's system of simply requesting a
   -- refresh when desired.
   return stat.level
end

return Chara
