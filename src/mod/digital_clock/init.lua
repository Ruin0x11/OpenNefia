require ("mod.digital_clock.data.asset")

local Event = require("api.Event")
local Gui = require("api.Gui")
local UiDigitalClock = require("mod.digital_clock.api.gui.UiDigitalClock")

data:add_multi(
   "base.config_option",
   {
      { _id = "enabled", type = "boolean", default = true },
   }
)

local function add_digital_clock()
   Gui.add_hud_widget(UiDigitalClock:new(), "digital_clock.digital_clock")
end

Event.register("base.before_engine_init", "Add digital clock", add_digital_clock)

local function setup_digital_clock()
   local enable = config.digital_clock.enabled
   Gui.hud_widget("hud_clock"):set_enabled(not enable)
   Gui.hud_widget("digital_clock.digital_clock"):set_enabled(enable)
end

Event.register("base.on_game_initialize", "Setup digital clock", setup_digital_clock)
