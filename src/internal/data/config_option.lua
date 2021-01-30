local data = require("internal.data")

data:add_multi(
   "base.config_option",
   {
      {
         _id = "enable_music",

         type = "boolean",
         default = true
      },
      {
         _id = "screen_sync",

         type = "integer",
         default = 6
      },
      {
         _id = "anim_wait",

         type = "number",
         default = 40
      },
      {
         _id = "auto_turn_speed",

         type = "enum",
         choices = { "normal", "high", "highest" },
         default = "normal"
      },
      {
         _id = "language",

         type = "data_id",
         data_type = "base.language",
         default = "base.english"
      },
      {
         _id = "keybinds",

         type = "table",
         default = {}
      },
      {
         _id = "positional_audio",

         type = "boolean",
         default = true
      },
      {
         _id = "show_charamake_extras",

         type = "boolean",
         default = true
      },
      {
         _id = "quickstart_scenario",

         type = "data_id",
         data_type = "base.scenario",
         default = "test_room.test_room"
      },
      {
         _id = "default_font",

         type = "string",
         default = "kochi-gothic-subst.ttf"
      },
      {
         _id = "autosave",

         type = "boolean",
         default = false
      },
      {
         _id = "skip_scene_playback",

         type = "boolean",
         default = true
      },
      {
         _id = "quickstart_on_startup",

         type = "boolean",
         default = false
      },
      {
         _id = "_save_id",

         type = "string",
         optional = true,
         default = nil
      },
      {
         _id = "themes",

         type = "table",
         default = {}
      },
   }
)


data:add_multi(
   "base.config_option",
   {
      {
         _id = "development_mode",

         type = "boolean",
         default = false
      },
      {
         _id = "debug_autoidentify",

         type = "boolean",
         default = false
      },
      {
         _id = "debug_no_weight",

         type = "boolean",
         default = false
      },
      {
         _id = "debug_default_seed",

         type = "integer",
         optional = true,
         default = nil
      },
      {
         _id = "debug_show_all_skills",

         type = "boolean",
         default = false
      },
      {
         _id = "debug_infinite_skill_points",

         type = "boolean",
         default = false
      }
   }
)
