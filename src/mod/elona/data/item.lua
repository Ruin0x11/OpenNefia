local Map = require("api.Map")
local Event = require("api.Event")
local Gui = require("api.Gui")
local Item = require("api.Item")
local Rand = require("api.Rand")
local ElonaMagic = require("mod.elona.api.ElonaMagic")
local Effect = require("mod.elona.api.Effect")
local Enum = require("api.Enum")
local ItemMaterial = require("mod.elona.api.ItemMaterial")
local Skill = require("mod.elona_sys.api.Skill")
local ItemFunction = require("mod.elona.api.ItemFunction")
local Calc = require("mod.elona.api.Calc")
local Building = require("mod.elona.api.Building")
local I18N = require("api.I18N")
local Magic = require("mod.elona_sys.api.Magic")
local Input = require("api.Input")
local Log = require("api.Log")
local Chara = require("api.Chara")
local Pos = require("api.Pos")
local Anim = require("mod.elona_sys.api.Anim")
local World = require("api.World")
local Weather = require("mod.elona.api.Weather")
local Area = require("api.Area")
local ElonaItem = require("mod.elona.api.ElonaItem")
local Filters = require("mod.elona.api.Filters")
local SkillCheck = require("mod.elona.api.SkillCheck")
local Const = require("api.Const")
local Charagen = require("mod.elona.api.Charagen")
local Mef = require("api.Mef")
local Hunger = require("mod.elona.api.Hunger")
local ProductionMenu = require("mod.elona.api.gui.ProductionMenu")
local Inventory = require("api.Inventory")
local light = require("mod.elona.data.item.light")

-- >>>>>>>> shade2/calculation.hsp:854 #defcfunc calcInitGold int c ..
local function calc_initial_gold(_, params, result)
   local item = params.item
   local owner = params.owner
   local map = params.map or Map.current()

   if not owner then
      local base = (map and map.level or 1) * 25
      local is_shelter = false -- TODO shelter
      if is_shelter then
         base = 1
      end

      return Rand.rnd(base + 10) + 1
   end

   local calc = owner.proto.calc_initial_gold
   if calc then
      return calc(owner)
   end

   return item.amount
end
-- <<<<<<<< shade2/calculation.hsp:863 	return rnd(cLevel(c)*25+10)+1 ...

local hook_calc_initial_gold =
   Event.define_hook("calc_initial_gold",
                     "Initial gold amount.",
                     1,
                     nil,
                     calc_initial_gold)

local function open_chest(filter, item_count, after_cb)
   return function(self, params)
      -- >>>>>>>> shade2/action.hsp:950 	item_separate ci ...
      local sep = self:separate()

      if sep.params.chest_item_level <= 0 then
         Gui.mes("action.open.empty")
         return "turn_end"
      end

      if sep.params.chest_lockpick_difficulty > 0 then
         local success = SkillCheck.try_to_lockpick(params.chara, sep)
         if not success then
            return "turn_end"
         end
      end

      ElonaItem.open_chest(sep, filter, item_count)
      sep.params.chest_item_level = 0

      if after_cb then
         after_cb(sep, params)
      end

      return "turn_end"
      -- <<<<<<<< shade2/action.hsp:961 	} ..
   end
end

-- >>>>>>>> shade2/action.hsp:1027 *open_newYear ...
local function new_years_gift_effect(gift, chara)
   Gui.play_sound("base.chest1", gift.x, gift.y)
   Gui.mes("action.open.text", gift:build_name())
   Input.query_more()

   Gui.play_sound("base.ding2")
   Rand.set_seed()

   local quality = gift.params.new_years_gift_quality or 0
   local map = chara:current_map()

   if quality < Const.IMPRESSION_FRIEND then
      if Rand.one_in(3) then
         Gui.mes_visible("action.open.new_year_gift.something_jumps_out", chara.x, chara.y)
         for _ = 1, 3 + Rand.rnd(3) do
            local filter = {
               level = Calc.calc_object_level(chara:calc("level")*3/2+3, map),
               quality = Calc.calc_object_quality(Enum.Quality.Normal)
            }
            Charagen.create(chara.x, chara.y, filter, map)
         end
         return
      end

      if Rand.one_in(3) then
         Gui.mes_visible("action.open.new_year_gift.trap", chara.x, chara.y)
         for _ = 1, 6 do
            local x = chara.x + Rand.rnd(3) - Rand.rnd(3)
            local y = chara.y + Rand.rnd(3) - Rand.rnd(3)
            if map:can_access(x, y) then
               Mef.create("elona.fire", x, y, { duration = Rand.rnd(15+20), power = 50, origin = chara }, map)
               Effect.damage_map_fire(x, y, chara, map)
            end
         end
         return
      end

      Gui.mes_visible("action.open.new_year_gift.cursed_letter", chara.x, chara.y)
      Magic.cast("elona.effect_curse", { source = chara, target = chara, power = 1000 })
      return
   end

   if quality < Const.IMPRESSION_MARRY then
      if Rand.one_in(4) then
         Gui.mes_c_visible("action.open.new_year_gift.ring", chara.x, chara.y, "Yellow")
         local bells = {
            "elona.silver_bell",
            "elona.gold_bell"
         }
         local bell = Chara.create(Rand.choice(bells), chara.x, chara.y, {}, map)
         if bell and bell.relation <= Enum.Relation.Enemy then
            bell:set_relation_towards(chara, Enum.Relation.Dislike)
         end
         return
      end

      if Rand.one_in(5) then
         Gui.mes_visible("action.open.new_year_gift.younger_sister", chara.x, chara.y)
         local younger_sister = Chara.create("elona.younger_sister", chara.x, chara.y, {}, map)
         if younger_sister then
            younger_sister.gold = 5000
         end
         return
      end

      Gui.mes_visible("action.open.new_year_gift.something_inside", chara.x, chara.y)
      Item.create(Rand.choice(Filters.isetgiftminor), chara.x, chara.y, {amount=1}, map)
      return
   end

   if Rand.one_in(3) then
      Gui.mes_c_visible("action.open.new_year_gift.ring", chara.x, chara.y, "Yellow")
      local bells = {
         "elona.silver_bell",
         "elona.gold_bell"
      }
      for _ = 1, 2 + Rand.rnd(3) do
         local bell = Chara.create(Rand.choice(bells), chara.x, chara.y, {}, map)
         if bell and bell.relation <= Enum.Relation.Enemy then
            bell:set_relation_towards(chara, Enum.Relation.Dislike)
         end
      end
      return
   end

   if Rand.one_in(50) then
      Gui.mes_visible("action.open.new_year_gift.wonderful", chara.x, chara.y)
      Item.create(Rand.choice(Filters.isetgiftgrand), chara.x, chara.y, {amount=1}, map)
      return
   end

   Gui.mes_visible("action.open.new_year_gift.something_inside", chara.x, chara.y)
   Item.create(Rand.choice(Filters.isetgiftmajor), chara.x, chara.y, {amount=1}, map)
