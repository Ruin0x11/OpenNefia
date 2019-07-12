local Action = require("api.Action")
local Ai = require("api.Ai")
local Chara = require("api.Chara")
local Log = require("api.Log")
local Map = require("api.Map")
local Pos = require("api.Pos")
local Rand = require("api.Rand")

local function default_target(chara)
   return chara:get_party_leader() or Chara.player()
end

local function on_ai_calm_actions(chara)
   return chara:calc("on_ai_calm_action")
end

local function on_ai_ally_actions(chara)
   return chara:calc("on_ai_ally_action")
end

local function drift_towards_pos(x, y, initial_x, initial_y)
   local add_x = 0
   local add_y = 0
   if Rand.coinflip() then
      if chara.x > chara.initial_x then
         add_x = -1
      elseif chara.x < chara.initial_x then
         add_x = 1
      end
   end
   if Rand.coinflip() then
      if chara.y > chara.initial_y then
         add_y = -1
      elseif chara.y < chara.initial_x then
         add_y = 1
      end
   end

   return x + add_x, y + add_y
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

   if Map.can_access(nx, ny) then
      Action.move(chara, nx, ny)
      return true
   end

   return false
end

local function wander(chara, params)
   local nx, ny = Pos.random_direction(chara.x, chara.y)

   if Map.can_access(nx, ny) then
      Action.move(chara, nx, ny)
      return true
   end

   return false
end

local function go_to_preset_anchor(chara, params)
   if chara.ai_state.is_anchored then
      return Ai.run("base.go_to_position", { x = chara.ai_state.anchor_x, y = chara.ai_state.anchor_y })
   end

   return false
end

local function follow_player(chara, params)
   if chara.ai_config.follow_player_when_calm then
      local target = Chara.player()
      if Chara.is_alive(target) then
         return Ai.run("base.go_to_position", chara, { x = target.x, y = target.y })
      end
   end
end

local function dir_check(chara, dir, reverse)
   local nx = 0
   local ny = 0
   local blocked_by_chara = false

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

      if Map.can_access(nx, ny) then
         return nx, ny, blocked_by_chara
      end

      local on_cell = Chara.at(nx, ny)
      if on_cell ~= nil then
         if chara:reaction_towards(on_cell) <0 then
            chara:set_target(on_cell)
         else
            blocked_by_chara = true
         end
      end
      -- EVENT: on_ai_dir_check
      -- if is door, then space is open
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
   local nx, ny,blocked_by_chara = dir_check(chara, dir, reverse)
   return nx, ny, blocked_by_chara, {"south", "north"}
end

local function find_position_for_movement(chara)
   local dir_x = math.abs(chara.ai_state.last_target_x - chara.x)
   local dir_y = math.abs(chara.ai_state.last_target_y - chara.y)
   local nx, ny, blocked_by_chara, dirs
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
         return {"base.move", { x = nx, y = ny } }
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

      if params.retreat or chara.ai_config.min_distance > dist then
         -- Move away from target.
         chara.ai_state.last_target_x = chara.x + (chara.x - target.x)
         chara.ai_state.last_target_y = chara.y + (chara.y - target.y)
      end
   else
      chara.ai_state.wants_movement = chara.ai_state.wants_movement - 1
   end

   local dx, dy = Pos.direction_in(chara.x, chara.y, chara.ai_state.last_target_x, chara.ai_state.last_target_y)
   local nx, ny = chara.x + dx, chara.y + dy

   if Map.can_access(nx, ny) then
      Action.move(chara, nx, ny)
      return true
   end

   local on_cell = Chara.at(nx, ny)
   local Great = 3
   if on_cell ~= nil then
      if chara:reaction_towards(on_cell) < 0 then
         chara:set_target(on_cell)
         chara.ai_state.hate = chara.ai_state.hate + 4
         return Ai.run("base.basic_action", chara)
      elseif on_cell.quality > Great and on_cell.level > target.level then
         if on_cell:get_target() ~= chara:get_target() then
            return Chara.swap_positions(chara, chara:get_target())
         end
      end
   end

   if not chara:is_in_party() then
      if chara.quality > Great and chara:reaction_towards(chara:get_target()) < 0 then -- or -2
         if Map.is_in_bounds(nx, ny) then
            -- crush if wall
            if Rand.one_in(4) then
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
      if Map.can_access(nx, ny) then
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

