local Charagen = require("mod.elona.api.Charagen")
local Calc = require("mod.elona.api.Calc")
local Chara = require("api.Chara")
local Item = require("api.Item")
local Gui = require("api.Gui")
local Rand = require("api.Rand")
local Event = require("api.Event")
local Effect = require("mod.elona.api.Effect")
local IItem = require("api.item.IItem")
local Skill = require("mod.elona_sys.api.Skill")
local Input = require("api.Input")
local Anim = require("mod.elona_sys.api.Anim")
local Action = require("api.Action")
local Magic = require("mod.elona_sys.api.Magic")
local Enum = require("api.Enum")
local SkillCheck = require("mod.elona.api.SkillCheck")
local Log = require("api.Log")
local Hunger = require("mod.elona.api.Hunger")
local Const = require("api.Const")

local ElonaMagic = {}

-- BUG: we have to return false or nil instead of player_turn_query to support
-- characters other than the player using items!

function ElonaMagic.drink_potion(magic_id, power, item, params)
   -- TODO: allow multiple magic IDs to be passed at once, or maybe a callback
   -- function even.
   local chara = params.chara
   local triggered_by = params.triggered_by or "potion"
   local curse_state = params.curse_state or (item and item:calc("curse_state")) or Enum.CurseState.Normal

   if triggered_by == "potion_thrown" then
      local throw_power = params.throw_power or 100
      power = power * throw_power / 100
      curse_state = item:calc("curse_state")
   elseif triggered_by == "potion" then
      curse_state = item:calc("curse_state")
      if chara:is_in_fov() then
         Gui.play_sound("base.drink1", chara.x, chara.y)
         Gui.mes("action.drink.potion", chara, item:build_name(1))
      end
   elseif triggered_by == "potion_spilt" then
      -- pass
   end
   local magic_params = {
      source = chara,
      -- TODO target if thrown
      power = power,
      item = item,
      target = params.chara,
      curse_state = curse_state,
      triggered_by = triggered_by
   }
   local did_something, result = Magic.cast(magic_id, magic_params)

   if result and item and chara:is_player() and result.obvious then
      Effect.identify_item(item, Enum.IdentifyState.Name)
   end
   -- Event will be triggered globally if potion is consumed
   -- through spilling, since there will be no item to pass
   if class.is_an(IItem, item) then
      item.amount = item.amount - 1
   end

   chara.nutrition = chara.nutrition + 150

   if chara:is_in_player_party() and chara.nutrition > Const.HUNGER_THRESHOLD_BLOATED and Rand.one_in(5) then
      Hunger.vomit(chara)
   end

   if did_something then
      return "turn_end"
   else
      return "player_turn_query"
   end
end

local function proc_well_events(well, chara)
   -- >>>>>>>> shade2/proc.hsp:1389 	p=rnd(100) ..
   local event = Rand.rnd(100)
   Log.error("TODO well")

   if not chara:is_player() and Rand.one_in(15) then
      -- Fall into well.
      Gui.mes("action.drink.well.effect.falls.text", chara)
      Gui.mes_c("action.drink.well.effect.falls.dialog", "SkyBlue", chara)
      if SkillCheck.is_floating(chara) then
         Gui.mes_c("action.drink.well.effect.falls.floats", chara)
      else
         chara:damage_hp(9999, "elona.well")
      end
   end

   if well._id == "elona.holy_well" then
      if Rand.one_in(2) then
         Magic.cast("elona.wish")
         return
      end
   end

   if chara:is_player() then
      Gui.mes("action.drink.well.effect.default")
   end

   if chara:is_player() then
      chara.nutrition = chara.nutrition + 500
   else
      chara.nutrition = chara.nutrition + 4000
   end

   if well._id == "elona.holy_well" then
      save.elona.holy_well_count = save.elona.holy_well_count - 1
   else
      well.params.count_1 = well.params.count_1 - Rand.rnd(3)
      well.params.count_2 = well.params.count_2 + Rand.rnd(3)
      if well.params.count_2 >= 20 then
         Gui.mes("action.drink.well.completely_dried_up", well)
         return "turn_end"
      end
   end
   if well.params.count_1 < -5 then
      Gui.mes("action.drink.well.dried_up", well)
   end
   return "turn_end"
   -- <<<<<<<< shade2/proc.hsp:1462 	return true ..
end

