local Skill = require("mod.elona_sys.api.Skill")
local Magic = require("mod.elona_sys.api.Magic")
local Event = require("api.Event")
local Effect = require("mod.elona.api.Effect")
local Gui = require("api.Gui")
local Rand = require("api.Rand")
local Anim = require("mod.elona_sys.api.Anim")
local I18N = require("api.I18N")
local Map = require("api.Map")
local Chara = require("api.Chara")
local Enum = require("api.Enum")
local Item = require("api.Item")
local ElonaAction = require("mod.elona.api.ElonaAction")
local Calc = require("mod.elona.api.Calc")
local Input = require("api.Input")
local Pos = require("api.Pos")
local Feat = require("api.Feat")

local RANGE_BOLT = 6

data:add {
   _id = "action_pregnant",
   _type = "base.skill",
   elona_id = 654,

   type = "action",
   effect_id = "elona.pregnant",
   related_skill = "elona.stat_perception",
   cost = 15,
   range = 1,
   difficulty = 0,
   target_type = "enemy"
}
data:add {
   _id = "pregnant",
   _type = "elona_sys.magic",
   elona_id = 654,

   type = "action",
   params = {
      "source",
      "target",
   },

   cast = function(self, params)
      if params.target:is_in_fov() then
         Gui.mes_visible("magic.pregnant", params.target, params.source)
      end

      Effect.impregnate(params.target)

      return true
   end
}

local function proc_pregnancy(chara)
   if not chara:calc("is_pregnant") then
      return
   end

   -- >>>>>>>> elona122/shade2/item.hsp:449 *pregnant ..
   if Rand.one_in(15) then
      if chara:is_in_fov() then
         Gui.mes("misc.pregnant.pats_stomach", chara)
         Gui.mes(I18N.quote_speech("misc.pregnant.something_is_wrong"))
      end
   end

   local map = chara:current_map()
   if not Map.is_world_map(map) and Rand.one_in(30) then
      Gui.mes_visible("misc.pregnant.something_breaks_out", chara)
      chara:apply_effect("elona.bleeding", 15)
      local level = chara:calc("level") / 2 + 1
      local alien = Chara.create("elona.alien", chara.x, chara.y, { level = level, level_scaling = "fixed" }, map)
      if alien then
         if utf8.wide_len(chara.name) > 10 or string.match(chara.name, I18N.get("chara.job.alien.child")) then
            alien.name = I18N.get("chara.job.alien.alien_kid")
         else
            alien.name = I18N.get("chara.job.alien.child_of", chara.name)
         end
      end
   end
   -- <<<<<<<< elona122/shade2/item.hsp:463 	return ..
end

local function proc_curse(chara)
   local curse_power = chara:calc("curse_power")
   if curse_power <= 0 then
      return
   end
   -- >>>>>>>> elona122/shade2/item.hsp:437 *curse ..
   if Rand.one_in(4) then
      local damage = chara.hp * (5 + curse_power / 5) / 100
      chara:damage_hp(damage, "elona.curse")
      return
   end
   if not Map.is_world_map(chara:current_map()) then
      if Rand.one_in(10 - math.clamp(curse_power / 10, 0, 9)) then
         Magic.cast("elona.teleport", { source = chara, target = chara })
         return
      end
   end
   if Rand.one_in(10) and chara.gold > 0 then
      local lose_amount = math.min(Rand.rnd(chara.gold) / 100 + Rand.rnd(10) + 1, chara.gold)
      chara.gold = chara.gold - lose_amount
      Gui.mes_c_visible("misc.curse.gold_stolen", chara, "Purple")
      return
   end
   -- <<<<<<<< elona122/shade2/item.hsp:446 	return ..
end

local function proc_cursed_enchantments(chara)
   -- >>>>>>>> elona122/shade2/item.hsp:465 *curse_enc ..
   for _, enc, item in chara:iter_enchantments() do
      enc:on_turns_passed(item, chara)
   end
   -- <<<<<<<< elona122/shade2/item.hsp:491 	return ..
end

