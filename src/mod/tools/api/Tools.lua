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
local Input = require("api.Input")
local Mef = require("api.Mef")
local Enum = require("api.Enum")
local Effect = require("mod.elona.api.Effect")
local Area = require("api.Area")
local Charagen = require("mod.elona.api.Charagen")
local SaveFs = require("api.SaveFs")
local Log = require("api.Log")
local Itemgen = require("mod.elona.api.Itemgen")
local Filters = require("mod.elona.api.Filters")
local Quest = require("mod.elona_sys.api.Quest")
local Skill = require("mod.elona_sys.api.Skill")
local Magic = require("mod.elona_sys.api.Magic")
local Dialog = require("mod.elona_sys.dialog.api.Dialog")
local World = require("api.World")
local Encounter = require("mod.elona.api.Encounter")
local ElonaAction = require("mod.elona.api.ElonaAction")
local Hunger = require("mod.elona.api.Hunger")
local Home = require("mod.elona.api.Home")
local IMef = require("api.mef.IMef")
local Shortcut = require("mod.elona.api.Shortcut")
local IItemFood = require("mod.elona.api.aspect.IItemFood")
local IItemFromChara = require("mod.elona.api.aspect.IItemFromChara")
local IFeatLockedHatch = require("mod.elona.api.aspect.feat.IFeatLockedHatch")
local Text = require("mod.elona.api.Text")
local I18N = require("api.I18N")

local Tools = {}

function Tools.spawn_foes(count, id)
   count = count or 30
   for i=0,count do
      local x, y = Map.find_position_for_chara()
      if x then
         Chara.create(id or "elona.yeek", x, y)
      end
   end
end

function Tools.spawn_equipped_foes(count)
   local keys = data["base.item"]:iter():extract("_id"):to_list()
   count = count or 10
   for i=0,count do
      local x, y = Map.find_position_for_chara()
      if x then
         local c = Chara.create("elona.yeek", x, y)

         local item = Item.create("elona.long_bow", nil, nil, {}, c)
         c:equip_item(item)
         item = Item.create("elona.arrow", nil, nil, {}, c)
         c:equip_item(item)

         c:refresh()
      end
   end
end

function Tools.spawn_allies(count, id)
   count = count or 4
   for _=1,count do
      local x, y = Map.find_position_for_chara()
      if x then
         local c = Chara.create(id or "elona.wizard_of_elea", x, y)
         if not Chara.player():recruit_as_ally(c) then
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

function Tools.item()
   return Rand.choice(Item.iter())
end

function Tools.ally()
   return Rand.choice(Chara.player():iter_other_party_members())
end

function Tools.other()
   return Rand.choice(Chara.iter_others())
end

local function gen_relation_pred(relation)
   return function ()
      local pred = function(c)
         return c:relation_towards(Chara.player()) == relation
      end
      return Chara.iter():filter(pred)
   end
end

Tools.enemies = gen_relation_pred(Enum.Relation.Enemy)

function Tools.enemy()
   return Rand.choice(Tools.enemies())
end

Tools.citizens = gen_relation_pred(Enum.Relation.Neutral)

function Tools.citizen()
   return Rand.choice(Tools.citizens())
end

function Tools.feat()
   return Rand.choice(Feat.iter())
end

function Tools.dump_charas()
   local t = Chara.iter_all()
   :map(function(c) return { tostring(c.uid), c.x, c.y } end)
      :to_list()

   return table.concat(table.print(t, {header = {"UID", "X", "Y"}}), "\n")
end

function Tools.dump_items()
   local t = Item.iter()
   :map(function(i) return { tostring(i.uid), i.x, i.y } end)
      :to_list()

   return table.concat(table.print(t, {header = {"UID", "X", "Y"}}), "\n")
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
   Item.iter():each(function(item) Action.get(Chara.player(), item) end)
end

function Tools.drop_all()
   local drop = function(item)
      local success = Action.drop(Chara.player(), item) ~= nil
      -- if success then
      --    local nx, ny = Map.find_position_for_chara(item.x, item.y)
      --    if nx then
      --       item:set_pos(nx, ny)
      --    end
      -- end
   end
   Chara.player():iter_inventory():each(drop)
