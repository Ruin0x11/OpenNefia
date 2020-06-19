local Gui = require("api.Gui")
local Item = require("api.Item")
local MapArea = require("api.MapArea")
local Rand = require("api.Rand")
local Chara = require("api.Chara")
local Anim = require("mod.elona_sys.api.Anim")
local Skill = require("mod.elona_sys.api.Skill")
local ItemMemory = require("mod.elona_sys.api.ItemMemory")
local Calc = require("mod.elona.api.Calc")
local ExHelp = require("mod.elona.api.ExHelp")
local Event = require("api.Event")
local Map = require("api.Map")

local Effect = {}

--- @tparam curse_state curse_state
function Effect.is_cursed(curse_state)
   return curse_state == "cursed" or curse_state == "doomed"
end

--- @tparam IChara chara
function Effect.impregnate(chara)
   if chara:has_enchantment("elona.prevents_pregnancy") then
      Gui.mes("misc.pregnant.pukes_out", chara)
      return false
   end

   if chara.is_pregnant then
      return false
   end

   Gui.mes_c("misc.pregnant.gets_pregnant", "Orange", chara)
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
      color = "Orange"
   else
      color = "Purple"
   end

   Gui.mes_c("chara_status.karma.changed", color, delta)
   if delta > 0 then
      if chara.karma < -30 and chara.karma + delta >= -30 then
         Gui.mes_c("chara_status.karma.you_are_no_longer_criminal", "Green")
      end
   elseif delta < 0 then
      if chara.karma >= -30 and chara.karma + delta < -30 then
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
         -- TODO buff
      end

      Effect.modify_insanity(chara, 2)
   end
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

function Effect.try_to_identify_item(item, power)
   local level
   if power >= item:calc("difficulty_of_identification") then
      level = "completely"
   else
      level = "unidentified"
   end
   return Effect.identify_item(item, level)
end

function Effect.do_identify_item(item, level)
   if item.identify_state == "almost" then
      for _, cat in ipairs(item.categories) do
         if autoidentify[cat] then
            level = "completely"
            break
         end
      end
   end

   local old = identify_states[item.identify_state]
   local new = identify_states[level]
   assert(old, item.identify_state)
   assert(new, level)

   if old >= new then
      return false, "unidentified"
   end

   if old > identify_states.partly then
      ItemMemory.set_known(item, 1)
   end

   return true, level
end

function Effect.identify_item(item, level)
   local do_change_level, new_level = Effect.do_identify_item(item, level)
   if do_change_level then
      item.identify_state = level
   end
   return new_level
end

function Effect.modify_insanity(chara, delta)
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

function Effect.eat_rotten_food(chara)
   -- TODO
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

function Effect.can_return_to(entrance)
   local area = MapArea.area_for_map(entrance.map_uid)

   if not area then
      return false
   end

   if not area.can_return_to then
      return false
   end

   if (area.deepest_level_visited or 0) == 0 then
      return false
   end

   return true
end

function Effect.query_return_location(chara)
   local forbidden = Event.trigger("elona.calc_return_forbidden", {chara=chara}, false)
   if forbidden then
      Gui.mes("misc.return.forbidden")
      if not Input.yes_no() then
         Gui.update_screen()
         return nil
      end
   end

   local outer_map = Map.world_map_containing(chara:current_map())
   assert(outer_map)

   local to_prompt = function(map_entrance)
      return {
         text = "name"
      }
   end

   local maps = MapArea.iter_map_entrances("generated", outer_map)
      :filter(Effect.can_return_to)
      :map(to_prompt)
      :to_list()

   local result, canceled = Input.prompt(maps)

   if canceled then
      Gui.mes("misc.return.no_location")
      return nil
   end

   Gui.update_screen()

   return maps[result.index].map_uid, 15 + Rand.rnd(15)
end

function Effect.decrement_fame(chara, fraction)
   local delta = chara.fame / fraction + 5
   delta = delta + Rand.rnd(delta / 2) - Rand.rnd(delta / 2)
   chara.fame = math.max(chara.fame - math.floor(delta), 0)
   return delta
end

return Effect