local function event_pregnancy_curse(source, params, result)
   if result and result.blocked then
      return result
   end

   -- >>>>>>>> elona122/shade2/main.hsp:830 	if cTurn(cc)¥25=0{ ..
   if source.turns_alive % 25 == 0 then
      proc_curse(source)
      proc_cursed_enchantments(source)
      proc_pregnancy(source)
   end
   -- <<<<<<<< elona122/shade2/main.hsp:834 		} ...

   return result
end
Event.register("base.on_chara_pass_turn", "Proc pregnancy and curse", event_pregnancy_curse)

-- fov

-- attack

data:add {
   _id = "action_eye_of_insanity",
   _type = "base.skill",
   elona_id = 636,

   type = "action",
   effect_id = "elona.eye_of_insanity",
   related_skill = "elona.stat_charisma",
   cost = 10,
   range = 2,
   difficulty = 0,
   target_type = "enemy"
}
data:add {
   _id = "eye_of_insanity",
   _type = "elona_sys.magic",
   elona_id = 636,

   params = {
      "source",
      "target",
   },

   dice = function(self, params)
      local level = params.source:skill_level("elona.action_eye_of_insanity")
      return {
         x = 1 + level / 20,
         y = 10 + 1,
         bonus = 0
      }
   end,

   cast = function(self, params)
      local source = params.source
      local target = params.target

      Gui.mes_c("magic.insanity", "Purple", source, target)

      local dice = self:dice(params)
      local damage = Rand.roll_dice(dice.x, dice.y, dice.bonus)

      Effect.damage_insanity(target, damage)

      return true
   end
}

data:add {
   _id = "action_harvest_mana",
   _type = "base.skill",
   elona_id = 621,

   type = "action",
   effect_id = "elona.harvest_mana",
   related_skill = "elona.stat_magic",
   cost = 10,
   range = 0,
   difficulty = 700,
   target_type = "self_or_nearby"
}
data:add {
   _id = "harvest_mana",
   _type = "elona_sys.magic",
   elona_id = 621,

   params = {
      "source",
      "target",
   },

   cast = function(self, params)
      local source = params.source
      local target = params.target

      target:heal_mp(params.power / 2 + Rand.rnd(params.power / 2 + 1))

      if target:is_in_fov() then
         Gui.mes("magic.harvest_mana", target)
         local cb = Anim.heal(target.x, target.y, "base.heal_effect", "base.heal1")
         Gui.start_draw_callback(cb)
      end
   end
}

data:add {
   _id = "action_absorb_magic",
   _type = "base.skill",
   elona_id = 624,

   type = "action",
   effect_id = "elona.absorb_magic",
   related_skill = "elona.stat_magic",
   cost = 25,
   range = 0,
   difficulty = 0,
   target_type = "self"
}
data:add {
   _id = "absorb_magic",
   _type = "elona_sys.magic",
   elona_id = 624,

   params = {
      "source",
      "target",
   },

   dice = function(self, params)
      local level = params.source:skill_level("elona.action_absorb_magic")
      local piety = params.source:calc("piety")
      return {
         x = 1 + level / 20,
         y = piety / 140 + 1 + 1,
         bonus = 0
      }
   end,

   cast = function(self, params)
      local source = params.source
      local target = params.target

      local dice = self:dice(params)

      target:heal_mp(Rand.roll_dice(dice.x, dice.y, dice.bonus))

      if target:is_in_fov() then
         Gui.mes("magic.absorb_magic", target)
         local cb = Anim.heal(target.x, target.y, "base.heal_effect", "base.heal1")
         Gui.start_draw_callback(cb)
      end
   end
}