end

function Tools.goto_thing(thing)
   local IMapObject = require("api.IMapObject")
   if class.is_an(IMapObject, thing) then
      local x, y = Map.find_free_position(thing.x, thing.y, {}, thing:current_map())
      if x then
         assert(Chara.player():set_pos(x, y, true))
      end
   end
end

function Tools.go_home()
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
   Draw.set_font(11)
   Draw.text(string.format("%d,%d", x, y), x+4, y-12)
   Draw.filled_rect(x, y - 4, 1, 8)
   Draw.filled_rect(x - 4, y, 8, 1)
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

function Tools.print_map(map)
   map = map or Map.current()
   local res = "\n"
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
   for i, t in map:iter_tile_memory() do
      local c = " "
      local x = (i-1) % map:width()
      local y = math.floor((i-1) / map:width())

      if t then
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

function Tools.dungeon(kind)
   local DungeonMap = require("mod.elona.api.DungeonMap")
   local map = DungeonMap.generate(kind, 1, "elona.home")

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

function Tools.tile_at()
   local PositionPrompt = require("api.gui.PositionPrompt")
   local result, canceled = PositionPrompt:new():query()
   if not result or canceled then
      return fun.iter({})
   end

   return Map.current():tile(result.x, result.y)
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

function Tools.cpos()
   return Chara.player().x, Chara.player().y
end

function Tools.open_dictionary()
   local DictionaryView = require("mod.tools.api.DictionaryView")
   local SidebarMenu = require("api.gui.menu.SideBarMenu")

   local view = DictionaryView:new()
   SidebarMenu:new(view):query()

   return "player_turn_query"
end

function Tools.goto_down_stairs()
   local map = Map.current()
   local stairs = map:iter_feats():filter(function(f) return f._id == "elona.stairs_down" or f:get_aspect(IFeatLockedHatch) end):nth(1)
   if stairs then
      local x, y = Map.find_free_position(stairs.x, stairs.y, map)
      if x and y then
         Chara.player():set_pos(x, y)
      end
   end
end

function Tools.goto_up_stairs()
   local map = Map.current()
   local stairs = map:iter_feats():filter(function(f) return f._id == "elona.stairs_up" end):nth(1)
   if stairs then
      local x, y = Map.find_free_position(stairs.x, stairs.y, map)
      if x and y then
         Chara.player():set_pos(x, y)
      end
   end
end

function Tools.uid_to_map(uid)
   local ok, map = Map.load(uid)
   if not ok then
      return nil, map
   end
   return map
end

function Tools.new_quests()
   local Quest = require("mod.elona_sys.api.Quest")
   local World = require("api.World")
   local map = Map.current()
   World.pass_time_in_seconds(60*60*24*5)
   Quest.update_in_map(map)
   Map.save(map)
end

function Tools.reload_theme()
   local UiTheme = require("api.gui.UiTheme")
   UiTheme.clear()
   local default_theme = "base.default"
   UiTheme.add_theme(default_theme)
end

function Tools.print_map_detailed(map)
   local str = ""
   local function print(...)
      for i, s in ipairs({...}) do
         if i > 1 then
            str = str .. "\t"
         end
         str = str .. s
      end
      str = str .. "\n"
   end

   map = map or Map.current()
   print("-----", "Map: " .. map.name)
   print(Tools.print_map(map))

   print("=====", "Chara")
   for _, chara in Chara.iter(map) do
      print(chara.name, chara.x, chara.y)
   end

   print("=====", "Item")
   for _, item in Item.iter(map) do
      print(item.name, item.x, item.y)
   end

   print("=====", "Feat")
   for _, feat in Feat.iter(map) do
      print(feat._id, feat.x, feat.y)
   end

   print("=====")

   return str
end

