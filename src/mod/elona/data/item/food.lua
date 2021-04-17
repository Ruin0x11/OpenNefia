local Gui = require("api.Gui")
local Rand = require("api.Rand")
local Skill = require("mod.elona_sys.api.Skill")
local Hunger = require("mod.elona.api.Hunger")
local Effect = require("mod.elona.api.Effect")
local Enum = require("api.Enum")
local Chara = require("api.Chara")
local IItemFromChara = require("mod.elona.api.aspect.IItemFromChara")
local IItemFood = require("mod.elona.api.aspect.IItemFood")
local IItemSeed = require("mod.elona.api.aspect.IItemSeed")

--
-- Food
--

data:add {
   _type = "base.item",
   _id = "edible_wild_plant",
   elona_id = 179,
   image = "elona.item_edible_wild_plant",
   value = 60,
   weight = 100,
   material = "elona.fresh",
   coefficient = 100,

   categories = {
      "elona.junk_in_field",
      "elona.food",
      "elona.offering_vegetable",
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.vegetable",
         spoilage_hours = 48
      }
   }
}

data:add {
   _type = "base.item",
   _id = "api_nut",
   elona_id = 191,
   image = "elona.item_api_nut",
   value = 80,
   weight = 40,
   coefficient = 100,

   categories = {
      "elona.junk_in_field",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.sweet",
      }
   }
}

data:add {
   _type = "base.item",
   _id = "healthy_leaf",
   elona_id = 193,
   image = "elona.item_healthy_leaf",
   value = 240,
   weight = 90,
   coefficient = 100,

   categories = {
      "elona.junk_in_field",
      "elona.food",
      "elona.offering_vegetable",
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.vegetable",
      }
   }
}

data:add {
   _type = "base.item",
   _id = "corpse",
   elona_id = 204,
   image = "elona.item_corpse",
   value = 80,
   weight = 2000,
   material = "elona.fresh",
   coefficient = 100,

   gods = {
      any = true
   },

   categories = {
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.meat",
         spoilage_hours = 4
      },
      IItemFromChara
   },

   on_eat = function(self, params)
      -- >>>>>>>> shade2/item.hsp:1097 	if iId(ci)=204:if iSubName(ci)=319{ ...
      local chara = params.chara
      if self:calc_aspect(IItemFromChara, "chara_id") == "elona.little_sister" then
         Gui.mes_c("food.effect.little_sister", "Green")
         if Rand.rnd(chara:base_skill_level("elona.stat_life") ^ 2 + 1) < 2000 then
            Skill.gain_fixed_skill_exp(chara, "elona.stat_life", 1000)
         end
         if Rand.rnd(chara:base_skill_level("elona.stat_mana") ^ 2 + 1) < 2000 then
            Skill.gain_fixed_skill_exp(chara, "elona.stat_mana", 1000)
         end

         for _, skill in Skill.iter_skills() do
            if chara:has_skill(skill._id) then
               Skill.modify_potential(chara, skill._id, Rand.rnd(10) + 1)
            end
         end
      end
      -- <<<<<<<< shade2/item.hsp:1105 		} ..
   end,

   events = {
      {
         id = "elona_sys.before_item_eat",
         name = "corpse effects",

         callback = function(self, params, result)
            -- >>>>>>>> shade2/item.hsp:1042 	if iId(ci)=idCorpse{ ...
            local corpse_chara_id = self:calc_aspect(IItemFromChara, "chara_id")
            if not corpse_chara_id then
               return
            end

            local chara = params.chara

            if Hunger.is_human_flesh(self) then
               if chara:has_trait("elona.eat_human") then
                  Gui.mes("food.effect.human.like")
               else
                  Gui.mes("food.effect.human.dislike")
                  Effect.damage_insanity(chara, 15)
                  chara:apply_effect("elona.insanity", 150)
                  if not chara:has_trait("elona.eat_human") and Rand.one_in(5) then
                     chara:modify_trait_level("elona.eat_human", 1)
                  end
               end
            elseif chara:has_trait("elona.eat_human") then
               Gui.mes("food.effect.human.would_have_rather_eaten")
               result.nutrition = result.nutrition * 2 / 3
            end

            local chara_proto = data["base.chara"]:ensure(corpse_chara_id)

            if chara_proto.on_eat_corpse then
               chara_proto.on_eat_corpse(self, params, result)
            end

            return result
            -- <<<<<<<< shade2/item.hsp:1066 		} ..
         end
      },
      {
         _type = "base.item",
         id = "elona.on_item_eat_begin",
         name = "itadaki-mammoth",

         callback = function(self)
            if self:calc_aspect(IItemFromChara, "chara_id") == "elona.mammoth" then
               Gui.mes("activity.eat.start.mammoth")
            end
         end
      }
   }
}

