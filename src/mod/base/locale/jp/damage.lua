return {
   damage = {
      critical_hit = "会心の一撃！ ",
      death_word_breaks = "死の宣告は無効になった。",
      evade = {
         ally = function(_1, _2)
            return ("%s%sの攻撃を華麗に避けた。")
               :format(kare_wa(_2), name(_1))
         end,
         other = function(_1)
            return ("%s攻撃を華麗にかわされた。")
               :format(kare_wa(_1))
         end
      },
      explode_click = " *カチッ* ",
      furthermore = "さらに",
      get_off_corpse = function(_1)
         return ("%sは%sの死体から降りた。")
            :format(you(), name(_1))
      end,
      is_engulfed_in_fury = function(_1)
         return ("%sは怒りに体を奮わせた！")
            :format(name(_1))
      end,
      is_frightened = function(_1)
         return ("%sは怖気づいた。")
            :format(name(_1))
      end,
      is_healed = function(_1)
         return ("%sは回復した。")
            :format(name(_1))
      end,
      lay_hand = function(_1)
         return ("%sは叫んだ。「この者にジュアの加護を。レイハンド！」")
            :format(name(_1))
      end,
      levels = {
         critically = "致命傷を与えた。",
         moderately = "傷つけた。",
         scratch = "かすり傷をつけた。",
         severely = "深い傷を負わせた。",
         slightly = "軽い傷を負わせた。"
      },
      magic_reaction_hurts = function(_1)
         return ("マナの反動が%sの精神を蝕んだ！")
            :format(name(_1))
      end,
      miss = {
         ally = function(_1, _2)
            return ("%s%sの攻撃を避けた。")
               :format(kare_wa(_2), name(_1))
         end,
         other = function(_1)
            return ("%s攻撃をかわされた。")
               :format(kare_wa(_1))
         end
      },
      reactions = {
         is_severely_hurt = function(_1)
            return ("%sは悲痛な叫び声をあげた。")
               :format(name(_1))
         end,
         screams = function(_1)
            return ("%sは痛手を負った。")
               :format(name(_1))
         end,
         writhes_in_pain = function(_1)
            return ("%sは苦痛にもだえた。")
               :format(name(_1))
         end
      },
      reactive_attack = {
         acids = "酸が飛び散った。",
         ether_thorns = function(_1)
            return ("エーテルの棘が%sに刺さった。")
               :format(name(_1))
         end,
         thorns = function(_1)
            return ("棘が%sに刺さった。")
               :format(name(_1))
         end
      },
      runs_away_in_terror = function(_1)
         return ("%sは恐怖して逃げ出した。")
            :format(name(_1))
      end,
      sand_bag = {
         "くっ！",
         "まだまだ！",
         "もう限界…",
         "うぐぐ",
         "あう",
         "ああんっ"
      },
      sleep_is_disturbed = function(_1)
         return ("%sは眠りを妨げられた。")
            :format(name(_1))
      end,
      splits = function(_1)
         return ("%sは分裂した！")
            :format(name(_1))
      end,
      vorpal = {
         melee = " *シャキーン* ",
         ranged = " *ズバシュッ* "
      },
      weapon = {
         attacks_and = function(_1, _2, _3)
            return ("%s%sを%s")
               :format(kare_wa(_1), name(_3), _2)
         end,
         attacks_throwing = function(_1, _2, _3, _4)
            return ("%s%sに%sを%s")
               :format(kare_wa(_1), name(_3), _4, _2)
         end,
         attacks_unarmed = function(_1, _2, _3)
            return ("%s%sに%s")
               :format(kare_wa(_3), name(_1), _2)
         end,
         attacks_unarmed_and = function(_1, _2, _3)
            return ("%s%sを%s")
               :format(kare_wa(_1), name(_3), _2)
         end,
         attacks_with = function(_1, _2, _3, _4)
            return ("%s%sに%sで%s。")
               :format(kare_wa(_3), name(_1), _4, _2)
         end
      },
      wields_proudly = function(_1, _2)
         return ("%sは%sを誇らしげに構えた。")
            :format(name(_1), _2)
      end,
      you_feel_sad = "あなたは悲しくなった。",

      melee = {
         default = {
            enemy = "殴って",
            ally = "殴られた。",
            weapon = "手",
         },

         claw = {
            enemy = "引っ掻き",
            ally = "引っ掻かれた。",
            weapon = "爪",
         },

         bite = {
            enemy = "噛み付いて",
            ally = "噛み付かれた。",
            weapon = "牙",
         },

         gaze = {
            enemy = "睨んで",
            ally = "睨まれた。",
            weapon = "眼",
         },

         sting = {
            enemy = "刺し",
            ally = "刺された。",
            weapon = "針",
         },

         touch = {
            enemy = "触って",
            ally = "触られた。",
            weapon = "手",
         },

         spore = {
            enemy = "胞子を撒き散らし",
            ally = "胞子を飛ばされた。",
            weapon = "胞子",
         }
      }
   }
}
