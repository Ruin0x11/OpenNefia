local Pos = require("api.Pos")

local ElonaPos = {}

function ElonaPos.make_breath(start_x, start_y, end_x, end_y, range, map)
   local breath = {}
   local breath_width = 1
   local count = 0
   local dx
   local dy

   for _, x, y in Pos.iter_line(start_x, start_y, end_x, end_y, true):take(range) do
      dx = x
      dy = y
      if count < 6 then
         if count % 3 == 1 then
            breath_width = breath_width + 2
         end
      else
         breath_width = breath_width - 2
         if breath_width < 3 then
            breath_width = 3
         end
      end
      count = count + 1
      if count >= range then
         break
      end

      for j = 0, breath_width - 1 do
         local ty = j - math.floor(breath_width/2) + dy
         for i = 0, breath_width - 1 do
            local tx = i - math.floor(breath_width/2) + dx
            if map:is_in_fov(tx, ty) then
               if #breath >= 100 then
                  return breath
               end

               local found = false
               for _, pos in ipairs(breath) do
                  if pos[1] == tx and pos[2] == ty then
                     found = true
                     break
                  end
               end
               if not found then
                  breath[#breath+1] = { tx, ty }
               end
            end
         end
      end
   end

   return breath
end

function ElonaPos.make_route(start_x, start_y, end_x, end_y, map)
   if start_x == end_x and start_y == end_y then
      return {{ start_x, end_x }}, true
   end
   local sx = start_x
   local sy = start_y

   local route = {}

   for _, x, y in Pos.iter_line(start_x, start_y, end_x, end_y) do
      -- Position differences are used instead of actual positions to support
      -- extending the line beyond the target position, like for bolts that pass
      -- through the target.
      local dx = x - sx
      local dy = y - sy

      if map:can_see_through(x, y) then
         route[#route+1] = { dx, dy }
      else
         return route, false
      end
      sx = x
      sy = y
   end

   return route, true
end

local function test_los(map, x, y, tx, ty)
   return map:has_los(x, y, tx, ty)
end

function ElonaPos.make_ball(x, y, range, map, test_cb)
   local positions = {}

   test_cb = test_cb or test_los

   for i = 0, range * 2 do
      local ty = y - range + i
      if ty >= 0 and ty < map:height() then
         for j = 0, range * 2 do
            local tx = x - range + j
            if tx >= 0 and tx < map:width() then
               if Pos.dist(x, y, tx, ty) <= range and test_cb(map, x, y, tx, ty) then
                  positions[#positions+1] = { tx, ty }
               end
            end
         end
      end
   end

   return positions
end

return ElonaPos
