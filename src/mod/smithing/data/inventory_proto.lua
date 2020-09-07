local Smithing = require("mod.smithing.api.Smithing")

data:add {
   _type = "elona_sys.inventory_proto",
   _id = "hammer_target",

   elona_id = 30,
   elona_sub_id = 0,

   sources = { "chara", "equipment" },
   params = { hammer = "table" },
   icon = nil,
   show_money = false,
   query_amount = false,
   window_title = "smithing.inventory_proto.forge",
   -- query_text = "ui.inv.title.target",

   filter = function(ctxt, item)
      return Smithing.can_smith_item(item, ctxt.hammer)
   end,

   on_select = function(ctxt, item, amount)
      return "inventory_continue"
   end
}

data:add {
   _type = "elona_sys.inventory_proto",
   _id = "hammer_weapon_material",

   elona_id = 30,
   elona_sub_id = 1,

   sources = { "chara", "equipment" },
   params = { hammer = "table" },
   icon = nil,
   show_money = false,
   query_amount = false,
   window_title = "smithing.inventory_proto.forge",
   -- query_text = "ui.inv.title.target",

   filter = function(ctxt, item)
      return Smithing.can_use_item_as_weapon_material(item, ctxt.hammer)
   end,

   on_select = function(ctxt, item, amount)
      return "inventory_continue"
   end
}
