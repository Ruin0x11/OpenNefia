local Color = {}

function Color.hsv_to_rgb(h, s, v)
   if s <= 0 then return {v,v,v} end
   h, s, v = h/256*6, s/255, v/255
   local c = v*s
   local x = (1-math.abs((h%2)-1))*c
   local m = (v-c)
   local r,g,b
   if h < 1     then r,g,b = c,x,0
   elseif h < 2 then r,g,b = x,c,0
   elseif h < 3 then r,g,b = 0,c,x
   elseif h < 4 then r,g,b = 0,x,c
   elseif h < 5 then r,g,b = x,0,c
   else              r,g,b = c,0,x
   end return {(r+m)*255,(g+m)*255,(b+m)*255}
   end

return Color