data:add {
   _type = "base.item",
   _id = "ration",
   elona_id = 233,
   image = "elona.item_sack",
   value = 280,
   weight = 400,
   level = 3,
   coefficient = 100,

   categories = {
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_quality = 3
      }
   }
}

data:add {
   _type = "base.item",
   _id = "stick_bread",
   elona_id = 258,
   image = "elona.item_stick_bread",
   value = 280,
   weight = 350,
   level = 3,
   coefficient = 100,

   categories = {
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_quality = 3
      }
   }
}

data:add {
   _type = "base.item",
   _id = "pop_corn",
   elona_id = 497,
   image = "elona.item_pop_corn",
   value = 440,
   weight = 200,
   level = 3,
   rarity = 250000,
   coefficient = 100,

   tags = { "sf", "fest" },

   categories = {
      "elona.tag_sf",
      "elona.tag_fest",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_quality = 5
      }
   }
}

data:add {
   _type = "base.item",
   _id = "fried_potato",
   elona_id = 498,
   image = "elona.item_fried_potato",
   value = 350,
   weight = 180,
   level = 3,
   rarity = 250000,
   coefficient = 100,

   tags = { "sf", "fest" },

   categories = {
      "elona.tag_sf",
      "elona.tag_fest",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_quality = 6
      }
   }
}

data:add {
   _type = "base.item",
   _id = "cyber_snack",
   elona_id = 499,
   image = "elona.item_cyber_snack",
   value = 750,
   weight = 500,
   level = 3,
   rarity = 250000,
   coefficient = 100,

   tags = { "sf", "fest" },

   categories = {
      "elona.tag_sf",
      "elona.tag_fest",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_quality = 7
      }
   }
}

data:add {
   _type = "base.item",
   _id = "jerky",
   elona_id = 571,
   image = "elona.item_jerky",
   value = 640,
   weight = 450,
   level = 3,
   rarity = 200000,
   coefficient = 100,

   _ext = {
      [IItemFood] = {
         food_quality = 5
      },
      IItemFromChara
   },

   categories = {
      "elona.food"
   },

   events = {
      {
         id = "elona_sys.before_item_eat",
         name = "jerky effects",

         callback = function(self, params, result)
            -- >>>>>>>> shade2/item.hsp:1064 	if (iId(ci)=idCorpse)or( ((iId(ci)=idJerky)or(iId ...
            local chara = self:calc_aspect(IItemFromChara, "chara_id")
            if not chara then
               return
            end

            local chara_proto = data["base.chara"]:ensure(chara)

            if chara_proto.on_eat_corpse and Rand.one_in(3) then
               chara_proto.on_eat_corpse(self, params, result)
            end

            return result
            -- <<<<<<<< shade2/item.hsp:1066 		} ..
         end
      },
   }
}

data:add {
   _type = "base.item",
   _id = "egg",
   elona_id = 573,
   image = "elona.item_egg",
   value = 500,
   weight = 300,
   rarity = 300000,
   coefficient = 100,

   categories = {
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona_egg",
         spoilage_hours = 240
      },
      IItemFromChara
   },

   events = {
      {
         id = "elona_sys.before_item_eat",
         name = "egg effects",

         callback = function(self, params, result)
            -- >>>>>>>> shade2/item.hsp:1064 	if (iId(ci)=idCorpse)or( ((iId(ci)=idJerky)or(iId ...
            local chara = self:calc_aspect(IItemFromChara, "chara_id")
            if not chara then
               return
            end

            local dat = data["base.chara"]:ensure(chara)

            if dat.on_eat_corpse and Rand.one_in(3) then
               dat.on_eat_corpse(self, params, result)
            end

            return result
            -- <<<<<<<< shade2/item.hsp:1066 		} ..
         end
      },
   },
}

data:add {
   _type = "base.item",
   _id = "hero_cheese",
   elona_id = 655,
   image = "elona.item_hero_cheese",
   value = 100000,
   weight = 500,
   fltselect = 3,
   coefficient = 100,

   is_precious = true,
   quality = Enum.Quality.Unique,

   color = { 175, 175, 255 },

   categories = {
      "elona.unique_item",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_quality = 7
      }
   },

   on_eat = function(self, params)
      -- >>>>>>>> shade2/item.hsp:1120 	if iId(ci)=idHeroCheese{ ...
      Skill.gain_fixed_skill_exp(params.chara, "elona.stat_life", 1000 * 3)
      -- <<<<<<<< shade2/item.hsp:1122 		} ..
   end
}

data:add {
   _type = "base.item",
   _id = "sisters_love_fueled_lunch",
   elona_id = 667,
   image = "elona.item_gift",
   value = 900,
   weight = 500,
   level = 3,
   fltselect = 1,
   rarity = 250000,
   coefficient = 100,

   -- >>>>>>>> shade2/item.hsp:676 	if iId(ci)=idSisterLunch{ ..
   is_handmade = true,
   -- <<<<<<<< shade2/item.hsp:678 	} ..

   categories = {
      "elona.no_generate",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_quality = 7
      }
   },

   on_eat = function(self, params)
      -- >>>>>>>> shade2/item.hsp:1135 	if iId(ci)=idSisterLunch{ ...
      local chara = params.chara
      Gui.mes("food.effect.sisters_love_fueled_lunch", chara)
      Effect.heal_insanity(chara, 30)
      -- <<<<<<<< shade2/item.hsp:1138 		} ..
   end
}

data:add {
   _type = "base.item",
   _id = "rabbits_tail",
   elona_id = 702,
   image = "elona.item_rabbits_tail",
   value = 10000,
   weight = 150,
   fltselect = 3,
   coefficient = 100,

   is_precious = true,
   quality = Enum.Quality.Unique,

   color = { 255, 155, 155 },

   categories = {
      "elona.unique_item",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_quality = 4
      }
   },

   on_eat = function(self, params)
      -- >>>>>>>> shade2/item.hsp:1112 	if iId(ci)=idRabbitTail{ ...
      Skill.gain_fixed_skill_exp(params.chara, "elona.stat_luck", 1000)
      -- <<<<<<<< shade2/item.hsp:1114 		} ..
   end,
}

