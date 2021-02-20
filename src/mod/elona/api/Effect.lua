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
local Input = require("api.Input")
local Enum = require("api.Enum")
local IChara = require("api.chara.IChara")
local Area = require("api.Area")
local World = require("api.World")
local Const = require("api.Const")
local I18N = require("api.I18N")
local Mef = require("api.Mef")
local elona_Item = require("mod.elona.api.Item")

local Effect = {}

--- @tparam curse_state curse_state
function Effect.is_cursed(curse_state)
   return curse_state == Enum.CurseState.Cursed or curse_state == Enum.CurseState.Doomed
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
   elseif curse_state == Enum.CurseState.Blessed then
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
      if (chara:is_in_player_party() and chara.anorexia_count > 10)
         or (not chara:is_in_player_party() and Rand.one_in(4))
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
            if not Chara.is_alive(chara) and chara:relation_towards() > Enum.Relation.Neutral then
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
   if power >= item:calc("identify_difficulty") then
      level = Enum.IdentifyState.Full
   else
      level = Enum.IdentifyState.None
   end
   return Effect.identify_item(item, level)
end

-- <<<<<<<< shade2/item.hsp:695 	} ..
local FOOD_CHIPS = {
   ["elona.bread"] = {
      [0] = "elona.item_dish_charred",
      [1] = "elona.item_dish_charred",
      [2] = "elona.item_dish_sweet_5",
      [3] = "elona.item_dish_sweet_3",
      [4] = "elona.item_dish_sweet_5",
      [5] = "elona.item_dish_bread_5",
      [6] = "elona.item_dish_bread_6",
      [7] = "elona.item_dish_bread_7",
      [8] = "elona.item_dish_bread_8",
      [9] = "elona.item_dish_bread_9"
   },
   ["elona.egg"] = {
      [0] = "elona.item_dish_charred",
      [1] = "elona.item_dish_charred",
      [2] = "elona.item_dish_charred",
      [3] = "elona.item_dish_egg_3",
      [4] = "elona.item_dish_meat_8",
      [5] = "elona.item_dish_egg_3",
      [6] = "elona.item_dish_vegetable_4",
      [7] = "elona.item_hero_cheese",
      [8] = "elona.item_dish_egg_8",
      [9] = "elona.item_dish_meat_7"
   },
   ["elona.fish"] = {
      [0] = "elona.item_dish_charred",
      [1] = "elona.item_dish_charred",
      [2] = "elona.item_dish_charred",
      [3] = "elona.item_dish_fish_3",
      [4] = "elona.item_dish_vegetable_4",
      [5] = "elona.item_dish_vegetable_4",
      [6] = "elona.item_dish_fish_3",
      [7] = "elona.item_dish_fish_7",
      [8] = "elona.item_dish_fish_3",
      [9] = "elona.item_dish_fish_3"
   },
   ["elona.fruit"] = {
      [0] = "elona.item_dish_charred",
      [1] = "elona.item_dish_charred",
      [2] = "elona.item_dish_charred",
      [3] = "elona.item_dish_meat_8",
      [4] = "elona.item_dish_fruit_4",
      [5] = "elona.item_dish_fruit_4",
      [6] = "elona.item_dish_fruit_6",
      [7] = "elona.item_dish_fruit_6",
      [8] = "elona.item_dish_egg_8",
      [9] = "elona.item_dish_fruit_4"
   },
   ["elona.meat"] = {
      [0] = "elona.item_dish_charred",
      [1] = "elona.item_dish_charred",
      [2] = "elona.item_dish_charred",
      [3] = "elona.item_dish_meat_3",
      [4] = "elona.item_dish_meat_4",
      [5] = "elona.item_dish_meat_5",
      [6] = "elona.item_dish_meat_5",
      [7] = "elona.item_dish_meat_7",
      [8] = "elona.item_dish_meat_8",
      [9] = "elona.item_dish_meat_4"
   },
   ["elona.pasta"] = {
      [0] = "elona.item_dish_charred",
      [1] = "elona.item_dish_charred",
      [2] = "elona.item_dish_meat_8",
      [3] = "elona.item_dish_pasta_3",
      [4] = "elona.item_dish_pasta_4",
      [5] = "elona.item_dish_pasta_4",
      [6] = "elona.item_dish_pasta_3",
      [7] = "elona.item_dish_pasta_3",
      [8] = "elona.item_dish_pasta_4",
      [9] = "elona.item_dish_pasta_3"
   },
   ["elona.sweet"] = {
      [0] = "elona.item_dish_charred",
      [1] = "elona.item_dish_charred",
      [2] = "elona.item_dish_charred",
      [3] = "elona.item_dish_sweet_3",
      [4] = "elona.item_dish_fruit_4",
      [5] = "elona.item_dish_sweet_5",
      [6] = "elona.item_dish_fruit_4",
      [7] = "elona.item_dish_egg_8",
      [8] = "elona.item_dish_egg_8",
      [9] = "elona.item_dish_egg_8"
   },
   ["elona.vegetable"] = {
      [0] = "elona.item_dish_charred",
      [1] = "elona.item_dish_charred",
      [2] = "elona.item_dish_charred",
      [3] = "elona.item_dish_meat_8",
      [4] = "elona.item_dish_vegetable_4",
      [5] = "elona.item_dish_meat_7",
      [6] = "elona.item_dish_meat_8",
      [7] = "elona.item_dish_vegetable_4",
      [8] = "elona.item_dish_meat_8",
      [9] = "elona.item_dish_meat_7"
   }
}

