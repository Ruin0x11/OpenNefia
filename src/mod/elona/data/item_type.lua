local categories = {
   {
      _id = "equip_melee",
      ordering = 10000,
   },
   {
      _id = "equip_head",
      ordering = 12000,
   },
   {
      _id = "equip_shield",
      ordering = 14000,
   },
   {
      _id = "equip_body",
      ordering = 16000,
   },
   {
      _id = "equip_leg",
      ordering = 18000,
   },
   {
      _id = "equip_cloak",
      ordering = 19000,
   },
   {
      _id = "equip_back",
      ordering = 20000,
   },
   {
      _id = "equip_wrist",
      ordering = 22000,
   },
   {
      _id = "equip_ranged",
      ordering = 24000,
   },
   {
      _id = "equip_ammo",
      ordering = 25000,
   },
   {
      _id = "equip_ring",
      ordering = 32000,
   },
   {
      _id = "equip_neck",
      ordering = 34000,
   },
   {
      _id = "drink",
      ordering = 52000,
   },
   {
      _id = "scroll",
      ordering = 53000,
   },
   {
      _id = "spellbook",
      ordering = 54000,
   },
   {
      _id = "book",
      ordering = 55000,
   },
   {
      _id = "rod",
      ordering = 56000,
   },
   {
      _id = "food",
      ordering = 57000,
   },
   {
      _id = "misc_item",
      ordering = 59000,
   },
   {
      _id = "furniture",
      ordering = 60000,
   },
   {
      _id = "furniture_well",
      ordering = 60001,
   },
   {
      _id = "furniture_altar",
      ordering = 60002,
   },
   {
      _id = "remains",
      ordering = 62000,
   },
   {
      _id = "junk",
      ordering = 64000,
   },
   {
      _id = "gold",
      ordering = 68000,
   },
   {
      _id = "platinum",
      ordering = 69000,
   },
   {
      _id = "container",
      ordering = 72000,
   },
   {
      _id = "ore",
      ordering = 77000,
   },
   {
      _id = "tree",
      ordering = 80000,
   },
   {
      _id = "cargo_food",
      ordering = 91000,
   },
   {
      _id = "cargo",
      ordering = 92000,
   },
   {
      _id = "bug",
      ordering = 99999999,
      parents = {
         "elona.bug"
      }
   },
}

