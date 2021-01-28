local fs = require("util.fs")

local config = {}

config["base.language"] = "base.english"
config["base.keybinds"] = {}
config["base.play_music"] = false
config["base.anim_wait"] = 40 * 0.5
config["base.auto_turn_speed"] = "highest"
config["base.screen_sync"] = 6
config["base.positional_audio"] = false
config["base.show_charamake_extras"] = false
config["base.quickstart_scenario"] = "test_room.test_room"
config["base.default_font"] = "kochi-gothic-subst.ttf"
if fs.is_file("data/font/MS-Gothic.ttf") then
   config["base.default_font"] = "MS-Gothic.ttf"
end
config["base.autosave"] = false
config["base.skip_scene_playback"] = false

config["base.quickstart_on_startup"] = false

-- private variables
config["base._save_id"] = nil
config["base._basic_attributes"] = {
   "elona.stat_strength",
   "elona.stat_constitution",
   "elona.stat_dexterity",
   "elona.stat_perception",
   "elona.stat_learning",
   "elona.stat_will",
   "elona.stat_magic",
   "elona.stat_charisma",
}

config["base.themes"] = {}

config["base.debug_autoidentify"] = false
config["base.debug_no_weight"] = false
config["base.debug_default_seed"] = nil
config["base.debug_show_all_skills"] = false
config["base.debug_infinite_skill_points"] = false
config["base.development_mode"] = false
config["base.enable_native_libs"] = true

-- XXX: strict loading order should always be enforced, but doing so requires
-- some refactoring.
config["base.disable_strict_load_order"] = true

-- Don't overwrite existing values in the current config.
config.on_hotload = function(old, new)
   for k, v in pairs(new) do
      if old[k] == nil then
         old[k] = v
      end
   end
end

return config