end
-- <<<<<<<< shade2/action.hsp:1099 return ..

local function open_new_years_gift(self, params)
   -- >>>>>>>> shade2/action.hsp:950 	item_separate ci ...
   local sep = self:separate()

   if sep.params.chest_item_level <= 0 then
      Gui.mes("action.open.empty")
      return "turn_end"
   end

   if sep.params.chest_lockpick_difficulty > 0 then
      local success = SkillCheck.try_to_lockpick(params.chara, sep)
      if not success then
         return "turn_end"
      end
   end

   new_years_gift_effect(sep, params.chara)
   sep.params.chest_item_level = 0
   sep:stack()

   return "turn_end"
   -- <<<<<<<< shade2/action.hsp:961 	} ..
end

-- TODO: Some fields should not be stored on the prototype as
-- defaults, but instead copied on generation.

-- IMPORTANT: Fields like "on_throw", "on_drink", "on_use" and similar are tied
-- to event handlers that are dynamically generated in elona_sys.events. See the
-- "Connect item events" handler there for details.

local item =
   {
      {
         _id = "bug",
         elona_id = 0,
         image = "elona.item_worthless_fake_gold_bar",
         value = 1,
         weight = 1,
         fltselect = 1,
         category = 99999999,
         subcategory = 99999999,
         coefficient = 100,
         categories = {
            "elona.bug",
            "elona.no_generate"
         },
         light = light.item,
         is_wishable = false
      },
      {
         _id = "book_unreadable",
         elona_id = 23,
         image = "elona.item_book",
         value = 100,
         weight = 80,
         on_read = function(self)
            -- >>>>>>>> shade2/proc.hsp:1254 	item_identify ci,knownName ..
            Effect.identify_item(self, Enum.IdentifyState.Name)
            local BookMenu = require("api.gui.menu.BookMenu")
            BookMenu:new("text", true):query()
            return "player_turn_query"
            -- >>>>>>>> shade2/proc.hsp:1254 	item_identify ci,knownName ..
         end,
         fltselect = 1,
         category = 55000,
         coefficient = 100,
         is_wishable = false,

         param1 = 1,
         elona_type = "normal_book",
         categories = {
            "elona.book",
            "elona.no_generate"
         }
      },
      {
         _id = "book",
         elona_id = 24,
         image = "elona.item_book",
         value = 500,
         weight = 80,
         on_read = function(self)
            -- >>>>>>>> shade2/proc.hsp:1254 	item_identify ci,knownName ..
            Effect.identify_item(self, Enum.IdentifyState.Name)
            local text = I18N.get("_.elona.book." .. self.params.book_id .. ".text")
            local BookMenu = require("api.gui.menu.BookMenu")
            BookMenu:new(text, true):query()
            return "player_turn_query"
            -- >>>>>>>> shade2/proc.hsp:1254 	item_identify ci,knownName ..
         end,
         category = 55000,
         rarity = 2000000,
         coefficient = 100,

         params = { book_id = nil },

         on_init_params = function(self)
            -- >>>>>>>> shade2/item.hsp:618 	if iId(ci)=idBook	:if iBookId(ci)=0:iBookId(ci)=i ..
            if not self.params.book_id then
               local cands = data["elona.book"]:iter()
               :filter(function(book) return book.is_randomly_generated end)
                  :extract("_id")
                  :to_list()
               self.params.book_id = Rand.choice(cands)
            end
            -- <<<<<<<< shade2/item.hsp:618 	if iId(ci)=idBook	:if iBookId(ci)=0:iBookId(ci)=i ..
         end,

         elona_type = "normal_book",

         prevent_sell_in_own_shop = true,

         categories = {
            "elona.book"
         }
      },
      {
         _id = "bugged_book",
         elona_id = 25,
         image = "elona.item_book",
         value = 100,
         weight = 80,
         fltselect = 1,
         category = 55000,
         coefficient = 100,

         param1 = 2,
         elona_type = "normal_book",
         categories = {
            "elona.book",
            "elona.no_generate"
         }
      },
      {
         _id = "broken_vase",
         elona_id = 46,
         image = "elona.item_broken_vase",
         value = 6,
         weight = 800,
         category = 64000,
         subcategory = 64000,
         coefficient = 100,
         categories = {
            "elona.junk",
            "elona.junk_in_field"
         }
      },
      {
         _id = "washing",
         elona_id = 47,
         image = "elona.item_washing",
         value = 140,
         weight = 250,
         category = 64000,
         subcategory = 64100,
         coefficient = 100,
         categories = {
            "elona.junk_town",
            "elona.junk"
         }
      },
      {
         _id = "bonfire",
         elona_id = 48,
         image = "elona.item_bonfire",
         value = 170,
         weight = 3200,
         category = 64000,
         coefficient = 100,
         categories = {
            "elona.junk"
         },
         light = light.torch_lamp
      },
      {
         _id = "flag",
         elona_id = 49,
         image = "elona.item_flag",
         value = 130,
         weight = 1400,
         category = 64000,
         coefficient = 100,
         categories = {
            "elona.junk"
         }
      },
      {
         _id = "broken_sword",
         elona_id = 50,
         image = "elona.item_broken_sword",
         value = 10,
         weight = 1050,
         category = 64000,
         subcategory = 64000,
         coefficient = 100,
         categories = {
            "elona.junk",
            "elona.junk_in_field"
         }
      },
      {
         _id = "bone_fragment",
         elona_id = 51,
         image = "elona.item_bone_fragment",
         value = 10,
         weight = 80,
         category = 64000,
         subcategory = 64000,
         coefficient = 100,
         categories = {
            "elona.junk",
            "elona.junk_in_field"
         }
      },
      {
         _id = "skeleton",
         elona_id = 52,
         image = "elona.item_skeleton",
         value = 10,
         weight = 80,
         category = 64000,
         coefficient = 100,
         categories = {
            "elona.junk"
         }
      },
      {
         _id = "tombstone",
         elona_id = 53,
         image = "elona.item_tombstone",
         value = 10,
         weight = 12000,
         category = 64000,
         coefficient = 100,
         categories = {
            "elona.junk"
         }
      },
      {
         _id = "gold_piece",
         elona_id = 54,
         image = "elona.item_gold_piece",
         value = 1,
         weight = 0,
         category = 68000,
         coefficient = 100,

         prevent_sell_in_own_shop = true,

         events = {
            {
               id = "base.on_get_item",
               name = "Add gold to inventory",
               priority = 50000,

               callback = function(self, params)
                  Gui.play_sound("base.getgold1", params.chara.x, params.chara.y)
                  Gui.mes("action.pick_up.execute", params.chara, self:build_name(params.amount))
                  params.chara.gold = params.chara.gold + self.amount
                  self:remove_ownership()
                  return true
               end
            },
            {
               id = "elona.on_item_created_from_wish",
               name = "Adjust amount",

               callback = function(self, params)
                  -- >>>>>>>> shade2/command.hsp:1595 		if iId(ci)=idGold:iNum(ci)=cLevel(pc)*cLevel(pc) ..
                  self.amount = params.chara:calc("level") * params.chara:calc("level") * 50 + 20000
                  -- <<<<<<<< shade2/command.hsp:1595 		if iId(ci)=idGold:iNum(ci)=cLevel(pc)*cLevel(pc) ..
               end
            },
         },

         on_init_params = function(self, params)
            -- >>>>>>>> shade2/item.hsp:650 	if iId(ci)=idGold{ ..
            self.amount = hook_calc_initial_gold({item=self,owner=params.owner})
            if self:calc("quality") == Enum.Quality.Good then
               self.amount = self.amount * 2
            end
            if self:calc("quality") >= Enum.Quality.Great then
               self.amount = self.amount * 4
            end

            if params.owner then
               params.owner.gold = params.owner.gold + self.amount
               self:remove_ownership()
            end
            -- <<<<<<<< shade2/item.hsp:655 		} ..
         end,

         categories = {
            "elona.gold"
         }
      },
      {
         _id = "platinum_coin",
         elona_id = 55,
         image = "elona.item_platinum_coin",
         value = 1,
         weight = 1,
         category = 69000,
         coefficient = 100,
         tags = { "noshop" },
         always_drop = true,

         categories = {
            "elona.platinum",
            "elona.tag_noshop"
         },

         events = {
            {
               id = "base.on_get_item",
               name = "Add platinum to inventory",
               priority = 50000,

               callback = function(self, params)
                  Gui.mes("action.pick_up.execute", params.chara, self:build_name(params.amount))
                  Gui.play_sound(Rand.choice({"base.get1", "base.get2"}), params.chara.x, params.chara.y)
                  params.chara.platinum = params.chara.platinum + self.amount
                  self:remove_ownership()
               end
            },
            {
               id = "elona.on_item_created_from_wish",
               name = "Adjust amount",

               callback = function(self, params)
                  -- >>>>>>>> shade2/command.hsp:1596 		if iId(ci)=idPlat:iNum(ci)=8+rnd(5) ..
                  self.amount = 8 + Rand.rnd(5)
                  -- <<<<<<<< shade2/command.hsp:1596 		if iId(ci)=idPlat:iNum(ci)=8+rnd(5) ..
               end
            },
         }
      },
      {
         _id = "ore_piece",
         elona_id = 214,
         image = "elona.item_ore_piece",
         value = 180,
         weight = 12000,
         category = 64000,
         subcategory = 64000,
         coefficient = 100,

         random_color = "Furniture",

         categories = {
            "elona.junk",
            "elona.junk_in_field"
         }
      },
      {
         _id = "lot_of_empty_bottles",
         elona_id = 215,
         image = "elona.item_whisky",
         value = 10,
         weight = 220,
         category = 64000,
         subcategory = 64100,
         coefficient = 100,
         originalnameref2 = "lot",
         random_color = "Furniture",
         categories = {
            "elona.junk_town",
            "elona.junk"
         }
      },
      {
         _id = "basket",
         elona_id = 216,
         image = "elona.item_basket",
         value = 40,
         weight = 80,
         category = 64000,
         coefficient = 100,
         tags = { "fest" },
         random_color = "Furniture",
         categories = {
            "elona.tag_fest",
            "elona.junk"
         }
      },
      {
         _id = "empty_bowl",
         elona_id = 217,
         image = "elona.item_empty_bowl",
         value = 25,
         weight = 90,
         category = 64000,
         coefficient = 100,
         random_color = "Furniture",
         categories = {
            "elona.junk"
         }
      },
      {
         _id = "bowl",
         elona_id = 218,
         image = "elona.item_bowl",
         value = 30,
         weight = 80,
         category = 64000,
         coefficient = 100,
         random_color = "Furniture",
         categories = {
            "elona.junk"
         }
      },
      {
         _id = "straw",
         elona_id = 221,
         image = "elona.item_straw",
         value = 7,
         weight = 70,
         category = 64000,
         coefficient = 100,
         categories = {
            "elona.junk"
         }
      },
      {
         _id = "animal_bone",
         elona_id = 222,
         image = "elona.item_animal_bone",
         value = 8,
         weight = 40,
         category = 64000,
         subcategory = 64000,
         coefficient = 100,
         categories = {
            "elona.junk",
            "elona.junk_in_field"
         }
      },
      {
         _id = "bejeweled_chest",
         elona_id = 239,
         image = "elona.item_small_gamble_chest",
         value = 3000,
         weight = 3000,
         category = 72000,
         rarity = 100000,
         coefficient = 100,
         random_color = "Furniture",
         categories = {
            "elona.container"
         },
         light = light.item,

         -- >>>>>>>> shade2/action.hsp:984 	if iId(ri)=idChestGood{ ...
         on_open = open_chest(
            function(filter, item, gen_iteration)
               if gen_iteration == 1 and Rand.one_in(3) then
                  filter.quality = Enum.Quality.Great
               else
                  filter.quality = Enum.Quality.Good
               end
               if Rand.one_in(60) then
                  filter.id = "elona.potion_of_cure_corruption"
               end
               return filter
         end),
         -- <<<<<<<< shade2/action.hsp:987 		} ..
      },
      {
         _id = "chest",
         elona_id = 240,
         image = "elona.item_small_gamble_chest",
         value = 1200,
         weight = 300000,
         category = 72000,
         rarity = 500000,
         coefficient = 100,
         random_color = "Furniture",
         categories = {
            "elona.container"
         },
         light = light.item,

         on_open = open_chest(
            function(filter, item, gen_iteration)
               return filter
         end),
      },
      {
         _id = "safe",
         elona_id = 241,
         image = "elona.item_shop_strongbox",
         value = 1000,
         weight = 300000,
         category = 72000,
         rarity = 500000,
         coefficient = 100,
         random_color = "Furniture",
         categories = {
            "elona.container"
         },
         light = light.item,

         -- >>>>>>>> shade2/action.hsp:992 	if iId(ri)=idChestMoney: if rnd(3)!0: fltTypeMino ...
         on_open = open_chest(function(filter, item)
               if not Rand.one_in(3) then
                  filter.categories = { "elona.gold" }
               else
                  filter.categories = { "elona.ore_valuable" }
               end
               return filter
         end),
         -- <<<<<<<< shade2/action.hsp:992 	if iId(ri)=idChestMoney: if rnd(3)!0: fltTypeMino ..
      },
      {
         _id = "fire_wood",
         elona_id = 273,
         image = "elona.item_fire_wood",
         value = 10,
         weight = 1500,
         category = 64000,
         coefficient = 100,
         random_color = "Furniture",
         categories = {
            "elona.junk"
         }
      },
      {
         _id = "scarecrow",
         elona_id = 274,
         image = "elona.item_scarecrow",
         value = 10,
         weight = 4800,
         category = 64000,
         coefficient = 100,
         random_color = "Furniture",
         categories = {
            "elona.junk"
         }
      },
      {
         _id = "broom",
         elona_id = 275,
         image = "elona.item_broom",
         value = 100,
         weight = 800,
         category = 64000,
         coefficient = 100,
         categories = {
            "elona.junk"
         }
      },
      {
         _id = "suitcase",
         elona_id = 283,
         image = "elona.item_heir_trunk",
         value = 380,
         weight = 1200,
         fltselect = 1,
         category = 72000,
         coefficient = 100,

         categories = {
            "elona.container",
            "elona.no_generate"
         },

         on_init_params = function(self)
            -- >>>>>>>> shade2/item.hsp:684 		if iId(ci)=idSuitcase : iParam1(ci)=(rnd(10)+1)* ...
            local player = Chara.player()
            self.params.chest_item_level = (Rand.rnd(10) + 1) * ((player and player:calc("level") or 1) / 10 + 1)
            -- <<<<<<<< shade2/item.hsp:684 		if iId(ci)=idSuitcase : iParam1(ci)=(rnd(10)+1)* ..
            -- >>>>>>>> shade2/item.hsp:687 		if (iId(ci)=idWallet)or(iId(ci)=idSuitcase):iPar ...
            self.params.chest_lockpick_difficulty = Rand.rnd(15)
            -- <<<<<<<< shade2/item.hsp:687 		if (iId(ci)=idWallet)or(iId(ci)=idSuitcase):iPar ..
         end,

         -- >>>>>>>> shade2/action.hsp:1024 	if iID(ri)=idSuitcase	: modKarma pc,-8 ...
         on_open = open_chest(nil, nil, function(self, params) Effect.modify_karma(params.chara, -8) end),
         -- <<<<<<<< shade2/action.hsp:1024 	if iID(ri)=idSuitcase	: modKarma pc,-8 ..
      },
      {
         _id = "wallet",
         elona_id = 284,
         image = "elona.item_wallet",
         value = 380,
         weight = 250,
         fltselect = 1,
         category = 72000,
         coefficient = 100,

         on_init_params = function(self)
            -- >>>>>>>> shade2/item.hsp:687 		if (iId(ci)=idWallet)or(iId(ci)=idSuitcase):iPar ...
            self.params.chest_lockpick_difficulty = Rand.rnd(15)
            -- <<<<<<<< shade2/item.hsp:687 		if (iId(ci)=idWallet)or(iId(ci)=idSuitcase):iPar ..
         end,

         -- >>>>>>>> shade2/action.hsp:1004 	if iID(ri)=idWallet{ ...
         on_open = open_chest(
            function(filter, item)
               filter.id = "elona.gold_piece"
               local amount = Rand.rnd(1000) + 1
               if Rand.one_in(5) then
                  amount = Rand.rnd(9) + 1
               end
               if Rand.one_in(10) then
                  amount = Rand.rnd(5000) + 5000
               end
               if Rand.one_in(20) then
                  amount = Rand.rnd(20000) + 10000
               end
               filter.amount = amount
               return filter
            end, nil, function(self, params) Effect.modify_karma(params.chara, -4) end),
         -- <<<<<<<< shade2/action.hsp:1010 		} ..

         categories = {
            "elona.container",
            "elona.no_generate"
         },
      },
      {
         _id = "large_bouquet",
         elona_id = 301,
         image = "elona.item_large_bouquet",
         value = 240,
         weight = 1400,
         category = 64000,
         coefficient = 100,
         categories = {
            "elona.junk"
         }
      },
      {
         _id = "stump",
         elona_id = 330,
         image = "elona.item_stump",
         value = 250,
         weight = 3500,
         category = 64000,
         coefficient = 100,

         elona_function = 44,

         categories = {
            "elona.junk"
         }
      },
      {
         _id = "remains_skin",
         elona_id = 337,
         image = "elona.item_rabbits_tail",
         value = 100,
         weight = 1500,
         category = 62000,
         coefficient = 100,
         params = { chara_id = nil },
         categories = {
            "elona.remains"
         }
      },
      {
         _id = "remains_blood",
         elona_id = 338,
         image = "elona.item_remains_blood",
         value = 100,
         weight = 1500,
         category = 62000,
         rarity = 200000,
         coefficient = 100,
         params = { chara_id = nil },
         categories = {
            "elona.remains"
         }
      },
      {
         _id = "remains_eye",
         elona_id = 339,
         image = "elona.item_remains_eye",
         value = 100,
         weight = 1500,
         category = 62000,
         rarity = 400000,
         coefficient = 100,
         params = { chara_id = nil },
         categories = {
            "elona.remains"
         }
      },
      {
         _id = "remains_heart",
         elona_id = 340,
         image = "elona.item_remains_heart",
         value = 100,
         weight = 1500,
         category = 62000,
         rarity = 100000,
         coefficient = 100,
         params = { chara_id = nil },
         categories = {
            "elona.remains"
         }
      },
      {
         _id = "remains_bone",
         elona_id = 341,
         image = "elona.item_remains_bone",
         value = 100,
         weight = 1500,
         category = 62000,
         coefficient = 100,
         params = { chara_id = nil },
         categories = {
            "elona.remains"
         }
      },
      {
         _id = "shopkeepers_trunk",
         elona_id = 361,
         image = "elona.item_heir_trunk",
         value = 380,
         weight = 1200,
         fltselect = 1,
         category = 72000,
         coefficient = 100,
         categories = {
            "elona.container",
            "elona.no_generate"
         },
         is_wishable = false,

         on_init_params = function(self)
         end,

         container_params = {
            type = "local"
         },

         on_open = function(self, params)
            -- >>>>>>>> shade2/action.hsp:890 	if iId(ci)=idShopBag{ ...
            local chara = params.chara

            Effect.modify_karma(chara, -10)

            -- Only allow taking, not putting. (provide "nil" to inventory group ID)
            Gui.play_sound("base.chest1")
            assert(self:is_item_container())
            Input.query_inventory(chara, "elona.inv_take_container", { container = self, params={query_leftover=true} }, nil)

            return "turn_end"
            -- <<<<<<<< shade2/action.hsp:894 		} ..
         end
      },
      {
         _id = "material_box",
         elona_id = 394,
         image = "elona.item_material_box",
         value = 500,
         weight = 1200,
         category = 72000,
         coefficient = 100,
         categories = {
            "elona.container"
         }
      },
      {
         _id = "treasure_ball",
         elona_id = 415,
         image = "elona.item_rare_treasure_ball",
         value = 4000,
         weight = 500,
         category = 72000,
         rarity = 100000,
         coefficient = 100,

         categories = {
            "elona.container"
         },

         on_init_params = function(self)
            local player = Chara.player()
            self.params.chest_item_level = (player and player:calc("level")) or 1
         end,

         -- >>>>>>>> shade2/action.hsp:994 	if (iID(ri)=415)or(iID(ri)=416){ ...
         on_open = open_chest(
            function(filter, item)
               filter.categories = {Rand.choice(Filters.fsetwear)}
               filter.quality = Enum.Quality.Good
               if Rand.one_in(30) then
                  filter.id = "elona.potion_of_cure_corruption"
               end

               return filter
            end, 1),
         -- <<<<<<<< shade2/action.hsp:998 		} ..
      },
      {
         _id = "rare_treasure_ball",
         elona_id = 416,
         image = "elona.item_rare_treasure_ball",
         value = 12000,
         weight = 500,
         category = 72000,
         rarity = 25000,
         coefficient = 100,
         tags = { "spshop" },

         categories = {
            "elona.container",
            "elona.tag_spshop"
         },

         on_init_params = function(self)
            local player = Chara.player()
            self.params.chest_item_level = (player and player:calc("level")) or 1
         end,

         -- >>>>>>>> shade2/action.hsp:994 	if (iID(ri)=415)or(iID(ri)=416){ ...
         on_open = open_chest(
            function(filter, item)
               filter.categories = {Rand.choice(Filters.fsetwear)}
               filter.quality = Enum.Quality.Great
               if Rand.one_in(30) then
                  filter.id = "elona.potion_of_cure_corruption"
               end

               return filter
            end, 1),
         -- <<<<<<<< shade2/action.hsp:998 		} ..
      },
      {
         _id = "figurine",
         elona_id = 503,
         image = "elona.item_figurine",
         value = 1000,
         weight = 2500,
         fltselect = 1,
         category = 62000,
         rarity = 100000,
         coefficient = 100,
         params = { chara_id = nil },
         categories = {
            "elona.remains",
            "elona.no_generate"
         },
      },
      {
         _id = "card",
         elona_id = 504,
         image = "elona.item_card",
         value = 500,
         weight = 200,
         fltselect = 1,
         category = 62000,
         rarity = 100000,
         coefficient = 100,
         params = { chara_id = nil },
         categories = {
            "elona.remains",
            "elona.no_generate"
         }
      },
      {
         _id = "heir_trunk",
         elona_id = 510,
         image = "elona.item_heir_trunk",
         value = 4500,
         weight = 20000,
         fltselect = 1,
         category = 72000,
         coefficient = 100,

         categories = {
            "elona.container",
            "elona.no_generate"
         }
      },
      {
         _id = "tree_of_beech",
         elona_id = 523,
         image = "elona.item_tree_of_beech",
         value = 700,
         weight = 45000,
         category = 80000,
         rarity = 3000000,
         coefficient = 100,
         originalnameref2 = "tree",
         categories = {
            "elona.tree"
         }
      },
      {
         _id = "tree_of_cedar",
         elona_id = 524,
         image = "elona.item_tree_of_cedar",
         value = 500,
         weight = 38000,
         category = 80000,
         rarity = 800000,
         coefficient = 100,
         originalnameref2 = "tree",
         categories = {
            "elona.tree"
         }
      },
      {
         _id = "tree_of_fruitless",
         elona_id = 525,
         image = "elona.item_tree_of_fruitless",
         value = 500,
         weight = 35000,
         fltselect = 1,
         category = 80000,
         rarity = 100000,
         coefficient = 100,
         originalnameref2 = "tree",
         categories = {
            "elona.tree",
            "elona.no_generate"
         }
      },
      {
         _id = "tree_of_fruits",
         elona_id = 526,
         image = "elona.item_tree_of_fruits",
         value = 2000,
         weight = 42000,
         category = 80000,
         rarity = 100000,
         coefficient = 100,
         originalnameref2 = "tree",

         params = {
            fruit_tree_amount = 0,
            fruit_tree_item_id = "elona.apple"
         },
         on_init_params = function(self)
            local FRUITS = {
               "elona.apple",
               "elona.grape",
               "elona.orange",
               "elona.lemon",
               "elona.strawberry",
               "elona.cherry"
            }
            self.params.fruit_tree_amount = Rand.rnd(2) + 3
            self.params.fruit_tree_item_id = Rand.choice(FRUITS)
         end,

         events = {
            {
               id = "elona_sys.on_item_bash",
               name = "Fruit tree bash behavior",

               callback = function(self)
                  self = self:separate()
                  Gui.play_sound("base.bash1")
                  Gui.mes("action.bash.tree.execute", self:build_name(1))
                  local fruits = self.params.fruit_tree_amount
                  if self:calc("own_state") == "unobtainable" or fruits <= 0 then
                     Gui.mes("action.bash.tree.no_fruits")
                     return "turn_end"
                  end
                  self.params.fruit_tree_amount = fruits - 1
                  if self.params.fruit_tree_amount <= 0 then
                     self.image = "elona.item_tree_of_fruitless"
                  end

                  local x = self.x
                  local y = self.y
                  local map = self:current_map()
                  if y + 1 < map:height() and map:can_access(x, y + 1) then
                     y = y + 1
                  end
                  local item = Item.create(self.params.fruit_tree_item_id, x, y, {}, map)
                  Gui.mes("action.bash.tree.falls_down", item:build_name(1))

                  return "turn_end"
               end
            },
            {
               id = "base.on_item_renew_major",
               name = "Fruit tree restock",

               callback = function(self)
                  if self.params.fruit_tree_amount < 10 then
                     self.params.fruit_tree_amount = self.params.fruit_tree_amount + 1
                     self.image = "elona.item_tree_of_fruits"
                  end
               end
            }
         },

         categories = {
            "elona.tree"
         }
      },
      {
         _id = "dead_tree",
         elona_id = 527,
         image = "elona.item_dead_tree",
         value = 500,
         weight = 20000,
         category = 80000,
         rarity = 500000,
         coefficient = 100,
         categories = {
            "elona.tree"
         }
      },
      {
         _id = "tree_of_zelkova",
         elona_id = 528,
         image = "elona.item_tree_of_zelkova",
         value = 800,
         weight = 28000,
         category = 80000,
         rarity = 1500000,
         coefficient = 100,
         originalnameref2 = "tree",
         categories = {
            "elona.tree"
         }
      },
      {
         _id = "tree_of_palm",
         elona_id = 529,
         image = "elona.item_tree_of_palm",
         value = 1000,
         weight = 39000,
         category = 80000,
         rarity = 200000,
         coefficient = 100,
         originalnameref2 = "tree",
         categories = {
            "elona.tree"
         }
      },
      {
         _id = "tree_of_ash",
         elona_id = 530,
         image = "elona.item_tree_of_ash",
         value = 900,
         weight = 28000,
         category = 80000,
         rarity = 500000,
         coefficient = 100,
         originalnameref2 = "tree",
         categories = {
            "elona.tree"
         }
      },
      {
         _id = "salary_chest",
         elona_id = 547,
         image = "elona.item_salary_chest",
         value = 6400,
         weight = 20000,
         fltselect = 1,
         category = 72000,
         coefficient = 100,

         on_open = function(self, params)
            -- >>>>>>>> shade2/action.hsp:896 	if iId(ci)=idTaxBox  :invCtrl=24,2:snd seInv:goto ...
            local inv = Inventory.get_or_create("elona.salary_chest")
            Input.query_inventory(params.chara, "elona.inv_take_container", { container = inv }, nil)

            return "turn_end"
            -- <<<<<<<< shade2/action.hsp:896 	if iId(ci)=idTaxBox  :invCtrl=24,2:snd seInv:goto ..
         end,

         categories = {
            "elona.container",
            "elona.no_generate"
         }
      },
      {
         _id = "masters_delivery_chest",
         elona_id = 560,
         image = "elona.item_masters_delivery_chest",
         value = 380,
         weight = 20000,
         fltselect = 1,
         category = 72000,
         coefficient = 100,

         is_precious = true,

         on_open = function(self, params)
            local chara = params.chara
            local map = chara:current_map()

            -- >>>>>>>> shade2/action.hsp:895 	if iId(ci)=idChestPay:invCtrl=24,0:snd seInv:goto ..
            if map._archetype == "elona.lumiest" or map._archetype == "elona.mages_guild" then
               Input.query_inventory(params.chara, "elona.inv_mages_guild_delivery_chest", nil, nil)
            else
               Input.query_inventory(params.chara, "elona.inv_harvest_delivery_chest", nil, nil)
            end
            -- <<<<<<<< shade2/action.hsp:895 	if iId(ci)=idChestPay:invCtrl=24,0:snd seInv:goto ..

            return "player_turn_query"
         end,

         categories = {
            "elona.container",
            "elona.no_generate"
         }
      },
      {
         _id = "shop_strongbox",
         elona_id = 561,
         image = "elona.item_shop_strongbox",
         value = 7200,
         weight = 20000,
         fltselect = 1,
         category = 72000,
         coefficient = 100,

         prevent_sell_in_own_shop = true,

         on_open = function(self, params)
            -- >>>>>>>> shade2/action.hsp:895 	if iId(ci)=idChestPay:invCtrl=24,0:snd seInv:goto ...
            local inv = Inventory.get_or_create("elona.shop_strongbox")
            Input.query_inventory(params.chara, "elona.inv_take_container", { container = inv }, nil)

            return "turn_end"
            -- <<<<<<<< shade2/action.hsp:895 	if iId(ci)=idChestPay:invCtrl=24,0:snd seInv:goto ..
         end,

         categories = {
            "elona.container",
            "elona.no_generate"
         }
      },
      {
         _id = "textbook",
         elona_id = 563,
         image = "elona.item_textbook",
         value = 4800,
         weight = 80,
         category = 55000,
         rarity = 50000,
         coefficient = 100,

         params = { textbook_skill_id = nil },
         on_init_params = function(self, params)
            -- >>>>>>>> shade2/item.hsp:619 	if iId(ci)=idBookSkill	:if iBookId(ci)=0:iBookId( ..
            self.params.textbook_skill_id = Skill.random_skill()
            -- <<<<<<<< shade2/item.hsp:619 	if iId(ci)=idBookSkill	:if iBookId(ci)=0:iBookId( ..
         end,

         on_read = function(self, params)
            -- >>>>>>>> shade2/command.hsp:4447 	if iId(ci)=idBookSkill{ ...
            local skill_id = self.params.textbook_skill_id
            local chara = params.chara
            if chara:is_player() and not chara:has_skill(skill_id) then
               Gui.mes("action.read.book.not_interested")
               if not Input.yes_no() then
                  return "player_turn_query"
               end
            end

            chara:start_activity("elona.training", {skill_id=skill_id,item=self})

            return "turn_end"
            -- <<<<<<<< shade2/command.hsp:4454 		} ...         end,
         end,

         elona_type = "normal_book",

         categories = {
            "elona.book"
         }
      },
      {
         _id = "shit",
         elona_id = 575,
         image = "elona.item_shit",
         value = 25,
         weight = 80,
         category = 64000,
         rarity = 250000,
         coefficient = 100,
         params = { chara_id = nil },
         categories = {
            "elona.junk"
         }
      },
      {
         _id = "freezer",
         elona_id = 579,
         image = "elona.item_freezer",
         value = 3800,
         weight = 15000,
         level = 30,
         fltselect = 1,
         category = 72000,
         rarity = 50000,
         coefficient = 100,

         on_open = function(self, params)
            -- >>>>>>>> shade2/action.hsp:932 			if invFile=roleFileFreezer : invContainer=15:el ...
            local inv = Inventory.get_or_create("elona.freezer")
            inv:set_max_capacity(15)
            Input.query_inventory(params.chara, "elona.inv_take_food_container", { params = { container_item = self }, container = inv }, "elona.food_container")
            -- <<<<<<<< shade2/action.hsp:932 			if invFile=roleFileFreezer : invContainer=15:el ..

            return "turn_end"
         end,

         categories = {
            "elona.container",
            "elona.no_generate"
         },

         events = {
            {
               id = "base.after_container_receive_item",
               name = "Reset spoilage date",

               callback = function(self, params)
                  local item = params.item
                  if item.spoilage_date and item.spoilage_date >= 0 and item.spoilage_hours then
                     item.spoilage_date = 0
                  end
               end
            },
            {
               id = "base.after_container_provide_item",
               name = "Reset spoilage date",

               callback = function(self, params)
                  local item = params.item
                  if (item.spoilage_date or 0) >= 0 and item.spoilage_hours then
                     item.spoilage_date = World.date_hours() + item.spoilage_hours
                  end
               end
            },
         }
      },
      {
         _id = "tree_of_naked",
         elona_id = 588,
         image = "elona.item_tree_of_naked",
         value = 500,
         weight = 14000,
         fltselect = 8,
         category = 80000,
         rarity = 250000,
         coefficient = 100,
         originalnameref2 = "tree",
         categories = {
            "elona.tree",
            "elona.snow_tree"
         }
      },
      {
         _id = "tree_of_fir",
         elona_id = 589,
         image = "elona.item_tree_of_fir",
         value = 1800,
         weight = 28000,
         fltselect = 8,
         category = 80000,
         rarity = 100000,
         coefficient = 100,
         originalnameref2 = "tree",
         categories = {
            "elona.tree",
            "elona.snow_tree"
         }
      },
      {
         _id = "snow_scarecrow",
         elona_id = 590,
         image = "elona.item_snow_scarecrow",
         value = 10,
         weight = 4800,
         category = 64000,
         coefficient = 100,
         random_color = "Furniture",
         categories = {
            "elona.junk"
         }
      },
      {
         _id = "christmas_tree",
         elona_id = 599,
         image = "elona.item_christmas_tree",
         value = 4800,
         weight = 35000,
         level = 30,
         fltselect = 8,
         category = 80000,
         rarity = 100000,
         coefficient = 100,
         categories = {
            "elona.tree",
            "elona.snow_tree"
         },
         light = light.crystal_high
      },
      {
         _id = "giants_shackle",
         elona_id = 600,
         image = "elona.item_giants_shackle",
         value = 1800,
         weight = 150000,
         level = 10,
         fltselect = 1,
         category = 72000,
         rarity = 100000,
         coefficient = 100,

         is_precious = true,

         on_open = function(self, params)
            -- >>>>>>>> shade2/action.hsp:899 		snd seLocked : txt lang("足枷を外した。","You unlock th ...
            Gui.play_sound("base.locked1")
            Gui.mes("action.open.shackle.text")
            local map = params.chara:current_map()
            if map and map._archetype == "elona.noyel" and not save.elona.is_fire_giant_released then
               local fire_giant = map:get_object_of_type("base.chara", save.elona.fire_giant_uid)
               if Chara.is_alive(fire_giant) then
                  local moyer = Chara.find("elona.moyer_the_crooked")
                  if Chara.is_alive(moyer) then
                     Gui.mes_c("action.open.shackle.dialog", "SkyBlue")
                     fire_giant:set_target(moyer, 1000)
                  end
               end
               save.elona.is_fire_giant_released = true
            end
            return "turn_end"
            -- <<<<<<<< shade2/action.hsp:908 		goto *turn_end ..
         end,

         categories = {
            "elona.container",
            "elona.no_generate"
         },

         light = light.item
      },
      {
         _id = "tax_masters_tax_box",
         elona_id = 616,
         image = "elona.item_tax_masters_tax_box",
         value = 14500,
         weight = 6500,
         level = 30,
         fltselect = 1,
         category = 72000,
         rarity = 100000,
         coefficient = 100,

         on_open = function(self, params)
            -- >>>>>>>> shade2/action.hsp:895 	if iId(ci)=idChestPay:invCtrl=24,0:snd seInv:goto ..
            Input.query_inventory(params.chara, "elona.inv_put_tax_box", nil, nil)
            -- <<<<<<<< shade2/action.hsp:895 	if iId(ci)=idChestPay:invCtrl=24,0:snd seInv:goto ..
            return "player_turn_query"
         end,

         is_precious = true,

         medal_value = 18,

         categories = {
            "elona.container",
            "elona.no_generate"
         }
      },
      {
         _id = "bait",
         elona_id = 617,
         image = "elona.item_bait_water_flea",
         value = 1000,
         weight = 250,
         fltselect = 1,
         category = 64000,
         coefficient = 100,

         on_dip_into = function(self, params)
            -- >>>>>>>> shade2/action.hsp:1600 	if iId(ciDip)=idBite{	 ...
            local target_item = params.target_item
            target_item = target_item:separate()
            self:remove(1)
            Gui.play_sound("base.equip1")
            Gui.mes("action.dip.result.bait_attachment", target_item:build_name(), self:build_name(1))

            if target_item.params.bait_type == self.params.bait_type then
               target_item.params.bait_amount = target_item.params.bait_amount + Rand.rnd(10) + 15
            else
               target_item.params.bait_amount = Rand.rnd(10) + 15
               target_item.params.bait_type = self.params.bait_type
            end

            return "turn_end"
            -- <<<<<<<< shade2/action.hsp:1605 		} ..
         end,

         params = { bait_type = "elona.water_flea" },

         on_init_params = function(self)
            -- >>>>>>>> shade2/item.hsp:638:DONE 	if iId(ci)=idBite{ ..
            self.params.bait_type = Rand.choice {
               "elona.water_flea",
               "elona.grasshopper",
               "elona.ladybug",
               "elona.dragonfly",
               "elona.locust",
               "elona.beetle",
            }

            local proto = data["elona.bait"]:ensure(self.params.bait_type)
            self.image = proto.image or self.image

            self.value = proto.value or proto.rank * proto.rank * 500 + 200
            -- <<<<<<<< shade2/item.hsp:642 		} ..
         end,

         categories = {
            "elona.no_generate",
            "elona.junk"
         },

         events = {
            {
               id = "elona_sys.calc_item_can_dip_into",
               name = "Bait dipping",

               callback = function(self, params)
                  return params.item._id == "elona.fishing_pole"
               end
            },
         },
      },
      {
         _id = "small_medal",
         elona_id = 622,
         image = "elona.item_small_medal",
         value = 1,
         weight = 1,
         category = 77000,
         rarity = 10000,
         coefficient = 100,

         is_precious = true,
         always_stack = true,

         tags = { "noshop" },
         rftags = { "ore" },
         categories = {
            "elona.tag_noshop",
            "elona.ore"
         }
      },
      {
         _id = "cooler_box",
         elona_id = 641,
         image = "elona.item_cooler_box",
         value = 7500,
         weight = 2500,
         level = 30,
         fltselect = 3,
         category = 72000,
         rarity = 50000,
         coefficient = 100,

         container_params = {
            type = "local",
            max_capacity = 4,
            combine_weight = true
         },

         on_open = function(self, params)
            Input.query_inventory(params.chara, "elona.inv_take_food_container", { params = { container_item = self }, container = self.inv }, "elona.food_container")

            return "player_turn_query"
         end,

         is_precious = true,
         quality = Enum.Quality.Unique,

         can_use_flight_on = false,

         categories = {
            "elona.container",
            "elona.unique_item"
         },

         events = {
            {
               id = "base.after_container_receive_item",
               name = "Reset spoilage date",

               callback = function(self, params)
                  local item = params.item
                  if item.spoilage_date and item.spoilage_date >= 0 and item.spoilage_hours then
                     item.spoilage_date = 0
                  end
               end
            },
            {
               id = "base.after_container_provide_item",
               name = "Reset spoilage date",

               callback = function(self, params)
                  local item = params.item
                  if (item.spoilage_date or 0) >= 0 and item.spoilage_hours then
                     item.spoilage_date = World.date_hours() + item.spoilage_hours
                  end
               end
            },
         }
      },
      {
         _id = "monster_heart",
         elona_id = 663,
         image = "elona.item_monster_heart",
         value = 25000,
         weight = 2500,
         fltselect = 3,
         category = 64000,
         rarity = 800000,
         coefficient = 100,

         is_precious = true,
         quality = Enum.Quality.Unique,
         categories = {
            "elona.unique_item",
            "elona.junk"
         },
         light = light.item
      },
      {
         _id = "book_of_rachel",
         elona_id = 668,
         image = "elona.item_book",
         value = 4000,
         weight = 80,
         category = 55000,
         rarity = 50000,
         coefficient = 0,

         params = { book_of_rachel_number = 1 },
         on_init_params = function(self)
            self.params.book_of_rachel_number = Rand.rnd(4) + 1
         end,

         on_read = function(self)
            -- >>>>>>>> shade2/proc.hsp:1250 	if iId(ci)=idDeedVoid: :snd seOpenBook: txt lang( ...
            Gui.play_sound("base.book1")
            Gui.mes("action.read.book.book_of_rachel")
            return "turn_end"
            -- <<<<<<<< shade2/proc.hsp:1250 	if iId(ci)=idDeedVoid: :snd seOpenBook: txt lang( ..
         end,

         elona_type = "normal_book",

         tags = { "noshop" },

         categories = {
            "elona.book",
            "elona.tag_noshop"
         }
      },
      {
         _id = "town_book",
         elona_id = 700,
         image = "elona.item_town_book",
         value = 750,
         weight = 20,
         on_read = function()
            -- menucycle = 1,
            -- show_city_chart(),
         end,
         category = 55000,
         rarity = 20000,
         coefficient = 0,
         categories = {
            "elona.book"
         }
      },
      {
         _id = "music_ticket",
         elona_id = 724,
         image = "elona.item_token_of_friendship",
         value = 1,
         weight = 1,
         fltselect = 1,
         category = 77000,
         rarity = 10000,
         coefficient = 100,

         is_precious = true,

         tags = { "noshop" },
         rftags = { "ore" },
         categories = {
            "elona.tag_noshop",
            "elona.no_generate",
            "elona.ore"
         }
      },
      {
         _id = "token_of_friendship",
         elona_id = 730,
         image = "elona.item_token_of_friendship",
         value = 1,
         weight = 1,
         fltselect = 1,
         category = 77000,
         rarity = 10000,
         coefficient = 100,
         originalnameref2 = "token",

         is_precious = true,

         tags = { "noshop" },
         rftags = { "ore" },
         categories = {
            "elona.tag_noshop",
            "elona.no_generate",
            "elona.ore"
         }
      },
      {
         _id = "small_gamble_chest",
         elona_id = 734,
         image = "elona.item_small_gamble_chest",
         value = 1200,
         weight = 3400,
         category = 72000,
         rarity = 50000,
         coefficient = 100,

         on_generate = function(self)
            -- >>>>>>>> shade2/item.hsp:689 		if iId(ci)=idGambleChest{ ...
            self.params.chest_lockpick_difficulty = Rand.rnd(Rand.rnd(100) + 1) + 1
            self.value = self.params.chest_lockpick_difficulty * 25 + 150
            self.amount = Rand.rnd(8)
            -- <<<<<<<< shade2/item.hsp:691 			} ..
         end,

         -- >>>>>>>> shade2/action.hsp:1000 	if iId(ri)=idGambleChest{ ...
         on_open = open_chest(
            function(filter, item)
               filter.id = "elona.gold_piece"

               if Rand.one_in(75) then
                  filter.amount = 50 * item:calc("value")
               else
                  filter.amount = Rand.rnd(item:calc("value")/10+1)+1
               end

               return filter
            end, 1),
         -- <<<<<<<< shade2/action.hsp:1003 		} ..

         categories = {
            "elona.container"
         }
      },
      {
         _id = "book_of_bokonon",
         elona_id = 747,
         image = "elona.item_book",
         value = 4000,
         weight = 80,
         fltselect = 1,
         category = 55000,
         rarity = 50000,
         coefficient = 0,
         originalnameref2 = "book",

         param1 = 1,

         params = { book_of_bokonon_no = 1 },
         on_init_params = function(self)
            self.params.book_of_bokonon_no = Rand.rnd(4) + 1
         end,

         elona_type = "normal_book",

         tags = { "noshop" },

         categories = {
            "elona.book",
            "elona.tag_noshop",
            "elona.no_generate"
         }
      },
      {
         _id = "new_years_gift",
         elona_id = 752,
         image = "elona.item_new_years_gift",
         value = 1650,
         weight = 80,
         fltselect = 1,
         category = 72000,
         rarity = 50000,
         coefficient = 100,
         categories = {
            "elona.container",
            "elona.no_generate"
         },

         on_open = open_new_years_gift
      },
      {
         _id = "recipe_holder",
         elona_id = 784,
         image = "elona.item_recipe_holder",
         value = 2500,
         weight = 550,
         category = 72000,
         rarity = 100000,
         coefficient = 0,
         categories = {
            "elona.container"
         }
      },
   }

data:add_multi("base.item", item)

require("mod.elona.data.item.cargo")
require("mod.elona.data.item.equip")
require("mod.elona.data.item.fish")
require("mod.elona.data.item.food")
require("mod.elona.data.item.furniture")
require("mod.elona.data.item.ore")
require("mod.elona.data.item.potion")
require("mod.elona.data.item.rod")
require("mod.elona.data.item.scroll")
require("mod.elona.data.item.spellbook")
require("mod.elona.data.item.tool")
