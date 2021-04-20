local Gui = require("api.Gui")
local I18N = require("api.I18N")
local ChatBubble = require("mod.chat_bubbles.api.ChatBubble")

data:add_multi(
   "base.config_option",
   {
      {
         _id = "enabled",
         type = "boolean",
         default = true,

         on_changed = function(v)
            ChatBubble.clear()
         end
      },
      {
         _id = "max_display_time",
         type = "integer",
         -- >>>>>>>> oomSEST/src/config.hsp:2461 	cfg_txtpopspeed = 20 ...
         default = 20,
         -- <<<<<<<< oomSEST/src/config.hsp:2461 	cfg_txtpopspeed = 20 ..
         -- >>>>>>>> oomSEST/src/config.hsp:1994 				oomSEST_setOption cfg_txtpopspeed, 1, 50 ...
         min_value = 1,
         max_value = 50
         -- <<<<<<<< oomSEST/src/config.hsp:1994 				oomSEST_setOption cfg_txtpopspeed, 1, 50 ..
      },
      {
         _id = "shorten_dead_character_messages",
         type = "boolean",
         default = false
      },
      {
         _id = "default_text_color",
         type = "extra_config_options.color",
         default = {0, 0, 0},
      },
      {
         _id = "default_bubble_color",
         type = "extra_config_options.color",
         default = {255, 255, 255},
      },
      {
         _id = "default_font",
         type = "enum",
         -- TODO
         choices = { "(font)" },
         default = "(font)"
      },
      {
         _id = "default_font_size",
         type =  "integer",
         min_value = 8,
         max_value = 30,
      },
      {
         _id = "default_font_style",
         type = "enum",
         choices = { "normal", "bold", "italic", "underline", "strikethrough" },
         default = "normal",
         formatter = function(_id, value, index)
            return tostring(index) .. ":" .. I18N.get("chat_bubbles:ui.menu.config.options.font_style.choices." .. value)
         end
      },
   }
)
