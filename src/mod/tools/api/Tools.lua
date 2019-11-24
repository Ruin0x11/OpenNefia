local Action = require("api.Action")
local Chara = require("api.Chara")
local Draw = require("api.Draw")
local Event = require("api.Event")
local Feat = require("api.Feat")
local Item = require("api.Item")
local Map = require("api.Map")
local Pos = require("api.Pos")
local Rand = require("api.Rand")
local Gui = require("api.Gui")

local Tools = {}

function Tools.spawn_foes(count)
   count = count or 100
   for i=0,count do
      local x, y = Map.find_position_for_chara()
      if x then
         Chara.create("content.enemy", x, y)
      end
   end
end

function Tools.spawn_equipped_foes(count)
   local keys = data["base.item"]:iter():extract("_id"):to_list()
   count = count or 100
   for i=0,count do
      local x, y = Map.find_position_for_chara()
      if x then
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
      local x, y = Map.find_position_for_chara()
      if x then
         local c = Chara.create("content.ally", x, y)
         if not c:recruit_as_ally() then
            return
         end
      end
   end
end

function Tools.spawn_items(count)
   count = count or 100

   local keys = data["base.item"]:iter():extract("_id"):to_list()
   for _=1,count do
      local x, y = Map.find_free_position(nil, nil, {allow_stacking=true})
      if x then
         Item.create(Rand.choice(keys), x, y)
      end
   end
end

function Tools.items()
   return Map.iter_items()
end

function Tools.item()
   return Rand.choice(Tools.items())
end

function Tools.allies()
   return Chara.iter_allies()
end

function Tools.ally()
   return Rand.choice(Tools.allies())
end

local function gen_faction_pred(faction)
   return function ()
      local pred = function(c)
         return Chara.is_alive(c) and c.faction == faction
      end
      return Map.iter_charas():filter(pred)
   end
end

Tools.enemies = gen_faction_pred("base.enemy")

function Tools.enemy()
   return Rand.choice(Tools.enemies())
end

Tools.citizens = gen_faction_pred("base.citizen")

function Tools.citizen()
   return Rand.choice(Tools.citizens())
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

function Tools.goto_map(id)
   local success, map = Map.generate("elona_sys.map_template", { id = id })
   if not success then
      error(map)
   end
   return Map.travel_to(map)
end

function Tools.go_home(name)
   return Map.travel_to(save.base.home_map_uid)
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

function Tools.feat_under()
   return Tools.feats_under():nth(1)
end

function Tools.items_under()
   local player = Chara.player()
   return Item.at(player.x, player.y)
end

function Tools.warp_to(x, y)
   if type(x) == "table" and x.x then
      y = x.y
      x = x.x
   end

   local player = Chara.player()
   local x, y = Map.find_position_for_chara(x, y, "ally")
   if x then
      player:set_pos(x, y)
   end
end

function Tools.draw_debug_pos(x, y, color)
   Draw.set_color(color or {255, 0, 0})
   Draw.set_font(14)
   Draw.text(string.format("%d/%d", x, y), x, y)
   Draw.filled_rect(x - 8, y - 8, 16, 16)
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

function Tools.bench(cb, ...)
   local sw = require("api.Stopwatch"):new()

   return sw:bench(cb, ...)
end

