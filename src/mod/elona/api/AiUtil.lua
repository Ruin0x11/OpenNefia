local AiUtil = {}
local Rand = require("api.Rand")
local Chara = require("api.Chara")
local Enum = require("api.Enum")
local Pos = require("api.Pos")
local Action = require("api.Action")
local Ai = require("api.Ai")
local MapTileset = require("mod.elona_sys.map_tileset.api.MapTileset")
local Map = require("api.Map")
local Gui = require("api.Gui")
local Anim = require("mod.elona_sys.api.Anim")

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
function AiUtil.move_towards_target(chara, target, retreat)
   -- >>>>>>>> shade2/ai.hsp:373 	if tc=cc:cTarget(cc)=0:goto *turn_end ...
   target = target or chara:get_target()
   if target == nil then
      return false
   end

   if chara == target then
      chara:set_target(default_target(chara))
      return true
   end

   if chara.ai_state.wants_movement <= 0 then
      chara.ai_state.last_target_x = target.x
      chara.ai_state.last_target_y = target.y

      local dist = Pos.dist(target.x, target.y, chara.x, chara.y)

      if retreat or chara.ai_distance > dist then
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
      elseif on_cell.quality > Enum.Quality.Good and on_cell.level > target.level then
         if on_cell:get_target() ~= chara:get_target() then
            if chara:swap_places(on_cell) then
               Gui.mes_visible("ai.swap.displace", chara.x, chara.y, chara, on_cell)
               local activity = on_cell:get_activity()
               if activity and activity.proto.interrupt_on_displace then
                  Gui.mes_visible("ai.swap.glare", chara.x, chara.y, chara, on_cell)
                  chara:remove_activity()
               end
            end
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
   -- <<<<<<<< shade2/ai.hsp:442 	goto *turn_end ..
end

-- @tparam int x
-- @tparam int y
-- @tparam[opt] int max_dist
function AiUtil.stay_near_position(chara, x, y, max_dist, retreat)
   local dist = max_dist or 2
   local nx, ny

   if Pos.dist(chara.x, chara.y, x, y) > dist then
      nx, ny = drift_towards_pos(chara.x, chara.y, x, y)
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

return AiUtil