data:add {
   _type = "base.item",
   _id = "fortune_cookie",
   elona_id = 738,
   image = "elona.item_fortune_cookie",
   value = 250,
   weight = 50,
   rarity = 400000,
   coefficient = 0,

   tags = { "fest" },

   categories = {
      "elona.tag_fest",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_quality = 6,
         nutrition = 750
      }
   },

   on_eat = function(self, params)
      -- >>>>>>>> shade2/item.hsp:1127 	if iId(ci)=idCookie:if cc<maxFollower{ ...
      local chara = params.chara
      if chara:is_in_player_party() then
         Gui.mes("food.effect.fortune_cookie", chara)
         local id = "talk.random.fortune_cookie.normal"
         if self:calc("curse_state") >= Enum.CurseState.Blessed then
            id = "talk.random.fortune_cookie.blessed"
         end
         Gui.mes_c(id, "Yellow")
      end
      -- <<<<<<<< shade2/item.hsp:1132 		} ..
   end
}

data:add {
   _type = "base.item",
   _id = "kagami_mochi",
   elona_id = 755,
   image = "elona.item_kagami_mochi",
   value = 2500,
   weight = 800,
   fltselect = 1,
   rarity = 400000,
   coefficient = 0,

   categories = {
      "elona.no_generate",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_quality = 6,
      }
   },

   on_eat = function(self, params)
      -- >>>>>>>> shade2/item.hsp:1107 	if iId(ci)=idKagamiMochi{ ...
      Gui.mes("food.effect.kagami_mochi")
      Skill.gain_fixed_skill_exp(params.chara, "elona.stat_luck", 2000)
      -- <<<<<<<< shade2/item.hsp:1110 	} ..
   end,

   events = {
      {
         id = "elona_sys.after_item_eat",
         name = "Choking behavior",
         priority = 150000,

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:1151 	if(iId(ci)=idKagamiMochi and rnd(3))or(iId(ci)=id ...
            local chance = 3
            if Rand.one_in(chance) then
               local chara = params.chara
               if chara:is_in_fov() then
                  Gui.mes_c("food.mochi.chokes", "Purple", chara)
                  Gui.mes_c("food.mochi.dialog")
               end
               chara:add_effect_turns("elona.choking", 1)
            end
            -- <<<<<<<< shade2/proc.hsp:1154 	} ..
         end
      }
   },
}

data:add {
   _type = "base.item",
   _id = "mochi",
   elona_id = 756,
   image = "elona.item_mochi",
   value = 800,
   weight = 350,
   rarity = 150000,
   coefficient = 0,

   tags = { "fest" },

   categories = {
      "elona.tag_fest",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_quality = 7,
      }
   },

   events = {
      {
         id = "elona_sys.after_item_eat",
         name = "Choking behavior",
         priority = 150000,

         callback = function(self, params)
            -- >>>>>>>> shade2/proc.hsp:1151 	if(iId(ci)=idKagamiMochi and rnd(3))or(iId(ci)=id ...
            local chance = 10
            if Rand.one_in(chance) then
               local chara = params.chara
               if chara:is_in_fov() then
                  Gui.mes_c("food.mochi.chokes", "Purple", chara)
                  Gui.mes_c("food.mochi.dialog")
               end
               chara:add_effect_turns("elona.choking", 1)
            end
            -- <<<<<<<< shade2/proc.hsp:1154 	} ..
         end
      }
   },
}

