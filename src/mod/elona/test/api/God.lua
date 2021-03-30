local Compat = require("mod.elona_sys.api.Compat")
local Item = require("api.Item")
local Assert = require("api.test.Assert")
local God = require("mod.elona.api.God")

local VANILLA_OFFERINGS = {
   [788] = { "elona.lulwy" },
   [618] = { "elona.ehekatl" },
   [554] = { "elona.kumiromi" },
   [553] = { "elona.kumiromi" },
   [512] = { "elona.mani" },
   [496] = { "elona.mani" },
   [495] = { "elona.mani" },
   [494] = { "elona.mani" },
   [492] = { "elona.mani" },
   [491] = { "elona.mani" },
   [490] = { "elona.mani" },
   [489] = { "elona.mani" },
   [488] = { "elona.mani" },
   [487] = { "elona.mani" },
   [486] = { "elona.mani" },
   [482] = { "elona.lulwy" },
   [421] = { "elona.kumiromi" },
   [420] = { "elona.kumiromi" },
   [419] = { "elona.kumiromi" },
   [418] = { "elona.kumiromi" },
   [417] = { "elona.kumiromi" },
   [354] = { "elona.ehekatl" },
   [353] = { "elona.ehekatl" },
   [352] = { "elona.ehekatl" },
   [351] = { "elona.ehekatl" },
   [350] = { "elona.ehekatl" },
   [349] = { "elona.ehekatl" },
   [348] = { "elona.ehekatl" },
   [347] = { "elona.ehekatl" },
   [346] = { "elona.ehekatl" },
   [345] = { "elona.ehekatl" },
   [261] = { "elona.ehekatl" },
   [231] = { "elona.mani" },
   [230] = { "elona.lulwy" },
   [229] = { "elona.itzpalt" },
   [212] = { "elona.itzpalt" },
   [204] = { "elona.mani", "elona.lulwy", "elona.itzpalt", "elona.ehekatl", "elona.opatos", "elona.jure", "elona.kumiromi" },
   [201] = { "elona.kumiromi" },
   [200] = { "elona.kumiromi" },
   [199] = { "elona.kumiromi" },
   [198] = { "elona.kumiromi" },
   [193] = { "elona.kumiromi" },
   [190] = { "elona.kumiromi" },
   [188] = { "elona.kumiromi" },
   [187] = { "elona.kumiromi" },
   [186] = { "elona.kumiromi" },
   [185] = { "elona.kumiromi" },
   [179] = { "elona.kumiromi" },
   [60] = { "elona.mani" },
   [58] = { "elona.lulwy" },
   [44] = { "elona.jure", "elona.opatos" },
   [42] = { "elona.jure", "elona.opatos" },
   [41] = { "elona.jure", "elona.opatos" },
   [40] = { "elona.jure", "elona.opatos" },
   [39] = { "elona.jure", "elona.opatos" },
   [38] = { "elona.jure", "elona.opatos" },
   [37] = { "elona.jure", "elona.opatos" },
   [36] = { "elona.jure", "elona.opatos" },
   [35] = { "elona.jure", "elona.opatos" },
}

function test_God_can_offer_item_to__vanilla()
   local seen = table.set {}
   for elona_id, gods in pairs(VANILLA_OFFERINGS) do
      local item_id = assert(Compat.convert_122_id("base.item", elona_id))
      local item = assert(Item.create(item_id, nil, nil, {ownerless=true}))
      seen[item._id] = true
      gods = table.set(gods)
      for _, god in data["elona.god"]:iter() do
         local expected = not not gods[god._id]
         local actual = God.can_offer_item_to(god._id, item)
         if expected ~= actual then
            Assert.fail("Item %s should be offerable to %s: %s, but got %s", item._id, god._id, expected, actual)
         end
      end
   end

   local filter = function(item)
      return item._id:match("^elona%.") and not seen[item._id]
   end

   for _, item_proto in data["base.item"]:iter():filter(filter) do
      local item = assert(Item.create(item_proto._id, nil, nil, {ownerless=true}))
      for _, god in data["elona.god"]:iter() do
         local actual = God.can_offer_item_to(god._id, item)
         if God.can_offer_item_to(god._id, item) ~= false then
            Assert.fail("Item %s should not be offerable to %s, but got %s", item._id, god._id, actual)
         end
      end
   end
end