-- >>>>>>>> shade2/text.hsp:645 *item_foodInit ..
function Item.get_food_image(food_type, food_quality)
   local t = FOOD_CHIPS[food_type]
   if not t then
      return "elona.item_dish_charred"
   end

   local image = t[food_quality]

   return image or "elona.item_dish_charred"
end
-- <<<<<<<< shade2/text.hsp:655 	return ...


-- >>>>>>>> shade2/item_func.hsp:705 #deffunc make_dish int ci,int p ..
function Effect.make_dish(item, quality)
   local food_type = item.params and item.params.food_type
   assert(food_type, ("'%s' isn't a cookable food."):format(item._id))

   item.image = Item.get_food_image(food_type, quality)
   item.weight = 500
   if item.spoilage_date and item.spoilage_date >= 0 then
      item.spoilage_date = 72 + World.date_hours()
   end
   item.params.food_quality = quality

   return item
end
-- <<<<<<<< shade2/item_func.hsp:709 	return ..

function Effect.damage_insanity(chara, delta)
   if chara:calc("quality") >= 4 then
      return
   end

   local resistance = chara:resist_level("elona.mind")
   if resistance > 10 then
      return
   end

   delta = math.floor(delta / resistance)
   if chara:is_in_player_party() and chara:has_trait("elona.god_heal") then
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
   if not source:is_player() then
      return true
   end

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

function Effect.is_visible(chara, viewer)
   viewer = viewer or Chara.player()
   local is_invisible = chara:calc("is_invisible") and not (viewer:calc("can_see_invisible") or chara:has_effect("elona.wet"))
   return not is_invisible
end

-- Applies wetness effect and shows the invisibility message.
function Effect.get_wet(chara, amount)
   chara:apply_effect("elona.wet", amount)
   if chara:is_in_fov() then
      Gui.mes("misc.wet.gets_wet", chara)
      if chara:calc("is_invisible") then
         Gui.mes("misc.wet.is_revealed", chara)
      end
   end
end

