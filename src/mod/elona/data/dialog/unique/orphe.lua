local Chara = require("api.Chara")
local I18N = require("api.I18N")

data:add {
   _type = "elona_sys.dialog",
   _id = "orphe",

   nodes = {
      __start = function()
         return "__IGNORED__"
      end,
      dialog = {
         text = {
            {"talk.unique.orphe.dialog._0", args = function()
                return {I18N.get("ui.sex." .. Chara.player():calc("gender"))}
            end},
            {"talk.unique.orphe.dialog._1"},
            {"talk.unique.orphe.dialog._2"},
            {"talk.unique.orphe.dialog._3"},
            {"talk.unique.orphe.dialog._4"},
            {"talk.unique.orphe.dialog._5"},
         }
      }
   }
}
