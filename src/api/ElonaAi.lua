local Ai = require("api.Ai")
local Chara = require("api.Chara")
local IAi = require("api.IAi")
local Log = require("api.Log")
local Map = require("api.Map")
local Pos = require("api.Pos")
local Rand = require("api.Rand")
local Event = require("api.Event")

local ElonaAi = class("ElonaAi", IAi)

function ElonaAi:init(params)
   params = params or {}

   -- custom parameters
   -- TODO: tablex.merge_selective_with_types
   self.min_distance = params.min_distance or 1
   self.move_chance_percent = params.move_chance_percent or 100
   self.sub_act_chance_percent = params.sub_act_chance_percent or 0
   self.normal_actions = params.normal_actions or {"default"}
   self.sub_actions = params.sub_actions or {"default"}
   self.calmness = params.calmness or "1"

   -- custom callbacks
   self.on_low_hp = params.on_low_hp or nil
   self.on_idle_action = params.on_idle_action or nil

   -- internal variables
   self.target = nil
   self.hate = 0
   self.player_attacker = nil
   self.item_to_be_used = nil
   self.wants_movement = 0
   self.last_target_x = 0
   self.last_target_y = 0
   self.being_attacked_by_enemy = false
end

function ElonaAi:hate_towards(chara, target)
   if self.target and self.target.uid == target.uid then
      return self.hate
   end

   return 0
end

function ElonaAi:get_target()
   return self.target
end

function ElonaAi:set_target(target)
   if not Chara.is_alive(target) then
      return
   end

   self.target = target
end

-- partially from omake's relationbetween
function ElonaAi:relation_towards(chara, other)
   -- EVENT: on calculate relation
   -- factions

   if Chara.is_in_party(other) then
      if Chara.is_in_party(chara) then
         return "friendly"
      end

      if chara.original_relation == other.relation then
         return "friendly"
      end
   else
      if chara.original_relation == other.original_relation then
         return "friendly"
      end
   end

   if chara.original_relation == "enemy" then
      if other.relation ~= "enemy" then
         return "enemy"
      end
   elseif Chara.is_in_party(chara) then
      return other.relation
   elseif Chara.is_in_party(other) then
      return chara.relation
   elseif other.original_relation == "enemy" then
      return "enemy"
   end

   return "neutral"
end

function ElonaAi:is_being_attacked()
   return self.being_attacked_by_enemy
end

function ElonaAi:calculate_ally_target(chara)
   self.hate = self.hate - 1

   local target = self.target()
   local target_not_important = target ~= nil
      and self:relation_towards(target) ~= "enemy"
   -- TODO will want proper character equality, by UID
      and target.ai:get_target() ~= chara

   if target == nil or self.hate <= 0 or target_not_important then
      self:set_target(nil)
      if self.player_attacker ~= nil then
         if self:relation_towards(self.player_attacker) == "enemy" then
            if Chara.is_alive(self.player_attacker) then
               if Map.has_los(chara.x, chara.y, self.player_attacker.x, self.player_attacker.y) then
                  self.hate = 5
                  self:set_target(self.player_attacker)
               end
            end
         end
      end
      if self:get_target() == nil then
         local player = Chara.player()

         if Chara.is_alive(player) then
            local target = Ai.get_target(other)
            if target ~= nil and Ai.relation_towards(player, target) == "enemy" then
               if Map.has_los(chara.x, chara.y, target.x, target.y) then
                  self.hate = 5
                  self:set_target(target)
               end
            end
         end
      end
      -- EVENT: base.on_calculate_ally_target
      -- wet/invisible
   end
end