data:add {
   _id = "action_drain_blood",
   _type = "base.skill",
   elona_id = 601,

   type = "action",
   effect_id = "elona.drain_blood",
   related_skill = "elona.stat_dexterity",
   cost = 7,
   range = 1,
   difficulty = 0,
   target_type = "enemy"
}
data:add {
   _id = "drain_blood",
   _type = "elona_sys.magic",
   elona_id = 601,

   params = {
      "source",
      "target",
   },

   dice = function(self, params)
      local level = params.source:skill_level("elona.action_drain_blood")
      return {
         x = 1 + level / 15,
         y = 6 + 1,
         bonus = level / 4,
         element = "elona.nether",
         element_power = 200
      }
   end,

   cast = function(self, params)
      local source = params.source
      local target = params.target

      local tense = "enemy"

      local cast_style = source:calc("cast_style")
      if cast_style then
         if source:is_player() then
            Gui.mes_visible("action.cast.self", source, "ability." .. self._id .. ".name")
         else
            Gui.mes_visible("action.cast.other", source, "ui.cast_style." .. cast_style)
         end
      else
         if target:is_allied() then
            Gui.mes_visible("magic.sucks_blood.ally", source, target)
         else
            tense = "ally"
            Gui.mes_visible("magic.sucks_blood.other", source, target)
         end
      end

      local dice = self:dice(params)

      local damage = Rand.roll_dice(dice.x, dice.y, dice.bonus)
      target:damage_hp(damage, source,
                       {
                          element = dice.element,
                          element_power = dice.element_power,
                          message_tense = tense,
                          no_attack_text = true
      })

      return true
   end
}

data:add {
   _id = "action_manis_disassembly",
   _type = "base.skill",
   elona_id = 660,

   type = "action",
   effect_id = "elona.manis_disassembly",
   related_skill = "elona.stat_will",
   cost = 10,
   range = 0,
   difficulty = 0,
   target_type = "direction"
}
data:add {
   _id = "manis_disassembly",
   _type = "elona_sys.magic",
   elona_id = 660,

   params = {
      "source",
      "target",
   },

   cast = function(self, params)
      local source = params.source
      local target = params.target

      Gui.mes("magic.disassembly")
      target.hp = target:calc("max_hp") / 12 + 1

      return true
   end
}

local function make_touch(opts)
   local full_id = "elona.action_" .. opts._id
   data:add {
      _id = "action_" .. opts._id,
      _type = "base.skill",
      elona_id = opts.elona_id,

      type = "action",
      effect_id = "elona." .. opts._id,
      related_skill = opts.related_skill,
      cost = 10,
      range = 0,
      difficulty = 0,
      target_type = "direction"
   }
   data:add {
      _id = opts._id,
      _type = "elona_sys.magic",
      elona_id = opts.elona_id,

      params = {
         "source",
         "target",
      },

      dice = function(self, params)
         local level = params.source:skill_level(full_id)
         return opts.dice(params.power, level)
      end,

      cast = function(self, params)
         local source = params.source
         local target = params.target

         local tense = "enemy"

         local dice = self:dice(params)
         local element = dice.element

         local cast_style = source:calc("cast_style")
         if cast_style then
            if source:is_player() then
               Gui.mes_visible("action.cast.self", source, "ability." .. self._id .. ".name")
            else
               Gui.mes_visible("action.cast.other", source, "ui.cast_style." .. cast_style)
            end
         else
            local element_adj = I18N.get("element.damage.name." .. element)
            local melee_style = source:calc("melee_style") or "default"
            local melee_text
            if target:is_allied() then
               melee_text = I18N.get("damage.melee." .. melee_style .. ".ally")
               Gui.mes_visible("magic.touch.ally", source, target, element_adj, melee_text)
            else
               tense = "ally"
               melee_text = I18N.get("damage.melee." .. melee_style .. ".enemy")
               Gui.mes_visible("magic.touch.other", source, target, element_adj, melee_text)
            end
         end

         -- Some of the actions have special names for the melee damage type
         -- ("silky", "rotten") but don't actually exist as elemental damage
         -- types. If so then don't use an elemental type for them.
         if not data["base.element"][element] then
            element = nil
         end

         local damage = Rand.roll_dice(dice.x, dice.y, dice.bonus)
         target:damage_hp(damage, source,
                          {
                             element = element,
                             element_power = dice.element_power,
                             message_tense = tense,
                             no_attack_text = true
         })

         if opts.on_damage then
            opts.on_damage(self, params, dice)
         end

         return true
      end
   }
end

make_touch {
   _id = "touch_of_weakness",
   elona_id = 613,

   related_skill = "elona.stat_magic",

   dice = function(p, l)
      return {
         x = 1 + l / 10,
         y = 3 + 1,
         bonus = 0,
         element = "elona.rotten"
      }
   end,

   on_damage = function(self, params, dice)
      local target = params.target
      local attribute_id = Skill.random_attribute()

      local sustain_enc = Effect.has_sustain_enchantment(target, attribute_id)

      local proceed = true
      if (target:calc("quality") >= Enum.Quality.Great and Rand.one_in(4)) or sustain_enc then
         proceed = false
      end

      if proceed then
         local adj = target:stat_adjustment(attribute_id)
         local diff = target:base_skill_level(attribute_id) - adj
         if diff > 0 then
            diff = diff * params.power / 2000 + 1
            target:set_stat_adjustment(attribute_id, adj - diff)
         end
         Gui.mes_c_visible("magic.weaken", target, "Purple")
         target:refresh()
      end
   end
}

make_touch {
   _id = "touch_of_hunger",
   elona_id = 614,

   related_skill = "elona.stat_magic",

   dice = function(p, l)
      return {
         x = 1 + l / 10,
         y = 3 + 1,
         bonus = 0,
         element = "elona.starving"
      }
   end,

   on_damage = function(self, params, dice)
      local target = params.target
      target.nutrition = target.nutrition - 8 * 100
      Gui.mes_c_visible("magic.hunger", target, "Purple")
      Effect.get_hungry(target)
   end
}

make_touch {
   _id = "touch_of_poison",
   elona_id = 615,

   related_skill = "elona.stat_dexterity",

   dice = function(p, l)
      return {
         x = 1 + l / 10,
         y = 4 + 1,
         bonus = 0,
         element = "elona.poison",
         element_power = l * 4 + 20
      }
   end
}

make_touch {
   _id = "touch_of_nerve",
   elona_id = 616,

   related_skill = "elona.stat_dexterity",

   dice = function(p, l)
      return {
         x = 1 + l / 10,
         y = 3 + 1,
         bonus = 0,
         element = "elona.nerve",
         element_power = l * 4 + 20
      }
   end
}

make_touch {
   _id = "touch_of_fear",
   elona_id = 617,

   related_skill = "elona.stat_will",

   dice = function(p, l)
      return {
         x = 1 + l / 10,
         y = 3 + 1,
         bonus = 0,
         element = "elona.fearful",
         element_power = 100 + l * 2
      }
   end,

   on_damage = function(self, params, dice)
      params.target:apply_effect("elona.fear", dice.element_power)
   end
}

make_touch {
   _id = "touch_of_sleep",
   elona_id = 618,

   related_skill = "elona.stat_will",

   dice = function(p, l)
      return {
         x = 1 + l / 10,
         y = 3 + 1,
         bonus = 0,
         element = "elona.silky",
         element_power = 100 + l * 3
      }
   end,

   on_damage = function(self, params, dice)
      params.target:apply_effect("elona.sleep", dice.element_power)
   end
}

data:add {
   _id = "action_scavenge",
   _type = "base.skill",
   elona_id = 651,

   type = "action",
   effect_id = "elona.scavenge",
   related_skill = "elona.stat_dexterity",
   cost = 10,
   range = 0,
   difficulty = 0,
   target_type = "direction"
}
data:add {
   _id = "scavenge",
   _type = "elona_sys.magic",
   elona_id = 651,

   params = {
      "source",
      "target",
   },

   cast = function(self, params)
      local source = params.source
      local target = params.target

      Gui.mes_visible("magic.scavenge.apply", target, source)

      local filter = function(item)
         if not Item.is_alive(item) then
            return false
         end

         if item._id == "elona.fish_a" then
            return true
         end
      end
      local food = target:iter_inventory():filter(filter):nth(1)
      if food == nil then
         filter = function(item)
            return Item.is_alive(item) and not item:calc("is_precious") and item:has_category("elona.food")
         end
         food = target:iter_inventory():filter(filter):nth(1)
      end

      if food == nil then
         return true
      end

      if food:calc("is_spiked_with_love_potion") then
         Gui.mes_visible("magic.scavenge.rotten", target, source, food)
         return true
      end

      food:remove_activity()

      Gui.mes_visible("magic.scavenge.eats", target, source, food)

      source:heal_hp(source:calc("max_hp") / 3)
      Effect.eat_food(source, food)

      return true
   end
}

