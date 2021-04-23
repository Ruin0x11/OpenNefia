local Effect = require("mod.elona.api.Effect")
local Enum = require("api.Enum")
local Item = require("api.Item")
local utils = require("mod.test_room.data.map_archetype.utils")
local InventoryContext = require("api.gui.menu.InventoryContext")
local IItemWell = require("mod.elona.api.aspect.IItemWell")

local magic_items = {
   _id = "magic_items"
}

local function create_magic_items(x, y, width, map)
   local categories = table.set {
      "elona.spellbook",
      "elona.rod",
      "elona.drink",
      "elona.scroll",
   }
   local filter = function(i)
      for _, cat in ipairs(i.categories or {}) do
         if categories[cat] then
            return true
         end
      end
      return false
   end

   local create = function(i)
      local item = Item.create(i._id, nil, nil, {}, map)
      Effect.identify_item(item, Enum.IdentifyState.Full)
      return item
   end

   local items = data["base.item"]:iter():filter(filter):map(create)
      :filter(fun.op.truth)
      :into_sorted(InventoryContext.default_sort):to_list()

   return utils.roundup(items, x, y, width)
end

local function create_wells(x, y, width, map)
   local filter = function(i)
      return i._ext and i._ext[IItemWell]
   end

   local create = function(i)
      local item = Item.create(i._id, nil, nil, {aspects={[IItemWell]={water_amount=1000,dryness_amount=-1000}}}, map)
      Effect.identify_item(item, Enum.IdentifyState.Full)
      return item
   end

   local items = data["base.item"]:iter():filter(filter):map(create)
      :filter(fun.op.truth)
      :into_sorted(InventoryContext.default_sort):to_list()

   return utils.roundup(items, x, y, width)
end

function magic_items.on_generate_map(area, floor)
   local map = utils.create_map(20, 24)
   utils.create_stairs(2, 2, area, map)
   utils.create_sandbag(4, 2, map)

   local x, y = 2, 4
   x, y = create_magic_items(x, y, 16, map)
   x, y = create_wells(x, y, 16, map)

   return map
end

return magic_items
