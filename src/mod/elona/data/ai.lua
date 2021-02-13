local Gui = require("api.Gui")
local Enum = require("api.Enum")
local MapTileset = require("mod.elona_sys.map_tileset.api.MapTileset")
local Map = require("api.Map")
local Anim = require("mod.elona_sys.api.Anim")
local Effect = require("mod.elona.api.Effect")
local SkillCheck = require("mod.elona.api.SkillCheck")

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

local function drift_towards_pos(x, y, initial_x, initial_y)
   local add_x = 0
   local add_y = 0
   if Rand.one_in(2) then
      if x > initial_x then
         add_x = -1
      elseif x < initial_x then
         add_x = 1
      end
   end
   if Rand.one_in(2) then
      if y > initial_y then
         add_y = -1
      elseif y < initial_x then
         add_y = 1
      end
   end

   return x + add_x, y + add_y
end

local function dir_check(chara, dir, reverse)
   local nx = 0
   local ny = 0
   local blocked_by_chara = false
   local map = chara:current_map()

   local start, finish
   if reverse then
      start = 1
      finish = -1
   else
      start = -1
      finish = 1
   end

   for step=start,finish,finish do
      if dir == "east" then -- 1
         nx = chara.x + 1
         ny = chara.y + step
      elseif dir == "west" then -- 2
         nx = chara.x - 1
         ny = chara.y + step
      elseif dir == "north" then -- 3
         nx = chara.x + step
         ny = chara.y - 1
      elseif dir == "south" then -- 0
         nx = chara.x + step
         ny = chara.y - 1
      end

      if map:can_access(nx, ny) then
         return nx, ny, blocked_by_chara
      end

      local on_cell = Chara.at(nx, ny, map)
      if on_cell ~= nil then
         if chara:relation_towards(on_cell) <= Enum.Relation.Enemy then
            chara:set_target(on_cell)
         else
            blocked_by_chara = true
         end
      end

      local can_access = chara:emit("elona.on_ai_dir_check", {x=nx, y=ny}, false)
      if not can_access then
         return nx, ny, blocked_by_chara
      end
   end

   return nil, nil, blocked_by_chara
end

local function dir_check_east_west(chara)
   local reverse, dir
   if chara.ai_state.last_target_x > chara.x then
      if chara.ai_state.last_target_y > chara.y then
         reverse = true
      else
         reverse = false
      end
      dir = "east"
   elseif chara.ai_state.last_target_x < chara.x then
      if chara.ai_state.last_target_y < chara.y then
         reverse = false
      else
         reverse = true
      end
      dir = "west"
   end

   local nx, ny,blocked_by_chara = dir_check(chara, dir, reverse)
   return nx, ny, blocked_by_chara, {"east", "west"}
end

local function dir_check_north_south(chara)
   local reverse, dir
   if chara.ai_state.last_target_y > chara.y then
      if chara.ai_state.last_target_x > chara.x then
         reverse = true
      else
         reverse = false
      end
      dir = "south"
   elseif chara.ai_state.last_target_y < chara.y then
      if chara.ai_state.last_target_x > chara.x then -- NOTE
         reverse = false
      else
         reverse = true
      end
      dir = "north"
   end
   local nx, ny, blocked_by_chara = dir_check(chara, dir, reverse)
   return nx, ny, blocked_by_chara, {"south", "north"}
end

local function find_position_for_movement(chara)
   local dir_x = math.abs(chara.ai_state.last_target_x - chara.x)
   local dir_y = math.abs(chara.ai_state.last_target_y - chara.y)
   local nx, ny, blocked_by_chara
   local dirs = {}
   local order = {}
   if dir_x >= dir_y then
      order[1] = dir_check_east_west
      order[2] = dir_check_north_south
   else
      order[1] = dir_check_north_south
      order[2] = dir_check_east_west
   end

   for i=1,2 do
      nx, ny, blocked_by_chara, dirs = order[i](chara)
      if nx ~= nil and ny ~= nil then
         return {"elona.move", { x = nx, y = ny } }, false, {}
      end
   end

   return nil, blocked_by_chara, dirs
end

