data:add_multi(
   "base.config_option",
   {
      {
         _id = "show_weight_graph",
         type = "enum",
         choices = { "disabled", "left", "right" },
         default = "left"
      },
   }
)

data:add {
   _type = "base.config_menu",
   _id = "menu",

   items = {
      "weight_graph.show_weight_graph",
   }
}

-- TODO immutable data edits
local menu = { _type = "base.config_menu", _id = "weight_graph.menu" }
table.insert(data["base.config_menu"]:ensure("base.default").items, menu)
