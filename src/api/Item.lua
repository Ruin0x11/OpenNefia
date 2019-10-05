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
   if type(item) ~= "table" or item.amount <= 0 then
      return false
   end

   local map = item:current_map()
   if not map then
      return false
   end

   return map.uid == Map.current().uid
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

   if params.ownerless then
      where = nil
   else
      where = where or field.map
   end

   if not class.is_an(ILocation, where) and not params.ownerless then
      return nil, "invalid location"
   end

   if where and where:is_positional() then
      x, y = Map.find_free_position(x, y, {}, where)
      if not x then
         return nil
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

   if ctxt:after_filter({item}) then
      return nil, "after_filter_failed"
   end

   if not ctxt:can_select(item) then
      return nil, "cannot_select"
   end

   return ctxt:on_select(item)
end

return Item
