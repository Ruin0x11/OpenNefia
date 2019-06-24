local ILocation = require("api.ILocation")
local Chara = require("api.Chara")
local Map = require("api.Map")
local MapObject = require("api.MapObject")

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

function Item.stack(item)
   -- TODO: have to find where item is first.
   return item
end

function Item.create(id, x, y, amount, params, where)
   if x == nil then
      local player = Chara.player()
      if Chara.is_alive(player) then
         x = player.x
         y = player.y
      end
   end

   amount = amount or 1
   params = params or {}

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
         item = Item.stack(item)
         assert(item)
      end

      item:refresh()
   end

   return item
end

return Item
