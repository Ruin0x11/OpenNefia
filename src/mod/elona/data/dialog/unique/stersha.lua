local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")

data:add {
   _type = "elona_sys.dialog",
   _id = "stersha",

   nodes = {
      __start = function()
         local flag = Sidequest.progress("elona.main_quest")
         if flag >= 200 then
            return "late"
         elseif flag < 90 then
            return "early"
         end

         return "mid"
      end,
      late = {
         text = "talk.unique.stersha.late"
      },
      early = {
         text = "talk.unique.stersha.early"
      },
      mid = {
         text = "talk.unique.stersha.mid"
      }
   }
}
