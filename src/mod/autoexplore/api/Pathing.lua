local Chara = require("api.Chara")
local Gui = require("api.Gui")
local I18N = require("api.I18N")
local Map = require("api.Map")
local Pathfinder = require("mod.autoexplore.api.Pathfinder")
local Util = require("mod.autoexplore.api.Util")
local Pos = require("api.Pos")

local function points_equal(a, b)
   return a.x == b.x and a.y == b.y
end

local function is_valid_explore_target(target)
   if points_equal(target, { x = Chara.player().x, y = Chara.player().y }) then
      return false
   end

   for _, x, y in Pos.iter_rect(-1, -1, 1, 1) do
      if x ~= 0 and y ~= 0 then
         if Map.is_in_bounds(target.x + x, target.y + y) then
            if not Map.current():is_memorized(target.x + x, target.y + y) then
               return true
            end
         end
      end
   end
   return false
end

local Pathing = class.class("Pathing")

local function find_target_square(pos)
   local state = Pathfinder:new()
   local target = state:pathfind(pos)

   if target.x == -1 then
      -- Path through dangerous tiles.
      state = Pathfinder:new()
      state.avoid_danger = false
      target = state:pathfind(pos)
   end

   if target.x ~= -1 then
      -- Fail if tile is unreachable
      if state.distance_map[target.x][target.y] <= 0 and not points_equal(pos, target) then
         target.x = -1
         target.y = -1
      end
   end

   if target.x ~= -1 then
      return target
   else
      return { x = -1, y = -1 }
   end
end

local function calc_move_towards_dest(pos, dest, ignore_blocking)
   local state = Pathfinder:new()
   state.ignore_blocking = ignore_blocking

   if dest.x == -1 and dest.y == -1 then
      return { x = 0, y = 0, reached = false }
   end

   -- The destination and start are reversed, such that the final tile
   -- in the path found is directly next to the starting point. This
   -- allows for determining what direction the next step should be
   -- taken.
   local target = state:pathfind(dest, pos)
   if target.x == -1 then
      state = Pathfinder:new()
      state.ignore_blocking = ignore_blocking
      state.avoid_danger = false
      target = state:pathfind(dest, pos)
   end

   if target.x ~= -1 then
      return { x = target.x - pos.x, y = target.y - pos.y, reached = points_equal(target, dest) }
   else
      return { x = 0, y = 0, reached = false }
   end
end

local function delta_to_command(dx, dy)
   local lookup = {
      [-1] = { [-1] = "northwest", [0] = "north", [1] = "northeast" },
      [0]  = { [-1] = "west",                     [1] = "east"      },
      [1]  = { [-1] = "southwest", [0] = "south", [1] = "southeast" },
   }
   return lookup[dy][dx]
end

function Pathing:init(dest, waypoint)
   self.explore = dest == nil
   if self.explore then
      self.dest = { x = -1, y = -1 }
      self.type = "explore"
   else
      self.dest = dest
      self.type = "travel"
   end
   self.waypoint = waypoint
   self.waypoint_reached = false
end

function Pathing:has_explore_target()
   return self.dest and self.dest.x ~= -1 and is_valid_explore_target(self.dest)
end

function Pathing.print_halt_reason(dest)
   Gui.mes_newline()
   if not Map.is_in_bounds(dest.x, dest.y) then
      Gui.mes("autoexplore.pathing.halt.default")
   elseif not Map.current():is_memorized(dest.x, dest.y) then
      Gui.mes("autoexplore.pathing.halt.unknown_tile")
   elseif Util.chara_blocks(dest) then
      local chara = Chara.at(dest.x, dest.y)
      Gui.mes("autoexplore.pathing.halt.chara", chara)
   elseif Util.mef_blocks(dest) or Util.has_trap(dest) then
      Gui.mes("autoexplore.pathing.halt.danger")
   elseif not Map.can_access(dest.x, dest.y)  then
      Gui.mes("autoexplore.pathing.halt.solid")
   else
      Gui.mes("autoexplore.pathing.halt.default")
   end
end

function Pathing:on_halt()
   local pos = { x = Chara.player().x, y = Chara.player().y }
   local reached = points_equal(self.dest, pos)
   local travel_name = I18N.get("autoexplore." .. self.type .. ".name")

   if not reached then
      Pathing.print_halt_reason(self.dest)
      Gui.mes("autoexplore.pathing.aborted", travel_name)
   else
      Gui.mes("autoexplore.pathing.finished", travel_name)
   end
end

function Pathing:get_action()
   local player = Chara.player()
   local start = {x = player.x, y = player.y}

   if self.explore and not self:has_explore_target() then
      self.dest = find_target_square(start)
   end

   local dest = self.dest
   local ignore_blocking = false

   local move = calc_move_towards_dest(start, dest, ignore_blocking)

   if move.x == 0 and move.y == 0 then
      self:on_halt()
      return nil
   end

   return delta_to_command(move.x, move.y)
end

return Pathing