data:add {
   _type = "base.item",
   _id = "special_steamed_meat_bun",
   elona_id = 775,
   image = "elona.item_special_steamed_meat_bun",
   value = 160,
   weight = 250,
   level = 3,
   rarity = 50000,
   coefficient = 100,

   is_precious = true,
   categories = {
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_quality = 8,
      }
   },
}

data:add {
   _type = "base.item",
   _id = "bottle_of_salt",
   elona_id = 785,
   image = "elona.item_bottle_of_salt",
   value = 80,
   weight = 80,
   rarity = 100000,
   coefficient = 0,
   originalnameref2 = "bottle",

   rftags = { "flavor" },

   categories = {
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_quality = 1,
      }
   },
}

data:add {
   _type = "base.item",
   _id = "sack_of_sugar",
   elona_id = 786,
   image = "elona.item_sack_of_sugar",
   value = 50,
   weight = 120,
   rarity = 100000,
   coefficient = 0,
   originalnameref2 = "sack",

   rftags = { "flavor" },

   categories = {
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_quality = 4,
      }
   },
}

data:add {
   _type = "base.item",
   _id = "puff_puff_bread",
   elona_id = 787,
   image = "elona.item_puff_puff_bread",
   value = 350,
   weight = 350,
   level = 3,
   rarity = 100000,
   coefficient = 100,

   categories = {
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_quality = 5,
         spoilage_hours = 720
      }
   },
}

data:add {
   _type = "base.item",
   _id = "putitoro",
   elona_id = 792,
   image = "elona.item_putitoro",
   value = 2000,
   weight = 200,
   fltselect = 1,
   rarity = 150000,
   coefficient = 0,

   categories = {
      "elona.no_generate",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_quality = 8,
      }
   },
}

--
-- Flour
--

data:add {
   _type = "base.item",
   _id = "sack_of_flour",
   elona_id = 260,
   image = "elona.item_sack",
   value = 280,
   weight = 800,
   level = 3,
   rarity = 5000000,
   coefficient = 100,
   originalnameref2 = "sack",

   categories = {
      "elona.food_flour",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.bread",
         spoilage_hours = 240
      }
   },
}

--
-- Noodle
--

data:add {
   _type = "base.item",
   _id = "raw_noodle",
   elona_id = 259,
   image = "elona.item_sack",
   value = 280,
   weight = 400,
   material = "elona.fresh",
   level = 3,
   rarity = 5000000,
   coefficient = 100,

   categories = {
      "elona.food_noodle",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.pasta",
         spoilage_hours = 24
      }
   }
}

--
-- Vegetable
--

data:add {
   _type = "base.item",
   _id = "quwapana",
   elona_id = 177,
   image = "elona.item_quwapana",
   value = 80,
   weight = 160,
   material = "elona.fresh",
   coefficient = 100,

   categories = {
      "elona.food_vegetable",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.fruit",
         spoilage_hours = 72
      }
   }
}

data:add {
   _type = "base.item",
   _id = "aloe",
   elona_id = 178,
   image = "elona.item_stomafillia",
   value = 70,
   weight = 170,
   material = "elona.fresh",
   coefficient = 100,

   categories = {
      "elona.food_vegetable",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.fruit",
         spoilage_hours = 72
      }
   }
}

data:add {
   _type = "base.item",
   _id = "guava",
   elona_id = 184,
   image = "elona.item_guava",
   value = 80,
   weight = 620,
   material = "elona.fresh",
   coefficient = 100,

   categories = {
      "elona.food_vegetable",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.fruit",
         spoilage_hours = 8
      }
   }
}

data:add {
   _type = "base.item",
   _id = "carrot",
   elona_id = 185,
   image = "elona.item_carrot",
   value = 40,
   weight = 420,
   material = "elona.fresh",
   coefficient = 100,

   categories = {
      "elona.food_vegetable",
      "elona.food",
      "elona.offering_vegetable"
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.vegetable",
         spoilage_hours = 72
      }
   }
}

data:add {
   _type = "base.item",
   _id = "radish",
   elona_id = 186,
   image = "elona.item_radish",
   value = 50,
   weight = 950,
   material = "elona.fresh",
   coefficient = 100,

   categories = {
      "elona.food_vegetable",
      "elona.food",
      "elona.offering_vegetable"
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.vegetable",
         spoilage_hours = 72
      }
   }
}

