data:add {
   _type = "base.trait",
   _id = "blacksmith",

   elona_id = 70,

   level_min = 0,
   level_max = 3,
   type = "feat",

   can_acquire = function(self, chara)
      return chara:is_player()
   end,
}
