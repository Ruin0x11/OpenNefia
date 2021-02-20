local global = require("mod.elona.internal.global")
local Quest = require("mod.elona_sys.api.Quest")
local Log = require("api.Log")
local Gui = require("api.Gui")
local Input = require("api.Input")
local Chara = require("api.Chara")
local Rand = require("api.Rand")
local Enum = require("api.Enum")
local Charagen = require("mod.tools.api.Charagen")

data:add {
   _type = "elona.encounter",
   _id = "assassin",

   encounter_level = function()
      -- >>>>>>>> shade2/map.hsp:1615 			flt qLevel(rq),fixGood ...
      local quest
      if global.encounter_quest_uid then
         quest = Quest.get(global.encounter_quest_uid)
      end
      if quest == nil then
         Log.error("Missing encounter quest for assassin encounter %s", global.encounter_quest_uid)
         return 1
      end
      return quest.difficulty
      -- <<<<<<<< shade2/map.hsp:1615 			flt qLevel(rq),fixGood ..
   end,

   before_encounter_start = function()
      -- >>>>>>>> shade2/action.hsp:678 			txt lang("暗殺者につかまった。あなたはクライアントを守らなければならない。","Yo ...
      Gui.mes("misc.caught_by_assassins")
      Input.query_more()
      -- <<<<<<<< shade2/action.hsp:679 			msg_halt ..
   end,

   on_map_entered = function(map, level, outer_map, outer_x, outer_y)
      local player = Chara.player()

      -- >>>>>>>> shade2/map.hsp:1608 		if encounter=encounterAssassin{ ...
      local quest
      if global.encounter_quest_uid then
         quest = Quest.get(global.encounter_quest_uid)
      end
      if quest == nil then
         Log.error("Missing encounter quest for assassin encounter %s", global.encounter_quest_uid)
      else
         quest.state = "accepted"
         Quest.set_immediate_quest(quest)
      end

      map.max_crowd_density = 0
      table.insert(map.types, "quest")

      for _ = 1, Rand.rnd(3) + 5 do
         local filter = {
            level = level,
            quality = Enum.Quality.Good
         }
         local assassin = Charagen.create(player.x, player.y, filter, map)
         if assassin then
            assassin:set_target(player, 30)
            assassin.relation = Enum.Relation.Enemy
         end
      end
      -- <<<<<<<< shade2/map.hsp:1620 			} ...   end
   end
}