data:add {
   _type = "base.item",
   _id = "sweet_potato",
   elona_id = 187,
   image = "elona.item_sweet_potato",
   value = 40,
   weight = 790,
   coefficient = 100,

   tags = { "fest" },

   categories = {
      "elona.food_vegetable",
      "elona.tag_fest",
      "elona.food",
      "elona.offering_vegetable"
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.vegetable",
      }
   }
}

data:add {
   _type = "base.item",
   _id = "lettuce",
   elona_id = 188,
   image = "elona.item_lettuce",
   value = 50,
   weight = 650,
   material = "elona.fresh",
   coefficient = 100,

   categories = {
      "elona.food_vegetable",
      "elona.food",
      "elona.offering_vegetable"
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.vegetable",
         spoilage_hours = 72
      }
   }
}

data:add {
   _type = "base.item",
   _id = "imo",
   elona_id = 190,
   image = "elona.item_imo",
   value = 70,
   weight = 650,
   coefficient = 100,

   categories = {
      "elona.food_vegetable",
      "elona.food",
      "elona.offering_vegetable"
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.vegetable",
      }
   }
}

data:add {
   _type = "base.item",
   _id = "green_pea",
   elona_id = 198,
   image = "elona.item_green_pea",
   value = 260,
   weight = 360,
   material = "elona.fresh",
   coefficient = 100,

   categories = {
      "elona.food_vegetable",
      "elona.food",
      "elona.offering_vegetable"
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.vegetable",
         spoilage_hours = 72
      }
   }
}

data:add {
   _type = "base.item",
   _id = "cbocchi",
   elona_id = 199,
   image = "elona.item_cbocchi",
   value = 80,
   weight = 970,
   material = "elona.fresh",
   coefficient = 100,

   categories = {
      "elona.food_vegetable",
      "elona.food",
      "elona.offering_vegetable"
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.vegetable",
         spoilage_hours = 72
      }
   }
}

data:add {
   _type = "base.item",
   _id = "melon",
   elona_id = 200,
   image = "elona.item_melon",
   value = 30,
   weight = 840,
   material = "elona.fresh",
   coefficient = 100,

   categories = {
      "elona.food_vegetable",
      "elona.food",
      "elona.offering_vegetable"
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.vegetable",
         spoilage_hours = 72
      }
   }
}

data:add {
   _type = "base.item",
   _id = "leccho",
   elona_id = 201,
   image = "elona.item_leccho",
   value = 70,
   weight = 550,
   material = "elona.fresh",
   coefficient = 100,

   categories = {
      "elona.food_vegetable",
      "elona.food",
      "elona.offering_vegetable"
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.vegetable",
         spoilage_hours = 2
      }
   }
}

--
-- Fruit
--

data:add {
   _type = "base.item",
   _id = "apple",
   elona_id = 180,
   image = "elona.item_happy_apple",
   value = 180,
   weight = 720,
   material = "elona.fresh",
   coefficient = 100,

   categories = {
      "elona.food_fruit",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.fruit",
         spoilage_hours = 16
      }
   }
}

data:add {
   _type = "base.item",
   _id = "grape",
   elona_id = 181,
   image = "elona.item_grape",
   value = 220,
   weight = 510,
   material = "elona.fresh",
   coefficient = 100,

   categories = {
      "elona.food_fruit",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.fruit",
         spoilage_hours = 16
      }
   }
}

data:add {
   _type = "base.item",
   _id = "kiwi",
   elona_id = 182,
   image = "elona.item_kiwi",
   value = 190,
   weight = 440,
   material = "elona.fresh",
   coefficient = 100,

   categories = {
      "elona.food_fruit",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.fruit",
         spoilage_hours = 12
      }
   }
}

data:add {
   _type = "base.item",
   _id = "cherry",
   elona_id = 183,
   image = "elona.item_cherry",
   value = 170,
   weight = 220,
   material = "elona.fresh",
   coefficient = 100,

   categories = {
      "elona.food_fruit",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.fruit",
         spoilage_hours = 16
      }
   }
}

data:add {
   _type = "base.item",
   _id = "strawberry",
   elona_id = 192,
   image = "elona.item_strawberry",
   value = 260,
   weight = 720,
   material = "elona.fresh",
   coefficient = 100,

   categories = {
      "elona.food_fruit",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.fruit",
         spoilage_hours = 16
      }
   }
}

data:add {
   _type = "base.item",
   _id = "rainbow_fruit",
   elona_id = 194,
   image = "elona.item_rainbow_fruit",
   value = 220,
   weight = 1070,
   material = "elona.fresh",
   coefficient = 100,

   categories = {
      "elona.food_fruit",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.fruit",
         spoilage_hours = 8
      }
   }
}

data:add {
   _type = "base.item",
   _id = "qucche",
   elona_id = 195,
   image = "elona.item_qucche",
   value = 100,
   weight = 560,
   material = "elona.fresh",
   coefficient = 100,

   categories = {
      "elona.food_fruit",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.fruit",
         spoilage_hours = 12
      }
   }
}

