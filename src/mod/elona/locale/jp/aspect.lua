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
            IItemFishingPole = {
               action_name = "釣竿",

               remaining = function(s, bait, charges)
                  return ("%s(%s残り%s匹)"):format(s, bait, charges)
               end
            },
            IItemBait = {
               action_name = "餌",

               title = function(s, bait_name)
                  return ("%s%s"):format(s, bait_name)
               end
            },
            IItemMoneyBox = {
               action_name = "貯金箱",

               amount = function(s, amount)
                  return ("%s%s"):format(s, amount)
               end,
               increments = {
                  _500       = "5百金貨",
                  _2000      = "2千金貨",
                  _10000     = "1万金貨",
                  _50000     = "5万金貨",
                  _500000    = "50万金貨",
                  _5000000   = "500万金貨",
                  _100000000 = "1億金貨"
               }
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
            },
            IItemPotion = {
               action_name = "ポーション"
            },
            IItemWell = {
               action_name = "井戸"
            }
         }
      }
   }
}
