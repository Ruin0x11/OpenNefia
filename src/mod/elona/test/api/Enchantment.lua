local Item = require("api.Item")
local Assert = require("api.test.Assert")
local Enchantment = require("mod.elona.api.Enchantment")
local TestUtil = require("api.test.TestUtil")

local function enchantless_item(id)
   TestUtil.set_player()

   local item = Item.create(id, nil, nil, {ownerless=true})

   local filter = function(enc) return enc.source ~= "item" end
   item:iter_enchantments():filter(filter):each(function(enc) assert(item:remove_enchantment(enc)) end)

   item:refresh()
   Assert.eq(0, item:iter_enchantments(item):length())
   return item
end


function test_elona_Enchantment_random_enc_id()
   local item = enchantless_item("elona.long_bow")

   Assert.is_truthy(Enchantment.random_enc_id(item, 99))
end
