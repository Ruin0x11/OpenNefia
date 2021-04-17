local Gui = require("api.Gui")
local SkillCheck = require("mod.elona.api.SkillCheck")
local ElonaItem = require("mod.elona.api.ElonaItem")
local Input = require("api.Input")
local Rand = require("api.Rand")
local Const = require("api.Const")
local Calc = require("mod.elona.api.Calc")
local Enum = require("api.Enum")
local Charagen = require("mod.elona.api.Charagen")
local Mef = require("api.Mef")
local Effect = require("mod.elona.api.Effect")
local Magic = require("mod.elona_sys.api.Magic")
local Chara = require("api.Chara")
local Item = require("api.Item")
local Filters = require("mod.elona.api.Filters")
local light = require("mod.elona.data.item.light")
local Inventory = require("api.Inventory")
local World = require("api.World")

--
-- Chest
--

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

data:add {
   _type = "base.item",
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
}

data:add {
   _type = "base.item",
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
}

data:add {
   _type = "base.item",
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
}

data:add {
   _type = "base.item",
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
}

data:add {
   _type = "base.item",
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
}

data:add {
   _type = "base.item",
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
}

data:add {
   _type = "base.item",
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
}

data:add {
   _type = "base.item",
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
}

data:add {
   _type = "base.item",
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
}

data:add {
   _type = "base.item",
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
}

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

data:add {
   _type = "base.item",
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
}

--
-- Inventory
--

data:add {
   _type = "base.item",
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
}

data:add {
   _type = "base.item",
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
}

data:add {
   _type = "base.item",
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
}

data:add {
   _type = "base.item",
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
}

data:add {
   _type = "base.item",
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
}

data:add {
   _type = "base.item",
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
}

data:add {
   _type = "base.item",
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
}

--
-- Special
--

data:add {
   _type = "base.item",
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
}

data:add {
   _type = "base.item",
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
}
