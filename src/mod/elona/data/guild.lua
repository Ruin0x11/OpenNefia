local I18N = require("api.I18N")

local function order(elona_id)
   return 100000 + elona_id * 10000
end

data:add_type {
   name = "guild"
}

--
-- Mage's Guild
--

do
   data:add {
      _type = "elona.guild",
      _id = "mage"
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
      _id = "fighter"
   }

   data:add {
      _type = "elona_sys.sidequest",
      _id = "guild_fighter_joining",
      elona_id = 217,
      ordering = order(217),

      progress = {
         [1] = function()
            local target_quota = save.elona.guild_fighter_target_chara_quota
            local target_name = "chara." .. tostring(save.elona.guild_fighter_target_chara_id) .. ".name"
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
            local target_name = "chara." .. tostring(save.elona.guild_fighter_target_chara_id) .. ".name"
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
      _id = "thief"
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
            return I18N.get("sidequest._.elona.guild_thief_quota.progress._0", save.elona.guild_thief_stolen_goods_gold_value)
         end,
         [1000] = "",
      },
   }
end
