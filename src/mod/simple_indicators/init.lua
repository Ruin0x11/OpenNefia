local Event = require("api.Event")
local Gui = require("api.Gui")
local UiSimpleIndicatorsWidget = require("mod.simple_indicators.api.gui.UiSimpleIndicatorsWidget")
local SimpleIndicators = require("mod.simple_indicators.api.SimpleIndicators")

require("mod.simple_indicators.data.init")

local function add_indicators_widget()
   Gui.add_hud_widget(UiSimpleIndicatorsWidget:new(), "simple_indicators.simple_indicators")
end

Event.register("base.before_engine_init", "Add indicators widget", add_indicators_widget)

local function setup_indicators_widget()
   local enable = config.simple_indicators.enabled
   Gui.hud_widget("simple_indicators.simple_indicators"):set_enabled(enable)
end

Event.register("base.on_game_initialize", "Setup indicators widget", setup_indicators_widget)

local function setup_stamina_indicator(enabled)
   SimpleIndicators.set_enabled("simple_indicators.stamina", enabled)
end

data:add_multi(
   "base.config_option",
   {
      { _id = "enabled", type = "boolean", default = true, on_changed = setup_indicators_widget },
      { _id = "show_stamina", type = "boolean", default = true, on_changed = setup_stamina_indicator },
   }
)
