local template = {
   map_name = "palmia",

   copy_to_map = {
      turn_cost = 10000
   },

   areas = {
      { id = "base.vernis", x = 20, y = 30 }
   },

   objects = {
      ["base.chara"] = {
         { id = "content.player", x = 20, y = 31 }
      }
   },

   on_generate = function(map)
   end
}