data:add {
   _type = "base.item",
   _id = "orange",
   elona_id = 196,
   image = "elona.item_orange",
   value = 130,
   weight = 880,
   material = "elona.fresh",
   coefficient = 100,

   categories = {
      "elona.food_fruit",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.fruit",
         spoilage_hours = 8
      }
   }
}

data:add {
   _type = "base.item",
   _id = "lemon",
   elona_id = 197,
   image = "elona.item_magic_fruit",
   value = 240,
   weight = 440,
   material = "elona.fresh",
   coefficient = 100,

   categories = {
      "elona.food_fruit",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.fruit",
         spoilage_hours = 12
      }
   }
}

data:add {
   _type = "base.item",
   _id = "happy_apple",
   elona_id = 639,
   image = "elona.item_happy_apple",
   value = 100000,
   weight = 720,
   fltselect = 3,
   coefficient = 100,

   is_precious = true,
   quality = Enum.Quality.Unique,

   color = { 225, 225, 255 },

   categories = {
      "elona.food_fruit",
      "elona.unique_item",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_quality = 7
      }
   },

   on_eat = function(self, params)
      -- >>>>>>>> shade2/item.hsp:1116 	if iId(ci)=idHappyApple{ ...
      Skill.gain_fixed_skill_exp(params.chara, "elona.stat_luck", 1000 * 20)
      -- <<<<<<<< shade2/item.hsp:1118 		} ..
   end
}

data:add {
   _type = "base.item",
   _id = "magic_fruit",
   elona_id = 662,
   image = "elona.item_magic_fruit",
   value = 100000,
   weight = 440,
   fltselect = 3,
   coefficient = 100,

   is_precious = true,
   quality = Enum.Quality.Unique,

   color = { 255, 155, 155 },

   categories = {
      "elona.food_fruit",
      "elona.unique_item",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_quality = 7
      }
   },

   on_eat = function(self, params)
      -- >>>>>>>> shade2/item.hsp:1124 	if iId(ci)=idMagicFruit{ ...
      Skill.gain_fixed_skill_exp(params.chara, "elona.stat_mana", 1000 * 3)
      -- <<<<<<<< shade2/item.hsp:1126 		} ..
   end
}

data:add {
   _type = "base.item",
   _id = "tomato",
   elona_id = 772,
   image = "elona.item_tomato",
   value = 90,
   weight = 330,
   material = "elona.fresh",
   coefficient = 100,

   categories = {
      "elona.food_fruit",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_type = "elona.vegetable",
         spoilage_hours = 32
      }
   },

   on_throw = function(self, params)
      -- >>>>>>>> shade2/action.hsp:57 		if sync(tlocX,tlocY) : if iId(ci)=idSnow{ ...
      local map = params.chara:current_map()
      if map:is_in_fov(params.x, params.y) then
         Gui.play_sound("base.crush2", params.x, params.y)
      end

      local target = Chara.at(params.x, params.y)
      if target then
         Gui.mes("action.throw.hits", target)
         -- <<<<<<<< shade2/action.hsp:69 			} ..
         -- >>>>>>>> shade2/action.hsp:70 			if iId(ci)=idTomato{ ...
         if map:is_in_fov(params.x, params.y) then
            Gui.mes_c("action.throw.tomato", "Blue")
         end
         local food = self:get_aspect(IItemFood)
         if food and food:is_rotten(self) then
            Gui.mes_c_visible("damage.is_engulfed_in_fury", target, "Blue")
            target:add_effect_turns("elona.fury", Rand.rnd(10) + 5)
         end
         return "turn_end"
         -- <<<<<<<< shade2/action.hsp:77 			}	 ...               return "turn_end"
      end

      -- >>>>>>>> shade2/action.hsp:106 		if iId(ci)=idTomato{ ...
      if map:is_in_fov(params.x, params.y) then
         Gui.mes_c("action.throw.tomato", "Blue")
      end
      return "turn_end"
      -- <<<<<<<< shade2/action.hsp:109 		} ...            return "turn_end"
   end,
}

--
-- Seed
--

data:add {
   _type = "base.item",
   _id = "vegetable_seed",
   elona_id = 417,
   image = "elona.item_seed",
   value = 240,
   weight = 40,
   coefficient = 100,

   color = { 175, 255, 175 },

   categories = {
      "elona.crop_seed",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_quality = 1
      },
      [IItemSeed] = {
         plant_id = "elona.vegetable"
      }
   },
}

