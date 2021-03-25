local Event = require("api.Event")
local Gui = require("api.Gui")
local AllyHpBarWidget = require("mod.omake_overhaul.api.gui.AllyHpBarWidget")

local function add_widgets()
   Gui.add_hud_widget(AllyHpBarWidget:new(), "omake_overhaul.ally_hp_bar")
end
Event.register("base.before_engine_init", "Add omake_overhaul widgets", add_widgets)

local function setup_widgets()
   Gui.hud_widget("omake_overhaul.ally_hp_bar"):set_enabled(config.omake_overhaul.show_ally_hp_bar)
   Gui.refresh_hud(true)
end
Event.register("base.on_game_initialize", "Setup omake_overhaul widgets", setup_widgets)

data:add_multi(
   "base.config_option",
   {
      { _id = "extra_ally_skill_exp_gain", type = "boolean", default = false },
      {
         _id = "show_ally_hp_bar",
         type = "enum",
         choices = { "hidden", "left_side", "right_side" },
         default = "hidden",
         on_changed = setup_widgets
      },
   }
)
