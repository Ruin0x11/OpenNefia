data:add {
   _type = "elona_sys.dialog",
   _id = "guard",

   nodes = {
      where_is = function(t)
         return "elona.default:talk"
      end,
      lost_item = function(t)
         return "elona.default:talk"
      end,
   }
}
