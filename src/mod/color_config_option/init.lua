require("mod.color_config_option.data.init")

data:add {
   _type = "base.config_option",
   _id = "test_option",

   type = "color_config_option.color",
   default = {128, 128, 128}
}

data:add {
   _type = "base.config_menu",
   _id = "menu",

   items = {
      "color_config_option.test_option"
   }
}

local menu = { _type = "base.config_menu", _id = "color_config_option.menu" }
table.insert(data["base.config_menu"]:ensure("base.default").items, menu)
