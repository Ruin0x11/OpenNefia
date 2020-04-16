local Map = require("api.Map")
local Chara = require("api.Chara")
local Util = require("mod.autoexplore.api.Util")

local function points_equal(a, b)
   return a.x == b.x and a.y == b.y
end

local function make_distance_map()
   local m = {}
   for i=0, Map.width() - 1 do
      m[i] = {}
      for j=0, Map.height() - 1 do
         m[i][j] = 0
      end
   end
   return m
end

local Pathfinder = class.class("Pathfinder")

function Pathfinder:init()
   self.dest = nil
   self.avoid_danger = true
   self.circ = nil
   self.next_points = 0
   self.points = 0
   self.distance_map = make_distance_map()
   self.next_move = { x = -1, y = -1 }
   self.unexplored_place = { x = -1, y = -1 }
   self.unexplored_dist = -1
   self.traveled_dist = 0
end

function Pathfinder:is_exploring()
   return self.dest == nil
end

function Pathfinder:update_unexplored_pos(pos, next_pos)
   -- HACK: For some reason, by the time the destination is reached
   -- the memorized tiles might not be updated, causing the reached
   -- destination to still be marked as unexplored.
   if points_equal(pos, { x = Chara.player().x, y = Chara.player().y }) then
      return
   end

   if not Map.current():is_memorized(next_pos.x, next_pos.y) then
      if self.traveled_dist < self.unexplored_dist or self.unexplored_dist < 0 then
         self.unexplored_dist = self.traveled_dist
         self.unexplored_place = pos
      end
   end
end

function Pathfinder:mark_point(next_pos)
   if self.distance_map[next_pos.x][next_pos.y] == 0 then
      self.next_points = self.next_points + 1
      self.circ[not self.ring][self.next_points] = next_pos
      self.distance_map[next_pos.x][next_pos.y] = self.traveled_distance;
   end
end

function Pathfinder:flood(pos, next_pos)
   if not Map.is_in_bounds(next_pos.x, next_pos.y) then
      return false
   end

   if self:is_exploring() then
      self:update_unexplored_pos(pos, next_pos)

      if self.unexplored_dist >= 0 then
         return true
      end
   end

   if not self:is_exploring() and points_equal(self.dest, next_pos) then
      self.next_move = pos
      return true
   end

   if Util.is_safe_to_travel(next_pos) then
      self:mark_point(next_pos)
   end

   return false
end

local flood_dirs = {
   { x =  0, y = -1 },
   { x =  1, y =  0 },
   { x =  0, y =  1 },
   { x = -1, y =  0 },
   { x = -1, y = -1 },
   { x = -1, y =  1 },
   { x =  1, y = -1 },
   { x =  1, y =  1 },
   { x =  1, y =  1 },
}

function Pathfinder:examine_point(pos)
   if not Map.is_in_bounds(pos.x, pos.y) then
      return false
   end

   local found_target = false

   for i=1,8 do
      local next_pos = { x = pos.x + flood_dirs[i].x, y = pos.y + flood_dirs[i].y }
      if self:flood(pos, next_pos) then
         found_target = true
      end
   end

   return found_target
end

function Pathfinder:pathfind(start, dest)
   if not Util.is_safe_to_travel(start) and not self.ignore_blocking then
      return { x = -1, y = -1 }
   end

   self.dest = dest

   if not self:is_exploring() and points_equal(start, dest) then
      return start
   end

   self.distance_map = make_distance_map()
   self.next_move = { x = -1, y = -1 }
   self.unexplored_place = { x = -1, y = -1 }
   self.unexplored_dist = -1
   self.next_points = 0
   self.traveled_distance = 1
   self.ring = false

   self.circ = {}
   self.circ[false] = {}
   self.circ[true] = {}
   self.circ[self.ring][1] = start

   local points = 1

   while points > 0 do
      for i=1,points do
         local pos = self.circ[self.ring][i]
         local reached = self:examine_point(pos)
         if reached then
            if self:is_exploring() then
               return self.unexplored_place
            else
               return self.next_move
            end
         end
      end

      points = self.next_points
      self.next_points = 0
      self.ring = not self.ring
      self.traveled_distance = self.traveled_distance + 1
   end

   if self:is_exploring() then
      return self.unexplored_place
   else
      return self.next_move
   end
end

return Pathfinder