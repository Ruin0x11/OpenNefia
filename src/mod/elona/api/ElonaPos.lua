local Pos = require("api.Pos")

local ElonaPos = {}

function ElonaPos.make_breath(start_x, start_y, end_x, end_y, range, map)
   local breath = {}
   local breath_width = 1
   local count = 0
   local dx
   local dy

   for _, x, y in Pos.iter_line(start_x, start_y, end_x, end_y) do
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

return ElonaPos
