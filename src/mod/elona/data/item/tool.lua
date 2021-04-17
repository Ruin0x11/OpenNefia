local ProductionMenu = require("mod.elona.api.gui.ProductionMenu")
local Gui = require("api.Gui")
local Input = require("api.Input")
local Magic = require("mod.elona_sys.api.Magic")
local light = require("mod.elona.data.item.light")
local Rand = require("api.Rand")
local Building = require("mod.elona.api.Building")
local ItemMaterial = require("mod.elona.api.ItemMaterial")
local Enum = require("api.Enum")
local Pos = require("api.Pos")
local Chara = require("api.Chara")
local Anim = require("mod.elona_sys.api.Anim")
local Weather = require("mod.elona.api.Weather")

--
-- Tool
--

data:add {
   _type = "base.item",
   _id = "alchemy_kit",
   elona_id = 127,
   image = "elona.item_alchemy_kit",
   value = 1960,
   weight = 900,
   category = 59000,
   coefficient = 100,
   random_color = "Furniture",

   on_use = function(self, params)
      ProductionMenu:new(params.chara, "elona.alchemy"):query()
      return "turn_end"
   end,

   categories = {
      "elona.misc_item"
   }
}

data:add {
   _type = "base.item",
   _id = "sewing_kit",
   elona_id = 160,
   image = "elona.item_sewing_kit",
   value = 780,
   weight = 500,
   category = 59000,
   coefficient = 100,
   random_color = "Furniture",

   on_use = function(self, params)
      ProductionMenu:new(params.chara, "elona.tailoring"):query()
      return "turn_end"
   end,

   categories = {
      "elona.misc_item"
   }
}

data:add {
   _type = "base.item",
   _id = "carpenters_tool",
   elona_id = 161,
   image = "elona.item_carpenters_tool",
   value = 1250,
   weight = 500,
   category = 59000,
   coefficient = 100,
   random_color = "Furniture",

   on_use = function(self, params)
      ProductionMenu:new(params.chara, "elona.carpentry"):query()
      return "turn_end"
   end,

   categories = {
      "elona.misc_item"
   }
}

data:add {
_type = "base.item",
   _id = "tight_rope",
   elona_id = 219,
   image = "elona.item_rope",
   value = 180,
   weight = 340,
   category = 59000,
   subcategory = 64000,
   coefficient = 100,
   random_color = "Furniture",

   on_use = function(self, params)
      -- >>>>>>>> shade2/action.hsp:2074 	case effRope ...
      local chara = params.chara
      if chara:is_player() then
         Gui.mes("action.use.rope.prompt")
         if not Input.yes_no() then
            return "turn_end"
         end
      end

      chara:damage_hp(math.max(chara.hp + 1, 99999), "elona.tight_rope")
      -- <<<<<<<< shade2/action.hsp:2079 	swbreak ..
   end,

   categories = {
      "elona.junk_in_field",
      "elona.misc_item"
   }
}

data:add {
   _type = "base.item",
   _id = "pot",
   elona_id = 223,
   image = "elona.item_pot",
   value = 150,
   weight = 15000,
   category = 59000,
   coefficient = 100,

   on_use = function(self, params)
      Magic.cast("elona.cooking", { source = params.chara, item = self })
   end,
   params = { cooking_quality = 60 },
   categories = {
      "elona.misc_item"
   }
}

data:add {
   _type = "base.item",
   _id = "campfire",
   elona_id = 255,
   image = "elona.item_campfire",
   value = 1860,
   weight = 12000,
   category = 59000,
   coefficient = 100,

   on_use = function(self, params)
      Magic.cast("elona.cooking", { source = params.chara, item = self })
   end,
   params = { cooking_quality = 40 },
   categories = {
      "elona.misc_item"
   },

   light = light.torch,
   ambient_sounds = { "base.bg_fire" },
}

data:add {
   _type = "base.item",
   _id = "portable_cooking_tool",
   elona_id = 256,
   image = "elona.item_portable_cooking_tool",
   value = 1860,
   weight = 1200,
   category = 59000,
   coefficient = 100,

   on_use = function(self, params)
      Magic.cast("elona.cooking", { source = params.chara, item = self })
   end,
   params = { cooking_quality = 80 },
   categories = {
      "elona.misc_item"
   }
}

