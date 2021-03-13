local Quest = require("mod.elona_sys.api.Quest")
local Item = require("api.Item")
local Rand = require("api.Rand")
local Enum = require("api.Enum")
local Chara = require("api.Chara")
local Calc = require("mod.elona.api.Calc")
local Itemgen = require("mod.tools.api.Itemgen")
local Skill = require("mod.elona_sys.api.Skill")
local FigureDrawable = require("mod.elona.api.gui.FigureDrawable")
local CardDrawable = require("mod.elona.api.gui.CardDrawable")

local LootDrops = {}

-- >>>>>>>> shade2/module.hsp:2 #define global rangeNoCargo (mType!mTypeWorld)&(mT ...
-- TODO cargo
local function can_use_cargo_items(map)
   return map:has_type("world_map")
      or map:has_type("player_owned")
      or map:has_type("town")
      or map:has_type("shelter")
      or map:has_type("field")
      or map:has_type("guild")
end
-- <<<<<<<< shade2/module.hsp:2 #define global rangeNoCargo (mType!mTypeWorld)&(mT ..

function LootDrops.should_drop_card_or_figure(chara)
   local quality = chara:calc("quality")
   return Rand.one_in(175)
      or quality == Enum.Quality.Unique
      or config.elona.debug_always_drop_figure_card
      or (quality == Enum.Quality.Great and Rand.one_in(2))
      or (quality == Enum.Quality.God and Rand.one_in(3))
end

function LootDrops.should_drop_player_item(item, player, map)
   -- >>>>>>>> shade2/item.hsp:99 		if iNum(cnt)=0:continue ...
   if not Item.is_alive(item) then
      return false
   end

   if map:calc("is_temporary") then
      if item:is_equipped() or item:calc("is_precious") or Rand.one_in(3) then
         return false
      end
   elseif Rand.one_in(5) then
      return false
   end

   if item:calc("is_cargo") then
      if not can_use_cargo_items(map) then
         return false
      elseif Rand.one_in(2) then
         return false
      end
   end

   local should_drop = true

   if item:is_equipped() then
      if Rand.one_in(10) then
         should_drop = false
      end

      local curse_state = item:calc("curse_state")
      if curse_state >= Enum.CurseState.Blessed then
         if Rand.one_in(2) then
            should_drop = false
         end
      end

      if curse_state <= Enum.CurseState.Cursed then
         if Rand.one_in(2) then
            should_drop = true
         end
      end

      if curse_state <= Enum.CurseState.Doomed then
         if Rand.one_in(2) then
            should_drop = true
         end
      end
   elseif item:calc("identify_state") == Enum.IdentifyState.Full then
      if Rand.one_in(4) then
         should_drop = false
      end
   end

   return should_drop
   -- <<<<<<<< shade2/item.hsp:135 		if f:iNum(ci)=0:continue ..
end

function LootDrops.should_drop_item(item, chara)
   -- >>>>>>>> shade2/item.hsp:164 	if iNum(cnt)=0:continue ...
   if not Item.is_alive(item) then
      return false
   end

   if chara:find_role("elona.custom_chara") then
      return false
   end

   local result = false
   local quality = item:calc("quality")
   if quality >= Enum.Quality.God then
      result = true
   end
   if Rand.one_in(30) then
      result = true
   end
   if quality >= Enum.Quality.Great then
      if Rand.one_in(2) then
         result = true
      end
   end
   if chara:find_role("elona.adventurer") then
      if Rand.one_in(5) then
         result = false
      end
   end
   if quality == Enum.Quality.Unique then
      result = true
   end
   if item:calc("always_drop") then
      result = true
   end

   return result
   -- <<<<<<<< shade2/item.hsp:178 	if f=false : continue ..
end

