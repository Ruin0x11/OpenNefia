local MapObject = require("api.MapObject")
local ILocation = require("api.ILocation")
local Map = require("api.Map")
local Event = require("api.Event")

local field = require("game.field")
local save = require("internal.global.save")

-- Functions for manipulating characters.
local Chara = {}

function Chara.at(x, y, map)
   -- TODO: ILocation instead of map
   map = map or field.map

   if not map:is_in_bounds(x, y) then
      return nil
   end

   local objs = map:iter_type_at_pos("base.chara", x, y):filter(function(c) return Chara.is_alive(c, map) end)

   assert(objs:length() <= 1, string.format("More than one live character on tile %d,%d", x, y))

   return objs:nth(1)
end

function Chara.is_player(c)
   return type(c) == "table" and field.player == c.uid
end

function Chara.player()
   local map = Map.current()
   return map and map:get_object(field.player)
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
   c.max_stamina = 10000

   c:reset_all_reactions()
   c:heal_to_max()
   c:refresh()
end

function Chara.is_alive(c, map)
   map = map or Map.current()

   if type(c) ~= "table" or c.state ~= "Alive" then
      return false
   end

   local their_map = c:current_map()
   if not their_map then
      return false
   end

   return their_map.uid == map.uid
end

local hook_generate_chara =
   Event.define_hook("generate_chara",
                     "Overrides the behavior for character generation.")

function Chara.create(id, x, y, params, where)
   params = params or {}
   params.level = params.level or 1
   params.quality = params.quality or 0
   where = where or field.map

   if params.ownerless then
      where = nil
   else
      where = where or field.map
   end

   if not class.is_an(ILocation, where) and not params.ownerless then
      return nil
   end

   local copy = params.copy or {}
   copy.level = params.level
   copy.quality = params.quality

   local gen_params = {
      no_build = params.no_build,
      copy = copy
   }

   params.id = id
   params.x = x
   params.y = y
   params.where = where
   params.gen_params = gen_params

   local chara = hook_generate_chara(params)

   if chara == nil then
      chara = MapObject.generate_from("base.chara", id, gen_params)
   end

   if where then
      -- TODO: may want to return status
      Map.try_place_chara(chara, x, y, where)
   end

   if chara and not params.no_build then
      chara:refresh()
   end

   chara:emit("base.on_chara_generated")

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
   return fun.wrap(iter, {map = field.map, uids = save.base.allies}, 1)
end

function Chara.find(id, kind)
   if kind == "ally" then
      return Chara.iter_allies():filter(function(i) return i._id == id end):nth(1)
   end

   return nil
end

return Chara
