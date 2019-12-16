--- Functions for manipulating items.
--- @module Item
local ILocation = require("api.ILocation")
local Map = require("api.Map")
local MapObject = require("api.MapObject")
local InventoryContext = require("api.gui.menu.InventoryContext")

local data = require("internal.data")
local field = require("game.field")

local Item = {}

function Item.at(x, y, map)
   map = map or field.map

   if not map:is_in_bounds(x, y) then
      return fun.iter({})
   end

   return map:iter_type_at_pos("base.item", x, y):filter(Item.is_alive)
end

--- @tparam[opt] InstancedMap map
--- @treturn Iterator(IItem)
function Item.iter(map)
   return (map or field.map):iter_items()
end

--- @tparam[opt] InstancedMap map
--- @treturn Iterator(IItem)
function Item.iter_ground(map)
   map = map or field.map
   local is_on_ground = function(i)
      return i:current_map() ~= nil
   end
   return Item.iter(map):filter(is_on_ground)
end

--- Returns true if this item has any amount remaining and is
--- contained in the current map. Will also handle nil values.
---
--- @tparam[opt] IItem item
--- @tparam[opt] InstancedMap map Map to check for existence in; defaults to current
function Item.is_alive(item, map)
   map = map or Map.current()
   if type(item) ~= "table" or item.amount <= 0 then
      return false
   end

   local their_map = item:current_map()
   if not their_map then
      return false
   end

   return their_map.uid == map.uid
end

--- Creates a new item. Returns the item on success, or nil if
--- creation failed.
---
--- @tparam id:base.item id
--- @tparam[opt] int x Defaults to a random free position on the map.
--- @tparam[opt] int y
--- @tparam[opt] table params Extra parameters.
---  - ownerless (bool): Do not attach the item to a map. If true, then `where` is ignored.
---  - no_build (bool): Do not call :build() on the object.
---  - no_stack (bool): Do not attempt to stack this item with others like it on the same tile.
---  - copy (table): A dict of fields to copy to the newly created item. Overrides fix_level, quality, and amount.
---  - amount (int): Amount of the item to create.
---  - fix_level (int): Fix level of the item.
---  - quality (int): Quality of the item (1-6).
--- @tparam[opt] ILocation map Where to instantiate this item.
---   Defaults to the current map.
--- @treturn[opt] IItem
--- @treturn[opt] string error
function Item.create(id, x, y, params, where)
   params = params or {}

   if params.ownerless then
      where = nil
   else
      where = where or field.map
   end

   if not class.is_an(ILocation, where) and not params.ownerless then
      return nil, "invalid location"
   end

   if where and where:is_positional() and params.approximate_pos then
      x, y = Map.find_free_position(x, y, {only_map=true, allow_stacking=true}, where)
      if not x then
         return nil, "out of bounds"
      end
   end

   local copy = params.copy or {}
   copy.fix_level = params.fix_level or nil
   copy.quality = params.quality or nil
   copy.amount = math.max(1, params.amount or 1)

   local gen_params = {
      no_build = params.no_build,
      copy = copy
   }
   local item = MapObject.generate_from("base.item", id, gen_params)

   if where then
      item = where:take_object(item, x, y)

      if not item then
         return nil, "location failed to receive object"
      end
   end

   item:emit("base.on_generate")

   if not params.no_stack then
      item:stack()
   end

   item:refresh()

   return item
end

--- Causes the same behavior as selecting the given item in a given
--- inventory context. The item must be contained in the inventory's
--- sources and be selectable.
---
--- @tparam IItem item
--- @tparam string operation
--- @tparam[opt] table params
--- @treturn[opt] IItem non-nil on success
--- @treturn[opt] string error
function Item.activate_shortcut(item, operation, params)
   if type(operation) ~= "string" then
      error(string.format("Invalid inventory operation: %s", operation))
   end

   if not Item.is_alive(item) then
      return nil, "item_dead"
   end

   local proto = data["elona_sys.inventory_proto"]:ensure(operation)

   params = params or {}
   params.chara = params.chara or item:get_owning_chara() or nil
   params.map = (params.chara and params.chara:current_map()) or nil

   local ctxt = InventoryContext:new(proto, params)

   -- TODO: include specific reason, like "is_in_world_map"
   if not ctxt:filter(item) then
      return nil, "filtered_out"
   end

   if ctxt:after_filter({item}) then
      return nil, "after_filter_failed"
   end

   if not ctxt:can_select(item) then
      return nil, "cannot_select"
   end

   return ctxt:on_select(item)
end

return Item
