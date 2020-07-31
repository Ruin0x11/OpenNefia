local Event = require("api.Event")
local Chara = require("api.Chara")
local Skill = require("mod.elona_sys.api.Skill")
local Item = require("api.Item")
local Env = require("api.Env")

local function level_up()
   local player = Chara.player()

   local levels = 100
   for _= 1, levels do
      Skill.gain_level(player)
      Skill.grow_primary_skills(player)
   end

   player:mod_base_skill_level("elona.stat_magic", 10)
   player:mod_base_skill_level("elona.stat_mana", 10000)

   data["base.skill"]:iter()
      :each(function(m)
            Skill.gain_skill(player, m._id, 100, 1)
           end)

   Skill.gain_skill(player, "elona.mining", 10000)

   player.gold = 10000000
   player.platinum = 10000

   player:heal_to_max()
end

Event.register("base.on_new_game", "Make player stronger", level_up)

local function enable_themes()
   local themes = {}

   if Env.is_mod_loaded("beautify") then
      themes[#themes+1] = "beautify.beautify"
   end

   if Env.is_mod_loaded("scrounged_theme") then
      themes[#themes+1] = "scrounged_theme.scrounged"
   end

   if Env.is_mod_loaded("scrounged_theme") then
      themes[#themes+1] = "scrounged_theme.scrounged"
   end

   if Env.is_mod_loaded("elonapack") then
      themes[#themes+1] = "elonapack.elonapack"
   end

   if Env.is_mod_loaded("ceri_items") then
      themes[#themes+1] = "ceri_items.ceri_items"
   end

   config["base.themes"] = themes
end

Event.register("base.before_engine_init", "Enable non-redistributable themes if available", enable_themes)
