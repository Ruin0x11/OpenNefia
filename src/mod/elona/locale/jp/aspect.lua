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
            IItemCookingTool = {
               action_name = "調理道具"
            },
            IItemGaroksHammer = {
               action_name = "ガロクの槌"
            },
            IItemTextbook = {
               action_name = "学習書",

               title = function(s, skill_name)
                  return ("《%s》という題名の%s"):format(skill_name, s)
               end
            },
            IItemBook = {
               action_name = "本",

               title = function(s, title)
                  return ("《%s》という題名の%s"):format(title, s)
               end
            },
            IItemBookOfRachel = {
               action_name = "レイチェルの絵本",

               title = function(s, no)
                  return ("第%s巻目の%s"):format(no, s)
               end
            }
         }
      }
   }
}
