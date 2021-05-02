return {
  talk = {
    visitor = {
      adventurer = {
        conversation = {
          dialog = function(_1, _2)
  return ("やあ。特に用はない%s、なんだか暇を持てましていたら、%sと話がしたくなって%s、寄ってみた%s")
  :format(ga(_2, 3), kimi(_2, 3), na(_2, 3), noda(_2))
end,
          hold = function(_1)
  return ("あなたと%sは愉快に語り合った！")
  :format(name(_1))
end
        },
        drink = {
          cheers = function(_1)
  return ("あなたと%sは乾杯した！")
  :format(name(_1))
end,
          dialog = function(_1)
  return ("酒でも飲んで親睦を深めよう%s")
  :format(yo(_1, 2))
end
        },
        favorite_skill = {
          dialog = function(_1, _2)
  return ("%sは%sの得意なスキルの内の一つ%s")
  :format(_1, ore(_2, 3), da(_2))
end
        },
        favorite_stat = {
          dialog = function(_1, _2)
  return ("%sは%sが自慢なの%s")
  :format(ore(_2, 3), _1, da(_2))
end
        },
        friendship = {
          dialog = function(_1)
  return ("友達の証としてこれをあげ%s大事に使って%s")
  :format(ru(_1, 2), yo(_1))
end,
          no_empty_spot = "部屋が一杯で置けなかった…"
        },
        hate = {
          dialog = function(_1)
  return ("貴様！見つけた%s")
  :format(yo(_1, 2))
end,
          text = function(_1)
  return ("「これでも食らうがいい%s」")
  :format(yo(_1, 2))
end,
          throws = function(_1)
  return ("%sは火炎瓶を投げた。")
  :format(name(_1))
end
        },
        like = {
          dialog = function(_1)
  return ("これ、あげ%s")
  :format(ru(_1, 2))
end,
          wonder_if = "友達100人できるかな♪"
        },
        materials = {
          dialog = function(_1)
  return ("旅の途中にこんなものを拾った%s%sの役に立つと思って持ってきた%s")
  :format(noda(_1), kimi(_1, 3), yo(_1))
end,
          receive = function(_1)
  return ("%sは色々なものが詰まった袋を、あなたに手渡した。")
  :format(name(_1))
end
        },
        new_year = {
          gift = function(_1)
  return ("日ごろの感謝の意をこめてこれをあげる%s")
  :format(yo(_1))
end,
          happy_new_year = function(_1)
  return ("明けましておめでとう%s")
  :format(da(_1, 2))
end,
          throws = function(_1, _2)
  return ("%sは%sを置いていった。")
  :format(name(_1), _2)
end
        },
        souvenir = {
          dialog = function(_1)
  return ("近くまで来たので寄ってみた%sついでだから、土産にこれをあげ%s")
  :format(noda(_1), ru(_1))
end,
          inventory_is_full = "所持品が一杯で受け取れなかった…",
          receive = function(_1)
  return ("%sを受け取った。")
  :format(_1)
end
        },
        train = {
          choices = {
            learn = "習得する",
            pass = "遠慮しとく",
            train = "訓練する"
          },
          learn = {
            after = function(_1)
  return ("新しい技術をどうやら習得できたようだ%s")
  :format(na(_1))
end,
            dialog = function(_1, _2, _3)
  return ("%sのスキルを、友達価格の%s platで教えてあげてもいい%sどう%s")
  :format(_1, _2, ga(_3, 3), kana(_3, 1))
end
          },
          pass = function(_1)
  return ("わかった%sまたしばらくしてから尋ねてみ%s")
  :format(yo(_1), ru(_1))
end,
          train = {
            after = function(_1)
  return ("よし、これで訓練は終わり%sかなり潜在能力が伸びた%s")
  :format(da(_1), yo(_1, 2))
end,
            dialog = function(_1, _2, _3)
  return ("%sのスキルを、友達価格の%s platで訓練してもいい%sどう%s")
  :format(_1, _2, ga(_3, 3), kana(_3, 1))
end
          }
        }
      },
      beggar = {
        after = function(_1)
  return ("%sこの恩は一生忘れない%s")
  :format(thanks(_1, 2), yo(_1))
end,
        cheap = "ケチ！",
        dialog = function(_1)
  return ("パンを買う金さえない%s恵んで%s、おねがい%s")
  :format(noda(_1), kure(_1, 3), da(_1, 2))
end,
        spare = function(_1)
  return ("あなたは%sgoldを乞食に渡した。")
  :format(_1)
end
      },
      choices = {
        no = "だめ",
        yes = "いい"
      },
      merchant = {
        choices = {
          not_now = "今はいい",
        },
        dialog = function(_1)
  return ("今日は%sの幸運な日%s普段は一般の客には売らない格安の品を、特別に見せてあげ%s覚えておいて%s、今日だけだ%s")
  :format(kimi(_1, 3), da(_1), ru(_1), kure(_1, 3), yo(_1))
end,
        regret = function(_1)
  return ("後になって後悔しても知らない%s")
  :format(yo(_1))
end
      },
      mysterious_producer = {
        no_turning_back = function(_1)
  return ("よい心がけだ%s")
  :format(na(_1, 2))
end,
        want_to_be_star = function(_1)
  return ("スターになりたい%s")
  :format(kana(_1, 1))
end
      },
      punk = {
        dialog = function(_1)
  return ("フッ。よく逃げ出さずに戻ってきた%s準備はいいか。")
  :format(na(_1))
end,
        hump = "ふん！"
      },
      receive = function(_1, _2)
  return ("%sに%sをもらった！")
  :format(name(_2), _1)
end,
      trainer = {
        after = function(_1)
  return ("うむ、なかなか見所がある%s")
  :format(yo(_1))
end,
        choices = {
          improve = function(_1)
  return ("%sを鍛える")
  :format(_1)
end,
          not_today = "訓練しない"
        },
        dialog = {
          member = function(_1, _2, _3)
  return ("%sの一員足るもの、ギルドの名に恥じないよう、常に己の技量を磨き続けなければならない%sギルドの一員である%sには、たったのプラチナ%s枚で潜在能力を伸ばす訓練を施してあげる%s")
  :format(_1, yo(_3), kimi(_3, 3), _2, yo(_3))
end,
          nonmember = function(_1, _2)
  return ("鍛えている%s冒険者として生き残るには、日ごろの鍛錬が大切%sわずかプラチナ%s枚で、潜在能力を伸ばす特別な訓練を施してあげる%s")
  :format(kana(_2, 2), da(_2, 2), _1, yo(_2, 2))
end
        },
        no_more_this_month = function(_1)
  return ("今月はもう訓練は終わり%s")
  :format(da(_1))
end,
        potential_expands = function(_1, _2)
  return ("%sの%sの潜在能力が大きく上昇した。")
  :format(name(_1), _2)
end,
        regret = function(_1)
  return ("後悔する%s")
  :format(yo(_1, 2))
end
      },
      just_visiting = function(_1)
  return ("まあ、とくに用もないんだけど%s")
  :format(na(_1))
end
    }
  }
}