-- @tparam bool retreat
local function move_towards_target(chara, params)
   local retreat = params.retreat

   local target = chara:get_target()
   assert(target ~= nil)

   if chara == target then
      chara:set_target(default_target(chara))
      return true
   end

   if chara.ai_state.wants_movement <= 0 then
      chara.ai_state.last_target_x = target.x
      chara.ai_state.last_target_y = target.y

      local dist = Pos.dist(target.x, target.y, chara.x, chara.y)

      if params.retreat or chara.ai_dist > dist then
         -- Move away from target.
         chara.ai_state.last_target_x = chara.x + (chara.x - target.x)
         chara.ai_state.last_target_y = chara.y + (chara.y - target.y)
      end
   else
      chara.ai_state.wants_movement = chara.ai_state.wants_movement - 1
   end

   local dx, dy = Pos.direction_in(chara.x, chara.y, chara.ai_state.last_target_x, chara.ai_state.last_target_y)
   local nx, ny = chara.x + dx, chara.y + dy

   local map = chara:current_map()

   if map:can_access(nx, ny) then
      Action.move(chara, nx, ny)
      return true
   end

   local on_cell = Chara.at(nx, ny, map)
   if on_cell ~= nil then
      if chara:relation_towards(on_cell) <= Enum.Relation.Enemy then
         chara:set_target(on_cell, chara:get_aggro(on_cell) + 4)
         return Ai.run("elona.basic_action", chara)
      elseif on_cell.quality > Enum.Quality.Great and on_cell.level > target.level then
         if on_cell:get_target() ~= chara:get_target() then
            return Chara.swap_positions(chara, chara:get_target())
         end
      end
   end

   if not chara:is_in_player_party() then
      if chara.quality > Enum.Quality.Great and chara:relation_towards(chara:get_target()) <= Enum.Relation.Hate then
         if map:is_in_bounds(nx, ny) then
            if Rand.one_in(4) then
               local tile = MapTileset.get("elona.mapgen_tunnel", map)
               map:set_tile(nx, ny, tile)
               Map.spill_fragments(nx, ny, 2, map)
               Gui.play_sound("base.crush1")
               local anim = Anim.breaking(nx, ny)
               Gui.start_draw_callback(anim)
               Gui.mes_visible("ai.crushes_wall", chara, chara)
               return true
            end
         end
      end
   end

   local action, blocked_by_chara, dirs = find_position_for_movement(chara)
   if action == true then
      return true
   end

   if chara.ai_state.wants_movement > 0 then
      nx, ny = Pos.random_direction(chara.x, chara.y)
      if map:can_access(nx, ny) then
         Action.move(chara, nx, ny)
         return true
      end
   else
      if blocked_by_chara then
         chara.ai_state.wants_movement = 3
      else
         chara.ai_state.wants_movement = 6
      end

      local dir = Rand.choice(dirs)

      if dir == 1 then
         chara.ai_state.last_target_x = chara.x - 6
         chara.ai_state.last_target_y = chara.y;
      elseif dir == 2 then
         chara.ai_state.last_target_x = chara.x + 6
         chara.ai_state.last_target_y = chara.y;
      elseif dir == 3 then
         chara.ai_state.last_target_x = chara.x;
         chara.ai_state.last_target_y = chara.y - 6;
      elseif dir == 0 then
         chara.ai_state.last_target_x = chara.x;
         chara.ai_state.last_target_y = chara.y + 6;
      end
   end

   return false
end

-- @tparam int x
-- @tparam int y
-- @tparam[opt] int max_dist
local function go_to_position(chara, params)
   local dist = params.max_dist or 2
   local nx, ny

   if Pos.dist(chara.x, chara.y, params.x, params.y) > dist then
      nx, ny = drift_towards_pos(chara.x, chara.y, params.x, params.y)
   else
      nx, ny = Pos.random_direction(chara.x, chara.y)
   end

   local map = chara:current_map()
   if map:can_access(nx, ny) then
      Action.move(chara, nx, ny)
      return true
   end

   return false
end

local function go_to_preset_anchor(chara, params)
   if chara.ai_state.is_anchored then
      return Ai.run("elona.go_to_position", chara, { x = chara.ai_state.anchor_x, y = chara.ai_state.anchor_y })
   end

   return false
end

local function wander(chara, params)
   local map = chara:current_map()
   if chara:calc("ai_calm") == 2 and map:calc("has_anchored_npcs") then
      return Ai.run("elona.go_to_position", chara, { x = chara.initial_x, y = chara.initial_y })
   end

   if (chara:calc("ai_calm") or 1) == 1 then
      local nx, ny = Pos.random_direction(chara.x, chara.y)
      if map:can_access(nx, ny) then
         Action.move(chara, nx, ny)
         return true
      end
   end

   return false
end

local function follow_player(chara, params)
   --if chara.ai_config.follow_player_when_calm then
   if chara:calc("ai_calm") == 4 then
      local target = Chara.player()
      if Chara.is_alive(target) then
         return Ai.run("elona.go_to_position", chara, { x = target.x, y = target.y })
      end
   end
end

local function on_ai_calm_actions(chara, params)
   return chara:emit("elona.on_ai_calm_action", params, false)
end

local function on_ai_ally_actions(chara, params)
   return chara:emit("elona.on_ai_ally_action", params, false)
end

local idle_action = {
   "elona.follow_player",
   function()
      if not Rand.one_in(5) then return true end
   end,
   "elona.on_ai_calm_actions",
   "elona.go_to_preset_anchor",
   "elona.wander",
}

local function do_sleep(chara, _, result)
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
end

Event.register("elona.on_ai_calm_action", "Sleep if nighttime", do_sleep)