function ElonaAi:decide_default(chara, target)
   local dist = Pos.dist(target.x, target.y, chara.x, chara.y)

   -- EVENT: on_default_action

   if dist == 1 then
      return {"base.melee", {target=target}}
   end

   if dist < 6 and Map.has_los(chara.x, chara.y, target.x, target.y) then
      local can_do_ranged_attack = false
      if can_do_ranged_attack then
         return {"base.ranged", {target=target}}
      end
   end

   if self.min_distance <= dist then
      if Rand.one_in(3) then
         return "turn_end"
      end
   end
   if Rand.one_in(5) then
      self.hate = self.hate - 1
   end
   if Rand.percent_chance(self.move_chance_percent) then
      return self:do_noncombat_action(chara, target)
   end

   return "turn_end"
end

function ElonaAi:decide_basic(chara, target)
   if Chara.is_player(target) then
      -- for all allies
      --   Ai.send_event(ally, "base.player_attacked", { player_attacker = chara })
      -- end
   end

   local choosing_sub_act = Rand.percent_chance(self.sub_act_chance_percent)
   local choice

   if choosing_sub_act then
      choice = Rand.choice(self.sub_actions)
   else
      choice = Rand.choice(self.normal_actions)
   end

   if choice == "default" then
      return self:decide_default(chara, target)
   end

   if not choice then
      Log.warn("No AI choice available for character %d", chara.uid)
   end

   return choice or "turn_end"
end

function ElonaAi:find_position_for_movement(chara)
   local dir_x = math.abs(self.last_target_x - chara.x)
   local dir_y = math.abs(self.last_target_y - chara.y)
   local nx, ny, blocked_by_chara, dirs
   local order = {}
   if dir_x >= dir_y then
      order[1] = ElonaAi.dir_check_east_west
      order[2] = ElonaAi.dir_check_north_south
   else
      order[1] = ElonaAi.dir_check_north_south
      order[2] = ElonaAi.dir_check_east_west
   end

   for i=1,2 do
      nx, ny, blocked_by_chara, dirs = order[i](self, chara)
      if nx ~= nil and ny ~= nil then
         return {"base.move", { x = nx, y = ny } }
      end
   end

   return nil, blocked_by_chara, dirs
end

function ElonaAi:dir_check(chara, dir, reverse)
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
         if self:relation_towards(chara, on_cell) == "enemy" then
            self:set_target(on_cell)
         else
            blocked_by_chara = true
         end
      end
      -- EVENT: on_ai_dir_check
      -- if is door, then space is open
   end

   return nil, nil, blocked_by_chara
end

function ElonaAi:dir_check_east_west(chara)
   local reverse, dir
   if self.last_target_x > chara.x then
      if self.last_target_y > chara.y then
         reverse = true
      else
         reverse = false
      end
      dir = "east"
   elseif self.last_target_x < chara.x then
      if self.last_target_y < chara.y then
         reverse = false
      else
         reverse = true
      end
      dir = "west"
   end

   local nx, ny,blocked_by_chara = self:dir_check(chara, dir, reverse)
   return nx, ny, blocked_by_chara, {"east", "west"}
end

function ElonaAi:dir_check_north_south(chara)
   local reverse, dir
   if self.last_target_y > chara.y then
      if self.last_target_x > chara.x then
         reverse = true
      else
         reverse = false
      end
      dir = "south"
   elseif self.last_target_y < chara.y then
      if self.last_target_x > chara.x then -- NOTE
         reverse = false
      else
         reverse = true
      end
      dir = "north"
   end
   local nx, ny,blocked_by_chara = self:dir_check(chara, dir, reverse)
   return nx, ny, blocked_by_chara, {"south", "north"}
end