local subcategories = {
   {
      _id = "equip_melee_broadsword",
      ordering = 10001,
      parents = {
         "elona.equip_melee"
      }
   },
   {
      _id = "equip_melee_long_sword",
      ordering = 10002,
      parents = {
         "elona.equip_melee"
      }
   },
   {
      _id = "equip_melee_short_sword",
      ordering = 10003,
      parents = {
         "elona.equip_melee"
      }
   },
   {
      _id = "equip_melee_club",
      ordering = 10004,
      parents = {
         "elona.equip_melee"
      }
   },
   {
      _id = "equip_melee_hammer",
      ordering = 10005,
      parents = {
         "elona.equip_melee"
      }
   },
   {
      _id = "equip_melee_staff",
      ordering = 10006,
      parents = {
         "elona.equip_melee"
      }
   },
   {
      _id = "equip_melee_lance",
      ordering = 10007,
      parents = {
         "elona.equip_melee"
      }
   },
   {
      _id = "equip_melee_halberd",
      ordering = 10008,
      parents = {
         "elona.equip_melee"
      }
   },
   {
      _id = "equip_melee_hand_axe",
      ordering = 10009,
      parents = {
         "elona.equip_melee"
      }
   },
   {
      _id = "equip_melee_axe",
      ordering = 10010,
      parents = {
         "elona.equip_melee"
      }
   },
   {
      _id = "equip_melee_scythe",
      ordering = 10011,
      parents = {
         "elona.equip_melee"
      }
   },
   {
      _id = "equip_head_helm",
      ordering = 12001,
      parents = {
         "elona.equip_head"
      }
   },
   {
      _id = "equip_head_hat",
      ordering = 12002,
      parents = {
         "elona.equip_head"
      }
   },
   {
      _id = "equip_shield_shield",
      ordering = 14003,
      parents = {
         "elona.equip_shield"
      }
   },
   {
      _id = "equip_body_mail",
      ordering = 16001,
      parents = {
         "elona.equip_body"
      }
   },
   {
      _id = "equip_body_robe",
      ordering = 16003,
      parents = {
         "elona.equip_body"
      }
   },
   {
      _id = "equip_leg_heavy_boots",
      ordering = 18001,
      parents = {
         "elona.equip_leg"
      }
   },
   {
      _id = "equip_leg_shoes",
      ordering = 18002,
      parents = {
         "elona.equip_leg"
      }
   },
   {
      _id = "equip_back_girdle",
      ordering = 19001,
      parents = {
         "elona.equip_cloak"
      }
   },
   {
      _id = "equip_back_cloak",
      ordering = 20001,
      parents = {
         "elona.equip_back"
      }
   },
   {
      _id = "equip_wrist_gauntlet",
      ordering = 22001,
      parents = {
         "elona.equip_wrist"
      }
   },
   {
      _id = "equip_wrist_glove",
      ordering = 22003,
      parents = {
         "elona.equip_wrist"
      }
   },
   {
      _id = "equip_ranged_bow",
      ordering = 24001,
      parents = {
         "elona.equip_ranged"
      }
   },
   {
      _id = "equip_ranged_crossbow",
      ordering = 24003,
      parents = {
         "elona.equip_ranged"
      }
   },
   {
      _id = "equip_ranged_gun",
      ordering = 24020,
      parents = {
         "elona.equip_ranged"
      }
   },
   {
      _id = "equip_ranged_laser_gun",
      ordering = 24021,
      parents = {
         "elona.equip_ranged"
      }
   },
   {
      _id = "equip_ranged_thrown",
      ordering = 24030,
      parents = {
         "elona.equip_ranged"
      }
   },
   {
      _id = "equip_ammo_arrow",
      ordering = 25001,
      parents = {
         "elona.equip_ammo"
      }
   },
   {
      _id = "equip_ammo_bolt",
      ordering = 25002,
      parents = {
         "elona.equip_ammo"
      }
   },
   {
      _id = "equip_ammo_bullet",
      ordering = 25020,
      parents = {
         "elona.equip_ammo"
      }
   },
   {
      _id = "equip_ammo_energy_cell",
      ordering = 25030,
      parents = {
         "elona.equip_ammo"
      }
   },
   {
      _id = "equip_ring_ring",
      ordering = 32001,
      parents = {
         "elona.equip_ring"
      }
   },
   {
      _id = "equip_neck_armor",
      ordering = 34001,
      parents = {
         "elona.equip_neck"
      }
   },
   {
      _id = "drink_potion",
      ordering = 52001,
      parents = {
         "elona.drink"
      }
   },
   {
      _id = "drink_alcohol",
      ordering = 52002,
      parents = {
         "elona.drink"
      }
   },
   {
      _id = "scroll_deed",
      ordering = 53100,
      parents = {
         "elona.scroll"
      }
   },
   {
      _id = "food_flour",
      ordering = 57001,
      parents = {
         "elona.food"
      }
   },
   {
      _id = "food_noodle",
      ordering = 57002,
      parents = {
         "elona.food"
      }
   },
   {
      _id = "food_vegetable",
      ordering = 57003,
      parents = {
         "elona.food"
      }
   },
   {
      _id = "food_fruit",
      ordering = 57004,
      parents = {
         "elona.food"
      }
   },
   {
      _id = "crop_herb",
      ordering = 58005,
      parents = {
         "elona.food"
      }
   },
   {
      _id = "crop_seed",
      ordering = 58500,
      parents = {
         "elona.food"
      }
   },
   {
      _id = "misc_item_crafting",
      ordering = 59500,
      parents = {
         "elona.misc_item"
      }
   },
   {
      _id = "furniture_bed", -- sleeping bag/furniture
      ordering = 60004, -- sleeping bag/furniture
   },
   {
      _id = "furniture_instrument",
      ordering = 60005,
      parents = {
         "elona.furniture"
      }
   },
   {
      -- This is only used to generate items that appear in random
      -- overworld field maps.
      _id = "junk_in_field", -- subcategory 64000
      ordering = 64000, -- subcategory 64000
   },
   {
      _id = "junk_town",
      ordering = 64100,
      parents = {
         "elona.junk"
      }
   },
   {
      _id = "ore_valuable",
      ordering = 77001,
      parents = {
         "elona.ore"
      }
   },
}

