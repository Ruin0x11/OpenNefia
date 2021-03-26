local Autopickup = require("mod.autopickup.api.Autopickup")

require("mod.autopickup.data.init")
require("mod.autopickup.event.init")

data:add_multi("base.config_option",
               {
                  {
                     _id = "enabled",
                     type = "boolean",
                     default = false
                  },
                  {
                     _id = "rules",
                     type = "extra_config_options.text",
                     default = "",

                     on_changed = function()
                        Autopickup.clear_cache()
                     end
                  },
                  {
                     _id = "sound_on_destroy",
                     type = "boolean",
                     default = true
                  },
               })

data:add {
   _type = "base.config_menu",
   _id = "menu",

   items = {
      "autopickup.enabled",
      "autopickup.rules",
      "autopickup.sound_on_destroy"
   }
}

-- TODO immutable data edits
local menu = { _type = "base.config_menu", _id = "autopickup.menu" }
table.insert(data["base.config_menu"]:ensure("base.default").items, menu)
