local Action = require("api.Action")
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


local function rand_pos()
   local nx, ny
   local tries = 100
   while tries > 0 do
      nx, ny = Rand.rnd(Map.width()), Rand.rnd(Map.height())
      if Map.can_access(nx, ny) then
         return nx, ny
      end
      tries = tries - 1
   end
   return nx, ny
end

function Tools.spawn_items(count)
   count = count or 100

   local keys = data["base.item"]:iter():extract("_id"):to_list()
   for i=1,count do
      Item.create(Rand.choice(keys), rand_pos())
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

function Tools.clone_me(times)
   times = times or 50

   local p = Chara.player()
   for i in fun.range(times) do
      local x, y = Map.find_position_for_chara(p.x, p.y)
      if x ~= nil then
         local c = p:clone()
         Map.current():take_object(c, x, y)
      end
   end
end

function Tools.take_all()
   Map.iter_items():each(function(item) Action.get(Chara.player(), item) end)
end

function Tools.drop_all()
   local drop = function(item)
      local success = Action.drop(Chara.player(), item)
      if success then
         local nx, ny = Map.find_position_for_chara(item.x, item.y)
         if nx then
            item:set_pos(nx, ny)
         end
      end
   end
   Chara.player():iter_inventory():each(drop)
end

local print_flat = require("mod.tools.lib.print_flat")
Tools.print_flat = print_flat.print_flat

return Tools
