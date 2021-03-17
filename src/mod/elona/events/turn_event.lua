local Event = require("api.Event")
local Map = require("api.Map")
local Enum = require("api.Enum")
local Gui = require("api.Gui")
local Rand = require("api.Rand")
local Skill = require("mod.elona_sys.api.Skill")
local Chara = require("api.Chara")
local ElonaChara = require("mod.elona.api.ElonaChara")
local DeferredEvent = require("mod.elona_sys.api.DeferredEvent")
local Feat = require("api.Feat")
local Encounter = require("mod.elona.api.Encounter")
local Effect = require("mod.elona.api.Effect")
local Const = require("api.Const")
local Pos = require("api.Pos")
local Save = require("api.Save")
local Hunger = require("mod.elona.api.Hunger")

local function refresh_hp_mp_stamina(chara, params, result)
   local mp_factor = chara:skill_level("elona.stat_magic") * 2
      + chara:skill_level("elona.stat_will")
      + (chara:skill_level("elona.stat_learning") / 3)
      * (chara:calc("level") / 25)
      + chara:skill_level("elona.stat_magic")

   chara.max_mp = math.floor(math.clamp(mp_factor, 1, 1000000) * (chara:skill_level("elona.stat_mana") / 100))

   local hp_factor = chara:skill_level("elona.stat_constitution") * 2
      + chara:skill_level("elona.stat_strength")
      + (chara:skill_level("elona.stat_will") / 3)
      * (chara:calc("level") / 25)
      + chara:skill_level("elona.stat_strength")

   chara.max_hp = math.floor(math.clamp(hp_factor, 1, 1000000) * (chara:skill_level("elona.stat_life") / 100)) + 5

   chara.max_stamina = math.floor(100 + (chara:skill_level("elona.stat_constitution") + chara:skill_level("elona.stat_strength")) / 5
                                     + chara:trait_level("elona.stamina") * 8)
end

Event.register("base.on_refresh", "Update max HP/MP/stamina", refresh_hp_mp_stamina)

local function apply_buff_effects(chara, params, result)
   for _, buff in ipairs(chara.buffs) do
      if buff.duration > 0 then
         local buff_data = data["elona_sys.buff"]:ensure(buff._id)
         if buff_data.on_refresh then
            buff_data.on_refresh(buff, chara)
         end
      end
   end
end

Event.register("base.on_refresh", "Apply buff effects", apply_buff_effects)

local function set_player_scroll_speed(chara, params, result)
   local scroll = 10
   local start_run_wait = 2
   if Gui.key_held_frames() > start_run_wait then
      scroll = 6
   end

   -- TODO handle confusion if trying to run
   --
   -- if (key_shift)&(gRun=false)&(cConfuse(pc)=0)&(cDim(pc)=0):if mType!mTypeWorld{
   -- gRun=true
   -- cell_check cX(cc)+1,cY(cc):gRunRight=cellAccess
   -- cell_check cX(cc)-1,cY(cc):gRunLeft =cellAccess
   -- cell_check cX(cc),cY(cc)+1:gRunDown =cellAccess
   -- cell_check cX(cc),cY(cc)-1:gRunUp   =cellAccess
   -- }

   if Gui.player_is_running() then
      scroll = 1
   end

   chara:mod("scroll", scroll, "set")

   return result
end
Event.register("elona_sys.before_player_move", "Player scroll speed", set_player_scroll_speed)

local footstep = 0
local footsteps = {"base.foot1a", "base.foot1b"}
local snow_footsteps = {"base.foot2a", "base.foot2b", "base.foot2c"}
local snow_efmaps = { "base.effect_map_snow_1", "base.effect_map_snow_2" }

local function direction_to_angle(dir)
   if     dir == "North"     then return 0
   elseif dir == "Northeast" then return 45
   elseif dir == "East"      then return 90
   elseif dir == "Southeast" then return 135
   elseif dir == "South"     then return 180
   elseif dir == "Southwest" then return 225
   elseif dir == "West"      then return 270
   elseif dir == "Northwest" then return 315
   else                           return 360
   end
end

