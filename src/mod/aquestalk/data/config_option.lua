data:add_multi(
   "base.config_option",
   {
      {
         _id = "enabled_chara_talk",
         type = "boolean",
         default = false
      },
      {
         _id = "enabled_dialog",
         type = "boolean",
         default = false
      },
      {
         _id = "enabled_scene",
         type = "enum",
         choices = { "disabled", "dialog", "dialog_and_text" },
         default = "disabled"
      },
      {
         _id = "default_bas",
         type = "enum",
         choices = { "f1e", "f2e", "m1e" },
         default = "f1e"
      },
      {
         _id = "default_spd",
         type = "integer",
         min_value = 50,
         max_value = 300,
         default = 100
      },
      {
         _id = "default_vol",
         type = "integer",
         min_value = 0,
         max_value = 300,
         default = 100
      },
      {
         _id = "default_pit",
         type = "integer",
         min_value = 20,
         max_value = 200,
         default = 100
      },
      {
         _id = "default_acc",
         type = "integer",
         min_value = 20,
         max_value = 200,
         default = 100
      },
      {
         _id = "default_lmd",
         type = "integer",
         min_value = 0,
         max_value = 200,
         default = 100
      },
      {
         _id = "default_fsc",
         type = "integer",
         min_value = 50,
         max_value = 200,
         default = 100
      },
   }
)

data:add {
   _type = "base.config_menu",
   _id = "menu",

   items = {
      "aquestalk.enabled_chara_talk",
      "aquestalk.enabled_dialog",
      "aquestalk.enabled_scene",
      "aquestalk.default_bas",
      "aquestalk.default_spd",
      "aquestalk.default_vol",
      "aquestalk.default_pit",
      "aquestalk.default_acc",
      "aquestalk.default_lmd",
      "aquestalk.default_fsc",
   }
}

-- TODO immutable data edits
local menu = { _type = "base.config_menu", _id = "aquestalk.menu" }
table.insert(data["base.config_menu"]:ensure("base.default").items, menu)
