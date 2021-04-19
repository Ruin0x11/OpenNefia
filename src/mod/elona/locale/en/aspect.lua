return {
   aspect = {
      _ = {
         elona = {
            IItemUseable = {
               prompt = function(_1) return ("How do you want to use %s?"):format(_1) end,
            },
            IItemSeed = {
               action_name = "Seed"
            },
            IItemMusicDisc = {
               action_name = "Music Disc"
            },
            IItemMonsterBall = {
               action_name = "Monster Ball",

               level = function(lv)
                  return (" Level %s(Empty)"):format(lv)
               end
            }
         }
      }
   }
}
