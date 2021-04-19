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

               level = function(s, lv)
                  return ("%s Lv %s (空)"):format(s, lv)
               end
            },
            IItemTextbook = {
               action_name = "学習書",

               title = function(s, skill_name)
                  return ("《%s》という題名の%s"):format(skill_name, s)
               end
            }
         }
      }
   }
}