function ElonaAi:do_noncombat_action(chara, target, retreat)
   -- EVENT: on_ai_noncombat_action
   -- sell items

   if chara == target then
      self:set_target(nil)
      return "turn_end"
   end

   assert(target ~= nil)

   if self.wants_movement <= 0 then
      self.last_target_x = target.x
      self.last_target_y = target.y

      local dist = Pos.dist(target.x, target.y, chara.x, chara.y)

      if retreat or self.min_distance > dist then
         -- Move away from target.
         self.last_target_x = chara.x + (chara.x - target.x)
         self.last_target_y = chara.y + (chara.y - target.y)
      end
   else
      self.wants_movement = self.wants_movement - 1
   end

   local dx, dy = Pos.direction_in(chara.x, chara.y, self.last_target_x, self.last_target_y)
   local nx, ny = chara.x + dx, chara.y + dy

   if Map.can_access(nx, ny) then
      return {"base.move", { x = nx, y = ny } }
   end

   local on_cell = Chara.at(nx, ny)
   local Great = 3
   if on_cell ~= nil then
      if self:relation_towards(chara, on_cell) == "enemy" then
         self:set_target(on_cell)
         self.hate = self.hate + 4
         return self:decide_basic(chara, self:get_target())
      elseif chara.quality > Great and chara.level > self:get_target().level then
         if self.enemy ~= self:get_target() then
            local success = Chara.swap_positions(chara, self:get_target())

            -- EVENT: on_ai_displace_chara

            return "turn_end"
         end
      end
   end

   if not Chara.is_ally(chara) then
      if chara.quality > Great and self.relation == "enemy" then -- or -2
         if Map.is_in_bounds(nx, ny) then
            -- crush if wall
            if Rand.one_in(4) then
               return "turn_end"
            end
         end
      end
   end

   local action, blocked_by_chara, dirs = self:find_position_for_movement(chara)
   if action ~= nil then
      return action
   end

   if self.wants_movement > 0 then
      nx, ny = Pos.random_direction(chara.x, chara.y)
      if Map.can_access(nx, ny) then
         return {"base.move", { x = nx, y = ny } }
      end
   else
      if blocked_by_chara then
         self.wants_movement = 3
      else
         self.wants_movement = 6
      end

      local dir = Rand.choice(dirs)

      if dir == 1 then
         self.last_target_x = chara.x - 6
         self.last_target_y = chara.y;
      elseif dir == 2 then
         self.last_target_x = chara.x + 6
         self.last_target_y = chara.y;
      elseif dir == 3 then
         self.last_target_x = chara.x;
         self.last_target_y = chara.y - 6;
      elseif dir == 0 then
         self.last_target_x = chara.x;
         self.last_target_y = chara.y + 6;
      end
   end

   return "turn_end"
end

function ElonaAi:run_custom_actions(type_, chara, target)
   for _, cb in ipairs(self:enabled_actions("ally")) do
      local act = cb({ai=self, chara=chara, target=target})
      if act ~= nil then
         return act
      end
   end
end

function ElonaAi:enable_action(id)
end

function ElonaAi:decide_ally_targeted_action(ally, target)
   if Chara.is_alive(target) then
      -- item on space

      -- EVENT: on_decide_ally_action

      local act = self:run_custom_actions("ally", ally, target)
      if act ~= nil then
         return act
      end

      local dist = Pos.dist(target.x, target.y, chara.x, chara.y)

      if dist > 2 or Rand.one_in(3) then
         return self:do_noncombat_action(ally, target, false)
      end

      return self:do_idle_action(ally, target)
   end

   return nil
end

function ElonaAi:decide_targeted_action(chara, target)
   -- EVENT: if blocked, proc map events
   -- blind
   -- confused

   if chara.relation == "friendly" then
      local act = self:decide_ally_targeted_action(chara, target)
      if act ~= nil then
         return act
      end
   end

   -- EVENT: proc status effect
   -- fear
   -- blind

   local dist = Pos.dist(target.x, target.y, chara.x, chara.y)
   if dist ~= self.min_distance then
      if Rand.percent_chance(self.move_chance_percent)  then
         return self:do_noncombat_action(chara, target, false)
      end
   end

   return self:decide_basic(chara, target)
end

