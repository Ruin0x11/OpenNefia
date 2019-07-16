local Action = require("api.Action")
local Chara = require("api.Chara")
local Draw = require("api.Draw")
local Feat = require("api.Feat")
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

function Tools.spawn_equipped_foes(count)
   local keys = data["base.item"]:iter():extract("_id"):to_list()
   count = count or 100
   for i=0,count do
      local x = Rand.rnd(Map.width())
      local y = Rand.rnd(Map.height())
      if Map.can_access(x, y) then
         local c = Chara.create("content.enemy", x, y)

         local gen = function() return Item.create(Rand.choice(keys), 0, 0, { ownerless = true }) end
         local pred = function(i) return i.equip_slots ~= nil end
         local iter = fun.tabulate(gen):filter(pred)

         for _, i in iter:take(17) do
            local slot = c:find_equip_slot_for(i)
            if slot then
               assert(c:equip_item(i, true))
            end
         end

         c:refresh()
      end
   end
end

function Tools.show_equipment(chara)
   return require("api.gui.menu.EquipmentMenu"):new(chara):query()
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

function Tools.items()
   return Map.iter_items()
end

function Tools.item()
   return Tools.items():nth(1)
end

function Tools.allies()
   return Chara.iter_allies()
end

function Tools.ally()
   return Tools.allies():nth(1)
end

function Tools.enemies()
   local pred = function(c)
      return Chara.is_alive(c) and not c:is_in_party()
   end
   return Map.iter_charas():filter(pred)
end

function Tools.enemy()
   return Tools.enemies():nth(1)
end

Tools.foes = Tools.enemies

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
         -- TODO inventory, equip
         c:refresh()
      end
   end
end

function Tools.take_all()
   Map.iter_items():each(function(item) Action.get(Chara.player(), item) end)
end

function Tools.drop_all()
   local drop = function(item)
      local success = Action.drop(Chara.player(), item)
      -- if success then
      --    local nx, ny = Map.find_position_for_chara(item.x, item.y)
      --    if nx then
      --       item:set_pos(nx, ny)
      --    end
      -- end
   end
   Chara.player():iter_inventory():each(drop)
end

function Tools.goto_map(name)
   local success, map = Map.generate("elona_sys.elona122", { name = name })
   if not success then
      error(map)
   end
   return Map.travel_to(map)
end

function Tools.top_layer()
   return Draw.get_layer(Draw.layer_count()-1)
end

function Tools.data_keys(_type)
   return data[_type]:iter():extract("_id")
end

function Tools.by_uid(uid)
   return Map.current():get_object(uid)
end

function Tools.feats_under()
   local player = Chara.player()
   return Feat.at(player.x, player.y)
end

function Tools.items_under()
   local player = Chara.player()
   return Item.at(player.x, player.y)
end

function Tools.warp_to(x, y)
   local player = Chara.player()
   local x, y = Map.find_position_for_chara(x, y, "ally")
   if x then
      player:set_pos(x, y)
   end
end

function Tools.draw_debug_pos(x, y, color)
   Draw.set_color(color or {255, 0, 0})
   Draw.set_font(11)
   Draw.text(string.format("%d/%d", x, y), x, y)
   Draw.filled_rect(x - 4, y - 4, 8, 8)
   Draw.set_color(255, 255, 255)
end

function Tools.draw_debug_rect(x, y, w, h, centered)
   if centered then
      x = x - w / 2
      y = y - h / 2
   end
   local p = {
      {x, y},
      {x+w, y},
      {x, y+h},
      {x+w, y+h}
   }
   for _, pos in ipairs(p) do
      Tools.draw_debug_pos(pos[1], pos[2])
   end
   Tools.draw_line_rect(x, y, w, h)
end

local print_flat = require("mod.tools.lib.print_flat")
Tools.print_flat = print_flat.print_flat

function Tools.graph()
   local function random_point()
      return { Rand.rnd(100), Rand.rnd(100) }
   end

   local graph = {
      {
         color = { 255, 0, 0 },
         data = fun.tabulate(random_point):take(20):to_list(),
      }
   }

   require("mod.graphs.api.gui.menu.GraphMenu"):new(graph):query()
end

return Tools
