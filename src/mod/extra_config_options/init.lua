require("mod.extra_config_options.data.init")

data:add {
   _type = "base.config_option",
   _id = "test_option_color",

   type = "extra_config_options.color",
   default = {128, 128, 128}
}

data:add {
   _type = "base.config_option",
   _id = "test_option_text",

   type = "extra_config_options.text",
   default = [[
test option

text
]]
}

data:add {
   _type = "base.config_menu",
   _id = "menu",

   items = {
      "extra_config_options.test_option_color",
      "extra_config_options.test_option_text"
   }
}

-- TODO immutable data edits
local menu = { _type = "base.config_menu", _id = "extra_config_options.menu" }
table.insert(data["base.config_menu"]:ensure("base.default").items, menu)