local idle_action = {
   "base.follow_player",
   function()
      if Rand.one_in(5) then return true end
   end,
   "base.on_ai_calm_actions",
   "base.go_to_preset_anchor",
   "base.wander",
}

local function default_action(chara, params)
   local target = params.target or chara:get_target()
   if target == nil then
      return false
   end

   local dist = Pos.dist(target.x, target.y, chara.x, chara.y)

   if dist == 1 then
      chara:say("base.ai_melee")
      Action.melee(chara, target)
      return true
   end

   if dist < 6 and Map.has_los(chara.x, chara.y, target.x, target.y) then
      chara:say("base.ai_ranged")
      local can_do_ranged_attack = false
      if can_do_ranged_attack then
         Action.ranged(chara, target)
         return true
      end
   end

   if chara.ai_config.min_distance <= dist then
      if Rand.one_in(3) then
         return true
      end
   end

   if Rand.one_in(5) then
      chara.ai_state.hate = chara.ai_state.hate - 1
   end

   if Rand.percent_chance(chara.ai_config.move_chance_percent) then
      return Ai.run("base.idle_action", chara)
   end

   return true
end

local function get_actions(chara, _type)
   local pred = function(a) return a.type == _type end

   return fun.iter(chara:calc("known_abilities")):filter(pred):to_list()
end

local function basic_action(chara, params)
   local target = chara:get_target()

   chara:act_hostile_towards(target)

   local choosing_sub_act = Rand.percent_chance(chara.ai_config.sub_act_chance_percent)
   local choice

   if choosing_sub_act then
      choice = Rand.choice(get_actions(chara, "main"))
   else
      choice = Rand.choice(get_actions(chara, "sub"))
   end

   if not choice then
      return Ai.run("base.default_action", chara)
   end

   return Ai.run(choice.id, choice.params)
end

local function search_for_target(chara, params)
   local search_radius = params.search_radius or 5
   local x, y

   for j=0,search_radius - 1 do
      y = chara.y - 2 + j

      if y >= 0 and y <= Map.height() then
         for i=0,search_radius - 1 do
            x = chara.x - 2 + i

            if x >= 0 and y < Map.width() then
               local on_cell = Chara.at(x, y)
               if on_cell ~= nil and not on_cell:is_player() then
                  if chara:reaction_towards(on_cell) < 0 then
                     local can_be_attacked = true
                     if can_be_attacked then
                        chara.ai_state.hate = 30
                        chara:set_target(on_cell)
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
   chara.ai_state.hate = chara.ai_state.hate - 1

   local target = chara:get_target()
   local being_targeted = target ~= nil
      and target:get_target() ~= nil
   -- TODO will want proper character equality, by UID
      and target:get_target().uid == chara.uid

   local target_not_important = target ~= nil
      and chara:reaction_towards(target) >= 0
      and not being_targeted

   if target == nil or target:is_party_leader_of(chara) or chara.ai_state.hate <= 0 or target_not_important then

      -- Follow the leader.
      chara:set_target(chara:get_party_leader())

      if chara.ai_state.leader_attacker ~= nil then
         if Chara.is_alive(chara.ai_state.leader_attacker) then
            if chara:reaction_towards(chara.ai_state.leader_attacker) < 0 then
               if Map.has_los(chara.x, chara.y, chara.ai_state.leader_attacker.x, chara.ai_state.leader_attacker.y) then
                  chara.ai_state.hate = 5
                  chara:set_target(chara.ai_state.leader_attacker)
               end
            end
         else
            chara.ai_state.leader_attacker = nil
         end
      end

      if chara:get_target() == nil or chara:get_target():is_party_leader_of(chara) then
         local leader = chara:get_party_leader()

         if Chara.is_alive(leader) then
            local target = leader:get_target()
            if target ~= nil and leader:reaction_towards(target) < 0 then
               if Map.has_los(chara.x, chara.y, target.x, target.y) then
                  chara.ai_state.hate = 5
                  chara:set_target(target)
               end
            end
         end
      end
      -- EVENT: base.on_calculate_ally_target
      -- wet/invisible
      -- EVENT: on_set_target?
   end