data:add {
   _type = "base.item",
   _id = "fishing_pole",
   elona_id = 342,
   image = "elona.item_fishing_pole",
   value = 1200,
   weight = 2400,
   category = 59000,
   coefficient = 100,

   params = { bait_type = "elona.water_flea", bait_amount = 0 },

   on_use = function(self, params)
      Magic.cast("elona.fishing", { source = params.chara, item = self })
   end,

   elona_function = 16,
   param1 = 60,
   categories = {
      "elona.misc_item"
   }
}

data:add {
   _type = "base.item",
   _id = "gem_cutter",
   elona_id = 393,
   image = "elona.item_gem_cutter",
   value = 2000,
   weight = 500,
   category = 59000,
   coefficient = 100,
   random_color = "Furniture",

   on_use = function(self, params)
      ProductionMenu:new(params.chara, "elona.jeweler"):query()
      return "turn_end"
   end,

   categories = {
      "elona.misc_item"
   }
}

data:add {
   _type = "base.item",
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
}

data:add {
   _type = "base.item",
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

   params = { disc_music_id = "" },
   on_init_params = function(self, params)
      self.disc_music_id = Rand.choice(data["base.music"]:iter())._id
   end,

   tags = { "sf" },
   random_color = "Furniture",
   categories = {
      "elona.tag_sf",
      "elona.misc_item"
   },
   light = light.item
}

data:add {
   _type = "base.item",
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

   params = {
      shelter_serial_no = 0
   },

   categories = {
      "elona.misc_item"
   },

   light = light.item
}

data:add {
   _type = "base.item",
   _id = "register",
   elona_id = 562,
   image = "elona.item_register",
   value = 1500,
   weight = 20000,
   on_use = function()
      Building.query_house_board()
      return "player_turn_query"
   end,
   fltselect = 1,
   category = 59000,
   coefficient = 100,

   elona_function = 8,

   prevent_sell_in_own_shop = true,

   categories = {
      "elona.no_generate",
      "elona.misc_item"
   }
}

data:add {
   _type = "base.item",
   _id = "fireproof_blanket",
   elona_id = 567,
   image = "elona.item_blanket",
   value = 2400,
   weight = 800,
   charge_level = 12,
   category = 59000,
   rarity = 500000,
   coefficient = 0,

   on_init_params = function(self)
      self.charges = 12 + Rand.rnd(12) - Rand.rnd(12)
   end,
   has_charge = true,

   color = { 255, 155, 155 },

   categories = {
      "elona.misc_item"
   }
}

data:add {
   _type = "base.item",
   _id = "coldproof_blanket",
   elona_id = 568,
   image = "elona.item_blanket",
   value = 2400,
   weight = 800,
   charge_level = 12,
   category = 59000,
   rarity = 500000,
   coefficient = 0,

   on_init_params = function(self)
      self.charges = 12 + Rand.rnd(12) - Rand.rnd(12)
   end,
   has_charge = true,

   color = { 175, 175, 255 },

   categories = {
      "elona.misc_item"
   }
}

data:add {
   _type = "base.item",
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
}

