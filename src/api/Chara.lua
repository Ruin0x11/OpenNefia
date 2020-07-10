--- Functions for manipulating characters.
--- @module Chara
local MapObject = require("api.MapObject")
local ILocation = require("api.ILocation")
local Event = require("api.Event")

local field = require("game.field")
local save = require("internal.global.save")

local Chara = {}

--- Returns the character at the given position, if any.
---
--- @tparam int x
--- @tparam int y
--- @tparam[opt] InstancedMap map
--- @treturn[opt] IChara
function Chara.at(x, y, map)
   -- TODO: ILocation instead of map
   map = map or field.map

   if not map:is_in_bounds(x, y) then
      return nil
   end

   for _, chara in map:iter_type_at_pos("base.chara", x, y) do
      if chara.state == "Alive" then
         return chara
      end
   end

   return nil
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

--- Iterates all characters in the map.
---
--- @tparam[opt] InstancedMap map
--- @treturn Iterator(IChara)
function Chara.iter_all(map)
   return (map or field.map):iter_charas()
end

--- Iterates all live characters in the map.
---
--- @tparam[opt] InstancedMap map
--- @treturn Iterator(IChara)
function Chara.iter(map)
   return Chara.iter_all(map):filter(Chara.is_alive)
end

--- Iterates the characters in the player's party, including the
--- player themselves.
---
--- @treturn Iterator(IChara)
function Chara.iter_party(map)
   local party = table.append({ save.base.player }, save.base.allies)
   return fun.wrap(iter, {map = map or field.map, uids = party}, 1)
end

--- Iterates the characters in the player's party, not including the
--- player.
---
--- @treturn Iterator(IChara)
function Chara.iter_allies(map)
   return fun.wrap(iter, {map = map or field.map, uids = save.base.allies}, 1)
end

--- Iterates all characters that are not allied (the player or a pet).
---
--- @treturn Iterator(IChara)
function Chara.iter_others(map)
   map = map or field.map
   return map:iter_charas():filter(function(c) return not c:is_allied() end)
end

--- Looks for a character with the given UID or base.chara ID in the
--- current map.
---
--- @tparam id:base.chara|uid id
--- @tparam string kind "all", "allies" or "others"
--- @tparam[opt] InstancedMap map
--- @treturn[opt] IChara
function Chara.find(id, kind, map)
   map = map or field.map

   kind = kind or "all"

   local iter
   if kind == "all" then
      iter = Chara.iter(map)
   elseif kind == "allies" then
      iter = Chara.iter_allies(map)
   elseif kind == "others" then
      iter = Chara.iter_others(map)
   else
      error(("invalid kind passed to Chara.find: %s"):format(kind))
   end

   local compare_field
   if type(id) == "number" then
      compare_field = "uid"
   else
      compare_field = "_id"
   end

   local pred = function(chara)
      return Chara.is_alive(chara, map) and chara[compare_field] == id
   end

   return iter:filter(pred):nth(1)
end

--- Returns true if this character is the current player.
---
--- @tparam IChara c
--- @treturn bool
function Chara.is_player(c)
   return type(c) == "table" and field.player.uid == c.uid
end

--- Obtains a reference to the current player. This can be nil if a
--- save hasn't been loaded yet.
---
--- @treturn[opt] IChara
function Chara.player()
   return field.player
end

--- Sets the current player to a different character. The character
--- must be contained in the current map.
---
--- @tparam IChara chara
function Chara.set_player(chara)
   assert(type(chara) == "table")

   if field.map then
      assert(field.map:has_object(chara.uid))
   end

   chara:emit("base.on_set_player", {previous_player=field.player})

   field.player = chara

   local c = Chara.player()

   c.faction = "base.friendly"

   c:reset_all_reactions()
   c:heal_to_max()
   c:refresh()

   field.hud:update_from_player(c)
end

--- Returns true if this character is in the alive state. Will also
--- handle nil values.
---
--- @tparam[opt] IChara c
--- @tparam[opt] InstancedMap map Map to check for existence in
function Chara.is_alive(c, map)
   if type(c) ~= "table" or c.state ~= "Alive" then
      return false
   end

   if map == nil then
      return true
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

--- Creates a new character. Returns the character on success, or nil
--- if creation failed.
---
--- @tparam id:base.chara id
--- @tparam[opt] int x Defaults to a random free position on the map.
--- @tparam[opt] int y
--- @tparam[opt] table params Extra parameters.
---   - ownerless (bool): Do not attach the character to a map. If true, then `where` is ignored.
---   - no_build (bool): Do not call :build() on the object.
---   - copy (table): A dict of fields to copy to the newly created item. Overrides level and quality.
---   - level (int): Level of the character.
---   - quality (int): Quality of the character (1-6).
--- @tparam[opt] ILocation map Where to instantiate this item. Defaults to the current map.
--- @treturn[opt] IChara
--- @treturn[opt] string error
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
      local Map = require("api.Map")
      Map.try_place_chara(chara, x, y, where)
   end

   if chara and not params.no_build then
      chara:refresh()
   end

   chara:instantiate()
   chara:emit("base.on_chara_generated")

   return chara
end

return Chara
