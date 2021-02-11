local config = {
   _id = "default",

   name = "My Config",
   items = {
      {
         id = "option_boolean", -- my_mod.option_boolean == true
         name = "Boolean",
         type = "boolean",

         default = false
      },
      {
         id = "option_enum",
         name = "Enum",
         type = "enum",

         options = { "a", "b", "c" },
         default = "b"
      },
      {
         id = "inner_menu",
         name = "Menu",
         type = "menu",

         menu_id = "my_mod.custom_menu"
      }
   }
}

local item = {
   _type = "config_option",
   _id = "option_boolean",
   type = "boolean",

   default = false
}
local config = {
   _type = "config_menu",
   _id = "my_mod",

   name = "My config",
   items = {
      "my_mod.option_boolean"
   }
}
Config.register_top_level_menu("my_mod.my_mod")

local menu = {
   _type = "config_menu",
   _id = "custom_menu",

   impl = "mod.my_mod.api.ui.CustomConfigMenu"
}

-- Local Variables:
-- open-nefia-always-send-to-repl: t
-- End:
