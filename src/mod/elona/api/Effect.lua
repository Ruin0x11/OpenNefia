local Gui = require("api.Gui")
local Item = require("api.Item")
local Rand = require("api.Rand")
local Chara = require("api.Chara")
local Anim = require("mod.elona_sys.api.Anim")
local Skill = require("mod.elona_sys.api.Skill")
local ItemMemory = require("mod.elona_sys.api.ItemMemory")
local Calc = require("mod.elona.api.Calc")
local ExHelp = require("mod.elona.api.ExHelp")
local Event = require("api.Event")
local Map = require("api.Map")
local Input = require("api.Input")
local Enum = require("api.Enum")
local IChara = require("api.chara.IChara")
local Area = require("api.Area")
local World = require("api.World")
local Const = require("api.Const")
local I18N = require("api.I18N")

local Effect = {}

--- @tparam curse_state curse_state
function Effect.is_cursed(curse_state)
   return curse_state == "cursed" or curse_state == "doomed"
end

--- @tparam IChara chara
function Effect.impregnate(chara)
   if chara:find_enchantment("elona.res_pregnancy") then
      Gui.mes("misc.pregnant.pukes_out", chara)
      return false
   end

   if chara.is_pregnant then
      return false
   end

   Gui.mes_c("misc.pregnant.gets_pregnant", "Yellow", chara)
   local anim = Anim.load("elona.anim_smoke", chara.x, chara.y)
   Gui.start_draw_callback(anim)
   chara.is_pregnant = true

   return true
end

--- @tparam IChara chara
--- @tparam int delta
--- @tparam[opt] bool force
function Effect.modify_weight(chara, delta, force)
   local height = chara.height
   local min = height * height * 18 / 25000
   local max = height * height * 24 / 10000

   if chara.weight < min then
      chara.weight = min
      return
   end
   if delta > 0 and chara.weight > max and not force then
      return
   end

   chara.weight = math.floor(chara.weight * (100 + delta) / 100 + ((delta > 0 and 1) or 0) - ((delta < 0 and 1) or 0))

   if chara.weight < 1 then
      chara.weight = 1
   end

   if chara:is_in_fov() then
      if delta >= 3 then
         Gui.mes("chara.weight.gain", chara)
      elseif delta <= -3 then
         Gui.mes("chara.weight.lose", chara)
      end
   end
end

--- @tparam IChara chara
--- @tparam int delta
function Effect.modify_height(chara, delta)
   chara.height = math.floor(chara.height * (100 + delta) / 100 + ((delta > 0 and 1) or 0) - ((delta < 0 and 1) or 0))

   if chara.height < 1 then
      chara.height = 1
   end

   if chara:is_in_fov() then
      if delta > 0 then
         Gui.mes("chara.height.gain", chara)
      elseif delta < 0 then
         Gui.mes("chara.height.lose", chara)
      end
   end
end

--- @tparam IChara chara
--- @tparam int delta
function Effect.modify_karma(chara, delta)
   if chara:has_trait("elona.perm_evil") and delta < 0 then
      delta = delta * 75 / 100
      if delta <= 0 then
         return
      end
   end
   if chara:has_trait("elona.perm_good") then
      delta = delta * 150 / 100
   end

   local color
   if delta >= 0 then
      color = "Yellow"
   else
      color = "Purple"
   end

   Gui.mes_c("chara_status.karma.changed", color, delta)
   if delta > 0 then
      if chara.karma < Const.KARMA_BAD and chara.karma + delta >= Const.KARMA_BAD then
         Gui.mes_c("chara_status.karma.you_are_no_longer_criminal", "Green")
      end
   elseif delta < 0 then
      if chara.karma >= Const.KARMA_BAD and chara.karma + delta < Const.KARMA_BAD then
         Gui.mes_c("chara_status.karma.you_are_criminal_now", "Purple")
         Calc.make_guards_hostile()
      end
   end

   local max = 20
   if chara:has_trait("elona.perm_evil") then
      max = max - 20
   end
   if chara:has_trait("elona.perm_good") then
      max = max + 20
   end

   chara.karma = math.clamp(chara.karma + delta, -100, max)
end

function Effect.show_eating_message(chara)
   local nutrition = chara.nutrition
   if nutrition >= 12000 then
      Gui.mes_c("food.eating_message.bloated", "Green")
   elseif nutrition >= 10000 then
      Gui.mes_c("food.eating_message.satisfied", "Green")
   elseif nutrition >= 5000 then
      Gui.mes_c("food.eating_message.normal", "Green")
   elseif nutrition >= 2000 then
      Gui.mes_c("food.eating_message.hungry", "Green")
   elseif nutrition >= 1000 then
      Gui.mes_c("food.eating_message.very_hungry", "Green")
   else
      Gui.mes_c("food.eating_message.starving", "Green")
   end
end

function Effect.apply_general_eating_effect(chara, food)
   -- TODO
end

function Effect.apply_food_curse_state(chara, curse_state)
   -- >>>>>>>> shade2/chara_func.hsp:1930 	if cExist(c)!cAlive:return ..
   if not Chara.is_alive(chara) then
      return
   end

   if Effect.is_cursed(curse_state) then
      chara.nutrition = chara.nutrition - 1500
      if chara:is_in_fov() then
         Gui.mes("food.eat_status.bad", chara)
      end
      Effect.vomit(chara)
   elseif curse_state == "blessed" then
      if chara:is_in_fov() then
         Gui.mes("food.eat_status.good", chara)
      end
      if Rand.one_in(5) then
         Effect.add_buff(chara, chara, "elona.lucky", 100, 500 + Rand.rnd(500))
      end

      Effect.heal_insanity(chara, 2)
   end
   -- <<<<<<<< shade2/chara_func.hsp:1941 	return ..
end

function Effect.vomit(chara)
   chara.anorexia_count = chara.anorexia_count + 1

   if chara:is_in_fov() then
      Gui.play_sound("base.vomit")
      Gui.mes("food.vomits", chara)
   end

   if chara.is_pregnant then
      chara.is_pregnant = false
      if chara:is_in_fov() then
         Gui.mes("food.spits_alien_children", chara)
      end
   end

   local map = chara:current_map()
   if not map:has_type("world_map") then
      local chance = 2
      for _, item in Item.iter_ground(map) do
         if Item.is_alive(item) and item._id == "elona.vomit" then
            chance = chance + 1
         end
      end
      if chara:is_player() or Rand.one_in(chance * chance * chance) then
         local vomit = Item.create("elona.vomit", chara.x, chara.y)
         if vomit and not chara:is_player() then
            vomit.params = { chara_id = chara._id }
         end
      end
   end

   if chara.is_anorexic then
      Skill.gain_fixed_skill_exp(chara, "elona.stat_strength", -50)
      Skill.gain_fixed_skill_exp(chara, "elona.stat_constitution", -75)
      Skill.gain_fixed_skill_exp(chara, "elona.stat_charisma", -100)
   else
      if (chara:is_allied() and chara.anorexia_count > 10)
         or (not chara:is_allied() and Rand.one_in(4))
      then
         if Rand.one_in(5) then
            chara.has_anorexia = true
            if chara:is_in_fov() then
               Gui.mes("food.anorexia.develops", chara)
               Gui.play_sound("base.offer1")
            end
         end
      end
   end

   chara:apply_effect("elona.dimming", 100)
   Effect.modify_weight(chara, (1 + Rand.rnd(5)) * -1)
   if chara.nutrition <= 0 then
      chara:damage_hp(9999, "elona.vomit")
   end
   chara.nutrition = chara.nutrition - 3000
end

function Effect.proc_anorexia(chara)
   if chara:calc("is_anorexic") then
      Effect.vomit(chara)
   end
end

function Effect.proc_cursed_drink(chara, curse_state)
   if not Effect.is_cursed(curse_state) then
      return
   end
   if chara:is_in_fov() then
      Gui.mes("food.eat_status.cursed_drink", chara)
   end
   chara:apply_effect("elona.sick", 200)
end

function Effect.get_hungry(chara)
   if chara:has_trait("elona.perm_slow_food") and Rand.one_in(3) then
      return
   end

   local old_level = math.floor(chara.nutrition / 1000)
   chara.nutrition = chara.nutrition - 8
   local new_level = math.floor(chara.nutrition / 1000)
   if new_level ~= old_level then
      if new_level == 1 then
         Gui.mes("food.hunger_status.starving")
      elseif new_level == 2 then
         Gui.mes("food.hunger_status.very_hungry")
      elseif new_level == 5 then
         Gui.mes("food.hunger_status.hungry")
      end
      Skill.refresh_speed(chara)
   end
end

function Effect.eat_food(chara, food)
   -- >>>>>>>> shade2/proc.hsp:1128 *insta_eat ..
   Effect.apply_general_eating_effect(chara, food)
   food:emit("elona_sys.on_item_eat", {chara=chara})

   if chara:is_player() then
      Effect.identify_item(food, Enum.IdentifyState.Name)
   end

   if chara:unequip_item(food) then
      chara:refresh()
   end

   food.amount = food.amount - 1

   if chara:is_player() then
      Effect.show_eating_message(chara)
   else
      if chara.item_to_be_used
         and chara.item_to_be_used.uid == food
      then
         chara.item_to_be_used = nil
      end

      if chara.is_eating_traded_item then
         chara.is_eating_traded_item = false
         if food.spoilage_date and food.spoilage_date < World.date_hours() then
            Gui.mes_c("food.passed_rotten", "SkyBlue")
            chara:damage_hp(999, "elona.rotten_food")
            local player = Chara.player()
            if not Chara.is_alive(chara) and chara:reaction_towards() > 0 then
               Effect.modify_karma(player, -5)
            else
               Effect.modify_karma(player, -1)
            end
            Skill.modify_impression(chara, -25)
            return
         end
      end
   end

   Effect.proc_anorexia(chara)

   food:emit("elona.on_eat_item_finish", {chara=chara})
   -- <<<<<<<< shade2/proc.hsp:1155 	return ..
end

-- TODO all categories with elona_id >= 50000
local autoidentify = table.set {
   "elona.drink",
   "elona.cargo_food",
   "elona.cargo",
   "elona.misc_item",
   "elona.gold",
   "elona.remains",
   "elona.scroll",
   "elona.tree",
   "elona.book",
   "elona.junk_in_field",
   "elona.platinum",
   "elona.food",
   "elona.ore",
   "elona.furniture",
   "elona.furniture_well",
   "elona.furniture_altar",
   "elona.spellbook",
   "elona.rod",
   "elona.junk",
   "elona.container"
}

local identify_states = {
   unidentified = 0,
   partly = 1,
   almost = 2,
   completely = 3
}

function Effect.do_identify_item(item, level)
   if item.identify_state == Enum.IdentifyState.Quality then
      for _, cat in ipairs(item.categories) do
         if autoidentify[cat] then
            level = Enum.IdentifyState.Full
            break
         end
      end
   end

   local old = item.identify_state
   local new = level

   if old >= new then
      return false, "unidentified"
   end

   return true, level
end

function Effect.identify_item(item, level)
   local do_change_level, new_level = Effect.do_identify_item(item, level)
   if do_change_level then
      item.identify_state = level

      if level >= Enum.IdentifyState.Name then
         ItemMemory.set_known(item._id, true)
      end
   end
   return do_change_level, new_level
end

function Effect.try_to_identify_item(item, power)
   local level
   if power >= item:calc("difficulty_of_identification") then
      level = Enum.IdentifyState.Full
   else
      level = Enum.IdentifyState.None
   end
   return Effect.identify_item(item, level)
end

function Effect.damage_insanity(chara, delta)
   if chara:calc("quality") >= 4 then
      return
   end

   local resistance = chara:resist_level("elona.mind")
   if resistance > 10 then
      return
   end

   delta = math.floor(delta / resistance)
   if chara:is_allied() and chara:has_trait("elona.god_heal") then
      delta = delta - Rand.rnd(4)
   end

   delta = math.max(delta, 0)
   chara:add_effect_turns("elona.insanity", delta)
   if Rand.one_in(10) or Rand.rnd(delta + 1) > 5 or Rand.rnd(chara:effect_turns("elona.insanity") + 1) > 50 then
      chara:apply_effect("elona.insanity", 100)
   end
end

function Effect.heal_insanity(chara, amount)
   amount = math.max(amount or 0, 0)
   chara.insanity = math.max(chara.insanity - amount, 0)
end

function Effect.eat_rotten_food(chara)
   -- TODO
end

function Effect.heal(chara, dice_x, dice_y, bonus)
   -- TODO riding
   local healing = Rand.roll_dice(dice_x, dice_y, bonus)
   chara:heal_hp(healing)
   chara:heal_effect("elona.fear")
   chara:heal_effect("elona.poison", 50)
   chara:heal_effect("elona.confusion", 50)
   chara:heal_effect("elona.dimming", 30)
   chara:heal_effect("elona.bleeding", 20)
   Effect.heal_insanity(chara, 1)
end

local function add_ether_disease_trait(chara)
   for _ = 1, 100000 do
      -- TODO
      Gui.mes_c("add corruption trait", "Red")
      break
   end
end

local function remove_ether_disease_trait(chara)
   for _ = 1, 100000 do
      -- TODO
      Gui.mes_c("remove corruption trait", "Green")
      break
   end
end

function Effect.modify_corruption(chara, delta)
   local original_stage = math.floor(chara.ether_disease_corruption / 1000)
   local add_amount = delta
   if delta > 0 then
      add_amount = add_amount + chara:calc("ether_disease_speed")
   end

   if chara:has_trait("elona.perm_res_ether") and delta > 0 then
      add_amount = add_amount * 100 / 150
   end

   chara.ether_disease_corruption = math.clamp(math.floor(chara.ether_disease_corruption + add_amount), 0, 20000)
   local stage_delta = math.floor(chara.ether_disease_corruption / 1000) - original_stage

   if not chara:is_player() then
      return
   end

   if stage_delta > 0 then
      if original_stage == 0 then
         Gui.mes_c("chara.corruption.symptom", "Purple")
         ExHelp.maybe_show(15)
      end

      local traits_to_add
      if original_stage + stage_delta >= 20 then
         traits_to_add = 20 - original_stage
      else
         traits_to_add = stage_delta
      end

      for i = 1, traits_to_add do
         if original_stage + i > 20 then
            break
         end
         add_ether_disease_trait(chara)
      end

      local anim = Anim.load("elona.anim_smoke", chara.x, chara.y)
      Gui.start_draw_callback(anim)
   elseif stage_delta < 0 then
      local traits_to_remove
      if original_stage + stage_delta < 0 then
         traits_to_remove = original_stage
      else
         traits_to_remove = math.abs(stage_delta)
      end

      if traits_to_remove < 0 then
         traits_to_remove = 0
      end

      for _ = 1, traits_to_remove do
         remove_ether_disease_trait(chara)
      end

      local anim = Anim.load("elona.anim_sparkle", chara.x, chara.y)
      Gui.start_draw_callback(anim)
   end

   chara:refresh()
end

function Effect.can_return_to(area_uid)
   local area = Area.get(area_uid)

   if not area then
      return false
   end

   if not area.metadata.can_return_to then
      return false
   end

   if (area.deepest_level_visited or 0) == 0 then
      return false
   end

   return true
end

-- >>>>>>>> shade2/command.hsp:4386 *com_return ..
function Effect.query_return_location(chara)
   local forbidden = Event.trigger("elona.calc_return_forbidden", {chara=chara}, false)
   if forbidden then
      Gui.mes("misc.return.forbidden")
      if not Input.yes_no() then
         Gui.update_screen()
         return nil
      end
   end

   local maps = {}

   local map = chara:current_map()
   local world_area = Area.get_root_area(map)
   if world_area then
      maps = Area.iter_all_contained_in(world_area)
         :filter(Effect.can_return_to)
         :map(function(uid, area)
               local deepest = area.deepest_level_visited
               local text = I18N.get("misc.dungeon_level", area.name, deepest)
               local ok, map_meta = assert(area:get_floor(deepest))
               return {
                  text = text,
                  map_uid = map_meta.uid
               }
             end)
         :to_list()
   end

   if #maps == 0 then
      Gui.mes("misc.return.no_location")
      return nil
   end

   Gui.mes("misc.return.where_do_you_want_to_go")
   local result, canceled = Input.prompt(maps)

   if canceled then
      return nil
   end

   Gui.update_screen()

   return maps[result.index].map_uid
end
-- <<<<<<<< shade2/command.hsp:4426 		}	 ..

function Effect.decrement_fame(chara, fraction)
   local delta = chara.fame / fraction + 5
   delta = math.floor(delta + Rand.rnd(delta / 2) - Rand.rnd(delta / 2))
   chara.fame = math.max(chara.fame - math.floor(delta), 0)
   return delta
end

function Effect.do_stamina_check(source, base_cost, related_skill_id)
   local sp_cost = base_cost / 2 + 1
   if source.stamina < 50 and source.stamina < Rand.rnd(75) then
      source:damage_sp(sp_cost)
      return false
   end
   source:damage_sp(Rand.rnd(sp_cost) + sp_cost)
   if related_skill_id then
      Skill.gain_skill_exp(source, related_skill_id, 25)
   end
   return true
end

function Effect.is_visible(chara)
   local is_invisible = chara:calc("is_invisible") and not (Chara.player():calc("can_see_invisible") or chara:has_effect("elona.wet"))
   return not is_invisible
end

-- Applies wetness effect and shows the invisibility message.
function Effect.get_wet(chara, amount)
   chara:apply_effect("elona.wet", amount)
   if chara:is_in_fov() then
      Gui.mes("misc.wet.gets_wet")
      if chara:calc("is_invisible") then
         Gui.mes("misc.wet.is_revealed")
      end
   end
end

function Effect.damage_map_fire(x, y, origin)
   -- TODO
end

function Effect.damage_map_ice(x, y, origin)
   -- TODO
end

function Effect.start_incognito(source)
   local filter = function(chara)
      local is_wandering_merchant = chara:iter_roles("elona.shopkeeper")
          :any(function(role) return role.inventory_id == "elona.wandering_merchant" end)
      if is_wandering_merchant then
         return false
      end

      if chara:find_role("elona.shop_guard") then
         return false
      end

      return chara:base_reaction_towards(source) >= 0
         and chara:reaction_towards(source) < 0
   end

   local apply = function(chara)
      chara.ai_state.hate = 0
      chara:reset_reaction_at(source)
      chara:set_emotion_icon("elona.question", 2)
   end

   Chara.iter():filter(filter):each(apply)
end

function Effect.end_incognito(source)
   local filter = function(chara)
      return not chara:is_player() and chara:find_role("elona.guard") and source:calc("karma") < Const.KARMA_BAD
   end

   local apply = function(chara)
      chara:mod_reaction_at(source, -100)
      chara.ai_state.hate = 80
      chara:set_emotion_icon("elona.angry", 2)
      require("api.Log").info("%s", chara.name)
   end

   Chara.iter():filter(filter):each(apply)
end

function Effect.act_hostile_towards(source, target)
   if not source:is_allied() or target:is_player() then
      return
   end

   if target:reaction_towards(source) >= 0 then
      target:set_emotion_icon("elona.angry", 4)
   end

   if target:reaction_towards(source) >= 1000 then
      Gui.mes_c("misc.hostile_action.glares_at_you", "Purple", target)
   else
      if target:reaction_towards(source) >= 100 then
         Effect.modify_karma(source, -2)
      end
      -- TODO fire giant
      if target:reaction_towards(source) > 0 then
         Gui.mes_c("misc.hostile_action.glares_at_you", "Purple", target)
         target:set_reaction_at(source, 0) -- reaction towards "base.friendly" is 100
      else
         if target:reaction_towards(source) >= 0 then
            Gui.mes_c("misc.hostile_action.gets_furious", "Purple", target)
         end
         target:set_reaction_at(source, -100)
         target.ai_state.hate = 80
         target:set_target(source)
      end
   end

   if target.is_livestock and Rand.one_in(50) then
      Gui.mes_c("misc.hostile_action.get_excited", "Red")
      local anger = function(chara)
         chara:set_reaction_at(source, -100)
         chara:set_target(source)
         chara.ai_state.hate = 20
         if target:reaction_towards(source) >= 0 then
            target:set_emotion_icon("elona.angry", 3)
         end
      end
      Chara.iter():filter(function(c) return target.is_livestock end):each(anger)
   end
end

function Effect.create_new_building(deed)
   -- >>>>>>>> shade2/map_user.hsp:30 *building_new ..
   -- TODO
   return "player_turn_query"
   -- <<<<<<<< shade2/map_user.hsp:136 	goto *turn_end ..
end

local function resists_hex(chara, buff_id, power, duration)
   data["elona_sys.buff"]:ensure(buff_id)
   local magic_resist = chara:resist_level("elona.magic")
   local quality = chara:calc("quality")

   -- Buffs sometimes have more than one power component (for example Divine
   -- Wisdom, which increases both Learning and Magic)
   if type(power) == "table" then
      power = power[1]
   end

   local fixed_duration = duration

   local resists = false

   if magic_resist / 2 > Rand.rnd(power * 2 + 100) then
      resists = true
   end

   if power * 3 < magic_resist then
      resists = true
   end

   if power / 3 < magic_resist then
      resists = false
   end

   if quality > Enum.Quality.Good then
      if Rand.one_in(4) then
         resists = true
      else
         fixed_duration = duration / 5 + 1
      end
   end

   if quality >= Enum.Quality.Great and buff_id == "elona.death_word" then
      resists = true
   end

   local buff = chara:get_buff("elona.holy_veil")
   if buff then
      if buff.power + 50 > power * 5 / 2 or Rand.rnd(buff.power + 50) > Rand.rnd(power + 1) then
         Gui.mes("magic.buff.holy_veil_repels")
         return "done"
      end
   end

   return resists, fixed_duration
end

function Effect.add_buff(target, source, buff_id, power, duration)
   local buff = data["elona_sys.buff"]:ensure(buff_id)

   if duration <= 0 then
      return false
   end

   if target:find_buff(buff_id) then
      Gui.mes("magic.buff.no_effect")
      return false
   end

   local fixed_duration

   if buff.type == "hex" then
      local resists
      resists, fixed_duration = resists_hex(target, buff_id, power, duration)
      if resists == "done" then
         return false
      elseif resists then
         Gui.mes_visible("magic.buff.resists", target)
         return false
      end

      if source and source:is_player() then
         source:act_hostile_towards(target)
      end
   else
      fixed_duration = duration
   end

   local apply_mes = "buff." .. buff_id .. ".apply"

   Gui.mes_visible(apply_mes, target)
   target:add_buff(buff_id, power, fixed_duration)

   return true
end

function Effect.on_kill(attacker, victim)
   -- >>>>>>>> shade2/chara_func.hsp:1121 #deffunc check_kill int cc,int tc ..
   -- TODO arena

   if class.is_an(IChara, attacker) then
      if attacker:is_allied() then
         save.base.total_killed = save.base.total_killed + 1
      end
   end
   -- <<<<<<<< shade2/chara_func.hsp:1146 	return ..
end

function Effect.has_sustain_enchantment(chara, attribute_id)
   local is_sustain_enc = function(enc)
      return enc._id == "elona.sustain_attribute"
         and enc.params.skill_id == attribute_id
   end
   return chara:iter_enchantments():any(is_sustain_enc)
end

function Effect.generate_money(chara)
   -- >>>>>>>> shade2/calculation.hsp:703 #deffunc generateMoney int id ...
   local gold = Rand.rnd(100) + Rand.rnd(chara:calc("level") * 50 + 1)
   local shop = chara:find_role("elona.shopkeeper")
   if shop then
      gold = gold + 2500 + chara:calc("shop_rank") * 250
   end
   if chara.gold < gold / 2 then
      chara.gold = gold
   end
   -- <<<<<<<< shade2/calculation.hsp:707 	return ..
end

return Effect
