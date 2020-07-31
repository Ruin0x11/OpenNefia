return {
  activity = {
    cancel = {
      item = function(_1)
  return ("%sは行動を中断した。")
  :format(name(_1))
end,
      normal = function(_1, _2)
  return ("%sは%sを中断した。")
  :format(name(_1), _2)
end,
      prompt = function(_1)
  return ("%sを中断したほうがいいだろうか？ ")
  :format(_1)
end
    },
    construct = {
      finish = function(_1)
  return ("%sを作り終えた。")
  :format(itemname(_1, 1))
end,
      start = function(_1)
  return ("%sの建設を始めた。")
  :format(itemname(_1, 1))
end
    },
    dig = function(_1)
  return ("%sを掘り始めた。")
  :format(itemname(_1, 1))
end,
    dig_mining = {
      fail = "背中が痛い…掘るのを諦めた。",
      finish = {
        find = "何かを見つけた。",
        wall = "壁を掘り終えた。"
      },
      start = {
        hard = "この壁はとても固そうだ！",
        spot = "鉱石を掘り始めた。",
        wall = "壁を掘りはじめた。"
      }
    },
    dig_spot = {
      finish = "地面を掘り終えた。",
      something_is_there = " *ガチッ* …何かがある！",
      sound = { " *ざくっ* ", " *カキン* ", " *ごつっ* ", " *じゃり* ", " *♪* " },
      start = {
        global = "地面を掘り始めた。",
        other = "探索を始めた。"
      }
    },
    eat = {
      finish = function(_1, _2)
  return ("%s%sを食べ終えた。")
  :format(kare_wa(_1), itemname(_2, 1))
end,
      start = {
        in_secret = function(_1, _2)
  return ("%sは%sをこっそりと口に運んだ。")
  :format(name(_1), itemname(_2, 1))
end,
        mammoth = "「いただきマンモス」",
        normal = function(_1, _2)
  return ("%sは%sを口に運んだ。")
  :format(name(_1), itemname(_2, 1))
end
      }
    },
    fishing = {
      fail = "何も釣れなかった…",
      get = function(_1)
  return ("%sを釣り上げた！")
  :format(itemname(_1, 1))
end,
      start = "釣りを始めた。"
    },
    guillotine = "突然ギロチンが落ちてきた！",
    harvest = {
      finish = function(_1, _2)
  return ("%sを収穫した(%s)")
  :format(itemname(_1, 1), _2)
end,
      sound = { " *ザクッ* ", " *♪* ", " *ズシュ* ", " *ジャリ* " }
    },
    iron_maiden = "突然ふたが閉まった！",
    material = {
      digging = {
        fails = "採掘に失敗した。",
        no_more = "鉱石を掘りつくした。"
      },
      fishing = {
        fails = "釣りに失敗した。",
        no_more = "泉は干上がった。"
      },
      get = function(_1, _2, _3)
  return ("マテリアル:%sを%s個%s。")
  :format(_3, _2, _1)
end,
      get_verb = {
        dig_up = "掘り当てた",
        find = "見つけた",
        fish_up = "釣り上げた",
        get = "入手した",
        harvest = "採取した"
      },
      harvesting = {
        no_more = "もう目ぼしい植物は見当たらない。"
      },
      lose = function(_1, _2)
  return ("マテリアル:%sを%s個失った")
  :format(_1, _2)
end,
      lose_total = function(_1)
  return ("(残り %s個) ")
  :format(_1)
end,
      searching = {
        fails = "採取に失敗した。",
        no_more = "もう何もない。"
      },
      start = "採取を始めた。"
    },
    perform = {
      dialog = {
        angry = { "「引っ込め！」", "「うるさい！」", "「下手っぴ！」", "「何のつもりだ！」" },
        disinterest = { "「飽きた」", "「前にも聴いたよ」", "「またこの曲か…」" },
        interest = { function(_1)
  return ("%sは歓声を上げた。")
  :format(name(_1))
end, function(_1)
  return ("%sは目を輝かせた。")
  :format(name(_1))
end, "「ブラボー」", "「いいぞ！」", function(_1)
  return ("%sはうっとりした。")
  :format(name(_1))
end, function(_1, _2)
  return ("%sは%sの演奏を褒め称えた。")
  :format(name(_1), name(_2))
end }
      },
      gets_angry = function(_1)
  return ("%sは激怒した。")
  :format(name(_1))
end,
      quality = {
        _0 = "まるで駄目だ…",
        _1 = "不評だった…",
        _2 = "もっと練習しなくては…",
        _3 = "演奏を終えた。",
        _4 = "いまいちだ。",
        _5 = "手ごたえがあった。",
        _6 = "納得できる演奏ができた。",
        _7 = "大盛況だ！",
        _8 = "素晴らしい！",
        _9 = "歴史に残る名演だ！"
      },
      sound = {
        cha = "ｼﾞｬﾝ♪ ",
        random = { "ﾁｬﾗﾝ♪ ", "ﾎﾟﾛﾝ♪ ", "ﾀﾞｰﾝ♪ " }
      },
      start = function(_1, _2)
  return ("%sは%sの演奏をはじめた。")
  :format(name(_1), itemname(_2))
end,
      throws_rock = function(_1)
  return ("%sは石を投げた。")
  :format(name(_1))
end,
      tip = function(_1, _2)
  return ("%sは合計 %sのおひねりを貰った。")
  :format(name(_1), _2)
end
    },
    pull_hatch = {
      finish = function(_1)
  return ("%sのハッチを回し終えた。")
  :format(itemname(_1, 1))
end,
      start = function(_1)
  return ("%sのハッチを回し始めた。")
  :format(itemname(_1, 1))
end
    },
    read = {
      finish = function(_1, _2)
  return ("%s%sを読み終えた。")
  :format(kare_wa(_1), _2)
end,
      start = function(_1, _2)
  return ("%s%sを読み始めた。")
  :format(kare_wa(_1), _2)
end
    },
    rest = {
      drop_off_to_sleep = "あなたはそのまま眠りにおちた…",
      finish = "あなたは休息を終えた。",
      start = "あなたは横になった。"
    },
    sex = {
      after_dialog = { function(_1)
  return ("よかった%s")
  :format(yo(_1, 2))
end, function(_1)
  return ("す、すごい%s")
  :format(yo(_1, 2))
end, function(_1)
  return ("も、もうだめ%s")
  :format(da(_1, 2))
end, function(_1)
  return ("は、激しかった%s")
  :format(yo(_1, 2))
end, function(_1)
  return ("か、完敗%s")
  :format(da(_1, 2))
end },
      dialog = { "「きくぅ」", "「もふもふ」", "「くやしい、でも…」", "「はぁはぁ！」", "「ウフフフ」" },
      format = function(_1, _2)
  return ("「%s%s」")
  :format(_1, _2)
end,
      gets_furious = function(_1)
  return ("%sは激怒した。「なめてんの？」")
  :format(name(_1))
end,
      spare_life = function(_1, _2)
  return ("「そ、その%sとは体だけの関係%s%sは何も知らないから、命だけは…！」")
  :format(_1, da(_2), ore(_2, 3))
end,
      take = function(_1)
  return ("さあ、小遣いを受け取って%s")
  :format(kure(_1, 3))
end,
      take_all_i_have = function(_1)
  return ("これが%sの財布の中身の全て%s")
  :format(ore(_1, 3), da(_1))
end,
      take_clothes_off = function(_1)
  return ("%sは服を脱ぎ始めた。")
  :format(name(_1))
end
    },
    sleep = {
      but_you_cannot = "しかし、大事な用を思い出して飛び起きた。",
      finish = "あなたは眠り込んだ。",
      new_gene = {
        choices = {
          _0 = "ふぅ"
        },
        text = function(_1)
  return ("%sとあなたは熱い一夜を供にした。新たな遺伝子が生成された。")
  :format(name(_1))
end,
        title = "遺伝子"
      },
      slept_for = function(_1)
  return ("%s時間眠った。あなたはリフレッシュした。")
  :format(_1)
end,
      start = {
        global = "露営の準備を始めた。",
        other = "寝る仕度を始めた。"
      },
      wake_up = {
        good = function(_1)
  return ("心地よい目覚めだ。潜在能力が伸びた(計%s%%)。")
  :format(_1)
end,
        so_so = "まあまあの目覚めだ。"
      }
    },
    steal = {
      abort = "行動を中断した。",
      cannot_be_stolen = "それは盗めない。",
      guilt = "あなたは良心の呵責を感じた。",
      it_is_too_heavy = "重すぎて手に負えない。",
      notice = {
        dialog = {
          guard = "「貴様、何をしている！」",
          other = "「ガード！ガード！」"
        },
        in_fov = function(_1)
  return ("%sは窃盗を見咎めた。")
  :format(name(_1))
end,
        out_of_fov = function(_1)
  return ("%sは不振な物音に気づいた。")
  :format(name(_1))
end,
        you_are_found = "盗みを見咎められた！"
      },
      start = function(_1)
  return ("%sに目星をつけた。")
  :format(itemname(_1, 1))
end,
      succeed = function(_1)
  return ("%sを盗んだ。")
  :format(itemname(_1))
end,
      target_is_dead = "対象は死んでいる",
      you_lose_the_target = "対象が見当たらない。"
    },
    study = {
      finish = {
        studying = function(_1)
  return ("%sの学習を終えた。")
  :format(_1)
end,
        training = "トレーニングを終えた。"
      },
      start = {
        bored = "もう飽きた。",
        studying = function(_1)
  return ("%sの学習を始めた。")
  :format(_1)
end,
        training = "トレーニングを始めた。",
        weather_is_bad = "外が悪天候なので、じっくりと取り組むことにした。"
      }
    }
  }
}
