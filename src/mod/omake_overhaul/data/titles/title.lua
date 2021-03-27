local NpcMemory = require("mod.elona_sys.api.NpcMemory")
local I18N = require("api.I18N")
local Title = require("mod.titles.api.Title")
local MapObject = require("api.MapObject")
local Event = require("api.Event")

local function order(elona_id)
   return 100000 + elona_id * 10000
end

data:add {
   _type = "titles.title",
   _id = "decoy",
   elona_variant_ids = {
      oomsest = 0
   },
   ordering = order(0),

   localize_info = function(info)
      -- >>>>>>>> oomSEST/src/southtyris.hsp:42487 	if (title_pos == 1) { ...
      local killed = NpcMemory.killed("elona.rodlob")
      info[#info+1] = { text = I18N.get("titles.title._.omake_overhaul.decoy.info.killed", killed) }
      return info
      -- <<<<<<<< oomSEST/src/southtyris.hsp:42490 	} ..
   end,

   check_earned = function(chara)
      -- >>>>>>>> oomSEST/src/southtyris.hsp:42878 	if (npcmemory(0, 242) != 0) { ...
      return NpcMemory.killed("elona.rodlob") > 0
      -- <<<<<<<< oomSEST/src/southtyris.hsp:42883 	} ..
   end,

   on_toggle_effect = function(enabled, chara)
      -- >>>>>>>> oomSEST/src/southtyris.hsp:42435 		if (ogdata(440) == 2) { ...
      if enabled then
         chara:mod_base_skill_level("elona.action_summon_yeek", 1, "set")
      else
         chara:mod_base_skill_level("elona.action_summon_yeek", 0, "set")
      end
      -- <<<<<<<< oomSEST/src/southtyris.hsp:42439 		} ..
   end
}

data:add {
   _type = "titles.title",
   _id = "born_in_a_temple",
   elona_variant_ids = {
      oomsest = 1
   },
   ordering = order(1),

   localize_info = function(info)
      -- >>>>>>>> oomSEST/src/southtyris.hsp:42487 	if (title_pos == 1) { ...
      local killed = NpcMemory.killed("elona.tuwen")
      info[#info+1] = { text = I18N.get("titles.title._.omake_overhaul.born_in_a_temple.info.killed", killed) }
      return info
      -- <<<<<<<< oomSEST/src/southtyris.hsp:42490 	} ..
   end,

   check_earned = function(chara)
      -- >>>>>>>> oomSEST/src/southtyris.hsp:42884 	if (npcmemory(0, 257) != 0) { ...
      return NpcMemory.killed("elona.tuwen") > 0
      -- <<<<<<<< oomSEST/src/southtyris.hsp:42889 	} ..
   end
}
-- TODO title effect

data:add {
   _type = "titles.title",
   _id = "god_of_war",
   elona_variant_ids = {
      oomsest = 25
   },
   ordering = order(25),

   localize_info = function(info)
      -- >>>>>>>> oomSEST/src/southtyris.hsp:42575 	if (title_pos == 25) { ...
      local killed_bubbles = NpcMemory.killed("elona.bubble")
      local killed_blue_bubbles = NpcMemory.killed("elona.blue_bubble")
      local killed_mass_monsters = NpcMemory.killed("elona.mass_monster")
      local killed_cubes = NpcMemory.killed("elona.cube")

      info[#info+1] = { text = I18N.get("titles.title._.omake_overhaul.god_of_war.info.killed.bubbles", killed_bubbles) }
      info[#info+1] = { text = I18N.get("titles.title._.omake_overhaul.god_of_war.info.killed.blue_bubbles", killed_blue_bubbles) }
      info[#info+1] = { text = I18N.get("titles.title._.omake_overhaul.god_of_war.info.killed.mass_monsters", killed_mass_monsters) }
      info[#info+1] = { text = I18N.get("titles.title._.omake_overhaul.god_of_war.info.killed.cubes", killed_cubes) }

      return info
      -- <<<<<<<< oomSEST/src/southtyris.hsp:42578 	} ..
   end,

   check_earned = function(chara)
      -- >>>>>>>> oomSEST/src/southtyris.hsp:43030 	if (sorg(152, 0) >= 100) { ...
      return chara:base_skill_level("elona.tactics") >= 100
      -- <<<<<<<< oomSEST/src/southtyris.hsp:43035 	} ..
   end,
}

local function title_effect_god_of_war(source, params)
   -- >>>>>>>> oomSEST/src/southtyris.hsp:63950 			if (dist(cX(cc), cY(cc), dx, dy) > sdataref(3,  ...
   if Title.state("omake_overhaul.god_of_war") == "effect_on"
      and params.magic._id == "elona.swarm"
      and MapObject.is_map_object(source, "base.chara")
      and source:is_player()
   then
      local mp = params.magic_params
      mp.range = mp.range + 1
   end
   -- <<<<<<<< oomSEST/src/southtyris.hsp:63950 			if (dist(cX(cc), cY(cc), dx, dy) > sdataref(3,  ..
end
Event.register("elona_sys.on_cast_magic", "Title effect: God of War", title_effect_god_of_war, { priority = 50000 })
