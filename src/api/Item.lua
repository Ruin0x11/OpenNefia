local ILocation = require("api.ILocation")
local Chara = require("api.Chara")
local Map = require("api.Map")
local MapObject = require("api.MapObject")
local InventoryContext = require("api.gui.menu.InventoryContext")

local data = require("internal.data")
local field = require("game.field")

-- Functions for manipulating items.
local Item = {}

function Item.at(x, y, map)
   map = map or field.map

   if not Map.is_in_bounds(x, y, map) then
      return {}
   end

   return map:get_pool("base.item"):objects_at_pos(x, y):filter(Item.is_alive)
end

function Item.set_pos(i, x, y)
   if type(i) ~= "table" or not field:exists(i) then
      Log.warn("Item.set_pos: Not setting position of %s to %d,%d\n\t%s", tostring(i), x, y, debug.traceback(""))
      return false
   end

   if not Map.is_in_bounds(x, y) then
      return false
   end

   field.map:move_object(i, x, y)

   return true
end

function Item.is_alive(item)
   return type(item) == "table" and item.amount > 0
end

function Item.almost_equals(a, b)
   local comparators = {
      "weight",
      "image"
   }

   for _, field in ipairs(comparators) do
      if a[field] ~= b[field] then
         return false
      end
   end

   return true
end

function Item.create(id, x, y, params, where)
   if x == nil then
      local player = Chara.player()
      if Chara.is_alive(player) then
         x = player.x
         y = player.y
      end
   end

   params = params or {}
   local amount = params.amount or 1

   where = where or field.map

   if not is_an(ILocation, where) then return nil end

   -- TODO: if where:is_positional()
   local InstancedMap = require("api.InstancedMap")
   if is_an(InstancedMap, where) then
      if not Map.is_in_bounds(x, y, where) then
         return nil
      end
   end

   local item = MapObject.generate_from("base.item", id)
   item.amount = amount

   item = where:take_object(item, x, y)

   if item then
      if not params.no_stack then
         -- item:stack()
      end

      item:refresh()
   end

   return item
end

--- Causes the same behavior as selecting the given item in its
--- owner's inventory. The item must be owned by a character and
--- selectable in the character's inventory.
-- @tparam IItem item
-- @tparam string operation
-- @tparam table params
-- @treturn[1][1] IItem
-- @treturn[2][1] nil
-- @treturn[2][2] string error kind
function Item.activate_shortcut(item, operation, params)
   if type(operation) ~= "string" then
      error(string.format("Invalid inventory operation: %s", operation))
   end

   local chara = item:get_owning_chara()

   if not chara then
      return nil, "not_owned"
   end

   if not Item.is_alive(item) then
      return nil, "item_dead"
   end

   local protos = require("api.gui.menu.InventoryProtos")
   local proto = protos[operation]
   if not proto then
      error("unknown context type " .. operation)
   end

   params = params or {}
   params.chara = chara
   params.map = chara:current_map()

   local ctxt = InventoryContext:new(proto, params)

   -- TODO: include specific reason, like "is_in_world_map"
   if not ctxt:filter(item) then
      return nil, "filtered_out"
   end

   if not ctxt:after_filter(item) then
      return nil, "after_filter_failed"
   end

   if not ctxt:can_select(item) then
      return nil, "cannot_select"
   end

   return ctxt:on_select(item)
end

return Item