function Tools.restart_scenario()
   local scenario = data["base.scenario"]:ensure(save.base.scenario)
   local player = Chara.create("base.player", nil, nil, {ownerless=true})

   local params = scenario:on_game_start(player)
   Chara.set_player(player)

   save.base.home_map_uid = save.base.home_map_uid or Map.current().uid

   Event.trigger("base.on_new_game")
end

function Tools.chara_sheet()
   local chara = Tools.thing_at()
   if chara == nil or chara._type ~= "base.chara" then
      return
   end

   local CharacterInfoMenu = require("api.gui.menu.CharacterInfoMenu")
   CharacterInfoMenu:new(chara):query()
end

function Tools.memorize_map()
   Map.current():iter_tiles():each(function(x, y) Map.current():memorize_tile(x, y) end)
end

function Tools.forget_map()
   Map.current():iter_tiles():each(function(x, y) Map.current():reveal_tile(x, y, "elona.wall_stone_4_fog") end)
end

function Tools.forget_objects()
   Map.current():iter_tiles():each(function(x, y) Map.current():forget_objects(x, y) end)
end

function Tools.fill_with_mef(id, duration, power)
   Map.current():iter_tiles():each(function(x, y) Mef.create(id, x, y, { duration = duration, power = power }) end)
end

function Tools.clear_mefs()
   Mef.iter():each(IMef.remove_ownership)
end

function Tools.player_pos()
   return Chara.player().x, Chara.player().y
end

function Tools.make_foods(x, y)
   local foods = data["base.item"]:iter():filter(function(i) return i._ext and i._ext[IItemFood] end):extract("_id")

   for _, i, _id in foods:enumerate() do
      for quality=0, 9 do
         local food = Item.create(_id, x + i, y + quality - 1, {})
         Hunger.make_dish(food, quality)
      end
   end
end

function Tools.roundup(iter, x, y, width)
   width = width or 20
   x = x or Chara.player().x - math.floor(width / 2)
   y = y or Chara.player().y
   local i = 1
   for _, obj in iter:unwrap() do
      local tx = (i-1) % width
      local ty = math.floor((i-1) / width)
      obj:set_pos(x + tx, y + ty)
       i = i + 1
   end
end

function Tools.iter_buffs(type)
   type = type or "blessing"
   return data["elona_sys.buff"]:iter():filter(function(b) return b.type == type end)
end

function Tools.apply_all_buffs(type, chara, power)
   local ElonaMagic = require("mod.elona.api.ElonaMagic")
   chara = chara or Chara.player()
   type = type or "blessing"
   power = power or 1000
   Tools.iter_buffs(type):each(function(b) ElonaMagic.apply_buff(b._id, { target = chara, source = chara, power = power }) end)
end

function Tools.identify_all()
   Item.iter_in_everything(Map.current()):each(function(i) Effect.identify_item(i, Enum.IdentifyState.Full) end)
end

function Tools.goto_area(area_archetype_id, floor)
   local area
   if not Area.is_created(area_archetype_id) then
      local cur = Area.current()
      area = Area.create_unique(area_archetype_id, (cur and cur.uid) or "root")
      area.parent_x = Chara.player().x
      area.parent_y = Chara.player().y
   else
      area = Area.get_unique(area_archetype_id)
   end

   local ok, map = area:load_or_generate_floor(floor or 1)
   if not ok then
      error(map)
   end

   assert(Map.save(map))
   assert(Map.travel_to(map))
end

local BAR_STYLES = {
    '▁▂▃▄▅▆▇█',
    '⣀⣄⣤⣦⣶⣷⣿',
    '⣀⣄⣆⣇⣧⣷⣿',
    '○◔◐◕⬤',
    '□◱◧▣■',
    '□◱▨▩■',
    '□◱▥▦■',
    '░▒▓█',
    '░█',
    '⬜⬛',
    '▱▰',
    '▭◼',
    '▯▮',
    '◯⬤',
    '⚪⚫',
}