function Effect.create_potion_puddle(x, y, item, chara)
   -- >>>>>>>> shade2/action.hsp:111 		efP=50+sThrow(cc)*10 ...
   local map = chara:current_map()
   local power = 50 + chara:skill_level("elona.throwing") * 10
   if item.proto.on_create_potion_puddle then
      item.proto.on_create_potion_puddle(item, x, y, chara)
   else
      local puddle = Mef.create("elona.potion", x, y, { origin = chara, duration = -1, power = power }, map)
      if puddle then
         puddle.color = item:calc("color")
         puddle.params.item_id = item._id
         puddle.params.curse_state = item:calc("curse_state")
      end
   end
   -- <<<<<<<< shade2/action.hsp:114 		addMef tlocX,tlocY,mefPotion,27,-1,efP,cc,iId(ci ..
end

local FLAMMABLE_CATEGORIES = {
   "elona.rod",
   "elona.tree",
   "elona.book",
   "elona.scroll",
   "elona.spellbook",
}

function Effect.damage_item_acid(item)
   local owner = item:get_owning_chara()

   if not item:calc("is_acidproof") then
      Gui.mes("item.acid.damaged", owner, item:build_name(nil, true))
      item.bonus = item.bonus - 1
      return true
   else
      Gui.mes("item.acid.immune", owner, item:build_name(nil, true))
      return false
   end
end

function Effect.damage_chara_item_acid(chara)
   -- >>>>>>>> shade2/chara_func.hsp:1152 	if ciRef!-1:ci=ciRef:else{ ...
   local elona_Item = require("mod.elona.api.Item")

   local pred = function(item) return Rand.one_in(math.clamp(30, 1, 30)) and item:calc("bonus") > -4 end
   local target = chara:iter_equipment():filter(pred):nth(1)
   if target == nil or not elona_Item.is_equipment(target) then
      return false
   end

   return Effect.damage_item_acid(target)
   -- <<<<<<<< shade2/chara_func.hsp:1161 	if iType(ci)>=fltHeadItem : return ...

end

function Effect.damage_item_fire(item, fireproof_blanket)
   -- >>>>>>>> shade2/chara_func.hsp:1195 	rowAct_item ci ...
   if not Item.is_alive(item) then
      return false
   end

   local owner = item:get_owning_chara()

   item:remove_activity()

   if item:calc("is_fireproof") or item:calc("is_precious") then
      return false
   end

   if item:has_category("elona.food") and item.params.food_quality == 0 then
      if owner then
         Gui.mes_c_visible("item.someones_item.get_broiled", owner, "Orange", item, owner)
      else
         Gui.mes_c_visible("item.item_on_the_ground.get_broiled", item, "Orange", item)
      end
      Effect.make_dish(item, Rand.rnd(5) + 1)
      return true
   end

   if item:has_category("elona.container")
      or item:has_category("elona.misc_item")
      or item:has_category("elona.gold")
   then
      return false
   end

   if item:is_equipped() and Rand.one_in(2) then
      return false
   end

   local is_flammable = fun.iter(FLAMMABLE_CATEGORIES):any(function(cat) return item:has_category(cat) end)

   if not is_flammable then
      if not Rand.one_in(4) then
         return false
      end
      if owner == nil and not Rand.one_in(4) then
         return false
      end
   end

   if fireproof_blanket and Item.is_alive(fireproof_blanket) then
      if owner then
         Gui.mes_visible("item.fireproof_blanket.protects_item", owner.x, owner.y, fireproof_blanket:build_name(1), owner)
      end
      if fireproof_blanket.charges > 0 then
         fireproof_blanket.charges = fireproof_blanket.charges - 1
      else
         if Rand.one_in(20) then
            fireproof_blanket.amount = fireproof_blanket.amount - 1
            if owner then
               Gui.mes_visible("item.fireproof_blanket.turns_to_dust", owner.x, owner.y, fireproof_blanket:build_name(1))
            end
            return true
         end
      end
      return false
   end

   local lost_amount = math.floor(Rand.rnd(item.amount) / 2 + 1)

   if owner then
      if item:is_equipped() then
         Gui.mes_c_visible("item.someones_item.equipment_turns_to_dust", owner.x, owner.y, "Purple", item:build_name(lost_amount), lost_amount, owner)
         item:unequip()
         item:remove_ownership()
         owner:refresh()
      else
         Gui.mes_c_visible("item.someones_item.turns_to_dust", owner.x, owner.y, "Purple", item:build_name(lost_amount, true), lost_amount, owner)
      end
   else
      Gui.mes_c_visible("item.item_on_the_ground.turns_to_dust", item.x, item.y, "Purple", item:build_name(lost_amount), lost_amount)
   end

   item.amount = item.amount - lost_amount
   item:refresh_cell_on_map()
   if owner then
      owner:refresh_weight()
   end

   return true
   -- <<<<<<<< shade2/chara_func.hsp:1233 	return f ..
end

function Effect.damage_chara_items_fire(chara)
   -- >>>>>>>> shade2/chara_func.hsp:1174 #deffunc item_fire int tc,int ciRef ...
   if chara:resist_level("elona.fire") >= 6 or chara:calc("quality") >= Enum.Quality.Great then
      return false
   end

   local targets = {}
   local fireproof_blanket
   for _, item in chara:iter_items() do
      if Item.is_alive(item) then
         if item._id == "elona.fireproof_blanket" and not fireproof_blanket then
            fireproof_blanket = item:separate()
         else
            targets[#targets+1] = item
         end
      end
   end

   if #targets == 0 then
      return false
   end

   local did_something = false
   for _ = 1, 3 do
      local target = Rand.choice(targets)

      did_something = Effect.damage_item_fire(target, fireproof_blanket) or did_something
   end

   return did_something
   -- <<<<<<<< shade2/chara_func.hsp:1233 	return f ..
end

function Effect.damage_map_fire(x, y, origin, map)
   -- >>>>>>>> shade2/chara_func.hsp:1235 #deffunc mapitem_fire int x,int y ...
   local item = Item.at(x, y, map):nth(1)
   if item then
      local did_something = Effect.damage_item_fire(item)
      if did_something then
         local mef = Mef.at(x, y, map)
         if mef then
            mef:remove_ownership()
         end
         Mef.create("elona.fire", x, y, { duration = Rand.rnd(10) + 5, 100, origin = origin }, map)
      end
      map:refresh_tile(x, y)
   end
   -- <<<<<<<< shade2/chara_func.hsp:1246 	return ..
end

function Effect.damage_item_ice(item, coldproof_blanket)
   -- >>>>>>>> shade2/chara_func.hsp:1265 	if max=0:return false ...
   if not Item.is_alive(item) then
      return false
   end

   local owner = item:get_owning_chara()

   item:remove_activity()

   if item:calc("is_precious") then
      return false
   end

   if item:has_category("elona.container")
      or item:has_category("elona.misc_item")
      or item:has_category("elona.gold")
   then
      return false
   end

   if item:calc("quality") >= Enum.Quality.Great or item:is_equipped() then
      return false
   end

   if not item:has_category("elona.drink") and not Rand.one_in(30) then
      return false
   end

   if coldproof_blanket and Item.is_alive(coldproof_blanket) then
      if owner then
         Gui.mes_visible("item.coldproof_blanket.protects_item", owner.x, owner.y, coldproof_blanket:build_name(1), owner)
      end
      if coldproof_blanket.charges > 0 then
         coldproof_blanket.charges = coldproof_blanket.charges - 1
      else
         if Rand.one_in(20) then
            coldproof_blanket.amount = coldproof_blanket.amount - 1
            if owner then
               Gui.mes_visible("item.coldproof_blanket.is_broken_to_pieces", owner.x, owner.y, coldproof_blanket:build_name(1))
            end
            return true
         end
      end
      return false
   end

   local lost_amount = math.floor(Rand.rnd(item.amount) / 2 + 1)

   if owner then
      Gui.mes_c_visible("item.someones_item.breaks_to_pieces", owner.x, owner.y, "Purple", item:build_name(lost_amount, true), lost_amount, owner)
   else
      Gui.mes_c_visible("item.item_on_the_ground.breaks_to_pieces", item.x, item.y, "Purple", item:build_name(lost_amount), lost_amount)
   end

   item.amount = item.amount - lost_amount
   item:refresh_cell_on_map()
   if owner then
      owner:refresh_weight()
   end

   return true
   -- <<<<<<<< shade2/chara_func.hsp:1289 	return f ..
end

function Effect.damage_chara_items_cold(chara)
   -- >>>>>>>> shade2/chara_func.hsp:1252 	if tc!-1{ ...
   if chara:resist_level("elona.cold") >= 6 or chara:calc("quality") >= Enum.Quality.Great then
      return false
   end

   local targets = {}
   local coldproof_blanket
   for _, item in chara:iter_items() do
      if Item.is_alive(item) then
         if item._id == "elona.coldproof_blanket" and not coldproof_blanket then
            coldproof_blanket = item:separate()
         else
            targets[#targets+1] = item
         end
      end
   end

   if #targets == 0 then
      return false
   end
   -- <<<<<<<< shade2/chara_func.hsp:1263 		} ..

   local did_something = false
   for _ = 1, 3 do
      local target = Rand.choice(targets)

      did_something = Effect.damage_item_ice(target, coldproof_blanket) or did_something
   end

   return did_something
end

function Effect.damage_map_cold(x, y, origin, map)
   -- >>>>>>>> shade2/chara_func.hsp:1291 #deffunc mapitem_cold int x,int y ...
   local item = Item.at(x, y, map):nth(1)
   if item then
      Effect.damage_item_ice(item)
      map:refresh_tile(x, y)
   end
   -- <<<<<<<< shade2/chara_func.hsp:1302 	return ..
end

local function is_wandering_merchant(chara)
   return chara:iter_roles("elona.shopkeeper"):any(function(role) return role.inventory_id == "elona.wandering_merchant" end)
end

function Effect.start_incognito(source)
   local filter = function(chara)
      if is_wandering_merchant(chara) then
         return false
      end

      if chara:find_role("elona.shop_guard") then
         return false
      end

      return chara:base_relation_towards(source) >= Enum.Relation.Hate
         and chara:relation_towards(source) <= Enum.Relation.Hate
   end

   local apply = function(chara)
      chara.aggro = 0
      chara:reset_relation_towards(source)
      chara:set_emotion_icon("elona.question", 2)
   end

   Chara.iter():filter(filter):each(apply)
end

function Effect.end_incognito(source)
   local filter = function(chara)
      return not chara:is_player() and chara:find_role("elona.guard") and source:calc("karma") < Const.KARMA_BAD
   end

   local apply = function(chara)
      chara:set_relation_towards(source, Enum.Relation.Enemy)
      chara:set_aggro(source, 80)
      chara:set_emotion_icon("elona.angry", 2)
   end

   Chara.iter():filter(filter):each(apply)
end

function Effect.turn_hostile(map, target)
   target = target or Chara.player()

   -- >>>>>>>> shade2/module.hsp:125 	#module ...
   local filter = function(chara)
      return not chara:is_in_player_party() and (chara:find_role("elona.guard")
                                                    or chara:find_role("elona.shop_guard")
                                                    or is_wandering_merchant(chara))
   end

   local apply = function(chara)
      chara:set_relation_towards(target, Enum.Relation.Enemy)
      chara:set_aggro(target, 80)
      chara:set_emotion_icon("elona.angry", 2)
   end

   Chara.iter(map):filter(filter):each(apply)
   -- <<<<<<<< shade2/module.hsp:133 	return ..
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
      if attacker:is_in_player_party() then
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

function Effect.sense_quality(chara)
   -- >>>>>>>> shade2/item.hsp:496 *item_senseQuality ...
   if chara:has_effect("elona.confusion") or
      chara:has_effect("elona.sleep") or
      chara:has_effect("elona.paralysis") or
      chara:has_effect("elona.choking")
   then
      return false
   end

   local filter = function(i)
      return Item.is_alive(i)
         and i.identify_state < Enum.IdentifyState.Full
         and elona_Item.is_equipment(i)
   end

   for _, item in chara:iter_items():filter(filter) do
      local power = chara:skill_level("elona.stat_perception") + chara:skill_level("elona.sense_quality") * 5
      local proc = 1500 + item:calc("identify_difficulty")

      if power > Rand.rnd(proc * 5) then
         local unidentified_name = item:build_name()
         Effect.identify_item(item, Enum.IdentifyState.Full)
         ItemMemory.set_known(item._id, true)
         if config.elona.hide_autoidentify ~= "all" then
            Gui.mes("misc.identify.fully_identified", unidentified_name, item:build_name())
         end
         Skill.gain_skill_exp(chara, "elona.sense_quality", 50)
      end
      if item.identify_state < Enum.IdentifyState.Quality and power > Rand.rnd(proc) then
         if config.elona.hide_autoidentify == "none" then
            Gui.mes("misc.identify.almost_identified", item:build_name(), "ui.quality._" .. item.quality)
         end
         Effect.identify_item(item, Enum.IdentifyState.Quality)
         Skill.gain_skill_exp(chara, "elona.sense_quality", 50)
      end
   end
   -- <<<<<<<< shade2/item.hsp:516 	return ..
end

return Effect