data:add {
   _type = "base.item",
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

   params = {
      bank_gold_stored = 0,
      bank_gold_increment = 0,
   },

   on_init_params = function(self, params)
      -- >>>>>>>> shade2/item.hsp:69 	moneyBox =500,2000,10000,50000,500000,5000000,100 ..
      local BANK_INCREMENTS = { 500, 2000, 10000, 50000, 500000, 5000000, 100000000 }
      -- <<<<<<<< shade2/item.hsp:69 	moneyBox =500,2000,10000,50000,500000,5000000,100 ..
      -- >>>>>>>> shade2/item.hsp:661 	if iId(ci)=idMoneyBox{ ..
      local idx = Rand.rnd(Rand.rnd(#BANK_INCREMENTS) + 1) + 1
      self.params.bank_gold_increment = BANK_INCREMENTS[idx]
      self.value = 2000 + idx * idx + idx * 100
      -- <<<<<<<< shade2/item.hsp:664 		} ..
   end,

   categories = {
      "elona.misc_item"
   },

   light = light.item
}

data:add {
   _type = "base.item",
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
}

data:add {
   _type = "base.item",
   _id = "house_board",
   elona_id = 611,
   image = "elona.item_house_board",
   value = 3500,
   weight = 1200,
   category = 59000,
   rarity = 50000,
   coefficient = 100,

   elona_function = 8,
   on_use = function()
      Building.query_house_board()
      return "player_turn_query"
   end,

   categories = {
      "elona.misc_item"
   }
}

data:add {
   _type = "base.item",
   _id = "disguise_set",
   elona_id = 629,
   image = "elona.item_disguise_set",
   value = 7200,
   weight = 3500,
   charge_level = 4,
   on_use = function() end,
   level = 5,
   category = 59000,
   rarity = 100000,
   coefficient = 0,

   elona_function = 20,
   on_init_params = function(self)
      self.charges = 4 + Rand.rnd(4) - Rand.rnd(4)
   end,
   has_charge = true,
   categories = {
      "elona.misc_item"
   }
}

data:add {
   _type = "base.item",
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

   on_init_params = function(self, params)
      -- >>>>>>>> shade2/item.hsp:669 	if iId(ci)=idMaterialKit{ ..
      local material = ItemMaterial.choose_random_material(self)
      ItemMaterial.apply_item_material(self, material)
      -- <<<<<<<< shade2/item.hsp:672 		} ..
   end,

   before_wish = function(filter, chara)
      -- >>>>>>>> shade2/command.hsp:1587 		if p=idMaterialKit:objFix=2 ..
      filter.quality = Enum.Quality.Normal
      return filter
      -- <<<<<<<< shade2/command.hsp:1587 		if p=idMaterialKit:objFix=2 ..
   end,

   tags = { "noshop", "spshop" },

   categories = {
      "elona.tag_noshop",
      "elona.tag_spshop",
      "elona.misc_item"
   }
}

data:add {
   _type = "base.item",
   _id = "leash",
   elona_id = 634,
   image = "elona.item_leash",
   value = 1200,
   weight = 1200,
   category = 59000,
   rarity = 500000,
   coefficient = 0,

   elona_function = 23,
   on_use = function(self, params)
      -- >>>>>>>> shade2/action.hsp:1872 	case effLeash ...
      local chara = params.chara
      Gui.mes("action.use.leash.prompt")
      local dir, canceled = Input.query_direction()
      if canceled then
         Gui.mes("common.it_is_impossible")
         return "player_turn_query"
      end

      local x, y = Pos.add_direction(dir, chara.x, chara.y)
      local target = Chara.at(x, y)
      if target == nil then
         Gui.mes("common.it_is_impossible")
         return "player_turn_query"
      end

      if target:is_player() then
         Gui.mes("action.use.leash.self")
      else
         if target.leashed_to == nil then
            if not target:is_in_player_party() and Rand.one_in(5) then
               Gui.mes("action.use.leash.other.start.resists", target)
               self.amount = self.amount - 1
               self:refresh_cell_on_map()
               chara:refresh_weight()
               return "turn_end"
            end

            target.leashed_to = chara.uid
            Gui.mes("action.use.leash.other.start.text", target)
            Gui.mes_c("action.use.leash.other.start.dialog", "SkyBlue", target)
         else
            target.leashed_to = nil
            Gui.mes("action.use.leash.other.stop.text", target)
            Gui.mes_c("action.use.leash.other.stop.dialog", "SkyBlue", target)
         end
      end

      local anim = Anim.load("elona.anim_smoke", target.x, target.y)
      Gui.start_draw_callback(anim)

      return "turn_end"
      -- <<<<<<<< shade2/action.hsp:1894 	swbreak ..
   end,

   categories = {
      "elona.misc_item"
   }
}

data:add {
   _type = "base.item",
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
}

data:add {
   _type = "base.item",
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
}

data:add {
   _type = "base.item",
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
   quality = Enum.Quality.Unique,
   categories = {
      "elona.unique_weapon",
      "elona.misc_item"
   }
}

data:add {
   _type = "base.item",
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
}

data:add {
   _type = "base.item",
   _id = "statue_of_opatos",
   elona_id = 665,
   image = "elona.item_statue_of_opatos",
   value = 100000,
   weight = 15000,
   fltselect = 3,
   category = 59000,
   rarity = 800000,
   coefficient = 100,
   originalnameref2 = "statue",

   elona_function = 26,
   is_precious = true,
   cooldown_hours = 240,
   quality = Enum.Quality.Unique,
   categories = {
      "elona.unique_item",
      "elona.misc_item"
   }
}

data:add {
   _type = "base.item",
   _id = "statue_of_lulwy",
   elona_id = 666,
   image = "elona.item_statue_of_lulwy",
   value = 100000,
   weight = 14000,
   fltselect = 3,
   category = 59000,
   rarity = 800000,
   coefficient = 100,
   originalnameref2 = "statue",

   on_use = function(self, params, result)
      -- >>>>>>>> shade2/action.hsp:2008 	case effRenewWeather ...
      Gui.mes("action.use.statue.activate", self:build_name(1))
      Gui.play_sound("base.pray1", self.x, self.y)

      local w = Weather.get()

      if w._id == "elona.etherwind" then
         Gui.mes_c("action.use.statue.lulwy.during_etherwind", "Yellow")
      else
         local choose_weather = function()
            if Rand.one_in(10) then
               return "elona.sunny"
            end
            if Rand.one_in(10) then
               return "elona.rain"
            end
            if Rand.one_in(15) then
               return "elona.hard_rain"
            end
            if Rand.one_in(20) then
               return "elona.snow"
            end
            return nil
         end
         local next_weather_id = fun.tabulate(choose_weather):filter(function(i) return i and i ~= w._id end):nth(1)
         Weather.change_to(next_weather_id)
         Gui.mes_c("action.use.statue.lulwy.normal", "Yellow")
         Gui.mes("action.weather.changes")
      end
      -- <<<<<<<< shade2/action.hsp:2025 	swbreak ..
   end,

   is_precious = true,
   cooldown_hours = 120,
   quality = Enum.Quality.Unique,
   categories = {
      "elona.unique_item",
      "elona.misc_item"
   }
}

data:add {
   _type = "base.item",
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
   quality = Enum.Quality.Unique,
   categories = {
      "elona.unique_item",
      "elona.misc_item"
   }
}

data:add {
   _type = "base.item",
   _id = "secret_treasure",
   elona_id = 672,
   image = "elona.item_secret_treasure",
   value = 5000,
   weight = 1000,
   fltselect = 3,
   category = 59000,
   rarity = 800000,
   coefficient = 100,

   params = { secret_treasure_trait = "elona.perm_good" },

   elona_function = 29,
   is_precious = true,
   quality = Enum.Quality.Unique,
   categories = {
      "elona.unique_item",
      "elona.misc_item"
   }
}

data:add {
   _type = "base.item",
   _id = "lulwys_gem_stone_of_god_speed",
   elona_id = 680,
   image = "elona.item_gemstone",
   value = 50000,
   weight = 1200,
   fltselect = 3,
   category = 59000,
   rarity = 800000,
   coefficient = 100,
   originalnameref2 = "Lulwy's gem stone",

   elona_function = 30,
   is_precious = true,
   param1 = 446,
   param2 = 300,
   cooldown_hours = 12,
   quality = Enum.Quality.Unique,

   color = { 175, 175, 255 },

   categories = {
      "elona.unique_item",
      "elona.misc_item"
   }
}

data:add {
   _type = "base.item",
   _id = "jures_gem_stone_of_holy_rain",
   elona_id = 681,
   image = "elona.item_gemstone",
   value = 50000,
   weight = 1200,
   fltselect = 3,
   category = 59000,
   rarity = 800000,
   coefficient = 100,
   originalnameref2 = "Jure's gem stone",

   elona_function = 30,
   is_precious = true,
   param1 = 404,
   param2 = 400,
   cooldown_hours = 8,
   quality = Enum.Quality.Unique,

   color = { 225, 225, 255 },

   categories = {
      "elona.unique_item",
      "elona.misc_item"
   }
}

data:add {
   _type = "base.item",
   _id = "kumiromis_gem_stone_of_rejuvenation",
   elona_id = 682,
   image = "elona.item_gemstone",
   value = 50000,
   weight = 1200,
   fltselect = 3,
   category = 59000,
   rarity = 800000,
   coefficient = 100,
   originalnameref2 = "Kumiromi's gem stone",

   elona_function = 31,
   is_precious = true,
   cooldown_hours = 72,
   quality = Enum.Quality.Unique,

   color = { 175, 255, 175 },

   categories = {
      "elona.unique_item",
      "elona.misc_item"
   }
}

data:add {
   _type = "base.item",
   _id = "gem_stone_of_mani",
   elona_id = 683,
   image = "elona.item_gemstone",
   value = 50000,
   weight = 1200,
   fltselect = 3,
   category = 59000,
   rarity = 800000,
   coefficient = 100,
   originalnameref2 = "gem stone",

   elona_function = 30,
   is_precious = true,
   param1 = 1132,
   param2 = 100,
   cooldown_hours = 24,
   quality = Enum.Quality.Unique,

   color = { 255, 155, 155 },

   categories = {
      "elona.unique_item",
      "elona.misc_item"
   }
}

data:add {
   _type = "base.item",
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
}

data:add {
   _type = "base.item",
   _id = "monster_ball",
   elona_id = 685,
   image = "elona.item_monster_ball",
   value = 4500,
   weight = 1400,
   category = 59000,
   rarity = 400000,
   coefficient = 100,

   elona_function = 33,

   params = {
      monster_ball_captured_chara_id = nil,
      monster_ball_captured_chara_level = 0,
      monster_ball_max_level = 0
   },

   on_init_params = function(self, params)
      -- >>>>>>>> shade2/item.hsp:665 	if iId(ci)=idMonsterBall{ ..
      self.params.monster_ball_max_level = Rand.rnd(params.level + 1) + 1
      self.value = 2000 + self.params.monster_ball_max_level * self.params.monster_ball_max_level
         + self.params.monster_ball_max_level * 100
      -- <<<<<<<< shade2/item.hsp:668 		} ..
   end,

   on_throw = function(self, params)
      -- >>>>>>>> shade2/action.hsp:17 	if iId(ci)=idMonsterBall{ ...
      local map = params.chara:current_map()
      local clone = self:clone()
      if map and map:can_take_object(clone) then
         assert(map:take_object(clone, params.x, params.y))
         clone.amount = 1
      end
      -- <<<<<<<< shade2/action.hsp:21 		} ..

      -- >>>>>>>> shade2/action.hsp:27 		snd seThrow2 ...
      Gui.play_sound("base.throw2", params.x, params.y)
      map:refresh_tile(params.x, params.y)
      local target = Chara.at(params.x, params.y, map)
      if target then
         Gui.mes("action.throw.hits", target)

         -- >>>>>>>> shade2/action.hsp:32 			if iId(ci)=idMonsterBall{ ...
         if not config.base.development_mode then
            if target:is_ally() or target:has_any_roles() or target:calc("quality") == Enum.Quality.Unique or target:calc("is_precious") then
               Gui.mes("action.throw.monster_ball.cannot_be_captured")
               return "turn_end"
            end

            if target:calc("level") > clone.params.monster_ball_max_level then
               Gui.mes("action.throw.monster_ball.not_enough_power")
               return "turn_end"
            end

            if target.hp > target:calc("max_hp") / 10 then
               Gui.mes("action.throw.monster_ball.not_weak_enough")
               return "turn_end"
            end
         end

         Gui.mes_c("action.throw.monster_ball.capture", "Green", target)
         local anim = Anim.load("elona.anim_smoke", params.x, params.y)
         Gui.start_draw_callback(anim)

         clone.params.monster_ball_captured_chara_id = target._id
         clone.params.monster_ball_captured_chara_level = target.level
         clone.weight = math.clamp(target.weight, 10000, 100000)
         clone.value = 1000
         clone.can_throw = false
         -- <<<<<<<< shade2/action.hsp:43 				 ..

         -- >>>>>>>> shade2/action.hsp:49 			chara_vanquish tc ...
         target:vanquish() -- triggers "elona_sys.on_quest_check" via "base.on_chara_vanquished"
         -- <<<<<<<< shade2/action.hsp:50 			check_quest ..
      end
      -- <<<<<<<< shade2/action.hsp:31 			txtMore:txt lang(name(tc)+"に見事に命中した！","It hits  ..

      return "turn_end"
   end,

   on_use = function(self, params)
      -- >>>>>>>> shade2/action.hsp:2082 	case effMonsterBall ...
      local source = params.chara
      if self.params.monster_ball_captured_chara_id == nil then
         Gui.mes("action.use.monster_ball.empty")
         return "player_turn_query"
      end

      if not source:can_recruit_allies() then
         Gui.mes("action.use.monster_ball.party_is_full")
         return "player_turn_query"
      end

      Gui.mes("action.use.monster_ball.use", self:build_name(1))
      self.amount = self.amount - 1
      self:refresh_cell_on_map()

      -- TODO void
      local chara = Chara.create(self.params.monster_ball_captured_chara_id, source.x, source.y, {}, source:current_map())
      source:recruit_as_ally(chara)
      -- <<<<<<<< shade2/action.hsp:2089 	swbreak ..
   end,

   categories = {
      "elona.misc_item"
   }
}

data:add {
   _type = "base.item",
   _id = "statue_of_jure",
   elona_id = 686,
   image = "elona.item_statue_of_jure",
   value = 100000,
   weight = 12000,
   fltselect = 3,
   category = 59000,
   rarity = 800000,
   coefficient = 100,
   originalnameref2 = "statue",

   elona_function = 34,
   is_precious = true,
   cooldown_hours = 720,
   quality = Enum.Quality.Unique,
   categories = {
      "elona.unique_item",
      "elona.misc_item"
   }
}

data:add {
   _type = "base.item",
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
   },

   events = {
      {
         id = "elona.on_item_steal_attempt",
         name = "The iron maiden falls forward!",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:514 			if iId(ci)=idDeath1:if rnd(15)=0:rowActEnd cc:t ...
            if Rand.one_in(15) then
               local chara = params.chara
               chara:remove_activity()
               Gui.mes("activity.iron_maiden")
               chara:damage_hp(9999, "elona.iron_maiden")
               return "turn_end"
            end
            -- <<<<<<<< shade2/proc.hsp:514 			if iId(ci)=idDeath1:if rnd(15)=0:rowActEnd cc:t ..
         end
      },
   },
}

data:add {
   _type = "base.item",
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
   },

   events = {
      {
         id = "elona.on_item_steal_attempt",
         name = "The guillotine is activated!",

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:514 			if iId(ci)=idDeath1:if rnd(15)=0:rowActEnd cc:t ...
            if Rand.one_in(15) then
               local chara = params.chara
               chara:remove_activity()
               Gui.mes("activity.guillotine")
               chara:damage_hp(9999, "elona.guillotine")
               return "turn_end"
            end
            -- <<<<<<<< shade2/proc.hsp:514 			if iId(ci)=idDeath1:if rnd(15)=0:rowActEnd cc:t ..
         end
      },
   },
}

data:add {
   _type = "base.item",
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

   light = light.item,

   on_throw = function(self, params)
      -- >>>>>>>> shade2/action.hsp:27 		snd seThrow2 ...
      local map = params.chara:current_map()

      Gui.play_sound("base.throw2", params.x, params.y)
      map:refresh_tile(params.x, params.y)
      local target = Chara.at(params.x, params.y)
      if target then
         Gui.mes("action.throw.hits", target)

         -- >>>>>>>> shade2/action.hsp:45 				if (cId(tc)!319)or(tc<maxFollower):txtNothingH ...
         if target._id ~= "elona.little_sister" or target:is_ally() then
            Gui.mes("common.nothing_happens")
            return "turn_end"
         end

         -- TODO arena
         -- TODO pet arena
         -- TODO show house

         Chara.player():recruit_as_ally(target)
         -- <<<<<<<< shade2/action.hsp:47 				rc=tc:gosub *add_ally ..

         map:emit("elona_sys.on_quest_check") -- TODO move to IChara:recruit_as_ally()
      end
      -- <<<<<<<< shade2/action.hsp:31 			txtMore:txt lang(name(tc)+"に見事に命中した！","It hits  ..

      return "turn_end"
   end
}

data:add {
   _type = "base.item",
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
}

data:add {
   _type = "base.item",
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
}

data:add {
   _type = "base.item",
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
}

data:add {
   _type = "base.item",
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
}

data:add {
   _type = "base.item",
   _id = "statue_of_ehekatl",
   elona_id = 721,
   image = "elona.item_statue_of_ehekatl",
   value = 100000,
   weight = 12000,
   fltselect = 3,
   category = 59000,
   rarity = 800000,
   coefficient = 100,
   originalnameref2 = "statue",

   elona_function = 43,
   is_precious = true,
   cooldown_hours = 480,
   quality = Enum.Quality.Unique,
   categories = {
      "elona.unique_item",
      "elona.misc_item"
   }
}

data:add {
   _type = "base.item",
   _id = "sand_bag",
   elona_id = 733,
   image = "elona.item_sand_bag",
   value = 4800,
   weight = 8500,
   category = 59000,
   rarity = 10000,
   coefficient = 100,

   on_use = function(self, params)
      -- >>>>>>>> shade2/action.hsp:1896 	case effSandBag ...
      -- TODO show house
      local chara = params.chara

      Gui.mes("action.use.sandbag.prompt")
      local dir = Input.query_direction(chara)
      if dir == nil then
         Gui.mes("common.it_is_impossible")
         return "player_turn_query"
      end

      local x, y = Pos.add_direction(dir, chara.x, chara.y)
      local target = Chara.at(x, y)
      if target == nil then
         Gui.mes("common.it_is_impossible")
         return "player_turn_query"
      end

      if target.hp >= target:calc("max_hp") and not config.base.development_mode then
         Gui.mes("action.use.sandbag.not_weak_enough")
         return "player_turn_query"
      end

      if not target:is_player() and target:is_in_player_party() then
         Gui.mes("action.use.sandbag.ally")
         return "player_turn_query"
      end

      if target.is_hung_on_sandbag then
         Gui.mes("action.use.sandbag.already")
         return "player_turn_query"
      end

      if target:is_player() then
         Gui.mes("action.use.sandbag.self")
         return "turn_end"
      end

      -- TODO render sand bag chip if is_hung_on_sandbag
      Gui.play_sound("base.build1", x, y)
      target.is_hung_on_sandbag = true
      Gui.mes("action.use.sandbag.start", target)
      Gui.mes("action.use.leash.other.start.dialog", target)
      local anim = Anim.load("elona.anim_smoke", target.x, target.y)
      Gui.start_draw_callback(anim)
      target:refresh()
      self:remove(1)

      return "turn_end"
      -- <<<<<<<< shade2/action.hsp:1918 	swbreak ...         end,
   end,

   categories = {
      "elona.misc_item"
   }
}

data:add {
   _type = "base.item",
   _id = "plank_of_carneades",
   elona_id = 743,
   image = "elona.item_gemstone",
   value = 50000,
   weight = 1200,
   fltselect = 1,
   category = 59000,
   rarity = 800000,
   coefficient = 100,
   originalnameref2 = "plank",

   elona_function = 30,
   is_precious = true,
   param1 = 1132,
   param2 = 100,
   cooldown_hours = 24,

   color = { 255, 155, 155 },

   categories = {
      "elona.no_generate",
      "elona.misc_item"
   }
}

data:add {
   _type = "base.item",
   _id = "schrodingers_cat",
   elona_id = 744,
   image = "elona.item_gemstone",
   value = 50000,
   weight = 1200,
   fltselect = 1,
   category = 59000,
   rarity = 800000,
   coefficient = 100,

   elona_function = 30,
   is_precious = true,
   param1 = 1132,
   param2 = 100,
   cooldown_hours = 24,

   color = { 255, 155, 155 },

   categories = {
      "elona.no_generate",
      "elona.misc_item"
   }
}

data:add {
   _type = "base.item",
   _id = "heart",
   elona_id = 745,
   image = "elona.item_gemstone",
   value = 50000,
   weight = 1200,
   fltselect = 1,
   category = 59000,
   rarity = 800000,
   coefficient = 100,

   elona_function = 30,
   is_precious = true,
   param1 = 1132,
   param2 = 100,
   cooldown_hours = 24,

   color = { 255, 155, 155 },

   categories = {
      "elona.no_generate",
      "elona.misc_item"
   }
}

data:add {
   _type = "base.item",
   _id = "tamers_whip",
   elona_id = 746,
   image = "elona.item_gemstone",
   value = 50000,
   weight = 1200,
   fltselect = 1,
   category = 59000,
   rarity = 800000,
   coefficient = 100,

   elona_function = 30,
   is_precious = true,
   param1 = 1132,
   param2 = 100,
   cooldown_hours = 24,

   color = { 255, 155, 155 },

   categories = {
      "elona.no_generate",
      "elona.misc_item"
   }
}

data:add {
   _type = "base.item",
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
}

data:add {
   _type = "base.item",
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
}

data:add {
   _type = "base.item",
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

   params = { garoks_hammer_seed = 0 },
   on_init_params = function(self)
      self.params.garoks_hammer_seed = Rand.rnd(20000) + 1
   end,

   quality = Enum.Quality.Unique,
   medal_value = 94,
   categories = {
      "elona.unique_item",
      "elona.misc_item"
   },
   light = light.item
}

data:add {
   _type = "base.item",
   _id = "statue_of_kumiromi",
   elona_id = 776,
   image = "elona.item_statue_of_kumiromi",
   value = 100000,
   weight = 15000,
   fltselect = 3,
   category = 59000,
   rarity = 800000,
   coefficient = 100,
   originalnameref2 = "statue",

   elona_function = 26,
   is_precious = true,
   cooldown_hours = 240,
   quality = Enum.Quality.Unique,
   categories = {
      "elona.unique_item",
      "elona.misc_item"
   }
}

data:add {
   _type = "base.item",
   _id = "statue_of_mani",
   elona_id = 777,
   image = "elona.item_statue_of_mani",
   value = 100000,
   weight = 15000,
   fltselect = 3,
   category = 59000,
   rarity = 800000,
   coefficient = 100,
   originalnameref2 = "statue",

   elona_function = 26,
   is_precious = true,
   cooldown_hours = 240,
   quality = Enum.Quality.Unique,
   categories = {
      "elona.unique_item",
      "elona.misc_item"
   }
}

--
-- Crafting Tool
--

data:add {
   _type = "base.item",
   _id = "pot_for_testing",
   elona_id = 789,
   image = "elona.item_pot_for_testing",
   value = 1000,
   weight = 500,
   category = 59000,
   subcategory = 59500,
   coefficient = 100,
   random_color = "Furniture",

   on_use = function(self, params)
      Magic.cast("elona.cooking", { source = params.chara, item = self })
   end,

   categories = {
      "elona.misc_item_crafting",
      "elona.misc_item"
   }
}

data:add {
   _type = "base.item",
   _id = "frying_pan_for_testing",
   elona_id = 790,
   image = "elona.item_frying_pan_for_testing",
   value = 1000,
   weight = 500,
   category = 59000,
   subcategory = 59500,
   coefficient = 100,
   random_color = "Furniture",

   on_use = function(self, params)
      Magic.cast("elona.cooking", { source = params.chara, item = self })
   end,

   categories = {
      "elona.misc_item_crafting",
      "elona.misc_item"
   }
}