--- from https://changaco.oy.lc/unicode-progress-bars/
function Tools.percent_bar(p, min, max)
   min = min or 10
   max = max or min

   local style = BAR_STYLES[8]
   local symbols = fun.wrap(utf8.chars(style)):to_list()
   local full_symbol = symbols[#symbols]
   local n = #symbols - 1

   p = math.clamp(p, 0.0, 1.0)
   if p == 1.0 then
      return string.rep(full_symbol, max)
   end

   local min_delta = math.huge
   local r = ""

   for i=min, max do
      local x = p * i
      local full = math.floor(x)
      local rest = x - full
      local middle = math.floor(rest * n)
      if p > 0.0 and full == 0 and middle == 0 then
         middle = 1
      end
      local d = math.abs(p - (full + middle / n) / i) * 100
      if d < min_delta then
         min_delta = d
         local m = symbols[middle+1]
         if full == i then
            m = ""
         end
         r = string.rep(full_symbol, full) .. m .. string.rep(symbols[1], i - full - 1)
      end
   end

   return r, min_delta
end

local function left_pad(s, count, pad)
    return s .. string.rep(pad or " ", count - #s)
end

local function get_list(tbl, count, ...)
   if type(tbl) == "function" then
      local args = {...}
      local cb = tbl
      local f = function() return cb(table.unpack(args)) end
      tbl = fun.tabulate(f)
   end

   assert(type(tbl) == "table")
   if tostring(tbl) == "<generator>" then
      tbl = tbl:take(count):to_list()
   end

   return tbl
end

function Tools.print_frequency(tbl, count, ...)
   count = math.clamp(count or 1000, 0, 1000000)
   local tbl = get_list(tbl, count, ...)

   local counts = {}
   for i, v in ipairs(tbl) do
      if i > count then
         break
      end
      counts[v] = (counts[v] or 0) + 1
   end

   local percents = {}
   for k, v in pairs(counts) do
      local percent = v / #tbl
      percents[#percents+1] = { key = k, percent = percent, total = v }
   end

   table.sort(percents, function(a, b) return a.percent < b.percent end)
   local max = percents[#percents].percent

   return Tools.print_frequency_2(percents, max)
end

function Tools.print_frequency_2(percents, max)
   local max_len = 0
   local max_name_len = 0
   local names = {}
   local amounts = {}
   for _, pair in ipairs(percents) do
      local percent = pair.percent
      local total = pair.total
      local amount = ("%.02f%% (%d)"):format(percent * 100, total)
      local name = tostring(pair.key)
      if name:len() > 25 then
         name = name:sub(1, 25) .. "..."
      end
      amounts[#amounts+1] = amount
      names[#names+1] = name
      max_len = math.max(max_len, amount:len())
      max_name_len = math.max(max_name_len, name:len())
   end

   local s = ""
   for i, pair in ipairs(percents) do
      local name = left_pad(names[i], max_name_len)
      local percent = pair.percent
      local amount = amounts[i]
      local bar = Tools.percent_bar(percent / max, 40)
      s = s .. ("\n%-6s %s %s"):format(name, left_pad(amount, max_len), bar)
   end

   return s
end

function Tools.test_frequency(f, match, inputs, count)
   count = math.clamp(count or 1000, 0, 1000000)
   inputs = get_list(inputs, count)

   local percents = {}
   local max = 0.0

   for _, input in ipairs(inputs) do
      local tbl = get_list(f, count, input)
      local total = 0
      for _, result in ipairs(tbl) do
         if result == match then
            total = total + 1
         end
      end
      local percent = total / #tbl
      max = math.max(max, percent)
      percents[#percents+1] = {
         percent = percent,
         key = input,
         total = total
      }
   end

   return Tools.print_frequency_2(percents, max)
end

function Tools.print_plot(tbl, count, sort)
   count = math.clamp(count or 1000, 0, 1000000)
   tbl = get_list(tbl, count)
   local percents = {}
   local sum = fun.iter(table.values(tbl)):sum()
   local max = 0.0

   for k, v in pairs(tbl) do
      local percent = v / sum
      max = math.max(max, percent)
      percents[#percents+1] = {
         percent = percent,
         key = k,
         total = v
      }
   end

   if sort then
      table.sort(percents, function(a, b) return a.percent < b.percent end)
   end

   return Tools.print_frequency_2(percents, max)
end

function Tools.chara_id_for_map(map_archetype_id)
   local archetype = data["base.map_archetype"]:ensure(map_archetype_id)
   local filter = {}
   if archetype.chara_filter then
      filter = archetype.chara_filter(Map.current())
   end

   if filter.id then
      return filter.id
   end

   local level = filter.level
   local quality = filter.quality
   local fltselect = filter.fltselect
   local category = filter.category
   local race_filter = filter.race_filter
   local tag_filters = filter.tag_filters

   return Charagen.random_chara_id(level, quality, fltselect, category, race_filter, tag_filters)
end

function Tools.items_in_category(cat)
   local filter = function(i)
      for _, c in ipairs(i.categories or {}) do
         if cat == c then
            return true
         end
      end
      return false
   end
   return data["base.item"]:iter():filter(filter):extract("_id"):to_list()
end

function Tools.savecycle_object(obj)
   return SaveFs.deserialize(SaveFs.serialize(obj))
end

function Tools.item_desc(iter)
   iter = iter or Item.iter()
   local items = iter:to_list()
   if items[1] == nil then
      return
   end

   local ItemDescriptionMenu = require("api.gui.menu.ItemDescriptionMenu")
   ItemDescriptionMenu:new(items[1], items):query()
end

function Tools.iter_in_area(_type)
   _type = _type or "base.item"
   Gui.mes("Upper left position.")
   local sx, sy = Input.query_position()
   if not sx then
      return
   end
   Gui.mes("Lower right position.")
   local ex, ey = Input.query_position()
   if not ex then
      return
   end

   local filter = function(obj)
      return sx <= obj.x and sy <= obj.y and obj.x <= ex and obj.y <= ey
   end

   return Map.current():iter_type(_type):filter(filter)
end

function Tools.refill_ammo()
   local enc = Chara.player():iter_merged_enchantments():filter(function(enc) return enc._id == "elona.ammo" end):nth(1)
   if not enc then
      return
   end

   enc.params.ammo_max = 9999
   enc.params.ammo_current = enc.params.ammo_max
end

function Tools.performance_stats()
   local fps = Gui.global_widget("fps_counter")
   if not fps then
      return 0, 0, 0
   end
   return fps:widget():get_stats()
end

function Tools.museum_items()
   for _ = 1, 50 do
      local id = Rand.choice({"elona.card", "elona.figurine"})
      local item = Item.create(id, nil, nil, {aspects={[IItemFromChara]={chara_id=Charagen.random_chara_id_raw(100)}}})
      if not item then
         break
      end
   end
end

function Tools.random_artifacts(count)
   count = count or 10
   local player = Chara.player()
   for _ = 1, count do
      local item = Itemgen.create(nil, nil, { categories = Rand.choice(Filters.fsetwear), quality = Enum.Quality.Great }, player)
      Effect.identify_item(item, Enum.IdentifyState.Full)
   end
end

function Tools.end_quest()
   if save.elona_sys.immediate_quest_uid and save.elona_sys.quest_time_limit > 0 then
      save.elona_sys.quest_time_limit = 1
      World.pass_time_in_seconds(120)
   end
end

function Tools.powerup(chara, levels)
   for _= 1, levels or 50 do
      Skill.gain_level(chara)
      Skill.grow_primary_skills(chara)
   end

   Skill.iter_actions()
      :each(function(m)
            Skill.gain_skill(chara, m._id, 100, 1000)
           end)

   Skill.iter_spells()
      :each(function(m)
            Skill.gain_skill(chara, m._id, 10, 1000)
           end)

   chara:refresh()
   chara:heal_to_max()

   if chara:is_player() then
      Shortcut.assign_skill_shortcut(1, "elona.spell_crystal_spear")
      Shortcut.assign_skill_shortcut(2, "elona.spell_magic_storm")
      Shortcut.assign_skill_shortcut(3, "elona.action_harvest_mana")
      Shortcut.assign_skill_shortcut(4, "elona.spell_healing_rain")
      Shortcut.assign_skill_shortcut(8, "elona.spell_sense_object")
      Shortcut.assign_skill_shortcut(9, "elona.spell_magic_map")
   end
end

local function visit_quest_giver(quest)
   local player = Chara.player()
   local map = player:current_map()
   local client = Chara.find(quest.client_uid, "all", map)
   if client then
      Magic.cast("elona.shadow_step", {source=player, target=client})
      if Chara.is_alive(client) then
         Dialog.start(client, "elona.quest_giver:quest_about")
      end
   else
      Log.warn("Couldn't visit client")
   end
end

function Tools.quick_quest(quest_id)
   if quest_id == nil then
      local quests = data["elona_sys.quest"]:iter()
      local choices = quests:map(function(q) return q._id:gsub("^.*%.", "") end):to_list()
      local choice, canceled = Input.prompt(choices)
      if canceled then
         return
      end
      quest_id = quests:nth(choice.index)._id
   end

   local map = Chara.player():current_map()
   local client = assert(Quest.iter_clients_in_map(map):nth(1))
   local new_quest = Quest.generate_from_proto(quest_id, client, map)

   if new_quest == nil then
      return nil
   end

   visit_quest_giver(new_quest)
end

function Tools.quick_encounter(id, level)
   local player = Chara.player()
   local outer_map = player:current_map()
   Encounter.start(id, outer_map, player.x, player.y, level)
end

function Tools.chow_down(chara)
   assert(Chara.is_alive(chara))
   local item = Itemgen.create(nil, nil, { categories = "elona.food" }, chara)
   ElonaAction.eat(chara, item)
end

function Tools.track_skill(skill_id)
   data["base.skill"]:ensure(skill_id)
   save.base.tracked_skill_ids[skill_id] = not save.base.tracked_skill_ids[skill_id]
end

function Tools.most_valuable_items()
   local map = function(proto)
      local item = Item.create(proto._id, nil, nil, {ownerless=true})
      return {
         _id = proto._id,
         value = Home.calc_item_value(item)
      }
   end

   local function sort(a, b)
      return a.value > b.value
   end

   return data["base.item"]:iter():map(map):into_sorted(sort):extract("_id")
end

-- Compatible with omake's camera functionality.
function Tools.take_picture(map, kind)
   local layers = {
       tile_layer          = { require_path = "internal.layer.tile_layer" },
       debris_layer        = { require_path = "internal.layer.debris_layer" },
       chip_layer          = { require_path = "internal.layer.chip_layer" },
       tile_overhang_layer = { require_path = "internal.layer.tile_overhang_layer" },
       emotion_icon_layer  = { require_path = "internal.layer.emotion_icon_layer" },
   }

   kind = kind or "all"

   local map_object_types = {
      "base.feat",
      "base.mef"
   }

   if kind == "map_and_charas" then
      map_object_types[#map_object_types+1] = "base.chara"
   elseif kind == "map_and_items" then
      map_object_types[#map_object_types+1] = "base.item"
   elseif kind == "all" then
      map_object_types = nil
   end

   return Gui.render_tilemap_to_image(map, layers, map_object_types)
end

function Tools.goto_chara(_id)
   local player = Chara.player()
   local map = player:current_map()
   local chara = Chara.find(_id, "others", map)
   if chara then
      local x, y = Map.find_free_position(chara.x, chara.y, {}, map)
      if x and y then
         player:set_pos(x, y)
      end
   end
end

function Tools.find_release_name(starting_letter)
   assert(I18N.language_id() == "base.english", "Must have language set to English.")
   assert(type(starting_letter) == "string", "Argument must be a single letter string.")
   assert(utf8.len(starting_letter) == 1, "Must be single letter.")

   local letter_pattern = ("[%s%s]"):format(starting_letter:lower(), starting_letter:upper())
   local pattern = ("^%s[^ ]+ %s[^ ]+$"):format(letter_pattern, letter_pattern)
   local filter = function(s)
      return s:match(pattern)
   end

   return fun.tabulate(Text.random_title):take(10000):filter(filter)
end

return Tools
