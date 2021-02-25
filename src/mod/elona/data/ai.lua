local Gui = require("api.Gui")
local Enum = require("api.Enum")
local Effect = require("mod.elona.api.Effect")
local SkillCheck = require("mod.elona.api.SkillCheck")
local Const = require("api.Const")
local I18N = require("api.I18N")
local AiUtil = require("mod.elona.api.AiUtil")
local Log = require("api.Log")
local Itemgen = require("mod.tools.api.Itemgen")
local Skill = require("mod.elona_sys.api.Skill")

local Action = require("api.Action")
local Item = require("api.Item")
local Event = require("api.Event")
local ElonaAction = require("mod.elona.api.ElonaAction")
local Ai = require("api.Ai")
local Chara = require("api.Chara")
local Pos = require("api.Pos")
local Rand = require("api.Rand")
local elona_Magic = require("mod.elona.api.Magic")

local function default_target(chara)
   return chara:get_party_leader() or Chara.player()
end

local function move_towards_target(chara, params)
   local target = params.target or chara:get_target()
   assert(target ~= nil)

   return AiUtil.move_towards_target(chara, target, params.retreat)
end

local function stay_near_position(chara, params)
   return AiUtil.stay_near_position(chara, params.x, params.y, params.max_dist)
end

local function go_to_preset_anchor(chara, params)
   if chara.ai_state.is_anchored then
      return Ai.run("elona.stay_near_position", chara, { x = chara.ai_state.anchor_x, y = chara.ai_state.anchor_y })
   end

   return false
end

local function wander(chara, params)
   local map = chara:current_map()

   local calm_action = chara.ai_actions and chara.ai_actions.calm_action

   -- >>>>>>>> shade2/ai.hsp:318 	if cAiCalm(cc)=aiRoam{ ...
   if calm_action == "elona.calm_roam" then
      local nx, ny = Pos.random_direction(chara.x, chara.y)
      if map:can_access(nx, ny) then
         Action.move(chara, nx, ny)
         return true
      end
   end
   -- <<<<<<<< shade2/ai.hsp:323 		} ..

   -- >>>>>>>> shade2/ai.hsp:325 	if cAiCalm(cc)=aiDull{ ...
   if calm_action == "elona.calm_dull" then
      if map:calc("has_anchored_npcs") then
         return Ai.run("elona.stay_near_position", chara, { x = chara.initial_x, y = chara.initial_y })
      else
         local nx, ny = Pos.random_direction(chara.x, chara.y)
         if map:can_access(nx, ny) then
            Action.move(chara, nx, ny)
            return true
         end
      end
   end
   -- <<<<<<<< shade2/ai.hsp:336 		} ..

   return false
end

local function follow_player(chara, params)
   if chara.ai_actions and chara.ai_actions.calm_action == "elona.calm_follow" then
      local target = Chara.player()
      if Chara.is_alive(target) then
         chara:set_target(target)
         return Ai.run("elona.move_towards_target", chara)
      end
   end
end

local function do_drink(chara, _, result)
   -- >>>>>>>> shade2/ai.hsp:211 	if cDrunk(cc)!0:if sync(cc):if cnRace(cc)="cat"{ ...
   if result then
      return result
   end
   if not chara:has_effect("elona.drunk") or not chara:is_in_fov() or chara.race ~= "elona.cat" then
      return result
   end

   if chara:effect_turns("elona.drunk") < 5 then
      chara:add_effect_turns("elona.drunk", 40)
   end

   if I18N.language() == "jp" then
      local text, color
      if Rand.one_in(3) then
         text = Rand.choice { "「米さ米種だろ♪」","「飲ま飲まイェイ！！」","「飲ま飲ま飲まイェイ！！」" }
      elseif Rand.one_in(4) then
         text = Rand.choice { "「字ベロ♪指♪ラマ♪ｸﾏｰ!!して♪パンチラ♪」","「アロー♪アーロン♪スゲェ♪ピカソ♪算段ビーフ♪」","「キスすごい肉♪脱線してんの♪さらに肉♪」" }
      elseif Rand.one_in(4) then
         text = Rand.choice { "「キープダルシム♪アゴスタディーイェイ♪並フェイスで大きい筆入れ♪」","「ハロー♪猿ー♪すげー♪うん入る♪」" }
      elseif Rand.one_in(4) then
         text = " *ﾋﾟﾛﾘ〜ﾋﾟﾛﾘ〜* "
         color = "Blue"
      else
         text = Rand.choice { "「マイアヒー♪」","「マイアフゥー♪」","「マイアホー♪」" }
      end
      Gui.mes_c(text, color)
   else
      local text
      if Rand.one_in(2) then
         text = Rand.choice { "Vrei sa pleci dar♪","Numa numa yay!!","Numa numa numa yay!!" }
      else
         text = Rand.choice { "Mai-Ya-Hi♪","Mai-Ya-Hoo♪","Mai-Ya-Ha Ma Mi A♪" }
      end
      Gui.mes_c(text)
   end
   -- <<<<<<<< shade2/ai.hsp:226 	}	 ..
