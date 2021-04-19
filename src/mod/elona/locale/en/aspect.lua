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

               level = function(s, lv)
                  return ("%s Level %s(Empty)"):format(s, lv)
               end
            },
            IItemTextbook = {
               action_name = "Textbook",

               title = function(s, skill_name)
                  return ("%s titled <Art of %s>"):format(s, skill_name)
               end
            },
            IItemBook = {
               action_name = "Book",

               title = function(s, title)
                  return ("%s titled <%s>"):format(s, title)
               end
            }
         }
      }
   }
}
