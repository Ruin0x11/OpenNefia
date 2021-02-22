local Smithing = require("mod.smithing.api.Smithing")

data:add {
   _type = "elona_sys.inventory_proto",
   _id = "hammer_target",

   elona_id = 30,
   elona_sub_id = 0,

   sources = { "chara", "equipment", "ground" },
   params = { hammer = "table" },
   icon = nil,
   show_money = false,
   query_amount = false,
   window_title = "smithing.inventory_proto.forge",
   -- query_text = "ui.inv.title.target",

   filter = function(ctxt, item)
      return Smithing.can_smith_item(item, ctxt.params.hammer, {})
   end
}

data:add {
   _type = "elona_sys.inventory_proto",
   _id = "hammer_weapon_material",

   elona_id = 30,
   elona_sub_id = 1,

   sources = { "chara", "equipment", "ground" },
   params = { hammer = "table", selected_items = "table" },
   icon = nil,
   show_money = false,
   query_amount = false,
   window_title = "smithing.inventory_proto.forge",
   -- query_text = "ui.inv.title.target",

   filter = function(ctxt, item)
      return Smithing.can_use_item_as_weapon_material(item, ctxt.params.hammer, ctxt.params.selected_items)
   end
}

data:add {
   _type = "elona_sys.inventory_proto",
   _id = "hammer_furniture_material",

   elona_id = 30,
   elona_sub_id = 3,

   sources = { "chara", "equipment", "ground" },
   params = { hammer = "table", selected_items = "table" },
   icon = nil,
   show_money = false,
   query_amount = false,
   window_title = "smithing.inventory_proto.forge",
   -- query_text = "ui.inv.title.target",

   filter = function(ctxt, item)
      return Smithing.can_use_item_as_furniture_material(item, ctxt.params.hammer, ctxt.params.selected_items)
   end
}