data:add {
   _type = "base.item",
   _id = "fruit_seed",
   elona_id = 418,
   image = "elona.item_seed",
   value = 280,
   weight = 40,
   rarity = 800000,
   coefficient = 100,

   color = { 255, 255, 175 },

   categories = {
      "elona.crop_seed",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_quality = 1
      },
      [IItemSeed] = {
         plant_id = "elona.fruit"
      }
   },
}

data:add {
   _type = "base.item",
   _id = "herb_seed",
   elona_id = 419,
   image = "elona.item_seed",
   value = 1800,
   weight = 40,
   rarity = 100000,
   coefficient = 100,

   color = { 175, 175, 255 },

   categories = {
      "elona.crop_seed",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_quality = 1
      },
      [IItemSeed] = {
         plant_id = "elona.herb"
      }
   },
}

data:add {
   _type = "base.item",
   _id = "unknown_seed",
   elona_id = 420,
   image = "elona.item_seed",
   value = 2500,
   weight = 40,
   rarity = 250000,
   coefficient = 100,
   random_color = "Furniture",

   categories = {
      "elona.crop_seed",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_quality = 1
      },
      [IItemSeed] = {
         plant_id = "elona.unknown_plant"
      }
   },
}

data:add {
   _type = "base.item",
   _id = "artifact_seed",
   elona_id = 421,
   image = "elona.item_seed",
   value = 120000,
   weight = 40,
   rarity = 20000,
   coefficient = 100,

   tags = { "noshop", "spshop" },
   color = { 255, 215, 175 },
   medal_value = 15,
   categories = {
      "elona.crop_seed",
      "elona.tag_noshop",
      "elona.tag_spshop",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_quality = 1
      },
      [IItemSeed] = {
         plant_id = "elona.artifact"
      }
   }
}

data:add {
   _type = "base.item",
   _id = "gem_seed",
   elona_id = 553,
   image = "elona.item_seed",
   value = 4500,
   weight = 40,
   rarity = 250000,
   coefficient = 100,

   color = { 185, 155, 215 },

   categories = {
      "elona.crop_seed",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_quality = 1
      },
      [IItemSeed] = {
         plant_id = "elona.gem"
      }
   }
}

data:add {
   _type = "base.item",
   _id = "magical_seed",
   elona_id = 554,
   image = "elona.item_seed",
   value = 3500,
   weight = 40,
   rarity = 250000,
   coefficient = 100,

   color = { 155, 205, 205 },

   categories = {
      "elona.crop_seed",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_quality = 1
      },
      [IItemSeed] = {
         plant_id = "elona.magical_plant"
      }
   }
}

--
-- Herb
--

data:add {
   _type = "base.item",
   _id = "morgia",
   elona_id = 422,
   image = "elona.item_stomafillia",
   value = 1050,
   weight = 250,
   rarity = 80000,
   coefficient = 100,

   categories = {
      "elona.crop_herb",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_quality = 1,
         nutrition = 500,
         exp_gains = {
            { _id = "elona.stat_strength", amount = 900 },
            { _id = "elona.stat_constitution", amount = 700 },
            { _id = "elona.stat_charisma", amount = 10 },
            { _id = "elona.stat_magic", amount = 10 },
            { _id = "elona.stat_dexterity", amount = 10 },
            { _id = "elona.stat_perception", amount = 10 },
            { _id = "elona.stat_learning", amount = 10 },
            { _id = "elona.stat_will", amount = 10 },
         },
      }
   },

   events = {
      {
         id = "elona_sys.before_item_eat",
         name = "morgia effects",

         callback = function(self, params)
            params.chara:mod_skill_potential("elona.stat_strength", 2)
            params.chara:mod_skill_potential("elona.stat_constitution", 2)
            if params.chara:is_player() then
               Gui.mes("food.effect.herb.morgia")
            end
         end
      }
   },
}

data:add {
   _type = "base.item",
   _id = "mareilon",
   elona_id = 423,
   image = "elona.item_stomafillia",
   value = 800,
   weight = 210,
   rarity = 80000,
   coefficient = 100,

   _ext = {
      [IItemFood] = {
         food_quality = 4,
         nutrition = 500,
         exp_gains = {
            { _id = "elona.stat_strength", amount = 10 },
            { _id = "elona.stat_constitution", amount = 10 },
            { _id = "elona.stat_charisma", amount = 10 },
            { _id = "elona.stat_magic", amount = 800 },
            { _id = "elona.stat_dexterity", amount = 10 },
            { _id = "elona.stat_perception", amount = 10 },
            { _id = "elona.stat_learning", amount = 10 },
            { _id = "elona.stat_will", amount = 800 },
         },
      }
   },

   events = {
      {
         id = "elona_sys.before_item_eat",
         name = "marelion effects",

         callback = function(self, params)
            params.chara:mod_skill_potential("elona.stat_magic", 2)
            params.chara:mod_skill_potential("elona.stat_will", 2)
            if params.chara:is_player() then
               Gui.mes("food.effect.herb.mareilon")
            end
         end
      }
   },

   categories = {
      "elona.crop_herb",
      "elona.food"
   }
}

