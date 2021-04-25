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
require("mod.elona.data.dialog.role.spell_writer")
require("mod.elona.data.dialog.role.informer")
require("mod.elona.data.dialog.role.adventurer")

require("mod.elona.data.dialog.unique.miches")
require("mod.elona.data.dialog.unique.larnneire")
require("mod.elona.data.dialog.unique.lomias")
require("mod.elona.data.dialog.unique.rilian")
require("mod.elona.data.dialog.unique.poppy")
require("mod.elona.data.dialog.unique.rogue_boss")
require("mod.elona.data.dialog.unique.lexus")
require("mod.elona.data.dialog.unique.doria")
require("mod.elona.data.dialog.unique.abyss")
require("mod.elona.data.dialog.unique.miral")
require("mod.elona.data.dialog.unique.garokk")
require("mod.elona.data.dialog.unique.orphe")
require("mod.elona.data.dialog.unique.zeome")
require("mod.elona.data.dialog.unique.erystia")
require("mod.elona.data.dialog.unique.karam")
require("mod.elona.data.dialog.unique.slan")
require("mod.elona.data.dialog.unique.xabi")
require("mod.elona.data.dialog.unique.stersha")
require("mod.elona.data.dialog.unique.ainc")
require("mod.elona.data.dialog.unique.arnord")