local function leave_footsteps(chara, _, result)
   -- >>>>>>>> shade2/action.hsp:747 			if p=tSnow :addEfMap cX(cc),cY(cc),mefSnow,10,d ...
   local map = chara:current_map()
   if (chara.x ~= result.x or chara.y ~= result.y)
      and Map.can_access(result.x, result.y, map)
   then
      local angle = direction_to_angle(chara.direction)
      local tile = map:tile(result.x, result.y)
      if tile.show_name then
         Gui.mes("action.move.walk_into", "map_tile._." .. tile._id .. ".name")
      end
      if tile.kind == Enum.TileRole.Snow then
         Gui.add_effect_map(Rand.choice(snow_efmaps), result.x, result.y, 10, angle, "fade")
         Gui.play_sound(snow_footsteps[footstep%2+1])
         footstep = footstep + Rand.rnd(2)
      else
         if map:has_type("world_map") then
            Gui.add_effect_map("base.effect_map_foot", result.x, result.y, 10, angle, "fade")
            Gui.play_sound(footsteps[footstep%2+1])
            footstep = footstep + 1
         end
      end
   end

   return result
   -- <<<<<<<< shade2/action.hsp:753 			} ..
end
Event.register("elona_sys.before_player_move", "Leave footsteps", leave_footsteps)

local function proc_random_encounter(chara, params, result)
   -- >>>>>>>> shade2/action.hsp:647 	if mType=mTypeWorld:if cc=pc{ ...
   if config.elona.debug_no_encounters then
      return result
   end
   if not chara:is_player() then
      return result
   end

   local map = chara:current_map()
   local x, y = chara.x, chara.y
   if not (map:has_type("world_map") and Feat.at(x, y, map):length() == 0) then
      return result
   end

   local encounter_id = Encounter.random_encounter_id(map, x, y)
   if encounter_id ~= nil then
      Gui.update_screen()
      Encounter.start(encounter_id, map, x, y)
      return true
   end
   -- <<<<<<<< shade2/action.hsp:670 			} ..
   return result
end

Event.register("base.on_chara_moved", "Proc random encounters", proc_random_encounter)

local function respawn_mobs()
   -- >>>>>>>> shade2/main.hsp:545 		if gTurn¥20=0 : call chara_spawn ...
   if save.base.play_turns % 20 == 0 then
      ElonaChara.spawn_mobs()
   end
   -- <<<<<<<< shade2/main.hsp:545 		if gTurn¥20=0 : call chara_spawn ..
end

Event.register("base.on_minute_passed", "Respawn mobs", respawn_mobs)

local function proc_sense_quality()
   -- >>>>>>>> shade2/main.hsp:546 		if gTurn¥10=1 : call item_senseQuality ...
   if save.base.play_turns % 10 == 0 then
      -- NOTE: You don't actually have to know Sense Quality to sense item
      -- quality.
      Effect.sense_quality(Chara.player())
   end
   -- <<<<<<<< shade2/main.hsp:546 		if gTurn¥10=1 : call item_senseQuality ..
end

Event.register("base.on_minute_passed", "Proc sense quality", proc_sense_quality)

local function on_regenerate(chara)
   if Rand.one_in(6) then
      local amount = Rand.rnd(chara:skill_level("elona.healing") / 3 + 1) + 1
      chara:heal_hp(amount, true)
   end
   if Rand.one_in(5) then
      local amount = Rand.rnd(chara:skill_level("elona.meditation") / 2 + 1) + 1
      chara:heal_mp(amount, true)
   end
end

Event.register("base.on_regenerate", "Regenerate HP/MP", on_regenerate)

local function gain_healing_meditation_exp(chara)
   local exp = 0
   if chara.hp ~= chara:calc("max_hp") then
      local healing = chara:skill_level("elona.healing")
      if healing < chara:skill_level("elona.stat_constitution") then
         exp = 5 + healing / 5
      end
   end
   Skill.gain_skill_exp(chara, "elona.healing", exp, 1000)

   exp = 0
   if chara.mp ~= chara:calc("max_mp") then
      local meditation = chara:skill_level("elona.meditation")
      if meditation < chara:skill_level("elona.stat_magic") then
         exp = 5 + meditation / 5
      end
   end
   Skill.gain_skill_exp(chara, "elona.meditation", exp, 1000)
end

local function gain_stealth_experience(chara)
   local exp = 2

   local map = chara:current_map()
   if map and map:has_type("world_map") and Rand.one_in(20) then
      exp = 0
   end

   Skill.gain_skill_exp(chara, "elona.stealth", exp, 0, 1000)
