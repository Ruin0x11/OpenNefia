data:add_multi(
   "base.config_option",
   {
      {
         _id = "enabled",
         type = "boolean",
         default = true
      },
      {
         _id = "position",
         type = "enum",
         choices = { "left", "right" },
         default = "left"
      },
   }
)

data:add {
   _type = "base.config_menu",
   _id = "menu",

   items = {
      "weight_graph.enabled",
      "weight_graph.default_font_size",
   }
}

-- TODO immutable data edits
local menu = { _type = "base.config_menu", _id = "chat_bubbles.menu" }
table.insert(data["base.config_menu"]:ensure("base.default").items, menu)