data:add {
   _type = "base.item",
   _id = "spenseweed",
   elona_id = 424,
   image = "elona.item_stomafillia",
   value = 900,
   weight = 220,
   rarity = 80000,
   coefficient = 100,

   categories = {
      "elona.crop_herb",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_quality = 3,
         nutrition = 500,
         exp_gains = {
            { _id = "elona.stat_strength", amount = 10 },
            { _id = "elona.stat_constitution", amount = 10 },
            { _id = "elona.stat_charisma", amount = 10 },
            { _id = "elona.stat_magic", amount = 10 },
            { _id = "elona.stat_dexterity", amount = 750 },
            { _id = "elona.stat_perception", amount = 800 },
            { _id = "elona.stat_learning", amount = 10 },
            { _id = "elona.stat_will", amount = 10 },
         },
      }
   },

   events = {
      {
         id = "elona_sys.before_item_eat",
         name = "spenseweed effects",

         callback = function(self, params)
            params.chara:mod_skill_potential("elona.stat_dexterity", 2)
            params.chara:mod_skill_potential("elona.stat_perception", 2)
            if params.chara:is_player() then
               Gui.mes("food.effect.herb.spenseweed")
            end
         end
      }
   },
}

data:add {
   _type = "base.item",
   _id = "curaria",
   elona_id = 425,
   image = "elona.item_stomafillia",
   value = 680,
   weight = 260,
   coefficient = 100,

   _ext = {
      [IItemFood] = {
         food_quality = 6,
         nutrition = 2500,
         exp_gains = {
            { _id = "elona.stat_strength", amount = 100 },
            { _id = "elona.stat_constitution", amount = 100 },
            { _id = "elona.stat_charisma", amount = 100 },
            { _id = "elona.stat_magic", amount = 100 },
            { _id = "elona.stat_dexterity", amount = 100 },
            { _id = "elona.stat_perception", amount = 100 },
            { _id = "elona.stat_learning", amount = 100 },
            { _id = "elona.stat_will", amount = 100 },
         },
      }
   },

   events = {
      {
         id = "elona_sys.before_item_eat",
         name = "curaria effects",

         callback = function(self, params)
            if params.chara:is_player() then
               Gui.mes("food.effect.herb.curaria")
            end
         end
      }
   },

   categories = {
      "elona.crop_herb",
      "elona.food"
   }
}

data:add {
   _type = "base.item",
   _id = "alraunia",
   elona_id = 426,
   image = "elona.item_stomafillia",
   value = 1200,
   weight = 120,
   rarity = 80000,
   coefficient = 100,

   categories = {
      "elona.crop_herb",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_quality = 3,
         nutrition = 500,
         exp_gains = {
            { _id = "elona.stat_strength", amount = 10 },
            { _id = "elona.stat_constitution", amount = 10 },
            { _id = "elona.stat_charisma", amount = 850 },
            { _id = "elona.stat_magic", amount = 10 },
            { _id = "elona.stat_dexterity", amount = 10 },
            { _id = "elona.stat_perception", amount = 10 },
            { _id = "elona.stat_learning", amount = 700 },
            { _id = "elona.stat_will", amount = 10 },
         },
      }
   },

   events = {
      {
         id = "elona_sys.before_item_eat",
         name = "alraunia effects",

         callback = function(self, params)
            params.chara:mod_skill_potential("elona.stat_charisma", 2)
            params.chara:mod_skill_potential("elona.stat_learning", 2)
            if params.chara:is_player() then
               Gui.mes("food.effect.herb.alraunia")
            end
         end
      }
   },
}

data:add {
   _type = "base.item",
   _id = "stomafillia",
   elona_id = 427,
   image = "elona.item_stomafillia",
   value = 800,
   weight = 480,
   coefficient = 100,

   categories = {
      "elona.crop_herb",
      "elona.food"
   },

   _ext = {
      [IItemFood] = {
         food_quality = 7,
         nutrition = 20000,
         exp_gains = {
            { _id = "elona.stat_strength", amount = 50 },
            { _id = "elona.stat_constitution", amount = 50 },
            { _id = "elona.stat_charisma", amount = 50 },
            { _id = "elona.stat_magic", amount = 50 },
            { _id = "elona.stat_dexterity", amount = 50 },
            { _id = "elona.stat_perception", amount = 50 },
            { _id = "elona.stat_learning", amount = 50 },
            { _id = "elona.stat_will", amount = 50 },
         },
      }
   }
}
