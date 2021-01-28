local Event = require("api.Event")
local Gui = require("api.Gui")
local UiStaminaWidget = require("mod.stamina_widget.api.ui.UiStaminaWidget")

config["stamina_widget.enabled"] = true

local function add_stamina_widget()
   Gui.add_hud_widget(UiStaminaWidget:new(), "stamina_widget.stamina_widget")
end

Event.register("base.before_engine_init", "Add stamina widget", add_stamina_widget)

local function setup_stamina_widget()
   local enable = config["stamina_widget.enabled"]
   Gui.hud_widget("stamina_widget.stamina_widget"):set_enabled(enable)
end

Event.register("base.on_game_initialize", "Setup stamina widget", setup_stamina_widget)
