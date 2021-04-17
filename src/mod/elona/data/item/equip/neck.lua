local Gui = require("api.Gui")
local Skill = require("mod.elona_sys.api.Skill")
local Enum = require("api.Enum")
local light = require("mod.elona.data.item.light")

--
-- Small Amulet
--

data:add {
   _type = "base.item",
   _id = "decorative_amulet",
   elona_id = 67,
   knownnameref = "amulet",
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
}

data:add {
   _type = "base.item",
   _id = "peridot",
   elona_id = 468,
   knownnameref = "amulet",
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
   has_random_name = "ring",
   categories = {
      "elona.equip_neck_armor",
      "elona.equip_neck"
   }
}

data:add {
   _type = "base.item",
   _id = "talisman",
   elona_id = 469,
   knownnameref = "amulet",
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
   has_random_name = "ring",
   categories = {
      "elona.equip_neck_armor",
      "elona.equip_neck"
   }
}

data:add {
   _type = "base.item",
   _id = "neck_guard",
   elona_id = 470,
   knownnameref = "amulet",
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
   has_random_name = "ring",
   categories = {
      "elona.equip_neck_armor",
      "elona.equip_neck"
   }
}

data:add {
   _type = "base.item",
   _id = "charm",
   elona_id = 471,
   knownnameref = "amulet",
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
   has_random_name = "ring",
   tags = { "fest" },
   categories = {
      "elona.equip_neck_armor",
      "elona.tag_fest",
      "elona.equip_neck"
   }
}

data:add {
   _type = "base.item",
   _id = "bejeweled_amulet",
   elona_id = 472,
   knownnameref = "amulet",
   image = "elona.item_bejeweled_amulet",
   value = 1800,
   weight = 50,
   material = "elona.metal",
   level = 5,
   category = 34000,
   equip_slots = { "elona.neck" },
   subcategory = 34001,
   coefficient = 100,
   has_random_name = "ring",
   categories = {
      "elona.equip_neck_armor",
      "elona.equip_neck"
   }
}

data:add {
   _type = "base.item",
   _id = "engagement_amulet",
   elona_id = 473,
   knownnameref = "amulet",
   image = "elona.item_engagement_amulet",
   value = 5000,
   weight = 50,
   material = "elona.metal",
   category = 34000,
   equip_slots = { "elona.neck" },
   subcategory = 34001,
   rarity = 800000,
   coefficient = 100,
   has_random_name = "ring",
   categories = {
      "elona.equip_neck_armor",
      "elona.equip_neck"
   },

   events = {
      {
         id = "elona.on_item_given",
         name = "Engagement item effects",

         callback = function(self, params)
            -- >>>>>>>> shade2/command.hsp:3821 				if (iId(ci)=idRingEngage)or(iId(ci)=idAmuEngag ...
            local target = params.target
            Gui.mes_c("ui.inv.give.engagement", "Green", target)
            Skill.modify_impression(target, 15)
            target:set_emotion_icon("elona.heart", 3)
            -- <<<<<<<< shade2/command.hsp:3825 				} ..
         end
      },
      {
         id = "elona.on_item_taken",
         name = "Swallow engagement item",

         callback = function(self, params)
            -- >>>>>>>> shade2/command.hsp:3935 			if (iId(ci)=idRingEngage)or(iId(ci)=idAmuEngage ...
            local target = params.target

            Gui.mes_c("ui.inv.take_ally.swallows_ring", "Purple", target, self:build_name(1))
            Gui.play_sound("base.offer1")
            Skill.modify_impression(target, -20)
            target:set_emotion_icon("elona.angry", 3)
            self:remove(1)

            return "inventory_continue"
            -- <<<<<<<< shade2/command.hsp:3939 				} ..
         end
      },
   },
}

data:add {
   _type = "base.item",
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
   quality = Enum.Quality.Unique,

   categories = {
      "elona.equip_neck_armor",
      "elona.unique_item",
      "elona.equip_neck"
   },
   light = light.item,

   enchantments = {
      { _id = "elona.res_pregnancy", power = 100 },
      { _id = "elona.modify_attribute", power = 450, params = { skill_id = "elona.stat_charisma" } },
      { _id = "elona.res_steal", power = 100 },
   }
}

data:add {
   _type = "base.item",
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
   quality = Enum.Quality.Unique,

   color = { 185, 155, 215 },

   categories = {
      "elona.equip_neck_armor",
      "elona.unique_item",
      "elona.equip_neck"
   },

   light = light.item,

   enchantments = {
      { _id = "elona.extra_shoot", power = 600 },
      { _id = "elona.modify_skill", power = 700, params = { skill_id = "elona.crossbow" } },
   }
}

data:add {
   _type = "base.item",
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
   quality = Enum.Quality.Unique,

   color = { 255, 215, 175 },

   categories = {
      "elona.equip_neck_armor",
      "elona.unique_item",
      "elona.equip_neck"
   },

   light = light.item,

   enchantments = {
      { _id = "elona.extra_melee", power = 600 },
      { _id = "elona.modify_skill", power = 650, params = { skill_id = "elona.dual_wield" } },
   }
}

data:add {
   _type = "base.item",
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
   quality = Enum.Quality.Unique,

   color = { 175, 175, 255 },

   categories = {
      "elona.equip_neck_armor",
      "elona.unique_item",
      "elona.equip_neck"
   },

   light = light.item,

   enchantments = {
      { _id = "elona.god_talk", power = 100 },
      { _id = "elona.modify_skill", power = 550, params = { skill_id = "elona.faith" } },
      { _id = "elona.modify_resistance", power = 400, params = { element_id = "elona.sound" } },
   }
}