end

local function gain_weight_lifting_experience(chara)
   local exp = 0

   if chara:calc("inventory_weight_type") > Enum.Burden.None then
      exp = 4

      local map = chara:current_map()
      if map and map:has_type("world_map") and Rand.one_in(20) then
         exp = 0
      end
   end

   Skill.gain_skill_exp(chara, "elona.weight_lifting", exp, 0, 1000)
end

local function update_emotion_icon(chara)
   chara.emotion_icon_turns = math.max(chara.emotion_icon_turns - 1, 0)
   if chara.emotion_icon and chara.emotion_icon_turns == 0 then
      chara.emotion_icon = nil
   end
end

Event.register("base.before_chara_turn_start", "Update emotion icon", update_emotion_icon, {priority = 50000})

local function proc_enough_exp_for_level(chara)
   while chara.experience >= chara.required_experience do
      if chara:is_player() then
         Gui.play_sound("base.ding1")
         Gui.mes_alert()
      end
      Skill.gain_level(chara, true)
   end
end

Event.register("base.before_chara_turn_start", "Check if character leveled up", proc_enough_exp_for_level, {priority = 90000})

local function gain_experience_at_turn_start(chara)
   chara.noise = 0

   local target = chara:get_target()
   if not Chara.is_alive(target) then
      chara:set_target(nil)
      chara:set_aggro(nil, 0)
   end

   if not chara:is_player() then
      return
   end

   local turn = chara.turns_alive % 10
   if turn == 1 then
      chara:iter_party_members()
         :filter(Chara.is_alive)
         :each(gain_healing_meditation_exp)
   elseif turn == 2 then
      gain_stealth_experience(chara)
   elseif turn == 3 then
      gain_weight_lifting_experience(chara)
   elseif turn == 4 then
      if not chara:has_activity() then
         chara:heal_stamina(2, true)
      end
   end
end

Event.register("base.before_chara_turn_start", "Gain experience", gain_experience_at_turn_start)

-- >>>>>>>> shade2/main.hsp:792 	if cDrunk(cc)!0{ ...
local function pick_drunkard_fight(chara)
   local map = chara:current_map()

   if map:has_type("world_map") then
      return
   end

   local filter = function(other)
      return Chara.is_alive(other)
         and Pos.dist(chara.x, chara.y, other.x, other.y) <= 5
         and chara:has_los(other.x, other.y)
         and chara ~= other
         and Rand.one_in(3)
   end

   local target = Chara.iter(map):filter(filter):nth(1)
   if target == nil then
      return
   end

   if chara:is_in_fov() or target:is_in_fov() then
      Gui.mes_c("action.npc.drunk.gets_the_worse", "SkyBlue", chara, target)
      Gui.mes("action.npc.drunk.dialog")
   end

   if Rand.one_in(4) and not target:is_player() then
      if chara:is_in_fov() or target:is_in_fov() then
         Gui.mes_c("action.npc.drunk.annoyed.text", "SkyBlue", target)
         Gui.mes("action.npc.drunk.annoyed.dialog")

         -- XXX maybe this isn't correct. but our targeting system and the way
         -- relation is calculated between two characters is different than in
         -- vanilla. (see IFactioned)
         target:set_relation_towards(chara, Enum.Relation.Enemy)

         target:set_target(chara, 20)
         target:set_emotion_icon("elona.angry", 2)
      end
   end
end

local function proc_drunk_behavior(chara, params, result)
   if not chara:has_effect("elona.drunk") then
      return result
   end

   if Rand.one_in(200) and not chara:is_player() then
      pick_drunkard_fight(chara)
   end

   if chara:effect_turns("elona.drunk") >= Const.CON_DRUNK_HEAVY or chara.nutrition > Const.HUNGER_THRESHOLD_VOMIT then
      if Rand.one_in(60) then
         Hunger.vomit(chara)
         return { blocked = true }
      end
   end

   return result
end
Event.register("base.on_chara_pass_turn", "Proc drunk effect behavior", proc_drunk_behavior)
-- <<<<<<<< shade2/main.hsp:818 		} ..

