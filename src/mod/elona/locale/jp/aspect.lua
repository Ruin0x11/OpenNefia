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
            IItemChair = {
               action_name = "椅子"
            },

            IItemReadable = {
               prompt = function(_1) return ("どうやって%sを読む？"):format(_1) end,
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
            IItemSpellbook = {
               action_name = "魔法書",
            },
            IItemAncientBook = {
               action_name = "古書物",

               decoded = function(_1)
                  return ("解読済みの%s"):format(_1)
               end,
               undecoded = nil,

               title = function(title, name)
                  return ("《%s》という題名の%s"):format(title, name)
               end,
               titles = {
                  _0 = "ヴォイニッチ写本",
                  _1 = "ドール賛歌",
                  _2 = "ポナペ教教典",
                  _3 = "グラーキ黙示録",
                  _4 = "グ＝ハーン断章",
                  _5 = "断罪の書",
                  _6 = "ドジアンの書",
                  _7 = "エイボンの書",
                  _8 = "大いなる教書",
                  _9 = "セラエノ断章",
                  _10 = "ネクロノミコン",
                  _11 = "ルルイエ異本",
                  _12 = "エルトダウン・シャールズ",
                  _13 = "金枝篇",
                  _14 = "終焉の書"
               },
            },

            IItemPotion = {
               action_name = "ポーション"
            },
            IItemWell = {
               action_name = "井戸"
            },

            IItemZappable = {
               prompt = function(_1) return ("どうやって%sを振る？"):format(_1) end,
            },
            IItemRod = {
               action_name = "杖"
            },

            IFeatActivatable = {
               prompt = function(_1) return ("どうやって%sを使う？"):format(_1) end,
            },
            IFeatDescendable = {
               prompt = function(_1) return ("どうやって%sを使う？"):format(_1) end,
            },
            IFeatLockedHatch = {
               action_name = "ハッチ"
            },

            IItemChargeable = {
               action_name = "充填可のアイテム"
            }
         }
      }
   }
}
