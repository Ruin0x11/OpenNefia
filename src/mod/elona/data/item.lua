local Event = require("api.Event")
local Gui = require("api.Gui")
local Item = require("api.Item")
local Rand = require("api.Rand")
local Resolver = require("api.Resolver")
local Magic = require("mod.elona.api.Magic")
local Effect = require("mod.elona.api.Effect")

local function calc_initial_gold(item, owner)
   local amount
   if owner then
      amount = owner:calc("calc_initial_gold")
   else
      local dungeon_level = 1
      local base = dungeon_level * 25
      local is_shelter = false
      if is_shelter then
         base = 1
      end

      amount = Rand.rnd(base + 10) + 1
   end

   if item then
      local quality = item:calc("quality")

      -- TODO make number instead of enum
      if quality == 3 then -- great
         amount = amount * 2
      end

      if quality >= 4 then -- miracle
         amount = amount * 4
      end
   end

   return amount
end

local hook_calc_initial_gold =
   Event.define_hook("calc_initial_gold",
                     "Initial gold amount.",
                     1,
                     nil,
                     function(_, params, result)
                        return calc_initial_gold(params.item, params.owner)
   end)

local light = {
   lantern = {
      chip = "light_lantern",
      bright = 80,
      offset_y = 0,
      power = 6,
      flicker = 40,
      always_on = false
   },
   lamp = {
      chip = "light_lantern",
      bright = 100,
      offset_y = 30,
      power = 8,
      flicker = 20,
      always_on = false
   },
   torch = {
      chip = "light_torch",
      bright = 50,
      offset_y = 8,
      power = 8,
      flicker = 50,
      always_on = true
   },
   torch_lamp = {
      chip = "light_torch",
      bright = 70,
      offset_y = 28,
      power = 8,
      flicker = 70,
      always_on = true
   },
   town_light = {
      chip = "light_town_light",
      bright = 140,
      offset_y = 48,
      power = 10,
      flicker = 20,
      always_on = false
   },
   port_light = {
      chip = "light_port_light",
      bright = 140,
      offset_y = 62,
      power = 10,
      flicker = 20,
      always_on = false
   },
   port_light_snow = {
      chip = "light_town_light",
      bright = 100,
      offset_y = 72,
      power = 10,
      flicker = 20,
      always_on = false
   },
   stove = {
      chip = "light_stove",
      bright = 170,
      offset_y = 4,
      power = 2,
      flicker = 80,
      always_on = true
   },
   crystal = {
      chip = "light_crystal",
      bright = 30,
      offset_y = 8,
      power = 2,
      flicker = 80,
      always_on = true
   },
   crystal_middle = {
      chip = "light_crystal",
      bright = 30,
      offset_y = 24,
      power = 2,
      flicker = 80,
      always_on = true
   },
   crystal_high = {
      chip = "light_crystal",
      bright = 30,
      offset_y = 50,
      power = 5,
      flicker = 80,
      always_on = true
   },
   town = {
      chip = "light_town",
      bright = 120,
      offset_y = 0,
      power = 15,
      flicker = 15,
      always_on = false
   },
   item = {
      chip = "light_item",
      bright = 35,
      offset_y = 4,
      power = 1,
      flicker = 40,
      always_on = true
   },
   item_middle = {
      chip = "light_item",
      bright = 35,
      offset_y = 24,
      power = 1,
      flicker = 40,
      always_on = true
   },
   gate = {
      chip = "light_window",
      bright = 20,
      offset_y = 32,
      power = 2,
      flicker = 30,
      always_on = true
   },
   candle = {
      chip = "light_candle",
      bright = 50,
      offset_y = 48,
      power = 5,
      flicker = 70,
      always_on = true
   },
   candle_low = {
      chip = "light_candle",
      bright = 50,
      offset_y = 16,
      power = 5,
      flicker = 70,
      always_on = true
   },
   window = {
      chip = "light_window",
      bright = 100,
      offset_y = 24,
      power = 3,
      flicker = 10,
      always_on = false
   },
   window_red = {
      chip = "light_window_red",
      bright = 70,
      offset_y = 35,
      power = 3,
      flicker = 10,
      always_on = false
   },
}