function ElonaAi:search_surroundings_for_target(chara)
   local search_radius = 5
   local x, y
   local target = nil

   for j=0,search_radius - 1 do
      y = chara.y - 2 + j

      if y >= 0 and y <= Map.height() then
         for i=0,search_radius - 1 do
            x = chara.x - 2 + i

            if x >= 0 and y < Map.width() then
               local on_cell = Chara.at(x, y)
               if on_cell ~= nil then
                  if self:relation_towards(chara, on_cell) == "enemy" then
                     local can_be_attacked = true
                     if can_be_attacked then
                        target = on_cell
                        break
                     end
                  end
               end
            end
         end
      end

      if target ~= nil then
         break
      end
   end

   return target
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

function ElonaAi:do_idle_action(chara, target)
   if self.calmness == "4" then
      return self:do_noncombat_action(chara, Chara.player())
   end

   if Rand.one_in(5) then
      return "turn_end"
   end

   -- EVENT: on_idle_action
   -- drunk
   -- sleep
   -- quest
   -- snowmen
   -- eat if hungry

   local nx, ny

   if self.calmness == "5" then
      -- CALLBACK: on_idle_action(per chara)

      nx, ny = Pos.random_direction(chara.x, chara.y)
      if Map.can_access(nx, ny) then
         return { "base.move", { x = nx, y = ny } }
      end
   elseif self.calmness == "2" then
      if chara.initial_x ~= nil and chara.initial_y ~= nil then
         nx, ny = drift_towards_pos(chara.x, chara.y, chara.initial_x, chara.initial_y)
      else
         nx, ny = Pos.random_direction(chara.x, chara.y)
      end
      if Map.can_access(nx, ny) then
         return { "base.move", { x = nx, y = ny } }
      end
   else
      -- TODO dedup
      nx, ny = Pos.random_direction(chara.x, chara.y)
      if Map.can_access(nx, ny) then
         return { "base.move", { x = nx, y = ny } }
      end
   end

   return "turn_end"
end

function ElonaAi:decide_action(chara)
   if self.relation == "friendly" then
      self:calculate_ally_target(chara)
   end

   local target = self:get_target()
   if target ~= nil and not Chara.is_alive(target) then
      self:set_target(nil)
      self.hate = 0
   end

   local ev = Event.trigger("base.before_ai_decide_action", { chara = chara })
   if ev.action then
      return ev.action
   end
   -- EVENT: on_decide_action
   -- pet arena
   -- noyel
   -- mount
   -- custom talk
   -- choked

   if self:get_target() == nil then
      self:set_target(Chara.player())
   end

   if type(self.on_low_hp) == "function" then
      if chara.hp < chara.max_hp / 4 then
         if chara.mp > 0 and Rand.one_in(5) then
            local result = self:on_low_hp(chara)
            if type(result) == "string" then return result end
         end
      end
   end

   if self.item_to_be_used ~= nil then
   end

   self.item_to_be_used = nil

   local target = self:get_target()
   if Chara.is_alive(target) and (self.hate > 0 or self.relation == "friendly") then

      return self:decide_targeted_action(chara, target)
   end

   -- HACK: don't make enemies all scan on the same turn since it's
   -- slow.
   if (chara.turns_alive + chara.uid) % 10 == 1 then
      local new_target = self:search_surroundings_for_target(chara)
      if new_target ~= nil then
         self:set_target(new_target)
         self.hate = 30
      end
   end

   -- EVENT: on_something
   -- try to perceive player
   local target = self:get_target()
   if Chara.is_player(target) then
      -- perceive
   end

   return self:do_idle_action(chara, self:get_target())
end

function ElonaAi:event(id, params)
   if id == "base.player_attacked" then
      self.player_attacker = params.player_attacker
   elseif id == "base.turn_hostile" then
      self.relation = "enemy"
      self.hate = params.hate
      self:set_target(params.target)
   elseif id == "base.modify_hate" then
      self.hate = self.hate + params.hate_delta
   end
end

return ElonaAi
