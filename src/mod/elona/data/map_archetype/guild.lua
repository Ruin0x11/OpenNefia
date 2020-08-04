local MapEntrance = require("mod.elona_sys.api.MapEntrance")
local util = require("mod.elona.data.map_archetype.util")
local Elona122Map = require("mod.elona_sys.map_loader.Elona122Map")
local Chara = require("api.Chara")
local I18N = require("api.I18N")

local thieves_guild = {
   _type = "base.map_archetype",
   _id = "thieves_guild",

   starting_pos = MapEntrance.stairs_up,

   properties = {
      music = "elona.ruin",
      types = { "guild" },
      level = 3,
      is_indoor = true,
      max_crowd_density = 25,
   },
}

thieves_guild.chara_filter = util.chara_filter_town(
   function()
      return { id = "elona.thief_guild_member" }
   end
)

function thieves_guild.on_generate_map()
   local map = Elona122Map.generate("thiefguild")
   map:set_archetype("elona.thieves_guild", { set_properties = true })

   local chara = Chara.create("elona.sin", 21, 9, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.trainer", 3, 6, nil, map)
   chara.roles["elona.trainer"] = true
   chara.name = I18N.get("chara.job.trainer", chara.name)

   chara = Chara.create("elona.wizard", 3, 12, nil, map)
   chara.roles["elona.wizard"] = true

   chara = Chara.create("elona.shopkeeper", 5, 18, nil, map)
   chara.roles["elona.shopkeeper"] = {inventory_id = "elona.blackmarket"}
   chara.shop_rank = 10
   chara.name = I18N.get("chara.job.blackmarket", chara.name)

   chara = Chara.create("elona.shopkeeper", 27, 13, nil, map)
   chara.roles["elona.shopkeeper"] = {inventory_id = "elona.blackmarket"}
   chara.shop_rank = 10
   chara.name = I18N.get("chara.job.blackmarket", chara.name)

   chara = Chara.create("elona.shopkeeper", 21, 19, nil, map)
   chara.roles["elona.shopkeeper"] = {inventory_id = "elona.the_fence"}
   chara.shop_rank = 10
   chara.name = I18N.get("chara.job.fence", chara.name)

   for _=1, 16 do
      Chara.create("elona.thief_guild_member", nil, nil, nil, map)
   end

   return map
end
data:add(thieves_guild)

data:add {
   _type = "base.area_archetype",
   _id = "thieves_guild",

   floors = {
      [1] = "elona.thieves_guild"
   }
}


local fighters_guild = {
   _type = "base.map_archetype",
   _id = "fighters_guild",

   starting_pos = MapEntrance.stairs_up,

   properties = {
      music = "elona.ruin",
      types = { "guild" },
      level = 3,
      is_indoor = true,
      max_crowd_density = 25,
   },
}

fighters_guild.chara_filter = util.chara_filter_town(
   function()
      return { id = "elona.fighter_guild_member" }
   end
)

function fighters_guild.on_generate_map()
   local map = Elona122Map.generate("fighterguild")
   map:set_archetype("elona.fighters_guild", { set_properties = true })

   local chara = Chara.create("elona.fray", 27, 4, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.healer", 28, 10, nil, map)
   chara.roles["elona.healer"] = true

   chara = Chara.create("elona.trainer", 15, 10, nil, map)
   chara.roles["elona.trainer"] = true
   chara.name = I18N.get("chara.job.trainer", chara.name)

   chara = Chara.create("elona.wizard", 14, 18, nil, map)
   chara.roles["elona.wizard"] = true

   chara = Chara.create("elona.blacksmith", 29, 15, nil, map)
   chara.roles["elona.shopkeeper"] = {inventory_id = "elona.blacksmith"}
   chara.shop_rank = 12
   chara.name = I18N.get("chara.job.blacksmith", chara.name)

   for _=1, 16 do
      Chara.create("elona.fighter_guild_member", nil, nil, nil, map)
   end

   return map
end
data:add(fighters_guild)

data:add {
   _type = "base.area_archetype",
   _id = "fighters_guild",

   floors = {
      [1] = "elona.fighters_guild"
   }
}


local mages_guild = {
   _type = "base.map_archetype",
   _id = "mages_guild",

   starting_pos = MapEntrance.stairs_up,

   properties = {
      music = "elona.ruin",
      types = { "guild" },
      level = 3,
      is_indoor = true,
      max_crowd_density = 25,
   }
}

mages_guild.chara_filter = util.chara_filter_town(
   function()
      return { id = "elona.mage_guild_member" }
   end
)

function mages_guild.on_generate_map()
   local map = Elona122Map.generate("mageguild")
   map:set_archetype("elona.mages_guild", { set_properties = true })

   local chara = Chara.create("elona.revlus", 24, 3, nil, map)
   chara.roles["elona.special"] = true

   chara = Chara.create("elona.wizard", 27, 8, nil, map)
   chara.roles["elona.shopkeeper"] = {inventory_id="spell_writer"}
   chara.roles["elona.spell_writer"] = true
   chara.name = I18N.get("chara.job.spell_writer", chara.name)

   chara = Chara.create("elona.wizard", 22, 8, nil, map)
   chara.roles["elona.shopkeeper"] = { inventory_id = "elona.magic_vendor" }
   chara.shop_rank = 11
   chara.name = I18N.get("chara.job.magic_vendor", chara.name)

   chara = Chara.create("elona.healer", 3, 9, nil, map)
   chara.roles["elona.healer"] = true

   chara = Chara.create("elona.trainer", 12, 6, nil, map)
   chara.roles["elona.trainer"] = true
   chara.name = I18N.get("chara.job.trainer", chara.name)

   chara = Chara.create("elona.wizard", 3, 3, nil, map)
   chara.roles["elona.wizard"] = true

   for _=1, 16 do
      Chara.create("elona.mage_guild_member", nil, nil, nil, map)
   end

   return map
end

data:add(mages_guild)

data:add {
   _type = "base.area_archetype",
   _id = "mages_guild",

   floors = {
      [1] = "elona.mages_guild"
   }
}
