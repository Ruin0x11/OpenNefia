local Event = require("api.Event")
local Gui = require("api.Gui")
local UiSkillTrackerEx = require("mod.skill_tracker_ex.api.gui.UiSkillTrackerEx")
local Chara = require("api.Chara")

local function setup_skill_tracker_ex(enable)
   save.base.tracked_skill_ids = table.set {
      "elona.bow",
      "elona.evasion",
      "elona.eye_of_mind",
      "elona.spell_crystal_spear",
      "elona.tactics",
      "elona.literacy",
      "elona.memorization",
      "elona.stat_learning",
   }

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

local function log_skill_exp_gain(chara, params)
   if not chara:is_player() then
      return
   end

   local holder = Gui.hud_widget("skill_tracker_ex.skill_tracker_ex")

   if holder then
      holder:widget():on_gain_skill_exp(params.skill_id, params.base_exp_amount, params.actual_exp_amount)
   end
end

Event.register("elona_sys.on_gain_skill_exp", "Log skill exp gain", log_skill_exp_gain)

data:add_multi(
   "base.config_option",
   {
      { _id = "enabled", type = "boolean", default = false, on_changed = setup_skill_tracker_ex },
   }
)