data:add {
   _id = "action_decapitation",
   _type = "base.skill",
   elona_id = 658,

   type = "action",
   effect_id = "elona.decapitation",
   related_skill = "elona.stat_dexterity",
   cost = 10,
   range = 1,
   difficulty = 0,
   target_type = "enemy"
}
data:add {
   _id = "decapitation",
   _type = "elona_sys.magic",
   elona_id = 658,

   params = {
      "source",
      "target",
   },

   cast = function(self, params)
      local source = params.source
      local target = params.target

      if target.hp > target:calc("max_hp") / 8 then
         return true
      end

      local tense = "enemy"
      local is_third_person = true

      if target:is_allied() then
         tense = "ally"
         is_third_person = false
      end

      if target:is_in_fov() then
         Gui.play_sound("base.atksword")
         Gui.mes_c("magic.vorpal.sound", "Red")
         if tense == "enemy" then
            Gui.mes("magic.vorpal.ally", source, target)
         else
            Gui.mes("magic.vorpal.other", source, target)
         end
      end

      target:damage_hp(target:calc("max_hp"), source, {
                          no_attack_text = true,
                          message_tense = tense,
                          is_third_pereson = is_third_person,
                          element = "elona.vorpal",
                          element_power = 0
      })

      return true
   end
}

data:add {
   _id = "action_eye_of_ether",
   _type = "base.skill",
   elona_id = 633,

   type = "action",
   effect_id = "elona.eye_of_ether",
   related_skill = "elona.stat_will",
   cost = 10,
   range = 2,
   difficulty = 0,
   target_type = "enemy",
}
data:add {
   _id = "eye_of_ether",
   _type = "elona_sys.magic",
   elona_id = 633,

   params = {
      "source",
      "target"
   },

   cast = function(self, params)
      local source = params.source
      local target = params.target

      if not target:is_player() then
         return true
      end

      Gui.mes_c("magic.eye_of_ether", target)
      Effect.modify_corruption(target, 100)

      return true
   end
}

data:add {
   _id = "action_eye_of_dimness",
   _type = "base.skill",
   elona_id = 638,

   type = "action",
   effect_id = "elona.eye_of_dimness",
   related_skill = "elona.stat_charisma",
   cost = 10,
   range = 2,
   difficulty = 0,
   target_type = "enemy",
}
data:add {
   _id = "eye_of_dimness",
   _type = "elona_sys.magic",
   elona_id = 638,

   params = {
      "source",
      "target"
   },

   cast = function(self, params)
      local target = params.target

      target:apply_effect("elona.dimming", 200)

      return true
   end
}

data:add {
   _id = "action_insult",
   _type = "base.skill",
   elona_id = 648,

   type = "action",
   effect_id = "elona.insult",
   related_skill = "elona.stat_charisma",
   cost = 10,
   range = 4,
   difficulty = 0,
   target_type = "enemy",
}
data:add {
   _id = "insult",
   _type = "elona_sys.magic",
   elona_id = 648,

   params = {
      "source",
      "target"
   },

   cast = function(self, params)
      local source = params.source
      local target = params.target

      if target:is_in_fov() then
         Gui.mes("magic.insult.apply", source, target)

         local insult = I18N.get_optional("magic.insult.list." .. target:calc("gender"))
         if insult == nil then
            insult = I18N.get("magic.insult.list.neutral")
         end
         Gui.mes(I18N.quote_speech(insult))
      end

      target:apply_effect("elona.dimming", 200)

      return true
   end
}


data:add {
   _id = "action_eye_of_mana",
   _type = "base.skill",
   elona_id = 652,

   type = "action",
   effect_id = "elona.eye_of_mana",
   related_skill = "elona.stat_magic",
   cost = 10,
   range = 2,
   difficulty = 0,
   target_type = "enemy",
}
data:add {
   _id = "eye_of_mana",
   _type = "elona_sys.magic",
   elona_id = 652,

   params = {
      "source",
      "target"
   },

   cast = function(self, params)
      local source = params.source
      local target = params.target

      Gui.mes_visible("magic.gaze", target, source)

      target:damage_mp(Rand.rnd(20) + 1)

      return true
   end
}