local function proc_overweight_prevent_movement(player, params, result)
   -- >>>>>>>> shade2/action.hsp:534 	if cBurden(pc)>=burdenMax:if dbg_noWeight=false : ...
   if player:calc("inventory_weight_type") >= Enum.Burden.Max and not config.base.debug_no_weight then
      Gui.mes_duplicate()
      Gui.mes("action.move.carry_too_much")
      result.result = "player_turn_query"
      return result, "blocked"
   end

   return result
   -- <<<<<<<< shade2/action.hsp:534 	if cBurden(pc)>=burdenMax:if dbg_noWeight=false : ..
end
Event.register("elona_sys.before_player_move", "Proc movement prevention on overweight", proc_overweight_prevent_movement)

local function proc_status_effect_random_movement(player, params, result)
   -- >>>>>>>> shade2/action.hsp:521 	f=false ...
   local stumble = false

   if player:has_effect("elona.dimming") and player:effect_turns("elona.dimming") + 10 > Rand.rnd(60) then
      stumble = true
   end

   if player:has_effect("elona.drunk") and Rand.one_in(5) then
      Gui.mes_c("action.move.drunk", "SkyBlue")
      stumble = true
   end

   if player:has_effect("elona.confusion") then
      stumble = true
   end

   if stumble then
      result.x = player.x + Rand.rnd(3) - 1
      result.y = player.y + Rand.rnd(3) - 1
   end

   return result
   -- <<<<<<<< shade2/action.hsp:528 		} ..
end
Event.register("elona_sys.before_player_move", "Proc status effect random movement", proc_status_effect_random_movement)

local function proc_ether_disease_death()
   -- >>>>>>>> shade2/main.hsp:914 	if gCorrupt>=maxCorrupt : dmgHp pc,999999,dmgFrom ...
   local player = Chara.player()
   if not Chara.is_alive(player) then
      return
   end

   if player:calc("ether_disease_corruption") >= Const.ETHER_DISEASE_DEATH_THRESHOLD then
      player:damage_hp(math.max(999999, player:calc("max_hp")), "elona.ether_disease")
   end
   -- <<<<<<<< shade2/main.hsp:914 	if gCorrupt>=maxCorrupt : dmgHp pc,999999,dmgFrom ..
end
Event.register("base.on_turn_begin", "Kill player if ether disease too progressed", proc_ether_disease_death)

local function proc_player_death_penalties(player)
   -- >>>>>>>> shade2/main.hsp:1789  ...
   if player:calc("level") > 5 then
      local attribute_id = Skill.random_base_attribute()
      if player:skill_level(attribute_id) > 0 and Rand.one_in(3) then
         Skill.gain_skill_exp(player, attribute_id, -500)
      end
      if player.karma < Const.KARMA_BAD then
         Effect.modify_karma(player, 10)
      end
   else
      Gui.mes("event.death_penalty_not_applied")
   end

   if player.ether_disease_corruption >= Const.ETHER_DISEASE_DEATH_THRESHOLD then
      Effect.modify_corruption(player, -2000)
   end

   Gui.mes("event.you_lost_some_money")
   player.gold = math.floor(player.gold / 3)
   Effect.decrement_fame(player, 10)

   player:refresh()
   Save.queue_autosave()
   -- <<<<<<<< shade2/main.hsp:1816 	swbreak ..
end
Event.register("base.on_player_death_revival", "Proc player death penalties", proc_player_death_penalties)

local function proc_trait_on_turn_begin()
   local player = Chara.player()
   if not Chara.is_alive(player) then
      return
   end

   -- >>>>>>>> shade2/main.hsp:987 	if trait(traitEtherPotion)!0{ ...
   for _, trait in player:iter_traits() do
      if trait.proto.on_turn_begin then
         trait.proto.on_turn_begin(player.traits[trait._id], player)
      end
   end
   -- <<<<<<<< shade2/main.hsp:992 		}	 ..

   -- >>>>>>>> shade2/main.hsp:994 	if cBit(cInvisi,cTarget(pc))=true:if cBit(cSeeInv ...
   local target = player:get_target()
   if Chara.is_alive(target) and not Effect.is_visible(target, player) then
      player:set_target(nil)
   end
   -- <<<<<<<< shade2/main.hsp:994 	if cBit(cInvisi,cTarget(pc))=true:if cBit(cSeeInv ..
end
Event.register("base.on_turn_begin", "Proc trait on turn begin", proc_trait_on_turn_begin, { priority = 150000 })
