local Map = require("api.Map")

local data = require("internal.data")
local field = require("game.field")

-- Functions for manipulating items.
local Item = {}

function Item.at(x, y, map)
   map = map or field.map

   if not Map.is_in_bounds(x, y, map) then
      return {}
   end

   local objs = map:objects_at("base.item", x, y)

   local items = {}
   for _, id in ipairs(objs) do
      local v = map:get_object("base.item", id)
      if Item.is_alive(v) then
         items[#items+1] = v
      end
   end

   return items
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

function Item.delete(i, map)
   (map or field.map):remove_object(i)
end

function Item.is_alive(item)
   return type(item) == "table" and item.number > 0
end

local function init_item(item)
   -- TODO remove and place in schema as defaults

   item.inv = nil
   item.ownership = "none"

   item.curse_state = "cursed"
   item.identify_state = "completely"

   item.flags = {}

   -- item:send("base.on_item_create")
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

function Item.create(id, x, y, number, params, map)
   number = number or 1
   params = params or {}

   map = map or field.map

   if map == nil then return nil end

   if not Map.is_in_bounds(x, y, map) then
      return nil
   end

   local proto = data["base.item"][id]
   if proto == nil then return nil end

   assert(type(proto) == "table")

   local item = map:create_object(proto, x, y)

   -- TODO remove
   item.number = number
   init_item(item)

   if not params.no_stack then
      item = Item.stack(item)
   end

   return item
end

function Item.create_in(id, chara, number, params)
   -- WARNING: This should be generalized to create_in(chara),
   -- create_in(map), create_in(party)
   if not Chara.is_alive(chara) then
      return
   end

   local proto = data["base.item"][id]
   if proto == nil then return nil end

   assert(type(proto) == "table")

   local item = chara.inv:create_object(proto)
   if item == nil then
      return nil
   end

   -- TODO remove
   item.number = number
   init_item(item)

   if not params.no_stack then
      item = Item.stack(item)
   end

   return item
end

return Item
