local Event = require("api.Event")
local Map = require("api.Map")
local Enum = require("api.Enum")
local Gui = require("api.Gui")
local Rand = require("api.Rand")
local Skill = require("mod.elona_sys.api.Skill")
local Chara = require("api.Chara")
local elona_Chara = require("mod.elona.api.Chara")
local DeferredEvent = require("mod.elona_sys.api.DeferredEvent")
local Feat = require("api.Feat")
local Encounter = require("mod.elona.api.Encounter")
local Effect = require("mod.elona.api.Effect")
local Const = require("api.Const")
local Pos = require("api.Pos")

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

local footstep = 0
local footsteps = {"base.foot1a", "base.foot1b"}
local snow_footsteps = {"base.foot2a", "base.foot2b", "base.foot2c"}

local function leave_footsteps(_, params, result)
   local player = params.chara
   local map = player:current_map()
   if (player.x ~= result.pos.x or player.y ~= result.pos.y)
      and Map.can_access(result.pos.x, result.pos.y, map)
   then
      local tile = map:tile(params.chara.x, params.chara.y)
      if tile.kind == Enum.TileRole.Snow then
         Gui.play_sound(snow_footsteps[footstep%2+1])
         footstep = footstep + Rand.rnd(2)
      else
         if map:has_type("world_map") then
            Gui.play_sound(footsteps[footstep%2+1])
            footstep = footstep + 1
         end
      end
   end

   return result
end

Event.register("elona_sys.hook_player_move", "Leave footsteps", leave_footsteps)

local function proc_random_encounter(chara, params, result)
   -- >>>>>>>> shade2/action.hsp:647 	if mType=mTypeWorld:if cc=pc{ ...
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
      elona_Chara.spawn_mobs()
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

   if chara:calc("inventory_weight_type") > 0 then
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
         Effect.vomit(chara)
         return { blocked = true }
      end
   end

   return result
end
Event.register("base.on_chara_pass_turn", "Proc drunk effect behavior", proc_drunk_behavior)
-- <<<<<<<< shade2/main.hsp:818 		} ..
