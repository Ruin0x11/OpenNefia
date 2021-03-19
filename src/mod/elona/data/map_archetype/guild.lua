local MapEntrance = require("mod.elona_sys.api.MapEntrance")
local util = require("mod.elona.data.map_archetype.util")
local Elona122Map = require("mod.elona_sys.map_loader.Elona122Map")
local Chara = require("api.Chara")
local I18N = require("api.I18N")
local DeferredEvent = require("mod.elona_sys.api.DeferredEvent")
local DeferredEvents = require("mod.elona.api.DeferredEvents")
local Area = require("api.Area")

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
      trainer_skills = {
         "elona.pickpocket",
         "elona.disarm_trap",
         "elona.lock_picking",
         "elona.stealth",
         "elona.marksman",
      }
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
   chara:add_role("elona.special")

   chara = Chara.create("elona.trainer", 3, 6, nil, map)
   chara:add_role("elona.trainer")
   chara.name = I18N.get("chara.job.trainer", chara.name)

   chara = Chara.create("elona.wizard", 3, 12, nil, map)
   chara:add_role("elona.identifier")

   chara = Chara.create("elona.shopkeeper", 5, 18, nil, map)
   chara:add_role("elona.shopkeeper", {inventory_id = "elona.blackmarket"})
   chara.shop_rank = 10
   chara.name = I18N.get("chara.job.blackmarket", chara.name)

   chara = Chara.create("elona.shopkeeper", 27, 13, nil, map)
   chara:add_role("elona.shopkeeper", {inventory_id = "elona.blackmarket"})
   chara.shop_rank = 10
   chara.name = I18N.get("chara.job.blackmarket", chara.name)

   chara = Chara.create("elona.shopkeeper", 21, 19, nil, map)
   chara:add_role("elona.shopkeeper", {inventory_id = "elona.the_fence"})
   chara.shop_rank = 10
   chara.name = I18N.get("chara.job.fence", chara.name)

   for _=1, 16 do
      Chara.create("elona.thief_guild_member", nil, nil, nil, map)
   end

   return map
end


function thieves_guild.on_map_entered_events(map, params)
   local prev_map = params.previous_map
   local prev_x = params.previous_x
   local prev_y = params.previous_y
   util.connect_stair_at_to_prev_map(map, 8, 9, prev_map, prev_x, prev_y)

   -- >>>>>>>> shade2/map.hsp:2032 	if areaId(gArea)=areaKapul{ ...
   DeferredEvent.add(function()
         DeferredEvents.proc_guild_intruder("elona.thief", Chara.player(), map)
   end)
   -- <<<<<<<< shade2/map.hsp:2034 		} ..
end

data:add(thieves_guild)


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
      trainer_skills = {
         "elona.weight_lifting",
         "elona.dual_wield",
         "elona.two_hand",
         "elona.heavy_armor",
         "elona.tactics",
         "elona.marksman",
         "elona.shield",
         "elona.eye_of_mind",
      }
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
   chara:add_role("elona.special")

   chara = Chara.create("elona.healer", 28, 10, nil, map)
   chara:add_role("elona.healer")

   chara = Chara.create("elona.trainer", 15, 10, nil, map)
   chara:add_role("elona.trainer")
   chara.name = I18N.get("chara.job.trainer", chara.name)

   chara = Chara.create("elona.wizard", 14, 18, nil, map)
   chara:add_role("elona.identifier")

   chara = Chara.create("elona.shopkeeper", 29, 15, nil, map)
   chara:add_role("elona.shopkeeper", {inventory_id = "elona.blacksmith"})
   chara.shop_rank = 12
   chara.name = I18N.get("chara.job.blacksmith", chara.name)

   for _=1, 16 do
      Chara.create("elona.fighter_guild_member", nil, nil, nil, map)
   end

   return map
end

function fighters_guild.on_map_entered_events(map, params)
   local prev_map = params.previous_map
   local prev_x = params.previous_x
   local prev_y = params.previous_y
   util.connect_stair_at_to_prev_map(map, 16, 1, prev_map, prev_x, prev_y)

   -- >>>>>>>> shade2/map.hsp:2032 	if areaId(gArea)=areaKapul{ ...
   DeferredEvent.add(function()
         DeferredEvents.proc_guild_intruder("elona.fighter", Chara.player(), map)
   end)
   -- <<<<<<<< shade2/map.hsp:2034 		} ..
end

data:add(fighters_guild)


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
      trainer_skills = {
         "elona.casting",
         "elona.memorization",
         "elona.meditation",
         "elona.magic_capacity",
         "elona.alchemy",
         "elona.control_magic",
         "elona.light_armor",
         "elona.greater_evasion",
      }
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
   chara:add_role("elona.special")

   chara = Chara.create("elona.wizard", 27, 8, nil, map)
   chara:add_role("elona.shopkeeper", { inventory_id="spell_writer" })
   chara:add_role("elona.spell_writer")
   chara.name = I18N.get("chara.job.spell_writer", chara.name)

   chara = Chara.create("elona.wizard", 22, 8, nil, map)
   chara:add_role("elona.shopkeeper", { inventory_id = "elona.magic_vendor" })
   chara.shop_rank = 11
   chara.name = I18N.get("chara.job.magic_vendor", chara.name)

   chara = Chara.create("elona.healer", 3, 9, nil, map)
   chara:add_role("elona.healer")

   chara = Chara.create("elona.trainer", 12, 6, nil, map)
   chara:add_role("elona.trainer")
   chara.name = I18N.get("chara.job.trainer", chara.name)

   chara = Chara.create("elona.wizard", 3, 3, nil, map)
   chara:add_role("elona.identifier")

   for _=1, 16 do
      Chara.create("elona.mage_guild_member", nil, nil, nil, map)
   end

   return map
end

function mages_guild.on_map_entered_events(map, params)
   local prev_map = params.previous_map
   local prev_x = params.previous_x
   local prev_y = params.previous_y
   util.connect_stair_at_to_prev_map(map, 13, 14, prev_map, prev_x, prev_y)

   -- >>>>>>>> shade2/map.hsp:2026 	if areaId(gArea)=areaLumiest{ ...
   DeferredEvent.add(function()
         DeferredEvents.proc_guild_intruder("elona.mage", Chara.player(), map)
   end)
   -- <<<<<<<< shade2/map.hsp:2028 		} ..
end

data:add(mages_guild)