function ElonaMagic.drink_well(item, params)
   -- >>>>>>>> shade2/proc.hsp:1383 *drinkWell ..
   local chara = params.chara

   if item.params.count_1 < -5 or item.params.count_2 >= 20
      or (item._id == "elona.holy_well" and save.elona.holy_well_count <= 0)
   then
      Gui.mes("action.drink.well.is_dry", item)
      return "turn_end"
   end

   local sep = item:separate()
   Gui.play_sound("base.drink1", chara.x, chara.y)
   Gui.mes("action.drink.well.draw", chara, item)
   -- <<<<<<<< shade2/proc.hsp:1387 	tc=cc:ciBk=ci ..

   return proc_well_events(sep, chara)
end

--- @tparam IItem item
--- @tparam table magic
--- @tparam table params
--- @treturn string
function ElonaMagic.read_scroll(item, magic, params)
   -- >>>>>>>> shade2/proc.hsp:1465 *readScroll ..
   params = params or {}
   params.chara = params.chara or nil
   params.no_consume_item = params.no_consume_item

   local chara = params.chara or item:get_owning_chara()

   if chara:has_effect("elona.blindness") then
      if chara:is_in_fov() then
         Gui.mes("action.read.cannot_see", chara)
      end
      return "turn_end"
   end

   if chara:has_effect("elona.dimming") or chara:has_effect("elona.confusion") then
      if not Rand.one_in(4) then
         if chara:is_in_fov() then
            Gui.mes("action.read.scroll.dimmed_or_confused", chara)
         end
         return "turn_end"
      end
   end

   if chara:is_in_fov() then
      Gui.mes("action.read.scroll.execute", chara, item:build_name(1))
   end
   if not params.no_consume then
      item.amount = item.amount - 1
      Skill.gain_skill_exp(chara, "elona.literacy", 25, 2)
   end

   local did_something, result
   for _, pair in ipairs(magic) do
      local magic_id = pair._id
      local power = pair.power
      assert(magic_id and power, ("Missing _id (%s) or power (%s) for magic callback"):format(magic_id, power))
      did_something, result = Magic.cast(magic_id, {power=power,item=item,source=chara,target=chara})
   end

   result = result or {}
   if result.obvious == nil then
      result.obvious = true
   end

   if result and chara:is_player() and result.obvious then
      Effect.identify_item(item, Enum.IdentifyState.Name)
   end

   return "turn_end"
   -- <<<<<<<< shade2/proc.hsp:1488 	return true ..
end

