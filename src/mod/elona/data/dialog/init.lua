data:add {
   _type = "elona_sys.dialog",
   _id = "is_sleeping",
   nodes = {
      __start = {
         text = {
            {"talk.is_sleeping", args = function(t) return {t.speaker} end},
         }
      },
   }
}

data:add {
   _type = "elona_sys.dialog",
   _id = "is_busy",
   nodes = {
      __start = {
         text = {
            {"talk.is_busy", args = function(t) return {t.speaker} end},
         }
      },
   }
}

require("mod.elona.data.dialog.special.default")
require("mod.elona.data.dialog.special.quest_giver")
require("mod.elona.data.dialog.special.sex")
require("mod.elona.data.dialog.special.servant")

require("mod.elona.data.dialog.role.guard")
require("mod.elona.data.dialog.role.prostitute")
require("mod.elona.data.dialog.role.trainer")
require("mod.elona.data.dialog.role.shopkeeper")
require("mod.elona.data.dialog.role.innkeeper")

require("mod.elona.data.dialog.unique.miches")
require("mod.elona.data.dialog.unique.larnneire")
require("mod.elona.data.dialog.unique.lomias")
require("mod.elona.data.dialog.unique.rilian")
require("mod.elona.data.dialog.unique.poppy")
require("mod.elona.data.dialog.unique.rogue_boss")
