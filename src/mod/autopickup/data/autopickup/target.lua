local ElonaItem = require("mod.elona.api.ElonaItem")

data:add_type {
   name = "target",
   fields = {
      {
         name = "match",
         type = types.callback({"item", types.map_object("base.item")}, types.boolean)
      }
   }
}

data:add {
   _type = "autopickup.target",
   _id = "item",

   match = function(item)
      return true
   end
}

data:add {
   _type = "autopickup.target",
   _id = "equipment",

   match = function(item)
      return ElonaItem.is_equipment(item)
   end
}

local function add_category_target(_id, category)
   data:add {
      _type = "autopickup.target",
      _id = _id,

      match = function(item)
         return item:has_category(category)
      end
   }
end

-- TODO extend item_type data entries with matcher data for autopick
add_category_target("melee_weapon", "elona.equip_melee")
add_category_target("helm", "elona.equip_head")
add_category_target("shield", "elona.equip_shield")
add_category_target("armor", "elona.equip_body")
add_category_target("boots", "elona.equip_leg")
add_category_target("belt", "elona.equip_cloak")
add_category_target("cloak", "elona.equip_back")
add_category_target("gloves", "elona.equip_wrist")
add_category_target("ranged_weapon", "elona.equip_ranged")
add_category_target("ammo", "elona.equip_ammo")
add_category_target("ring", "elona.equip_ring")
add_category_target("necklace", "elona.equip_neck")
add_category_target("potion", "elona.drink")
add_category_target("scroll", "elona.scroll")
add_category_target("spellbook", "elona.spellbook")
add_category_target("book", "elona.book")
add_category_target("rod", "elona.rod")
add_category_target("food", "elona.food")
add_category_target("tool", "elona.misc_item")
add_category_target("furniture", "elona.furniture")
add_category_target("well", "elona.furniture_well")
add_category_target("altar", "elona.furniture_altar")
add_category_target("remains", "elona.remains")
add_category_target("junk", "elona.junk")
add_category_target("gold_piece", "elona.gold")
add_category_target("platinum_coin", "elona.platinum")
add_category_target("chest", "elona.container")
add_category_target("ore", "elona.ore")
add_category_target("tree", "elona.tree")
add_category_target("travelers_food", "elona.cargo_food")
add_category_target("cargo", "elona.cargo")
