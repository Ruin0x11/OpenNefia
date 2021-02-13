local Event = require("api.Event")
local Map = require("api.Map")
local Enum = require("api.Enum")
local Gui = require("api.Gui")
local Rand = require("api.Rand")
local Skill = require("mod.elona_sys.api.Skill")
local Chara = require("api.Chara")
local elona_Chara = require("mod.elona.api.Chara")

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

local function respawn_mobs()
   if save.base.play_turns % 20 == 0 then
      elona_Chara.spawn_mobs()
   end
end

Event.register("base.on_minute_passed", "Respawn mobs", respawn_mobs)

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

Event.register("base.before_chara_turn_start", "Update emotion icon", update_emotion_icon)

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