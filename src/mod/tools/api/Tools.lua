local Chara = require("api.Chara")
local Map = require("api.Map")
local Rand = require("api.Rand")
local Tools = {}

function Tools.spawn_foes(count)
   count = count or 100
   for i=0,count do
      local x = Rand.rnd(Map.width())
      local y = Rand.rnd(Map.height())
      if Map.can_access(x, y) then
         Chara.create("base.enemy", x, y)
      end
   end
end

function Tools.spawn_allies(count)
   count = count or 16
   for i=0,count do
      local x = Rand.rnd(Map.width())
      local y = Rand.rnd(Map.height())
      if Map.can_access(x, y) then
         local c = Chara.create("base.ally", x, y)
         if not c:recruit_as_ally() then
            return
         end
      end
   end
end

function Tools.ally()
   for _, c in Chara.iter_allies() do
      return c
   end
end

function Tools.enemy()
   for _, c in Map.iter_charas() do
      if Chara.is_alive(c) and not c:is_in_party() then
         return c
      end
   end
end

function Tools.dump_charas()
   local t = {}
   for _, c in Map.iter_charas() do
      t[#t+1] = { tostring(c.uid), c.x, c.y }
   end

   return table.print(t, {"UID", "X", "Y"})
end

function Tools.dump_items()
   local t = {}
   for _, i in Map.iter_items() do
      t[#t+1] = { tostring(i.uid), i.x, i.y }
   end

   return table.print(t, {"UID", "X", "Y"})
end

return Tools
