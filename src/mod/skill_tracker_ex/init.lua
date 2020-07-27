local Event = require("api.Event")
local Gui = require("api.Gui")
local UiSkillTrackerEx = require("mod.skill_tracker_ex.api.gui.UiSkillTrackerEx")
local Chara = require("api.Chara")

config["skill_tracker_ex.enabled"] = true

local function setup_skill_tracker_ex()
   local enable = config["skill_tracker_ex.enabled"]
   Gui.hud_widget("hud_skill_tracker"):set_enabled(not enable)
   Gui.hud_widget("skill_tracker_ex.skill_tracker_ex"):set_enabled(enable)
   -- TODO hud
   Gui.hud_widget("skill_tracker_ex.skill_tracker_ex"):widget():set_data(Chara.player())
end

Event.register("base.on_game_initialize", "Setup enhanced skill tracker", setup_skill_tracker_ex)

local function add_skill_tracker_ex()
   Gui.add_hud_widget(UiSkillTrackerEx:new(), "skill_tracker_ex.skill_tracker_ex")
end

Event.register("base.before_engine_init", "Add enhanced skill tracker", add_skill_tracker_ex)
