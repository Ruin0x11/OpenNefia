local Chara = require("api.Chara")
local Map = require("api.Map")
local Item = require("api.Item")
local Rand = require("api.Rand")
local Tools = {}

function Tools.spawn_foes(count)
   count = count or 100
   for i=0,count do
      local x = Rand.rnd(Map.width())
      local y = Rand.rnd(Map.height())
      if Map.can_access(x, y) then
         Chara.create("content.enemy", x, y)
      end
   end
end

function Tools.spawn_allies(count)
   count = count or 16
   for i=0,count do
      local x = Rand.rnd(Map.width())
      local y = Rand.rnd(Map.height())
      if Map.can_access(x, y) then
         local c = Chara.create("content.ally", x, y)
         if not c:recruit_as_ally() then
            return
         end
      end
   end
end

function Tools.spawn_items(count)
   count = count or 100
   for i=0,count do
      local x = Rand.rnd(Map.width())
      local y = Rand.rnd(Map.height())
      if Map.can_access(x, y) then
         Item.create("content.armor", x, y)
      end
   end
end

function Tools.item()
   return Map.iter_items():nth(1)
end

function Tools.ally()
   return Chara.iter_allies():nth(1)
end

function Tools.enemy()
   local pred = function(c)
      return Chara.is_alive(c) and not c:is_in_party()
   end
   return Map.iter_charas():filter(pred):nth(1)
end

function Tools.dump_charas()
   local t = Map.iter_charas()
   :map(function(c) return { tostring(c.uid), c.x, c.y } end)
      :to_list()

   return table.print(t, {header = {"UID", "X", "Y"}})
end

function Tools.dump_items()
   local t = Map.iter_items()
   :map(function(i) return { tostring(i.uid), i.x, i.y } end)
      :to_list()

   return table.print(t, {header = {"UID", "X", "Y"}})
end

return Tools
