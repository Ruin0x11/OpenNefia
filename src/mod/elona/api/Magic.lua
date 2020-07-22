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
local elona_sys_Magic = require("mod.elona_sys.api.Magic")

local Magic = {}

-- BUG: we have to return false or nil instead of player_turn_query to support
-- characters other than the player using items!

function Magic.drink_potion(magic_id, power, item, params)
   local chara = params.chara
   local triggered_by = params.triggered_by or "potion"
   local curse_state = params.curse_state or item:calc("curse_state") or "none"

   if triggered_by == "potion_thrown" then
      local throw_power = params.throw_power or 100
      power = power * throw_power / 100
      curse_state = item:calc("curse_state")
   elseif triggered_by == "potion" then
      curse_state = item:calc("curse_state")
      if chara:is_in_fov() then
         Gui.play_sound("base.drink1", chara.x, chara.y)
         Gui.mes("action.drink.potion", chara, item)
      end
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

   if result and chara:is_player() and result.obvious then
      Effect.identify_item(item, "partly")
   end
   -- Event will be triggered globally if potion is consumed
   -- through spilling, since there will be no item to pass
   if class.is_an(IItem, item) then
      item.amount = item.amount - 1
   end

   chara.nutrition = chara.nutrition + 150

   if chara:is_allied() and chara.nutrition > 12000 and Rand.one_in(5) then
      Effect.vomit(chara)
   end

   if did_something then
      return "turn_end"
   else
      return "player_turn_query"
   end
end

local function proc_well_events(well, chara)
   local event = Rand.rnd(100)

   if not chara:is_player() and Rand.one_in(15) then
      -- Fall into well.
      Gui.mes("action.drink.well.effect.falls.text", chara)
      Gui.mes_c("action.drink.well.effect.falls.dialog", "SkyBlue", chara)
      if chara:calc("is_floating") and not chara:has_effect("elona.gravity") then
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
end

function Magic.drink_well(item, params)
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

   return proc_well_events(sep, chara)
end

function Magic.read_scroll(magic_id, power, item, params)
   local chara = params.chara

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
      Gui.mes("action.read.scroll.execute", chara, item)
   end
   if not item:calc("can_read_multiple_times") then
      item.amount = item.amount - 1
      Skill.gain_skill_exp(chara, "elona.literacy", 25, 2)
   end

   local did_something, result = Magic.cast(magic_id, {power=power,item=item,source=params.chara})

   if result and chara:is_player() and result.obvious then
      Effect.identify_item(item, "partly")
   end

   return "turn_end"
end

function Magic.zap_wand(magic_id, power, item, params)
   local magic = data["elona_sys.magic"]:ensure(magic_id)
   local chara = params.chara

   local curse_state = item:calc("curse_state")
   if curse_state == "blessed" then
      curse_state = "none"
   end

   local x, y = elona_sys_Magic.prompt_magic_location(magic_id, chara)
   if x == nil then
      return "player_turn_query"
   end

   local target = Chara.at(x, y, chara:current_map())
   if target == nil then
      if chara:is_in_fov() then
         Gui.mes("action.zap.execute", item)
         Gui.mes("common.nothing_happens")
      end
      return "turn_end"
   end

   if chara:is_in_fov() then
      Gui.mes("action.zap.execute", item)
   end

   local magic_device = chara:skill_level("elona.magic_device")
   local stat_magic = chara:skill_level("elona.stat_magic")
   local stat_perception = chara:skill_level("elona.stat_perception")
   local adjusted_power = power * (100 + magic_device * 10 + stat_magic / 2 + stat_perception / 2) / 100

   local success = chara:emit("elona.calc_wand_success", {magic_id=magic_id,item=item}, false)

   if success then
      local did_something, result = Magic.cast(magic_id,
                                               {
                                                  power=adjusted_power,
                                                  item=item,
                                                  target=params.chara,
                                                  curse_state=curse_state
      })

      if result and chara:is_player() and result.obvious then
         Effect.identify_item(item, "partly")
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
   end

   local sep = item:separate()
   sep.count = sep.count - 1

   return "turn_end"
end

function Magic.check_can_cast_spell(skill_id, caster)
   local skill_data = data["base.skill"]:ensure(skill_id)

   if skill_data.on_check_can_cast then
      if not skill_data.on_check_can_cast(skill_data, caster) then
         return false
      end
   end

   return true
end

function Magic.do_cast_spell(skill_id, caster, use_mp)
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

   if not Magic.check_can_cast_spell(skill_id, caster) then
      return false
   end

   local target = caster:get_target()
   local success, result = elona_sys_Magic.get_magic_location(skill_data.target_type,
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
   else
      if caster:is_player() then
         Gui.mes_visible("action.cast.self", caster.x, caster.y, caster, "ability." .. skill_id .. ".name")
      else
         Gui.mes_visible("action.cast.other", caster.x, caster.y, caster, "ui.cast_style." .. (caster:calc("cast_style") or "default"))
      end
   end

   -- TODO buff: silence

   if not config["base.debug_no_spell_failure"] then
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

   -- TODO enchantment: enhances your spells

   local rapid_magic
   if caster:calc("can_cast_rapid_magic") and skill_data.is_rapid_magic then
      rapid_magic = 1 + (Rand.one_in(3) and 1 or 0) + (Rand.one_in(2) and 1 or 0)
   end

   if rapid_magic then
      for i = 1, rapid_magic do
         elona_sys_Magic.cast(skill_data.effect_id, params)
         if not Chara.is_alive(params.target) then
            local target = Action.find_target(caster)
            if target == nil or caster:reaction_towards(target) > 0 then
               break
            else
               params.target = target
            end
         end
      end
   else
      elona_sys_Magic.cast(skill_data.effect_id, params)
   end

   return true
end

local function gain_spell_and_casting_experience(skill_id, caster)
   local skill_entry = data["base.skill"]:ensure(skill_id)

   if caster:is_player() then
      Skill.gain_skill_exp(caster, skill_id, skill_entry.cost * 4 + 20, 4, 5)
   end

   Skill.gain_skill_exp(caster, "elona.casting", skill_entry.cost + 10, 5)
end

function Magic.cast_spell(skill_id, caster, use_mp)
   local success = Magic.do_cast_spell(skill_id, caster, use_mp)
   if success then
      gain_spell_and_casting_experience(skill_id, caster)
      return true
   end

   return false
end

local function damage_sp_action(chara, skill_data)
   if not chara:is_player() then
      return
   end


end

function Magic.do_action(skill_id, caster)
   -- TODO: action: death word
   --
   local skill_data = data["base.skill"]:ensure(skill_id)

   local target = caster:get_target()
   local success, params = elona_sys_Magic.get_magic_location(skill_data.target_type,
                                                              skill_data.range,
                                                              caster,
                                                              "action",
                                                              target,
                                                              skill_data.ai_check_ranged_if_self,
                                                              skill_data.on_choose_target)

   if not success then
      return false
   end

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

   if params.no_effect and skill_data.message_nothing_happens then
      Gui.mes("common.nothing_happens")
      return true
   end

   local did_something = elona_sys_Magic.cast(skill_data.effect_id, params)

   return did_something
end

function Magic.apply_buff(buff_id, params)
   local buff = data["elona_sys.buff"]:ensure(buff_id)
   local target = params.target

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

   local power = buff:power(params)
   params.buff = power

   Effect.add_buff(target, buff_id, power.power, power.duration)

   if buff.on_apply then
      buff:on_apply(params)
   end
end

return Magic
