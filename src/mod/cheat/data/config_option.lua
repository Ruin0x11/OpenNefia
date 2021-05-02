local Chara = require("api.Chara")
local Skill = require("mod.elona_sys.api.Skill")
local Event = require("api.Event")
local Const = require("api.Const")
local Gui = require("api.Gui")
local Advice = require("api.Advice")
local Enum = require("api.Enum")

data:add {
   _type = "base.config_option",
   _id = "easy_new_game",

   type = "boolean",
   default = false
}

local function easy_new_game()
   if not config.cheat.easy_new_game then
      return
   end

   local player = Chara.player()

   local levels = 100
   for _= 1, levels do
      Skill.gain_level(player)
      Skill.grow_primary_skills(player)
   end

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
Event.register("base.on_new_game", "Cheat: config.cheat.easy_new_game", easy_new_game)

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
Event.register("base.on_refresh", "Cheat: config.cheat.max_attributes", max_attributes)


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
Event.register("base.on_refresh", "Cheat: config.cheat.max_skills", max_skills)


data:add {
   _type = "base.config_option",
   _id = "max_spells",

   type = "boolean",
   default = false,

   on_changed = refresh_player
}

local function max_spells(chara)
   if not config.cheat.max_spells then
      return
   end

   if not chara:is_player() then
      return
   end

   local max_skill = function(skill)
      chara:mod_skill_level(skill._id, Const.MAX_SKILL_LEVEL, "set")
   end
   Skill.iter_spells():each(max_skill)
end
Event.register("base.on_refresh", "Cheat: config.cheat.max_spells", max_spells)


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
Event.register("base.on_refresh", "Cheat: config.cheat.max_resistances", max_resistances)


data:add {
   _type = "base.config_option",
   _id = "invincibility",

   type = "boolean",
   default = false
}

local function invincibility(chara, params, result)
   if not config.cheat.invincibility then
      return
   end

   -- >>>>>>>> shade2/chara_func.hsp:1476 		if dbg_hpAlwaysFull@:cHP(tc)=cMHP(tc) ...
   if chara:is_player() then
      chara.hp = chara:calc("max_hp")
   end
   -- <<<<<<<< shade2/chara_func.hsp:1476 		if dbg_hpAlwaysFull@:cHP(tc)=cMHP(tc) ..

   return result
end
Event.register("base.after_chara_damaged", "Cheat: config.cheat.invincibility", invincibility)


data:add {
   _type = "base.config_option",
   _id = "infinite_skill_points",

   type = "boolean",
   default = false
}

local function infinite_skill_points(chara, skill_id)
   if config.cheat.infinite_skill_points then
      chara.skill_bonus = chara.skill_bonus + 1
   end
end
Advice.add("before", "api.gui.menu.CharacterInfoMenu", "apply_skill_point", "Cheat: config.cheat.infinite_skill_points", infinite_skill_points)


data:add {
   _type = "base.config_option",
   _id = "no_spell_failure",

   type = "boolean",
   default = false
}

local function no_spell_failure(orig_fn, skill_id, caster, ...)
   if config.cheat.no_spell_failure and caster:is_player() then
      return 100
   end

   return orig_fn(skill_id, caster, ...)
end
Advice.add("around", "mod.elona_sys.api.Skill", "calc_spell_success_chance", "Cheat: config.cheat.no_spell_failure", no_spell_failure)


data:add {
   _type = "base.config_option",
   _id = "no_inventory_burden",

   type = "boolean",
   default = false,

   on_changed = refresh_player
}

local function no_inventory_burden(chara)
   if not config.cheat.no_inventory_burden then
      return
   end

   chara.inventory_weight_type = Enum.Burden.None
   Skill.refresh_speed(chara)
end
Event.register("base.on_refresh_weight", "Cheat: config.cheat.no_inventory_burden", no_inventory_burden, { priority = 1000000 })


--
-- Advice
--

data:add {
   _type = "base.config_option",
   _id = "show_stair_locations",

   type = "boolean",
   default = false,

   on_changed = function()
      Gui.refresh_hud()
   end
}

--
-- Config Menu
--

data:add {
   _type = "base.config_menu",
   _id = "menu",

   items = {
      "cheat.easy_new_game",
      "cheat.max_attributes",
      "cheat.max_skills",
      "cheat.max_spells",
      "cheat.max_resistances",
      "cheat.invincibility",
      "cheat.infinite_skill_points",
      "cheat.no_spell_failure",
      "cheat.no_inventory_burden",
      "cheat.show_stair_locations",
   }
}

-- TODO immutable data edits
local menu = { _type = "base.config_menu", _id = "cheat.menu" }
table.insert(data["base.config_menu"]:ensure("base.default").items, menu)
