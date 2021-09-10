local I18N = require("api.I18N")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local Event = require("api.Event")

local function order(elona_id)
   return 100000 + elona_id * 10000
end

data:add_type {
   name = "guild",
   fields = {
      {
         name = "guest_trainer_skills",
         type = types.list(types.data_id("base.skill"))
      }
   }
}

--
-- Mage's Guild
--

do
   data:add {
      _type = "elona.guild",
      _id = "mage",

      -- >>>>>>>> shade2/chat.hsp:240 	if flagMageGuild!0{ ...
      guest_trainer_skills = {
         "elona.stat_magic",
         "elona.stat_will",
         "elona.stat_learning"
      }
      -- <<<<<<<< shade2/chat.hsp:242 		}else{ ..
   }

   data:add {
      _type = "elona_sys.sidequest",
      _id = "guild_mage_joining",
      elona_id = 216,
      ordering = order(216),

      progress = {
         [1] = function()
            return I18N.get("sidequest._.elona.guild_mage_joining.progress._0", save.elona.guild_mage_point_quota)
         end,
         [1000] = "",
      },
   }

   data:add {
      _type = "elona_sys.sidequest",
      _id = "guild_mage_quota",
      elona_id = 219,
      ordering = order(219),

      progress = {
         [1] = function()
            return I18N.get("sidequest._.elona.guild_mage_quota.progress._0", save.elona.guild_mage_point_quota)
         end,
         [1000] = "",
      },
   }
end

--
-- Fighter's Guild
--

do
   data:add {
      _type = "elona.guild",
      _id = "fighter",

      -- >>>>>>>> shade2/chat.hsp:243 	if flagFighterGuild!0{ ...
      guest_trainer_skills = {
         "elona.stat_strength",
         "elona.stat_endurance",
         "elona.stat_dexterity"
      },
      -- <<<<<<<< shade2/chat.hsp:245 		}else{ ..
   }


   data:add {
      _type = "elona_sys.sidequest",
      _id = "guild_fighter_joining",
      elona_id = 217,
      ordering = order(217),

      progress = {
         [1] = function()
            local target_quota = save.elona.guild_fighter_target_chara_quota
            local target_name = I18N.localize("base.chara", save.elona.guild_fighter_target_chara_id, "name")
            return I18N.get("sidequest._.elona.guild_fighter_joining.progress._0", target_quota, target_name)
         end,
         [1000] = "",
      },
   }

   data:add {
      _type = "elona_sys.sidequest",
      _id = "guild_fighter_quota",
      elona_id = 220,
      ordering = order(220),

      progress = {
         [1] = function()
            local target_quota = save.elona.guild_fighter_target_chara_quota
            local target_name = I18N.localize("base.chara", save.elona.guild_fighter_target_chara_id, "name")
            return I18N.get("sidequest._.elona.guild_fighter_quota.progress._0", target_quota, target_name)
         end,
         [1000] = "",
      },
   }
end

--
-- Thieves' Guild
--

do
   data:add {
      _type = "elona.guild",
      _id = "thief",

      -- >>>>>>>> shade2/chat.hsp:246 	if flagThiefGuild!0{ ...
      guest_trainer_skills = {
         "elona.stat_dexterity",
         "elona.stat_perception",
         "elona.stat_endurance",
         "elona.stat_learning",
      },
      -- <<<<<<<< shade2/chat.hsp:248 		}else{ ..
   }

   data:add {
      _type = "elona_sys.sidequest",
      _id = "guild_thief_joining",
      elona_id = 218,
      ordering = order(218),

      progress = {
         [1] = "sidequest._.elona.guild_thief_joining.progress._0",
         [1000] = "",
      },
   }

   data:add {
      _type = "elona_sys.sidequest",
      _id = "guild_thief_quota",
      elona_id = 221,
      ordering = order(221),

      progress = {
         [1] = function()
            return I18N.get("sidequest._.elona.guild_thief_quota.progress._0", save.elona.guild_thief_stolen_goods_quota)
         end,
         [1000] = "",
      },
   }
end

local function reset_guild_sidequest_progress(chara, params)
   local guild_id = params.guild_id

   -- >>>>>>>> shade2/chat.hsp:1861 			flagThiefGuild	=0 ...
   if guild_id ~= "elona.mage" then
      Sidequest.set_progress("elona.guild_mage_joining", 0)
      Sidequest.set_progress("elona.guild_mage_quota", 0)
      save.elona.guild_mage_point_quota = 0
   elseif guild_id ~= "elona.fighter" then
      Sidequest.set_progress("elona.guild_fighter_joining", 0)
      Sidequest.set_progress("elona.guild_fighter_quota", 0)
      save.elona.guild_fighter_target_chara_id = nil
      save.elona.guild_fighter_target_chara_quota = 0
   elseif guild_id ~= "elona.thief" then
      Sidequest.set_progress("elona.guild_thief_joining", 0)
      Sidequest.set_progress("elona.guild_thief_quota", 0)
      save.elona.thieves_guild_quota = 0
   end
   -- <<<<<<<< shade2/chat.hsp:1873 			sqThief1	=0 ..
end
Event.register("elona.on_chara_changed_guild", "Reset other guild sidequest progress", reset_guild_sidequest_progress)
