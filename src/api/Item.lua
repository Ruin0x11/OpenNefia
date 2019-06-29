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

   if not map:is_in_bounds(x, y) then
      return fun.iter({})
   end

   return map:iter_type_at_pos("base.item", x, y):filter(Item.is_alive)
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

   if not is_an(ILocation, where) then
      if params.ownerless then
         where = nil
      else
         return nil
      end
   end

   if where then
      if where:is_positional() then
         if not where:is_in_bounds(x, y) then
            return nil
         end
      end
   end

   local item = MapObject.generate_from("base.item", id)
   item.amount = amount

   if where then
      item = where:take_object(item, x, y)
   end

   if item then
      if not params.no_stack then
         item:stack()
      end

      item:refresh()
   end

   return item
end

--- Causes the same behavior as selecting the given item in a given
--- inventory context. The item must be contained in the inventory's
--- sources and be selectable.
-- @tparam IItem item
-- @tparam string operation
-- @tparam[opt] table params
-- @treturn[1][1] IItem
-- @treturn[2][1] nil
-- @treturn[2][2] string error kind
function Item.activate_shortcut(item, operation, params)
   if type(operation) ~= "string" then
      error(string.format("Invalid inventory operation: %s", operation))
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
   params.chara = params.chara or item:get_owning_chara() or nil
   params.map = (params.chara and params.chara:current_map()) or nil

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