-- TODO: Some fields should not be stored on the prototype as
-- defaults, but instead copied on generation.

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
         light = light.item
      },
      {
         _id = "long_sword",
         elona_id = 1,
         image = "elona.item_long_sword",
         value = 500,
         weight = 1500,
         dice_x = 2,
         dice_y = 8,
         hit_bonus = 5,
         damage_bonus = 4,
         material = "elona.metal",
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10002,
         coefficient = 100,

         skill = "elona.long_sword",
         pierce_rate = 5,
         categories = {
            "elona.equip_melee_long_sword",
            "elona.equip_melee"
         }
      },
      {
         _id = "dagger",
         elona_id = 2,
         image = "elona.item_dagger",
         value = 500,
         weight = 600,
         dice_x = 2,
         dice_y = 5,
         hit_bonus = 9,
         damage_bonus = 4,
         dv = 4,
         material = "elona.metal",
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10003,
         coefficient = 100,

         skill = "elona.short_sword",
         pierce_rate = 10,
         categories = {
            "elona.equip_melee_short_sword",
            "elona.equip_melee"
         }
      },
      {
         _id = "hand_axe",
         elona_id = 3,
         image = "elona.item_hand_axe",
         value = 500,
         weight = 900,
         dice_x = 2,
         dice_y = 9,
         hit_bonus = 4,
         damage_bonus = 5,
         material = "elona.metal",
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10009,
         coefficient = 100,

         skill = "elona.axe",

         categories = {
            "elona.equip_melee_hand_axe",
            "elona.equip_melee"
         }
      },
      {
         _id = "club",
         elona_id = 4,
         image = "elona.item_club",
         value = 500,
         weight = 1000,
         dice_x = 3,
         dice_y = 4,
         hit_bonus = 4,
         damage_bonus = 7,
         material = "elona.metal",
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10004,
         coefficient = 100,

         skill = "elona.blunt",

         categories = {
            "elona.equip_melee_club",
            "elona.equip_melee"
         }
      },
      {
         _id = "magic_hat",
         elona_id = 5,
         image = "elona.item_magic_hat",
         value = 1400,
         weight = 600,
         pv = 4,
         dv = 6,
         material = "elona.soft",
         level = 15,
         category = 12000,
         equip_slots = { "elona.head" },
         subcategory = 12002,
         coefficient = 100,
         categories = {
            "elona.equip_head_hat",
            "elona.equip_head"
         }
      },
      {
         _id = "fairy_hat",
         elona_id = 6,
         image = "elona.item_fairy_hat",
         value = 7200,
         weight = 400,
         pv = 5,
         dv = 7,
         material = "elona.soft",
         level = 30,
         category = 12000,
         equip_slots = { "elona.head" },
         subcategory = 12002,
         coefficient = 100,
         enchantments = {
            { id = 33, power = 100 }
         },
         categories = {
            "elona.equip_head_hat",
            "elona.equip_head"
         }
      },
      {
         _id = "breastplate",
         elona_id = 7,
         image = "elona.item_breastplate",
         value = 600,
         weight = 4500,
         pv = 10,
         dv = 6,
         material = "elona.metal",
         appearance = 1,
         category = 16000,
         equip_slots = { "elona.body" },
         subcategory = 16001,
         coefficient = 100,
         categories = {
            "elona.equip_body_mail",
            "elona.equip_body"
         }
      },
      {
         _id = "robe",
         elona_id = 8,
         image = "elona.item_robe",
         value = 450,
         weight = 800,
         pv = 3,
         dv = 11,
         material = "elona.soft",
         appearance = 3,
         category = 16000,
         equip_slots = { "elona.body" },
         subcategory = 16003,
         coefficient = 100,
         categories = {
            "elona.equip_body_robe",
            "elona.equip_body"
         }
      },
      {
         _id = "decorated_gloves",
         elona_id = 9,
         image = "elona.item_decorated_gloves",
         value = 1400,
         weight = 700,
         hit_bonus = 6,
         damage_bonus = 2,
         pv = 5,
         dv = 7,
         material = "elona.soft",
         appearance = 1,
         level = 30,
         category = 22000,
         equip_slots = { "elona.arm" },
         subcategory = 22003,
         coefficient = 100,
         categories = {
            "elona.equip_wrist_glove",
            "elona.equip_wrist"
         }
      },
      {
         _id = "thick_gauntlets",
         elona_id = 10,
         image = "elona.item_thick_gauntlets",
         value = 400,
         weight = 1100,
         hit_bonus = 2,
         damage_bonus = 1,
         pv = 4,
         dv = 2,
         material = "elona.metal",
         appearance = 2,
         category = 22000,
         equip_slots = { "elona.arm" },
         subcategory = 22001,
         coefficient = 100,
         categories = {
            "elona.equip_wrist_gauntlet",
            "elona.equip_wrist"
         }
      },
      {
         _id = "heavy_boots",
         elona_id = 11,
         image = "elona.item_heavy_boots",
         value = 480,
         weight = 950,
         pv = 3,
         dv = 1,
         material = "elona.metal",
         appearance = 3,
         category = 18000,
         equip_slots = { "elona.leg" },
         subcategory = 18001,
         coefficient = 100,
         categories = {
            "elona.equip_leg_heavy_boots",
            "elona.equip_leg"
         }
      },
      {
         _id = "composite_boots",
         elona_id = 12,
         image = "elona.item_composite_boots",
         value = 2200,
         weight = 720,
         pv = 5,
         dv = 1,
         material = "elona.metal",
         appearance = 4,
         level = 15,
         category = 18000,
         equip_slots = { "elona.leg" },
         subcategory = 18001,
         coefficient = 100,
         categories = {
            "elona.equip_leg_heavy_boots",
            "elona.equip_leg"
         }
      },
      {
         _id = "decorative_ring",
         elona_id = 13,
         image = "elona.item_decorative_ring",
         value = 450,
         weight = 50,
         material = "elona.soft",
         category = 32000,
         equip_slots = { "elona.ring" },
         subcategory = 32001,
         coefficient = 100,
         has_random_name = true,
         categories = {
            "elona.equip_ring_ring",
            "elona.equip_ring"
         }
      },
      {
         _id = "scroll_of_identify",
         elona_id = 14,
         image = "elona.item_scroll",
         value = 480,
         weight = 20,
         on_read = function() end,
         category = 53000,
         coefficient = 0,
         originalnameref2 = "scroll",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         efid = 411,
         efp = 100,
         elona_type = "scroll",
         categories = {
            "elona.scroll",
         }
      },
      {
         _id = "scroll_of_oracle",
         elona_id = 15,
         image = "elona.item_scroll",
         value = 12000,
         weight = 20,
         on_read = function() end,
         category = 53000,
         coefficient = 0,
         originalnameref2 = "scroll",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         efid = 413,
         efp = 100,
         elona_type = "scroll",
         categories = {
            "elona.scroll",
         }
      },
      {
         _id = "scroll_of_teleportation",
         elona_id = 16,
         image = "elona.item_scroll",
         value = 200,
         weight = 20,
         on_read = function() end,
         category = 53000,
         coefficient = 0,
         originalnameref2 = "scroll",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         efid = 408,
         efp = 100,
         elona_type = "scroll",
         categories = {
            "elona.scroll",
         }
      },
      {
         _id = "scroll_of_incognito",
         elona_id = 17,
         image = "elona.item_scroll",
         value = 3500,
         weight = 20,
         on_read = function() end,
         category = 53000,
         rarity = 70000,
         coefficient = 0,
         originalnameref2 = "scroll",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         efid = 458,
         efp = 300,
         elona_type = "scroll",
         categories = {
            "elona.scroll",
         }
      },
      {
         _id = "rod_of_identify",
         elona_id = 18,
         image = "elona.item_rod",
         value = 1080,
         weight = 800,
         chargelevel = 8,
         on_zap = function() end,
         level = 4,
         category = 56000,
         coefficient = 0,
         originalnameref2 = "rod",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 8 }),
         has_charge = true,

         efid = 411,
         efp = 100,
         categories = {
            "elona.rod"
         }
      },
      {
         _id = "rod_of_teleportation",
         elona_id = 19,
         image = "elona.item_rod",
         value = 840,
         weight = 800,
         chargelevel = 12,
         on_zap = function() end,
         category = 56000,
         coefficient = 0,
         originalnameref2 = "rod",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 12 }),
         has_charge = true,

         efid = 409,
         efp = 100,
         categories = {
            "elona.rod"
         }
      },
      {
         _id = "spellbook_of_teleportation",
         elona_id = 20,
         image = "elona.item_spellbook",
         value = 3200,
         weight = 380,
         chargelevel = 5,
         on_read = function() end,
         category = 54000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 5 }),
         has_charge = true,

         efid = 408,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "spellbook_of_identify",
         elona_id = 21,
         image = "elona.item_spellbook",
         value = 5600,
         weight = 380,
         chargelevel = 4,
         on_read = function() end,
         level = 6,
         category = 54000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 4 }),
         has_charge = true,

         efid = 411,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "spellbook_of_uncurse",
         elona_id = 22,
         image = "elona.item_spellbook",
         value = 6400,
         weight = 380,
         chargelevel = 4,
         on_read = function() end,
         level = 10,
         category = 54000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 4 }),
         has_charge = true,

         efid = 412,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "book_a",
         elona_id = 23,
         image = "elona.item_book",
         value = 100,
         weight = 80,
         on_read = function(self)
            Effect.identify_item(self, "partly")
            local BookMenu = require("api.gui.menu.BookMenu")
            BookMenu:new("text", true):query()
         end,
         fltselect = 1,
         category = 55000,
         coefficient = 100,

         param1 = 1,
         elona_type = "normal_book",
         categories = {
            "elona.book",
            "elona.no_generate"
         }
      },
      {
         _id = "book_b",
         elona_id = 24,
         image = "elona.item_book",
         value = 500,
         weight = 80,
         on_read = function(self)
            Effect.identify_item(self, "partly")
            local BookMenu = require("api.gui.menu.BookMenu")
            BookMenu:new("text", true):query()
         end,
         category = 55000,
         rarity = 2000000,
         coefficient = 100,

         params = { book_id = "string" },

         on_generate = function(self)
            if not self.params.book_id then
               self.params.book_id = ""
            end
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
         on_read = function() end,
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
         _id = "bottle_of_dirty_water",
         elona_id = 26,
         image = "elona.item_potion",
         value = 100,
         weight = 120,
         category = 52000,
         coefficient = 100,
         originalnameref2 = "bottle",

         on_drink = Magic.drink_potion(1130),
         categories = {
            "elona.drink",
         }
      },
      {
         _id = "potion_of_blindness",
         elona_id = 27,
         image = "elona.item_potion",
         value = 20,
         weight = 120,
         category = 52000,
         coefficient = 100,
         originalnameref2 = "potion",
         has_random_name = true,

         on_drink = Magic.drink_potion(1111, 200),

         tags = { "neg" },
         color = Resolver.make("elona.random_item_color"),
         categories = {
            "elona.drink",
            "elona.tag_neg"
         }
      },
      {
         _id = "potion_of_confusion",
         elona_id = 28,
         image = "elona.item_potion",
         value = 30,
         weight = 120,
         category = 52000,
         coefficient = 100,
         originalnameref2 = "potion",
         has_random_name = true,

         on_drink = Magic.drink_potion(1109, 150),

         tags = { "neg" },
         color = Resolver.make("elona.random_item_color"),
         categories = {
            "elona.drink",
            "elona.tag_neg"
         }
      },
      {
         _id = "potion_of_paralysis",
         elona_id = 29,
         image = "elona.item_potion",
         value = 40,
         weight = 120,
         category = 52000,
         coefficient = 100,
         originalnameref2 = "potion",
         has_random_name = true,

         on_drink = Magic.drink_potion(1110, 200),

         tags = { "neg" },
         color = Resolver.make("elona.random_item_color"),
         categories = {
            "elona.drink",
            "elona.tag_neg"
         }
      },
      {
         _id = "sleeping_drug",
         elona_id = 30,
         image = "elona.item_potion",
         value = 120,
         weight = 120,
         category = 52000,
         coefficient = 100,
         has_random_name = true,

         on_drink = Magic.drink_potion(1112, 200),

         tags = { "nogive" },
         color = Resolver.make("elona.random_item_color"),
         categories = {
            "elona.drink",
            "elona.tag_nogive"
         }
      },
      {
         _id = "bottle_of_crim_ale",
         elona_id = 31,
         image = "elona.item_potion",
         value = 280,
         weight = 50,
         category = 52000,
         subcategory = 52002,
         coefficient = 0,
         originalnameref2 = "bottle",

         on_drink = Magic.drink_potion(1102, 300),
         categories = {
            "elona.drink",
            "elona.drink_alcohol"
         }
      },
      {
         _id = "spellbook_of_ice_bolt",
         elona_id = 32,
         image = "elona.item_spellbook",
         value = 3800,
         weight = 380,
         chargelevel = 4,
         on_read = function() end,
         category = 54000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 4 }),
         has_charge = true,

         efid = 419,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "spellbook_of_fire_bolt",
         elona_id = 33,
         image = "elona.item_spellbook",
         value = 3800,
         weight = 380,
         chargelevel = 4,
         on_read = function() end,
         category = 54000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 4 }),
         has_charge = true,

         efid = 420,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "spellbook_of_lightning_bolt",
         elona_id = 34,
         image = "elona.item_spellbook",
         value = 3800,
         weight = 380,
         chargelevel = 4,
         on_read = function() end,
         category = 54000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 4 }),
         has_charge = true,

         efid = 421,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "earth_crystal",
         elona_id = 35,
         image = "elona.item_crystal",
         value = 450,
         weight = 1600,
         category = 77000,
         coefficient = 100,

         gods = { "elona.jure", "elona.opatos" },

         rftags = { "ore" },
         color = { 255, 255, 175 },
         categories = {
            "elona.ore"
         }
      },
      {
         _id = "mana_crystal",
         elona_id = 36,
         image = "elona.item_crystal",
         value = 470,
         weight = 900,
         category = 77000,
         coefficient = 100,

         gods = { "elona.jure", "elona.opatos" },

         rftags = { "ore" },
         color = { 255, 155, 155 },
         categories = {
            "elona.ore"
         }
      },
      {
         _id = "sun_crystal",
         elona_id = 37,
         image = "elona.item_crystal",
         value = 450,
         weight = 1200,
         category = 77000,
         coefficient = 100,

         gods = { "elona.jure", "elona.opatos" },

         rftags = { "ore" },
         color = { 255, 215, 175 },
         categories = {
            "elona.ore"
         },
         light = light.crystal
      },
      {
         _id = "gold_bar",
         elona_id = 38,
         image = "elona.item_worthless_fake_gold_bar",
         value = 2000,
         weight = 1100,
         category = 77000,
         rarity = 500000,
         coefficient = 100,

         gods = { "elona.jure", "elona.opatos" },

         rftags = { "ore" },

         categories = {
            "elona.ore"
         },

         light = light.crystal
      },
      {
         _id = "raw_ore_of_rubynus",
         elona_id = 39,
         image = "elona.item_raw_ore",
         value = 1400,
         weight = 240,
         category = 77000,
         subcategory = 77001,
         rarity = 500000,
         coefficient = 100,
         originalnameref2 = "raw ore",

         gods = { "elona.jure", "elona.opatos" },

         rftags = { "ore" },
         color = { 255, 155, 155 },
         categories = {
            "elona.ore_valuable",
            "elona.ore"
         },
         light = light.crystal
      },
      {
         _id = "raw_ore_of_mica",
         elona_id = 40,
         image = "elona.item_raw_ore",
         value = 720,
         weight = 70,
         category = 77000,
         subcategory = 77001,
         coefficient = 100,
         originalnameref2 = "raw ore",

         gods = { "elona.jure", "elona.opatos" },

         rftags = { "ore" },

         categories = {
            "elona.ore_valuable",
            "elona.ore"
         }
      },
      {
         _id = "raw_ore_of_emerald",
         elona_id = 41,
         image = "elona.item_raw_ore_of_diamond",
         value = 2450,
         weight = 380,
         category = 77000,
         subcategory = 77001,
         rarity = 400000,
         coefficient = 100,
         originalnameref2 = "raw ore",

         gods = { "elona.jure", "elona.opatos" },

         rftags = { "ore" },
         color = { 175, 255, 175 },
         categories = {
            "elona.ore_valuable",
            "elona.ore"
         },
         light = light.crystal
      },
      {
         _id = "raw_ore_of_diamond",
         elona_id = 42,
         image = "elona.item_raw_ore_of_diamond",
         value = 4200,
         weight = 320,
         category = 77000,
         subcategory = 77001,
         rarity = 250000,
         coefficient = 100,
         originalnameref2 = "raw ore",

         gods = { "elona.jure", "elona.opatos" },

         rftags = { "ore" },
         color = { 175, 175, 255 },
         categories = {
            "elona.ore_valuable",
            "elona.ore"
         },
         light = light.crystal
      },
      {
         _id = "wood_piece",
         elona_id = 43,
         image = "elona.item_wood_piece",
         value = 10,
         weight = 120,
         category = 64000,
         subcategory = 64000,
         coefficient = 100,
         tags = { "fish" },
         categories = {
            "elona.tag_fish",
            "elona.junk",
            "elona.junk_in_field"
         }
      },
      {
         _id = "junk_stone",
         elona_id = 44,
         image = "elona.item_junk_stone",
         value = 10,
         weight = 450,
         category = 77000,
         subcategory = 64000,
         coefficient = 100,

         gods = { "elona.jure", "elona.opatos" },

         rftags = { "ore" },

         categories = {
            "elona.junk_in_field",
            "elona.ore"
         }
      },
      {
         _id = "garbage",
         elona_id = 45,
         image = "elona.item_garbage",
         value = 8,
         weight = 80,
         category = 64000,
         subcategory = 64000,
         coefficient = 100,
         tags = { "fish" },
         categories = {
            "elona.tag_fish",
            "elona.junk",
            "elona.junk_in_field"
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
            }
         },

         on_generate = function(self, is_shop, owner)
            local Rand = require("api.Rand")

            self.amount = hook_calc_initial_gold({item=self,owner=owner})
            print("Amount,", self.amount)

            if owner then
               owner.gold = owner.gold + self.amount
               self:remove_ownership()
            end
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

         on_get = function(self, getter)
            getter.platinum = getter.platinum + self.amount
            self:remove_ownership()
         end,

         categories = {
            "elona.platinum",
            "elona.tag_noshop"
         }
      },
      {
         _id = "diablo",
         elona_id = 56,
         image = "elona.item_long_sword",
         value = 40000,
         weight = 2200,
         dice_x = 4,
         dice_y = 8,
         hit_bonus = 2,
         damage_bonus = 8,
         pv = 2,
         dv = -3,
         material = "elona.steel",
         level = 40,
         fltselect = 3,
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10002,
         coefficient = 100,

         skill = "elona.long_sword",

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",

         color = { 155, 154, 153 },
         pierce_rate = 10,
         enchantments = {
            { id = 40, power = 300 },
            { id = 70058, power = 400 },
            { id = 10018, power = 300 },
            { id = 24, power = 100 }
         },
         medal_value = 65,
         categories = {
            "elona.equip_melee_long_sword",
            "elona.unique_item",
            "elona.equip_melee"
         },
         light = light.item
      },
      {
         _id = "zantetsu",
         elona_id = 57,
         image = "elona.item_zantetsu",
         value = 40000,
         weight = 1400,
         dice_x = 7,
         dice_y = 7,
         hit_bonus = 4,
         material = "elona.silver",
         level = 30,
         fltselect = 2,
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10002,
         coefficient = 100,

         skill = "elona.long_sword",

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",

         color = { 175, 175, 255 },
         pierce_rate = 25,
         enchantments = {
            { id = 39, power = 400 },
            { id = 25, power = 100 },
            { id = 10010, power = 300 },
            { id = 20058, power = 200 }
         },
         categories = {
            "elona.equip_melee_long_sword",
            "elona.unique_weapon",
            "elona.equip_melee"
         },
         light = light.item
      },
      {
         _id = "long_bow",
         elona_id = 58,
         image = "elona.item_long_bow",
         value = 500,
         weight = 1200,
         dice_x = 2,
         dice_y = 7,
         hit_bonus = 4,
         damage_bonus = 8,
         material = "elona.metal",
         category = 24000,
         equip_slots = { "elona.ranged" },
         subcategory = 24001,
         coefficient = 100,

         skill = "elona.bow",

         gods = { "elona.lulwy" },

         effective_range = { 50, 90, 100, 90, 80, 80, 70, 60, 50, 20 },

         pierce_rate = 20,

         categories = {
            "elona.equip_ranged_bow",
            "elona.equip_ranged"
         }
      },
      {
         _id = "knight_shield",
         elona_id = 59,
         image = "elona.item_knight_shield",
         value = 4800,
         weight = 2200,
         pv = 8,
         dv = -2,
         material = "elona.metal",
         level = 30,
         category = 14000,
         equip_slots = { "elona.hand" },
         subcategory = 14003,
         coefficient = 100,

         skill = "elona.shield",

         categories = {
            "elona.equip_shield_shield",
            "elona.equip_shield"
         }
      },
      {
         _id = "pistol",
         elona_id = 60,
         image = "elona.item_pistol",
         value = 500,
         weight = 800,
         dice_x = 1,
         dice_y = 22,
         hit_bonus = 7,
         damage_bonus = 1,
         material = "elona.metal",
         category = 24000,
         equip_slots = { "elona.ranged" },
         subcategory = 24020,
         coefficient = 100,

         skill = "elona.firearm",

         gods = { "elona.mani" },

         tags = { "sf" },

         effective_range = { 100, 90, 70, 50, 20, 20, 20, 20, 20, 20 },
         pierce_rate = 10,
         categories = {
            "elona.equip_ranged_gun",
            "elona.tag_sf",
            "elona.equip_ranged"
         }
      },
      {
         _id = "arrow",
         elona_id = 61,
         image = "elona.item_bolt",
         value = 150,
         weight = 1200,
         dice_x = 1,
         dice_y = 8,
         hit_bonus = 2,
         damage_bonus = 1,
         material = "elona.metal",
         category = 25000,
         equip_slots = { "elona.ammo" },
         subcategory = 25001,
         coefficient = 100,

         skill = "elona.bow",

         categories = {
            "elona.equip_ammo",
            "elona.equip_ammo_arrow"
         }
      },
      {
         _id = "bullet",
         elona_id = 62,
         image = "elona.item_bullet",
         value = 150,
         weight = 2400,
         dice_x = 2,
         dice_y = 2,
         hit_bonus = 4,
         damage_bonus = 1,
         material = "elona.metal",
         category = 25000,
         equip_slots = { "elona.ammo" },
         subcategory = 25020,
         coefficient = 100,

         skill = "elona.firearm",

         tags = { "sf" },

         categories = {
            "elona.equip_ammo",
            "elona.equip_ammo_bullet",
            "elona.tag_sf"
         }
      },
      {
         _id = "scythe_of_void",
         elona_id = 63,
         image = "elona.item_scythe",
         value = 50000,
         weight = 9000,
         dice_x = 1,
         dice_y = 44,
         damage_bonus = 4,
         material = "elona.iron",
         level = 35,
         fltselect = 3,
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10011,
         coefficient = 100,

         skill = "elona.scythe",

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",

         color = { 255, 155, 155 },
         pierce_rate = 15,
         enchantments = {
            { id = 32, power = 100 },
            { id = 38, power = 500 },
            { id = 34, power = 450 },
            { id = 20060, power = 250 },
            { id = 80025, power = 100 }
         },
         categories = {
            "elona.equip_melee_scythe",
            "elona.unique_item",
            "elona.equip_melee"
         },
         light = light.item
      },
      {
         _id = "mournblade",
         elona_id = 64,
         image = "elona.item_long_sword",
         value = 60000,
         weight = 4000,
         dice_x = 3,
         dice_y = 13,
         hit_bonus = 8,
         damage_bonus = 5,
         pv = 4,
         dv = -4,
         material = "elona.obsidian",
         level = 50,
         fltselect = 3,
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10002,
         coefficient = 100,

         skill = "elona.long_sword",

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",

         color = { 175, 175, 255 },
         pierce_rate = 15,
         enchantments = {
            { id = 36, power = 300 },
            { id = 70059, power = 300 },
            { id = 70056, power = 250 },
            { id = 30166, power = 300 },
            { id = 20059, power = 250 },
            { id = 20056, power = 200 }
         },
         categories = {
            "elona.equip_melee_long_sword",
            "elona.unique_item",
            "elona.equip_melee"
         },
         light = light.item
      },
      {
         _id = "light_cloak",
         elona_id = 65,
         image = "elona.item_light_cloak",
         value = 250,
         weight = 700,
         pv = 3,
         dv = 4,
         material = "elona.soft",
         appearance = 1,
         category = 20000,
         equip_slots = { "elona.back" },
         subcategory = 20001,
         coefficient = 100,
         categories = {
            "elona.equip_back",
            "elona.equip_back_cloak"
         }
      },
      {
         _id = "girdle",
         elona_id = 66,
         image = "elona.item_girdle",
         value = 300,
         weight = 900,
         pv = 3,
         dv = 3,
         material = "elona.soft",
         appearance = 1,
         category = 19000,
         equip_slots = { "elona.waist" },
         subcategory = 19001,
         coefficient = 100,
         categories = {
            "elona.equip_back_girdle",
            "elona.equip_cloak"
         }
      },
      {
         _id = "decorative_amulet",
         elona_id = 67,
         image = "elona.item_decorative_amulet",
         value = 200,
         weight = 50,
         material = "elona.soft",
         category = 34000,
         equip_slots = { "elona.neck" },
         subcategory = 34001,
         coefficient = 100,
         has_random_name = true,
         categories = {
            "elona.equip_neck_armor",
            "elona.equip_neck"
         }
      },
      {
         _id = "potion_of_cure_minor_wound",
         elona_id = 68,
         image = "elona.item_potion",
         value = 150,
         weight = 120,
         category = 52000,
         subcategory = 52001,
         coefficient = 100,
         originalnameref2 = "potion",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         on_drink = Magic.drink_potion(400, 100),
         categories = {
            "elona.drink",
            "elona.drink_potion"
         }
      },
      {
         _id = "potion_of_cure_major_wound",
         elona_id = 69,
         image = "elona.item_potion",
         value = 300,
         weight = 120,
         level = 4,
         category = 52000,
         subcategory = 52001,
         coefficient = 100,
         originalnameref2 = "potion",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         on_drink = Magic.drink_potion(400, 300),
         categories = {
            "elona.drink",
            "elona.drink_potion"
         }
      },
      {
         _id = "potion_of_cure_critical_wound",
         elona_id = 70,
         image = "elona.item_potion",
         value = 1280,
         weight = 120,
         level = 8,
         category = 52000,
         subcategory = 52001,
         coefficient = 50,
         originalnameref2 = "potion",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         on_drink = Magic.drink_potion(401, 100),
         categories = {
            "elona.drink",
            "elona.drink_potion"
         }
      },
      {
         _id = "potion_of_healing",
         elona_id = 71,
         image = "elona.item_potion",
         value = 3000,
         weight = 120,
         level = 15,
         category = 52000,
         subcategory = 52001,
         rarity = 700000,
         coefficient = 50,
         originalnameref2 = "potion",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         on_drink = Magic.drink_potion(401, 300),
         categories = {
            "elona.drink",
            "elona.drink_potion"
         }
      },
      {
         _id = "potion_of_healer",
         elona_id = 72,
         image = "elona.item_potion",
         value = 5000,
         weight = 120,
         level = 25,
         category = 52000,
         subcategory = 52001,
         rarity = 600000,
         coefficient = 0,
         originalnameref2 = "potion",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         on_drink = Magic.drink_potion(401, 400),
         categories = {
            "elona.drink",
            "elona.drink_potion"
         }
      },
      {
         _id = "ragnarok",
         elona_id = 73,
         image = "elona.item_long_sword",
         value = 20000,
         weight = 4200,
         dice_x = 2,
         dice_y = 18,
         hit_bonus = 4,
         damage_bonus = 3,
         pv = 1,
         dv = -1,
         material = "elona.obsidian",
         level = 30,
         fltselect = 3,
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10002,
         coefficient = 100,

         skill = "elona.long_sword",
         { id = 37, power = 100 },

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",

         color = { 155, 154, 153 },
         pierce_rate = 20,
         categories = {
            "elona.equip_melee_long_sword",
            "elona.unique_item",
            "elona.equip_melee"
         },
         light = light.item
      },
      {
         _id = "potion_of_healer_odina",
         elona_id = 74,
         image = "elona.item_potion",
         value = 7500,
         weight = 120,
         level = 35,
         category = 52000,
         subcategory = 52001,
         rarity = 500000,
         coefficient = 0,
         originalnameref2 = "potion",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         on_drink = Magic.drink_potion(402, 100),
         categories = {
            "elona.drink",
            "elona.drink_potion"
         }
      },
      {
         _id = "potion_of_healer_eris",
         elona_id = 75,
         image = "elona.item_potion",
         value = 10000,
         weight = 120,
         level = 45,
         category = 52000,
         subcategory = 52001,
         rarity = 250000,
         coefficient = 0,
         originalnameref2 = "potion",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         on_drink = Magic.drink_potion(402, 300),
         categories = {
            "elona.drink",
            "elona.drink_potion"
         }
      },
      {
         _id = "potion_of_healer_jure",
         elona_id = 76,
         image = "elona.item_potion",
         value = 15000,
         weight = 120,
         level = 45,
         category = 52000,
         subcategory = 52001,
         rarity = 150000,
         coefficient = 0,
         originalnameref2 = "potion",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         on_drink = Magic.drink_potion(403, 100),
         categories = {
            "elona.drink",
            "elona.drink_potion"
         }
      },
      {
         _id = "round_chair",
         elona_id = 77,
         image = "elona.item_round_chair",
         value = 80,
         weight = 900,
         category = 60000,
         coefficient = 100,

         elona_function = 44,

         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "bookshelf",
         elona_id = 78,
         image = "elona.item_bookshelf",
         value = 1800,
         weight = 10200,
         level = 12,
         category = 60000,
         rarity = 600000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "luxury_drawer",
         elona_id = 79,
         image = "elona.item_luxury_drawer",
         value = 6400,
         weight = 8900,
         level = 20,
         category = 60000,
         rarity = 100000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "boring_bed",
         elona_id = 80,
         image = "elona.item_bed",
         value = 1400,
         weight = 15000,
         on_use = function() end,
         level = 5,
         category = 60000,
         subcategory = 60004,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },

         param1 = 100,

         categories = {
            "elona.furniture_bed",
            "elona.furniture"
         }
      },
      {
         _id = "rag_doll",
         elona_id = 81,
         image = "elona.item_rag_doll",
         value = 240,
         weight = 350,
         category = 60000,
         coefficient = 100,

         elona_function = 44,

         tags = { "fest" },
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.tag_fest",
            "elona.furniture"
         }
      },
      {
         _id = "toy",
         elona_id = 82,
         image = "elona.item_noble_toy",
         value = 320,
         weight = 320,
         category = 60000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "modern_table",
         elona_id = 83,
         image = "elona.item_modern_table",
         value = 2400,
         weight = 6800,
         level = 7,
         category = 60000,
         rarity = 400000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         },
         light = light.item
      },
      {
         _id = "dining_table",
         elona_id = 84,
         image = "elona.item_dining_table",
         value = 3800,
         weight = 7000,
         level = 18,
         category = 60000,
         rarity = 200000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "armor",
         elona_id = 85,
         image = "elona.item_armor",
         value = 1600,
         weight = 8400,
         level = 15,
         category = 60000,
         rarity = 300000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "lot_of_goods",
         elona_id = 86,
         image = "elona.item_lot_of_goods",
         value = 450,
         weight = 800,
         level = 5,
         category = 60000,
         coefficient = 100,
         originalnameref2 = "lot",
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "lot_of_accessories",
         elona_id = 87,
         image = "elona.item_lot_of_accessories",
         value = 720,
         weight = 750,
         level = 5,
         category = 60000,
         coefficient = 100,
         originalnameref2 = "lot",
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "grand_piano",
         elona_id = 88,
         image = "elona.item_goulds_piano",
         value = 15000,
         weight = 45000,
         level = 20,
         category = 60000,
         subcategory = 60005,
         rarity = 100000,
         coefficient = 100,

         skill = "elona.performer",
         elona_function = 17,
         param1 = 200,
         categories = {
            "elona.furniture_instrument",
            "elona.furniture"
         },
         light = light.item_middle
      },
      {
         _id = "bar_table_alpha",
         elona_id = 89,
         image = "elona.item_bar_table_alpha",
         value = 1200,
         weight = 7900,
         level = 12,
         category = 60000,
         rarity = 500000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "bar_table_beta",
         elona_id = 90,
         image = "elona.item_bar_table_beta",
         value = 1200,
         weight = 7900,
         level = 12,
         category = 60000,
         rarity = 500000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "barrel",
         elona_id = 91,
         image = "elona.item_barrel",
         value = 180,
         weight = 3400,
         category = 60000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "modern_chair",
         elona_id = 92,
         image = "elona.item_modern_chair",
         value = 750,
         weight = 1100,
         level = 3,
         category = 60000,
         rarity = 600000,
         coefficient = 100,

         elona_function = 44,

         tags = { "sf" },
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.tag_sf",
            "elona.furniture"
         }
      },
      {
         _id = "pick",
         elona_id = 93,
         image = "elona.item_pick",
         value = 160,
         weight = 1200,
         category = 60000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "lantern",
         elona_id = 94,
         image = "elona.item_lantern",
         value = 120,
         weight = 400,
         category = 60000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         },
         light = light.lantern
      },
      {
         _id = "decorative_armor",
         elona_id = 95,
         image = "elona.item_decorative_armor",
         value = 4200,
         weight = 3800,
         level = 7,
         category = 60000,
         rarity = 100000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "anvil",
         elona_id = 96,
         image = "elona.item_anvil",
         value = 3500,
         weight = 9500,
         level = 9,
         category = 60000,
         rarity = 300000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "closed_pot",
         elona_id = 97,
         image = "elona.item_closed_pot",
         value = 140,
         weight = 420,
         category = 60000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "open_pot",
         elona_id = 98,
         image = "elona.item_open_pot",
         value = 120,
         weight = 540,
         category = 60000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "academic_table",
         elona_id = 99,
         image = "elona.item_academic_table",
         value = 1050,
         weight = 4200,
         category = 60000,
         rarity = 200000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "rack_of_potions",
         elona_id = 100,
         image = "elona.item_rack_of_potions",
         value = 3800,
         weight = 80,
         level = 13,
         category = 60000,
         rarity = 200000,
         coefficient = 100,
         originalnameref2 = "rack",
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "square_chair",
         elona_id = 101,
         image = "elona.item_square_chair",
         value = 360,
         weight = 1200,
         category = 60000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },

         elona_function = 44,

         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "cheap_chair",
         elona_id = 102,
         image = "elona.item_cheap_chair",
         value = 120,
         weight = 6800,
         category = 60000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },

         elona_function = 44,

         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "cupboard",
         elona_id = 103,
         image = "elona.item_cupboard",
         value = 2400,
         weight = 7300,
         level = 11,
         category = 60000,
         rarity = 200000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "barn",
         elona_id = 104,
         image = "elona.item_barn",
         value = 750,
         weight = 8200,
         category = 60000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "neat_shelf",
         elona_id = 105,
         image = "elona.item_neat_shelf",
         value = 1800,
         weight = 7600,
         level = 7,
         category = 60000,
         rarity = 300000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "closet",
         elona_id = 106,
         image = "elona.item_closet",
         value = 1500,
         weight = 6800,
         level = 7,
         category = 60000,
         rarity = 400000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "variety_of_tools",
         elona_id = 107,
         image = "elona.item_variety_of_tools",
         value = 1050,
         weight = 750,
         category = 60000,
         rarity = 200000,
         coefficient = 100,
         originalnameref2 = "variety",
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "variety_of_goods",
         elona_id = 108,
         image = "elona.item_variety_of_goods",
         value = 1300,
         weight = 820,
         level = 3,
         category = 60000,
         rarity = 200000,
         coefficient = 100,
         originalnameref2 = "variety",
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "well",
         elona_id = 109,
         image = "elona.item_well",
         value = 1800,
         weight = 350000,
         category = 60001,
         subcategory = 60001,
         coefficient = 100,

         param2 = 100,
         params = {
            count_1 = 0,
            count_2 = 0,
         },

         on_drink = Magic.drink_well,
         elona_type = "well",

         categories = {
            "elona.furniture_well"
         },

         light = light.item
      },
      {
         _id = "variety_of_clothes",
         elona_id = 110,
         image = "elona.item_variety_of_clothes",
         value = 1800,
         weight = 950,
         level = 5,
         category = 60000,
         rarity = 200000,
         coefficient = 100,
         originalnameref2 = "variety",
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "furnace",
         elona_id = 111,
         image = "elona.item_furnace",
         value = 4400,
         weight = 45800,
         level = 17,
         category = 60000,
         rarity = 100000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         },
         light = light.torch_lamp
      },
      {
         _id = "oven",
         elona_id = 112,
         image = "elona.item_oven",
         value = 8500,
         weight = 14000,
         level = 22,
         category = 60000,
         rarity = 150000,
         coefficient = 100,

         elona_function = 15,
         param1 = 150,

         tags = { "sf" },

         categories = {
            "elona.tag_sf",
            "elona.furniture"
         }
      },
      {
         _id = "sign",
         elona_id = 113,
         image = "elona.item_sign",
         value = 100,
         weight = 3200,
         category = 60000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "crossroad_sign",
         elona_id = 114,
         image = "elona.item_crossroad_sign",
         value = 120,
         weight = 3500,
         category = 60000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "board",
         elona_id = 115,
         image = "elona.item_board",
         value = 240,
         weight = 9500,
         category = 60000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "spellbook_of_minor_teleportation",
         elona_id = 116,
         image = "elona.item_spellbook",
         value = 2400,
         weight = 380,
         chargelevel = 4,
         on_read = function() end,
         category = 54000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 4 }),
         has_charge = true,

         efid = 410,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "empty_basket",
         elona_id = 117,
         image = "elona.item_empty_basket",
         value = 20,
         weight = 80,
         category = 64000,
         coefficient = 100,
         tags = { "fish" },
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.tag_fish",
            "elona.junk"
         }
      },
      {
         _id = "spellbook_of_summon_monsters",
         elona_id = 118,
         image = "elona.item_spellbook",
         value = 6000,
         weight = 380,
         chargelevel = 4,
         on_read = function() end,
         level = 5,
         category = 54000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 4 }),
         has_charge = true,

         efid = 424,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "rod_of_cure_minor_wound",
         elona_id = 119,
         image = "elona.item_rod",
         value = 650,
         weight = 800,
         chargelevel = 8,
         on_zap = function() end,
         level = 3,
         category = 56000,
         coefficient = 0,
         originalnameref2 = "rod",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 8 }),
         has_charge = true,

         efid = 400,
         efp = 100,
         categories = {
            "elona.rod"
         }
      },
      {
         _id = "rod_of_magic_missile",
         elona_id = 120,
         image = "elona.item_rod",
         value = 800,
         weight = 800,
         chargelevel = 10,
         on_zap = function() end,
         level = 2,
         category = 56000,
         coefficient = 0,
         originalnameref2 = "rod",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 10 }),
         has_charge = true,

         efid = 414,
         efp = 100,
         categories = {
            "elona.rod"
         }
      },
      {
         _id = "rod_of_summon_monsters",
         elona_id = 121,
         image = "elona.item_rod",
         value = 700,
         weight = 800,
         chargelevel = 8,
         on_zap = function() end,
         category = 56000,
         coefficient = 0,
         originalnameref2 = "rod",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 8 }),
         has_charge = true,

         efid = 424,
         efp = 100,
         categories = {
            "elona.rod"
         }
      },
      {
         _id = "rod_of_ice_bolt",
         elona_id = 122,
         image = "elona.item_rod",
         value = 1460,
         weight = 800,
         chargelevel = 8,
         on_zap = function() end,
         level = 8,
         category = 56000,
         coefficient = 0,
         originalnameref2 = "rod",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 8 }),
         has_charge = true,

         efid = 419,
         efp = 100,
         categories = {
            "elona.rod"
         }
      },
      {
         _id = "rod_of_fire_bolt",
         elona_id = 123,
         image = "elona.item_rod",
         value = 1600,
         weight = 800,
         chargelevel = 10,
         on_zap = function() end,
         level = 8,
         category = 56000,
         coefficient = 0,
         originalnameref2 = "rod",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 10 }),
         has_charge = true,

         efid = 420,
         efp = 100,
         categories = {
            "elona.rod"
         }
      },
      {
         _id = "show_case_of_breads",
         elona_id = 124,
         image = "elona.item_show_case_of_breads",
         value = 1400,
         weight = 7800,
         category = 60000,
         rarity = 200000,
         coefficient = 100,
         originalnameref2 = "show case",
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "rod_of_heal",
         elona_id = 125,
         image = "elona.item_rod",
         value = 4800,
         weight = 800,
         chargelevel = 4,
         on_zap = function() end,
         level = 15,
         category = 56000,
         rarity = 250000,
         coefficient = 0,
         originalnameref2 = "rod",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 4 }),
         has_charge = true,

         efid = 402,
         efp = 100,
         categories = {
            "elona.rod"
         }
      },
      {
         _id = "beaker",
         elona_id = 126,
         image = "elona.item_beaker",
         value = 80,
         weight = 210,
         category = 60000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "alchemy_kit",
         elona_id = 127,
         image = "elona.item_alchemy_kit",
         value = 1960,
         weight = 900,
         on_use = function() end,
         category = 59000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },

         elona_function = 2,

         categories = {
            "elona.misc_item"
         }
      },
      {
         _id = "pentagram",
         elona_id = 128,
         image = "elona.item_pentagram",
         value = 3500,
         weight = 1840,
         category = 60000,
         rarity = 200000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         },
         light = light.item
      },
      {
         _id = "small_foliage_plant",
         elona_id = 129,
         image = "elona.item_small_foliage_plant",
         value = 850,
         weight = 420,
         level = 7,
         category = 60000,
         rarity = 300000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "rose",
         elona_id = 130,
         image = "elona.item_rose",
         value = 1050,
         weight = 400,
         level = 9,
         category = 60000,
         rarity = 300000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "large_foliage_plant",
         elona_id = 131,
         image = "elona.item_large_foliage_plant",
         value = 1800,
         weight = 380,
         level = 11,
         category = 60000,
         rarity = 300000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "sage",
         elona_id = 132,
         image = "elona.item_sage",
         value = 650,
         weight = 320,
         category = 60000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "gazania",
         elona_id = 133,
         image = "elona.item_gazania",
         value = 750,
         weight = 350,
         category = 60000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "nerine",
         elona_id = 134,
         image = "elona.item_nerine",
         value = 880,
         weight = 400,
         category = 60000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "anemos",
         elona_id = 135,
         image = "elona.item_anemos",
         value = 920,
         weight = 300,
         category = 60000,
         rarity = 500000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "foxtail_grass",
         elona_id = 136,
         image = "elona.item_foxtail_grass",
         value = 1500,
         weight = 240,
         category = 60000,
         rarity = 250000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "carnation",
         elona_id = 137,
         image = "elona.item_carnation",
         value = 780,
         weight = 250,
         category = 60000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "statue_ornamented_with_plants",
         elona_id = 138,
         image = "elona.item_statue_ornamented_with_plants",
         value = 3400,
         weight = 32000,
         level = 18,
         category = 60000,
         rarity = 200000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "statue_ornamented_with_flowers",
         elona_id = 139,
         image = "elona.item_statue_ornamented_with_flowers",
         value = 3900,
         weight = 32000,
         level = 20,
         category = 60000,
         rarity = 200000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "canvas",
         elona_id = 140,
         image = "elona.item_canvas",
         value = 830,
         weight = 1100,
         category = 59000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.misc_item"
         }
      },
      {
         _id = "map",
         elona_id = 141,
         image = "elona.item_map",
         value = 450,
         weight = 240,
         category = 60000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "food_maker",
         elona_id = 142,
         image = "elona.item_food_maker",
         value = 7800,
         weight = 17400,
         level = 14,
         category = 60000,
         rarity = 150000,
         coefficient = 100,

         elona_function = 15,
         param1 = 200,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "bundle_of_bows",
         elona_id = 143,
         image = "elona.item_bundle_of_bows",
         value = 240,
         weight = 1500,
         category = 60000,
         coefficient = 100,
         originalnameref2 = "bundle",
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "bundle_of_weapons",
         elona_id = 144,
         image = "elona.item_bundle_of_weapons",
         value = 940,
         weight = 2400,
         category = 60000,
         coefficient = 100,
         originalnameref2 = "bundle",
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "decorated_cloth",
         elona_id = 145,
         image = "elona.item_decorated_cloth",
         value = 1400,
         weight = 860,
         category = 60000,
         rarity = 250000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "decorated_armor",
         elona_id = 146,
         image = "elona.item_decorated_armor",
         value = 1900,
         weight = 4400,
         category = 60000,
         rarity = 250000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "statue_of_armor",
         elona_id = 147,
         image = "elona.item_statue_of_armor",
         value = 3600,
         weight = 7500,
         category = 60000,
         rarity = 100000,
         coefficient = 100,
         originalnameref2 = "statue",
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "disorderly_book",
         elona_id = 148,
         image = "elona.item_disorderly_book",
         value = 240,
         weight = 830,
         category = 60000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "lot_of_books",
         elona_id = 149,
         image = "elona.item_lot_of_books",
         value = 320,
         weight = 940,
         category = 60000,
         coefficient = 100,
         originalnameref2 = "lot",
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "craft_rack",
         elona_id = 150,
         image = "elona.item_craft_rack",
         value = 4500,
         weight = 8700,
         level = 17,
         category = 60000,
         rarity = 200000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "craft_book_shelf",
         elona_id = 151,
         image = "elona.item_craft_book_shelf",
         value = 4400,
         weight = 8600,
         level = 17,
         category = 60000,
         rarity = 200000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "lot_of_alcohols",
         elona_id = 152,
         image = "elona.item_lot_of_alcohols",
         value = 350,
         weight = 320,
         category = 60000,
         coefficient = 100,
         originalnameref2 = "lot",
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "kitchen",
         elona_id = 153,
         image = "elona.item_kitchen",
         value = 1200,
         weight = 14000,
         level = 4,
         category = 60000,
         rarity = 250000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },

         elona_function = 15,
         param1 = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "washstand",
         elona_id = 154,
         image = "elona.item_washstand",
         value = 1100,
         weight = 15000,
         level = 4,
         category = 60000,
         rarity = 250000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },

         elona_function = 15,
         param1 = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "kitchen_oven",
         elona_id = 155,
         image = "elona.item_kitchen_oven",
         value = 1500,
         weight = 14000,
         level = 4,
         category = 60000,
         rarity = 250000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },

         elona_function = 15,
         param1 = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "narrow_dining_table",
         elona_id = 156,
         image = "elona.item_narrow_dining_table",
         value = 1200,
         weight = 9700,
         category = 60000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "elegant_table",
         elona_id = 157,
         image = "elona.item_elegant_table",
         value = 3500,
         weight = 8600,
         level = 14,
         category = 60000,
         rarity = 250000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "gorgeous_candlestick",
         elona_id = 158,
         image = "elona.item_gorgeous_candlestick",
         value = 800,
         weight = 860,
         category = 60000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         },
         light = light.lamp
      },
      {
         _id = "simple_shelf",
         elona_id = 159,
         image = "elona.item_simple_shelf",
         value = 1200,
         weight = 11000,
         category = 60000,
         rarity = 500000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "sewing_kit",
         elona_id = 160,
         image = "elona.item_sewing_kit",
         value = 780,
         weight = 500,
         on_use = function() end,
         category = 59000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },

         elona_function = 4,

         categories = {
            "elona.misc_item"
         }
      },
      {
         _id = "carpenters_tool",
         elona_id = 161,
         image = "elona.item_carpenters_tool",
         value = 1250,
         weight = 500,
         on_use = function() end,
         category = 59000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },

         elona_function = 1,

         categories = {
            "elona.misc_item"
         }
      },
      {
         _id = "messy_cloth",
         elona_id = 162,
         image = "elona.item_messy_cloth",
         value = 430,
         weight = 1200,
         category = 60000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "silk_cloth",
         elona_id = 163,
         image = "elona.item_silk_cloth",
         value = 1400,
         weight = 340,
         level = 4,
         category = 60000,
         rarity = 500000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "collapsed_grave",
         elona_id = 164,
         image = "elona.item_collapsed_grave",
         value = 1800,
         weight = 400000,
         category = 60000,
         subcategory = 64000,
         rarity = 100000,
         coefficient = 100,
         categories = {
            "elona.junk_in_field",
            "elona.furniture"
         }
      },
      {
         _id = "crumbled_grave",
         elona_id = 165,
         image = "elona.item_crumbled_grave",
         value = 1700,
         weight = 400000,
         category = 60000,
         subcategory = 64000,
         rarity = 100000,
         coefficient = 100,
         categories = {
            "elona.junk_in_field",
            "elona.furniture"
         }
      },
      {
         _id = "grave_of_ornamented_with_flowers",
         elona_id = 166,
         image = "elona.item_grave_of_ornamented_with_flowers",
         value = 3250,
         weight = 650000,
         level = 5,
         category = 60000,
         subcategory = 64000,
         rarity = 50000,
         coefficient = 100,
         originalnameref2 = "grave",
         categories = {
            "elona.junk_in_field",
            "elona.furniture"
         }
      },
      {
         _id = "brand_new_grave",
         elona_id = 167,
         image = "elona.item_brand_new_grave",
         value = 2500,
         weight = 650000,
         level = 5,
         category = 60000,
         rarity = 100000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "solemn_tomb",
         elona_id = 168,
         image = "elona.item_solemn_tomb",
         value = 4400,
         weight = 650000,
         level = 10,
         category = 60000,
         rarity = 100000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "ancient_tomb",
         elona_id = 169,
         image = "elona.item_grave",
         value = 6500,
         weight = 650000,
         level = 20,
         category = 60000,
         rarity = 100000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "old_grave",
         elona_id = 170,
         image = "elona.item_old_grave",
         value = 2400,
         weight = 650000,
         level = 10,
         category = 60000,
         rarity = 100000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "altar",
         elona_id = 171,
         image = "elona.item_ceremony_altar",
         value = 1500,
         weight = 500000,
         fltselect = 1,
         category = 60002,
         subcategory = 60002,
         coefficient = 100,

         params = { god_id = "" },

         categories = {
            "elona.furniture_altar",
            "elona.no_generate"
         },

         light = light.candle_low
      },
      {
         _id = "ceremony_altar",
         elona_id = 172,
         image = "elona.item_ceremony_altar",
         value = 1600,
         weight = 500000,
         fltselect = 1,
         category = 60002,
         subcategory = 60002,
         coefficient = 100,
         categories = {
            "elona.furniture_altar",
            "elona.no_generate"
         },
         light = light.candle_low
      },
      {
         _id = "fountain",
         elona_id = 173,
         image = "elona.item_fountain",
         value = 2400,
         weight = 600000,
         fltselect = 1,
         category = 60001,
         subcategory = 60001,
         coefficient = 100,

         param2 = 100,
         params = {
            count_1 = 0,
            count_2 = 0,
         },

         on_drink = Magic.drink_well,
         elona_type = "well",

         categories = {
            "elona.furniture_well",
            "elona.no_generate"
         }
      },
      {
         _id = "bunk_bed",
         elona_id = 174,
         image = "elona.item_bunk_bed",
         value = 2200,
         weight = 12400,
         on_use = function() end,
         level = 5,
         category = 60000,
         subcategory = 60004,
         rarity = 100000,
         coefficient = 100,

         param1 = 110,

         categories = {
            "elona.furniture_bed",
            "elona.furniture"
         }
      },
      {
         _id = "rod_of_lightning_bolt",
         elona_id = 175,
         image = "elona.item_rod",
         value = 1900,
         weight = 800,
         chargelevel = 10,
         on_zap = function() end,
         level = 8,
         category = 56000,
         coefficient = 0,
         originalnameref2 = "rod",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 10 }),
         has_charge = true,

         efid = 421,
         efp = 100,
         categories = {
            "elona.rod"
         }
      },
      {
         _id = "rod_of_slow",
         elona_id = 176,
         image = "elona.item_rod",
         value = 1500,
         weight = 800,
         chargelevel = 8,
         on_zap = function() end,
         level = 3,
         category = 56000,
         coefficient = 0,
         originalnameref2 = "rod",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 8 }),
         has_charge = true,

         efid = 447,
         efp = 100,
         categories = {
            "elona.rod"
         }
      },
      {
         _id = "quwapana",
         elona_id = 177,
         image = "elona.item_quwapana",
         value = 80,
         weight = 160,
         material = "elona.fresh",
         expiration_date = 72,
         category = 57000,
         subcategory = 57003,
         coefficient = 100,

         param1 = 3000,
         param3 = 72,
         categories = {
            "elona.food_vegetable",
            "elona.food"
         }
      },
      {
         _id = "aloe",
         elona_id = 178,
         image = "elona.item_stomafillia",
         value = 70,
         weight = 170,
         material = "elona.fresh",
         expiration_date = 72,
         category = 57000,
         subcategory = 57003,
         coefficient = 100,

         param1 = 3000,
         param3 = 72,
         categories = {
            "elona.food_vegetable",
            "elona.food"
         }
      },
      {
         _id = "edible_wild_plant",
         elona_id = 179,
         image = "elona.item_edible_wild_plant",
         value = 60,
         weight = 100,
         material = "elona.fresh",
         expiration_date = 48,
         category = 57000,
         subcategory = 64000,
         coefficient = 100,

         param1 = 2000,
         param3 = 48,

         gods = { "elona.kumiromi" },

         categories = {
            "elona.junk_in_field",
            "elona.food"
         }
      },
      {
         _id = "apple",
         elona_id = 180,
         image = "elona.item_happy_apple",
         value = 180,
         weight = 720,
         material = "elona.fresh",
         expiration_date = 16,
         category = 57000,
         subcategory = 57004,
         coefficient = 100,

         param1 = 3000,
         param3 = 16,
         categories = {
            "elona.food_fruit",
            "elona.food"
         }
      },
      {
         _id = "grape",
         elona_id = 181,
         image = "elona.item_grape",
         value = 220,
         weight = 510,
         material = "elona.fresh",
         expiration_date = 16,
         category = 57000,
         subcategory = 57004,
         coefficient = 100,

         param1 = 3000,
         param3 = 16,
         categories = {
            "elona.food_fruit",
            "elona.food"
         }
      },
      {
         _id = "kiwi",
         elona_id = 182,
         image = "elona.item_kiwi",
         value = 190,
         weight = 440,
         material = "elona.fresh",
         expiration_date = 12,
         category = 57000,
         subcategory = 57004,
         coefficient = 100,

         param1 = 3000,
         param3 = 12,
         categories = {
            "elona.food_fruit",
            "elona.food"
         }
      },
      {
         _id = "cherry",
         elona_id = 183,
         image = "elona.item_cherry",
         value = 170,
         weight = 220,
         material = "elona.fresh",
         expiration_date = 16,
         category = 57000,
         subcategory = 57004,
         coefficient = 100,

         param1 = 3000,
         param3 = 16,
         categories = {
            "elona.food_fruit",
            "elona.food"
         }
      },
      {
         _id = "guava",
         elona_id = 184,
         image = "elona.item_guava",
         value = 80,
         weight = 620,
         material = "elona.fresh",
         expiration_date = 8,
         category = 57000,
         subcategory = 57003,
         coefficient = 100,

         param1 = 3000,
         param3 = 8,
         categories = {
            "elona.food_vegetable",
            "elona.food"
         }
      },
      {
         _id = "carrot",
         elona_id = 185,
         image = "elona.item_carrot",
         value = 40,
         weight = 420,
         material = "elona.fresh",
         expiration_date = 72,
         category = 57000,
         subcategory = 57003,
         coefficient = 100,

         param1 = 2000,
         param3 = 72,

         gods = { "elona.kumiromi" },

         categories = {
            "elona.food_vegetable",
            "elona.food"
         }
      },
      {
         _id = "radish",
         elona_id = 186,
         image = "elona.item_radish",
         value = 50,
         weight = 950,
         material = "elona.fresh",
         expiration_date = 72,
         category = 57000,
         subcategory = 57003,
         coefficient = 100,

         param1 = 2000,
         param3 = 72,

         gods = { "elona.kumiromi" },

         categories = {
            "elona.food_vegetable",
            "elona.food"
         }
      },
      {
         _id = "sweet_potato",
         elona_id = 187,
         image = "elona.item_sweet_potato",
         value = 40,
         weight = 790,
         category = 57000,
         subcategory = 57003,
         coefficient = 100,

         param1 = 2000,

         gods = { "elona.kumiromi" },

         tags = { "fest" },

         categories = {
            "elona.food_vegetable",
            "elona.tag_fest",
            "elona.food"
         }
      },
      {
         _id = "lettuce",
         elona_id = 188,
         image = "elona.item_lettuce",
         value = 50,
         weight = 650,
         material = "elona.fresh",
         expiration_date = 72,
         category = 57000,
         subcategory = 57003,
         coefficient = 100,

         param1 = 2000,
         param3 = 72,

         gods = { "elona.kumiromi" },

         categories = {
            "elona.food_vegetable",
            "elona.food"
         }
      },
      {
         _id = "stack_of_dishes",
         elona_id = 189,
         image = "elona.item_stack_of_dishes",
         value = 120,
         weight = 450,
         category = 60000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "imo",
         elona_id = 190,
         image = "elona.item_imo",
         value = 70,
         weight = 650,
         category = 57000,
         subcategory = 57003,
         coefficient = 100,

         param1 = 2000,

         gods = { "elona.kumiromi" },

         categories = {
            "elona.food_vegetable",
            "elona.food"
         }
      },
      {
         _id = "api_nut",
         elona_id = 191,
         image = "elona.item_api_nut",
         value = 80,
         weight = 40,
         category = 57000,
         subcategory = 64000,
         coefficient = 100,

         param1 = 4000,

         categories = {
            "elona.junk_in_field",
            "elona.food"
         }
      },
      {
         _id = "strawberry",
         elona_id = 192,
         image = "elona.item_strawberry",
         value = 260,
         weight = 720,
         material = "elona.fresh",
         expiration_date = 16,
         category = 57000,
         subcategory = 57004,
         coefficient = 100,

         param1 = 3000,
         param3 = 16,
         categories = {
            "elona.food_fruit",
            "elona.food"
         }
      },
      {
         _id = "healthy_leaf",
         elona_id = 193,
         image = "elona.item_healthy_leaf",
         value = 240,
         weight = 90,
         category = 57000,
         subcategory = 64000,
         coefficient = 100,

         param1 = 2000,

         gods = { "elona.kumiromi" },

         categories = {
            "elona.junk_in_field",
            "elona.food"
         }
      },
      {
         _id = "rainbow_fruit",
         elona_id = 194,
         image = "elona.item_rainbow_fruit",
         value = 220,
         weight = 1070,
         material = "elona.fresh",
         expiration_date = 8,
         category = 57000,
         subcategory = 57004,
         coefficient = 100,

         param1 = 3000,
         param3 = 8,
         categories = {
            "elona.food_fruit",
            "elona.food"
         }
      },
      {
         _id = "qucche",
         elona_id = 195,
         image = "elona.item_qucche",
         value = 100,
         weight = 560,
         material = "elona.fresh",
         expiration_date = 12,
         category = 57000,
         subcategory = 57004,
         coefficient = 100,

         param1 = 3000,
         param3 = 12,
         categories = {
            "elona.food_fruit",
            "elona.food"
         }
      },
      {
         _id = "tangerine",
         elona_id = 196,
         image = "elona.item_tangerine",
         value = 130,
         weight = 880,
         material = "elona.fresh",
         expiration_date = 8,
         category = 57000,
         subcategory = 57004,
         coefficient = 100,

         param1 = 3000,
         param3 = 8,
         categories = {
            "elona.food_fruit",
            "elona.food"
         }
      },
      {
         _id = "lemon",
         elona_id = 197,
         image = "elona.item_magic_fruit",
         value = 240,
         weight = 440,
         material = "elona.fresh",
         expiration_date = 12,
         category = 57000,
         subcategory = 57004,
         coefficient = 100,

         param1 = 3000,
         param3 = 12,
         categories = {
            "elona.food_fruit",
            "elona.food"
         }
      },
      {
         _id = "green_pea",
         elona_id = 198,
         image = "elona.item_green_pea",
         value = 260,
         weight = 360,
         material = "elona.fresh",
         expiration_date = 72,
         category = 57000,
         subcategory = 57003,
         coefficient = 100,

         param1 = 2000,
         param3 = 72,

         gods = { "elona.kumiromi" },

         categories = {
            "elona.food_vegetable",
            "elona.food"
         }
      },
      {
         _id = "cbocchi",
         elona_id = 199,
         image = "elona.item_cbocchi",
         value = 80,
         weight = 970,
         material = "elona.fresh",
         expiration_date = 72,
         category = 57000,
         subcategory = 57003,
         coefficient = 100,

         param1 = 2000,
         param3 = 72,

         gods = { "elona.kumiromi" },

         categories = {
            "elona.food_vegetable",
            "elona.food"
         }
      },
      {
         _id = "melon",
         elona_id = 200,
         image = "elona.item_melon",
         value = 30,
         weight = 840,
         material = "elona.fresh",
         expiration_date = 72,
         category = 57000,
         subcategory = 57003,
         coefficient = 100,

         param1 = 2000,
         param3 = 72,

         gods = { "elona.kumiromi" },

         categories = {
            "elona.food_vegetable",
            "elona.food"
         }
      },
      {
         _id = "leccho",
         elona_id = 201,
         image = "elona.item_leccho",
         value = 70,
         weight = 550,
         material = "elona.fresh",
         expiration_date = 2,
         category = 57000,
         subcategory = 57003,
         coefficient = 100,

         param1 = 2000,
         param3 = 2,

         gods = { "elona.kumiromi" },

         categories = {
            "elona.food_vegetable",
            "elona.food"
         }
      },
      {
         _id = "rod_of_magic_mapping",
         elona_id = 202,
         image = "elona.item_rod",
         value = 3250,
         weight = 800,
         chargelevel = 9,
         on_zap = function() end,
         level = 4,
         category = 56000,
         coefficient = 0,
         originalnameref2 = "rod",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 9 }),
         has_charge = true,

         efid = 429,
         efp = 100,
         categories = {
            "elona.rod"
         }
      },
      {
         _id = "rod_of_cure",
         elona_id = 203,
         image = "elona.item_rod",
         value = 2600,
         weight = 800,
         chargelevel = 8,
         on_zap = function() end,
         level = 10,
         category = 56000,
         rarity = 800000,
         coefficient = 0,
         originalnameref2 = "rod",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 8 }),
         has_charge = true,

         efid = 401,
         efp = 100,
         categories = {
            "elona.rod"
         }
      },
      {
         _id = "corpse",
         elona_id = 204,
         image = "elona.item_corpse",
         value = 80,
         weight = 2000,
         material = "elona.fresh",
         expiration_date = 4,
         category = 57000,
         coefficient = 100,

         param1 = 1000,
         param3 = 4,
         params = {
            chara_id = nil
         },

         gods = { "any" },

         events = {
            {
               id = "elona_sys.on_item_eat",
               name = "corpse effects",

               callback = function(self, params, result)
                  local corpse_chara_id = self.params.chara_id
                  if not corpse_chara_id then
                     return
                  end

                  local dat = data["base.chara"]:ensure(corpse_chara_id)
                  local chara = params.chara

                  if table.set(dat.tags or {})["man"] then
                     if chara:has_trait("elona.can_eat_human_flesh") then
                        Gui.mes("food.effect.human.like")
                     else
                        Gui.mes("food.effect.human.dislike")
                        Effect.modify_insanity(chara, 15)
                        chara:apply_effect("elona.insanity", 150)
                        if not chara:has_trait("elona.can_eat_human_flesh") and Rand.one_in(5) then
                           chara:gain_trait("elona.can_eat_human_flesh")
                        end
                     end
                  elseif chara:has_trait("elona.can_eat_human_flesh") then
                     Gui.mes("food.effect.human.would_have_rather_eaten")
                     result.nutrition = result.nutrition * 2 / 3
                  end

                  if dat.on_eat_corpse then
                     dat.on_eat_corpse(self, params, result)
                  end

                  return result
               end
            },
            {
               id = "elona.on_eat_item_begin",
               name = "itadaki-mammoth",

               callback = function(self)
                  if self.params.chara_id == "elona.mammoth" then
                     Gui.mes("activity.eat.start.mammoth")
                  end
               end
            }
         },

         categories = {
            "elona.food"
         }
      },
      {
         _id = "bottle_of_whisky",
         elona_id = 205,
         image = "elona.item_bottle_of_whisky",
         value = 180,
         weight = 50,
         category = 52000,
         subcategory = 52002,
         coefficient = 100,
         originalnameref2 = "bottle",

         on_drink = Magic.drink_potion(1102, 500),
         categories = {
            "elona.drink",
            "elona.drink_alcohol"
         }
      },
      {
         _id = "ether_dagger",
         elona_id = 206,
         image = "elona.item_dagger",
         value = 60000,
         weight = 600,
         dice_x = 5,
         dice_y = 5,
         hit_bonus = 16,
         damage_bonus = 8,
         pv = 6,
         dv = 4,
         material = "elona.ether",
         level = 40,
         fltselect = 2,
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10003,
         coefficient = 100,

         skill = "elona.short_sword",

         _copy = {
            enchantments = {
               { id = 80000, power = 200 },
               { id = 70052, power = 300 },
               { id = 20052, power = 250 },
               { id = 30172, power = 350 },
            }
         },

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",

         color = { 175, 175, 255 },
         pierce_rate = 20,
         categories = {
            "elona.equip_melee_short_sword",
            "elona.unique_weapon",
            "elona.equip_melee"
         },
         light = light.item
      },
      {
         _id = "bow_of_vinderre",
         elona_id = 207,
         image = "elona.item_long_bow",
         value = 60000,
         weight = 1200,
         dice_x = 2,
         dice_y = 15,
         hit_bonus = 5,
         damage_bonus = 7,
         material = "elona.mithril",
         level = 35,
         fltselect = 2,
         category = 24000,
         equip_slots = { "elona.ranged" },
         subcategory = 24001,
         coefficient = 100,

         skill = "elona.bow",

         _copy = {
            enchantments = {
               { id = 80001, power = 100 },
               { id = 60012, power = 100 },
               { id = 60013, power = 100 },
               { id = 10012, power = 450 },
               { id = 20055, power = 300 },
               { id = 70055, power = 300 },
            }
         },

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",

         color = { 155, 154, 153 },

         effective_range = { 50, 90, 100, 90, 80, 80, 70, 60, 50, 20 },
         pierce_rate = 20,
         categories = {
            "elona.equip_ranged_bow",
            "elona.unique_weapon",
            "elona.equip_ranged"
         },
         light = light.item
      },
      {
         _id = "worthless_fake_gold_bar",
         elona_id = 208,
         image = "elona.item_worthless_fake_gold_bar",
         value = 1,
         weight = 1,
         category = 77000,
         coefficient = 100,
         rftags = { "ore" },
         categories = {
            "elona.ore"
         }
      },
      {
         _id = "scroll_of_uncurse",
         elona_id = 209,
         image = "elona.item_scroll",
         value = 1050,
         weight = 20,
         on_read = function() end,
         category = 53000,
         coefficient = 0,
         originalnameref2 = "scroll",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         efid = 412,
         efp = 100,
         elona_type = "scroll",
         categories = {
            "elona.scroll",
         }
      },
      {
         _id = "stone",
         elona_id = 210,
         image = "elona.item_stone",
         value = 180,
         weight = 2000,
         dice_x = 1,
         dice_y = 12,
         material = "elona.iron",
         category = 24000,
         equip_slots = { "elona.ranged" },
         subcategory = 24030,
         coefficient = 100,

         skill = "elona.throwing",

         effective_range = { 60, 100, 70, 20, 20, 20, 20, 20, 20, 20 },
         pierce_rate = 5,
         categories = {
            "elona.equip_ranged_thrown",
            "elona.equip_ranged"
         }
      },
      {
         _id = "sickle",
         elona_id = 211,
         image = "elona.item_scythe",
         value = 500,
         weight = 1400,
         dice_x = 2,
         dice_y = 5,
         hit_bonus = 2,
         damage_bonus = 10,
         material = "elona.metal",
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10011,
         coefficient = 100,

         skill = "elona.scythe",

         _copy = {
            enchantments = {
               { id = 80025, power = 100 },
            }
         },
         pierce_rate = 5,
         categories = {
            "elona.equip_melee_scythe",
            "elona.equip_melee"
         }
      },
      {
         _id = "staff",
         elona_id = 212,
         image = "elona.item_staff",
         value = 500,
         weight = 900,
         dice_x = 1,
         dice_y = 8,
         hit_bonus = 4,
         damage_bonus = 3,
         dv = 4,
         material = "elona.metal",
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10006,
         coefficient = 100,

         skill = "elona.stave",

         gods = { "elona.itzpalt" },

         categories = {
            "elona.equip_melee_staff",
            "elona.equip_melee"
         }
      },
      {
         _id = "spear",
         elona_id = 213,
         image = "elona.item_spear",
         value = 500,
         weight = 2500,
         dice_x = 3,
         dice_y = 5,
         hit_bonus = 2,
         damage_bonus = 4,
         dv = 3,
         material = "elona.metal",
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10007,
         coefficient = 100,

         skill = "elona.polearm",
         pierce_rate = 25,
         categories = {
            "elona.equip_melee_lance",
            "elona.equip_melee"
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

         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },

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
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
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
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
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
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
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
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.junk"
         }
      },
      {
         _id = "tight_rope",
         elona_id = 219,
         image = "elona.item_rope",
         value = 180,
         weight = 340,
         category = 59000,
         subcategory = 64000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },

         elona_function = 46,

         categories = {
            "elona.junk_in_field",
            "elona.misc_item"
         }
      },
      {
         _id = "dead_fish",
         elona_id = 220,
         image = "elona.item_bomb_fish",
         value = 4,
         weight = 50,
         category = 64000,
         subcategory = 64000,
         coefficient = 100,
         tags = { "fish" },
         categories = {
            "elona.tag_fish",
            "elona.junk",
            "elona.junk_in_field"
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
         _id = "pot",
         elona_id = 223,
         image = "elona.item_pot",
         value = 150,
         weight = 15000,
         category = 59000,
         coefficient = 100,

         elona_function = 15,
         param1 = 60,
         categories = {
            "elona.misc_item"
         }
      },
      {
         _id = "katana",
         elona_id = 224,
         image = "elona.item_katana",
         value = 500,
         weight = 1200,
         dice_x = 4,
         dice_y = 4,
         damage_bonus = 6,
         material = "elona.metal",
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10002,
         coefficient = 100,

         skill = "elona.long_sword",
         pierce_rate = 20,
         categories = {
            "elona.equip_melee_long_sword",
            "elona.equip_melee"
         }
      },
      {
         _id = "scimitar",
         elona_id = 225,
         image = "elona.item_scimitar",
         value = 500,
         weight = 900,
         dice_x = 3,
         dice_y = 4,
         hit_bonus = 7,
         damage_bonus = 3,
         dv = 2,
         material = "elona.metal",
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10003,
         coefficient = 100,

         skill = "elona.short_sword",
         pierce_rate = 10,
         categories = {
            "elona.equip_melee_short_sword",
            "elona.equip_melee"
         }
      },
      {
         _id = "battle_axe",
         elona_id = 226,
         image = "elona.item_battle_axe",
         value = 500,
         weight = 3700,
         dice_x = 1,
         dice_y = 18,
         hit_bonus = -1,
         damage_bonus = 3,
         material = "elona.metal",
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10010,
         coefficient = 100,

         skill = "elona.axe",

         categories = {
            "elona.equip_melee_axe",
            "elona.equip_melee"
         }
      },
      {
         _id = "hammer",
         elona_id = 227,
         image = "elona.item_hammer",
         value = 500,
         weight = 4200,
         dice_x = 2,
         dice_y = 13,
         hit_bonus = -3,
         damage_bonus = 4,
         material = "elona.metal",
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10005,
         coefficient = 100,

         skill = "elona.blunt",

         categories = {
            "elona.equip_melee_hammer",
            "elona.equip_melee"
         }
      },
      {
         _id = "trident",
         elona_id = 228,
         image = "elona.item_trident",
         value = 500,
         weight = 1800,
         dice_x = 4,
         dice_y = 4,
         hit_bonus = 1,
         damage_bonus = 3,
         dv = 3,
         material = "elona.metal",
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10007,
         coefficient = 100,

         skill = "elona.polearm",
         pierce_rate = 25,
         categories = {
            "elona.equip_melee_lance",
            "elona.equip_melee"
         }
      },
      {
         _id = "long_staff",
         elona_id = 229,
         image = "elona.item_long_staff",
         value = 500,
         weight = 800,
         dice_x = 2,
         dice_y = 5,
         hit_bonus = 3,
         damage_bonus = 4,
         dv = 4,
         material = "elona.metal",
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10006,
         coefficient = 100,

         skill = "elona.stave",

         gods = { "elona.itzpalt" },

         categories = {
            "elona.equip_melee_staff",
            "elona.equip_melee"
         }
      },
      {
         _id = "short_bow",
         elona_id = 230,
         image = "elona.item_long_bow",
         value = 500,
         weight = 800,
         dice_x = 3,
         dice_y = 5,
         hit_bonus = 8,
         damage_bonus = 3,
         material = "elona.metal",
         category = 24000,
         equip_slots = { "elona.ranged" },
         subcategory = 24001,
         coefficient = 100,

         skill = "elona.bow",

         gods = { "elona.lulwy" },

         effective_range = { 70, 100, 100, 80, 60, 20, 20, 20, 20, 20 },

         pierce_rate = 15,

         categories = {
            "elona.equip_ranged_bow",
            "elona.equip_ranged"
         }
      },
      {
         _id = "machine_gun",
         elona_id = 231,
         image = "elona.item_machine_gun",
         value = 500,
         weight = 1800,
         dice_x = 10,
         dice_y = 3,
         hit_bonus = 10,
         damage_bonus = 1,
         material = "elona.metal",
         category = 24000,
         equip_slots = { "elona.ranged" },
         subcategory = 24020,
         coefficient = 100,

         skill = "elona.firearm",

         gods = { "elona.mani" },

         tags = { "sf" },

         effective_range = { 80, 100, 100, 90, 80, 70, 20, 20, 20, 20 },
         pierce_rate = 0,
         categories = {
            "elona.equip_ranged_gun",
            "elona.tag_sf",
            "elona.equip_ranged"
         }
      },
      {
         _id = "claymore",
         elona_id = 232,
         image = "elona.item_claymore",
         value = 500,
         weight = 4000,
         dice_x = 3,
         dice_y = 7,
         hit_bonus = 1,
         damage_bonus = 8,
         material = "elona.metal",
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10001,
         coefficient = 100,

         skill = "elona.long_sword",

         categories = {
            "elona.equip_melee_broadsword",
            "elona.equip_melee"
         }
      },
      {
         _id = "ration",
         elona_id = 233,
         image = "elona.item_sack",
         value = 280,
         weight = 400,
         level = 3,
         category = 57000,
         coefficient = 100,

         food_rank = 3,

         categories = {
            "elona.food"
         }
      },
      {
         _id = "bardiche",
         elona_id = 234,
         image = "elona.item_bardiche",
         value = 500,
         weight = 3500,
         dice_x = 1,
         dice_y = 20,
         hit_bonus = -1,
         damage_bonus = 5,
         material = "elona.metal",
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10010,
         coefficient = 100,

         skill = "elona.axe",

         categories = {
            "elona.equip_melee_axe",
            "elona.equip_melee"
         }
      },
      {
         _id = "halberd",
         elona_id = 235,
         image = "elona.item_halberd",
         value = 500,
         weight = 3800,
         dice_x = 2,
         dice_y = 10,
         hit_bonus = -2,
         damage_bonus = 1,
         material = "elona.metal",
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10008,
         coefficient = 100,

         skill = "elona.polearm",
         pierce_rate = 30,
         categories = {
            "elona.equip_melee_halberd",
            "elona.equip_melee"
         }
      },
      {
         _id = "scroll_of_return",
         elona_id = 236,
         image = "elona.item_scroll",
         value = 750,
         weight = 20,
         on_read = function() end,
         category = 53000,
         rarity = 300000,
         coefficient = 0,
         originalnameref2 = "scroll",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         efid = 428,
         efp = 100,
         elona_type = "scroll",
         categories = {
            "elona.scroll",
         }
      },
      {
         _id = "figurine_of_warrior",
         elona_id = 237,
         image = "elona.item_figurine_of_warrior",
         value = 2000,
         weight = 240,
         category = 60000,
         rarity = 100000,
         coefficient = 100,
         originalnameref2 = "figurine",
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "figurine_of_sword",
         elona_id = 238,
         image = "elona.item_figurine_of_sword",
         value = 2000,
         weight = 240,
         category = 60000,
         rarity = 100000,
         coefficient = 100,
         originalnameref2 = "figurine",
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
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
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.container"
         },
         light = light.item
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
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.container"
         },
         light = light.item
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
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.container"
         },
         light = light.item
      },
      {
         _id = "scroll_of_magical_map",
         elona_id = 242,
         image = "elona.item_scroll",
         value = 480,
         weight = 20,
         on_read = function() end,
         category = 53000,
         coefficient = 0,
         originalnameref2 = "scroll",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         efid = 429,
         efp = 500,
         elona_type = "scroll",
         categories = {
            "elona.scroll",
         }
      },
      {
         _id = "scroll_of_gain_attribute",
         elona_id = 243,
         image = "elona.item_scroll",
         value = 240000,
         weight = 20,
         on_read = function() end,
         level = 15,
         category = 53000,
         rarity = 25000,
         coefficient = 0,
         originalnameref2 = "scroll",
         has_random_name = true,

         efid = 1105,
         efp = 100,
         elona_type = "scroll",

         tags = { "noshop" },
         color = Resolver.make("elona.random_item_color"),
         categories = {
            "elona.scroll",
            "elona.tag_noshop"
         }
      },
      {
         _id = "scroll_of_wonder",
         elona_id = 244,
         image = "elona.item_scroll",
         value = 8000,
         weight = 20,
         on_read = function() end,
         level = 5,
         category = 53000,
         rarity = 500000,
         coefficient = 0,
         originalnameref2 = "scroll",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         efid = 1104,
         efp = 100,
         elona_type = "scroll",
         categories = {
            "elona.scroll",
         }
      },
      {
         _id = "scroll_of_minor_teleportation",
         elona_id = 245,
         image = "elona.item_scroll",
         value = 200,
         weight = 20,
         on_read = function() end,
         category = 53000,
         coefficient = 0,
         originalnameref2 = "scroll",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         efid = 408,
         efp = 100,
         elona_type = "scroll",
         categories = {
            "elona.scroll",
         }
      },
      {
         _id = "spellbook_of_magic_mapping",
         elona_id = 246,
         image = "elona.item_spellbook",
         value = 8500,
         weight = 380,
         chargelevel = 4,
         on_read = function() end,
         level = 12,
         category = 54000,
         rarity = 800000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 4 }),
         has_charge = true,

         efid = 429,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "spellbook_of_oracle",
         elona_id = 247,
         image = "elona.item_spellbook",
         value = 25000,
         weight = 380,
         chargelevel = 2,
         on_read = function() end,
         level = 15,
         category = 54000,
         rarity = 100000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 2 }),
         has_charge = true,

         efid = 413,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "spellbook_of_return",
         elona_id = 248,
         image = "elona.item_spellbook",
         value = 8900,
         weight = 380,
         chargelevel = 3,
         on_read = function() end,
         level = 8,
         category = 54000,
         rarity = 300000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 3 }),
         has_charge = true,

         efid = 428,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "spellbook_of_cure_minor_wound",
         elona_id = 249,
         image = "elona.item_spellbook",
         value = 4500,
         weight = 380,
         chargelevel = 5,
         on_read = function() end,
         category = 54000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 5 }),
         has_charge = true,

         efid = 400,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "spellbook_of_cure_critical_wound",
         elona_id = 250,
         image = "elona.item_spellbook",
         value = 9000,
         weight = 380,
         chargelevel = 4,
         on_read = function() end,
         level = 8,
         category = 54000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 4 }),
         has_charge = true,

         efid = 401,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "spellbook_of_cure_eris",
         elona_id = 251,
         image = "elona.item_spellbook",
         value = 15000,
         weight = 380,
         chargelevel = 3,
         on_read = function() end,
         level = 10,
         category = 54000,
         rarity = 700000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 3 }),
         has_charge = true,

         efid = 402,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "spellbook_of_cure_jure",
         elona_id = 252,
         image = "elona.item_spellbook",
         value = 35000,
         weight = 380,
         chargelevel = 2,
         on_read = function() end,
         level = 15,
         category = 54000,
         rarity = 300000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 2 }),
         has_charge = true,

         efid = 403,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "bottle_of_beer",
         elona_id = 253,
         image = "elona.item_molotov",
         value = 280,
         weight = 50,
         category = 52000,
         subcategory = 52002,
         coefficient = 0,
         originalnameref2 = "bottle",

         on_drink = Magic.drink_potion(1102, 200),
         categories = {
            "elona.drink",
            "elona.drink_alcohol"
         }
      },
      {
         _id = "horn",
         elona_id = 254,
         image = "elona.item_horn",
         value = 2500,
         weight = 6500,
         level = 5,
         category = 60000,
         subcategory = 60005,
         rarity = 500000,
         coefficient = 100,

         skill = "elona.performer",
         elona_function = 17,
         param1 = 110,

         tags = { "fest" },

         categories = {
            "elona.furniture_instrument",
            "elona.tag_fest",
            "elona.furniture"
         }
      },
      {
         _id = "campfire",
         elona_id = 255,
         image = "elona.item_campfire",
         value = 1860,
         weight = 12000,
         category = 59000,
         coefficient = 100,

         elona_function = 15,
         param1 = 40,
         categories = {
            "elona.misc_item"
         },
         light = light.torch
      },
      {
         _id = "portable_cooking_tool",
         elona_id = 256,
         image = "elona.item_portable_cooking_tool",
         value = 1860,
         weight = 1200,
         category = 59000,
         coefficient = 100,

         elona_function = 15,
         param1 = 80,
         categories = {
            "elona.misc_item"
         }
      },
      {
         _id = "spellbook_of_magic_arrow",
         elona_id = 257,
         image = "elona.item_spellbook",
         value = 2500,
         weight = 380,
         chargelevel = 5,
         on_read = function() end,
         category = 54000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 5 }),
         has_charge = true,

         efid = 414,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "stick_bread",
         elona_id = 258,
         image = "elona.item_stick_bread",
         value = 280,
         weight = 350,
         level = 3,
         category = 57000,
         coefficient = 100,

         food_rank = 3,

         categories = {
            "elona.food"
         }
      },
      {
         _id = "raw_noodle",
         elona_id = 259,
         image = "elona.item_sack",
         value = 280,
         weight = 400,
         material = "elona.fresh",
         expiration_date = 24,
         level = 3,
         category = 57000,
         subcategory = 57002,
         rarity = 5000000,
         coefficient = 100,

         param1 = 5000,
         param3 = 24,
         categories = {
            "elona.food_noodle",
            "elona.food"
         }
      },
      {
         _id = "sack_of_flour",
         elona_id = 260,
         image = "elona.item_sack",
         value = 280,
         weight = 800,
         expiration_date = 240,
         level = 3,
         category = 57000,
         subcategory = 57001,
         rarity = 5000000,
         coefficient = 100,
         originalnameref2 = "sack",

         param1 = 7000,
         param3 = 240,
         categories = {
            "elona.food_flour",
            "elona.food"
         }
      },
      {
         _id = "bomb_fish",
         elona_id = 261,
         image = "elona.item_bomb_fish",
         value = 280,
         weight = 350,
         material = "elona.fresh",
         expiration_date = 6,
         level = 3,
         category = 57000,
         rarity = 5000000,
         coefficient = 100,

         param1 = 6000,
         param3 = 6,

         gods = { "elona.ehekatl" },

         categories = {
            "elona.food"
         }
      },
      {
         _id = "poison",
         elona_id = 262,
         image = "elona.item_potion",
         value = 120,
         weight = 120,
         category = 52000,
         coefficient = 100,
         has_random_name = true,

         on_drink = Magic.drink_potion(1108, 200),

         tags = { "nogive" },
         color = Resolver.make("elona.random_item_color"),
         categories = {
            "elona.drink",
            "elona.tag_nogive"
         }
      },
      {
         _id = "spellbook_of_nether_eye",
         elona_id = 263,
         image = "elona.item_spellbook",
         value = 7200,
         weight = 380,
         chargelevel = 3,
         on_read = function() end,
         level = 6,
         category = 54000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 3 }),
         has_charge = true,

         efid = 415,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "spellbook_of_chaos_eye",
         elona_id = 264,
         image = "elona.item_spellbook",
         value = 9600,
         weight = 380,
         chargelevel = 3,
         on_read = function() end,
         level = 12,
         category = 54000,
         rarity = 800000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 3 }),
         has_charge = true,

         efid = 417,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "spellbook_of_nerve_eye",
         elona_id = 265,
         image = "elona.item_spellbook",
         value = 6400,
         weight = 380,
         chargelevel = 3,
         on_read = function() end,
         level = 10,
         category = 54000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 3 }),
         has_charge = true,

         efid = 416,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "wakizashi",
         elona_id = 266,
         image = "elona.item_wakizashi",
         value = 500,
         weight = 700,
         dice_x = 4,
         dice_y = 4,
         hit_bonus = 6,
         damage_bonus = 5,
         dv = 1,
         material = "elona.metal",
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10003,
         coefficient = 100,

         skill = "elona.short_sword",
         pierce_rate = 5,
         categories = {
            "elona.equip_melee_short_sword",
            "elona.equip_melee"
         }
      },
      {
         _id = "spellbook_of_darkness_beam",
         elona_id = 267,
         image = "elona.item_spellbook",
         value = 4500,
         weight = 380,
         chargelevel = 4,
         on_read = function() end,
         level = 3,
         category = 54000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 4 }),
         has_charge = true,

         efid = 422,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "spellbook_of_illusion_beam",
         elona_id = 268,
         image = "elona.item_spellbook",
         value = 5500,
         weight = 380,
         chargelevel = 4,
         on_read = function() end,
         level = 5,
         category = 54000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 4 }),
         has_charge = true,

         efid = 423,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "spellbook_of_ice_ball",
         elona_id = 269,
         image = "elona.item_spellbook",
         value = 5400,
         weight = 380,
         chargelevel = 4,
         on_read = function() end,
         level = 3,
         category = 54000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 4 }),
         has_charge = true,

         efid = 431,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "spellbook_of_fire_ball",
         elona_id = 270,
         image = "elona.item_spellbook",
         value = 5400,
         weight = 380,
         chargelevel = 4,
         on_read = function() end,
         level = 3,
         category = 54000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 4 }),
         has_charge = true,

         efid = 432,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "spellbook_of_sound_ball",
         elona_id = 271,
         image = "elona.item_spellbook",
         value = 8400,
         weight = 380,
         chargelevel = 4,
         on_read = function() end,
         level = 10,
         category = 54000,
         rarity = 800000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 4 }),
         has_charge = true,

         efid = 434,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "spellbook_of_chaos_ball",
         elona_id = 272,
         image = "elona.item_spellbook",
         value = 12000,
         weight = 380,
         chargelevel = 4,
         on_read = function() end,
         level = 15,
         category = 54000,
         rarity = 700000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 4 }),
         has_charge = true,

         efid = 433,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "fire_wood",
         elona_id = 273,
         image = "elona.item_fire_wood",
         value = 10,
         weight = 1500,
         category = 64000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
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
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
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
         _id = "long_pillar",
         elona_id = 276,
         image = "elona.item_long_pillar",
         value = 2600,
         weight = 350000,
         level = 8,
         category = 60000,
         rarity = 100000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "broken_pillar",
         elona_id = 277,
         image = "elona.item_broken_pillar",
         value = 1300,
         weight = 300000,
         level = 4,
         category = 60000,
         rarity = 500000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "street_lamp",
         elona_id = 278,
         image = "elona.item_street_lamp",
         value = 1200,
         weight = 300000,
         level = 10,
         category = 60000,
         rarity = 200000,
         coefficient = 100,
         tags = { "sf" },
         categories = {
            "elona.tag_sf",
            "elona.furniture"
         },
         light = light.town_light
      },
      {
         _id = "water_tub",
         elona_id = 279,
         image = "elona.item_water_tub",
         value = 380,
         weight = 300000,
         category = 60000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "comfortable_table",
         elona_id = 280,
         image = "elona.item_comfortable_table",
         value = 1800,
         weight = 9800,
         category = 60000,
         rarity = 400000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "inner_tube",
         elona_id = 281,
         image = "elona.item_inner_tube",
         value = 380,
         weight = 1500,
         category = 60000,
         coefficient = 100,
         tags = { "fish" },
         categories = {
            "elona.tag_fish",
            "elona.furniture"
         }
      },
      {
         _id = "mysterious_map",
         elona_id = 282,
         image = "elona.item_treasure_map",
         value = 380,
         weight = 180,
         category = 60000,
         coefficient = 100,
         can_read_multiple_times = true,
         categories = {
            "elona.furniture"
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

         param2 = Resolver.make("base.random", { rnd = 15 }),

         on_generate = function(self)
            local Chara = require("api.Chara")
            self.param1 = (Rand.rnd(10) + 1) * (Chara.player():calc("level") / 10 + 1)
         end,

         categories = {
            "elona.container",
            "elona.no_generate"
         }
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

         param2 = Resolver.make("base.random", { rnd = 15 }),

         categories = {
            "elona.container",
            "elona.no_generate"
         }
      },
      {
         _id = "potion_of_restore_body",
         elona_id = 285,
         image = "elona.item_potion",
         value = 280,
         weight = 120,
         category = 52000,
         subcategory = 52001,
         coefficient = 0,
         originalnameref2 = "potion",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         on_drink = Magic.drink_potion(439, 100),
         categories = {
            "elona.drink",
            "elona.drink_potion"
         }
      },
      {
         _id = "potion_of_restore_spirit",
         elona_id = 286,
         image = "elona.item_potion",
         value = 280,
         weight = 120,
         category = 52000,
         subcategory = 52001,
         coefficient = 0,
         originalnameref2 = "potion",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         on_drink = Magic.drink_potion(440, 100),
         categories = {
            "elona.drink",
            "elona.drink_potion"
         }
      },
      {
         _id = "potion_of_potential",
         elona_id = 287,
         image = "elona.item_potion",
         value = 50000,
         weight = 120,
         level = 10,
         category = 52000,
         rarity = 80000,
         coefficient = 0,
         originalnameref2 = "potion",
         has_random_name = true,

         on_drink = Magic.drink_potion(1113, 100),

         tags = { "spshop" },
         color = Resolver.make("elona.random_item_color"),
         categories = {
            "elona.drink",
            "elona.tag_spshop"
         }
      },
      {
         _id = "scroll_of_curse",
         elona_id = 288,
         image = "elona.item_scroll",
         value = 150,
         weight = 20,
         on_read = function() end,
         category = 53000,
         coefficient = 0,
         originalnameref2 = "scroll",
         has_random_name = true,

         efid = 1114,
         efp = 100,
         elona_type = "scroll",

         tags = { "neg" },
         color = Resolver.make("elona.random_item_color"),
         categories = {
            "elona.scroll",
            "elona.tag_neg"
         }
      },
      {
         _id = "spellbook_of_wishing",
         elona_id = 289,
         image = "elona.item_spellbook",
         value = 40000,
         weight = 380,
         on_read = function() end,
         level = 15,
         category = 54000,
         rarity = 20000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 1 }),
         has_charge = true,

         efid = 441,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "rod_of_wishing",
         elona_id = 290,
         image = "elona.item_rod",
         value = 300000,
         weight = 800,
         on_zap = function() end,
         level = 10,
         category = 56000,
         rarity = 20000,
         coefficient = 0,
         originalnameref2 = "rod",
         has_random_name = true,

         count = Resolver.make("elona.item_count", { count = 1 }),
         has_charge = true,

         zap_always_succeeds = true,

         efid = 441,
         efp = 100,

         tags = { "noshop" },
         color = Resolver.make("elona.random_item_color"),
         categories = {
            "elona.rod",
            "elona.tag_noshop"
         }
      },
      {
         _id = "well_kept_armor",
         elona_id = 291,
         image = "elona.item_well_kept_armor",
         value = 1500,
         weight = 12000,
         category = 60000,
         rarity = 400000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "rack_of_goods",
         elona_id = 292,
         image = "elona.item_rack_of_goods",
         value = 1800,
         weight = 6800,
         category = 60000,
         rarity = 500000,
         coefficient = 100,
         originalnameref2 = "rack",
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "rack_of_accessories",
         elona_id = 293,
         image = "elona.item_rack_of_accessories",
         value = 2000,
         weight = 7500,
         category = 60000,
         rarity = 500000,
         coefficient = 100,
         originalnameref2 = "rack",
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "towel",
         elona_id = 294,
         image = "elona.item_towel",
         value = 320,
         weight = 1080,
         category = 60000,
         coefficient = 100,
         tags = { "fest" },
         categories = {
            "elona.tag_fest",
            "elona.furniture"
         }
      },
      {
         _id = "ragged_table",
         elona_id = 295,
         image = "elona.item_ragged_table",
         value = 890,
         weight = 4500,
         category = 60000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "cabinet",
         elona_id = 296,
         image = "elona.item_cabinet",
         value = 2400,
         weight = 15000,
         level = 18,
         category = 60000,
         rarity = 250000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "luxury_bed",
         elona_id = 297,
         image = "elona.item_luxury_bed",
         value = 4500,
         weight = 17500,
         on_use = function() end,
         level = 15,
         category = 60000,
         subcategory = 60004,
         rarity = 200000,
         coefficient = 100,

         param1 = 150,

         categories = {
            "elona.furniture_bed",
            "elona.furniture"
         }
      },
      {
         _id = "vase",
         elona_id = 298,
         image = "elona.item_vase",
         value = 2000,
         weight = 2400,
         level = 7,
         category = 60000,
         rarity = 500000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         },
         light = light.item_middle
      },
      {
         _id = "high_grade_dresser",
         elona_id = 299,
         image = "elona.item_high_grade_dresser",
         value = 5500,
         weight = 9000,
         level = 14,
         category = 60000,
         rarity = 150000,
         coefficient = 100,

         elona_function = 19,

         categories = {
            "elona.furniture"
         },

         light = light.crystal_middle
      },
      {
         _id = "neat_bar_table",
         elona_id = 300,
         image = "elona.item_neat_bar_table",
         value = 1900,
         weight = 8500,
         level = 7,
         category = 60000,
         rarity = 500000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
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
         _id = "chest_of_clothes",
         elona_id = 302,
         image = "elona.item_chest_of_clothes",
         value = 1500,
         weight = 6800,
         level = 4,
         category = 60000,
         rarity = 500000,
         coefficient = 100,
         originalnameref2 = "chest",
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "giant_bed",
         elona_id = 303,
         image = "elona.item_giant_bed",
         value = 3800,
         weight = 15000,
         on_use = function() end,
         level = 12,
         category = 60000,
         subcategory = 60004,
         rarity = 400000,
         coefficient = 100,

         param1 = 120,

         categories = {
            "elona.furniture_bed",
            "elona.furniture"
         }
      },
      {
         _id = "plain_bed",
         elona_id = 304,
         image = "elona.item_plain_bed",
         value = 1200,
         weight = 13000,
         on_use = function() end,
         category = 60000,
         subcategory = 60004,
         coefficient = 100,

         param1 = 100,

         categories = {
            "elona.furniture_bed",
            "elona.furniture"
         }
      },
      {
         _id = "coffin",
         elona_id = 305,
         image = "elona.item_coffin",
         value = 2400,
         weight = 8900,
         on_use = function() end,
         level = 18,
         category = 60000,
         subcategory = 60004,
         rarity = 100000,
         coefficient = 100,

         param1 = 130,

         categories = {
            "elona.furniture_bed",
            "elona.furniture"
         }
      },
      {
         _id = "food_processor",
         elona_id = 306,
         image = "elona.item_food_processor",
         value = 5200,
         weight = 34000,
         category = 60000,
         rarity = 200000,
         coefficient = 100,

         elona_function = 15,
         param1 = 200,

         tags = { "sf" },

         categories = {
            "elona.tag_sf",
            "elona.furniture"
         }
      },
      {
         _id = "soft_bed",
         elona_id = 307,
         image = "elona.item_soft_bed",
         value = 2200,
         weight = 12000,
         on_use = function() end,
         category = 60000,
         subcategory = 60004,
         rarity = 200000,
         coefficient = 100,

         param1 = 130,

         categories = {
            "elona.furniture_bed",
            "elona.furniture"
         }
      },
      {
         _id = "cheap_rack",
         elona_id = 308,
         image = "elona.item_cheap_rack",
         value = 1200,
         weight = 9000,
         category = 60000,
         rarity = 800000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "dresser",
         elona_id = 309,
         image = "elona.item_dresser",
         value = 2400,
         weight = 8000,
         level = 7,
         category = 60000,
         rarity = 250000,
         coefficient = 100,

         elona_function = 19,

         categories = {
            "elona.furniture"
         },

         light = light.item_middle
      },
      {
         _id = "clean_bed",
         elona_id = 310,
         image = "elona.item_clean_bed",
         value = 1500,
         weight = 9500,
         on_use = function() end,
         category = 60000,
         subcategory = 60004,
         rarity = 500000,
         coefficient = 100,

         param1 = 130,

         categories = {
            "elona.furniture_bed",
            "elona.furniture"
         }
      },
      {
         _id = "bathtub",
         elona_id = 311,
         image = "elona.item_bathtub",
         value = 4800,
         weight = 28000,
         level = 19,
         category = 60000,
         rarity = 200000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         },
         light = light.item
      },
      {
         _id = "pachisuro_machine",
         elona_id = 312,
         image = "elona.item_pachisuro_machine",
         value = 2800,
         weight = 14000,
         on_use = function() end,
         fltselect = 1,
         category = 60000,
         rarity = 200000,
         coefficient = 100,
         categories = {
            "elona.no_generate",
            "elona.furniture"
         },
         light = light.item
      },
      {
         _id = "casino_table",
         elona_id = 313,
         image = "elona.item_casino_table",
         value = 2800,
         weight = 24000,
         on_use = function() end,
         fltselect = 1,
         category = 60000,
         rarity = 200000,
         coefficient = 100,
         categories = {
            "elona.no_generate",
            "elona.furniture"
         }
      },
      {
         _id = "slot_machine",
         elona_id = 314,
         image = "elona.item_slot_machine",
         value = 2000,
         weight = 12000,
         on_use = function() end,
         fltselect = 1,
         category = 60000,
         rarity = 200000,
         coefficient = 100,
         categories = {
            "elona.no_generate",
            "elona.furniture"
         },
         light = light.item
      },
      {
         _id = "darts_board",
         elona_id = 315,
         image = "elona.item_darts_board",
         value = 1800,
         weight = 8900,
         on_use = function() end,
         fltselect = 1,
         category = 60000,
         rarity = 200000,
         coefficient = 100,
         categories = {
            "elona.no_generate",
            "elona.furniture"
         }
      },
      {
         _id = "big_foliage_plant",
         elona_id = 316,
         image = "elona.item_big_foliage_plant",
         value = 3200,
         weight = 1200,
         level = 18,
         category = 60000,
         rarity = 200000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "old_shelf",
         elona_id = 317,
         image = "elona.item_old_shelf",
         value = 890,
         weight = 7600,
         category = 60000,
         rarity = 600000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "old_bookshelf",
         elona_id = 318,
         image = "elona.item_old_bookshelf",
         value = 1020,
         weight = 8900,
         category = 60000,
         rarity = 600000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "cheap_bed",
         elona_id = 319,
         image = "elona.item_cheap_bed",
         value = 880,
         weight = 2800,
         on_use = function() end,
         category = 60000,
         subcategory = 60004,
         rarity = 600000,
         coefficient = 100,

         param1 = 0,

         categories = {
            "elona.furniture_bed",
            "elona.furniture"
         }
      },
      {
         _id = "cheap_table",
         elona_id = 320,
         image = "elona.item_cheap_table",
         value = 900,
         weight = 6800,
         category = 60000,
         rarity = 200000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "neat_rack",
         elona_id = 321,
         image = "elona.item_neat_rack",
         value = 1480,
         weight = 8800,
         category = 60000,
         rarity = 500000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "simple_dresser",
         elona_id = 322,
         image = "elona.item_simple_dresser",
         value = 2200,
         weight = 12000,
         level = 4,
         category = 60000,
         rarity = 200000,
         coefficient = 100,

         elona_function = 19,

         categories = {
            "elona.furniture"
         },

         light = light.item_middle
      },
      {
         _id = "big_cupboard",
         elona_id = 323,
         image = "elona.item_big_cupboard",
         value = 2800,
         weight = 8900,
         level = 7,
         category = 60000,
         rarity = 200000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "sacred_altar",
         elona_id = 324,
         image = "elona.item_sacred_altar",
         value = 1500,
         weight = 15000,
         category = 60000,
         rarity = 200000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         },
         light = light.crystal
      },
      {
         _id = "comfortable_bed",
         elona_id = 325,
         image = "elona.item_comfortable_bed",
         value = 2800,
         weight = 10000,
         on_use = function() end,
         level = 9,
         category = 60000,
         subcategory = 60004,
         rarity = 200000,
         coefficient = 100,

         param1 = 130,

         categories = {
            "elona.furniture_bed",
            "elona.furniture"
         }
      },
      {
         _id = "simple_rack",
         elona_id = 326,
         image = "elona.item_simple_rack",
         value = 1400,
         weight = 8900,
         category = 60000,
         rarity = 500000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "wide_chair",
         elona_id = 327,
         image = "elona.item_wide_chair",
         value = 600,
         weight = 6400,
         category = 60000,
         rarity = 500000,
         coefficient = 100,

         elona_function = 44,

         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "upright_piano",
         elona_id = 328,
         image = "elona.item_piano",
         value = 4600,
         weight = 29000,
         level = 18,
         category = 60000,
         rarity = 200000,
         coefficient = 100,

         elona_function = 17,
         param1 = 150,
         categories = {
            "elona.furniture"
         },
         light = light.item_middle
      },
      {
         _id = "statue_of_cross",
         elona_id = 329,
         image = "elona.item_statue_of_cross",
         value = 1500,
         weight = 15600,
         category = 60000,
         coefficient = 100,
         originalnameref2 = "statue",
         categories = {
            "elona.furniture"
         },
         light = light.item_middle
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
         _id = "dress",
         elona_id = 331,
         image = "elona.item_dress",
         value = 1440,
         weight = 1050,
         level = 3,
         category = 60000,
         rarity = 200000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "table",
         elona_id = 332,
         image = "elona.item_table",
         value = 1200,
         weight = 4900,
         level = 3,
         category = 60000,
         rarity = 20000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "cargo_travelers_food",
         elona_id = 333,
         image = "elona.item_travelers_food",
         value = 40,
         weight = -2000,
         is_cargo = true,
         category = 91000,
         coefficient = 100,

         food_rank = 3,

         categories = {
            "elona.cargo_food"
         }
      },
      {
         _id = "throne",
         elona_id = 334,
         image = "elona.item_throne",
         value = 6800,
         weight = 35000,
         level = 22,
         category = 60000,
         rarity = 150000,
         coefficient = 100,

         elona_function = 44,

         categories = {
            "elona.furniture"
         },

         light = light.item
      },
      {
         _id = "golden_pedestal",
         elona_id = 335,
         image = "elona.item_golden_pedestal",
         value = 1200,
         weight = 15000,
         level = 8,
         category = 60000,
         rarity = 400000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         },
         light = light.lamp
      },
      {
         _id = "golden_statue",
         elona_id = 336,
         image = "elona.item_golden_statue",
         value = 3200,
         weight = 21000,
         level = 18,
         category = 60000,
         rarity = 200000,
         coefficient = 100,
         categories = {
            "elona.furniture"
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
         categories = {
            "elona.remains"
         }
      },
      {
         _id = "fishing_pole",
         elona_id = 342,
         image = "elona.item_fishing_pole",
         value = 1200,
         weight = 2400,
         category = 59000,
         coefficient = 100,

         elona_function = 16,
         param1 = 60,
         categories = {
            "elona.misc_item"
         }
      },
      {
         _id = "rune",
         elona_id = 343,
         image = "elona.item_rune",
         value = 780,
         weight = 500,
         on_use = function() end,
         category = 60000,
         coefficient = 100,

         elona_function = 22,

         categories = {
            "elona.furniture"
         },

         light = light.crystal
      },
      {
         _id = "deed",
         elona_id = 344,
         image = "elona.item_deed",
         value = 50000,
         weight = 500,
         on_read = function() end,
         fltselect = 1,
         category = 53000,
         subcategory = 53100,
         coefficient = 100,

         prevent_sell_in_own_shop = true,

         param1 = 1,

         params = { building_id = "" },

         on_generate = function(self, is_shop)
            self.param1 = Rand.rnd(5) + 1
            if not is_shop then
               self.param1 = 2
            end
            -- self.value = data["elona.building"][self.params.building_id].value
            self.value = 5000 + 4500 * self.param1 * self.param1 * self.param1 + self.param1 * 20000
            if self.param1 == 5 then
               self.value = self.value * 2
            end
         end,

         efid = 1115,

         color = { 175, 255, 175 },

         categories = {
            "elona.scroll",
            "elona.scroll_deed",
            "elona.no_generate"
         }
      },
      {
         _id = "moonfish",
         elona_id = 345,
         image = "elona.item_moonfish",
         value = 900,
         weight = 800,
         material = "elona.fresh",
         expiration_date = 4,
         level = 12,
         category = 57000,
         rarity = 500000,
         coefficient = 100,

         param1 = 6000,
         param3 = 4,

         gods = { "elona.ehekatl" },

         tags = { "fish" },
         rftags = { "fish" },
         categories = {
            "elona.tag_fish",
            "elona.food"
         }
      },
      {
         _id = "sardine",
         elona_id = 346,
         image = "elona.item_fish",
         value = 1200,
         weight = 1250,
         material = "elona.fresh",
         expiration_date = 4,
         level = 15,
         category = 57000,
         rarity = 300000,
         coefficient = 100,

         param1 = 6000,
         param3 = 4,

         gods = { "elona.ehekatl" },

         tags = { "fish" },
         rftags = { "fish" },
         categories = {
            "elona.tag_fish",
            "elona.food"
         }
      },
      {
         _id = "flatfish",
         elona_id = 347,
         image = "elona.item_flatfish",
         value = 700,
         weight = 900,
         material = "elona.fresh",
         expiration_date = 4,
         level = 10,
         category = 57000,
         rarity = 400000,
         coefficient = 100,

         param1 = 6000,
         param3 = 4,

         gods = { "elona.ehekatl" },

         tags = { "fish" },
         rftags = { "fish" },
         categories = {
            "elona.tag_fish",
            "elona.food"
         }
      },
      {
         _id = "manboo",
         elona_id = 348,
         image = "elona.item_manboo",
         value = 1500,
         weight = 2400,
         material = "elona.fresh",
         expiration_date = 4,
         level = 17,
         category = 57000,
         rarity = 200000,
         coefficient = 100,

         param1 = 6000,
         param3 = 4,

         gods = { "elona.ehekatl" },

         tags = { "fish" },
         rftags = { "fish" },
         categories = {
            "elona.tag_fish",
            "elona.food"
         }
      },
      {
         _id = "seabream",
         elona_id = 349,
         image = "elona.item_seabream",
         value = 150,
         weight = 800,
         material = "elona.fresh",
         expiration_date = 4,
         level = 3,
         category = 57000,
         coefficient = 100,

         param1 = 6000,
         param3 = 4,

         gods = { "elona.ehekatl" },

         tags = { "fish" },
         rftags = { "fish" },
         categories = {
            "elona.tag_fish",
            "elona.food"
         }
      },
      {
         _id = "salmon",
         elona_id = 350,
         image = "elona.item_salmon",
         value = 170,
         weight = 600,
         material = "elona.fresh",
         expiration_date = 4,
         level = 3,
         category = 57000,
         coefficient = 100,

         param1 = 6000,
         param3 = 4,

         gods = { "elona.ehekatl" },

         tags = { "fish" },
         rftags = { "fish" },
         categories = {
            "elona.tag_fish",
            "elona.food"
         }
      },
      {
         _id = "globefish",
         elona_id = 351,
         image = "elona.item_globefish",
         value = 320,
         weight = 550,
         material = "elona.fresh",
         expiration_date = 4,
         level = 5,
         category = 57000,
         rarity = 600000,
         coefficient = 100,

         param1 = 6000,
         param3 = 4,

         gods = { "elona.ehekatl" },

         tags = { "fish" },
         rftags = { "fish" },
         categories = {
            "elona.tag_fish",
            "elona.food"
         }
      },
      {
         _id = "tuna",
         elona_id = 352,
         image = "elona.item_tuna_fish",
         value = 640,
         weight = 700,
         material = "elona.fresh",
         expiration_date = 4,
         level = 7,
         category = 57000,
         rarity = 500000,
         coefficient = 100,

         param1 = 6000,
         param3 = 4,

         gods = { "elona.ehekatl" },

         tags = { "fish" },
         rftags = { "fish" },
         categories = {
            "elona.tag_fish",
            "elona.food"
         }
      },
      {
         _id = "cutlassfish",
         elona_id = 353,
         image = "elona.item_cutlassfish",
         value = 620,
         weight = 600,
         material = "elona.fresh",
         expiration_date = 4,
         level = 7,
         category = 57000,
         rarity = 500000,
         coefficient = 100,

         param1 = 6000,
         param3 = 4,

         gods = { "elona.ehekatl" },

         tags = { "fish" },
         rftags = { "fish" },
         categories = {
            "elona.tag_fish",
            "elona.food"
         }
      },
      {
         _id = "sandborer",
         elona_id = 354,
         image = "elona.item_sandborer",
         value = 380,
         weight = 450,
         material = "elona.fresh",
         expiration_date = 4,
         level = 5,
         category = 57000,
         rarity = 600000,
         coefficient = 100,

         param1 = 6000,
         param3 = 4,

         gods = { "elona.ehekatl" },

         tags = { "fish" },
         rftags = { "fish" },
         categories = {
            "elona.tag_fish",
            "elona.food"
         }
      },
      {
         _id = "gloves_of_vesda",
         elona_id = 355,
         image = "elona.item_plate_gauntlets",
         value = 40000,
         weight = 1200,
         pv = 30,
         dv = 5,
         material = "elona.mithril",
         level = 20,
         fltselect = 3,
         category = 22000,
         equip_slots = { "elona.arm" },
         subcategory = 22003,
         coefficient = 100,

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",

         color = { 255, 155, 155 },

         enchantments = {
            { id = 39, power = 150 },
            { id = 20050, power = 550 },
            { id = 10010, power = 400 },
            { id = 20057, power = 200 },
            { id = 30166, power = 450 },
            { id = 10019, power = 500 },
            { id = 25, power = 100 }
         },

         categories = {
            "elona.equip_wrist_glove",
            "elona.unique_item",
            "elona.equip_wrist"
         },

         light = light.item
      },
      {
         _id = "blood_moon",
         elona_id = 356,
         image = "elona.item_club",
         value = 30000,
         weight = 1800,
         dice_x = 3,
         dice_y = 5,
         hit_bonus = 8,
         damage_bonus = 22,
         material = "elona.iron",
         level = 30,
         fltselect = 3,
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10004,
         coefficient = 100,

         skill = "elona.blunt",

         _copy = {
            enchantments = {
               { id = 38, power = 300 },
               { id = 20050, power = 200 },
               { id = 20056, power = 250 },
               { id = 70050, power = 350 },
               { id = 25, power = 100 },
               { id = 26, power = 100 },
            }
         },

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",

         color = { 255, 155, 155 },

         categories = {
            "elona.equip_melee_club",
            "elona.unique_item",
            "elona.equip_melee"
         },

         light = light.item
      },
      {
         _id = "ring_of_steel_dragon",
         elona_id = 357,
         image = "elona.item_decorative_ring",
         value = 30000,
         weight = 1200,
         pv = 50,
         material = "elona.mithril",
         level = 30,
         fltselect = 3,
         category = 32000,
         equip_slots = { "elona.ring" },
         subcategory = 32001,
         coefficient = 100,

         _copy = {
            enchantments = {
               { id = 42, power = 100 },
               { id = 20060, power = 250 },
               { id = 20052, power = 450 },
               { id = 10010, power = 450 },
               { id = 30153, power = 550 },
               { id = 10018, power = -1400 },
               { id = 26, power = 100 },
               { id = 24, power = 100 },
            }
         },

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",
         categories = {
            "elona.equip_ring_ring",
            "elona.unique_item",
            "elona.equip_ring"
         },
         light = light.item
      },
      {
         _id = "staff_of_insanity",
         elona_id = 358,
         image = "elona.item_staff",
         value = 30000,
         weight = 2500,
         dice_x = 1,
         dice_y = 8,
         hit_bonus = -5,
         damage_bonus = 2,
         pv = 3,
         dv = 15,
         material = "elona.obsidian",
         level = 35,
         fltselect = 3,
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10006,
         coefficient = 100,

         skill = "elona.stave",

         _copy = {
            enchantments = {
               { id = 80002, power = 400 },
               { id = 70054, power = 350 },
               { id = 70058, power = 350 },
               { id = 10016, power = 450 },
               { id = 34, power = 350 },
               { id = 30172, power = 420 },
            }
         },

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",
         categories = {
            "elona.equip_melee_staff",
            "elona.unique_item",
            "elona.equip_melee"
         },
         light = light.item
      },
      {
         _id = "rankis",
         elona_id = 359,
         image = "elona.item_halberd",
         value = 30000,
         weight = 2000,
         dice_x = 8,
         dice_y = 4,
         hit_bonus = 2,
         damage_bonus = 11,
         dv = 6,
         material = "elona.iron",
         level = 35,
         fltselect = 3,
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10007,
         coefficient = 100,

         skill = "elona.polearm",

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",

         color = { 255, 155, 155 },
         pierce_rate = 40,
         enchantments = {
            { id = 40, power = 400 },
            { id = 70056, power = 400 },
            { id = 20056, power = 300 },
            { id = 26, power = 100 }
         },
         categories = {
            "elona.equip_melee_lance",
            "elona.unique_item",
            "elona.equip_melee"
         },
         light = light.item
      },
      {
         _id = "palmia_pride",
         elona_id = 360,
         image = "elona.item_decorative_ring",
         value = 30000,
         weight = 500,
         pv = 5,
         dv = 15,
         material = "elona.mithril",
         level = 30,
         fltselect = 3,
         category = 32000,
         equip_slots = { "elona.ring" },
         subcategory = 32001,
         coefficient = 100,

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",
         enchantments = {
            { id = 41, power = 100 },
            { id = 10019, power = 700 },
            { id = 10018, power = 350 },
            { id = 10017, power = 550 },
            { id = 20053, power = 200 },
            { id = 20059, power = 200 }
         },
         categories = {
            "elona.equip_ring_ring",
            "elona.unique_item",
            "elona.equip_ring"
         },
         light = light.item
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
         }
      },
      {
         _id = "scroll_of_greater_identify",
         elona_id = 362,
         image = "elona.item_scroll",
         value = 3500,
         weight = 20,
         on_read = function() end,
         level = 10,
         category = 53000,
         rarity = 300000,
         coefficient = 0,
         originalnameref2 = "scroll",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         efid = 411,
         efp = 2000,
         elona_type = "scroll",
         categories = {
            "elona.scroll",
         }
      },
      {
         _id = "scroll_of_vanish_curse",
         elona_id = 363,
         image = "elona.item_scroll",
         value = 4400,
         weight = 20,
         on_read = function() end,
         level = 12,
         category = 53000,
         rarity = 300000,
         coefficient = 0,
         originalnameref2 = "scroll",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         efid = 412,
         efp = 2500,
         elona_type = "scroll",
         categories = {
            "elona.scroll",
         }
      },
      {
         _id = "potion_of_defender",
         elona_id = 364,
         image = "elona.item_potion",
         value = 150,
         weight = 120,
         category = 52000,
         coefficient = 100,
         originalnameref2 = "potion",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         on_drink = Magic.drink_potion(442, 200),
         categories = {
            "elona.drink",
         }
      },
      {
         _id = "spellbook_of_holy_shield",
         elona_id = 365,
         image = "elona.item_spellbook",
         value = 2800,
         weight = 380,
         chargelevel = 5,
         on_read = function() end,
         level = 3,
         category = 54000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 5 }),
         has_charge = true,

         efid = 442,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "rod_of_silence",
         elona_id = 366,
         image = "elona.item_rod",
         value = 1080,
         weight = 800,
         chargelevel = 7,
         on_zap = function() end,
         level = 4,
         category = 56000,
         coefficient = 0,
         originalnameref2 = "rod",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 7 }),
         has_charge = true,

         efid = 443,
         efp = 100,
         categories = {
            "elona.rod"
         }
      },
      {
         _id = "spellbook_of_silence",
         elona_id = 367,
         image = "elona.item_spellbook",
         value = 8400,
         weight = 380,
         chargelevel = 3,
         on_read = function() end,
         level = 10,
         category = 54000,
         rarity = 600000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 3 }),
         has_charge = true,

         efid = 443,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "potion_of_silence",
         elona_id = 368,
         image = "elona.item_potion",
         value = 40,
         weight = 120,
         category = 52000,
         coefficient = 100,
         originalnameref2 = "potion",
         has_random_name = true,

         on_drink = Magic.drink_potion(443, 400),

         tags = { "neg" },
         color = Resolver.make("elona.random_item_color"),
         categories = {
            "elona.drink",
            "elona.tag_neg"
         }
      },
      {
         _id = "spellbook_of_regeneration",
         elona_id = 369,
         image = "elona.item_spellbook",
         value = 4400,
         weight = 380,
         chargelevel = 4,
         on_read = function() end,
         level = 8,
         category = 54000,
         rarity = 500000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 4 }),
         has_charge = true,

         efid = 444,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "potion_of_troll_blood",
         elona_id = 370,
         image = "elona.item_potion",
         value = 800,
         weight = 120,
         level = 9,
         category = 52000,
         coefficient = 100,
         originalnameref2 = "potion",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         on_drink = Magic.drink_potion(444, 300),
         categories = {
            "elona.drink",
         }
      },
      {
         _id = "spellbook_of_resistance",
         elona_id = 371,
         image = "elona.item_spellbook",
         value = 7500,
         weight = 380,
         chargelevel = 3,
         on_read = function() end,
         level = 8,
         category = 54000,
         rarity = 700000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 3 }),
         has_charge = true,

         efid = 445,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "potion_of_resistance",
         elona_id = 372,
         image = "elona.item_potion",
         value = 700,
         weight = 120,
         level = 8,
         category = 52000,
         coefficient = 100,
         originalnameref2 = "potion",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         on_drink = Magic.drink_potion(445, 250),
         categories = {
            "elona.drink",
         }
      },
      {
         _id = "spellbook_of_speed",
         elona_id = 373,
         image = "elona.item_spellbook",
         value = 12000,
         weight = 380,
         chargelevel = 3,
         on_read = function() end,
         level = 13,
         category = 54000,
         rarity = 700000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 3 }),
         has_charge = true,

         efid = 446,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "spellbook_of_slow",
         elona_id = 374,
         image = "elona.item_spellbook",
         value = 4800,
         weight = 380,
         chargelevel = 4,
         on_read = function() end,
         level = 7,
         category = 54000,
         rarity = 700000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 4 }),
         has_charge = true,

         efid = 447,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "potion_of_speed",
         elona_id = 375,
         image = "elona.item_potion",
         value = 850,
         weight = 120,
         category = 52000,
         rarity = 700000,
         coefficient = 100,
         originalnameref2 = "potion",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         on_drink = Magic.drink_potion(446, 250),
         categories = {
            "elona.drink",
         }
      },
      {
         _id = "potion_of_slow",
         elona_id = 376,
         image = "elona.item_potion",
         value = 30,
         weight = 120,
         category = 52000,
         coefficient = 100,
         originalnameref2 = "potion",
         has_random_name = true,

         on_drink = Magic.drink_potion(447, 400),

         tags = { "neg" },
         color = Resolver.make("elona.random_item_color"),
         categories = {
            "elona.drink",
            "elona.tag_neg"
         }
      },
      {
         _id = "rod_of_speed",
         elona_id = 377,
         image = "elona.item_rod",
         value = 4200,
         weight = 800,
         chargelevel = 8,
         on_zap = function() end,
         level = 8,
         category = 56000,
         coefficient = 0,
         originalnameref2 = "rod",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 8 }),
         has_charge = true,

         efid = 446,
         efp = 100,
         categories = {
            "elona.rod"
         }
      },
      {
         _id = "spellbook_of_hero",
         elona_id = 378,
         image = "elona.item_spellbook",
         value = 2600,
         weight = 380,
         chargelevel = 5,
         on_read = function() end,
         level = 2,
         category = 54000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 5 }),
         has_charge = true,

         efid = 448,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "potion_of_hero",
         elona_id = 379,
         image = "elona.item_potion",
         value = 450,
         weight = 120,
         category = 52000,
         coefficient = 100,
         originalnameref2 = "potion",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         on_drink = Magic.drink_potion(448, 250),
         categories = {
            "elona.drink",
         }
      },
      {
         _id = "spellbook_of_weakness",
         elona_id = 380,
         image = "elona.item_spellbook",
         value = 2500,
         weight = 380,
         chargelevel = 3,
         on_read = function() end,
         category = 54000,
         rarity = 700000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 3 }),
         has_charge = true,

         efid = 449,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "spellbook_of_elemental_scar",
         elona_id = 381,
         image = "elona.item_spellbook",
         value = 6400,
         weight = 380,
         chargelevel = 3,
         on_read = function() end,
         level = 10,
         category = 54000,
         rarity = 700000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 3 }),
         has_charge = true,

         efid = 450,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "potion_of_weakness",
         elona_id = 382,
         image = "elona.item_potion",
         value = 30,
         weight = 120,
         category = 52000,
         coefficient = 100,
         originalnameref2 = "potion",
         has_random_name = true,

         on_drink = Magic.drink_potion(449, 250),

         tags = { "neg" },
         color = Resolver.make("elona.random_item_color"),
         categories = {
            "elona.drink",
            "elona.tag_neg"
         }
      },
      {
         _id = "spellbook_of_holy_veil",
         elona_id = 383,
         image = "elona.item_spellbook",
         value = 11000,
         weight = 380,
         chargelevel = 4,
         on_read = function() end,
         level = 14,
         category = 54000,
         rarity = 200000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 4 }),
         has_charge = true,

         efid = 451,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "scroll_of_holy_veil",
         elona_id = 384,
         image = "elona.item_scroll",
         value = 1500,
         weight = 20,
         on_read = function() end,
         level = 3,
         category = 53000,
         rarity = 400000,
         coefficient = 0,
         originalnameref2 = "scroll",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         efid = 451,
         efp = 250,
         elona_type = "scroll",
         categories = {
            "elona.scroll",
         }
      },
      {
         _id = "rod_of_holy_light",
         elona_id = 385,
         image = "elona.item_rod",
         value = 3600,
         weight = 800,
         chargelevel = 6,
         on_zap = function() end,
         level = 7,
         category = 56000,
         rarity = 400000,
         coefficient = 0,
         originalnameref2 = "rod",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 6 }),
         has_charge = true,

         efid = 407,
         efp = 100,
         categories = {
            "elona.rod"
         }
      },
      {
         _id = "spellbook_of_holy_light",
         elona_id = 386,
         image = "elona.item_spellbook",
         value = 3500,
         weight = 380,
         chargelevel = 3,
         on_read = function() end,
         level = 2,
         category = 54000,
         rarity = 700000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 3 }),
         has_charge = true,

         efid = 406,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "spellbook_of_holy_rain",
         elona_id = 387,
         image = "elona.item_spellbook",
         value = 9800,
         weight = 380,
         chargelevel = 3,
         on_read = function() end,
         level = 11,
         category = 54000,
         rarity = 300000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 3 }),
         has_charge = true,

         efid = 407,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "scroll_of_holy_light",
         elona_id = 388,
         image = "elona.item_scroll",
         value = 350,
         weight = 20,
         on_read = function() end,
         category = 53000,
         rarity = 800000,
         coefficient = 0,
         originalnameref2 = "scroll",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         efid = 406,
         efp = 300,
         elona_type = "scroll",
         categories = {
            "elona.scroll",
         }
      },
      {
         _id = "scroll_of_holy_rain",
         elona_id = 389,
         image = "elona.item_scroll",
         value = 1400,
         weight = 20,
         on_read = function() end,
         level = 5,
         category = 53000,
         rarity = 400000,
         coefficient = 0,
         originalnameref2 = "scroll",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         efid = 407,
         efp = 300,
         elona_type = "scroll",
         categories = {
            "elona.scroll",
         }
      },
      {
         _id = "scroll_of_mana",
         elona_id = 390,
         image = "elona.item_scroll",
         value = 2400,
         weight = 20,
         on_read = function() end,
         level = 5,
         category = 53000,
         rarity = 150000,
         coefficient = 0,
         originalnameref2 = "scroll",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         efid = 621,
         efp = 250,
         elona_type = "scroll",
         categories = {
            "elona.scroll",
         }
      },
      {
         _id = "rod_of_mana",
         elona_id = 391,
         image = "elona.item_rod",
         value = 4100,
         weight = 800,
         chargelevel = 4,
         on_zap = function() end,
         level = 11,
         category = 56000,
         rarity = 200000,
         coefficient = 0,
         originalnameref2 = "rod",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 4 }),
         has_charge = true,

         efid = 621,
         efp = 100,
         categories = {
            "elona.rod"
         }
      },
      {
         _id = "bottle_of_sulfuric",
         elona_id = 392,
         image = "elona.item_molotov",
         value = 800,
         weight = 50,
         category = 52000,
         coefficient = 0,
         originalnameref2 = "bottle",

         on_drink = Magic.drink_potion(1116, 100),

         tags = { "nogive" },

         categories = {
            "elona.drink",
            "elona.tag_nogive"
         }
      },
      {
         _id = "gem_cutter",
         elona_id = 393,
         image = "elona.item_gem_cutter",
         value = 2000,
         weight = 500,
         on_use = function() end,
         category = 59000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },

         elona_function = 3,

         categories = {
            "elona.misc_item"
         }
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
         _id = "scroll_of_gain_material",
         elona_id = 395,
         image = "elona.item_scroll",
         value = 3800,
         weight = 20,
         on_read = function() end,
         level = 5,
         category = 53000,
         rarity = 700000,
         coefficient = 0,
         originalnameref2 = "scroll",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         efid = 1117,
         efp = 250,
         elona_type = "scroll",
         categories = {
            "elona.scroll",
         }
      },
      {
         _id = "spellbook_of_nightmare",
         elona_id = 396,
         image = "elona.item_spellbook",
         value = 3400,
         weight = 380,
         chargelevel = 4,
         on_read = function() end,
         level = 3,
         category = 54000,
         rarity = 800000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 4 }),
         has_charge = true,

         efid = 452,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "spellbook_of_knowledge",
         elona_id = 397,
         image = "elona.item_spellbook",
         value = 3800,
         weight = 380,
         chargelevel = 5,
         on_read = function() end,
         level = 3,
         category = 54000,
         rarity = 700000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 5 }),
         has_charge = true,

         efid = 453,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "scroll_of_knowledge",
         elona_id = 398,
         image = "elona.item_scroll",
         value = 1800,
         weight = 20,
         on_read = function() end,
         level = 3,
         category = 53000,
         rarity = 600000,
         coefficient = 0,
         originalnameref2 = "scroll",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         efid = 453,
         efp = 250,
         elona_type = "scroll",
         categories = {
            "elona.scroll",
         }
      },
      {
         _id = "cargo_rag_doll",
         elona_id = 399,
         image = "elona.item_rag_doll",
         value = 700,
         weight = -6500,
         is_cargo = true,
         category = 92000,
         coefficient = 100,

         param1 = 1,

         categories = {
            "elona.cargo"
         }
      },
      {
         _id = "cargo_barrel",
         elona_id = 400,
         image = "elona.item_barrel",
         value = 420,
         weight = -10000,
         is_cargo = true,
         category = 92000,
         coefficient = 100,

         param1 = 2,

         categories = {
            "elona.cargo"
         }
      },
      {
         _id = "cargo_piano",
         elona_id = 401,
         image = "elona.item_piano",
         value = 4000,
         weight = -50000,
         is_cargo = true,
         category = 92000,
         rarity = 200000,
         coefficient = 100,

         param1 = 4,

         categories = {
            "elona.cargo"
         }
      },
      {
         _id = "cargo_rope",
         elona_id = 402,
         image = "elona.item_rope",
         value = 550,
         weight = -4800,
         is_cargo = true,
         category = 92000,
         coefficient = 100,

         param1 = 5,

         categories = {
            "elona.cargo"
         }
      },
      {
         _id = "cargo_coffin",
         elona_id = 403,
         image = "elona.item_coffin",
         value = 2200,
         weight = -12000,
         is_cargo = true,
         category = 92000,
         rarity = 700000,
         coefficient = 100,

         param1 = 3,

         categories = {
            "elona.cargo"
         }
      },
      {
         _id = "cargo_manboo",
         elona_id = 404,
         image = "elona.item_manboo",
         value = 800,
         weight = -10000,
         is_cargo = true,
         category = 92000,
         rarity = 1500000,
         coefficient = 100,

         param1 = 0,

         categories = {
            "elona.cargo"
         }
      },
      {
         _id = "cargo_grave",
         elona_id = 405,
         image = "elona.item_grave",
         value = 2800,
         weight = -48000,
         is_cargo = true,
         category = 92000,
         rarity = 800000,
         coefficient = 100,

         param1 = 3,

         categories = {
            "elona.cargo"
         }
      },
      {
         _id = "cargo_tuna_fish",
         elona_id = 406,
         image = "elona.item_tuna_fish",
         value = 350,
         weight = -7500,
         is_cargo = true,
         category = 92000,
         rarity = 2000000,
         coefficient = 100,

         param1 = 0,

         categories = {
            "elona.cargo"
         }
      },
      {
         _id = "cargo_whisky",
         elona_id = 407,
         image = "elona.item_whisky",
         value = 1400,
         weight = -16000,
         is_cargo = true,
         category = 92000,
         rarity = 600000,
         coefficient = 100,

         param1 = 2,

         categories = {
            "elona.cargo"
         }
      },
      {
         _id = "cargo_noble_toy",
         elona_id = 408,
         image = "elona.item_noble_toy",
         value = 1200,
         weight = -32000,
         is_cargo = true,
         category = 92000,
         rarity = 500000,
         coefficient = 100,

         param1 = 1,

         categories = {
            "elona.cargo"
         }
      },
      {
         _id = "cargo_inner_tube",
         elona_id = 409,
         image = "elona.item_inner_tube",
         value = 340,
         weight = -1500,
         is_cargo = true,
         category = 92000,
         rarity = 1500000,
         coefficient = 100,

         param1 = 5,

         categories = {
            "elona.cargo"
         }
      },
      {
         _id = "spellbook_of_detect_objects",
         elona_id = 410,
         image = "elona.item_spellbook",
         value = 4000,
         weight = 380,
         chargelevel = 4,
         on_read = function() end,
         category = 54000,
         rarity = 600000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 4 }),
         has_charge = true,

         efid = 430,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "scroll_of_detect_objects",
         elona_id = 411,
         image = "elona.item_scroll",
         value = 350,
         weight = 20,
         on_read = function() end,
         category = 53000,
         coefficient = 0,
         originalnameref2 = "scroll",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         efid = 430,
         efp = 500,
         elona_type = "scroll",
         categories = {
            "elona.scroll",
         }
      },
      {
         _id = "rod_of_uncurse",
         elona_id = 412,
         image = "elona.item_rod",
         value = 3800,
         weight = 800,
         chargelevel = 3,
         on_zap = function() end,
         level = 12,
         category = 56000,
         rarity = 500000,
         coefficient = 0,
         originalnameref2 = "rod",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         _copy = {
            count = Resolver.make("elona.item_count", { count = 3 }),
         },

         has_charge = true,

         efid = 412,
         efp = 100,
         categories = {
            "elona.rod"
         }
      },
      {
         _id = "red_treasure_machine",
         elona_id = 413,
         image = "elona.item_red_treasure_machine",
         value = 15000,
         weight = 140000,
         on_use = function() end,
         level = 18,
         fltselect = 1,
         category = 60000,
         rarity = 50000,
         coefficient = 100,
         categories = {
            "elona.no_generate",
            "elona.furniture"
         }
      },
      {
         _id = "blue_treasure_machine",
         elona_id = 414,
         image = "elona.item_blue_treasure_machine",
         value = 30000,
         weight = 140000,
         on_use = function() end,
         level = 18,
         fltselect = 1,
         category = 60000,
         rarity = 50000,
         coefficient = 100,
         categories = {
            "elona.no_generate",
            "elona.furniture"
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

         param1 = Resolver.make("base.player_level"),

         categories = {
            "elona.container"
         }
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

         param1 = Resolver.make("base.player_level"),

         categories = {
            "elona.container",
            "elona.tag_spshop"
         }
      },
      {
         _id = "vegetable_seed",
         elona_id = 417,
         image = "elona.item_seed",
         value = 240,
         weight = 40,
         material = 36,
         on_use = function() end,
         category = 57000,
         subcategory = 58500,
         coefficient = 100,

         _copy = {
            food_rank = 1,
         },

         gods = { "elona.kumiromi" },

         color = { 175, 255, 175 },

         categories = {
            "elona.crop_seed",
            "elona.food"
         }
      },
      {
         _id = "fruit_seed",
         elona_id = 418,
         image = "elona.item_seed",
         value = 280,
         weight = 40,
         material = 37,
         on_use = function() end,
         category = 57000,
         subcategory = 58500,
         rarity = 800000,
         coefficient = 100,

         food_rank = 1,

         gods = { "elona.kumiromi" },

         color = { 255, 255, 175 },

         categories = {
            "elona.crop_seed",
            "elona.food"
         }
      },
      {
         _id = "herb_seed",
         elona_id = 419,
         image = "elona.item_seed",
         value = 1800,
         weight = 40,
         material = 38,
         on_use = function() end,
         category = 57000,
         subcategory = 58500,
         rarity = 100000,
         coefficient = 100,

         food_rank = 1,

         gods = { "elona.kumiromi" },

         color = { 175, 175, 255 },

         categories = {
            "elona.crop_seed",
            "elona.food"
         }
      },
      {
         _id = "unknown_seed",
         elona_id = 420,
         image = "elona.item_seed",
         value = 2500,
         weight = 40,
         material = 39,
         on_use = function() end,
         category = 57000,
         subcategory = 58500,
         rarity = 250000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },

         food_rank = 1,

         gods = { "elona.kumiromi" },

         categories = {
            "elona.crop_seed",
            "elona.food"
         }
      },
      {
         _id = "artifact_seed",
         elona_id = 421,
         image = "elona.item_seed",
         value = 120000,
         weight = 40,
         material = 40,
         on_use = function() end,
         category = 57000,
         subcategory = 58500,
         rarity = 20000,
         coefficient = 100,

         food_rank = 1,

         gods = { "elona.kumiromi" },

         tags = { "noshop", "spshop" },
         color = { 255, 215, 175 },
         medal_value = 15,
         categories = {
            "elona.crop_seed",
            "elona.tag_noshop",
            "elona.tag_spshop",
            "elona.food"
         }
      },
      {
         _id = "morgia",
         elona_id = 422,
         image = "elona.item_stomafillia",
         value = 1050,
         weight = 250,
         category = 57000,
         subcategory = 58005,
         rarity = 80000,
         coefficient = 100,

         food_rank = 1,

         nutrition = 500,
         food_buffs = {
            { id = 10, power = 900 },
            { id = 11, power = 700 },
            { id = 17, power = 10 },
            { id = 16, power = 10 },
            { id = 12, power = 10 },
            { id = 13, power = 10 },
            { id = 14, power = 10 },
            { id = 15, power = 10 },
         },

         events = {
            {
               id = "elona_sys.on_item_eat",
               name = "morgia effects",

               callback = function(self, params)
                  params.chara:mod_base_skill_potential(10, 2)
                  params.chara:mod_base_skill_potential(11, 2)
                  if params.chara:is_player() then
                     Gui.mes("food special: morgia")
                  end
               end
            }
         },

         categories = {
            "elona.crop_herb",
            "elona.food"
         }
      },
      {
         _id = "mareilon",
         elona_id = 423,
         image = "elona.item_stomafillia",
         value = 800,
         weight = 210,
         category = 57000,
         subcategory = 58005,
         rarity = 80000,
         coefficient = 100,

         food_rank = 4,

         nutrition = 500,
         food_buffs = {
            { id = 10, power = 10 },
            { id = 11, power = 10 },
            { id = 17, power = 10 },
            { id = 16, power = 800 },
            { id = 12, power = 10 },
            { id = 13, power = 10 },
            { id = 14, power = 10 },
            { id = 15, power = 800 },
         },

         events = {
            {
               id = "elona_sys.on_item_eat",
               name = "marelion effects",

               callback = function(self, params)
                  params.chara:mod_base_skill_potential(16, 2)
                  params.chara:mod_base_skill_potential(15, 2)
                  if params.chara:is_player() then
                     Gui.mes("food special: marelion")
                  end
               end
            }
         },

         categories = {
            "elona.crop_herb",
            "elona.food"
         }
      },
      {
         _id = "spenseweed",
         elona_id = 424,
         image = "elona.item_stomafillia",
         value = 900,
         weight = 220,
         category = 57000,
         subcategory = 58005,
         rarity = 80000,
         coefficient = 100,

         food_rank = 3,

         nutrition = 500,
         food_buffs = {
            { id = 10, power = 10 },
            { id = 11, power = 10 },
            { id = 17, power = 10 },
            { id = 16, power = 10 },
            { id = 12, power = 750 },
            { id = 13, power = 800 },
            { id = 14, power = 10 },
            { id = 15, power = 10 },
         },

         events = {
            {
               id = "elona_sys.on_item_eat",
               name = "spenseweed effects",

               callback = function(self, params)
                  params.chara:mod_base_skill_potential(12, 2)
                  params.chara:mod_base_skill_potential(13, 2)
                  if params.chara:is_player() then
                     Gui.mes("food special: spenseweed")
                  end
               end
            }
         },

         categories = {
            "elona.crop_herb",
            "elona.food"
         }
      },
      {
         _id = "curaria",
         elona_id = 425,
         image = "elona.item_stomafillia",
         value = 680,
         weight = 260,
         category = 57000,
         subcategory = 58005,
         coefficient = 100,

         food_rank = 6,

         nutrition = 2500,
         food_buffs = {
            { id = 10, power = 100 },
            { id = 11, power = 100 },
            { id = 17, power = 100 },
            { id = 16, power = 100 },
            { id = 12, power = 100 },
            { id = 13, power = 100 },
            { id = 14, power = 100 },
            { id = 15, power = 100 },
         },

         events = {
            {
               id = "elona_sys.on_item_eat",
               name = "curaria effects",

               callback = function(self, params)
                  if params.chara:is_player() then
                     Gui.mes("food special: curaria")
                  end
               end
            }
         },

         categories = {
            "elona.crop_herb",
            "elona.food"
         }
      },
      {
         _id = "alraunia",
         elona_id = 426,
         image = "elona.item_stomafillia",
         value = 1200,
         weight = 120,
         category = 57000,
         subcategory = 58005,
         rarity = 80000,
         coefficient = 100,

         food_rank = 3,

         nutrition = 500,
         food_buffs = {
            { id = 10, power = 10 },
            { id = 11, power = 10 },
            { id = 17, power = 850 },
            { id = 16, power = 10 },
            { id = 12, power = 10 },
            { id = 13, power = 10 },
            { id = 14, power = 700 },
            { id = 15, power = 10 },
         },
         events = {
            {
               id = "elona_sys.on_item_eat",
               name = "alraunia effects",

               callback = function(self, params)
                  params.chara:mod_base_skill_potential(17, 2)
                  params.chara:mod_base_skill_potential(14, 2)
                  if params.chara:is_player() then
                     Gui.mes("food special: alarunia")
                  end
               end
            }
         },
         categories = {
            "elona.crop_herb",
            "elona.food"
         }
      },
      {
         _id = "stomafillia",
         elona_id = 427,
         image = "elona.item_stomafillia",
         value = 800,
         weight = 480,
         category = 57000,
         subcategory = 58005,
         coefficient = 100,

         food_rank = 7,

         nutrition = 20000,
         food_buffs = {
            { id = 10, power = 50 },
            { id = 11, power = 50 },
            { id = 17, power = 50 },
            { id = 16, power = 50 },
            { id = 12, power = 50 },
            { id = 13, power = 50 },
            { id = 14, power = 50 },
            { id = 15, power = 50 },
         },
         categories = {
            "elona.crop_herb",
            "elona.food"
         }
      },
      {
         _id = "sleeping_bag",
         elona_id = 428,
         image = "elona.item_sleeping_bag",
         value = 800,
         weight = 2400,
         on_use = function() end,
         category = 59000,
         subcategory = 60004,
         coefficient = 0,

         param1 = 0,

         categories = {
            no_implicit = true,
            "elona.misc_item",
            "elona.furniture_bed",
         },
      },
      {
         _id = "potion_of_weaken_resistance",
         elona_id = 429,
         image = "elona.item_potion",
         value = 150,
         weight = 120,
         category = 52000,
         coefficient = 0,
         originalnameref2 = "potion",
         has_random_name = true,

         on_drink = Magic.drink_potion(1118, 100),

         tags = { "neg" },
         color = Resolver.make("elona.random_item_color"),
         categories = {
            "elona.drink",
            "elona.tag_neg"
         }
      },
      {
         _id = "scroll_of_growth",
         elona_id = 430,
         image = "elona.item_scroll",
         value = 15000,
         weight = 20,
         on_read = function() end,
         level = 5,
         category = 53000,
         rarity = 80000,
         coefficient = 0,
         originalnameref2 = "scroll",
         has_random_name = true,

         efid = 1119,
         efp = 500,
         elona_type = "scroll",

         tags = { "noshop" },
         color = Resolver.make("elona.random_item_color"),
         medal_value = 5,
         categories = {
            "elona.scroll",
            "elona.tag_noshop"
         }
      },
      {
         _id = "scroll_of_faith",
         elona_id = 431,
         image = "elona.item_scroll",
         value = 12000,
         weight = 20,
         on_read = function() end,
         level = 5,
         category = 53000,
         rarity = 300000,
         coefficient = 0,
         originalnameref2 = "scroll",
         has_random_name = true,

         efid = 1107,
         efp = 300,
         elona_type = "scroll",

         tags = { "noshop" },
         color = Resolver.make("elona.random_item_color"),
         medal_value = 8,
         categories = {
            "elona.scroll",
            "elona.tag_noshop"
         }
      },
      {
         _id = "potion_of_mutation",
         elona_id = 432,
         image = "elona.item_potion",
         value = 5000,
         weight = 120,
         level = 8,
         category = 52000,
         rarity = 200000,
         coefficient = 0,
         originalnameref2 = "potion",
         has_random_name = true,

         on_drink = Magic.drink_potion(454, 100),

         tags = { "nogive" },
         color = Resolver.make("elona.random_item_color"),
         categories = {
            "elona.drink",
            "elona.tag_nogive"
         }
      },
      {
         _id = "potion_of_cure_mutation",
         elona_id = 433,
         image = "elona.item_potion",
         value = 4000,
         weight = 120,
         level = 10,
         category = 52000,
         rarity = 400000,
         coefficient = 0,
         originalnameref2 = "potion",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         on_drink = Magic.drink_potion(1121, 200),
         categories = {
            "elona.drink",
         }
      },
      {
         _id = "spellbook_of_mutation",
         elona_id = 434,
         image = "elona.item_spellbook",
         value = 20000,
         weight = 380,
         chargelevel = 2,
         on_read = function() end,
         level = 15,
         category = 54000,
         rarity = 100000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 2 }),
         has_charge = true,

         efid = 454,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "banded_mail",
         elona_id = 435,
         image = "elona.item_banded_mail",
         value = 1500,
         weight = 6500,
         pv = 12,
         dv = 5,
         material = "elona.metal",
         appearance = 2,
         level = 10,
         category = 16000,
         equip_slots = { "elona.body" },
         subcategory = 16001,
         coefficient = 100,
         categories = {
            "elona.equip_body_mail",
            "elona.equip_body"
         }
      },
      {
         _id = "plate_mail",
         elona_id = 436,
         image = "elona.item_plate_mail",
         value = 12500,
         weight = 7500,
         pv = 21,
         dv = 6,
         material = "elona.metal",
         appearance = 7,
         level = 50,
         category = 16000,
         equip_slots = { "elona.body" },
         subcategory = 16001,
         coefficient = 100,
         categories = {
            "elona.equip_body_mail",
            "elona.equip_body"
         }
      },
      {
         _id = "ring_mail",
         elona_id = 437,
         image = "elona.item_ring_mail",
         value = 2400,
         weight = 5000,
         pv = 14,
         dv = 6,
         material = "elona.metal",
         appearance = 2,
         level = 20,
         category = 16000,
         equip_slots = { "elona.body" },
         subcategory = 16001,
         coefficient = 100,
         categories = {
            "elona.equip_body_mail",
            "elona.equip_body"
         }
      },
      {
         _id = "composite_mail",
         elona_id = 438,
         image = "elona.item_composite_mail",
         value = 4500,
         weight = 5500,
         pv = 17,
         dv = 7,
         material = "elona.metal",
         appearance = 6,
         level = 30,
         category = 16000,
         equip_slots = { "elona.body" },
         subcategory = 16001,
         coefficient = 100,
         categories = {
            "elona.equip_body_mail",
            "elona.equip_body"
         }
      },
      {
         _id = "chain_mail",
         elona_id = 439,
         image = "elona.item_chain_mail",
         value = 8000,
         weight = 5200,
         pv = 19,
         dv = 7,
         material = "elona.metal",
         appearance = 6,
         level = 40,
         category = 16000,
         equip_slots = { "elona.body" },
         subcategory = 16001,
         coefficient = 100,
         categories = {
            "elona.equip_body_mail",
            "elona.equip_body"
         }
      },
      {
         _id = "pope_robe",
         elona_id = 440,
         image = "elona.item_pope_robe",
         value = 9500,
         weight = 1200,
         pv = 8,
         dv = 18,
         material = "elona.soft",
         appearance = 4,
         level = 45,
         category = 16000,
         equip_slots = { "elona.body" },
         subcategory = 16003,
         coefficient = 100,
         categories = {
            "elona.equip_body_robe",
            "elona.equip_body"
         }
      },
      {
         _id = "light_mail",
         elona_id = 441,
         image = "elona.item_light_mail",
         value = 1200,
         weight = 1800,
         pv = 8,
         dv = 10,
         material = "elona.soft",
         appearance = 2,
         level = 10,
         category = 16000,
         equip_slots = { "elona.body" },
         subcategory = 16003,
         coefficient = 100,
         categories = {
            "elona.equip_body_robe",
            "elona.equip_body"
         }
      },
      {
         _id = "coat",
         elona_id = 442,
         image = "elona.item_coat",
         value = 2000,
         weight = 1500,
         pv = 9,
         dv = 13,
         material = "elona.soft",
         appearance = 5,
         level = 20,
         category = 16000,
         equip_slots = { "elona.body" },
         subcategory = 16003,
         coefficient = 100,
         categories = {
            "elona.equip_body_robe",
            "elona.equip_body"
         }
      },
      {
         _id = "breast_plate",
         elona_id = 443,
         image = "elona.item_breast_plate",
         value = 5500,
         weight = 2800,
         pv = 11,
         dv = 15,
         material = "elona.soft",
         appearance = 2,
         level = 25,
         category = 16000,
         equip_slots = { "elona.body" },
         subcategory = 16003,
         coefficient = 100,
         categories = {
            "elona.equip_body_robe",
            "elona.equip_body"
         }
      },
      {
         _id = "bulletproof_jacket",
         elona_id = 444,
         image = "elona.item_bulletproof_jacket",
         value = 7200,
         weight = 1600,
         pv = 15,
         dv = 14,
         material = "elona.soft",
         appearance = 5,
         level = 35,
         category = 16000,
         equip_slots = { "elona.body" },
         subcategory = 16003,
         coefficient = 100,
         categories = {
            "elona.equip_body_robe",
            "elona.equip_body"
         }
      },
      {
         _id = "gloves",
         elona_id = 445,
         image = "elona.item_gloves",
         value = 800,
         weight = 450,
         hit_bonus = 5,
         damage_bonus = 1,
         pv = 4,
         dv = 5,
         material = "elona.soft",
         appearance = 1,
         level = 15,
         category = 22000,
         equip_slots = { "elona.arm" },
         subcategory = 22003,
         coefficient = 100,
         categories = {
            "elona.equip_wrist_glove",
            "elona.equip_wrist"
         }
      },
      {
         _id = "plate_gauntlets",
         elona_id = 446,
         image = "elona.item_plate_gauntlets",
         value = 1800,
         weight = 1800,
         hit_bonus = 3,
         damage_bonus = 3,
         pv = 7,
         dv = 3,
         material = "elona.metal",
         appearance = 2,
         level = 30,
         category = 22000,
         equip_slots = { "elona.arm" },
         subcategory = 22001,
         coefficient = 100,
         categories = {
            "elona.equip_wrist_gauntlet",
            "elona.equip_wrist"
         }
      },
      {
         _id = "light_gloves",
         elona_id = 447,
         image = "elona.item_light_gloves",
         value = 280,
         weight = 200,
         hit_bonus = 3,
         pv = 3,
         dv = 3,
         material = "elona.soft",
         appearance = 1,
         category = 22000,
         equip_slots = { "elona.arm" },
         subcategory = 22003,
         coefficient = 100,
         categories = {
            "elona.equip_wrist_glove",
            "elona.equip_wrist"
         }
      },
      {
         _id = "composite_gauntlets",
         elona_id = 448,
         image = "elona.item_composite_gauntlets",
         value = 950,
         weight = 1300,
         hit_bonus = 4,
         damage_bonus = 2,
         pv = 5,
         dv = 3,
         material = "elona.metal",
         appearance = 2,
         level = 15,
         category = 22000,
         equip_slots = { "elona.arm" },
         subcategory = 22001,
         coefficient = 100,
         categories = {
            "elona.equip_wrist_gauntlet",
            "elona.equip_wrist"
         }
      },
      {
         _id = "small_shield",
         elona_id = 449,
         image = "elona.item_small_shield",
         value = 500,
         weight = 1200,
         pv = 4,
         dv = 3,
         material = "elona.metal",
         category = 14000,
         equip_slots = { "elona.hand" },
         subcategory = 14003,
         coefficient = 100,

         skill = "elona.shield",

         categories = {
            "elona.equip_shield_shield",
            "elona.equip_shield"
         }
      },
      {
         _id = "round_shield",
         elona_id = 450,
         image = "elona.item_round_shield",
         value = 1200,
         weight = 1500,
         pv = 5,
         dv = 4,
         material = "elona.metal",
         level = 10,
         category = 14000,
         equip_slots = { "elona.hand" },
         subcategory = 14003,
         coefficient = 100,

         skill = "elona.shield",

         categories = {
            "elona.equip_shield_shield",
            "elona.equip_shield"
         }
      },
      {
         _id = "shield",
         elona_id = 451,
         image = "elona.item_shield",
         value = 2500,
         weight = 1000,
         pv = 6,
         dv = 3,
         material = "elona.metal",
         level = 20,
         category = 14000,
         equip_slots = { "elona.hand" },
         subcategory = 14003,
         coefficient = 100,

         skill = "elona.shield",

         categories = {
            "elona.equip_shield_shield",
            "elona.equip_shield"
         }
      },
      {
         _id = "large_shield",
         elona_id = 452,
         image = "elona.item_large_shield",
         value = 7500,
         weight = 1400,
         pv = 8,
         dv = 2,
         material = "elona.metal",
         level = 40,
         category = 14000,
         equip_slots = { "elona.hand" },
         subcategory = 14003,
         coefficient = 100,

         skill = "elona.shield",

         categories = {
            "elona.equip_shield_shield",
            "elona.equip_shield"
         }
      },
      {
         _id = "kite_shield",
         elona_id = 453,
         image = "elona.item_kite_shield",
         value = 10000,
         weight = 3500,
         pv = 13,
         dv = -3,
         material = "elona.metal",
         level = 50,
         category = 14000,
         equip_slots = { "elona.hand" },
         subcategory = 14003,
         coefficient = 100,

         skill = "elona.shield",

         categories = {
            "elona.equip_shield_shield",
            "elona.equip_shield"
         }
      },
      {
         _id = "tower_shield",
         elona_id = 454,
         image = "elona.item_tower_shield",
         value = 18000,
         weight = 2400,
         pv = 10,
         dv = -1,
         material = "elona.metal",
         level = 60,
         category = 14000,
         equip_slots = { "elona.hand" },
         subcategory = 14003,
         coefficient = 100,

         skill = "elona.shield",

         categories = {
            "elona.equip_shield_shield",
            "elona.equip_shield"
         }
      },
      {
         _id = "shoes",
         elona_id = 455,
         image = "elona.item_boots",
         value = 260,
         weight = 250,
         pv = 1,
         dv = 3,
         material = "elona.soft",
         appearance = 5,
         category = 18000,
         equip_slots = { "elona.leg" },
         subcategory = 18002,
         coefficient = 100,
         categories = {
            "elona.equip_leg_shoes",
            "elona.equip_leg"
         }
      },
      {
         _id = "boots",
         elona_id = 456,
         image = "elona.item_boots",
         value = 1500,
         weight = 450,
         pv = 2,
         dv = 5,
         material = "elona.soft",
         appearance = 1,
         level = 15,
         category = 18000,
         equip_slots = { "elona.leg" },
         subcategory = 18002,
         coefficient = 100,
         categories = {
            "elona.equip_leg_shoes",
            "elona.equip_leg"
         }
      },
      {
         _id = "tight_boots",
         elona_id = 457,
         image = "elona.item_tight_boots",
         value = 3500,
         weight = 650,
         pv = 3,
         dv = 6,
         material = "elona.soft",
         appearance = 2,
         level = 30,
         category = 18000,
         equip_slots = { "elona.leg" },
         subcategory = 18002,
         coefficient = 100,
         categories = {
            "elona.equip_leg_shoes",
            "elona.equip_leg"
         }
      },
      {
         _id = "armored_boots",
         elona_id = 458,
         image = "elona.item_armored_boots",
         value = 4800,
         weight = 1400,
         pv = 6,
         material = "elona.metal",
         appearance = 4,
         level = 30,
         category = 18000,
         equip_slots = { "elona.leg" },
         subcategory = 18001,
         coefficient = 100,
         categories = {
            "elona.equip_leg_heavy_boots",
            "elona.equip_leg"
         }
      },
      {
         _id = "composite_girdle",
         elona_id = 459,
         image = "elona.item_composite_girdle",
         value = 2400,
         weight = 650,
         pv = 3,
         dv = 5,
         material = "elona.metal",
         appearance = 3,
         level = 15,
         category = 19000,
         equip_slots = { "elona.waist" },
         subcategory = 19001,
         coefficient = 100,
         categories = {
            "elona.equip_back_girdle",
            "elona.equip_cloak"
         }
      },
      {
         _id = "plate_girdle",
         elona_id = 460,
         image = "elona.item_composite_girdle",
         value = 3900,
         weight = 1400,
         pv = 6,
         dv = 3,
         material = "elona.metal",
         appearance = 2,
         level = 30,
         category = 19000,
         equip_slots = { "elona.waist" },
         subcategory = 19001,
         coefficient = 100,
         categories = {
            "elona.equip_back_girdle",
            "elona.equip_cloak"
         }
      },
      {
         _id = "armored_cloak",
         elona_id = 461,
         image = "elona.item_armored_cloak",
         value = 1400,
         weight = 1800,
         pv = 4,
         dv = 5,
         material = "elona.soft",
         appearance = 2,
         level = 15,
         category = 20000,
         equip_slots = { "elona.back" },
         subcategory = 20001,
         coefficient = 100,
         categories = {
            "elona.equip_back",
            "elona.equip_back_cloak"
         }
      },
      {
         _id = "cloak",
         elona_id = 462,
         image = "elona.item_cloak",
         value = 3500,
         weight = 1500,
         pv = 3,
         dv = 7,
         material = "elona.soft",
         appearance = 1,
         level = 30,
         category = 20000,
         equip_slots = { "elona.back" },
         subcategory = 20001,
         coefficient = 100,
         categories = {
            "elona.equip_back",
            "elona.equip_back_cloak"
         }
      },
      {
         _id = "feather_hat",
         elona_id = 463,
         image = "elona.item_feather_hat",
         value = 400,
         weight = 500,
         pv = 1,
         dv = 5,
         material = "elona.soft",
         category = 12000,
         equip_slots = { "elona.head" },
         subcategory = 12002,
         coefficient = 100,
         categories = {
            "elona.equip_head_hat",
            "elona.equip_head"
         }
      },
      {
         _id = "heavy_helm",
         elona_id = 464,
         image = "elona.item_heavy_helm",
         value = 4800,
         weight = 2400,
         pv = 7,
         dv = 4,
         material = "elona.metal",
         level = 30,
         category = 12000,
         equip_slots = { "elona.head" },
         subcategory = 12001,
         coefficient = 100,
         categories = {
            "elona.equip_head_helm",
            "elona.equip_head"
         }
      },
      {
         _id = "knight_helm",
         elona_id = 465,
         image = "elona.item_knight_helm",
         value = 2200,
         weight = 2000,
         pv = 7,
         dv = 1,
         material = "elona.metal",
         level = 15,
         category = 12000,
         equip_slots = { "elona.head" },
         subcategory = 12001,
         coefficient = 100,
         categories = {
            "elona.equip_head_helm",
            "elona.equip_head"
         }
      },
      {
         _id = "helm",
         elona_id = 466,
         image = "elona.item_helm",
         value = 600,
         weight = 1600,
         pv = 5,
         dv = 3,
         material = "elona.metal",
         category = 12000,
         equip_slots = { "elona.head" },
         subcategory = 12001,
         coefficient = 100,
         categories = {
            "elona.equip_head_helm",
            "elona.equip_head"
         }
      },
      {
         _id = "composite_helm",
         elona_id = 467,
         image = "elona.item_composite_helm",
         value = 9600,
         weight = 1800,
         pv = 8,
         dv = 5,
         material = "elona.metal",
         level = 60,
         category = 12000,
         equip_slots = { "elona.head" },
         subcategory = 12001,
         coefficient = 100,
         categories = {
            "elona.equip_head_helm",
            "elona.equip_head"
         }
      },
      {
         _id = "peridot",
         elona_id = 468,
         image = "elona.item_peridot",
         value = 4400,
         weight = 50,
         hit_bonus = 4,
         material = "elona.metal",
         level = 30,
         category = 34000,
         equip_slots = { "elona.neck" },
         subcategory = 34001,
         coefficient = 100,
         has_random_name = true,
         categories = {
            "elona.equip_neck_armor",
            "elona.equip_neck"
         }
      },
      {
         _id = "talisman",
         elona_id = 469,
         image = "elona.item_talisman",
         value = 4400,
         weight = 50,
         dv = 4,
         material = "elona.soft",
         level = 30,
         category = 34000,
         equip_slots = { "elona.neck" },
         subcategory = 34001,
         coefficient = 100,
         has_random_name = true,
         categories = {
            "elona.equip_neck_armor",
            "elona.equip_neck"
         }
      },
      {
         _id = "neck_guard",
         elona_id = 470,
         image = "elona.item_neck_guard",
         value = 2200,
         weight = 50,
         pv = 3,
         material = "elona.metal",
         level = 10,
         category = 34000,
         equip_slots = { "elona.neck" },
         subcategory = 34001,
         coefficient = 100,
         has_random_name = true,
         categories = {
            "elona.equip_neck_armor",
            "elona.equip_neck"
         }
      },
      {
         _id = "charm",
         elona_id = 471,
         image = "elona.item_charm",
         value = 2000,
         weight = 50,
         damage_bonus = 3,
         material = "elona.soft",
         level = 10,
         category = 34000,
         equip_slots = { "elona.neck" },
         subcategory = 34001,
         coefficient = 100,
         has_random_name = true,
         tags = { "fest" },
         categories = {
            "elona.equip_neck_armor",
            "elona.tag_fest",
            "elona.equip_neck"
         }
      },
      {
         _id = "bejeweled_amulet",
         elona_id = 472,
         image = "elona.item_bejeweled_amulet",
         value = 1800,
         weight = 50,
         material = "elona.metal",
         level = 5,
         category = 34000,
         equip_slots = { "elona.neck" },
         subcategory = 34001,
         coefficient = 100,
         has_random_name = true,
         categories = {
            "elona.equip_neck_armor",
            "elona.equip_neck"
         }
      },
      {
         _id = "engagement_amulet",
         elona_id = 473,
         image = "elona.item_engagement_amulet",
         value = 5000,
         weight = 50,
         material = "elona.metal",
         category = 34000,
         equip_slots = { "elona.neck" },
         subcategory = 34001,
         rarity = 800000,
         coefficient = 100,
         has_random_name = true,
         categories = {
            "elona.equip_neck_armor",
            "elona.equip_neck"
         }
      },
      {
         _id = "composite_ring",
         elona_id = 474,
         image = "elona.item_composite_ring",
         value = 450,
         weight = 50,
         damage_bonus = 2,
         material = "elona.metal",
         level = 15,
         category = 32000,
         equip_slots = { "elona.ring" },
         subcategory = 32001,
         coefficient = 100,
         has_random_name = true,
         categories = {
            "elona.equip_ring_ring",
            "elona.equip_ring"
         }
      },
      {
         _id = "armored_ring",
         elona_id = 475,
         image = "elona.item_armored_ring",
         value = 450,
         weight = 50,
         pv = 2,
         material = "elona.metal",
         level = 15,
         category = 32000,
         equip_slots = { "elona.ring" },
         subcategory = 32001,
         coefficient = 100,
         has_random_name = true,
         categories = {
            "elona.equip_ring_ring",
            "elona.equip_ring"
         }
      },
      {
         _id = "ring",
         elona_id = 476,
         image = "elona.item_ring",
         value = 450,
         weight = 50,
         material = "elona.metal",
         level = 10,
         category = 32000,
         equip_slots = { "elona.ring" },
         subcategory = 32001,
         coefficient = 100,
         has_random_name = true,
         categories = {
            "elona.equip_ring_ring",
            "elona.equip_ring"
         }
      },
      {
         _id = "engagement_ring",
         elona_id = 477,
         image = "elona.item_engagement_ring",
         value = 5200,
         weight = 50,
         material = "elona.metal",
         category = 32000,
         equip_slots = { "elona.ring" },
         subcategory = 32001,
         rarity = 700000,
         coefficient = 100,
         has_random_name = true,
         categories = {
            "elona.equip_ring_ring",
            "elona.equip_ring"
         }
      },
      {
         _id = "stethoscope",
         elona_id = 478,
         image = "elona.item_stethoscope",
         value = 1200,
         weight = 250,
         on_use = function() end,
         category = 59000,
         coefficient = 100,

         elona_function = 5,

         categories = {
            "elona.misc_item"
         }
      },
      {
         _id = "scroll_of_ally",
         elona_id = 479,
         image = "elona.item_scroll",
         value = 9000,
         weight = 20,
         on_read = function() end,
         level = 10,
         category = 53000,
         rarity = 300000,
         coefficient = 0,
         originalnameref2 = "scroll",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         efid = 1122,
         efp = 100,
         elona_type = "scroll",
         categories = {
            "elona.scroll",
         }
      },
      {
         _id = "rod_of_domination",
         elona_id = 480,
         image = "elona.item_rod",
         value = 16000,
         weight = 800,
         chargelevel = 2,
         on_zap = function() end,
         level = 5,
         category = 56000,
         rarity = 100000,
         coefficient = 0,
         originalnameref2 = "rod",
         has_random_name = true,

         count = Resolver.make("elona.item_count", { count = 2 }),
         has_charge = true,

         efid = 435,
         efp = 100,

         tags = { "noshop" },
         color = Resolver.make("elona.random_item_color"),
         medal_value = 20,
         categories = {
            "elona.rod",
            "elona.tag_noshop"
         }
      },
      {
         _id = "spellbook_of_domination",
         elona_id = 481,
         image = "elona.item_spellbook",
         value = 28000,
         weight = 380,
         chargelevel = 2,
         on_read = function() end,
         level = 5,
         category = 54000,
         rarity = 100000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 2 }),
         has_charge = true,

         efid = 435,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "crossbow",
         elona_id = 482,
         image = "elona.item_crossbow",
         value = 500,
         weight = 2800,
         dice_x = 1,
         dice_y = 18,
         hit_bonus = 4,
         damage_bonus = 6,
         material = "elona.metal",
         category = 24000,
         equip_slots = { "elona.ranged" },
         subcategory = 24003,
         coefficient = 100,

         skill = "elona.crossbow",

         gods = { "elona.lulwy" },

         effective_range = { 80, 100, 90, 80, 70, 60, 50, 20, 20, 20 },

         pierce_rate = 25,

         categories = {
            "elona.equip_ranged_crossbow",
            "elona.equip_ranged"
         }
      },
      {
         _id = "bolt",
         elona_id = 483,
         image = "elona.item_bolt",
         value = 150,
         weight = 3500,
         dice_x = 1,
         dice_y = 8,
         hit_bonus = 2,
         damage_bonus = 1,
         material = "elona.metal",
         category = 25000,
         equip_slots = { "elona.ammo" },
         subcategory = 25002,
         coefficient = 100,

         skill = "elona.crossbow",

         categories = {
            "elona.equip_ammo",
            "elona.equip_ammo_bolt"
         }
      },
      {
         _id = "spellbook_of_web",
         elona_id = 484,
         image = "elona.item_spellbook",
         value = 4500,
         weight = 380,
         chargelevel = 4,
         on_read = function() end,
         category = 54000,
         rarity = 800000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 4 }),
         has_charge = true,

         efid = 436,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "rod_of_web",
         elona_id = 485,
         image = "elona.item_rod",
         value = 3500,
         weight = 800,
         chargelevel = 8,
         on_zap = function() end,
         level = 3,
         category = 56000,
         rarity = 700000,
         coefficient = 0,
         originalnameref2 = "rod",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 8 }),
         has_charge = true,

         efid = 436,
         efp = 100,
         categories = {
            "elona.rod"
         }
      },
      {
         _id = "machine",
         elona_id = 486,
         image = "elona.item_machine",
         value = 3600,
         weight = 150000,
         level = 5,
         category = 60000,
         rarity = 200000,
         coefficient = 100,

         gods = { "elona.mani" },

         tags = { "sf" },

         categories = {
            "elona.tag_sf",
            "elona.furniture"
         },

         light = light.item
      },
      {
         _id = "computer",
         elona_id = 487,
         image = "elona.item_computer",
         value = 4400,
         weight = 45000,
         level = 12,
         category = 60000,
         rarity = 300000,
         coefficient = 100,

         gods = { "elona.mani" },

         tags = { "sf" },

         categories = {
            "elona.tag_sf",
            "elona.furniture"
         },

         light = light.item
      },
      {
         _id = "training_machine",
         elona_id = 488,
         image = "elona.item_training_machine",
         value = 2400,
         weight = 120000,
         level = 11,
         category = 60000,
         rarity = 200000,
         coefficient = 100,

         elona_function = 9,

         gods = { "elona.mani" },

         tags = { "sf" },

         categories = {
            "elona.tag_sf",
            "elona.furniture"
         }
      },
      {
         _id = "camera",
         elona_id = 489,
         image = "elona.item_camera",
         value = 1600,
         weight = 1500,
         category = 60000,
         rarity = 100000,
         coefficient = 100,

         gods = { "elona.mani" },

         tags = { "sf", "fest" },

         categories = {
            "elona.tag_sf",
            "elona.tag_fest",
            "elona.furniture"
         }
      },
      {
         _id = "microwave_oven",
         elona_id = 490,
         image = "elona.item_microwave_oven",
         value = 3200,
         weight = 150000,
         level = 15,
         category = 60000,
         rarity = 100000,
         coefficient = 100,

         gods = { "elona.mani" },

         tags = { "sf" },

         categories = {
            "elona.tag_sf",
            "elona.furniture"
         }
      },
      {
         _id = "server",
         elona_id = 491,
         image = "elona.item_server",
         value = 2400,
         weight = 95000,
         level = 18,
         category = 60000,
         rarity = 100000,
         coefficient = 100,

         gods = { "elona.mani" },

         tags = { "sf" },

         categories = {
            "elona.tag_sf",
            "elona.furniture"
         }
      },
      {
         _id = "storage",
         elona_id = 492,
         image = "elona.item_storage",
         value = 3100,
         weight = 14000,
         level = 11,
         category = 60000,
         rarity = 100000,
         coefficient = 100,

         gods = { "elona.mani" },

         tags = { "sf" },

         categories = {
            "elona.tag_sf",
            "elona.furniture"
         }
      },
      {
         _id = "trash_can",
         elona_id = 493,
         image = "elona.item_trash_can",
         value = 1000,
         weight = 8000,
         category = 60000,
         rarity = 100000,
         coefficient = 100,
         tags = { "sf" },
         categories = {
            "elona.tag_sf",
            "elona.furniture"
         }
      },
      {
         _id = "chip",
         elona_id = 494,
         image = "elona.item_chip",
         value = 1200,
         weight = 800,
         category = 60000,
         rarity = 500000,
         coefficient = 100,

         gods = { "elona.mani" },

         tags = { "sf" },

         categories = {
            "elona.tag_sf",
            "elona.furniture"
         }
      },
      {
         _id = "blank_disc",
         elona_id = 495,
         image = "elona.item_playback_disc",
         value = 1000,
         weight = 500,
         category = 60000,
         rarity = 500000,
         coefficient = 100,

         gods = { "elona.mani" },

         tags = { "sf" },

         categories = {
            "elona.tag_sf",
            "elona.furniture"
         },

         light = light.item
      },
      {
         _id = "shot_gun",
         elona_id = 496,
         image = "elona.item_shot_gun",
         value = 800,
         weight = 1500,
         dice_x = 4,
         dice_y = 8,
         hit_bonus = 4,
         damage_bonus = 6,
         material = "elona.metal",
         level = 10,
         category = 24000,
         equip_slots = { "elona.ranged" },
         subcategory = 24020,
         coefficient = 100,

         skill = "elona.firearm",

         gods = { "elona.mani" },

         tags = { "sf" },

         effective_range = { 100, 60, 20, 20, 20, 20, 20, 20, 20, 20 },
         pierce_rate = 30,
         categories = {
            "elona.equip_ranged_gun",
            "elona.tag_sf",
            "elona.equip_ranged"
         }
      },
      {
         _id = "pop_corn",
         elona_id = 497,
         image = "elona.item_pop_corn",
         value = 440,
         weight = 200,
         level = 3,
         category = 57000,
         rarity = 250000,
         coefficient = 100,

         food_rank = 5,

         tags = { "sf", "fest" },

         categories = {
            "elona.tag_sf",
            "elona.tag_fest",
            "elona.food"
         }
      },
      {
         _id = "fried_potato",
         elona_id = 498,
         image = "elona.item_fried_potato",
         value = 350,
         weight = 180,
         level = 3,
         category = 57000,
         rarity = 250000,
         coefficient = 100,

         food_rank = 6,

         tags = { "sf", "fest" },

         categories = {
            "elona.tag_sf",
            "elona.tag_fest",
            "elona.food"
         }
      },
      {
         _id = "cyber_snack",
         elona_id = 499,
         image = "elona.item_cyber_snack",
         value = 750,
         weight = 500,
         level = 3,
         category = 57000,
         rarity = 250000,
         coefficient = 100,

         food_rank = 7,

         tags = { "sf", "fest" },

         categories = {
            "elona.tag_sf",
            "elona.tag_fest",
            "elona.food"
         }
      },
      {
         _id = "scroll_of_inferior_material",
         elona_id = 500,
         image = "elona.item_scroll",
         value = 600,
         weight = 20,
         on_read = function() end,
         category = 53000,
         coefficient = 0,
         originalnameref2 = "scroll",
         has_random_name = true,

         efid = 1127,
         efp = 10,
         elona_type = "scroll",

         tags = { "neg" },
         color = Resolver.make("elona.random_item_color"),
         categories = {
            "elona.scroll",
            "elona.tag_neg"
         }
      },
      {
         _id = "scroll_of_change_material",
         elona_id = 501,
         image = "elona.item_scroll",
         value = 5000,
         weight = 20,
         on_read = function() end,
         level = 15,
         category = 53000,
         rarity = 500000,
         coefficient = 0,
         originalnameref2 = "scroll",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         efid = 1127,
         efp = 180,
         elona_type = "scroll",
         categories = {
            "elona.scroll",
         }
      },
      {
         _id = "scroll_of_superior_material",
         elona_id = 502,
         image = "elona.item_scroll",
         value = 20000,
         weight = 20,
         on_read = function() end,
         level = 30,
         category = 53000,
         rarity = 100000,
         coefficient = 0,
         originalnameref2 = "scroll",
         has_random_name = true,

         efid = 1127,
         efp = 350,
         elona_type = "scroll",

         tags = { "spshop" },
         color = Resolver.make("elona.random_item_color"),
         medal_value = 7,
         categories = {
            "elona.scroll",
            "elona.tag_spshop"
         }
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
         categories = {
            "elona.remains",
            "elona.no_generate"
         }
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
         categories = {
            "elona.remains",
            "elona.no_generate"
         }
      },
      {
         _id = "little_sisters_diary",
         elona_id = 505,
         image = "elona.item_spellbook",
         value = 8000,
         weight = 380,
         on_read = function() end,
         level = 5,
         category = 55000,
         rarity = 25000,
         coefficient = 0,
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         is_precious = true,

         efid = 1123,
         efp = 100,
         elona_type = "scroll",
         medal_value = 12,
         categories = {
            "elona.book"
         }
      },
      {
         _id = "scroll_of_enchant_weapon",
         elona_id = 506,
         image = "elona.item_scroll",
         value = 8000,
         weight = 20,
         on_read = function() end,
         category = 53000,
         rarity = 300000,
         coefficient = 0,
         originalnameref2 = "scroll",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         efid = 1124,
         efp = 200,
         elona_type = "scroll",
         categories = {
            "elona.scroll",
         }
      },
      {
         _id = "scroll_of_greater_enchant_weapon",
         elona_id = 507,
         image = "elona.item_scroll",
         value = 14000,
         weight = 20,
         on_read = function() end,
         level = 10,
         category = 53000,
         rarity = 100000,
         coefficient = 0,
         originalnameref2 = "scroll",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         efid = 1124,
         efp = 400,
         elona_type = "scroll",
         categories = {
            "elona.scroll",
         }
      },
      {
         _id = "scroll_of_enchant_armor",
         elona_id = 508,
         image = "elona.item_scroll",
         value = 8000,
         weight = 20,
         on_read = function() end,
         category = 53000,
         rarity = 300000,
         coefficient = 0,
         originalnameref2 = "scroll",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         efid = 1125,
         efp = 200,
         elona_type = "scroll",
         categories = {
            "elona.scroll",
         }
      },
      {
         _id = "scroll_of_greater_enchant_armor",
         elona_id = 509,
         image = "elona.item_scroll",
         value = 14000,
         weight = 20,
         on_read = function() end,
         level = 10,
         category = 53000,
         rarity = 100000,
         coefficient = 0,
         originalnameref2 = "scroll",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         efid = 1125,
         efp = 400,
         elona_type = "scroll",
         categories = {
            "elona.scroll",
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
         _id = "deed_of_heirship",
         elona_id = 511,
         image = "elona.item_deed",
         value = 10000,
         weight = 500,
         on_read = function()
            -- efid = 1128
            -- efp = param1
         end,
         level = 3,
         category = 53000,
         rarity = 250000,
         coefficient = 100,
         originalnameref2 = "deed",

         param1 = Resolver.make("base.between", { min = 100, coefficient = 200 }),

         elona_type = "scroll",

         categories = {
            "elona.scroll",
         }
      },
      {
         _id = "laser_gun",
         elona_id = 512,
         image = "elona.item_laser_gun",
         value = 1500,
         weight = 1200,
         dice_x = 2,
         dice_y = 12,
         hit_bonus = 5,
         damage_bonus = 5,
         material = "elona.metal",
         category = 24000,
         equip_slots = { "elona.ranged" },
         subcategory = 24021,
         rarity = 200000,
         coefficient = 100,

         skill = "elona.firearm",

         gods = { "elona.mani" },

         tags = { "sf" },

         effective_range = { 100, 100, 100, 100, 100, 100, 100, 20, 20, 20 },
         pierce_rate = 5,
         categories = {
            "elona.equip_ranged_laser_gun",
            "elona.tag_sf",
            "elona.equip_ranged"
         }
      },
      {
         _id = "energy_cell",
         elona_id = 513,
         image = "elona.item_energy_cell",
         value = 150,
         weight = 800,
         dice_x = 2,
         dice_y = 3,
         damage_bonus = 1,
         material = "elona.metal",
         category = 25000,
         equip_slots = { "elona.ammo" },
         subcategory = 25030,
         coefficient = 100,

         skill = "elona.firearm",

         tags = { "sf" },

         categories = {
            "elona.equip_ammo",
            "elona.equip_ammo_energy_cell",
            "elona.tag_sf"
         }
      },
      {
         _id = "rail_gun",
         elona_id = 514,
         image = "elona.item_laser_gun",
         value = 60000,
         weight = 8500,
         dice_x = 4,
         dice_y = 10,
         hit_bonus = -20,
         damage_bonus = 15,
         material = "elona.ether",
         level = 80,
         fltselect = 3,
         category = 24000,
         equip_slots = { "elona.ranged" },
         subcategory = 24021,
         rarity = 200000,
         coefficient = 100,

         skill = "elona.firearm",

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",

         tags = { "sf" },

         effective_range = { 100, 100, 100, 100, 100, 100, 100, 50, 20, 20 },
         pierce_rate = 5,
         enchantments = {
            { id = 80003, power = 350 },
            { id = 80004, power = 300 },
            { id = 70058, power = 300 },
            { id = 20057, power = 300 },
            { id = 20059, power = 300 }
         },
         categories = {
            "elona.equip_ranged_laser_gun",
            "elona.tag_sf",
            "elona.unique_item",
            "elona.equip_ranged"
         },
         light = light.item
      },
      {
         _id = "scroll_of_recharge",
         elona_id = 515,
         image = "elona.item_scroll",
         value = 2500,
         weight = 20,
         on_read = function() end,
         level = 5,
         category = 53000,
         rarity = 500000,
         coefficient = 0,
         originalnameref2 = "scroll",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         efid = 1129,
         efp = 300,
         elona_type = "scroll",
         categories = {
            "elona.scroll",
         }
      },
      {
         _id = "bottle_of_water",
         elona_id = 516,
         image = "elona.item_potion",
         value = 280,
         weight = 50,
         category = 52000,
         rarity = 400000,
         coefficient = 0,
         originalnameref2 = "bottle",

         on_drink = Magic.drink_potion(1103, 100),
         medal_value = 3,
         categories = {
            "elona.drink",
         }
      },
      {
         _id = "rod_of_change_creature",
         elona_id = 517,
         image = "elona.item_rod",
         value = 4500,
         weight = 800,
         chargelevel = 4,
         on_zap = function() end,
         level = 5,
         category = 56000,
         rarity = 700000,
         coefficient = 0,
         originalnameref2 = "rod",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 4 }),
         has_charge = true,

         efid = 628,
         efp = 100,
         categories = {
            "elona.rod"
         }
      },
      {
         _id = "rod_of_alchemy",
         elona_id = 518,
         image = "elona.item_rod",
         value = 6000,
         weight = 800,
         chargelevel = 3,
         on_zap = function() end,
         level = 7,
         category = 56000,
         rarity = 450000,
         coefficient = 0,
         originalnameref2 = "rod",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 3 }),
         has_charge = true,

         efid = 1132,
         efp = 100,
         categories = {
            "elona.rod"
         }
      },
      {
         _id = "bottle_of_dye",
         elona_id = 519,
         image = "elona.item_potion",
         value = 500,
         weight = 120,
         category = 52000,
         rarity = 2000000,
         coefficient = 100,
         originalnameref2 = "bottle",
         has_random_name = true,

         on_drink = Magic.drink_potion(1108, 150),

         tags = { "nogive" },
         color = "RandomAny",
         categories = {
            "elona.drink",
            "elona.tag_nogive"
         }
      },
      {
         _id = "wing",
         elona_id = 520,
         image = "elona.item_wing",
         value = 4500,
         weight = 500,
         dv = 9,
         material = "elona.soft",
         appearance = 3,
         level = 10,
         category = 20000,
         equip_slots = { "elona.back" },
         subcategory = 20001,
         rarity = 500000,
         coefficient = 100,
         enchantments = {
            { id = 32, power = 100 }
         },
         categories = {
            "elona.equip_back_cloak",
            "elona.equip_back"
         }
      },
      {
         _id = "deed_of_museum",
         elona_id = 521,
         image = "elona.item_deed",
         value = 140000,
         weight = 500,
         on_read = function() end,
         fltselect = 1,
         category = 53000,
         subcategory = 53100,
         rarity = 1000,
         coefficient = 100,
         originalnameref2 = "deed",

         param1 = 1,

         efid = 1115,

         color = { 255, 215, 175 },

         categories = {
            "elona.scroll",
            "elona.scroll_deed",
            "elona.no_generate"
         }
      },
      {
         _id = "deed_of_shop",
         elona_id = 522,
         image = "elona.item_deed",
         value = 200000,
         weight = 500,
         on_read = function() end,
         fltselect = 1,
         category = 53000,
         subcategory = 53100,
         rarity = 1000,
         coefficient = 100,
         originalnameref2 = "deed",

         param1 = 1,

         efid = 1115,

         color = { 255, 155, 155 },

         categories = {
            "elona.scroll",
            "elona.scroll_deed",
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

         param1 = Resolver.make("base.between", { min = 2, coefficient = 5 }),
         param2 = Resolver.make("elona.fruit_tree"),

         events = {
            {
               id = "base.on_build_item",
               name = "Generate fruit.",

               callback = function(self)
                  self.params = {
                     fruits = 5,
                     fruit_id = "elona.lemon"
                  }
               end
            },
            {
               id = "elona_sys.on_bash",
               name = "Fruit tree bash behavior",

               callback = function(self)
                  self = self:separate()
                  Gui.play_sound("base.bash1")
                  Gui.mes("action.bash.tree.execute", self)
                  local fruits = self:calc("params").fruits or 0
                  if self:calc("own_state") == "unobtainable" or fruits <= 0 then
                     Gui.mes("action.bash.tree.no_fruits")
                     return "turn_end"
                  end
                  self.params.fruits = self.params.fruits - 1
                  if self.params.fruits <= 0 then
                     self.image = "elona.item_tree_of_fruitless"
                  end

                  local x = self.x
                  local y = self.y
                  local map = self:current_map()
                  if y + 1 < map:height() and map:can_access(x, y + 1) then
                     y = y + 1
                  end
                  Item.create(self.params.fruit_id, x, y, {amount=0})

                  return "turn_end"
               end
            },
            {
               id = "base.on_regenerate",
               name = "Fruit tree restock",

               callback = function(self)
                  if self.params.fruits < 10 then
                     self.params.fruits = self.params.fruits + 1
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
         _id = "furnance",
         elona_id = 531,
         image = "elona.item_furnance",
         value = 8500,
         weight = 68000,
         level = 19,
         category = 60000,
         rarity = 100000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         },
         light = light.stove
      },
      {
         _id = "fireplace",
         elona_id = 532,
         image = "elona.item_fireplace",
         value = 9400,
         weight = 45000,
         level = 23,
         category = 60000,
         rarity = 100000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         },
         light = light.stove
      },
      {
         _id = "stove",
         elona_id = 533,
         image = "elona.item_stove",
         value = 7500,
         weight = 85000,
         level = 22,
         category = 60000,
         rarity = 100000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         },
         light = light.stove
      },
      {
         _id = "giant_foliage_plant",
         elona_id = 534,
         image = "elona.item_giant_foliage_plant",
         value = 4500,
         weight = 15000,
         level = 18,
         category = 60000,
         rarity = 200000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "big_table",
         elona_id = 535,
         image = "elona.item_big_table",
         value = 2400,
         weight = 5800,
         level = 5,
         category = 60000,
         rarity = 400000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "painting_of_madam",
         elona_id = 536,
         image = "elona.item_painting_of_madam",
         value = 8500,
         weight = 2000,
         level = 15,
         category = 60000,
         rarity = 100000,
         coefficient = 100,
         originalnameref2 = "painting",
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "painting_of_landscape",
         elona_id = 537,
         image = "elona.item_painting_of_landscape",
         value = 8200,
         weight = 500,
         level = 14,
         category = 60000,
         rarity = 100000,
         coefficient = 100,
         originalnameref2 = "painting",
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "painting_of_sunflower",
         elona_id = 538,
         image = "elona.item_painting_of_sunflower",
         value = 12000,
         weight = 450,
         level = 28,
         category = 60000,
         rarity = 50000,
         coefficient = 100,
         originalnameref2 = "painting",
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "statue_of_cat",
         elona_id = 539,
         image = "elona.item_statue_of_cat",
         value = 25000,
         weight = 48000,
         level = 30,
         category = 60000,
         rarity = 50000,
         coefficient = 100,
         originalnameref2 = "statue",
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "black_crystal",
         elona_id = 540,
         image = "elona.item_black_crystal",
         value = 7000,
         weight = 2500,
         level = 20,
         category = 60000,
         rarity = 500000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         },
         light = light.crystal
      },
      {
         _id = "snow_man",
         elona_id = 541,
         image = "elona.item_snow_man",
         value = 200,
         weight = 8500,
         category = 60000,
         rarity = 100000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         },
         light = light.item
      },
      {
         _id = "deed_of_farm",
         elona_id = 542,
         image = "elona.item_deed",
         value = 45000,
         weight = 500,
         on_read = function() end,
         fltselect = 1,
         category = 53000,
         subcategory = 53100,
         rarity = 1000,
         coefficient = 100,
         originalnameref2 = "deed",

         efid = 1115,

         color = { 225, 225, 255 },

         categories = {
            "elona.scroll",
            "elona.scroll_deed",
            "elona.no_generate"
         }
      },
      {
         _id = "deed_of_storage_house",
         elona_id = 543,
         image = "elona.item_deed",
         value = 10000,
         weight = 500,
         on_read = function() end,
         fltselect = 1,
         category = 53000,
         subcategory = 53100,
         rarity = 1000,
         coefficient = 100,
         originalnameref2 = "deed",

         efid = 1115,

         color = { 255, 225, 225 },

         categories = {
            "elona.scroll",
            "elona.scroll_deed",
            "elona.no_generate"
         }
      },
      {
         _id = "disc",
         elona_id = 544,
         image = "elona.item_playback_disc",
         value = 1000,
         weight = 500,
         on_use = function() end,
         category = 59000,
         rarity = 1500000,
         coefficient = 100,

         elona_function = 6,
         param1 = Resolver.make("elona.music_disc_id"),

         tags = { "sf" },
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.tag_sf",
            "elona.misc_item"
         },
         light = light.item
      },
      {
         _id = "rod_of_wall_creation",
         elona_id = 545,
         image = "elona.item_rod",
         value = 4000,
         weight = 800,
         chargelevel = 7,
         on_zap = function() end,
         level = 5,
         category = 56000,
         rarity = 800000,
         coefficient = 0,
         originalnameref2 = "rod",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 7 }),
         has_charge = true,

         efid = 438,
         efp = 100,
         categories = {
            "elona.rod"
         }
      },
      {
         _id = "spellbook_of_wall_creation",
         elona_id = 546,
         image = "elona.item_spellbook",
         value = 6800,
         weight = 380,
         chargelevel = 4,
         on_read = function() end,
         level = 4,
         category = 54000,
         rarity = 600000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 4 }),
         has_charge = true,

         efid = 438,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
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
         categories = {
            "elona.container",
            "elona.no_generate"
         }
      },
      {
         _id = "spellbook_of_healing_rain",
         elona_id = 548,
         image = "elona.item_spellbook",
         value = 9500,
         weight = 380,
         chargelevel = 3,
         on_read = function() end,
         level = 7,
         category = 54000,
         rarity = 300000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 3 }),
         has_charge = true,

         efid = 404,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "scroll_of_healing_rain",
         elona_id = 549,
         image = "elona.item_scroll",
         value = 3500,
         weight = 20,
         on_read = function() end,
         level = 12,
         category = 53000,
         rarity = 500000,
         coefficient = 0,
         originalnameref2 = "scroll",
         has_random_name = true,

         efid = 404,
         efp = 400,
         elona_type = "scroll",

         tags = { "noshop" },
         color = Resolver.make("elona.random_item_color"),
         categories = {
            "elona.scroll",
            "elona.tag_noshop"
         }
      },
      {
         _id = "spellbook_of_healing_hands",
         elona_id = 550,
         image = "elona.item_spellbook",
         value = 5800,
         weight = 380,
         chargelevel = 4,
         on_read = function() end,
         level = 5,
         category = 54000,
         rarity = 300000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 4 }),
         has_charge = true,

         efid = 405,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "rod_of_healing_hands",
         elona_id = 551,
         image = "elona.item_rod",
         value = 5600,
         weight = 800,
         chargelevel = 3,
         on_zap = function() end,
         level = 3,
         category = 56000,
         rarity = 800000,
         coefficient = 0,
         originalnameref2 = "rod",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 3 }),
         has_charge = true,

         efid = 405,
         efp = 100,
         categories = {
            "elona.rod"
         }
      },
      {
         _id = "feather",
         elona_id = 552,
         image = "elona.item_feather",
         value = 18000,
         weight = 500,
         pv = 6,
         dv = 4,
         material = "elona.metal",
         appearance = 4,
         level = 25,
         category = 20000,
         equip_slots = { "elona.back" },
         subcategory = 20001,
         rarity = 100000,
         coefficient = 100,
         enchantments = {
            { id = 32, power = 100 }
         },
         categories = {
            "elona.equip_back",
            "elona.equip_back_cloak"
         }
      },
      {
         _id = "gem_seed",
         elona_id = 553,
         image = "elona.item_seed",
         value = 4500,
         weight = 40,
         material = 41,
         on_use = function() end,
         category = 57000,
         subcategory = 58500,
         rarity = 250000,
         coefficient = 100,

         food_rank = 1,

         gods = { "elona.kumiromi" },

         color = { 185, 155, 215 },

         categories = {
            "elona.crop_seed",
            "elona.food"
         }
      },
      {
         _id = "magical_seed",
         elona_id = 554,
         image = "elona.item_seed",
         value = 3500,
         weight = 40,
         material = 42,
         on_use = function() end,
         category = 57000,
         subcategory = 58500,
         rarity = 250000,
         coefficient = 100,

         food_rank = 1,

         gods = { "elona.kumiromi" },

         color = { 155, 205, 205 },

         categories = {
            "elona.crop_seed",
            "elona.food"
         }
      },
      {
         _id = "shelter",
         elona_id = 555,
         image = "elona.item_shelter",
         value = 6500,
         weight = 12500,
         on_use = function() end,
         level = 5,
         category = 59000,
         rarity = 200000,
         coefficient = 100,

         elona_function = 7,

         prevent_sell_in_own_shop = true,

         categories = {
            "elona.misc_item"
         },

         light = light.item
      },
      {
         _id = "seven_league_boots",
         elona_id = 556,
         image = "elona.item_composite_boots",
         value = 24000,
         weight = 300,
         pv = 2,
         dv = 7,
         material = "elona.soft",
         appearance = 3,
         level = 30,
         category = 18000,
         equip_slots = { "elona.leg" },
         subcategory = 18002,
         rarity = 25000,
         coefficient = 100,
         enchantments = {
            { id = 29, power = 500 }
         },
         categories = {
            "elona.equip_leg_shoes",
            "elona.equip_leg"
         }
      },
      {
         _id = "vindale_cloak",
         elona_id = 557,
         image = "elona.item_light_cloak",
         value = 18000,
         weight = 400,
         pv = 3,
         dv = 7,
         material = "elona.soft",
         appearance = 1,
         level = 25,
         category = 20000,
         equip_slots = { "elona.back" },
         subcategory = 20001,
         rarity = 10000,
         coefficient = 100,
         enchantments = {
            { id = 30, power = 100 }
         },
         categories = {
            "elona.equip_back",
            "elona.equip_back_cloak"
         }
      },
      {
         _id = "aurora_ring",
         elona_id = 558,
         image = "elona.item_engagement_ring",
         value = 17000,
         weight = 50,
         pv = 2,
         dv = 2,
         material = "elona.metal",
         level = 15,
         category = 32000,
         equip_slots = { "elona.ring" },
         subcategory = 32001,
         rarity = 25000,
         coefficient = 100,
         has_random_name = true,
         enchantments = {
            { id = 31, power = 100 },
            { id = 20057, power = 100 }
         },
         categories = {
            "elona.equip_ring_ring",
            "elona.equip_ring"
         }
      },
      {
         _id = "potion_of_cure_corruption",
         elona_id = 559,
         image = "elona.item_potion",
         value = 100000,
         weight = 120,
         category = 52000,
         rarity = 30000,
         coefficient = 0,
         originalnameref2 = "potion",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         on_drink = Magic.drink_potion(1131, 200),
         medal_value = 10,
         categories = {
            "elona.drink",
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

         categories = {
            "elona.container",
            "elona.no_generate"
         }
      },
      {
         _id = "register",
         elona_id = 562,
         image = "elona.item_register",
         value = 1500,
         weight = 20000,
         on_use = function() end,
         fltselect = 1,
         category = 59000,
         coefficient = 100,

         elona_function = 8,

         prevent_sell_in_own_shop = true,

         categories = {
            "elona.no_generate",
            "elona.misc_item"
         }
      },
      {
         _id = "textbook",
         elona_id = 563,
         image = "elona.item_textbook",
         value = 4800,
         weight = 80,
         on_read = function() end,
         category = 55000,
         rarity = 50000,
         coefficient = 100,

         param1 = 0,

         elona_type = "normal_book",

         categories = {
            "elona.book"
         }
      },
      {
         _id = "spellbook_of_acid_ground",
         elona_id = 564,
         image = "elona.item_spellbook",
         value = 7500,
         weight = 380,
         chargelevel = 4,
         on_read = function() end,
         level = 8,
         category = 54000,
         rarity = 500000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 4 }),
         has_charge = true,

         efid = 455,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "rod_of_acid_ground",
         elona_id = 565,
         image = "elona.item_rod",
         value = 4400,
         weight = 800,
         chargelevel = 4,
         on_zap = function() end,
         level = 8,
         category = 56000,
         rarity = 800000,
         coefficient = 0,
         originalnameref2 = "rod",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 4 }),
         has_charge = true,

         efid = 455,
         efp = 100,
         categories = {
            "elona.rod"
         }
      },
      {
         _id = "acidproof_liquid",
         elona_id = 566,
         image = "elona.item_potion",
         value = 1900,
         weight = 120,
         category = 52000,
         rarity = 300000,
         coefficient = 100,
         has_random_name = true,

         on_drink = Magic.drink_potion(1116, 250),

         tags = { "nogive" },
         color = Resolver.make("elona.random_item_color"),
         categories = {
            "elona.drink",
            "elona.tag_nogive"
         }
      },
      {
         _id = "fireproof_blanket",
         elona_id = 567,
         image = "elona.item_blanket",
         value = 2400,
         weight = 800,
         chargelevel = 12,
         category = 59000,
         rarity = 500000,
         coefficient = 0,

         count = Resolver.make("elona.item_count", { count = 12 }),
         has_charge = true,

         color = { 255, 155, 155 },

         categories = {
            "elona.misc_item"
         }
      },
      {
         _id = "coldproof_blanket",
         elona_id = 568,
         image = "elona.item_blanket",
         value = 2400,
         weight = 800,
         chargelevel = 12,
         category = 59000,
         rarity = 500000,
         coefficient = 0,

         count = Resolver.make("elona.item_count", { count = 12 }),
         has_charge = true,

         color = { 175, 175, 255 },

         categories = {
            "elona.misc_item"
         }
      },
      {
         _id = "spellbook_of_fire_wall",
         elona_id = 569,
         image = "elona.item_spellbook",
         value = 5800,
         weight = 380,
         chargelevel = 4,
         on_read = function() end,
         level = 4,
         category = 54000,
         rarity = 500000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 4 }),
         has_charge = true,

         efid = 456,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "rod_of_fire_wall",
         elona_id = 570,
         image = "elona.item_rod",
         value = 3800,
         weight = 800,
         chargelevel = 4,
         on_zap = function() end,
         level = 4,
         category = 56000,
         rarity = 700000,
         coefficient = 0,
         originalnameref2 = "rod",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 4 }),
         has_charge = true,

         efid = 456,
         efp = 100,
         categories = {
            "elona.rod"
         }
      },
      {
         _id = "jerky",
         elona_id = 571,
         image = "elona.item_jerky",
         value = 640,
         weight = 450,
         level = 3,
         category = 57000,
         rarity = 200000,
         coefficient = 100,

         food_rank = 5,

         events = {
            {
               id = "elona_sys.on_item_eat",
               name = "egg effects",

               callback = function(self, params, result)
                  local chara = self.params.chara_id
                  if not chara then
                     return
                  end

                  local dat = data["base.chara"]:ensure(chara)

                  if dat.on_eat_corpse and Rand.one_in(3) then
                     dat:on_eat_corpse(self, params, result)
                  end

                  return result
               end
            },
         },

         categories = {
            "elona.food"
         }
      },
      {
         _id = "deed_of_ranch",
         elona_id = 572,
         image = "elona.item_deed",
         value = 80000,
         weight = 500,
         on_read = function() end,
         fltselect = 1,
         category = 53000,
         subcategory = 53100,
         rarity = 1000,
         coefficient = 100,
         originalnameref2 = "deed",

         efid = 1115,

         color = { 235, 215, 155 },

         categories = {
            "elona.scroll",
            "elona.scroll_deed",
            "elona.no_generate"
         }
      },
      {
         _id = "egg",
         elona_id = 573,
         image = "elona.item_egg",
         value = 500,
         weight = 300,
         expiration_date = 240,
         category = 57000,
         rarity = 300000,
         coefficient = 100,

         params = { chara_id = "" },

         param1 = 8000,
         param3 = 240,

         events = {
            {
               id = "elona_sys.on_item_eat",
               name = "egg effects",

               callback = function(self, params, result)
                  local chara = self.params.chara_id
                  if not chara then
                     return
                  end

                  local dat = data["base.chara"]:ensure(chara)

                  if dat.on_eat_corpse and Rand.one_in(3) then
                     dat:on_eat_corpse(self, params, result)
                  end

                  return result
               end
            },
         },

         categories = {
            "elona.food"
         }
      },
      {
         _id = "bottle_of_milk",
         elona_id = 574,
         image = "elona.item_bottle_of_milk",
         value = 1000,
         weight = 300,
         category = 52000,
         rarity = 300000,
         coefficient = 100,
         originalnameref2 = "bottle",

         params = { chara_id = "" },

         on_drink = Magic.drink_potion(1101, 100),
         categories = {
            "elona.drink",
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
         categories = {
            "elona.junk"
         }
      },
      {
         _id = "playback_disc",
         elona_id = 576,
         image = "elona.item_playback_disc",
         value = 1000,
         weight = 500,
         on_use = function() end,
         category = 59000,
         rarity = 200000,
         coefficient = 100,

         elona_function = 10,

         tags = { "sf" },
         color = { 255, 155, 155 },
         categories = {
            "elona.tag_sf",
            "elona.misc_item"
         },
         light = light.item
      },
      {
         _id = "molotov",
         elona_id = 577,
         image = "elona.item_molotov",
         value = 400,
         weight = 50,
         level = 10,
         category = 52000,
         coefficient = 0,
         has_random_name = true,

         on_drink = Magic.drink_potion(1133, 100),

         tags = { "nogive" },
         color = Resolver.make("elona.random_item_color"),
         categories = {
            "elona.drink",
            "elona.tag_nogive"
         }
      },
      {
         _id = "kitty_bank",
         elona_id = 578,
         image = "elona.item_kitty_bank",
         value = 1400,
         weight = 500,
         on_use = function() end,
         category = 59000,
         rarity = 300000,
         coefficient = 100,

         elona_function = 11,

         categories = {
            "elona.misc_item"
         },

         light = light.item
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
         categories = {
            "elona.container",
            "elona.no_generate"
         }
      },
      {
         _id = "modern_rack",
         elona_id = 580,
         image = "elona.item_modern_rack",
         value = 1600,
         weight = 10200,
         level = 12,
         category = 60000,
         rarity = 600000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "rod_of_make_door",
         elona_id = 581,
         image = "elona.item_rod",
         value = 2000,
         weight = 800,
         chargelevel = 6,
         on_zap = function() end,
         category = 56000,
         rarity = 500000,
         coefficient = 0,
         originalnameref2 = "rod",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 6 }),
         has_charge = true,

         efid = 457,
         efp = 100,
         categories = {
            "elona.rod"
         }
      },
      {
         _id = "spellbook_of_make_door",
         elona_id = 582,
         image = "elona.item_spellbook",
         value = 2000,
         weight = 380,
         chargelevel = 4,
         on_read = function() end,
         category = 54000,
         rarity = 400000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 4 }),
         has_charge = true,

         efid = 457,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "torch",
         elona_id = 583,
         image = "elona.item_torch",
         value = 200,
         weight = 150,
         category = 59000,
         coefficient = 100,

         elona_function = 13,
         param1 = 100,
         categories = {
            "elona.misc_item"
         },
         light = light.torch,

         on_use = function(self)
            if self.is_light_source then
               Gui.mes("action.use.torch.put_out")
               self.is_light_source = false
            else
               Gui.mes("action.use.torch.light")
               self.is_light_source = true
            end
         end
      },
      {
         _id = "candle",
         elona_id = 584,
         image = "elona.item_candle",
         value = 1500,
         weight = 200,
         category = 60000,
         rarity = 250000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         },
         light = light.candle
      },
      {
         _id = "fancy_lamp",
         elona_id = 585,
         image = "elona.item_fancy_lamp",
         value = 4500,
         weight = 1500,
         level = 20,
         category = 60000,
         rarity = 200000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         },
         light = light.lamp
      },
      {
         _id = "modern_lamp_a",
         elona_id = 586,
         image = "elona.item_modern_lamp_a",
         value = 7200,
         weight = 250000,
         level = 30,
         category = 60000,
         rarity = 200000,
         coefficient = 100,
         tags = { "sf" },
         categories = {
            "elona.tag_sf",
            "elona.furniture"
         },
         light = light.port_light
      },
      {
         _id = "handful_of_snow",
         elona_id = 587,
         image = "elona.item_handful_of_snow",
         value = 10,
         weight = 50,
         category = 52000,
         rarity = 100000,
         coefficient = 100,
         originalnameref2 = "handful",

         elona_function = 14,

         on_drink = Magic.drink_potion(1103, 100),
         categories = {
            "elona.drink",
         },
         light = light.item
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
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.junk"
         }
      },
      {
         _id = "mini_snow_man",
         elona_id = 591,
         image = "elona.item_mini_snow_man",
         value = 400,
         weight = 8500,
         category = 60000,
         rarity = 100000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         },
         light = light.item
      },
      {
         _id = "snow_barrel",
         elona_id = 592,
         image = "elona.item_snow_barrel",
         value = 180,
         weight = 3400,
         category = 60000,
         rarity = 100000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "modern_lamp_b",
         elona_id = 593,
         image = "elona.item_modern_lamp_b",
         value = 7200,
         weight = 250000,
         level = 30,
         category = 60000,
         rarity = 100000,
         coefficient = 100,
         tags = { "sf" },
         categories = {
            "elona.tag_sf",
            "elona.furniture"
         },
         light = light.port_light_snow
      },
      {
         _id = "statue_of_holy_cross",
         elona_id = 594,
         image = "elona.item_statue_of_holy_cross",
         value = 18000,
         weight = 12000,
         level = 40,
         category = 60000,
         rarity = 50000,
         coefficient = 100,
         originalnameref2 = "statue",
         categories = {
            "elona.furniture"
         },
         light = light.port_light_snow
      },
      {
         _id = "pillar",
         elona_id = 595,
         image = "elona.item_pillar",
         value = 2500,
         weight = 16000,
         level = 20,
         category = 60000,
         rarity = 200000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "stained_glass_window",
         elona_id = 596,
         image = "elona.item_stained_glass_window",
         value = 1800,
         weight = 4800,
         level = 10,
         category = 60000,
         rarity = 100000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         },
         light = light.item
      },
      {
         _id = "cargo_christmas_tree",
         elona_id = 597,
         image = "elona.item_christmas_tree",
         value = 3500,
         weight = -60000,
         is_cargo = true,
         category = 92000,
         rarity = 600000,
         coefficient = 100,

         param1 = 6,

         categories = {
            "elona.cargo"
         },

         light = light.crystal_high
      },
      {
         _id = "cargo_snow_man",
         elona_id = 598,
         image = "elona.item_snow_man",
         value = 1200,
         weight = -11000,
         is_cargo = true,
         category = 92000,
         rarity = 800000,
         coefficient = 100,

         param1 = 6,

         categories = {
            "elona.cargo"
         },

         light = light.item
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

         categories = {
            "elona.container",
            "elona.no_generate"
         },

         light = light.item
      },
      {
         _id = "empty_bottle",
         elona_id = 601,
         image = "elona.item_empty_bottle",
         value = 100,
         weight = 120,
         category = 52000,
         rarity = 800000,
         coefficient = 100,
         categories = {
            "elona.drink",
         }
      },
      {
         _id = "holy_well",
         elona_id = 602,
         image = "elona.item_holy_well",
         value = 185000,
         weight = 350000,
         fltselect = 1,
         category = 60001,
         subcategory = 60001,
         rarity = 50000,
         coefficient = 100,

         param2 = 100,
         params = {
            count_1 = 0,
            count_2 = 0,
         },

         on_drink = Magic.drink_well,
         elona_type = "well",

         categories = {
            "elona.furniture_well",
            "elona.no_generate"
         },

         light = light.item
      },
      {
         _id = "presidents_chair",
         elona_id = 603,
         image = "elona.item_presidents_chair",
         value = 12000,
         weight = 2400,
         level = 35,
         category = 60000,
         rarity = 10000,
         coefficient = 100,

         elona_function = 44,
         is_precious = true,
         medal_value = 20,
         categories = {
            "elona.furniture"
         },
         light = light.item
      },
      {
         _id = "green_plant",
         elona_id = 604,
         image = "elona.item_green_plant",
         value = 400,
         weight = 800,
         category = 60000,
         rarity = 500000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "money_tree",
         elona_id = 605,
         image = "elona.item_money_tree",
         value = 2200,
         weight = 1200,
         level = 15,
         category = 60000,
         rarity = 400000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "barbecue_set",
         elona_id = 606,
         image = "elona.item_barbecue_set",
         value = 9500,
         weight = 8250,
         level = 25,
         category = 60000,
         rarity = 150000,
         coefficient = 100,

         elona_function = 15,
         param1 = 225,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "giant_cactus",
         elona_id = 607,
         image = "elona.item_giant_cactus",
         value = 2600,
         weight = 4200,
         category = 60000,
         rarity = 300000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "square_window",
         elona_id = 608,
         image = "elona.item_square_window",
         value = 500,
         weight = 1500,
         category = 60000,
         rarity = 600000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         },
         light = light.window
      },
      {
         _id = "window",
         elona_id = 609,
         image = "elona.item_window",
         value = 700,
         weight = 1600,
         category = 60000,
         rarity = 500000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         },
         light = light.window
      },
      {
         _id = "triangle_plant",
         elona_id = 610,
         image = "elona.item_triangle_plant",
         value = 1500,
         weight = 5600,
         level = 18,
         category = 60000,
         rarity = 600000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "house_board",
         elona_id = 611,
         image = "elona.item_house_board",
         value = 3500,
         weight = 1200,
         category = 59000,
         rarity = 50000,
         coefficient = 100,

         elona_function = 8,

         categories = {
            "elona.misc_item"
         }
      },
      {
         _id = "nice_window",
         elona_id = 612,
         image = "elona.item_nice_window",
         value = 1000,
         weight = 2000,
         category = 60000,
         rarity = 400000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         },
         light = light.window
      },
      {
         _id = "kings_bed",
         elona_id = 613,
         image = "elona.item_bait",
         value = 35000,
         weight = 24000,
         on_use = function() end,
         level = 50,
         category = 60000,
         subcategory = 60004,
         rarity = 50000,
         coefficient = 100,

         param1 = 180,

         categories = {
            "elona.furniture_bed",
            "elona.furniture"
         }
      },
      {
         _id = "flower_arch",
         elona_id = 614,
         image = "elona.item_flower_arch",
         value = 2000,
         weight = 8000,
         level = 15,
         category = 60000,
         rarity = 400000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "bill",
         elona_id = 615,
         image = "elona.item_bill",
         value = 100,
         weight = 100,
         fltselect = 1,
         category = 53000,
         rarity = 400000,
         coefficient = 100,

         _copy = {
            identify_state = "completely",
            curse_state = "none"
         },

         is_precious = true,

         medal_value = 5,

         categories = {
            "elona.scroll",
            "elona.no_generate"
         }
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
         image = "elona.item_bait",
         value = 1000,
         weight = 250,
         fltselect = 1,
         category = 64000,
         coefficient = 100,

         on_calc_dip_targets = function(self)
            return {}
         end,

         params = { bait_rank = 0 },

         on_generate = function()
            self.params.bait_rank = Rand.rnd(6)
            self.image = "elona.item_bait"
            self.value = self.params.bait_rank * self.params.bait_rank * 500 + 200
         end,

         categories = {
            "elona.no_generate",
            "elona.junk"
         }
      },
      {
         _id = "fish_a",
         elona_id = 618,
         image = "elona.item_fish",
         value = 1200,
         weight = 1250,
         material = "elona.fresh",
         expiration_date = 4,
         level = 15,
         fltselect = 1,
         category = 57000,
         rarity = 300000,
         coefficient = 100,

         param1 = 6000,
         param3 = 4,

         gods = { "elona.ehekatl" },

         rftags = { "fish" },

         categories = {
            "elona.no_generate",
            "elona.food"
         }
      },
      {
         _id = "fish_b",
         elona_id = 619,
         image = "elona.item_fish",
         value = 1200,
         weight = 1250,
         level = 15,
         fltselect = 1,
         category = 64000,
         rarity = 300000,
         coefficient = 100,
         categories = {
            "elona.no_generate",
            "elona.junk"
         }
      },
      {
         _id = "love_potion",
         elona_id = 620,
         image = "elona.item_potion",
         value = 4500,
         weight = 50,
         level = 5,
         category = 52000,
         rarity = 150000,
         coefficient = 0,

         on_drink = Magic.drink_potion(1135, 100),

         tags = { "nogive" },

         categories = {
            "elona.drink",
            "elona.tag_nogive"
         }
      },
      {
         _id = "treasure_map",
         elona_id = 621,
         image = "elona.item_treasure_map",
         value = 10000,
         weight = 20,
         on_read = function() end,
         level = 5,
         category = 53000,
         rarity = 100000,
         coefficient = 100,

         efid = 1136,
         efp = 100,
         elona_type = "scroll",

         can_read_in_world_map = true,

         tags = { "noshop", "spshop" },

         categories = {
            "elona.scroll",
            "elona.tag_noshop",
            "elona.tag_spshop"
         }
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

         _copy = {
            identify_state = "completely",
            curse_state = "none"
         },

         tags = { "noshop" },
         rftags = { "ore" },
         categories = {
            "elona.tag_noshop",
            "elona.ore"
         }
      },
      {
         _id = "cat_sisters_diary",
         elona_id = 623,
         image = "elona.item_spellbook",
         value = 15000,
         weight = 380,
         on_read = function() end,
         level = 15,
         category = 55000,
         rarity = 1000,
         coefficient = 0,
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         is_precious = true,

         efid = 1138,
         efp = 100,
         elona_type = "scroll",
         medal_value = 85,
         categories = {
            "elona.book"
         }
      },
      {
         _id = "girls_diary",
         elona_id = 624,
         image = "elona.item_spellbook",
         value = 10000,
         weight = 380,
         on_read = function() end,
         level = 5,
         category = 55000,
         rarity = 5000,
         coefficient = 0,
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         is_precious = true,

         efid = 1137,
         efp = 100,
         elona_type = "scroll",
         medal_value = 25,
         categories = {
            "elona.book"
         }
      },
      {
         _id = "shrine_gate",
         elona_id = 625,
         image = "elona.item_shrine_gate",
         value = 7500,
         weight = 8000,
         fltselect = 1,
         category = 60000,
         rarity = 10000,
         coefficient = 100,

         is_precious = true,

         medal_value = 11,

         categories = {
            "elona.no_generate",
            "elona.furniture"
         }
      },
      {
         _id = "bottle_of_hermes_blood",
         elona_id = 626,
         image = "elona.item_potion",
         value = 50000,
         weight = 120,
         level = 15,
         category = 52000,
         rarity = 10000,
         coefficient = 100,
         originalnameref2 = "bottle",
         has_random_name = true,

         is_precious = true,

         on_drink = Magic.drink_potion(1139, 500),

         tags = { "spshop" },
         color = Resolver.make("elona.random_item_color"),
         medal_value = 30,
         categories = {
            "elona.drink",
            "elona.tag_spshop"
         }
      },
      {
         _id = "sages_helm",
         elona_id = 627,
         image = "elona.item_knight_helm",
         value = 40000,
         weight = 1500,
         pv = 15,
         dv = 4,
         material = "elona.mithril",
         level = 20,
         fltselect = 3,
         category = 12000,
         equip_slots = { "elona.head" },
         subcategory = 12001,
         coefficient = 100,

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",

         color = { 255, 215, 175 },

         enchantments = {
            { id = 25, power = 100 },
            { id = 35, power = 100 },
            { id = 10016, power = 200 },
            { id = 20054, power = 250 },
            { id = 20060, power = 150 },
            { id = 30161, power = 300 }
         },

         medal_value = 55,

         categories = {
            "elona.equip_head_helm",
            "elona.unique_item",
            "elona.equip_head"
         },

         light = light.item
      },
      {
         _id = "spellbook_of_incognito",
         elona_id = 628,
         image = "elona.item_spellbook",
         value = 7000,
         weight = 380,
         chargelevel = 4,
         on_read = function() end,
         level = 10,
         category = 54000,
         rarity = 200000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 4 }),
         has_charge = true,

         efid = 458,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "disguise_set",
         elona_id = 629,
         image = "elona.item_disguise_set",
         value = 7200,
         weight = 3500,
         chargelevel = 4,
         on_use = function() end,
         level = 5,
         category = 59000,
         rarity = 100000,
         coefficient = 0,

         elona_function = 20,
         count = Resolver.make("elona.item_count", { count = 4 }),
         has_charge = true,
         categories = {
            "elona.misc_item"
         }
      },
      {
         _id = "material_kit",
         elona_id = 630,
         image = "elona.item_material_kit",
         value = 2500,
         weight = 5000,
         on_use = function() end,
         category = 59000,
         rarity = 5000,
         coefficient = 0,

         elona_function = 21,

         tags = { "noshop", "spshop" },

         categories = {
            "elona.tag_noshop",
            "elona.tag_spshop",
            "elona.misc_item"
         }
      },
      {
         _id = "moon_gate",
         elona_id = 631,
         image = "elona.item_moon_gate",
         value = 50,
         weight = 5000000,
         level = 15,
         fltselect = 1,
         category = 60000,
         rarity = 400000,
         coefficient = 100,
         categories = {
            "elona.no_generate",
            "elona.furniture"
         },
         light = light.gate
      },
      {
         _id = "flying_scroll",
         elona_id = 632,
         image = "elona.item_scroll",
         value = 40000,
         weight = 5,
         on_read = function() end,
         category = 53000,
         rarity = 25000,
         coefficient = 0,
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         efid = 1140,
         efp = 150,
         elona_type = "scroll",
         categories = {
            "elona.scroll",
         }
      },
      {
         _id = "panty",
         elona_id = 633,
         image = "elona.item_panty",
         value = 25000,
         weight = 500,
         dice_x = 1,
         dice_y = 35,
         material = "elona.soft",
         level = 5,
         category = 24000,
         equip_slots = { "elona.ranged" },
         subcategory = 24030,
         rarity = 10000,
         coefficient = 100,

         skill = "elona.throwing",
         effective_range = { 50, 100, 50, 20, 20, 20, 20, 20, 20, 20 },pierce_rate = 5,
         enchantments = {
            { id = 70054, power = 800 }
         },
         categories = {
            "elona.equip_ranged_thrown",
            "elona.equip_ranged"
         }
      },
      {
         _id = "leash",
         elona_id = 634,
         image = "elona.item_leash",
         value = 1200,
         weight = 1200,
         on_use = function() end,
         category = 59000,
         rarity = 500000,
         coefficient = 0,

         elona_function = 23,

         categories = {
            "elona.misc_item"
         }
      },
      {
         _id = "mine",
         elona_id = 635,
         image = "elona.item_mine",
         value = 7500,
         weight = 9800,
         on_use = function() end,
         level = 10,
         category = 59000,
         rarity = 250000,
         coefficient = 0,

         elona_function = 24,

         tags = { "spshop" },

         categories = {
            "elona.tag_spshop",
            "elona.misc_item"
         }
      },
      {
         _id = "lockpick",
         elona_id = 636,
         image = "elona.item_lockpick",
         value = 800,
         weight = 400,
         category = 59000,
         rarity = 2000000,
         coefficient = 0,
         categories = {
            "elona.misc_item"
         }
      },
      {
         _id = "skeleton_key",
         elona_id = 637,
         image = "elona.item_skeleton_key",
         value = 150000,
         weight = 400,
         level = 20,
         fltselect = 2,
         category = 59000,
         rarity = 10000,
         coefficient = 100,

         is_precious = true,
         fixlv = "special",
         categories = {
            "elona.unique_weapon",
            "elona.misc_item"
         }
      },
      {
         _id = "scroll_of_escape",
         elona_id = 638,
         image = "elona.item_scroll",
         value = 450,
         weight = 20,
         on_read = function() end,
         category = 53000,
         rarity = 500000,
         coefficient = 0,
         originalnameref2 = "scroll",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         efid = 1141,
         efp = 100,
         elona_type = "scroll",
         categories = {
            "elona.scroll",
         }
      },
      {
         _id = "happy_apple",
         elona_id = 639,
         image = "elona.item_happy_apple",
         value = 100000,
         weight = 720,
         fltselect = 3,
         category = 57000,
         subcategory = 57004,
         coefficient = 100,

         is_precious = true,
         food_rank = 7,
         fixlv = "special",

         color = { 225, 225, 255 },

         categories = {
            "elona.food_fruit",
            "elona.unique_item",
            "elona.food"
         }
      },
      {
         _id = "unicorn_horn",
         elona_id = 640,
         image = "elona.item_unicorn_horn",
         value = 8000,
         weight = 2000,
         category = 59000,
         rarity = 40000,
         coefficient = 0,

         elona_function = 25,

         tags = { "noshop", "spshop" },

         categories = {
            "elona.tag_noshop",
            "elona.tag_spshop",
            "elona.misc_item"
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

         is_precious = true,
         fixlv = "special",
         categories = {
            "elona.container",
            "elona.unique_item"
         }
      },
      {
         _id = "rice_barrel",
         elona_id = 642,
         image = "elona.item_rice_barrel",
         value = 500,
         weight = 4800,
         category = 60000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "eastern_bed",
         elona_id = 643,
         image = "elona.item_eastern_bed",
         value = 2500,
         weight = 2000,
         on_use = function() end,
         category = 59000,
         subcategory = 60004,
         rarity = 200000,
         coefficient = 0,

         param1 = 130,

         categories = {
            "elona.furniture_bed",
            "elona.misc_item"
         }
      },
      {
         _id = "decorated_window",
         elona_id = 644,
         image = "elona.item_decorated_window",
         value = 2400,
         weight = 2000,
         category = 60000,
         rarity = 200000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         },
         light = light.window
      },
      {
         _id = "king_drawer",
         elona_id = 645,
         image = "elona.item_king_drawer",
         value = 9500,
         weight = 11000,
         level = 35,
         category = 60000,
         rarity = 100000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "menu_board",
         elona_id = 646,
         image = "elona.item_menu_board",
         value = 1800,
         weight = 4500,
         level = 5,
         category = 60000,
         rarity = 500000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "black_board",
         elona_id = 647,
         image = "elona.item_black_board",
         value = 5000,
         weight = 7800,
         level = 18,
         category = 60000,
         rarity = 200000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "sofa",
         elona_id = 648,
         image = "elona.item_sofa",
         value = 2500,
         weight = 5000,
         level = 5,
         category = 60000,
         rarity = 250000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },

         elona_function = 44,

         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "flowerbed",
         elona_id = 649,
         image = "elona.item_flowerbed",
         value = 1500,
         weight = 4000,
         level = 10,
         category = 60000,
         rarity = 500000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "toilet",
         elona_id = 650,
         image = "elona.item_toilet",
         value = 1000,
         weight = 12000,
         level = 4,
         category = 60001,
         subcategory = 60001,
         rarity = 500000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },

         params = {
            count_1 = 0,
            count_2 = 0,
         },

         on_drink = Magic.drink_well,
         elona_type = "well",

         categories = {
            "elona.furniture_well"
         }
      },
      {
         _id = "craft_cupboard",
         elona_id = 651,
         image = "elona.item_craft_cupboard",
         value = 4800,
         weight = 8400,
         level = 25,
         category = 60000,
         rarity = 100000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "sink",
         elona_id = 652,
         image = "elona.item_sink",
         value = 3500,
         weight = 15000,
         level = 15,
         category = 60000,
         rarity = 500000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "junk",
         elona_id = 653,
         image = "elona.item_junk",
         value = 600,
         weight = 150000,
         category = 60000,
         rarity = 100000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "double_bed",
         elona_id = 654,
         image = "elona.item_luxury_bed",
         value = 7500,
         weight = 16000,
         on_use = function() end,
         level = 40,
         category = 60000,
         subcategory = 60004,
         rarity = 250000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },

         param1 = 160,

         categories = {
            "elona.furniture_bed",
            "elona.furniture"
         }
      },
      {
         _id = "hero_cheese",
         elona_id = 655,
         image = "elona.item_hero_cheese",
         value = 100000,
         weight = 500,
         fltselect = 3,
         category = 57000,
         coefficient = 100,

         is_precious = true,
         food_rank = 7,
         fixlv = "special",

         color = { 175, 175, 255 },

         categories = {
            "elona.unique_item",
            "elona.food"
         }
      },
      {
         _id = "eastern_lamp",
         elona_id = 656,
         image = "elona.item_eastern_lamp",
         value = 3000,
         weight = 7900,
         level = 12,
         category = 60000,
         rarity = 500000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         },
         light = light.candle_low
      },
      {
         _id = "eastern_window",
         elona_id = 657,
         image = "elona.item_eastern_window",
         value = 3500,
         weight = 1200,
         level = 14,
         category = 60000,
         rarity = 500000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         },
         light = light.window
      },
      {
         _id = "chochin",
         elona_id = 658,
         image = "elona.item_chochin",
         value = 2500,
         weight = 500,
         level = 14,
         category = 60000,
         rarity = 500000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         },
         light = light.window_red
      },
      {
         _id = "partition",
         elona_id = 659,
         image = "elona.item_partition",
         value = 1000,
         weight = 1000,
         level = 5,
         category = 60000,
         rarity = 800000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "spellbook_of_darkness_arrow",
         elona_id = 660,
         image = "elona.item_spellbook",
         value = 3500,
         weight = 380,
         chargelevel = 5,
         on_read = function() end,
         level = 5,
         category = 54000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 5 }),
         has_charge = true,

         efid = 418,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "dal_i_thalion",
         elona_id = 661,
         image = "elona.item_tight_boots",
         value = 25000,
         weight = 650,
         pv = 7,
         dv = 16,
         material = "elona.leather",
         appearance = 2,
         level = 15,
         fltselect = 3,
         category = 18000,
         equip_slots = { "elona.leg" },
         subcategory = 18002,
         coefficient = 100,

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",

         color = { 255, 155, 155 },

         enchantments = {
            { id = 43, power = 100 },
            { id = 29, power = 100 },
            { id = 10012, power = 250 },
            { id = 30182, power = 200 }
         },

         categories = {
            "elona.equip_leg_shoes",
            "elona.unique_item",
            "elona.equip_leg"
         },

         light = light.item
      },
      {
         _id = "magic_fruit",
         elona_id = 662,
         image = "elona.item_magic_fruit",
         value = 100000,
         weight = 440,
         fltselect = 3,
         category = 57000,
         subcategory = 57004,
         coefficient = 100,

         is_precious = true,
         food_rank = 7,
         fixlv = "special",

         color = { 255, 155, 155 },

         categories = {
            "elona.food_fruit",
            "elona.unique_item",
            "elona.food"
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
         fixlv = "special",
         categories = {
            "elona.unique_item",
            "elona.junk"
         },
         light = light.item
      },
      {
         _id = "speed_ring",
         elona_id = 664,
         image = "elona.item_engagement_ring",
         value = 50000,
         weight = 50,
         material = "elona.metal",
         level = 15,
         category = 32000,
         equip_slots = { "elona.ring" },
         subcategory = 32001,
         rarity = 30000,
         coefficient = 100,
         has_random_name = true,

         params = { min_power = 400, coefficient = 1000 },

         on_generate = function(self)
            local Rand = require("api.Rand")
            local power = self.params.min_power + Rand.rnd(Rand.rnd(self.params.coefficient) + 1)
            self:add_enchantment("base.mod_skill", { power = power })
         end,

         categories = {
            "elona.equip_ring_ring",
            "elona.equip_ring"
         }
      },
      {
         _id = "statue_of_opatos",
         elona_id = 665,
         image = "elona.item_statue_of_opatos",
         value = 100000,
         weight = 15000,
         expiration_date = 240,
         fltselect = 3,
         category = 59000,
         rarity = 800000,
         coefficient = 100,
         originalnameref2 = "statue",

         elona_function = 26,
         is_precious = true,
         has_cooldown_time = true,
         param3 = 240,
         fixlv = "special",
         categories = {
            "elona.unique_item",
            "elona.misc_item"
         }
      },
      {
         _id = "statue_of_lulwy",
         elona_id = 666,
         image = "elona.item_statue_of_lulwy",
         value = 100000,
         weight = 14000,
         expiration_date = 120,
         fltselect = 3,
         category = 59000,
         rarity = 800000,
         coefficient = 100,
         originalnameref2 = "statue",

         elona_function = 27,
         is_precious = true,
         has_cooldown_time = true,
         param3 = 120,
         fixlv = "special",
         categories = {
            "elona.unique_item",
            "elona.misc_item"
         }
      },
      {
         _id = "sisters_love_fueled_lunch",
         elona_id = 667,
         image = "elona.item_gift",
         value = 900,
         weight = 500,
         level = 3,
         fltselect = 1,
         category = 57000,
         rarity = 250000,
         coefficient = 100,

         is_handmade = true,

         food_rank = 7,

         categories = {
            "elona.no_generate",
            "elona.food"
         }
      },
      {
         _id = "book_of_rachel",
         elona_id = 668,
         image = "elona.item_book",
         value = 4000,
         weight = 80,
         on_read = function() end,
         category = 55000,
         rarity = 50000,
         coefficient = 0,

         param1 = 1,
         param2 = Resolver.make("base.between", { min = 1, coefficient = 4 }),

         elona_type = "normal_book",

         tags = { "noshop" },

         categories = {
            "elona.book",
            "elona.tag_noshop"
         }
      },
      {
         _id = "cargo_art",
         elona_id = 669,
         image = "elona.item_painting_of_landscape",
         value = 3800,
         weight = -35000,
         is_cargo = true,
         category = 92000,
         rarity = 150000,
         coefficient = 100,

         param1 = 7,

         categories = {
            "elona.cargo"
         }
      },
      {
         _id = "cargo_canvas",
         elona_id = 670,
         image = "elona.item_canvas",
         value = 750,
         weight = -7000,
         is_cargo = true,
         category = 92000,
         coefficient = 100,

         param1 = 7,

         categories = {
            "elona.cargo"
         }
      },
      {
         _id = "nuclear_bomb",
         elona_id = 671,
         image = "elona.item_mine",
         value = 10000,
         weight = 120000,
         on_use = function() end,
         level = 10,
         fltselect = 3,
         category = 59000,
         rarity = 250000,
         coefficient = 0,

         elona_function = 28,
         is_precious = true,
         fixlv = "special",
         categories = {
            "elona.unique_item",
            "elona.misc_item"
         }
      },
      {
         _id = "secret_treasure",
         elona_id = 672,
         image = "elona.item_secret_treasure",
         value = 5000,
         weight = 1000,
         fltselect = 3,
         category = 59000,
         rarity = 800000,
         coefficient = 100,

         elona_function = 29,
         is_precious = true,
         fixlv = "special",
         categories = {
            "elona.unique_item",
            "elona.misc_item"
         }
      },
      {
         _id = "wind_bow",
         elona_id = 673,
         image = "elona.item_long_bow",
         value = 35000,
         weight = 800,
         dice_x = 2,
         dice_y = 23,
         hit_bonus = 4,
         damage_bonus = 11,
         material = "elona.ether",
         level = 60,
         fltselect = 3,
         category = 24000,
         equip_slots = { "elona.ranged" },
         subcategory = 24001,
         coefficient = 100,

         skill = "elona.bow",

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",

         color = { 225, 225, 255 },

         effective_range = { 50, 90, 100, 90, 80, 80, 70, 60, 50, 20 },
         pierce_rate = 20,
         enchantments = {
            { id = 80014, power = 200 },
            { id = 80005, power = 200 },
            { id = 10018, power = 250 },
            { id = 20052, power = 300 }
         },
         categories = {
            "elona.equip_ranged_bow",
            "elona.unique_item",
            "elona.equip_ranged"
         },
         light = light.item
      },
      {
         _id = "winchester_premium",
         elona_id = 674,
         image = "elona.item_shot_gun",
         value = 35000,
         weight = 2800,
         dice_x = 8,
         dice_y = 9,
         hit_bonus = 7,
         damage_bonus = 2,
         material = "elona.diamond",
         level = 60,
         fltselect = 3,
         category = 24000,
         equip_slots = { "elona.ranged" },
         subcategory = 24020,
         coefficient = 100,

         skill = "elona.firearm",

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",

         color = { 255, 155, 155 },

         effective_range = { 100, 40, 20, 20, 20, 20, 20, 20, 20, 20 },
         pierce_rate = 30,
         enchantments = {
            { id = 80017, power = 350 },
            { id = 43, power = 200 },
            { id = 30110, power = 450 },
            { id = 20057, power = 350 }
         },
         categories = {
            "elona.equip_ranged_gun",
            "elona.unique_item",
            "elona.equip_ranged"
         },
         light = light.item
      },
      {
         _id = "kumiromi_scythe",
         elona_id = 675,
         image = "elona.item_scythe",
         value = 35000,
         weight = 850,
         dice_x = 1,
         dice_y = 38,
         hit_bonus = 5,
         damage_bonus = 2,
         material = "elona.spirit",
         level = 60,
         fltselect = 3,
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10011,
         coefficient = 100,

         skill = "elona.scythe",

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",

         color = { 175, 255, 175 },
         pierce_rate = 15,
         enchantments = {
            { id = 30184, power = 600 },
            { id = 42, power = 100 },
            { id = 30180, power = 1100 },
            { id = 30163, power = 800 },
            { id = 10010, power = 550 },
            { id = 20059, power = 400 },
            { id = 80025, power = 100 }
         },
         categories = {
            "elona.equip_melee_scythe",
            "elona.unique_item",
            "elona.equip_melee"
         },
         light = light.item
      },
      {
         _id = "elemental_staff",
         elona_id = 676,
         image = "elona.item_staff",
         value = 35000,
         weight = 900,
         dice_x = 1,
         dice_y = 14,
         hit_bonus = 6,
         damage_bonus = 2,
         pv = 4,
         dv = 11,
         material = "elona.obsidian",
         level = 60,
         fltselect = 3,
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10006,
         coefficient = 100,

         skill = "elona.stave",

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",

         color = { 215, 255, 215 },

         enchantments = {
            { id = 80000, power = 400 },
            { id = 70050, power = 350 },
            { id = 70051, power = 350 },
            { id = 70052, power = 350 },
            { id = 20050, power = 250 },
            { id = 20051, power = 250 },
            { id = 20052, power = 250 }
         },

         categories = {
            "elona.equip_melee_staff",
            "elona.unique_item",
            "elona.equip_melee"
         },

         light = light.item
      },
      {
         _id = "holy_lance",
         elona_id = 677,
         image = "elona.item_holy_lance",
         value = 35000,
         weight = 4400,
         dice_x = 7,
         dice_y = 5,
         hit_bonus = 12,
         damage_bonus = 11,
         dv = 4,
         material = "elona.silver",
         level = 60,
         fltselect = 3,
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10007,
         coefficient = 100,

         skill = "elona.polearm",

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",
         pierce_rate = 30,
         enchantments = {
            { id = 80023, power = 350 },
            { id = 80012, power = 450 },
            { id = 10015, power = 650 },
            { id = 20053, power = 200 },
            { id = 20056, power = 150 }
         },
         categories = {
            "elona.equip_melee_lance",
            "elona.unique_item",
            "elona.equip_melee"
         },
         light = light.item
      },
      {
         _id = "lucky_dagger",
         elona_id = 678,
         image = "elona.item_dagger",
         value = 35000,
         weight = 400,
         dice_x = 4,
         dice_y = 6,
         hit_bonus = 13,
         damage_bonus = 18,
         pv = 13,
         dv = 18,
         material = "elona.mica",
         level = 60,
         fltselect = 3,
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10003,
         coefficient = 100,

         skill = "elona.short_sword",

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",

         color = { 255, 215, 175 },
         pierce_rate = 10,
         enchantments = {
            { id = 41, power = 100 },
            { id = 35, power = 100 },
            { id = 10019, power = 1500 },
            { id = 36, power = 400 },
            { id = 30185, power = 600 }
         },
         categories = {
            "elona.equip_melee_short_sword",
            "elona.unique_item",
            "elona.equip_melee"
         },
         light = light.item
      },
      {
         _id = "gaia_hammer",
         elona_id = 679,
         image = "elona.item_hammer",
         value = 35000,
         weight = 6500,
         dice_x = 2,
         dice_y = 30,
         hit_bonus = -3,
         damage_bonus = 2,
         material = "elona.adamantium",
         level = 60,
         fltselect = 3,
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10005,
         coefficient = 100,

         skill = "elona.blunt",

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",

         color = { 255, 215, 175 },

         enchantments = {
            { id = 39, power = 350 },
            { id = 80013, power = 500 },
            { id = 10010, power = 600 },
            { id = 30167, power = 450 },
            { id = 20054, power = 400 }
         },

         categories = {
            "elona.equip_melee_hammer",
            "elona.unique_item",
            "elona.equip_melee"
         },

         light = light.item
      },
      {
         _id = "lulwys_gem_stone_of_god_speed",
         elona_id = 680,
         image = "elona.item_gemstone",
         value = 50000,
         weight = 1200,
         expiration_date = 12,
         fltselect = 3,
         category = 59000,
         rarity = 800000,
         coefficient = 100,
         originalnameref2 = "Lulwy's gem stone",

         elona_function = 30,
         is_precious = true,
         has_cooldown_time = true,
         param1 = 446,
         param2 = 300,
         param3 = 12,
         fixlv = "special",

         color = { 175, 175, 255 },

         categories = {
            "elona.unique_item",
            "elona.misc_item"
         }
      },
      {
         _id = "jures_gem_stone_of_holy_rain",
         elona_id = 681,
         image = "elona.item_gemstone",
         value = 50000,
         weight = 1200,
         expiration_date = 8,
         fltselect = 3,
         category = 59000,
         rarity = 800000,
         coefficient = 100,
         originalnameref2 = "Jure's gem stone",

         elona_function = 30,
         is_precious = true,
         has_cooldown_time = true,
         param1 = 404,
         param2 = 400,
         param3 = 8,
         fixlv = "special",

         color = { 225, 225, 255 },

         categories = {
            "elona.unique_item",
            "elona.misc_item"
         }
      },
      {
         _id = "kumiromis_gem_stone_of_rejuvenation",
         elona_id = 682,
         image = "elona.item_gemstone",
         value = 50000,
         weight = 1200,
         expiration_date = 72,
         fltselect = 3,
         category = 59000,
         rarity = 800000,
         coefficient = 100,
         originalnameref2 = "Kumiromi's gem stone",

         elona_function = 31,
         is_precious = true,
         has_cooldown_time = true,
         param3 = 72,
         fixlv = "special",

         color = { 175, 255, 175 },

         categories = {
            "elona.unique_item",
            "elona.misc_item"
         }
      },
      {
         _id = "gem_stone_of_mani",
         elona_id = 683,
         image = "elona.item_gemstone",
         value = 50000,
         weight = 1200,
         expiration_date = 24,
         fltselect = 3,
         category = 59000,
         rarity = 800000,
         coefficient = 100,
         originalnameref2 = "gem stone",

         elona_function = 30,
         is_precious = true,
         has_cooldown_time = true,
         param1 = 1132,
         param2 = 100,
         param3 = 24,
         fixlv = "special",

         color = { 255, 155, 155 },

         categories = {
            "elona.unique_item",
            "elona.misc_item"
         }
      },
      {
         _id = "gene_machine",
         elona_id = 684,
         image = "elona.item_gene_machine",
         value = 20000,
         weight = 25000,
         level = 15,
         category = 59000,
         rarity = 10000,
         coefficient = 100,

         elona_function = 32,
         is_precious = true,
         categories = {
            "elona.misc_item"
         }
      },
      {
         _id = "monster_ball",
         elona_id = 685,
         image = "elona.item_monster_ball",
         value = 4500,
         weight = 1400,
         on_use = function() end,
         category = 59000,
         rarity = 400000,
         coefficient = 100,

         elona_function = 33,

         on_generate = function(self)
            self.param2 = Rand.rnd(self:calc("objlv") + 1) + 1
            self.value = 2000 + self.param2 * self.param2 + self.param2 * 100
         end,

         categories = {
            "elona.misc_item"
         }
      },
      {
         _id = "statue_of_jure",
         elona_id = 686,
         image = "elona.item_statue_of_jure",
         value = 100000,
         weight = 12000,
         expiration_date = 720,
         fltselect = 3,
         category = 59000,
         rarity = 800000,
         coefficient = 100,
         originalnameref2 = "statue",

         elona_function = 34,
         is_precious = true,
         has_cooldown_time = true,
         param3 = 720,
         fixlv = "special",
         categories = {
            "elona.unique_item",
            "elona.misc_item"
         }
      },
      {
         _id = "ancient_book",
         elona_id = 687,
         image = "elona.item_spellbook",
         value = 2000,
         weight = 380,
         chargelevel = 2,
         on_read = function() end,
         level = 3,
         category = 54000,
         rarity = 5000000,
         coefficient = 0,

         _copy = {
            count = Resolver.make("elona.item_count", { count = 2 }),
            has_charge = true,
         },

         on_generate = function(self)
            local Rand = require("api.Rand")
            self.param1 = Rand.rnd(Rand.rnd(math.clamp(math.floor(self:calc("objlv") / 2), 1, 15)) + 1)
         end,

         elona_type = "book",

         tags = { "noshop" },

         categories = {
            "elona.spellbook",
            "elona.tag_noshop"
         }
      },
      {
         _id = "iron_maiden",
         elona_id = 688,
         image = "elona.item_iron_maiden",
         value = 7500,
         weight = 26000,
         category = 59000,
         rarity = 5000,
         coefficient = 100,

         elona_function = 35,

         categories = {
            "elona.misc_item"
         }
      },
      {
         _id = "guillotine",
         elona_id = 689,
         image = "elona.item_guillotine",
         value = 5000,
         weight = 22000,
         category = 59000,
         rarity = 5000,
         coefficient = 100,

         elona_function = 36,

         categories = {
            "elona.misc_item"
         }
      },
      {
         _id = "pan_flute",
         elona_id = 690,
         image = "elona.item_pan_flute",
         value = 4500,
         weight = 18000,
         level = 15,
         category = 60000,
         subcategory = 60005,
         rarity = 350000,
         coefficient = 100,

         skill = "elona.performer",
         elona_function = 17,
         param1 = 150,

         tags = { "fest" },

         categories = {
            "elona.furniture_instrument",
            "elona.tag_fest",
            "elona.furniture"
         }
      },
      {
         _id = "lute",
         elona_id = 691,
         image = "elona.item_alud",
         value = 3800,
         weight = 8500,
         level = 10,
         category = 60000,
         subcategory = 60005,
         rarity = 400000,
         coefficient = 100,

         skill = "elona.performer",
         elona_function = 17,
         param1 = 130,

         tags = { "fest" },

         categories = {
            "elona.furniture_instrument",
            "elona.tag_fest",
            "elona.furniture"
         }
      },
      {
         _id = "harmonica",
         elona_id = 692,
         image = "elona.item_harmonica",
         value = 1500,
         weight = 850,
         category = 60000,
         subcategory = 60005,
         rarity = 500000,
         coefficient = 100,

         skill = "elona.performer",
         elona_function = 17,
         param1 = 70,

         tags = { "fest" },

         categories = {
            "elona.furniture_instrument",
            "elona.tag_fest",
            "elona.furniture"
         }
      },
      {
         _id = "harp",
         elona_id = 693,
         image = "elona.item_harp",
         value = 7500,
         weight = 30000,
         level = 10,
         category = 60000,
         subcategory = 60005,
         rarity = 250000,
         coefficient = 100,

         skill = "elona.performer",
         elona_function = 17,
         param1 = 175,
         categories = {
            "elona.furniture_instrument",
            "elona.furniture"
         }
      },
      {
         _id = "eastern_partition",
         elona_id = 694,
         image = "elona.item_eastern_partition",
         value = 2000,
         weight = 1200,
         level = 10,
         category = 60000,
         rarity = 800000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "axe_of_destruction",
         elona_id = 695,
         image = "elona.item_bardiche",
         value = 50000,
         weight = 14000,
         dice_x = 1,
         dice_y = 70,
         hit_bonus = -35,
         material = "elona.rubynus",
         level = 30,
         fltselect = 3,
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10010,
         coefficient = 100,

         skill = "elona.axe",

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",

         color = { 255, 155, 155 },

         enchantments = {
            { id = 44, power = 750 }
         },

         categories = {
            "elona.equip_melee_axe",
            "elona.unique_item",
            "elona.equip_melee"
         },

         light = light.item
      },
      {
         _id = "spellbook_of_magic_ball",
         elona_id = 696,
         image = "elona.item_spellbook",
         value = 14200,
         weight = 380,
         chargelevel = 2,
         on_read = function() end,
         level = 20,
         category = 54000,
         rarity = 300000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 2 }),
         has_charge = true,

         efid = 460,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "spellbook_of_magic_laser",
         elona_id = 697,
         image = "elona.item_spellbook",
         value = 12500,
         weight = 380,
         chargelevel = 2,
         on_read = function() end,
         level = 15,
         category = 54000,
         rarity = 300000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 2 }),
         has_charge = true,

         efid = 459,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "potion_of_salt_solution",
         elona_id = 698,
         image = "elona.item_handful_of_snow",
         value = 10,
         weight = 50,
         category = 52000,
         rarity = 100000,
         coefficient = 100,
         originalnameref2 = "potion",

         on_drink = Magic.drink_potion(1142, 100),
         categories = {
            "elona.drink",
         }
      },
      {
         _id = "little_ball",
         elona_id = 699,
         image = "elona.item_monster_ball",
         value = 10,
         weight = 3000,
         category = 59000,
         rarity = 400000,
         coefficient = 100,

         is_precious = true,

         color = { 255, 155, 155 },

         categories = {
            "elona.misc_item"
         },

         light = light.item
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
         _id = "deck",
         elona_id = 701,
         image = "elona.item_deck",
         value = 2200,
         weight = 20,
         category = 59000,
         rarity = 20000,
         coefficient = 0,

         elona_function = 37,

         categories = {
            "elona.misc_item"
         }
      },
      {
         _id = "rabbits_tail",
         elona_id = 702,
         image = "elona.item_rabbits_tail",
         value = 10000,
         weight = 150,
         fltselect = 3,
         category = 57000,
         coefficient = 100,

         is_precious = true,
         food_rank = 4,
         fixlv = "special",

         color = { 255, 155, 155 },

         categories = {
            "elona.unique_item",
            "elona.food"
         }
      },
      {
         _id = "whistle",
         elona_id = 703,
         image = "elona.item_whistle",
         value = 1400,
         weight = 20,
         category = 59000,
         rarity = 75000,
         coefficient = 0,

         elona_function = 39,

         categories = {
            "elona.misc_item"
         }
      },
      {
         _id = "vomit",
         elona_id = 704,
         image = "elona.item_vomit",
         value = 400,
         weight = 100,
         category = 52000,
         rarity = 10000,
         coefficient = 0,

         on_drink = Magic.drink_potion(1130, 100),
         categories = {
            "elona.drink",
         }
      },
      {
         _id = "beggars_pendant",
         elona_id = 705,
         image = "elona.item_neck_guard",
         value = 50,
         weight = 250,
         dv = 8,
         material = "elona.iron",
         level = 15,
         fltselect = 3,
         category = 34000,
         equip_slots = { "elona.neck" },
         subcategory = 34001,
         coefficient = 100,

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",
         enchantments = {
            { id = 48, power = 100 },
            { id = 10017, power = 450 },
            { id = 41, power = 100 }
         },
         categories = {
            "elona.equip_neck_armor",
            "elona.unique_item",
            "elona.equip_neck"
         },
         light = light.item
      },
      {
         _id = "potion_of_descent",
         elona_id = 706,
         image = "elona.item_potion",
         value = 4500,
         weight = 120,
         category = 52000,
         rarity = 4000,
         coefficient = 100,
         originalnameref2 = "potion",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         on_drink = Magic.drink_potion(1143, 100),
         categories = {
            "elona.drink",
         }
      },
      {
         _id = "stradivarius",
         elona_id = 707,
         image = "elona.item_stradivarius",
         value = 35000,
         weight = 4500,
         fltselect = 3,
         category = 60000,
         subcategory = 60005,
         rarity = 400000,
         coefficient = 100,

         skill = "elona.performer",

         elona_function = 17,
         is_precious = true,
         param1 = 180,
         fixlv = "special",
         enchantments = {
            { id = 49, power = 100 }
         },
         categories = {
            "elona.furniture_instrument",
            "elona.unique_item",
            "elona.furniture"
         },
         light = light.item
      },
      {
         _id = "book_of_resurrection",
         elona_id = 708,
         image = "elona.item_spellbook",
         value = 6000,
         weight = 380,
         on_read = function() end,
         category = 55000,
         rarity = 3000,
         coefficient = 0,
         originalnameref2 = "book",
         has_random_name = true,

         efid = 461,
         efp = 2500,
         elona_type = "scroll",

         tags = { "noshop" },
         color = Resolver.make("elona.random_item_color"),
         categories = {
            "elona.book",
            "elona.tag_noshop"
         }
      },
      {
         _id = "scroll_of_contingency",
         elona_id = 709,
         image = "elona.item_scroll",
         value = 3500,
         weight = 20,
         on_read = function() end,
         level = 5,
         category = 53000,
         rarity = 3000,
         coefficient = 0,
         originalnameref2 = "scroll",
         has_random_name = true,

         efid = 462,
         efp = 1500,
         elona_type = "scroll",

         tags = { "noshop" },
         color = Resolver.make("elona.random_item_color"),
         categories = {
            "elona.scroll",
            "elona.tag_noshop"
         }
      },
      {
         _id = "spellbook_of_contingency",
         elona_id = 710,
         image = "elona.item_spellbook",
         value = 8500,
         weight = 380,
         chargelevel = 3,
         on_read = function() end,
         level = 15,
         category = 54000,
         rarity = 300000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 3 }),
         has_charge = true,

         efid = 462,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "potion_of_evolution",
         elona_id = 711,
         image = "elona.item_potion",
         value = 12000,
         weight = 120,
         category = 52000,
         rarity = 5000,
         coefficient = 0,
         originalnameref2 = "potion",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         on_drink = Magic.drink_potion(1144, 100),
         categories = {
            "elona.drink",
         }
      },
      {
         _id = "deed_of_dungeon",
         elona_id = 712,
         image = "elona.item_deed",
         value = 500000,
         weight = 500,
         on_read = function() end,
         fltselect = 1,
         category = 53000,
         subcategory = 53100,
         rarity = 1000,
         coefficient = 100,
         originalnameref2 = "deed",

         efid = 1115,

         color = { 175, 175, 255 },

         categories = {
            "elona.scroll",
            "elona.scroll_deed",
            "elona.no_generate"
         }
      },
      {
         _id = "shuriken",
         elona_id = 713,
         image = "elona.item_shuriken",
         value = 750,
         weight = 400,
         dice_x = 1,
         dice_y = 20,
         hit_bonus = 4,
         material = "elona.metal",
         level = 5,
         category = 24000,
         equip_slots = { "elona.ranged" },
         subcategory = 24030,
         rarity = 200000,
         coefficient = 100,

         skill = "elona.throwing",
         effective_range = { 60, 100, 70, 20, 20, 20, 20, 20, 20, 20 },pierce_rate = 15,
         enchantments = {
            { id = 70061, power = 100 }
         },
         categories = {
            "elona.equip_ranged_thrown",
            "elona.equip_ranged"
         }
      },
      {
         _id = "grenade",
         elona_id = 714,
         image = "elona.item_grenade",
         value = 550,
         weight = 850,
         dice_x = 1,
         dice_y = 6,
         material = "elona.metal",
         level = 10,
         category = 24000,
         equip_slots = { "elona.ranged" },
         subcategory = 24030,
         rarity = 100000,
         coefficient = 100,

         skill = "elona.throwing",
         effective_range = { 80, 100, 90, 80, 60, 20, 20, 20, 20, 20 },
         pierce_rate = 0,
         enchantments = {
            { id = 80024, power = 100 }
         },
         categories = {
            "elona.equip_ranged_thrown",
            "elona.equip_ranged"
         }
      },
      {
         _id = "secret_experience_of_kumiromi",
         elona_id = 715,
         image = "elona.item_gemstone",
         value = 6800,
         weight = 1200,
         category = 59000,
         rarity = 1000,
         coefficient = 100,
         originalnameref2 = "secret experience",

         elona_function = 41,

         tags = { "noshop" },
         color = { 155, 205, 205 },
         categories = {
            "elona.tag_noshop",
            "elona.misc_item"
         }
      },
      {
         _id = "vanilla_rock",
         elona_id = 716,
         image = "elona.item_stone",
         value = 9500,
         weight = 7500,
         dice_x = 1,
         dice_y = 42,
         material = "elona.adamantium",
         level = 15,
         fltselect = 3,
         category = 24000,
         equip_slots = { "elona.ranged" },
         subcategory = 24030,
         coefficient = 100,

         skill = "elona.throwing",
         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",
         effective_range = { 60, 100, 70, 20, 20, 20, 20, 20, 20, 20 },pierce_rate = 50,categories = {
            "elona.equip_ranged_thrown",
            "elona.unique_item",
            "elona.equip_ranged"
         },light = light.item
      },
      {
         _id = "secret_experience_of_lomias",
         elona_id = 717,
         image = "elona.item_gemstone",
         value = 6800,
         weight = 1200,
         fltselect = 1,
         category = 59000,
         rarity = 1000,
         coefficient = 100,
         originalnameref2 = "secret experience",

         elona_function = 42,

         color = { 155, 205, 205 },

         categories = {
            "elona.no_generate",
            "elona.misc_item"
         }
      },
      {
         _id = "shenas_panty",
         elona_id = 718,
         image = "elona.item_panty",
         value = 94000,
         weight = 250,
         dice_x = 1,
         dice_y = 47,
         hit_bonus = 7,
         damage_bonus = 4,
         material = "elona.silk",
         level = 40,
         fltselect = 3,
         category = 24000,
         equip_slots = { "elona.ranged" },
         subcategory = 24030,
         coefficient = 100,

         skill = "elona.throwing",

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",

         color = { 255, 155, 155 },

         effective_range = { 50, 100, 50, 20, 20, 20, 20, 20, 20, 20 },
         pierce_rate = 5,
         enchantments = {
            { id = 40, power = 350 },
            { id = 70054, power = 1200 },
            { id = 10017, power = 450 },
            { id = 48, power = 100 },
            { id = 30, power = 500 }
         },
         categories = {
            "elona.equip_ranged_thrown",
            "elona.unique_item",
            "elona.equip_ranged"
         },
         light = light.item
      },
      {
         _id = "claymore_unique",
         elona_id = 719,
         image = "elona.item_claymore_unique",
         value = 45000,
         weight = 6500,
         dice_x = 3,
         dice_y = 14,
         hit_bonus = 1,
         damage_bonus = 16,
         material = "elona.silver",
         level = 45,
         fltselect = 3,
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10001,
         coefficient = 100,

         skill = "elona.long_sword",

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",
         enchantments = {
            { id = 44, power = 250 },
            { id = 39, power = 200 },
            { id = 33, power = 100 }
         },
         categories = {
            "elona.equip_melee_broadsword",
            "elona.unique_item",
            "elona.equip_melee"
         },
         light = light.item
      },
      {
         _id = "happy_bed",
         elona_id = 720,
         image = "elona.item_luxury_bed",
         value = 25000,
         weight = 31000,
         on_use = function() end,
         level = 45,
         category = 60000,
         subcategory = 60004,
         rarity = 2000,
         coefficient = 100,

         param1 = 200,

         tags = { "noshop" },
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture_bed",
            "elona.tag_noshop",
            "elona.furniture"
         },
         light = light.item
      },
      {
         _id = "statue_of_ehekatl",
         elona_id = 721,
         image = "elona.item_statue_of_ehekatl",
         value = 100000,
         weight = 12000,
         expiration_date = 480,
         fltselect = 3,
         category = 59000,
         rarity = 800000,
         coefficient = 100,
         originalnameref2 = "statue",

         elona_function = 43,
         is_precious = true,
         has_cooldown_time = true,
         param3 = 480,
         fixlv = "special",
         categories = {
            "elona.unique_item",
            "elona.misc_item"
         }
      },
      {
         _id = "arbalest",
         elona_id = 722,
         image = "elona.item_neck_guard",
         value = 9500,
         weight = 400,
         hit_bonus = 12,
         material = "elona.coral",
         level = 25,
         fltselect = 3,
         category = 34000,
         equip_slots = { "elona.neck" },
         subcategory = 34001,
         coefficient = 100,

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",

         color = { 185, 155, 215 },

         enchantments = {
            { id = 51, power = 600 },
            { id = 30109, power = 700 }
         },

         categories = {
            "elona.equip_neck_armor",
            "elona.unique_item",
            "elona.equip_neck"
         },

         light = light.item
      },
      {
         _id = "twin_edge",
         elona_id = 723,
         image = "elona.item_neck_guard",
         value = 9500,
         weight = 400,
         damage_bonus = 4,
         material = "elona.mica",
         level = 25,
         fltselect = 3,
         category = 34000,
         equip_slots = { "elona.neck" },
         subcategory = 34001,
         coefficient = 100,

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",

         color = { 255, 215, 175 },

         enchantments = {
            { id = 50, power = 600 },
            { id = 30166, power = 650 }
         },

         categories = {
            "elona.equip_neck_armor",
            "elona.unique_item",
            "elona.equip_neck"
         },

         light = light.item
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

         _copy = {
            identify_state = "completely",
            curse_state = "none"
         },

         tags = { "noshop" },
         rftags = { "ore" },
         categories = {
            "elona.tag_noshop",
            "elona.no_generate",
            "elona.ore"
         }
      },
      {
         _id = "kill_kill_piano",
         elona_id = 725,
         image = "elona.item_goulds_piano",
         value = 25000,
         weight = 75000,
         dice_x = 1,
         dice_y = 112,
         hit_bonus = -28,
         material = "elona.gold",
         level = 25,
         fltselect = 3,
         category = 24000,
         equip_slots = { "elona.ranged" },
         subcategory = 24030,
         coefficient = 100,

         skill = "elona.throwing",

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",

         color = { 255, 215, 175 },

         effective_range = { 60, 100, 70, 20, 20, 20, 20, 20, 20, 20 },
         pierce_rate = 0,
         enchantments = {
            { id = 70059, power = 400 },
            { id = 30183, power = -700 },
            { id = 44, power = 450 }
         },
         categories = {
            "elona.equip_ranged_thrown",
            "elona.unique_item",
            "elona.equip_ranged"
         },
         light = light.item
      },
      {
         _id = "alud",
         elona_id = 726,
         image = "elona.item_alud",
         value = 7500,
         weight = 2850,
         pv = 35,
         dv = -1,
         material = "elona.wood",
         level = 15,
         fltselect = 3,
         category = 14000,
         equip_slots = { "elona.hand" },
         subcategory = 14003,
         coefficient = 100,

         skill = "elona.shield",

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",

         color = { 255, 255, 175 },

         enchantments = {
            { id = 30183, power = -450 },
            { id = 52, power = 400 },
            { id = 53, power = 400 }
         },

         categories = {
            "elona.equip_shield_shield",
            "elona.unique_item",
            "elona.equip_shield"
         },

         light = light.item
      },
      {
         _id = "shield_of_thorn",
         elona_id = 727,
         image = "elona.item_small_shield",
         value = 17500,
         weight = 950,
         damage_bonus = 14,
         pv = 1,
         material = "elona.coral",
         level = 15,
         fltselect = 2,
         category = 14000,
         equip_slots = { "elona.hand" },
         subcategory = 14003,
         coefficient = 100,

         skill = "elona.shield",

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",

         color = { 255, 155, 155 },

         enchantments = {
            { id = 54, power = 1000 },
            { id = 20058, power = 450 }
         },

         categories = {
            "elona.equip_shield_shield",
            "elona.unique_weapon",
            "elona.equip_shield"
         },

         light = light.item
      },
      {
         _id = "crimson_plate",
         elona_id = 728,
         image = "elona.item_composite_girdle",
         value = 15000,
         weight = 1250,
         pv = 15,
         dv = 2,
         material = "elona.mithril",
         appearance = 2,
         level = 13,
         fltselect = 3,
         category = 19000,
         equip_slots = { "elona.waist" },
         subcategory = 19001,
         coefficient = 100,

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",

         color = { 255, 155, 155 },

         enchantments = {
            { id = 55, power = 100 },
            { id = 20056, power = 450 },
            { id = 20050, power = 350 }
         },

         categories = {
            "elona.equip_back_girdle",
            "elona.unique_item",
            "elona.equip_cloak"
         },

         light = light.item
      },
      {
         _id = "gift",
         elona_id = 729,
         image = "elona.item_gift",
         value = 2500,
         weight = 1000,
         category = 60000,
         rarity = 5000,
         coefficient = 0,
         tags = { "spshop" },
         categories = {
            "elona.tag_spshop",
            "elona.furniture"
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

         _copy = {
            identify_state = "completely",
            curse_state = "none"
         },

         tags = { "noshop" },
         rftags = { "ore" },
         categories = {
            "elona.tag_noshop",
            "elona.no_generate",
            "elona.ore"
         }
      },
      {
         _id = "spellbook_of_4_dimensional_pocket",
         elona_id = 731,
         image = "elona.item_spellbook",
         value = 8500,
         weight = 380,
         chargelevel = 3,
         on_read = function() end,
         level = 15,
         category = 54000,
         rarity = 400000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 3 }),
         has_charge = true,

         efid = 463,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "spellbook_of_harvest",
         elona_id = 732,
         image = "elona.item_spellbook",
         value = 4000,
         weight = 380,
         chargelevel = 3,
         on_read = function() end,
         level = 5,
         category = 54000,
         rarity = 800000,
         coefficient = 0,
         originalnameref2 = "spellbook",
         has_random_name = true,
         color = Resolver.make("elona.random_item_color"),

         count = Resolver.make("elona.item_count", { count = 3 }),
         has_charge = true,

         efid = 464,
         efp = 100,
         elona_type = "book",
         categories = {
            "elona.spellbook"
         }
      },
      {
         _id = "sand_bag",
         elona_id = 733,
         image = "elona.item_sand_bag",
         value = 4800,
         weight = 8500,
         category = 59000,
         rarity = 10000,
         coefficient = 100,

         elona_function = 45,

         categories = {
            "elona.misc_item"
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
            local Rand = require("api.Rand")
            self.param2 = Rand.rnd(Rand.rnd(100) + 1) + 1
            self.value = self.param2 * 25 + 150
            self.amount = Rand.rnd(8)
         end,

         categories = {
            "elona.container"
         }
      },
      {
         _id = "scythe",
         elona_id = 735,
         image = "elona.item_scythe",
         value = 500,
         weight = 4000,
         dice_x = 1,
         dice_y = 17,
         hit_bonus = 3,
         damage_bonus = 4,
         material = "elona.metal",
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10011,
         coefficient = 100,

         skill = "elona.scythe",pierce_rate = 5,enchantments = {
            { id = 80025, power = 100 }
         },categories = {
            "elona.equip_melee_scythe",
            "elona.equip_melee"
         }
      },
      {
         _id = "fireproof_liquid",
         elona_id = 736,
         image = "elona.item_potion",
         value = 1500,
         weight = 120,
         category = 52000,
         rarity = 300000,
         coefficient = 100,
         has_random_name = true,

         on_drink = Magic.drink_potion(1116, 250),

         tags = { "nogive" },
         color = Resolver.make("elona.random_item_color"),
         categories = {
            "elona.drink",
            "elona.tag_nogive"
         }
      },
      {
         _id = "scroll_of_name",
         elona_id = 737,
         image = "elona.item_scroll",
         value = 7500,
         weight = 20,
         on_read = function() end,
         level = 20,
         category = 53000,
         rarity = 2000,
         coefficient = 0,
         originalnameref2 = "scroll",
         has_random_name = true,

         efid = 1145,
         efp = 100,
         elona_type = "scroll",

         tags = { "noshop" },
         color = Resolver.make("elona.random_item_color"),
         categories = {
            "elona.scroll",
            "elona.tag_noshop"
         }
      },
      {
         _id = "fortune_cookie",
         elona_id = 738,
         image = "elona.item_fortune_cookie",
         value = 250,
         weight = 50,
         category = 57000,
         rarity = 400000,
         coefficient = 0,

         food_rank = 6,

         nutrition = 750,

         tags = { "fest" },

         categories = {
            "elona.tag_fest",
            "elona.food"
         }
      },
      {
         _id = "frisias_tail",
         elona_id = 739,
         image = "elona.item_staff",
         value = 30000,
         weight = 376500,
         dice_x = 25,
         dice_y = 16,
         hit_bonus = -460,
         damage_bonus = 32,
         material = "elona.ether",
         level = 99,
         fltselect = 3,
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10011,
         coefficient = 100,

         skill = "elona.scythe",

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",pierce_rate = 65,enchantments = {
            { id = 80002, power = 400 },
            { id = 70054, power = 850 },
            { id = 10016, power = 34500 },
            { id = 80025, power = 100 },
            { id = 37, power = 100 },
            { id = 80003, power = 350 }
         },categories = {
            "elona.equip_melee_scythe",
            "elona.unique_item",
            "elona.equip_melee"
         },light = light.item
      },
      {
         _id = "unknown_shell",
         elona_id = 740,
         image = "elona.item_peridot",
         value = 1200,
         weight = 150,
         pv = 14,
         dv = 2,
         material = "elona.mica",
         level = 5,
         fltselect = 3,
         category = 34000,
         equip_slots = { "elona.neck" },
         subcategory = 34001,
         coefficient = 100,

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",

         color = { 175, 175, 255 },

         enchantments = {
            { id = 56, power = 100 },
            { id = 30181, power = 550 },
            { id = 20057, power = 400 }
         },

         categories = {
            "elona.equip_neck_armor",
            "elona.unique_item",
            "elona.equip_neck"
         },

         light = light.item
      },
      {
         _id = "hiryu_to",
         elona_id = 741,
         image = "elona.item_zantetsu",
         value = 40000,
         weight = 2500,
         dice_x = 6,
         dice_y = 6,
         hit_bonus = 3,
         damage_bonus = 2,
         material = "elona.obsidian",
         level = 25,
         fltselect = 2,
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10002,
         coefficient = 100,

         skill = "elona.long_sword",

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",

         color = { 255, 155, 155 },
         pierce_rate = 20,
         enchantments = {
            { id = 20050, power = 550 },
            { id = 70052, power = 400 },
            { id = 57, power = 1150 },
            { id = 10011, power = 720 }
         },
         categories = {
            "elona.equip_melee_long_sword",
            "elona.unique_weapon",
            "elona.equip_melee"
         },
         light = light.item
      },
      {
         _id = "license_of_the_void_explorer",
         elona_id = 742,
         image = "elona.item_deed",
         value = 15000,
         weight = 500,
         on_read = function() end,
         fltselect = 3,
         category = 53000,
         rarity = 1000,
         coefficient = 100,
         originalnameref2 = "license",

         is_precious = true,
         fixlv = "special",

         elona_type = "normal_book",

         medal_value = 72,

         categories = {
            "elona.scroll",
            "elona.unique_item"
         }
      },
      {
         _id = "plank_of_carneades",
         elona_id = 743,
         image = "elona.item_gemstone",
         value = 50000,
         weight = 1200,
         expiration_date = 24,
         fltselect = 1,
         category = 59000,
         rarity = 800000,
         coefficient = 100,
         originalnameref2 = "plank",

         elona_function = 30,
         is_precious = true,
         has_cooldown_time = true,
         param1 = 1132,
         param2 = 100,
         param3 = 24,

         color = { 255, 155, 155 },

         categories = {
            "elona.no_generate",
            "elona.misc_item"
         }
      },
      {
         _id = "schrodingers_cat",
         elona_id = 744,
         image = "elona.item_gemstone",
         value = 50000,
         weight = 1200,
         expiration_date = 24,
         fltselect = 1,
         category = 59000,
         rarity = 800000,
         coefficient = 100,

         elona_function = 30,
         is_precious = true,
         has_cooldown_time = true,
         param1 = 1132,
         param2 = 100,
         param3 = 24,

         color = { 255, 155, 155 },

         categories = {
            "elona.no_generate",
            "elona.misc_item"
         }
      },
      {
         _id = "heart",
         elona_id = 745,
         image = "elona.item_gemstone",
         value = 50000,
         weight = 1200,
         expiration_date = 24,
         fltselect = 1,
         category = 59000,
         rarity = 800000,
         coefficient = 100,

         elona_function = 30,
         is_precious = true,
         has_cooldown_time = true,
         param1 = 1132,
         param2 = 100,
         param3 = 24,

         color = { 255, 155, 155 },

         categories = {
            "elona.no_generate",
            "elona.misc_item"
         }
      },
      {
         _id = "tamers_whip",
         elona_id = 746,
         image = "elona.item_gemstone",
         value = 50000,
         weight = 1200,
         expiration_date = 24,
         fltselect = 1,
         category = 59000,
         rarity = 800000,
         coefficient = 100,

         elona_function = 30,
         is_precious = true,
         has_cooldown_time = true,
         param1 = 1132,
         param2 = 100,
         param3 = 24,

         color = { 255, 155, 155 },

         categories = {
            "elona.no_generate",
            "elona.misc_item"
         }
      },
      {
         _id = "book_of_bokonon",
         elona_id = 747,
         image = "elona.item_book",
         value = 4000,
         weight = 80,
         on_read = function() end,
         fltselect = 1,
         category = 55000,
         rarity = 50000,
         coefficient = 0,
         originalnameref2 = "book",

         param1 = 1,
         param2 = Resolver.make("base.between", { min = 1, coefficient = 4 }),

         elona_type = "normal_book",

         tags = { "noshop" },

         categories = {
            "elona.book",
            "elona.tag_noshop",
            "elona.no_generate"
         }
      },
      {
         _id = "summoning_crystal",
         elona_id = 748,
         image = "elona.item_summoning_crystal",
         value = 4500,
         weight = 7500,
         on_use = function() end,
         category = 59000,
         rarity = 20000,
         coefficient = 0,

         elona_function = 47,
         is_precious = true,
         is_showroom_only = true,
         categories = {
            "elona.misc_item"
         },
         light = light.item_middle
      },
      {
         _id = "statue_of_creator",
         elona_id = 749,
         image = "elona.item_statue_of_creator",
         value = 50,
         weight = 15000,
         category = 59000,
         rarity = 800000,
         coefficient = 0,
         originalnameref2 = "statue",

         elona_function = 48,
         is_precious = true,
         categories = {
            "elona.misc_item"
         }
      },
      {
         _id = "upstairs",
         elona_id = 750,
         image = "elona.item_upstairs",
         value = 150000,
         weight = 7500,
         fltselect = 1,
         category = 60000,
         rarity = 20000,
         coefficient = 0,
         categories = {
            "elona.no_generate",
            "elona.furniture"
         }
      },
      {
         _id = "downstairs",
         elona_id = 751,
         image = "elona.item_downstairs",
         value = 150000,
         weight = 7500,
         fltselect = 1,
         category = 60000,
         rarity = 20000,
         coefficient = 0,
         categories = {
            "elona.no_generate",
            "elona.furniture"
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
         }
      },
      {
         _id = "kotatsu",
         elona_id = 753,
         image = "elona.item_kotatsu",
         value = 7800,
         weight = 9800,
         level = 28,
         fltselect = 1,
         category = 60000,
         rarity = 10000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.no_generate",
            "elona.furniture"
         }
      },
      {
         _id = "daruma",
         elona_id = 754,
         image = "elona.item_daruma",
         value = 3200,
         weight = 720,
         fltselect = 1,
         category = 60000,
         coefficient = 100,
         categories = {
            "elona.no_generate",
            "elona.furniture"
         }
      },
      {
         _id = "kagami_mochi",
         elona_id = 755,
         image = "elona.item_kagami_mochi",
         value = 2500,
         weight = 800,
         fltselect = 1,
         category = 57000,
         rarity = 400000,
         coefficient = 0,

         food_rank = 6,

         events = {
            {
               id = "elona.on_eat_item_finish",
               name = "Choking behavior",

               callback = function(self, params)
                  local chance = 3
                  if Rand.one_in(chance) then
                     local chara = params.chara
                     if chara:is_in_fov() then
                        Gui.mes_c("food.mochi.chokes", "Purple", chara)
                        Gui.mes_c("food.mochi.dialog")
                     end
                     chara:add_effect_turns("elona.choked", 1)
                  end
               end
            }
         },

         categories = {
            "elona.no_generate",
            "elona.food"
         }
      },
      {
         _id = "mochi",
         elona_id = 756,
         image = "elona.item_mochi",
         value = 800,
         weight = 350,
         category = 57000,
         rarity = 150000,
         coefficient = 0,

         food_rank = 7,

         tags = { "fest" },

         {
            id = "elona.on_eat_item_finish",
            name = "Choking behavior",

            callback = function(self, params)
               local chance = 10
               if Rand.one_in(chance) then
                  local chara = params.chara
                  if chara:is_in_fov() then
                     Gui.mes_c("food.mochi.chokes", "Purple", chara)
                     Gui.mes_c("food.mochi.dialog")
                  end
                  chara:add_effect_turns("elona.choked", 1)
               end
            end
         },

         categories = {
            "elona.tag_fest",
            "elona.food"
         }
      },
      {
         _id = "five_horned_helm",
         elona_id = 757,
         image = "elona.item_knight_helm",
         value = 15000,
         weight = 2400,
         damage_bonus = 8,
         pv = 7,
         dv = 2,
         material = "elona.obsidian",
         level = 5,
         fltselect = 3,
         category = 12000,
         equip_slots = { "elona.head" },
         subcategory = 12001,
         coefficient = 100,

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",

         color = { 175, 175, 255 },

         enchantments = {
            { id = 59, power = 100 },
            { id = 50, power = 200 },
            { id = 51, power = 150 },
            { id = 54, power = 180 },
            { id = 33, power = 100 }
         },

         categories = {
            "elona.equip_head_helm",
            "elona.unique_item",
            "elona.equip_head"
         },

         light = light.item
      },
      {
         _id = "mauser_c96_custom",
         elona_id = 758,
         image = "elona.item_pistol",
         value = 25000,
         weight = 950,
         dice_x = 1,
         dice_y = 24,
         hit_bonus = 14,
         damage_bonus = 26,
         material = "elona.iron",
         fltselect = 3,
         category = 24000,
         equip_slots = { "elona.ranged" },
         subcategory = 24020,
         coefficient = 100,

         skill = "elona.firearm",

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",

         tags = { "sf" },
         color = { 155, 154, 153 },
         effective_range = { 100, 90, 70, 50, 20, 20, 20, 20, 20, 20 },pierce_rate = 35,
         enchantments = {
            { id = 35, power = 100 }
         },
         categories = {
            "elona.equip_ranged_gun",
            "elona.tag_sf",
            "elona.unique_item",
            "elona.equip_ranged"
         },
         light = light.item
      },
      {
         _id = "lightsabre",
         elona_id = 759,
         image = "elona.item_lightsabre",
         value = 4800,
         weight = 600,
         dice_x = 2,
         dice_y = 5,
         material = "elona.ether",
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10002,
         rarity = 2000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },

         skill = "elona.long_sword",
         pierce_rate = 100,
         categories = {
            "elona.equip_melee_long_sword",
            "elona.equip_melee"
         },
         light = light.item
      },
      {
         _id = "garoks_hammer",
         elona_id = 760,
         image = "elona.item_material_kit",
         value = 75000,
         weight = 5000,
         on_use = function() end,
         fltselect = 3,
         category = 59000,
         rarity = 5000,
         coefficient = 0,

         elona_function = 49,
         is_precious = true,
         param1 = Resolver.make("base.between", { min = 1, coefficient = 20000 }),
         fixlv = "special",
         medal_value = 94,
         categories = {
            "elona.unique_item",
            "elona.misc_item"
         },
         light = light.item
      },
      {
         _id = "goulds_piano",
         elona_id = 761,
         image = "elona.item_goulds_piano",
         value = 35000,
         weight = 45000,
         level = 20,
         fltselect = 3,
         category = 60000,
         subcategory = 60005,
         rarity = 100000,
         coefficient = 100,

         skill = "elona.performer",

         elona_function = 17,
         is_precious = true,
         param1 = 200,
         fixlv = "special",

         color = { 255, 255, 255 },

         enchantments = {
            { id = 60, power = 100 }
         },

         categories = {
            "elona.furniture_instrument",
            "elona.unique_item",
            "elona.furniture"
         },

         light = light.item_middle
      },
      {
         _id = "festival_wreath",
         elona_id = 762,
         image = "elona.item_festival_wreath",
         value = 760,
         weight = 280,
         level = 25,
         fltselect = 1,
         category = 60000,
         rarity = 5000,
         coefficient = 100,
         tags = { "fest" },
         categories = {
            "elona.tag_fest",
            "elona.no_generate",
            "elona.furniture"
         },
         light = light.crystal_high
      },
      {
         _id = "pedestal",
         elona_id = 763,
         image = "elona.item_pedestal",
         value = 3600,
         weight = 85000,
         level = 15,
         category = 60000,
         rarity = 40000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "counter",
         elona_id = 764,
         image = "elona.item_counter",
         value = 1200,
         weight = 9900,
         level = 5,
         category = 60000,
         rarity = 25000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "red_stall",
         elona_id = 765,
         image = "elona.item_red_stall",
         value = 3800,
         weight = 48500,
         level = 30,
         category = 60000,
         rarity = 10000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "blue_stall",
         elona_id = 766,
         image = "elona.item_blue_stall",
         value = 3800,
         weight = 48500,
         level = 30,
         category = 60000,
         rarity = 10000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "jures_body_pillow",
         elona_id = 767,
         image = "elona.item_jures_body_pillow",
         value = 250,
         weight = 800,
         on_use = function() end,
         level = 5,
         fltselect = 1,
         category = 60000,
         subcategory = 60004,
         rarity = 25000,
         coefficient = 100,

         param1 = 0,

         categories = {
            "elona.furniture_bed",
            "elona.no_generate",
            "elona.furniture"
         }
      },
      {
         _id = "new_years_decoration",
         elona_id = 768,
         image = "elona.item_new_years_decoration",
         value = 400,
         weight = 150,
         level = 10,
         fltselect = 1,
         category = 60000,
         rarity = 5000,
         coefficient = 100,
         tags = { "fest" },
         categories = {
            "elona.tag_fest",
            "elona.no_generate",
            "elona.furniture"
         }
      },
      {
         _id = "miniature_tree",
         elona_id = 769,
         image = "elona.item_miniature_tree",
         value = 1650,
         weight = 530,
         level = 10,
         fltselect = 1,
         category = 60000,
         rarity = 5000,
         coefficient = 100,
         tags = { "fest" },
         categories = {
            "elona.tag_fest",
            "elona.no_generate",
            "elona.furniture"
         }
      },
      {
         _id = "bottle_of_soda",
         elona_id = 770,
         image = "elona.item_bottle_of_soda",
         value = 500,
         weight = 50,
         fltselect = 1,
         category = 52000,
         rarity = 400000,
         coefficient = 0,
         originalnameref2 = "bottle",

         on_drink = Magic.drink_potion(1146, 100),

         tags = { "fest" },

         categories = {
            "elona.drink",
            "elona.tag_fest",
            "elona.no_generate"
         }
      },
      {
         _id = "blue_capsule_drug",
         elona_id = 771,
         image = "elona.item_blue_capsule_drug",
         value = 7500,
         weight = 100,
         fltselect = 3,
         category = 52000,
         rarity = 5000,
         coefficient = 0,

         fixlv = "special",

         on_drink = Magic.drink_potion(1147, 100),
         categories = {
            "elona.drink",
            "elona.unique_item"
         }
      },
      {
         _id = "tomato",
         elona_id = 772,
         image = "elona.item_tomato",
         value = 90,
         weight = 330,
         material = "elona.fresh",
         expiration_date = 32,
         category = 57000,
         subcategory = 57004,
         coefficient = 100,

         param1 = 2000,
         param3 = 32,
         categories = {
            "elona.food_fruit",
            "elona.food"
         }
      },
      {
         _id = "large_bookshelf",
         elona_id = 773,
         image = "elona.item_large_bookshelf",
         value = 2400,
         weight = 15000,
         level = 18,
         category = 60000,
         rarity = 400000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "luxury_cabinet",
         elona_id = 774,
         image = "elona.item_luxury_cabinet",
         value = 7200,
         weight = 23800,
         level = 24,
         category = 60000,
         rarity = 150000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "special_steamed_meat_bun",
         elona_id = 775,
         image = "elona.item_special_steamed_meat_bun",
         value = 160,
         weight = 250,
         level = 3,
         category = 57000,
         rarity = 50000,
         coefficient = 100,

         is_precious = true,
         food_rank = 8,
         categories = {
            "elona.food"
         }
      },
      {
         _id = "statue_of_kumiromi",
         elona_id = 776,
         image = "elona.item_statue_of_kumiromi",
         value = 100000,
         weight = 15000,
         expiration_date = 240,
         fltselect = 3,
         category = 59000,
         rarity = 800000,
         coefficient = 100,
         originalnameref2 = "statue",

         elona_function = 26,
         is_precious = true,
         has_cooldown_time = true,
         param3 = 240,
         fixlv = "special",
         categories = {
            "elona.unique_item",
            "elona.misc_item"
         }
      },
      {
         _id = "statue_of_mani",
         elona_id = 777,
         image = "elona.item_statue_of_mani",
         value = 100000,
         weight = 15000,
         expiration_date = 240,
         fltselect = 3,
         category = 59000,
         rarity = 800000,
         coefficient = 100,
         originalnameref2 = "statue",

         elona_function = 26,
         is_precious = true,
         has_cooldown_time = true,
         param3 = 240,
         fixlv = "special",
         categories = {
            "elona.unique_item",
            "elona.misc_item"
         }
      },
      {
         _id = "luxury_sofa",
         elona_id = 778,
         image = "elona.item_luxury_sofa",
         value = 4900,
         weight = 9000,
         level = 15,
         category = 60000,
         rarity = 100000,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },

         elona_function = 44,

         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "deer_head",
         elona_id = 779,
         image = "elona.item_deer_head",
         value = 16000,
         weight = 1800,
         level = 32,
         category = 60000,
         rarity = 10000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "fur_carpet",
         elona_id = 780,
         image = "elona.item_fur_carpet",
         value = 23000,
         weight = 4200,
         level = 45,
         category = 60000,
         rarity = 10000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "kitchen_knife",
         elona_id = 781,
         image = "elona.item_kitchen_knife",
         value = 2400,
         weight = 400,
         dice_x = 1,
         dice_y = 14,
         hit_bonus = 5,
         damage_bonus = 1,
         material = "elona.metal",
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10003,
         rarity = 50000,
         coefficient = 100,

         skill = "elona.short_sword",
         pierce_rate = 40,
         categories = {
            "elona.equip_melee_short_sword",
            "elona.equip_melee"
         }
      },
      {
         _id = "dish",
         elona_id = 782,
         image = "elona.item_dish",
         value = 100,
         weight = 150,
         category = 60000,
         rarity = 250000,
         coefficient = 100,
         categories = {
            "elona.furniture"
         }
      },
      {
         _id = "recipe",
         elona_id = 783,
         image = "elona.item_recipe",
         value = 1000,
         weight = 50,
         on_read = function() end,
         category = 54000,
         rarity = 50000,
         coefficient = 0,

         elona_type = "book",

         categories = {
            "elona.spellbook"
         }
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
      {
         _id = "bottle_of_salt",
         elona_id = 785,
         image = "elona.item_bottle_of_salt",
         value = 80,
         weight = 80,
         category = 57000,
         rarity = 100000,
         coefficient = 0,
         originalnameref2 = "bottle",

         food_rank = 1,

         rftags = { "flavor" },

         categories = {
            "elona.food"
         }
      },
      {
         _id = "sack_of_sugar",
         elona_id = 786,
         image = "elona.item_sack_of_sugar",
         value = 50,
         weight = 120,
         category = 57000,
         rarity = 100000,
         coefficient = 0,
         originalnameref2 = "sack",

         food_rank = 4,

         rftags = { "flavor" },

         categories = {
            "elona.food"
         }
      },
      {
         _id = "puff_puff_bread",
         elona_id = 787,
         image = "elona.item_puff_puff_bread",
         value = 350,
         weight = 350,
         expiration_date = 720,
         level = 3,
         category = 57000,
         rarity = 100000,
         coefficient = 100,

         food_rank = 5,
         param3 = 720,
         categories = {
            "elona.food"
         }
      },
      {
         _id = "skull_bow",
         elona_id = 788,
         image = "elona.item_skull_bow",
         value = 2000,
         weight = 700,
         dice_x = 1,
         dice_y = 17,
         hit_bonus = -18,
         damage_bonus = 10,
         material = "elona.metal",
         level = 15,
         category = 24000,
         equip_slots = { "elona.ranged" },
         subcategory = 24001,
         rarity = 50000,
         coefficient = 100,

         skill = "elona.bow",

         gods = { "elona.lulwy" },

         effective_range = { 60, 90, 100, 100, 80, 60, 20, 20, 20, 20 },

         pierce_rate = 15,

         categories = {
            "elona.equip_ranged_bow",
            "elona.equip_ranged"
         }
      },
      {
         _id = "pot_for_testing",
         elona_id = 789,
         image = "elona.item_pot_for_testing",
         value = 1000,
         weight = 500,
         on_use = function() end,
         category = 59000,
         subcategory = 59500,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },

         elona_function = 15,

         categories = {
            "elona.misc_item_crafting",
            "elona.misc_item"
         }
      },
      {
         _id = "frying_pan_for_testing",
         elona_id = 790,
         image = "elona.item_frying_pan_for_testing",
         value = 1000,
         weight = 500,
         on_use = function() end,
         category = 59000,
         subcategory = 59500,
         coefficient = 100,
         _copy = {
            color = Resolver.make("elona.furniture_color"),
         },

         elona_function = 15,

         categories = {
            "elona.misc_item_crafting",
            "elona.misc_item"
         }
      },
      {
         _id = "dragon_slayer",
         elona_id = 791,
         image = "elona.item_dragon_slayer",
         value = 72000,
         weight = 22500,
         dice_x = 3,
         dice_y = 14,
         hit_bonus = -25,
         damage_bonus = 20,
         pv = 30,
         dv = -42,
         material = "elona.iron",
         level = 55,
         fltselect = 3,
         category = 10000,
         equip_slots = { "elona.hand" },
         subcategory = 10001,
         coefficient = 100,

         skill = "elona.long_sword",

         is_precious = true,
         identify_difficulty = 500,
         fixlv = "special",
         enchantments = {
            { id = 57, power = 300 },
            { id = 61, power = 200 }
         },
         categories = {
            "elona.equip_melee_broadsword",
            "elona.unique_item",
            "elona.equip_melee"
         }
      },
      {
         _id = "putitoro",
         elona_id = 792,
         image = "elona.item_putitoro",
         value = 2000,
         weight = 200,
         fltselect = 1,
         category = 57000,
         rarity = 150000,
         coefficient = 0,

         food_rank = 8,

         categories = {
            "elona.no_generate",
            "elona.food"
         }
      }
   }

data:add_multi("base.item", item)
