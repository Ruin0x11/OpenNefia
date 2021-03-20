local ReserveSpellbookMenu = require("mod.elona.api.gui.ReserveSpellbookMenu")

data:add {
   _type = "elona_sys.dialog",
   _id = "spell_writer",

   nodes = {
      reserve = function(t)
         ReserveSpellbookMenu:new():query()
         return "elona.default:talk"
      end,
   }
}
