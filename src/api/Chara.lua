local Ai = require("api.Ai")
local Event = require("api.Event")
local MapObject = require("api.MapObject")
local Gui = require("api.Gui")
local Inventory = require("api.Inventory")
local ILocation = require("api.ILocation")
local Log = require("api.Log")
local Map = require("api.Map")
local Pos = require("api.Pos")
local Rand = require("api.Rand")

local data = require("internal.data")
local field = require("game.field")

-- Functions for manipulating characters.
local Chara = {}

function Chara.at(x, y, map)
   -- TODO: ILocation instead of map
   map = map or field.map

   if not map:is_in_bounds(x, y) then
      return nil
   end

   local objs = map:iter_type_at_pos("base.chara", x, y):filter(Chara.is_alive)

   assert(objs:length() <= 1, string.format("More than one live character on tile %d,%d", x, y))

   return objs:nth(1)
end

function Chara.is_player(c)
   return type(c) == "table" and field.player == c.uid
end

function Chara.player()
   return Map.current():get_object(field.player)
end

function Chara.set_player(uid_or_chara)
   local uid = uid_or_chara
   if type(uid_or_chara) == "table" then
      uid = uid_or_chara.uid
   end

   assert(type(uid) == "number")
   assert(Map.current():has_object(uid))
   field.player = uid

   local c = Chara.player()

   c.faction = "base.friendly"

   c.max_hp = 500
   c.max_mp = 100

   c:reset_all_reactions()
   c:heal_to_max()
   c:refresh()
end

function Chara.is_alive(c)
   -- Persist based on character type.
   return type(c) == "table" and c.state == "Alive"
end

function Chara.create(id, x, y, params, where)
   if x == nil then
      local player = Chara.player()
      if Chara.is_alive(player) then
         x = player.x
         y = player.y
      end
   end

   params = params or {}
   where = where or field.map

   if params.ownerless then
      where = nil
   else
      where = where or field.map
   end

   if not class.is_an(ILocation, where) and not params.ownerless then
      return nil
   end

   if where and where:is_positional() then
      if not where:is_in_bounds(x, y) then
         return nil
      end

      if Chara.at(x, y, where) ~= nil then
         return nil
      end
   end

   local gen_params = {
      no_build = params.no_build
   }
   local chara = MapObject.generate_from("base.chara", id, gen_params)

   if where then
      chara = where:take_object(chara, x, y)
   end

   if chara and not params.no_build then
      chara:refresh()
   end

   return chara
end

local function iter(a, i)
   if i > #a.uids then
      return nil
   end
   if a.map == nil then
      return nil
   end

   local d = a.map:get_object_of_type("base.chara", a.uids[i])
   i = i + 1

   return i, d
end

function Chara.iter_allies()
   return fun.wrap(iter, {map = field.map, uids = field.allies}, 1)
end

function Chara.find(id, kind)
   if kind == "ally" then
      return Chara.iter_allies():filter(function(i) return i._id == id end):nth(1)
   end

   return nil
end

return Chara