local function do_eat(chara, _, result)
   if not Item.is_alive(chara.item_to_use) then
      return
   end
   if chara:is_ally() then
      return
   end

   if chara.nutrition <= 6000 then
      local map = chara:current_map()
      if not map:is_in_fov(chara.x, chara.y) or Rand.one_in(5) then
         if chara:calc("has_anorexia") then
            chara.nutrition = chara.nutrition - 5000
         else
            chara.nutrition = chara.nutrition + 5000
         end
      end
   end

   return result
end

Event.register("elona.on_ai_calm_action", "Eat if hungry", do_eat)

local function attempt_to_melee(chara, params)
   -- >>>>>>>> shade2/ai.hsp:519 	if distance=1{ ...
   local target = chara:get_target()
   local dist = Pos.dist(target.x, target.y, chara.x, chara.y)
   if dist == 1 then
      local target_damage_reaction = target:calc("damage_reaction")
      if not Chara.is_alive(target) then return false end

      if target_damage_reaction then
         local can_do_ranged_attack = false
         if can_do_ranged_attack and dist < 6 and chara:has_los(target.x, target.y) then
            Action.ranged(chara, target)
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
      choice = Rand.choice(chara.ai_actions.main or {})
   else
      choice = Rand.choice(chara.ai_actions.sub or {})
   end

   if choice then
      if Ai.run(choice.id, chara, choice) then
         return true
      end
   end

   if choice.id == "elona.melee" then
      return true
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
   if type(chara.on_low_hp) == "function" then
      if chara.hp < threshold then
         if chara.mp > 0 and Rand.one_in(chance) then
            return chara:on_low_hp(chara)
         end
      end
   end
end

local function decide_ally_targeted_action(chara, params)
   local target = chara:get_target()
   if Chara.is_alive(target) then
      -- item on space

      if Ai.run("elona.on_ai_ally_actions", chara) then
         return true
      end

      local dist = Pos.dist(target.x, target.y, chara.x, chara.y)

      if dist > 2 or Rand.one_in(3) then
         return Ai.run("elona.move_towards_target", chara)
      end

      return Ai.run("elona.idle_action", chara)
   end

   return false
end

local function on_status_effect(chara, params)
end

local function decide_targeted_action(chara, params)
   -- EVENT: if blocked, proc map events
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

   if Ai.run("elona.on_status_effect", chara) then
      return true
   end

   if chara:is_in_player_party() then
      return Ai.run("elona.decide_ally_targeted_action", chara)
   end

   -- EVENT: proc status effect
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
   if dist ~= chara.ai_dist then
      if Rand.percent_chance(chara.ai_move) then
         return Ai.run("elona.move_towards_target", chara)
      end
   end

   return Ai.run("elona.basic_action", chara)
end

local function ai_talk(chara, params)
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

   if Ai.run("elona.try_to_heal", chara) then
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
      { _id = "go_to_position",              act = go_to_position },
      { _id = "wander",                      act = wander },
      { _id = "go_to_preset_anchor",         act = go_to_preset_anchor },
      { _id = "follow_player",               act = follow_player },
      { _id = "move_towards_target",         act = move_towards_target },
      { _id = "basic_action",                act = basic_action },
      { _id = "search_for_target",           act = search_for_target },
      { _id = "decide_ally_target",          act = decide_ally_target },
      { _id = "ai_talk",                     act = ai_talk },
      { _id = "try_to_heal",                 act = try_to_heal },
      { _id = "attempt_to_melee",            act = attempt_to_melee },
      { _id = "idle_action",                 act = idle_action },
      { _id = "decide_ally_targeted_action", act = decide_ally_targeted_action },
      { _id = "on_status_effect",            act = on_status_effect },
      { _id = "decide_targeted_action",      act = decide_targeted_action },
      { _id = "elona_default_ai",            act = elona_default_ai },
   }
)

data:add {
   _type = "base.ai_action",
   _id = "melee",

   act = function(chara, params)
      local target = chara:get_target()
      if not Chara.is_alive(target) then
         return false
      end

      local dist = Pos.dist(target.x, target.y, chara.x, chara.y)

      if dist == 1 then
         chara:say("base.ai_melee")
         return Ai.run("elona.attempt_to_melee", chara)
      end

      if dist < 6 and chara:has_los(target.x, target.y) then
         chara:say("base.ai_ranged")
         local can_do_ranged_attack = false
         if can_do_ranged_attack then
            Action.ranged(chara, target)
            return true
         end
      end

      if chara.ai_dist <= dist then
         if Rand.one_in(3) then
            return true
         end
      end

      if Rand.one_in(5) then
         chara:set_aggro(chara:get_target(), chara:get_aggro() - 1)
      end

      if Rand.percent_chance(chara.ai_move) then
         return Ai.run("elona.idle_action", chara)
      end

      return true
   end
}

data:add {
   _type = "base.ai_action",
   _id = "magic",

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