function Tools.categories_with_without()
   -- determine subcategories that have at least one item with no
   -- subcategory and at least one item with the subcategory the same
   -- as the category.
   local categories = table.keys(table.set(data["base.item"]:iter():filter(function(i) return i.subcategory == nil end):extract("category"):to_list()))
   local result = {}
   for _, c in ipairs(categories) do
      local found = data["base.item"]:iter():filter(function(i) return i.category ~= c and i.subcategory == c end):nth(1)
      if found then
         result[#result+1] = { c, found }
      end
   end
   return result
end

function Tools.categories_flt_differ()
   -- determine major categories with at least one item with the same
   -- subcategory and one item with a different subcategory.
   local categories = table.unique(data["base.item"]:iter():filter(function(i) return i.category == i.subcategory end):extract("category"):to_list())
   local result = {}
   for _, c in ipairs(categories) do
      local found = data["base.item"]:iter():filter(function(i) return i.category == c and i.subcategory ~= c end)
      if found:length() > 0 then
         result[#result+1] = { c, found:extract("_id"):to_list() }
      end
   end
   return result
end

function Tools.categories_for_subcategories()
   -- extract the primary category for each subcategory.
   local cat = Tools.partition(data["base.item"], "subcategory", "category")
   cat[64000] = nil
   cat["nil"] = nil

   local map = function(k, v)
      local subcategory = data["base.item_type"]:iter():filter(function(i) return i.ordering == tonumber(k) end):nth(1)
      local item_type = table.unique(v)
      return (subcategory and subcategory._id) or k, item_type
   end
   return fun.iter(cat):map(map):filter(function(k, v) return #v > 1 end):to_map()
end

function Tools.partition(tbl, key, extract)
   extract = extract or "_id"
   local f = function(i)
      return tostring(i[key])
   end

   local i
   if tostring(tbl) == "<generator>" then
      i = tbl
   elseif tbl.iter then
      i = tbl:iter()
   else
      i = fun.iter(tbl)
   end
   local g = i:group_by(f)
   return fun.iter(g):map(function(k, v) return k, fun.iter(v):extract(extract):to_list() end):to_map()
end

function Tools.mkplayer(id)
   return Chara.create(id or "content.player", nil, nil, {ownerless=true})
end

function Tools.print_map(map)
   map = map or Map.current()
   local res = ""
   for _, x, y in Pos.iter_rect(0, 0, map:width()-1, map:height()-1) do
      local c
      if Map.is_floor(x, y, map) then
         local chara = Chara.at(x, y, map)
         if chara then
            if chara:is_player() then
               c = "@"
            else
               c = "c"
            end
         elseif Item.at(x, y, map):length() > 0 then
            c = "!"
         elseif Feat.at(x, y, map):length() > 0 then
            c = "^"
         else
            c = "."
         end
      else
         c = "#"
      end

      res = res .. c
      if x == map:width() - 1 then
         res = res .. "\n"
      end
   end

   return res
end

function Tools.print_memory(map)
   Gui.update_screen()
   map = map or Map.current()
   local res = ""
   for i, m in map:iter_tile_memory("base.map_tile") do
      local c = " "
      local x = (i-1) % map:width()
      local y = math.floor((i-1) / map:width())

      if m then
         local t = m[1]
         local tile = data["base.map_tile"][t._id]
         if map:is_in_fov(x, y) then
            if tile.is_opaque then
               c = '#'
            else
               c = '.'
            end
         else
            if tile.is_opaque then
               c = '0'
            else
               c = '-'
            end
         end
         local chara = Chara.at(x, y, map)
         if chara and chara:is_player() then
            c = "@"
         end
      end

      res = res .. c
      if x == map:width() - 1 then
         res = res .. "\n"
      end
   end

   return res
end

function Tools.print_shadow(map)
   map = map or Map.current()
   Gui.update_screen()
   local s = ""

   local shadow = map:shadow_map()

   for i=0, #shadow[1] do
      for j=0,#shadow do
         local o = shadow[j][i] or 0
         local i = "."
         if bit.band(o, 0x100) > 0 then
            i = "#"
         end
         s = s .. i
      end
      s = s .. "\n"
   end

   return s
end

function Tools.dungeon(kind, params)
   params = params or {}
   params.id = kind
   params.dungeon_level = params.dungeon_level or 1
   params.deepest_dungeon_level = params.deepest_dungeon_level or 5
   params.tileset = params.tileset or "elona.dungeon"
   local success, map = Map.generate("elona.dungeon_template", params)

   assert(success, map)

   return Tools.print_map(map)
end

function Tools.things_at(ty)
   local PositionPrompt = require("api.gui.PositionPrompt")
   local result, canceled = PositionPrompt:new():query()
   if not result or canceled then
      return fun.iter({})
   end

   if ty then
      return Map.current():objects_at_pos(result.x, result.y):filter(function(f) return f._type == ty end)
   else
      return Map.current():objects_at_pos(result.x, result.y)
   end
end

function Tools.thing_at(ty)
   return Tools.things_at(ty):nth(1)
end

-- Converts an array of sequential probabilities into percent
-- probabilities.
function Tools.to_percent_probabilities(probs)
   local result = {}
   local total = 1

   for i, prob in ipairs(probs) do
      local perc = 1 / prob

      result[i] = total * perc
      total = total * (1 - perc)
   end

   result[#probs+1] = total

   return result
end

return Tools
