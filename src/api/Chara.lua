local Chara = {}

function Chara.set_pos(c, x, y)
   if x >= 0 and y >= 0 and x < 40 and y < 40 then
      c.x = x
      c.y = y
      return true
   end
   return false
end

local directions = {
   North     = {  0, -1 },
   South     = {  0,  1 },
   East      = { -1,  0 },
   West      = {  1,  0 },
   Northeast = { -1, -1 },
   Southeast = { -1,  1 },
   Northwest = {  1, -1 },
   Southwest = {  1,  1 },
}

local function unpack_direction(dir)
   local dir = directions[dir]
   if dir then
      return dir[1], dir[2]
   else
      return 0, 0
   end
end

function Chara.move(c, dx, dy)
   if type(dx) == "string" then
      dx, dy = unpack_direction(dx)
   end
   return Chara.set_pos(c, c.x + dx, c.y + dy)
end

return Chara
