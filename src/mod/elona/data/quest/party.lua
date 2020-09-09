local Chara = require("api.Chara")
local Rand = require("api.Rand")
local Quest = require("mod.elona_sys.api.Quest")
local Map = require("api.Map")
local QuestMap = require("mod.elona.api.QuestMap")

local map_party = {
   _type = "base.map_archetype",
   _id = "quest_party",

   properties = {
      types = { "temporary" },
      tileset = "elona.castle",
      level = 1,
      is_indoor = false,
      max_crowd_density = 0,
      default_ai_calm = 0,
      shows_floor_count_in_name = true,
      prevents_building_shelter = true
   }
}

-- >>>>>>>> elona122/shade2/map_rand.hsp:676 	gLevelStartOn=mStartSpec ..
function map_party.starting_pos(map, chara)
   return {
      x = Rand.rnd(map:width()  / 3)  + map:width()  / 3,
      y = Rand.rnd(map:height() / 3)  + map:height() / 3
   }
end
-- <<<<<<<< elona122/shade2/map_rand.hsp:678 	map_placePlayer	 ..

data:add(map_party)

local party = {
   _id = "party",
   _type = "elona_sys.quest",

   elona_id = 1009,
   ordering = 50000,
   client_chara_type = 7,
   reward = nil,
   reward_fix = 0,

   min_fame = 0,
   chance = function(client, town)
      if town._archetype == "elona.palmia" then
         return 8
      end

      return 23
   end,

   params = { required_points = "number" },

   difficulty = function()
      local performer_skill = Chara.player():skill_level("elona.performer")
      return math.clamp(Rand.rnd(performer_skill + 10),
                        math.floor(1.5 * math.sqrt(performer_skill)) + 1,
                        math.floor(Chara.player():calc("fame") / 1000) + 10)
   end,

   expiration_hours = function() return (Rand.rnd(6) + 2) * 24 end,

   locale_data = function(self)
      return { required_points = self.params.required_points }
   end
}

function party.generate(self, client)
   self.params = {
      required_points = self.difficulty * 10 + Rand.rnd(50)
   }

   return true
end

function party.on_accept(self)
   return true, "elona.quest_party:accept"
end

function party.on_complete()
   return "quest.elona.party.dialog.complete"
end

data:add(party)

---
--- Dialog
---

data:add {
   _type = "elona_sys.dialog",
   _id = "quest_party",

   nodes = {
      accept = {
         text = "quest.elona.party.dialog.accept",
         on_finish = function(t)
            local party_map = QuestMap.generate_party()
            local current_map = t.speaker:current_map()
            local player = Chara.player()
            party_map:set_previous_map_and_location(current_map, player.x, player.y)

            local quest = Quest.for_client(t.speaker)
            assert(quest)

            local ext = party_map:get_mod_data("elona")
            ext.immediate_quest = quest
            ext.time_limit = 60
            ext.time_limit_notice_interval = 9999

            Map.travel_to(party_map)
         end
      },
      complete = {
         text = "quest.elona.party.dialog.complete",
         jump_to = "elona.default:__start"
      }
   }
}
