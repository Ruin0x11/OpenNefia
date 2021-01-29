local Enum = require("api.Enum")
local Const = require("api.Const")
local Chara = require("api.Chara")
local Combat = require("mod.elona.api.Combat")
local Feat = require("api.Feat")
local Gui = require("api.Gui")
local Input = require("api.Input")
local Item = require("api.Item")
local Map = require("api.Map")
local Rand = require("api.Rand")
local Skill = require("mod.elona_sys.api.Skill")
local Anim = require("mod.elona_sys.api.Anim")
local Action = require("api.Action")
local Effect = require("mod.elona.api.Effect")

local ElonaAction = {}

local function proc_shield_bash(chara, target)
   -- >>>>>>>> elona122/shade2/action.hsp:1213         if sync(cc):txt lang(name(cc)+"は盾で"+name(t ..
   local shield = chara:skill_level("elona.shield")
   local do_bash = math.clamp(math.sqrt(shield) - 3, 1, 5) + ((chara:calc("has_shield_bash") and 5) or 0)
   if Rand.percent_chance(do_bash) then
      Gui.mes_visible("action.melee.shield_bash", chara)
      target:damage_hp(Rand.rnd(shield) + 1, chara)
      target:apply_effect("elona.dimming", 50 + math.floor(math.sqrt(shield)) * 15)
      target:add_effect_turns("elona.paralysis", Rand.rnd(3))
   end
   -- <<<<<<<< elona122/shade2/action.hsp:1216         cParalyze(tc)+=rnd(3) ..
end

-- >>>>>>>> elona122/shade2/action.hsp:1219     repeat sizeBody ..
local function body_part_where_equipped(flag)
   return function(entry) return entry.equipped and entry.equipped:calc(flag) end
end

function ElonaAction.get_melee_weapons(chara)
   local pred = body_part_where_equipped "is_melee_weapon"
   return chara:iter_body_parts():filter(pred):extract("equipped")
end
-- <<<<<<<< elona122/shade2/action.hsp:1229     return ..

function ElonaAction.melee_attack(chara, target)
   -- >>>>>>>> elona122/shade2/action.hsp:1197 *act_melee ..
   -- TODO ai damage reaction

   if chara:calc("is_wielding_shield") then
      proc_shield_bash(chara, target)
   end

   local attack_number = 0

   for _, weapon in ElonaAction.get_melee_weapons(chara) do
      local skill = weapon:calc("skill")
      attack_number = attack_number + 1
      ElonaAction.physical_attack(chara, weapon, target, skill, 0, attack_number)
   end

   if attack_number == 0 then
      ElonaAction.physical_attack(chara, nil, target, "elona.martial_arts", 0, attack_number, false)
   end
   -- <<<<<<<< elona122/shade2/action.hsp:1229     return ..
end

function ElonaAction.get_ranged_weapon_and_ammo(chara)
   local pred = body_part_where_equipped "is_ranged_weapon"
   local ranged = chara:iter_body_parts():filter(pred):extract("equipped"):nth(1)

   pred = body_part_where_equipped "is_ammo"
   local ammo = chara:iter_body_parts():filter(pred):extract("equipped"):nth(1)

   if ranged == nil then
      return nil, "no_ranged_weapon"
   end

   local skill = ranged:calc("skill")
   if not ammo and skill ~= "elona.throwing" then
      return nil, "no_ammo"
   end

   if ammo and ammo:calc("skill") ~= skill then
      return nil, "wrong_ammo"
   end

   return ranged, ammo
end

function ElonaAction.ranged_attack(chara, target, weapon, ammo)
   -- >>>>>>>> elona122/shade2/action.hsp:1148 *act_fire ..
   local ammo_enchantment_id = nil
   local ammo_enchantment_data = nil

   if ammo then
      local enc = ammo.params.ammo_loaded
      if enc then
         if enc.params.ammo_current <= 0 then
            Gui.mes("action.ranged.load_normal_ammo")
            ammo.params.ammo_loaded = nil
         else
            -- get the `base.ammo_enchantment` ID of this InstancedEnchantment
            ammo_enchantment_id = enc.params.ammo_enchantment_id
            ammo_enchantment_data = data["base.ammo_enchantment"]:ensure(ammo_enchantment_id)

            if chara:is_player() then
               if chara.stamina < Const.FATIGUE_LIGHT and chara.stamina < Rand.rnd(Const.FATIGUE_LIGHT * 1.5) then
                  Gui.mes("magic.common.too_exhausted")
                  chara:damage_sp(ammo_enchantment_data.stamina_cost / 2 + 1)
                  return true
               end
               chara:damage_sp(ammo_enchantment_data.stamina_cost+ 1)
               enc.params.ammo_current = enc.params.ammo_current - 1
            end
         end
      end
   end

   local skill = weapon:calc("skill")

   if ammo_enchantment_data and ammo_enchantment_data.on_ranged_attack then
      ammo_enchantment_data.on_ranged_attack(chara, weapon, target, skill, ammo, ammo_enchantment_id)
   else
      ElonaAction.physical_attack(chara, weapon, target, skill, 0, 0, true, ammo, ammo_enchantment_id)
   end

   return true
   -- <<<<<<<< elona122/shade2/action.hsp:1195 	return ..
end

local function show_miss_text(chara, target, extra_attacks)
   -- >>>>>>>> shade2/action.hsp:1365 	if hit=atkEvade:if sync(cc){ ...
   if not Map.is_in_fov(chara.x, chara.y) then
      return
   end
   if extra_attacks > 0 then
      Gui.mes("damage.furthermore")
      Gui.mes_continue_sentence()
   end
   if target:is_ally() then
      Gui.mes("damage.miss.ally", chara, target)
   else
      Gui.mes("damage.miss.other", chara, target)
   end
   -- <<<<<<<< shade2/action.hsp:1368 		} ...
end

local function show_evade_text(chara, target, extra_attacks)
   -- >>>>>>>> shade2/action.hsp:1369 	if hit=atkEvadePlus:if sync(cc){ ...
   if not Map.is_in_fov(chara.x, chara.y) then
      return
   end
   if extra_attacks > 0 then
      Gui.mes("damage.furthermore")
      Gui.mes_continue_sentence()
   end
   if target:is_ally() then
      Gui.mes("damage.evade.ally", chara, target)
   else
      Gui.mes("damage.evade.other", chara, target)
   end
   -- <<<<<<<< shade2/action.hsp:1372 		} ...
end

function ElonaAction.play_ranged_animation(chara, start_x, start_y, end_x, end_y, attack_skill, weapon)
   local chip, sound

   local color = {255, 255, 255}

   -- >>>>>>>> shade2/screen.hsp:654 	preparePicItem 6,aniCol ...
   if attack_skill == "elona.bow" then
      chip = "elona.item_projectile_arrow"
      sound = "base.bow1"
   elseif attack_skill == "elona.crossbow" then
      chip = "elona.item_projectile_bolt"
      sound = "base.bow1"
   elseif attack_skill == "elona.firearm" then
      if table.set(weapon.proto.categories)["elona.equip_ranged_laser_gun"] then
         chip = "elona.item_projectile_laser"
         sound = "base.laser1"
      else
         chip = "elona.item_projectile_bullet"
         sound = "base.gun1"
      end
   else
      chip = weapon:calc("image")
      sound = "base.throw1"
   end
   -- <<<<<<<< shade2/screen.hsp:665 	if animeId=aniArrow	:snd seArrow1 ...

   if chara:is_in_fov() then
      local cb = Anim.ranged_attack(start_x, start_y, end_x, end_y, chip, color, sound, nil)
      Gui.start_draw_callback(cb)
   end
end

local function do_physical_attack(chara, weapon, target, attack_skill, extra_attacks, attack_number, is_ranged, ammo, ammo_enc)
   -- >>>>>>>> elona122/shade2/action.hsp:1233 *act_attack ..
   if not Chara.is_alive(chara) or not Chara.is_alive(target) then
      return
   end

   if chara:has_effect("elona.fear") then
      Gui.mes("damage.is_frightened", chara)
      return
   end
   -- <<<<<<<< elona122/shade2/action.hsp:1237  ..

   local event_params = {
      weapon = weapon,
      target = target,
      is_ranged = is_ranged,
      ammo = ammo,
      attack_skill = attack_skill,
      extra_attacks = extra_attacks,
   }

   local result = chara:emit("elona.before_physical_attack", event_params, {blocked=false})
   if result.blocked then
      return
   end

   -- >>>>>>>> elona122/shade2/action.hsp:1248 	if attackRange=true:call anime,(animeId=attackSki ..
   if is_ranged then
      -- TODO: inherit color if weapon has enchantments
      ElonaAction.play_ranged_animation(chara, chara.x, chara.y, target.x, target.y, attack_skill, weapon)
   end
   -- <<<<<<<< elona122/shade2/action.hsp:1248 	if attackRange=true:call anime,(animeId=attackSki ..

   attack_skill = attack_skill or "elona.martial_arts"

   -- >>>>>>>> elona122/shade2/action.hsp:1253 	hit=calcAttackHit() ..
   local hit = Combat.calc_attack_hit(chara, weapon, target, attack_skill, attack_number, is_ranged, ammo)
   local did_hit = hit == "hit" or hit == "critical"
   local is_critical = hit == "critical"

   if did_hit then
      if chara:is_player() then
         if is_critical then
            Gui.mes_c("damage.critical_hit", "Red")
            Gui.play_sound("base.atk2", target.x, target.y)
         else
            Gui.play_sound("base.atk1", target.x, target.y)
         end
      end

      local raw_damage = Combat.calc_attack_damage(chara, weapon, target, attack_skill, is_ranged, is_critical, ammo, ammo_enc)
      local damage = raw_damage.damage
      local original_damage = raw_damage.original_damage

      local play_animation = chara:is_player()
      if play_animation then
         local damage_percent = damage * 100 / target:calc("max_hp")
         local kind = data["base.skill"]:ensure(attack_skill).attack_animation or 0
         local anim = Anim.melee_attack(target.x, target.y, target:calc("breaks_into_debris"), kind, damage_percent, is_critical)
         Gui.start_draw_callback(anim)
      end

      local element, element_power
      if weapon then
         if weapon:calc("quality") >= Enum.Quality.Great then
            -- TODO ego name
            if Rand.one_in(5) then
               Gui.mes_c_visible("damage.wields_proudly", chara, "SkyBlue", weapon)
            end
         end
      else
         element = chara:calc("unarmed_element")
         element_power = chara:calc("unarmed_element_power")
         if element and not element_power then
            element_power = 0
         end
      end

      local tense = "enemy"
      if not target:is_ally() then
         tense = "ally"
      end

      local killed, base_damage, actual_damage = target:damage_hp(damage, chara, {element=element,element_power=element_power,extra_attacks=extra_attacks,weapon=weapon,message_tense=tense})
      -- <<<<<<<< elona122/shade2/action.hsp:1292  ..

      chara:emit("elona.on_physical_attack_hit", {weapon=weapon,target=target,hit=hit,damage=damage,base_damage=base_damage,actual_damage=actual_damage,original_damage=original_damage,is_ranged=is_ranged,attack_skill=attack_skill,killed=killed,ammo=ammo,ammo_enchantment=ammo_enc})
   else
      local play_sound = chara:is_player()
      if play_sound then
         Gui.play_sound("base.miss", target.x, target.y)
      end
      chara:emit("elona.on_physical_attack_miss", {weapon=weapon,target=target,hit=hit,is_ranged=is_ranged,attack_skill=attack_skill})
   end

   if hit == "miss" then
      show_miss_text(chara, target, extra_attacks)
   elseif hit == "evade" then
      show_evade_text(chara, target, extra_attacks)
   end

   target:interrupt_activity()
   -- TODO living weapon

   chara:emit("elona.after_physical_attack", {weapon=weapon,target=target,hit=hit,is_ranged=is_ranged,attack_skill=attack_skill})
end

function ElonaAction.physical_attack(chara, weapon, target, attack_skill, extra_attacks, attack_number, is_ranged, ammo, ammo_enc)
   local attacks = extra_attacks
   local going

   repeat
      do_physical_attack(chara, weapon, target, attack_skill, extra_attacks, attack_number, is_ranged, ammo, ammo_enc)
      going = false
      -- >>>>>>>> elona122/shade2/action.hsp:1383     if extraAttack=false{ ..
      if attacks == 0 then
         if is_ranged then
            if Rand.percent_chance(chara:calc("extra_ranged_attack_rate") or 0) then
               attacks = attacks + 1
               going = true
               ammo_enc = nil
            end
         else
            if Rand.percent_chance(chara:calc("extra_melee_attack_rate") or 0) then
               attacks = attacks + 1
               going = true
            end
         end
      end
      -- <<<<<<<< elona122/shade2/action.hsp:1389     } ..
   until not going
end

-- proc_damage_events_flag
-- 1:
--   - Print element damage 0 if chara is not killed
--   - do not trigger splitting behavior
-- 2:
--   - print "is scratched", "is slightly wounded", etc.
--   - print element text 1 if target is not party
--   - print transformed into meat/destroyed/minced if target is not party

function ElonaAction.prompt_really_attack(chara, target)
   Gui.mes(Action.target_level_text(chara, target))
   Gui.mes("action.really_attack", target)
   return Input.yes_no()
end

function ElonaAction.bash(chara, x, y)
   -- >>>>>>>> elona122/shade2/action.hsp:388     if map(x,y,5)!0{ ..
   for _, item in Item.at(x, y) do
      local result = item:emit("elona_sys.on_bash", {chara=chara}, nil)
      if result then return result end
   end

   local target = Chara.at(x, y)
   if target then
      if not target:has_effect("elona.sleep") then
         if chara:is_player() and target:reaction_towards(chara) > 0 then
            if not ElonaAction.prompt_really_attack(chara, target) then
               return "player_turn_query"
            end
         end
         if target:has_effect("elona.choking") then
            Gui.play_sound("base.bash1")
            Gui.mes("action.bash.choked.execute", chara, target)
            local killed = target:damage_hp(chara:skill_level("elona.stat_strength") * 5, chara)
            if not killed then
               Gui.mes("action.bash.choked.spits", target)
               target:remove_effect("elona.choking")
               Skill.modify_impression(target, 10)
            end
         else
            Gui.play_sound("base.bash1")
            Gui.mes("action.bash.execute", chara, target)
            chara:act_hostile_towards(target)
         end
      else
         Gui.play_sound("base.bash1")
         Gui.mes("action.bash.execute", chara, target)
         Gui.mes("action.bash.disturbs_sleep", chara, target)
         Effect.modify_karma(chara, -1)
         target:set_emotion_icon("elona.angry", 4)
      end
      target:remove_effect("elona.sleep")
      return "turn_end"
   end

   for _, feat in Feat.at(x, y) do
      local result = feat:emit("elona_sys.on_bash", {chara=chara})
      if result then return true end
   end

   Gui.mes("action.bash.air", chara)
   Gui.play_sound("base.miss", x, y)

   return true
   -- <<<<<<<< elona122/shade2/action.hsp:467     goto *turn_end ..
end

function ElonaAction.read(chara, item)
   local result = item:emit("elona_sys.on_item_read", {chara=chara,triggered_by="read"}, "turn_end")

   return result
end

function ElonaAction.eat(chara, item)
   -- >>>>>>>> elona122/shade2/action.hsp:364     if cc=pc{ ..
   if chara:is_player() then
      if item.chara_using and item.chara_using.uid ~= chara.uid then
         Gui.mes("action.someone_else_is_using")
         return "player_turn_query"
      end
   elseif item.chara_using then
      local using = item.chara_using
      if using.uid ~= chara.uid then
         using:finish_activity()
         assert(item.chara_using == nil)
         if chara:is_in_fov() then
            Gui.mes("action.eat.snatches", chara, using)
         end
      end
   end

   chara:start_activity("elona.eating", {food=item})

   return "turn_end"
   -- <<<<<<<< elona122/shade2/action.hsp:372     goto *turn_end ..
end

function ElonaAction.drink(chara, item)
   local result = item:emit("elona_sys.on_item_drink", {chara=chara,triggered_by="potion"}, "turn_end")
   return result
end

function ElonaAction.zap(chara, item)
   local result = item:emit("elona_sys.on_item_zap", {chara=chara,triggered_by="wand"}, "turn_end")
   return result
end

function ElonaAction.use(chara, item)
   local result = item:emit("elona_sys.on_item_use", {chara=chara,triggered_by="use"}, "turn_end")
   return result
end

function ElonaAction.open(chara, item)
   local result = item:emit("elona_sys.on_item_open", {chara=chara,triggered_by="open"}, "turn_end")
   return result
end

function ElonaAction.dip(chara, item)
   Gui.mes("common.nothing_happens")
   return "player_turn_query"
end

function ElonaAction.throw(chara, item)
   Gui.mes("common.nothing_happens")
   return "player_turn_query"
end

function ElonaAction.trade(player, target)
   local cb = function(i) i.identify_state = Enum.IdentifyState.Full end
   target:iter_items():each(cb)
   local result, canceled = Input.query_inventory(player, "elona.inv_trade", {target=target})
   return result, canceled
end

return ElonaAction
