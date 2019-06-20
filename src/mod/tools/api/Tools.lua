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
   count = count or 100
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

return Tools
