local Enum = require("api.Enum")
local light = require("mod.elona.data.item.light")

-- TODO: Some fields should not be stored on the prototype as
-- defaults, but instead copied on generation.

-- IMPORTANT: Fields like "on_throw", "on_drink", "on_use" and similar are tied
-- to event handlers that are dynamically generated in elona_sys.events. See the
-- "Connect item events" handler there for details.

local item =
   {
      {
         _id = "bug",
         elona_id = 0,
         image = "elona.item_worthless_fake_gold_bar",
         value = 1,
         weight = 1,
         fltselect = Enum.FltSelect.Sp,
         category = 99999999,
         subcategory = 99999999,
         coefficient = 100,
         categories = {
            "elona.bug",
            "elona.no_generate"
         },
         light = light.item,
         is_wishable = false
      },
   }

data:add_multi("base.item", item)

require("mod.elona.data.item.book")
require("mod.elona.data.item.cargo")
require("mod.elona.data.item.container")
require("mod.elona.data.item.currency")
require("mod.elona.data.item.equip")
require("mod.elona.data.item.fish")
require("mod.elona.data.item.food")
require("mod.elona.data.item.furniture")
require("mod.elona.data.item.junk")
require("mod.elona.data.item.ore")
require("mod.elona.data.item.potion")
require("mod.elona.data.item.remains")
require("mod.elona.data.item.remains")
require("mod.elona.data.item.rod")
require("mod.elona.data.item.scroll")
require("mod.elona.data.item.spellbook")
require("mod.elona.data.item.tool")
require("mod.elona.data.item.tree")
