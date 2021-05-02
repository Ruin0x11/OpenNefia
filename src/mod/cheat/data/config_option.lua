local Chara = require("api.Chara")
local Skill = require("mod.elona_sys.api.Skill")
local Event = require("api.Event")
local Const = require("api.Const")
local Gui = require("api.Gui")

data:add {
   _type = "base.config_option",
   _id = "easy_start",

   type = "boolean",
   default = false
}

local function easy_start()
   if not config.cheat.easy_start then
      return
   end

   local player = Chara.player()

   local levels = 100
   for _= 1, levels do
      Skill.gain_level(player)
      Skill.grow_primary_skills(player)
   end

   player:mod_base_skill_level("elona.stat_magic", 2000)
   player:mod_base_skill_level("elona.stat_mana", 2000)

   Skill.iter_attributes()
      :each(function(m)
            player:mod_base_skill_level(m._id, Const.MAX_SKILL_LEVEL, "set")
           end)

   Skill.iter_skills()
      :each(function(m)
            Skill.gain_skill(player, m._id, Const.MAX_SKILL_LEVEL, 1000)
           end)

   player.gold = 10000000
   player.platinum = 10000

   player:refresh()
   player:heal_to_max()
end
Event.register("base.on_new_game", "Option: cheat.easy_start", easy_start)

local function refresh_player()
   local player = Chara.player()
   if player then
      player:refresh()
      Gui.refresh_hud()
   end
end

data:add {
   _type = "base.config_option",
   _id = "max_attributes",

   type = "boolean",
   default = false,

   on_changed = refresh_player
}

local function max_attributes(chara)
   if not config.cheat.max_attributes then
      return
   end

   if not chara:is_player() then
      return
   end

   local max_skill = function(skill)
      chara:mod_skill_level(skill._id, Const.MAX_SKILL_LEVEL, "set")
   end
   Skill.iter_attributes():each(max_skill)
end
Event.register("base.on_refresh", "Option: cheat.max_attributes", max_attributes)

data:add {
   _type = "base.config_option",
   _id = "max_skills",

   type = "boolean",
   default = false,

   on_changed = refresh_player
}

local function max_skills(chara)
   if not config.cheat.max_skills then
      return
   end

   if not chara:is_player() then
      return
   end

   local max_skill = function(skill)
      chara:mod_skill_level(skill._id, Const.MAX_SKILL_LEVEL, "set")
   end
   Skill.iter_skills():each(max_skill)
end
Event.register("base.on_refresh", "Option: cheat.max_skills", max_skills)

data:add {
   _type = "base.config_option",
   _id = "max_resistances",

   type = "boolean",
   default = false,

   on_changed = refresh_player
}

local function max_resistances(chara)
   if not config.cheat.max_resistances then
      return
   end

   if not chara:is_player() then
      return
   end

   local max_resist = function(element)
      chara:mod_resist_level(element._id, Const.MAX_SKILL_LEVEL, "set")
   end
   Skill.iter_resistances():each(max_resist)
end
Event.register("base.on_refresh", "Option: cheat.max_resistances", max_resistances)

--
-- Advice
--

data:add {
   _type = "base.config_option",
   _id = "show_stair_locations",

   type = "boolean",
   default = false
}

--
-- Config Menu
--

data:add {
   _type = "base.config_menu",
   _id = "menu",

   items = {
      "cheat.easy_start",
      "cheat.max_attributes",
      "cheat.max_skills",
      "cheat.max_resistances",
      "cheat.show_stair_locations",
   }
}

-- TODO immutable data edits
local menu = { _type = "base.config_menu", _id = "cheat.menu" }
table.insert(data["base.config_menu"]:ensure("base.default").items, menu)