end
Event.register("elona.on_ai_calm_action", "Drink if cat", do_drink, { priority = 40000 })

local function do_sleep(chara, _, result)
   -- >>>>>>>> shade2/ai.hsp:228 	if cc>maxFollower : if (mType=mTypeTown)or(mType= ...
   if result then
      return result -- TODO move to event system
   end
   if chara:is_ally() then
      return
   end

   if chara:current_map():has_type {"elona.town", "elona.guild"} then
      local hour = save.base.date.hour
      if hour >= 22 or hour < 7 then
         if not chara:has_activity() then
            if Rand.one_in(100) then
               chara:apply_effect("elona.sleep", 4000)
            end
         end
      end
   end

   return result
   -- <<<<<<<< shade2/ai.hsp:230 		} ..
end
Event.register("elona.on_ai_calm_action", "Sleep if nighttime", do_sleep, { priority = 50000 })

local function do_eat(chara, _, result)
   if result then
      return result -- TODO move to event system
   end

   -- >>>>>>>> shade2/ai.hsp:232 	if cAiItem(cc)=0:if cRelation(cc)!cAlly{ ...
   if chara.item_to_use or chara:relation_towards(Chara.player()) >= Enum.Relation.Ally then
      return result
   end
   -- <<<<<<<< shade2/ai.hsp:232 	if cAiItem(cc)=0:if cRelation(cc)!cAlly{ ..

   -- >>>>>>>> shade2/ai.hsp:259 		if cHunger(cc)<=defAllyHunger{ ...
   if chara.nutrition > Const.ALLY_HUNGER_THRESHOLD then
      return result
   end

   if not chara:is_in_fov() or not Rand.one_in(5) then
      if chara:calc("is_anorexic") then
         chara.nutrition = chara.nutrition + 5000
      else
         chara.nutrition = chara.nutrition - 3000
      end
   else
      local filter = {
         level = 20
      }

      local choice = Rand.rnd(4)

      if choice == 0 or chara:calc("is_anorexic") then
         filter.categories = "elona.food"
      elseif choice == 1 then
         filter.categories = "elona.drink"
      else
         filter.categories = "elona.drink_alcohol"
      end

      local item = Itemgen.create(nil, nil, filter, chara)
      if item then
         if item._id == "elona.molotov" and Rand.one_in(5) then
            item:remove_ownership()
         else
            chara.item_to_use = item
            if not chara:calc("is_anorexic") then
               chara.nutrition = chara.nutrition + 5000
            else
               chara.nutrition = chara.nutrition - 3000
            end
         end
      end
   end
   -- <<<<<<<< shade2/ai.hsp:276 			} ..
end
Event.register("elona.on_ai_calm_action", "Eat if hungry", do_eat)

local function do_eat_ally(chara, _, result)
   -- >>>>>>>> shade2/ai.hsp:148 			if map(cX(cc),cY(cc),4)!0{ ...
   if result then
      return result
   end
   local target = chara:get_target()
   if not target or not target:is_player() then
      return result
   end

   local item = Item.at(chara.x, chara.y, chara:current_map()):nth(1)
   if item then
      if chara.nutrition <= Const.ALLY_HUNGER_THRESHOLD then
         if item:has_category("elona.food")
            and item:calc("own_state") <= Enum.OwnState.None
            and item:calc("curse_state") >= Enum.CurseState.Normal
         then
            ElonaAction.eat(chara, item)
            return true
         end

         if item:has_category("elona.furniture_well")
            and item:calc("own_state") <= Enum.OwnState.NotOwned
            and item.params.amount_remaining >= -5
            and item.params.amount_dryness < 20
            and item._id ~= "elona.holy_well"
         then
            ElonaAction.drink(chara, item)
            return true
         end
      end
   end
   -- <<<<<<<< shade2/ai.hsp:158 				} ..

   return result
end

Event.register("elona.on_ai_ally_action", "Eat if hungry", do_eat_ally)

-- >>>>>>>> shade2/ai.hsp:342 	if mType=mTypeTown:if cc<maxFollower{ ...
local function sell_ores(chara)
   local items_sold = 0
   local gold_earned = 0
   local filter = function(item) return item:has_category("elona.ore") end
   local each = function(item)
      local gold_value = item:calc("value") * item.amount
      items_sold = items_sold + item.amount
      gold_earned = gold_earned + gold_value
      item:remove_ownership()

      chara.gold = chara.gold + gold_value
   end

   chara:iter_inventory():filter(filter):each(each)

   if items_sold > 0 then
      Gui.mes_c("ai.ally.sells_items", "SkyBlue", chara, items_sold, gold_earned)
   end
end

local function train_potential(chara)
   local cost = chara:calc("level") * 500
   if chara.gold < cost then
      return false
   end

   chara.gold = chara.gold - cost

   Gui.play_sound("base.ding2")
   Gui.mes_c("ai.ally.visits_trainer", "SkyBlue", chara)

   for _ = 1, 4 do
      local skill
      for _ = 1, 9999 do
         if Rand.one_in(4) then
            skill = Rand.choice(Skill.iter_attributes())
         else
            skill = Rand.choice(Skill.iter_weapon_proficiencies())
         end

         if chara:has_skill(skill._id) then
            chara:mod_skill_potential(skill._id, 4)
            break
         end
      end
   end

   chara:refresh()

   return true
end

local function sell_ores_and_train_potential(chara, _, result)
   local map = chara:current_map()
   if not chara:is_in_player_party() or not map or not map:has_type("town") then
      return result
   end

   if Rand.one_in(100) then
      sell_ores(chara)
   end

   if Rand.one_in(100) then
      train_potential(chara)
   end

   return result
end

Event.register("elona.on_ai_ally_action", "If ally and in town, sell ores and train potential", sell_ores_and_train_potential)
-- <<<<<<<< shade2/ai.hsp:371 		} ..

local function on_ai_calm_actions(chara, params)
   if not Rand.one_in(5) then
      return true
   end

   local blocked = chara:emit("elona.on_ai_calm_action", params, false)
   if blocked then
      return true
   end
end

local function on_ai_ally_actions(chara, params)
   local blocked = chara:emit("elona.on_ai_ally_action", params, false)
   if blocked then
      return true
   end

   -- >>>>>>>> shade2/ai.hsp:159 			if cArea(cc)=gArea : if cBit(cHired,cc)=false : ...
   -- TODO shopkeeper idle movement
   -- <<<<<<<< shade2/ai.hsp:159 			if cArea(cc)=gArea : if cBit(cHired,cc)=false : ..

   return false
end

local idle_action = {
   "elona.follow_player",
   "elona.on_ai_calm_actions",
   "elona.go_to_preset_anchor",
   "elona.wander",
}

local function attempt_to_melee(chara, params)
   -- >>>>>>>> shade2/ai.hsp:519 	if distance=1{ ...
   local target = chara:get_target()
   local dist = Pos.dist(target.x, target.y, chara.x, chara.y)
   if dist == 1 then
      local target_damage_reaction = target:calc("damage_reaction")
      if not Chara.is_alive(target) then return false end

      if target_damage_reaction then
         local ranged, ammo = ElonaAction.get_ranged_weapon_and_ammo(chara)
         if ranged and dist < Const.AI_RANGED_ATTACK_THRESHOLD and chara:has_los(target.x, target.y) then
            ElonaAction.ranged_attack(chara, target, ranged, ammo)
            return true
         end

         if target_damage_reaction == "elona.cut" and chara.hp < chara:calc("max_hp") / 2 then
            return false
         end
      end

      ElonaAction.melee_attack(chara, target)

      return true
   end

   return false
   -- <<<<<<<< shade2/ai.hsp:521 	} ..
end

local function basic_action(chara, params)
   -- >>>>>>>> shade2/ai.hsp:470 *ai_actMain ..
   local target = chara:get_target()

   if target:is_party_leader() then
      save.base.parties:get(target:get_party()).metadata.leader_attacker = chara.uid
   end

   if not chara.ai_actions then
      return Ai.run("elona.melee", chara)
   end

   local choosing_sub_act = Rand.percent_chance(chara.ai_actions.sub_action_chance or 0)
   local choice

   if choosing_sub_act then
      if chara.ai_actions.sub then
         choice = Rand.choice(chara.ai_actions.sub)
      end
   else
      if chara.ai_actions.main then
         choice = Rand.choice(chara.ai_actions.main)
      end
   end

   if choice then
      if Ai.run(choice.id, chara, choice) then
         return true
      end

      if choice.id == "elona.melee" then
         return true
      end
   end

   return Ai.run("elona.melee", chara)
   -- <<<<<<<< shade2/ai.hsp:527 	 ..
end

local function search_for_target(chara, params)
   local search_radius = params.search_radius or 5
   local x, y
   local map = chara:current_map()

   for j=0,search_radius - 1 do
      y = chara.y - 2 + j

      if y >= 0 and y <= map:height() then
         for i=0,search_radius - 1 do
            x = chara.x - 2 + i

            if x >= 0 and y < map:width() then
               local on_cell = Chara.at(x, y, map)
               if on_cell ~= nil and not on_cell:is_player() and not on_cell:calc("is_not_targeted_by_ai") then
                  if chara:relation_towards(on_cell) <= Enum.Relation.Enemy then
                     if not chara:calc("is_not_targeted_by_ai") then
                        chara:set_target(on_cell, 30)
                        chara:set_emotion_icon("elona.angry", 2)
                        return true
                     end
                  end
               end
            end
         end
      end
   end

   return false
end

local function decide_ally_target(chara, params)
   chara:set_aggro(chara:get_target(), chara:get_aggro() - 1)

   local target = chara:get_target()
   local being_targeted = Chara.is_alive(target)
      and target:get_target() ~= nil
      and target:get_target() == chara

   local target_not_important = target ~= nil
      and chara:relation_towards(target) >= Enum.Relation.Hate
      and not being_targeted

   if not Chara.is_alive(target)
      or target:is_party_leader_of(chara)
      or chara:get_aggro(target) <= 0
      or target_not_important
   then
      -- Follow the leader.
      chara:set_target(chara:get_party_leader())

      local party = save.base.parties:get(chara:get_party())
      local map = chara:current_map()
      local leader_attacker = map:get_object_of_type("base.chara", party.metadata.leader_attacker)
      if leader_attacker ~= nil then
         if Chara.is_alive(leader_attacker) then
            if chara:relation_towards(leader_attacker) <= Enum.Relation.Enemy then
               if chara:has_los(leader_attacker.x, leader_attacker.y) then
                  chara:set_target(leader_attacker, 5)
               end
            end
         else
            party.metadata.leader_attacker = nil
         end
      end

      if chara:get_target() == nil or chara:get_target():is_party_leader_of(chara) then
         local leader = chara:get_party_leader()

         if Chara.is_alive(leader) then
            local leader_target = leader:get_target()
            if Chara.is_alive(leader_target) and leader:relation_towards(leader_target) <= Enum.Relation.Enemy then
               if chara:has_los(leader_target.x, leader_target.y) then
                  chara:set_target(leader_target, 5)
               end
            end
         end
      end

      target = chara:get_target()
      if target and not Effect.is_visible(target, chara) and Rand.one_in(5) then
         chara:set_target(chara:get_party_leader())
      end
   end
end

local function try_to_heal(chara, params)
   local threshold = params.threshold or chara:calc("max_hp") / 4
   local chance = params.chance or 5
   if chara.hp < threshold then
      if chara.mp > 0 and Rand.one_in(chance) then
         return Ai.run(params.action.id, chara. params.action)
      end
   end
end

local function try_to_use_item(chara, params, result)
   -- >>>>>>>> shade2/ai.hsp:134 	if a=fltFood:if (cRelation(cc)=cAlly)&(cHunger(cc ...
   if not Item.is_alive(chara.item_to_use) or not chara:has_item(chara.item_to_use) then
      chara.item_to_use = nil
      return result
   end

   local item = chara.item_to_use

   if chara:relation_towards(Chara.player()) ~= Enum.Relation.Neutral then
      chara.item_to_use = nil
   end

   if item:has_category("elona.food")
      and not (chara:relation_towards(Chara.player()) == Enum.Relation.Ally
                  and chara.nutrition > Const.ALLY_HUNGER_THRESHOLD)
   then
      ElonaAction.eat(chara, item)
      return true
   end

   if item:has_category("elona.drink") then
      ElonaAction.drink(chara, item)
      return true
   end

   if item:has_category("elona.scroll") then
      ElonaAction.read(chara, item)
      return true
   end

   chara.item_to_use = nil

   return result
   -- <<<<<<<< shade2/ai.hsp:136 		} ..
end

local function decide_ally_idle_action(chara, params)
   -- >>>>>>>> shade2/ai.hsp:147 		if cRelation(cc)=cAlly:if tc=pc{ ...
   local target = chara:get_target()
   if Chara.is_alive(target) then
      -- item on space

      if chara:relation_towards(Chara.player()) >= Enum.Relation.Ally then
         if Ai.run("elona.on_ai_ally_actions", chara) then
            return true
         end
      end

      local dist = Pos.dist(target.x, target.y, chara.x, chara.y)

      if dist > 2 or Rand.one_in(3) then
         return Ai.run("elona.move_towards_target", chara)
      end

      return Ai.run("elona.idle_action", chara)
   end

   return false
   -- <<<<<<<< shade2/ai.hsp:161 			} ..
end

local function decide_targeted_action(chara, params)
   -- >>>>>>>> shade2/ai.hsp:144 		if cBlind(cc)!0	  : if rnd(10)>2 : goto *ai_calm ...
   if chara:has_effect("elona.blindness") then
      if Rand.rnd(10) > 2 then
         return Ai.run("elona.idle_action", chara)
      end
   end
   if chara:has_effect("elona.confusion") then
      if Rand.rnd(10) > 3 then
         return Ai.run("elona.idle_action", chara)
      end
   end

   local target = chara:get_target()
   if chara:is_in_player_party() and target and target:is_player() then
      return Ai.run("elona.decide_ally_idle_action", chara)
   end

   if chara:has_effect("elona.fear") then
      return Ai.run("elona.move_towards_target", chara, {retreat=true})
   end

   if chara:has_effect("elona.blindness") then
      if Rand.one_in(3) then
         return Ai.run("elona.idle_action", chara)
      end
   end

   local target = chara:get_target()
   local dist = Pos.dist(target.x, target.y, chara.x, chara.y)
   if dist ~= chara.ai_distance then
      if Rand.percent_chance(chara.ai_move_chance) then
         return Ai.run("elona.move_towards_target", chara)
      end
   end

   return Ai.run("elona.basic_action", chara)
   -- <<<<<<<< shade2/ai.hsp:172 		} ..
end

local function ai_talk(chara, params)
   if chara.taught_words ~= nil then
      if Rand.one_in(30) then
         Gui.mes_c(chara.taught_words, "SkyBlue")
         return false
      end
   end

   if not chara:calc("is_talk_silenced") then
      if chara.turns_alive % 5 == 0 then
         if Rand.one_in(4) then
            local leader = chara:get_party_leader()
            if leader and Pos.is_in_square(chara.x, chara.y, leader.x, leader.y, 20) then
               if chara.aggro <= 0 then
                  chara:say("base.ai_calm")
               else
                  chara:say("base.ai_aggro")
               end
            end
         end
      end
   end
end

local function elona_default_ai(chara, params)
   local blocked = chara:emit("elona.before_default_ai_action")
   if blocked then
      return true
   end

   if chara:is_in_player_party() then
      Ai.run("elona.decide_ally_target", chara)
   end

   local target = chara:get_target()
   if target == nil or not Chara.is_alive(target) then
      chara:set_target(default_target(chara), 0)
   end

   -- TODO pet arena
   -- TODO noyel
   -- TODO mount
   blocked = chara:emit("elona.on_default_ai_action")
   if blocked then
      return true
   end

   Ai.run("elona.ai_talk", chara)

   local leader = chara:get_party_leader()
   if Chara.is_alive(leader) and leader:has_effect("elona.choking") then
      if Pos.dist(chara.x, chara.y, leader.x, leader.y) == 1 then
         ElonaAction.bash(chara, leader.x, leader.y)
         return true
      end
   else
      leader = Chara.player()
      if chara:relation_towards(leader) >= Enum.Relation.Neutral
         and Chara.is_alive(leader)
         and leader:has_effect("elona.choking")
         and Pos.dist(chara.x, chara.y, leader.x, leader.y) == 1
      then
         ElonaAction.bash(chara, leader.x, leader.y)
         return true
      end
   end

   if chara.ai_actions and chara.ai_actions.low_health_action then
      assert(chara.ai_actions.low_health_action)
      if Ai.run("elona.try_to_heal", chara, { action = chara.ai_actions.low_health_action, threshold = chara.ai_actions.low_health_threshold }) then
         return true
      end
   end

   if Ai.run("elona.try_to_use_item", chara) then
      return true
   end

   target = chara:get_target()
   if Chara.is_alive(target) and (chara:get_aggro(target) > 0 or chara:is_in_player_party()) then
      return Ai.run("elona.decide_targeted_action", chara)
   end

   if chara.turns_alive % 10 == 0 then
      Ai.run("elona.search_for_target", chara)
   end

   -- EVENT: on_search_for_target
   -- try to perceive player

   target = chara:get_target()
   if target:is_player() then
      local perceived = SkillCheck.try_to_perceive(target, chara)
      if perceived and chara:relation_towards(target) <= Enum.Relation.Enemy then
         chara:set_aggro(target, 30)
      end
   end

   return Ai.run("elona.idle_action", chara)
end

data:add_multi(
   "base.ai_action",
   {
      { _id = "on_ai_calm_actions",          act = on_ai_calm_actions },
      { _id = "on_ai_ally_actions",          act = on_ai_ally_actions },
      { _id = "stay_near_position",          act = stay_near_position },
      { _id = "wander",                      act = wander },
      { _id = "go_to_preset_anchor",         act = go_to_preset_anchor },
      { _id = "follow_player",               act = follow_player },
      { _id = "move_towards_target",         act = move_towards_target },
      { _id = "basic_action",                act = basic_action },
      { _id = "search_for_target",           act = search_for_target },
      { _id = "decide_ally_target",          act = decide_ally_target },
      { _id = "ai_talk",                     act = ai_talk },
      { _id = "try_to_heal",                 act = try_to_heal },
      { _id = "try_to_use_item",             act = try_to_use_item },
      { _id = "attempt_to_melee",            act = attempt_to_melee },
      { _id = "idle_action",                 act = idle_action },
      { _id = "decide_ally_idle_action",     act = decide_ally_idle_action },
      { _id = "decide_targeted_action",      act = decide_targeted_action },
      { _id = "elona_default_ai",            act = elona_default_ai },
   }
)

data:add {
   _type = "base.ai_action",
   _id = "melee",

   act = function(chara, params)
      -- >>>>>>>> shade2/ai.hsp:518 	 ...
      local target = chara:get_target()
      if not Chara.is_alive(target) then
         return false
      end

      local dist = Pos.dist(target.x, target.y, chara.x, chara.y)

      if dist == 1 then
         return Ai.run("elona.attempt_to_melee", chara)
      end

      if dist < Const.AI_RANGED_ATTACK_THRESHOLD and chara:has_los(target.x, target.y) then
         local ranged, ammo = ElonaAction.get_ranged_weapon_and_ammo(chara)
         if ranged then
            ElonaAction.ranged_attack(chara, target, ranged, ammo)
            return true
         end
      end

      if chara.ai_distance <= dist then
         if Rand.one_in(3) then
            return true
         end
      end

      if Rand.one_in(5) then
         chara:set_aggro(chara:get_target(), chara:get_aggro() - 1)
      end

      if Rand.percent_chance(chara.ai_move_chance) then
         return Ai.run("elona.idle_action", chara)
      end

      return true
      -- <<<<<<<< shade2/ai.hsp:528  ..
   end
}

data:add {
   _type = "base.ai_action",
   _id = "ranged",

   act = function(chara, params)
      -- >>>>>>>> shade2/ai.hsp:496 	if act=actRange{ ...
      local target = chara:get_target()
      if not Chara.is_alive(target) then
         return false
      end

      local dist = Pos.dist(target.x, target.y, chara.x, chara.y)

      if dist < Const.AI_RANGED_ATTACK_THRESHOLD and chara:has_los(target.x, target.y) then
         local ranged, ammo = ElonaAction.get_ranged_weapon_and_ammo(chara)
         if ranged then
            ElonaAction.ranged_attack(chara, target, ranged, ammo)
            return true
         end
      end

      return true
      -- <<<<<<<< shade2/ai.hsp:498 	} ...      local target = chara:get_target()
   end
}

data:add {
   _type = "base.ai_action",
   _id = "wait_melee",

   act = function(chara, params)
      -- >>>>>>>> shade2/ai.hsp:513 	if act=actWaitMelee{	 ...
      local target = chara:get_target()
      if not Chara.is_alive(target) then
         return false
      end

      local dist = Pos.dist(target.x, target.y, chara.x, chara.y)

      if dist == 1 then
         return Ai.run("elona.attempt_to_melee", chara)
      end

      if Rand.one_in(3) or chara:is_in_player_party() then
         if dist < Const.AI_RANGED_ATTACK_THRESHOLD and chara:has_los(target.x, target.y) then
            local ranged, ammo = ElonaAction.get_ranged_weapon_and_ammo(chara)
            if ranged then
               ElonaAction.ranged_attack(chara, target, ranged, ammo)
               return true
            end
         end
      end

      return true
      -- <<<<<<<< shade2/ai.hsp:517 	} ..
   end
}

data:add {
   _type = "base.ai_action",
   _id = "skill",

   act = function(chara, params)
      -- >>>>>>>> shade2/ai.hsp:500 	if act>=headSpell : if act<tailSpell{ ...
      local skill = data["base.skill"]:ensure(params.skill_id)
      if skill.type == "spell" then
         if chara.mp < chara:calc("max_mp") / 7 then
            if not Rand.one_in(3)
               or chara:is_in_player_party()
               or chara:calc("quality") >= Enum.Quality.Great
               or chara:calc("ai_regenerates_mana")
            then
               chara:heal_mp(chara:calc("level") / 4 + 5)
               return true
            end
         end
         local did_something = elona_Magic.cast_spell(skill._id, chara, true)
         if did_something then
            return true
         end
      end

      if skill.type == "action" then
         local did_something = elona_Magic.do_action(skill._id, chara)
         if did_something then
            return true
         end
      end

      return false
      -- <<<<<<<< shade2/ai.hsp:511 	} ..
   end
}

data:add {
   _type = "base.ai_action",
   _id = "throw_potion",

   act = function(chara, params)
      -- >>>>>>>> shade2/ai.hsp:478 		if (act>=headActThrow)&(act<tailActThrow):if dis ...
      local target = chara:get_target()
      local dist = Pos.dist(target.x, target.y, chara.x, chara.y)

      if dist < Const.AI_THROWING_ATTACK_THRESHOLD and chara:has_los(target.x, target.y) then
         local item_id
         if params.item_id then
            item_id = params.item_id
         else
            item_id = Rand.choice(params.id_set)
         end
         local potion = Itemgen.create(nil, nil, { amount = 1, categories = "elona.drink", id = item_id }, chara)
         if potion then
            ElonaAction.throw(chara, potion, target.x, target.y)
         end
         return true
      end

      return false
      -- <<<<<<<< shade2/ai.hsp:486 		} ..
   end
}