--- @tparam IItem item
--- @tparam magic_id id:elona_sys.magic
--- @tparam uint power
--- @tparam table params
--- @treturn string
function ElonaMagic.zap_wand(item, magic_id, power, params)
   -- >>>>>>>> shade2/proc.hsp:1491 *zapStaff ..
   params = params or {}

   local skill_data = Magic.skills_for_magic(magic_id)[1] or nil
   local chara = params.chara or item:get_owning_chara()

   if item.charges <= 0 then
      Gui.mes("action.zap.execute", item:build_name(1))
      Gui.mes("common.nothing_happens")
      return "turn_end"
   end

   local curse_state = item:calc("curse_state")
   if curse_state == Enum.CurseState.Blessed then
      curse_state = Enum.CurseState.Normal
   end

   local magic_pos

   if skill_data then
      local target = chara:get_target()
      local success
      success, magic_pos = Magic.get_magic_location(skill_data.target_type,
                                                              skill_data.range,
                                                              chara,
                                                              params.triggered_by or "wand",
                                                              target,
                                                              skill_data.ai_check_ranged_if_self,
                                                              skill_data.on_choose_target)

      if not success then
         return "turn_end"
      end
      -- <<<<<<<< shade2/proc.hsp:1499 	gosub *effect_selectTg ..
   else
      -- >>>>>>>> shade2/proc.hsp:1563 	if efId>tailSpAct:tc=cc:return true ..
      magic_pos = {
         source = chara,
         target = chara
      }
      -- <<<<<<<< shade2/proc.hsp:1563 	if efId>tailSpAct:tc=cc:return true ..
   end
   -- >>>>>>>> shade2/proc.hsp:1500 	if stat=false : efSource=false: return false ..

   if magic_pos.no_effect then
      if chara:is_in_fov() then
         Gui.mes("action.zap.execute", item:build_name(1))
         Gui.mes("common.nothing_happens")
      end

      if Item.is_alive(item) then
         item:refresh_cell_on_map()
      end

      local sep = item:separate()
      sep.charges = sep.charges - 1

      return "turn_end"
   end

   if chara:is_in_fov() then
      Gui.mes("action.zap.execute", item:build_name(1))
   end
   -- <<<<<<<< shade2/proc.hsp:1507 	if sync(cc) : txtActZap : txtMore ..

   -- >>>>>>>> shade2/proc.hsp:1509 	efP = efP*( 100 + sMagicDevice(cc) * 10 + sMAG(cc ..
   local magic_device = chara:skill_level("elona.magic_device")
   local stat_magic = chara:skill_level("elona.stat_magic")
   local stat_perception = chara:skill_level("elona.stat_perception")
   local adjusted_power = power * (100 + magic_device * 10 + stat_magic / 2 + stat_perception / 2) / 100

   local success = chara:emit("elona.calc_wand_success", {magic_id=magic_id,item=item}, false)

   if success then
      local magic_params = {
         power=adjusted_power,
         item=item,
         curse_state=curse_state,
         x = magic_pos.x,
         y = magic_pos.y,
         range = skill_data.range,
         source = magic_pos.source,
         target = magic_pos.target
      }
      local did_something, result = Magic.cast(magic_id, magic_params)

      result = result or {}
      if result.obvious == nil then
         result.obvious = true
      end

      if result and chara:is_player() and result.obvious then
         Effect.identify_item(item, Enum.IdentifyState.Name)
      end

      if chara:is_player() then
         Skill.gain_skill_exp(chara, "elona.magic_device", 40)
      end
   else
      if chara:is_in_fov() then
         Gui.mes("action.zap.fail", chara)
      end
   end

   if Item.is_alive(item) then
      item:refresh_cell_on_map()

      local sep = item:separate()
      sep.charges = sep.charges - 1
   end

   return "turn_end"
   -- <<<<<<<< shade2/proc.hsp:1536 	return true ..
end

function ElonaMagic.check_can_cast_spell(skill_id, caster)
   local skill_data = data["base.skill"]:ensure(skill_id)

   if skill_data.on_check_can_cast then
      if not skill_data.on_check_can_cast(skill_data, caster) then
         return false
      end
   end

   return true
end

function ElonaMagic.calc_spellbook_success(chara, difficulty, skill_level)
   -- >>>>>>>> shade2/calculation.hsp:1079 *calcReadCheck	 ..
   if chara:has_effect("elona.blindness") then
      return false
   end

   if chara:has_effect("elona.confusion") or chara:has_effect("elona.dimming") then
      if not Rand.one_in(4) then
         return false
      else
         return true
      end
   end

   if Rand.rnd(chara:skill_level("elona.literacy") * skill_level * 4 + 250) < Rand.rnd(difficulty + 1) then
      if Rand.one_in(7) then
         return false
      end
      if skill_level * 10 < difficulty and Rand.rnd(skill_level * 10 + 1) < Rand.rnd(difficulty + 1) then
         return false
      end
      if skill_level * 20 < difficulty and Rand.rnd(skill_level * 20 + 1) < Rand.rnd(difficulty + 1) then
         return false
      end
      if skill_level * 30 < difficulty and Rand.rnd(skill_level * 30 + 1) < Rand.rnd(difficulty + 1) then
         return false
      end
   end
   -- <<<<<<<< shade2/calculation.hsp:1094 	if f=true:return true ..

   return true
end

function ElonaMagic.fail_to_read_spellbook(chara, difficulty, skill_level)
   -- >>>>>>>> shade2/calculation.hsp:1092 	if rnd(4)=0{ ...
   if Rand.one_in(4) then
      Gui.mes_visible("misc.fail_to_cast.mana_is_absorbed", chara)
      if chara:is_player() then
         chara:damage_mp(chara:calc("max_mp"))
      else
         chara:damage_mp(chara:calc("max_mp") / 3)
      end
      return
   end

   if Rand.one_in(4) then
      if chara:is_in_fov() then
         if chara:has_effect("elona.confusion") then
            Gui.mes("misc.fail_to_cast.is_confused_more", chara)
         else
            Gui.mes("misc.fail_to_cast.too_difficult")
         end
      end
      chara:apply_effect("elona.confusion", 100)
      return
   end

   if Rand.one_in(4) then
      Gui.mes_visible("misc.fail_to_cast.creatures_are_summoned", chara)
      local player = Chara.player()
      local player_level = player:calc("level")
      local map = player:current_map()
      for i = 1, 2 + Rand.rnd(3) do
         local level = Calc.calc_object_level(player_level * 3 / 2 + 3, map)
         local quality = Calc.calc_object_quality(Enum.Quality.Normal)
         local spawned = Charagen.create(player.x, player.y, { level = level, quality = quality })
         if spawned and chara:relation_towards(player) <= Enum.Relation.Enemy then
            spawned:set_relation_towards(player, Enum.Relation.Dislike)
         end
      end
      return
   end

   Gui.mes_visible("misc.fail_to_cast.dimension_door_opens", chara)
   Magic.cast("elona.teleport", { source = chara, target = chara })

   return
      -- <<<<<<<< shade2/calculation.hsp:1114 	return false ..
end

-- Tries to read a spellbook, and on failure causes a negative effect to happen.
function ElonaMagic.try_to_read_spellbook(chara, difficulty, skill_level)
   -- >>>>>>>> shade2/calculation.hsp:1096 	if rnd(4)=0{ ..
   local success = ElonaMagic.calc_spellbook_success(chara, difficulty, skill_level)
   if success then
      return true
   end

   ElonaMagic.fail_to_read_spellbook(chara, difficulty, skill_level)

   return false
   -- <<<<<<<< shade2/calculation.hsp:1118 	return false ..
end

function ElonaMagic.do_cast_spell(skill_id, caster, use_mp)
   -- >>>>>>>> elona122/shade2/proc.hsp:1282 *cast_proc ..
   local skill_data = data["base.skill"]:ensure(skill_id)
   local params = {
      triggered_by = "spell",
      curse_state = "normal",
      power = Skill.calc_spell_power(skill_id, caster),
      range = skill_data.range
   }

   if caster:is_player() then
      if Skill.calc_spell_mp_cost(skill_id, caster) > caster.mp then
         Gui.mes("action.cast.overcast_warning")
         if not Input.yes_no() then
            return false
         end
      end
   end

   if not ElonaMagic.check_can_cast_spell(skill_id, caster) then
      return false
   end

   local target = caster:get_target()
   local success, result = Magic.get_magic_location(skill_data.target_type,
                                                              skill_data.range,
                                                              caster,
                                                              params.triggered_by,
                                                              target,
                                                              skill_data.ai_check_ranged_if_self,
                                                              skill_data.on_choose_target)

   if not success then
      return false
   end

   params = table.merge(params, result)

   if caster:is_player() or use_mp then
      if caster:is_player() then
         local stock = caster:spell_stock(skill_id)
         stock = math.max(stock - Skill.calc_spell_stock_cost(skill_id, caster), 0)
         caster:set_spell_stock(skill_id, stock)
      end
      local mp_used = Skill.calc_spell_mp_cost(skill_id, caster)
      -- TODO god blessing
      caster:damage_mp(mp_used, false, true)
      if not Chara.is_alive(caster) then
         return true
      end
   end

   if caster:has_effect("elona.confusion") or caster:has_effect("elona.dimming") then
      Gui.mes_visible("action.cast.confused", caster.x, caster.y, caster)
      local success = ElonaMagic.try_to_read_spellbook(caster, skill_data.difficulty, caster:skill_level(skill_data._id))
      if not success then
         return true
      end
   else
      if caster:is_player() then
         Gui.mes_visible("action.cast.self", caster.x, caster.y, caster, "ability." .. skill_id .. ".name")
      else
         Gui.mes_visible("action.cast.other", caster.x, caster.y, caster, "ui.cast_style." .. (caster:calc("cast_style") or "default"))
      end
   end

   if caster:get_buff("elona.mist_of_silence") ~= nil then
      Gui.mes_visible("action.cast.silenced", caster)
      return true
   end

   if not config.base.debug_no_spell_failure then
      if Rand.rnd(100) >= Skill.calc_spell_success_chance(skill_id, caster) then
         if caster:is_in_fov() then
            Gui.mes("action.cast.fail", caster)
            local cb = Anim.failure_to_cast(caster.x, caster.y)
            Gui.start_draw_callback(cb)
         end
         return true
      end
   end

   if params.no_effect then
      Gui.mes("common.nothing_happens")
      return true
   end

   local enc = caster:find_merged_enchantment("elona.power_magic")
   if enc then
      params.power = params.power * (100 + enc.total_power / 10) / 100
   end

   local rapid_magic
   if caster:calc("can_cast_rapid_magic") and skill_data.is_rapid_magic then
      rapid_magic = 1 + (Rand.one_in(3) and 1 or 0) + (Rand.one_in(2) and 1 or 0)
   end

   if rapid_magic then
      for i = 1, rapid_magic do
         Magic.cast(skill_data.effect_id, params)
         if not Chara.is_alive(params.target) then
            local target = Action.find_target(caster)
            if target == nil or caster:relation_towards(target) > Enum.Relation.Enemy then
               break
            else
               params.target = target
            end
         end
      end
   else
      Magic.cast(skill_data.effect_id, params)
   end

   return true
   -- <<<<<<<< elona122/shade2/proc.hsp:1350 	return true ..
end

local function gain_spell_and_casting_experience(skill_id, caster)
   local skill_entry = data["base.skill"]:ensure(skill_id)

   if caster:is_player() then
      Skill.gain_skill_exp(caster, skill_id, skill_entry.cost * 4 + 20, 4, 5)
   end

   Skill.gain_skill_exp(caster, "elona.casting", skill_entry.cost + 10, 5)
end

function ElonaMagic.cast_spell(skill_id, caster, use_mp)
   local success = ElonaMagic.do_cast_spell(skill_id, caster, use_mp)
   if success then
      gain_spell_and_casting_experience(skill_id, caster)
      return true
   end

   return false
end

function ElonaMagic.do_action(skill_id, caster)
   -- >>>>>>>> shade2/proc.hsp:1539 *action ...
   -- TODO: action: death word
   --
   local skill_data = data["base.skill"]:ensure(skill_id)
   local params = {
      triggered_by = "action",
      curse_state = "normal",
      power = Skill.calc_spell_power(skill_id, caster),
      range = skill_data.range
   }

   local target = caster:get_target()
   local success, result = Magic.get_magic_location(skill_data.target_type,
                                                              skill_data.range,
                                                              caster,
                                                              "action",
                                                              target,
                                                              skill_data.ai_check_ranged_if_self,
                                                              skill_data.on_choose_target)

   if not success then
      return false
   end

   params = table.merge(params, result)

   if skill_data.target_type ~= "self_or_nearby" and skill_data.target_type ~= "self" then
      if caster:has_effect("elona.confusion") or caster:has_effect("elona.blindness") then
         if Rand.one_in(5) then
            Gui.mes_visible("misc.shakes_head", caster.x, caster.y, caster)
            return true
         end
      end
   end

   if skill_data.type == "action" then
      local success = Effect.do_stamina_check(caster, skill_data.cost, skill_data.related_skill)
      if not success then
         Gui.mes("magic.common.too_exhausted")
         return true
      end
   end

   params.range = skill_data.range
   params.power = Skill.calc_spell_power(skill_id, caster)

   if params.no_effect and not skill_data.ignore_missing_target then
      Gui.mes("common.nothing_happens")
      return true
   end

   local did_something = Magic.cast(skill_data.effect_id, params)

   return did_something
   -- <<<<<<<< shade2/proc.hsp:1557 	return true ..
end

function ElonaMagic.apply_buff(buff_id, params)
   -- >>>>>>>> shade2/proc.hsp:1664 		if buffType(p)=buffBless:animeLoad 11,tc:else:if ..
   local buff = data["elona_sys.buff"]:ensure(buff_id)
   local target = params.target
   local source = params.source

   if buff.type == "blessing" then
      local cb = Anim.load("elona.anim_buff", target.x, target.y)
      Gui.start_draw_callback(cb)
   elseif buff.type == "hex" then
      local cb = Anim.heal(target.x, target.y, "base.curse_effect", "base.curse1", -1)
      Gui.start_draw_callback(cb)
   end

   if buff.target_rider then
      -- TODO riding
   end

   assert(buff.params, ("Buff '%s' missing 'params' callback"):format(buff_id))
   local power = buff:params(params)
   params.buff = power

   Effect.add_buff(target, source, buff_id, power.power, power.duration)

   if buff.on_apply then
      buff:on_apply(params)
   end

   return true
   -- <<<<<<<< shade2/proc.hsp:1682 		goto *effect_end ..
end

function ElonaMagic.read_spellbook(item, skill_id, params)
   -- >>>>>>>> shade2/proc.hsp:1168 *readSpellbook ..
   local chara = params.chara or item:get_owning_chara()

   if chara:has_effect("elona.blindness") then
      Gui.mes_visible("action.read.cannot_see", chara)
      return "turn_end"
   end

   local skill_data = data["base.skill"]:ensure(skill_id)

   local sep = item:separate()
   assert(Item.is_alive(sep))
   chara:set_item_using(sep)

   local turns = skill_data.difficulty / (2 * chara:skill_level("elona.literacy")) + 1
   chara:start_activity("elona.reading_spellbook", { skill_id = skill_id, spellbook = sep }, turns)

   return "turn_end"
   -- <<<<<<<< shade2/proc.hsp:1191 		} ..
end

return ElonaMagic