data:add {
   _id = "action_vanish",
   _type = "base.skill",
   elona_id = 653,

   type = "action",
   effect_id = "elona.vanish",
   related_skill = "elona.stat_perception",
   cost = 10,
   range = 0,
   difficulty = 0,
   target_type = "self",
}
data:add {
   _id = "vanish",
   _type = "elona_sys.magic",
   elona_id = 653,

   params = {
      "source",
      "target"
   },

   cast = function(self, params)
      local source = params.source
      local target = params.target

      if target:is_allied() or target:calc("quality") >= Enum.Quality.Great then
         return true
      end

      Gui.mes("magic.vanish", target)
      target:vanquish()

      return true
   end
}

local function make_distant_attack(range, elona_id)
   data:add {
      _id = "action_distant_attack_" .. range,
      _type = "base.skill",
      elona_id = elona_id,

      type = "action",
      effect_id = "elona.distant_attack_" .. range,
      related_skill = "elona.stat_strength",
      cost = 10,
      range = range,
      difficulty = 0,
      target_type = "enemy",
   }
   data:add {
      _id = "distant_attack_" .. range,
      _type = "elona_sys.magic",
      elona_id = elona_id,

      params = {
         "source",
         "target"
      },

      cast = function(self, params)
         local source = params.source
         local target = params.target

         local cb = Anim.ranged_attack(source.x, source.y, target.x, target.y, "elona.item_projectile_spore", nil, "base.arrow1", nil)
         Gui.start_draw_callback(cb)

         ElonaAction.melee_attack(source, target)

         return true
      end
   }
end

make_distant_attack(4, 649)
make_distant_attack(7, 650)


data:add {
   _id = "action_change",
   _type = "base.skill",
   elona_id = 628,

   type = "action",
   effect_id = "elona.change",
   related_skill = "elona.stat_perception",
   cost = 10,
   range = RANGE_BOLT,
   difficulty = 0,
   target_type = "enemy",
}
data:add {
   _id = "change",
   _type = "elona_sys.magic",
   elona_id = 628,

   params = {
      "source",
      "target"
   },

   cast = function(self, params)
      local source = params.source
      local target = params.target
      local map = params.source:current_map()

      if target:is_player() then
         Gui.mes("common.nothing_happens")
         return true, { obvious = false }
      end

      local success = true
      if params.power / 10 + 10 < target:calc("level") then
         success = false
      end

      -- TODO adventurer
      if target:calc("quality") >= Enum.Quality.Great or target:has_any_roles() or target:calc("is_not_changeable") then
         success = "impossible"
      end
      if target:is_allied() then
         success = false
      end

      if success == true then
         local cb = Anim.load("elona.anim_smoke", target.x, target.y)
         Gui.start_draw_callback(cb)
         Gui.mes("magic.change.apply", target)
         local level = Calc.calc_object_level(target:calc("level")+3, map)
         local quality = Enum.Quality.Normal
         local uid = target.uid

         -- This logic is really complicated and domain specific, and is used
         -- only in three places in the code (relocate_chara).
         Gui.mes("TODO")

         map:emit("elona_sys.on_quest_check")
      elseif success == false then
         Gui.mes("magic.common.resists", target)
      elseif success == "impossible" then
         Gui.mes("magic.change.cannot_be_changed", target)
      end

      return true
   end
}


data:add {
   _id = "action_draw_charge",
   _type = "base.skill",
   elona_id = 629,

   type = "action",
   effect_id = "elona.draw_charge",
   related_skill = "elona.stat_magic",
   cost = 1,
   range = 0,
   difficulty = 0,
   target_type = "self",
}
data:add {
   _id = "draw_charge",
   _type = "elona_sys.magic",
   elona_id = 629,

   params = {
      "source"
   },

   cast = function(self, params)
      local source = params.source
      local map = params.source:current_map()

      if not source:is_player() then
         Gui.mes("common.nothing_happens")
         return true, { obvious = false }
      end

      local result, canceled = Input.query_item(source, "elona.inv_draw_charge")

      if canceled then
         return true
      end

      local item = result.result

      local charges = 1
      local charge_level = item:calc("charge_level")
      if charge_level == 1 then
         charges = 100
      elseif charge_level == 2 then
         charges = 25
      elseif charge_level <= 4 then
         charges = 5
      elseif charge_level <= 6 then
         charges = 3
      end

      local cb = Anim.load("elona.anim_smoke", source.x, source.y)
      Gui.start_draw_callback(cb)

      charges = charges * item.charges
      source.absorbed_charges = source.absorbed_charges + charges
      Gui.mes("magic.draw_charge", item, charges, source.absorbed_charges)
      item:remove()
      source:refresh_weight()

      return true
   end
}