local tags = {
   {
      _id = "tag_sf"
   },
   {
      _id = "tag_fish"
   },
   {
      _id = "tag_neg"
   },
   {
      _id = "tag_noshop"
   },
   {
      _id = "tag_spshop"
   },
   {
      _id = "tag_fest"
   },
   {
      _id = "tag_nogive"
   },
}

local categories3 = {
   {
      _id = "no_generate",
      no_generate = true
   },
   {
      _id = "unique_weapon",
      no_generate = true
   },
   {
      _id = "unique_item",
      no_generate = true
   },
   {
      _id = "snow_tree",
      no_generate = true
   },
}

data:add_multi("base.item_type", categories)
data:add_multi("base.item_type", subcategories)
data:add_multi("base.item_type", tags)
data:add_multi("base.item_type", categories3)

local categories2 = {
   {
      _id = "autoidentified",

      copy_to_item = {
         identify_state = "completely",
         curse_state = "none"
      }
   },
   {
      _id = "automemorized",

      copy_to_item = {
         identify_state = "completely",
         curse_state = "none"
      },

      on_generate = function(self)
         local ItemMemory = require("mod.elona_sys.api.ItemMemory")
         Item.set_known(self, true)
      end
   },
   {
      _id = "uncursed",

      copy_to_item = {
         curse_state = "none"
      }
   },
   {
      _id = "can_sense",

      params = { threshold = 5 },

      on_generate = function(self, cat)
         local Chara = require("api.Chara")
         if Rand.rnd(Chara.player():skill("elona.sense_quality") + 1) > cat.params.threshold then
            self.identify_state = "almost"
         end
      end
   },
   {
      _id = "container",

      on_generate = function(self, cat)
         self.param1 = Resolver.resolve("elona.scale_with_dungeon_level") + 5
         self.param2 = Resolver.resolve("elona.scale_with_dungeon_level") + 1
         self.param3 = Rand.rnd(30000)
      end
   },
   {
      _id = "food",
      ordering = 57000,

      params = { min_quality = 3, max_quality = 5, cooked_chance = 50 },

      on_generate = function(self, cat, is_shop)
         local can_cook = true
         if not can_cook then
            return
         end

         local Rand = require("api.Rand")
         if is_shop then
            if Rand.percent_chance(cat.cooked_chance) then
               self.param2 = 0
            else
               self.param2 = Rand.between(cat.min_quality, cat.max_quality)
            end
         end
         if self.param2 > 0 then
            self.image = self.params.cooked_images[self.param2]
         end
         if self.material == "elona.raw" then
            local hours = 24
            self.param3 = self.param3 + hours
         end
      end
   },
   {
      _id = "furniture",
      ordering = 60000,

      params = {
         subtitles = {
            "test1",
            "test2",
            "test3",
         },
         subtitle_chance = 3 -- TODO
      },

      on_generate = function(self, cat)
         local Rand = require("api.Rand")
         if Rand.one_in(cat.params.subtitle_chance) then
            self.params.subtitle = Rand.choice(cat.params.subtitles)
         else
            self.params.subtitle = nil
         end
      end,

      on_add_data = function(self)
         self.prevent_sell_in_own_shop = true
      end
   },
   {
      _id = "bed",
      ordering = 60004,

      on_add_data = function(self)
         local event = {
            id = "base.on_use_item",
            name = "Use bed",

            callback = function(self, params)
               if save.elona_sys.awake_hours < 15 then
                  Gui.mes("not sleepy.")
                  return false
               end

               params.chara:start_activity("elona.prepare_to_sleep", {bed=self})

               return true
            end
         }
         table.insert(self.events, event)
      end
   },
   {
      _id = "gold",
      ordering = 68000,
   }
}
