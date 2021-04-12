-- ======================================================================
-- Copyright (c) 2012 RapidFire Studio Limited
-- All Rights Reserved.
-- http://www.rapidfirestudio.com

-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:

-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
-- CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
-- ======================================================================

local Pos = require("api.Pos")

local AStar = class.class("AStar")

----------------------------------------------------------------
-- local functions
----------------------------------------------------------------

local function heuristic_cost_estimate(node_a, node_b)
   return Pos.dist(node_a.x, node_a.y, node_b.x, node_b.y)
end

local function is_valid_node(node, neighbor)
   return node.can_access
end

local function lowest_f_score(set, f_score)
   local lowest, best_node = math.huge, nil
   for _, node in ipairs(set) do
      local score = f_score[node]
      if score < lowest then
         lowest, best_node = score, node
      end
   end
   return best_node
end

local function neighbor_nodes(the_node, nodes, valid_node_func)
   local neighbors = {}
   for _, node in ipairs(nodes) do
      if the_node ~= node and valid_node_func(the_node, node) then
         table.insert(neighbors, node)
      end
   end
   return neighbors
end

local function not_in(set, the_node)
   for _, node in ipairs(set) do
      if node == the_node then return false end
   end
   return true
end

local function remove_node(set, the_node)
   for i, node in ipairs(set) do
      if node == the_node then
         set[i] = set[#set]
         set[#set] = nil
         break
      end
   end
end

local function unwind_path(flat_path, map, current_node)
   if map[current_node] then
      table.insert(flat_path, 1, map[current_node])
      return unwind_path(flat_path, map, map[current_node])
   else
      return flat_path
   end
end

----------------------------------------------------------------
-- pathfinding functions
----------------------------------------------------------------

local function a_star(start, goal, nodes, valid_node_func, cost_func)
   local closedset = {}
   local openset = { start }
   local came_from = {}

   local _is_valid_node = is_valid_node
   if valid_node_func then _is_valid_node = valid_node_func end
   local _cost = heuristic_cost_estimate
   if cost_func then _cost = cost_func end

   local g_score, f_score = {}, {}
   g_score[start] = 0
   f_score[start] = g_score[start] + _cost(start, goal)

   while #openset > 0 do
      local current = lowest_f_score(openset, f_score)
      if current == goal then
         local path = unwind_path({}, came_from, goal)
         table.insert(path, goal)
         return path
      end

      remove_node(openset, current)
      table.insert(closedset, current)

      local neighbors = neighbor_nodes(current, nodes, _is_valid_node)
      for _, neighbor in ipairs(neighbors) do
         if not_in(closedset, neighbor) then
            local tentative_g_score = g_score[current] + Pos.dist(current.x, current.y, neighbor.x, neighbor.y)

            if not_in(openset, neighbor) or tentative_g_score < g_score[neighbor] then
               came_from[neighbor] = current
               g_score[neighbor] = tentative_g_score
               f_score[neighbor] = g_score[neighbor] + _cost(neighbor, goal)
               if not_in(openset, neighbor) then
                  table.insert(openset, neighbor)
               end
            end
         end
      end
   end
   return nil -- no valid path
end

----------------------------------------------------------------
-- exposed functions
----------------------------------------------------------------

function AStar:init(map, cache, valid_node_cb, cost_cb)
   self.map = map
   self.access = {}
   self.cache = cache or {}

   self.valid_node_cb = valid_node_cb or nil
   self.cost_cb = cost_cb or nil

   self:refresh_from_map()
end

function AStar:refresh_from_map()
   local access = {}
   for _, x, y in self.map:iter_tiles() do
      local ind = y * self.map:width() + x + 1
      access[ind] = { x = x, y = y, can_access = self.map:can_access(x, y) }
   end
   access.width = self.map:width()
   access.height = self.map:height()

   self.access = access
end

function AStar:path(start_x, start_y, goal_x, goal_y)
   local start_ind = start_y * self.access.width + start_x + 1;
   local goal_ind = goal_y * self.access.width + goal_x + 1;
   local start = assert(self.access[start_ind])
   local goal = assert(self.access[goal_ind])
   assert(start.x == start_x and start.y == start_y)
   assert(goal.x == goal_x and goal.y == goal_y)

   if self.cache then
      if not self.cache[start] then
         self.cache[start] = {}
      elseif self.cache[start][goal] then
         return self.cache[start][goal]
      end
   end

   local res_path = a_star(start, goal, self.access, self.valid_node_cb, self.cost_cb)

   if self.cache then
      if not self.cache[start][goal] then
         self.cache[start][goal] = res_path
      end
   end

   return res_path
end

return AStar