local function do_recharge(source, item, power)
   local charge_level = item:calc("charge_level")

   -- TODO more special cases
   if charge_level < 1 or item:calc("is_not_rechargable") then
      Gui.mes("magic.fill_charge.cannot_recharge")
      return true
   end

   if item.charges > charge_level then
      Gui.mes("magic.fill_charge.cannot_recharge_anymore", item)
      return true
   end

   local success = true

   if Rand.one_in(power / 25 + 1) then
      success = false
   end

   if item:has_category("elona.spellbook") and Rand.one_in(4) then
      success = false
   end

   if Rand.one_in(charge_level * charge_level + 1) then
      success = false
   end

   if success then
      local charges = 1 + Rand.rnd(charge_level / 2 + 1)
      if item:has_category("elona.spellbook") then
         charges = 1
      end

      Gui.mes("magic.fill_charge.apply", item, charges)
      item.charges = math.min(charges + item.charges, charge_level)
      local cb = Anim.load("elona.anim_smoke", source.x, source.y)
      Gui.start_draw_callback(cb)
   else
      if Rand.one_in(4) then
         Gui.mes("magic.fill_charge.explodes", item)
         item.amount = item.amount - 1
         source:refresh_weight()
      end
      Gui.mes("magic.fill_charge.fail", item)
   end

   return true
end

data:add {
   _id = "action_fill_charge",
   _type = "base.skill",
   elona_id = 630,

   type = "action",
   effect_id = "elona.fill_charge",
   related_skill = "elona.stat_magic",
   cost = 10,
   range = 0,
   difficulty = 0,
   target_type = "self",
}
data:add {
   _id = "fill_charge",
   _type = "elona_sys.magic",
   elona_id = 630,

   params = {
      "source"
   },

   cast = function(self, params)
      local source = params.source

      if not source:is_player() then
         Gui.mes("common.nothing_happens")
         return true, { obvious = false }
      end

      if source.absorbed_charges < 10 then
         Gui.mes("magic.fill_charge.more_power_needed")
         return true, { obvious = false }
      end

      source.absorbed_charges = math.max(source.absorbed_charges - 10, 0)
      Gui.mes("magic.fill_charge.spend", source.absorbed_charges)

      local result, canceled = Input.query_item(source, "elona.inv_draw_charge")
      if canceled then
         return true, { obvious = false }
      end

      local item = result.result
      return do_recharge(source, item, params.power)
   end
}

data:add {
   _id = "effect_recharge",
   _type = "elona_sys.magic",
   elona_id = 1129,

   params = {
      "source"
   },

   cast = function(self, params)
      local source = params.source

      local result, canceled = Input.query_item(source, "elona.inv_draw_charge")
      if canceled then
         return true, { obvious = false }
      end

      local item = result.result
      return do_recharge(source, item, params.power)
   end
}


data:add {
   _id = "action_swarm",
   _type = "base.skill",
   elona_id = 631,

   type = "action",
   effect_id = "elona.swarm",
   related_skill = "elona.stat_strength",
   cost = 5,
   range = 1,
   difficulty = 220,
   target_type = "self",
}
data:add {
   _id = "swarm",
   _type = "elona_sys.magic",
   elona_id = 631,

   params = {
      "source"
   },

   cast = function(self, params)
      local source = params.source
      local target = params.target
      local map = params.source:current_map()

      Gui.mes_c("magic.swarm", "Blue")

      local filter = function(chara)
         if not Chara.is_alive(chara) or chara:is_allied_with(source) then
            return false
         end

         if Pos.dist(source.x, source.y, chara.x, chara.y) > params.range then
            return false
         end

         if not source:has_los(chara.x, chara.y) then
            return false
         end

         return true
      end

      local melee = function(chara)
         local cb = Anim.swarm(chara.x, chara.y)
         Gui.start_draw_callback(cb)
         ElonaAction.melee_attack(source, chara)
      end

      Chara.iter():filter(filter):each(melee)

      return true
   end
}