function LootDrops.calc_dropped_player_items(player, map)
   -- >>>>>>>> shade2/item.hsp:128 		f=false ...
   if not map then return {} end

   local result = {}

   local pred = function(item)
      return LootDrops.should_drop_player_item(item, player, map)
   end
   local items = player:iter_items():filter(pred)
   for _, item in fun.unwrap(items) do
      local remove = false
      if not item:calc("is_precious") then
         if Rand.one_in(4) then
            remove = true
         end
         if item:calc("curse_state") == Enum.CurseState.Blessed then
            if Rand.one_in(3) then
               remove = false
            end
         end
         if item:is_cursed() then
            if Rand.one_in(3) then
               remove = true
            end
         end
         if item:calc("curse_state") == Enum.CurseState.Doomed then
            if Rand.one_in(3) then
               remove = true
            end
         end
      end

      result[#result+1] = { item = item, remove = remove }
   end

   return result
   -- <<<<<<<< shade2/item.hsp:135 		if f:iNum(ci)=0:continue ..
end

function LootDrops.calc_dropped_held_items(chara)
   local blocked = chara:emit("elona.before_chara_drop_items", {}, false)
   if blocked then
      return nil
   end

   if chara:is_player() then
      return LootDrops.calc_dropped_player_items(chara)
   end

   -- >>>>>>>> shade2/item.hsp:151 		if cRelation(rc)=cally:return ...
   if chara:relation_towards(Chara.player()) >= Enum.Relation.Ally then
      return nil
   end
   -- <<<<<<<< shade2/item.hsp:151 		if cRelation(rc)=cally:return ..

   -- >>>>>>>> shade2/item.hsp:159 	if cBit(cHired,rc) : return ...
   if chara:calc("is_hired") then
      return nil
   end

   if chara:calc("splits") or chara:calc("splits2") then
      if Rand.one_in(6) then
         return nil
      end
   end
   -- <<<<<<<< shade2/item.hsp:160 	if (cBit(cSplit,rc))or(cBit(cSplit2,rc)) : if rnd ..

   local pred = function(item)
      return LootDrops.should_drop_item(item, chara)
   end
   return chara:iter_items():filter(pred):map(function(item) return { item = item, remove = false } end):to_list()
end

function LootDrops.do_drop_held_items(chara, map, items)
   -- >>>>>>>> shade2/item.hsp:137 		iX(ci)=cX(rc):iY(ci)=cY(rc) ...
   for _, entry in ipairs(items) do
      local item = entry.item
      if item:is_equipped() then
         assert(chara:unequip_item(item))
      end

      -- TODO god cat blessing

      item:remove_ownership()
      if not entry.remove then
         local success = map:take_object(item, chara.x, chara.y)
         if not success then
            break
         end
         item:stack()
         item.own_state = Enum.OwnState.Inherited
      end
   end
   -- <<<<<<<< shade2/item.hsp:144 		iNum(ci)=0 ..
end

function LootDrops.make_loot(chance, category, chara, map)
   -- >>>>>>>> shade2/item_data.hsp:87 #define global loot(%%1,%%2=0,%%3=0,%%4=0) if rnd(%%1)= ...
   if Rand.one_in(chance) then
      if type(category) == "table" then
         category = Rand.choice(category)
      end
      data["base.item_type"]:ensure(category)
      local filter = {
         level = Calc.calc_object_level(chara:calc("level"), map),
         quality = Calc.calc_object_quality(Enum.Quality.Normal),
         categories = category
      }
      return filter
   end
   -- <<<<<<<< shade2/item_data.hsp:87 #define global loot(%%1,%%2=0,%%3=0,%%4=0) if rnd(%%1)= ..
end

function LootDrops.make_remains(item, chara)
   -- >>>>>>>> shade2/item_func.hsp:689 #module ...
   item.params.chara_id = chara._id
   item.color = chara.color
   item.weight = chara.weight
   if item._id == "elona.corpse" then
      item.weight = math.floor(250 * (item.weight + 100 / 100) + 500)
      item.value = math.floor(item.weight / 5)
   else
      item.weight = math.floor(20 * (item.weight + 500) / 500)
      item.value = math.floor(chara.level * 40 + 600)
      local rarity = chara.proto.rarity / 1000
      if rarity < 20 and chara.relation < Enum.Relation.Dislike then
         item.value = math.floor(item.value * math.clamp(4 - rarity / 5, 1, 5))
      end
   end
   -- <<<<<<<< shade2/item_func.hsp:703 	return ..
end

function LootDrops.make_corpse(item, chara, attacker)
   -- >>>>>>>> shade2/item.hsp:306 			remain_make ci,rc ...
   LootDrops.make_remains(item, chara)
   if chara:calc("is_livestock") and attacker and attacker:has_skill("elona.anatomy") then
      local extra_amount = 1
      if attacker:skill_level("elona.anatomy") > chara:calc("level") then
         extra_amount = extra_amount + 1
      end
      item.amount = item.amount + Rand.rnd(extra_amount)
   end
   -- <<<<<<<< shade2/item.hsp:307 			if cBit(cLivestock,rc)=true :if sAnatomy(pc)!0: ..
end

function LootDrops.calc_loot_drops(chara, map, attacker)
   map = map or chara:current_map()

   local drops = {}

   local loot = function(chance, category, on_create_cb)
      local filter = LootDrops.make_loot(chance, category, chara, map)
      if filter then
         local drop = { filter = filter }
         if on_create_cb then
            drop.on_create = on_create_cb
         end
         drops[#drops+1] = drop
      end
   end

   -- >>>>>>>> shade2/item.hsp:201 	if (cQuality(rc)>=fixGreat)or(rnd(20)=0)or(cBit(c ...
   local always_drops_gold = chara:calc("always_drops_gold")
   if chara:calc("quality") > Enum.Quality.Great
      or Rand.one_in(20)
      or always_drops_gold
   then
      local gold_amount = math.floor(chara.gold / (1 + ((not always_drops_gold) and 3 or 0)))

      drops[#drops+1] = {
         _id = "elona.gold_piece",
         amount = gold_amount
      }

      chara.gold = chara.gold - gold_amount
   end

   local eqtype = chara:calc("equipment_type")

   if eqtype then
      local proto = data["base.equipment_type"]:ensure(eqtype)
      if proto.on_drop_loot then
         proto.on_drop_loot(chara, attacker, drops)
      end
   end

   local loot_type = chara:calc("loot_type")

   if loot_type then
      local proto = data["base.loot_type"]:ensure(loot_type)
      if proto.on_drop_loot then
         proto.on_drop_loot(chara, attacker, drops)
      end
   end

   loot(40, "elona.remains", LootDrops.make_remains)

   -- TODO show house

   -- TODO arena
   local is_arena = false
   if not is_arena and not chara:find_role("elona.custom_chara") then
      local chara_id = chara._id
      local chara_color = chara.color

      local function set_collectable_params(tag, drawable_klass)
         return function(item)
            item.params.chara_id = chara_id

            -- special case for card/figure. the color of the chara chip displayed
            -- is changed, not the figure/card itself. (so not item.color)
            item.params.chara_color = table.deepcopy(chara_color)
            item.params.chara_image = chara:calc("image") or chara.proto.image or nil

            if item._id == "elona.figurine" and item.params.chara_image then
               local chip = data["base.chip"]:ensure(item.params.chara_image)
               if chip.is_tall then
                  item.image = "elona.item_figurine_tall"
               end
            end

            -- TODO preinit item.params before on_init_params, so this can get
            -- moved into the on_init_params() callback
            item:set_drawable(tag, drawable_klass:new(item.params.chara_image, item.params.chara_color), "above", 10000)

            item:refresh_cell_on_map()
         end
      end

      local set_figure_params = set_collectable_params("elona.figurine", FigureDrawable)
      local set_card_params = set_collectable_params("elona.card", CardDrawable)

      if LootDrops.should_drop_card_or_figure(chara) then
         drops[#drops+1] = { _id = "elona.card", on_create = set_card_params }
      end

      if LootDrops.should_drop_card_or_figure(chara) then
         drops[#drops+1] = { _id = "elona.figurine", on_create = set_figure_params }
      end
   end
   -- <<<<<<<< shade2/item.hsp:296 		} ..

   chara:emit("elona.on_chara_generate_loot_drops", {attacker=attacker}, drops)

   -- >>>>>>>> shade2/chara_func.hsp:1736 		catItem@=false : rollAnatomy@=false ...
   local anatomy_check = false
   if Rand.one_in(60) then
      anatomy_check = true
   end
   if Chara.is_alive(attacker) then
      -- TODO god cat blessing
      local power = math.floor(math.sqrt(attacker:skill_level("elona.anatomy")))
      if power > Rand.rnd(150) then
         anatomy_check = true
      end
      Skill.gain_skill_exp(attacker, "elona.anatomy", 10 + (anatomy_check and 4 or 0))
   end
   -- <<<<<<<< shade2/chara_func.hsp:1742 			} ..

   if anatomy_check
      or chara:calc("quality") >= Enum.Quality.Great
      or config.elona.debug_always_drop_remains
      or chara:calc("is_livestock")
      -- or config.base.development_mode
   then
      drops[#drops+1] = { _id = "elona.corpse", on_create = LootDrops.make_corpse }
   end

   if false
      -- or config.base.development_mode
   then
      drops[#drops+1] = {
         filter = {
            categories = "elona.remains"
         },
         on_create = LootDrops.make_remains
      }
   end

   local rich_loot = chara:calc("rich_loot_amount")
   if rich_loot and rich_loot > 0 then
      for i = 1, rich_loot do
         drops[#drops+1] = {
            filter = {
               level = Calc.calc_object_level(chara:calc("level"), map),
               categories = "elona.ore_valuable"
            }
         }
      end
      if Rand.one_in(3) then
         drops[#drops+1] = { _id = "elona.wallet" }
      end
   end

   return drops
end

function LootDrops.do_drop_loot(chara, map, attacker, drops)
   for _, drop in ipairs(drops) do
      local item

      if drop.filter then
         local filter = drop.filter

         filter.amount = filter.amount or drop.amount
         filter.no_stack = (filter.no_stack ~= nil and filter.no_stack) or drop.no_stack

         item = Itemgen.create(chara.x, chara.y, filter, map)
      else
         data["base.item"]:ensure(drop._id)
         local params = {
            amount = drop.amount
         }

         item = Item.create(drop._id, chara.x, chara.y, params, map)
      end

      if item then
         if drop.on_create then
            drop.on_create(item, chara, attacker)
         end
      end
   end

   chara:refresh_cell_on_map()

   -- TODO adventurer
end

-- >>>>>>>> shade2/item.hsp:93 *item_loot ...
function LootDrops.drop_loot(chara, attacker)
   -- <<<<<<<< shade2/item.hsp:93 *item_loot ..
   if chara:is_player() and Quest.is_immediate_quest_active() then
      return false
   end

   local map = chara:current_map()
   local items = LootDrops.calc_dropped_held_items(chara, map)

   local did_something = false
   if items and #items > 0 then
      LootDrops.do_drop_held_items(chara, map, items)
      did_something = true
   end

   if chara:is_player() then
      return did_something
   end

   local loot = LootDrops.calc_loot_drops(chara, map, attacker)
   if loot and #loot > 0 then
      LootDrops.do_drop_loot(chara, map, attacker, loot)
      did_something = true
   end

   return did_something
end

return LootDrops
