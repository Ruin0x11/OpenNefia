return {
   aspect = {
      _ = {
         elona = {
            IItemUseable = {
               prompt = function(_1) return ("どうやって%sを使う？"):format(_1) end,
            },
            IItemSeed = {
               action_name = "種"
            },
            IItemMusicDisc = {
               action_name = "ディスク"
            },
            IItemMonsterBall = {
               action_name = "モンスターボール",

               level = function(lv)
                  return (" Lv %s (空)"):format(lv)
               end
            }
         }
      }
   }
}