data:add {
   _id = "action_cheer",
   _type = "base.skill",
   elona_id = 656,

   type = "action",
   effect_id = "elona.cheer",
   related_skill = "elona.stat_charisma",
   cost = 28,
   range = RANGE_BOLT+1,
   difficulty = 500,
   target_type = "self_or_nearby",
}
data:add {
   _id = "cheer",
   _type = "elona_sys.magic",
   elona_id = 656,

   params = {
      "source"
   },

   cast = function(self, params)
      local source = params.source

      Gui.mes_visible("magic.cheer.apply", source)

      local filter = function(chara)
         if chara:is_player() or not chara:is_allied() or not chara:is_in_same_faction(source) then
            return false
         end

         if Pos.dist(source.x, source.y, chara.x, chara.y) > params.range then
            return false
         end

         if not source:has_los(chara.x, chara.y) then
            return false
         end

         return true
      end

      local cheer = function(chara)
         Gui.mes_c_visible("magic.cheer.is_excited", chara, "Blue")
         Effect.add_buff(chara, source, "elona.speed", source:skill_level("elona.stat_charisma") * 5 + 15, 15)
         Effect.add_buff(chara, source, "elona.hero", source:skill_level("elona.stat_charisma") * 5 + 100, 60)
         Effect.add_buff(chara, source, "elona.contingency", 1500, 30)
      end

      Chara.iter():filter(filter):each(cheer)

      return true
   end
}

data:add {
   _id = "action_mewmewmew",
   _type = "base.skill",
   elona_id = 657,

   type = "action",
   effect_id = "elona.mewmewmew",
   related_skill = "elona.stat_luck",
   cost = 1,
   range = 1,
   difficulty = 500,
   target_type = "self_or_nearby",
}
data:add {
   _id = "mewmewmew",
   _type = "elona_sys.magic",
   elona_id = 657,

   params = {
      "source"
   },

   cast = function(self, params)
      local source = params.source

      local filter = function(chara)
         if not Chara.is_alive(source) or chara == source then
            return false
         end

         return true
      end

      Gui.mes_c("magic.mewmewmew", "Blue")

      local positions = Chara.iter():filter(filter):map(function(c) return { x = c.x, y = c.y } end):to_list()

      local cb = Anim.miracle(positions)
      Gui.start_draw_callback(cb)

      Chara.iter():filter(filter):each(function(chara) chara:damage_hp(9999999, source) end)

      return true
   end
}

data:add {
   _id = "action_mirror",
   _type = "base.skill",
   elona_id = 626,

   type = "action",
   effect_id = "elona.mirror",
   related_skill = "elona.stat_perception",
   cost = 30,
   range = 1,
   difficulty = 500,
   target_type = "self",
}
data:add {
   _id = "mirror",
   _type = "elona_sys.magic",
   elona_id = 626,

   params = {
      "source"
   },

   cast = function(self, params)
      local source = params.source

      Gui.mes("magic.mirror")

      -- This skill was only used for debugging purposes.
      Gui.mes("TODO")

      return true
   end
}

data:add {
   _id = "action_drop_mine",
   _type = "base.skill",
   elona_id = 659,

   type = "action",
   effect_id = "elona.drop_mine",
   related_skill = "elona.stat_magic",
   cost = 15,
   range = 1,
   difficulty = 0,
   target_type = "self_or_nearby",
}
data:add {
   _id = "drop_mine",
   _type = "elona_sys.magic",
   elona_id = 659,

   params = {
      "source"
   },

   cast = function(self, params)
      local source = params.source
      local map = params.source:current_map()

      if Map.is_world_map(map) then
         return true
      end

      if Feat.at(source.x, source.y, map):length() > 0 then
         return true
      end

      Feat.create("elona.mine", source.x, source.y, {force=true}, map)
      Gui.mes_visible("magic.drop_mine", source)

      return true
   end
}
