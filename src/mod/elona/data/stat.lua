local stat = {
   {
      _id = "life",
      elona_id = 2,

      calc_final = function(level)
         return { level = level, potential = 100 }
      end
   },
   {
      _id = "mana",
      elona_id = 3,

      calc_final = function(level)
         return { level = level, potential = 100 }
      end
   },
   {
      _id = "strength",
      elona_id = 10,
   },
   {
      _id = "constitution",
      elona_id = 11,
   },
   {
      _id = "dexterity",
      elona_id = 12,
   },
   {
      _id = "perception",
      elona_id = 13,
   },
   {
      _id = "learning",
      elona_id = 14,
   },
   {
      _id = "will",
      elona_id = 15,
   },
   {
      _id = "magic",
      elona_id = 16,
   },
   {
      _id = "charisma",
      elona_id = 17,
   },
   {
      _id = "speed",
      elona_id = 18,

      calc_initial_level = function(level, chara)
         return math.floor(level * (100 * chara.level * 2) / 100)
      end
   },
   {
      _id = "luck",
      elona_id = 19,

      calc_final = function(level)
         return { level = level, potential = 100 }
      end
   }
}

data:add_multi("base.stat", stat)