end

local function try_to_heal(chara, params)
   local threshold = params.threshold or chara.max_hp / 4
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

      if Ai.run("base.on_ai_ally_actions", chara) then
         return true
      end

      local dist = Pos.dist(target.x, target.y, chara.x, chara.y)

      if dist > 2 or Rand.one_in(3) then
         return Ai.run("base.move_towards_target", chara)
      end

      return Ai.run("base.idle_action", chara)
   end

   return false
end

local function on_status_effect(chara, params)
end

local function decide_targeted_action(chara, params)
   -- EVENT: if blocked, proc map events
   -- blind
   -- confused

   if Ai.run("base.on_status_effect", chara) then
      return true
   end

   if chara:is_in_party() then
      return Ai.run("base.decide_ally_targeted_action", chara)
   end

   -- EVENT: proc status effect
   -- fear
   -- blind

   local target = chara:get_target()
   local dist = Pos.dist(target.x, target.y, chara.x, chara.y)
   if dist ~= chara.ai_config.min_distance then
      if Rand.percent_chance(chara.ai_config.move_chance_percent) then
         return Ai.run("base.move_towards_target", chara)
      end
   end

   return Ai.run("base.basic_action", chara)
end

local function ai_talk(chara, params)
   if not chara:calc("is_talk_silenced") then
      if chara.turns_alive % 5 == 0 then
         if Rand.one_in(4) then
            local leader = chara:get_party_leader()
            if leader and Pos.is_in_square(chara.x, chara.y, leader.x, leader.y, 20) then
               if chara.ai_state.hate <= 0 then
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
   if chara:is_in_party() then
      Ai.run("base.decide_ally_target", chara)
   end

   local target = chara:get_target()
   if target == nil or not Chara.is_alive(target) then
      chara:set_target(default_target(chara))
      chara.ai_state.hate = 0
   end

   -- EVENT: on_decide_action
   -- pet arena
   -- noyel
   -- mount

   Ai.run("base.ai_talk", chara)

   -- choked

   if Ai.run("base.try_to_heal", chara) then
      return true
   end

   local target = chara:get_target()
   if Chara.is_alive(target) and (chara.ai_state.hate > 0 or chara:is_in_party()) then
      return Ai.run("base.decide_targeted_action", chara)
   end

   if chara.turns_alive % 10 == 0 then
      Ai.run("base.search_for_target", chara)
   end

   -- EVENT: on_search_for_target
   -- try to perceive player

   target = chara:get_target()
   if target:is_player() then
      local perceived = true
      if perceived and chara:reaction_towards(target) < 0 then
         chara.ai_state.hate = 30
      end
   end

   return Ai.run("base.idle_action", chara)
end

local data = require("internal.data")

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
      { _id = "default_action",              act = default_action },
      { _id = "basic_action",                act = basic_action },
      { _id = "search_for_target",           act = search_for_target },
      { _id = "decide_ally_target",          act = decide_ally_target },
      { _id = "ai_talk",                     act = ai_talk },
      { _id = "try_to_heal",                 act = try_to_heal },
      { _id = "idle_action",                 act = idle_action },
      { _id = "decide_ally_targeted_action", act = decide_ally_targeted_action },
      { _id = "on_status_effect",            act = on_status_effect },
      { _id = "decide_targeted_action",      act = decide_targeted_action },
      { _id = "elona_default_ai",            act = elona_default_ai }
   }
)
