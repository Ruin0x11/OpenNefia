return {
  misc = {
    ["and"] = "と",
    artifact_regeneration = function(_1, _2)
  return ("%sは%sに形を変えた。")
  :format(_1, _2)
end,
    black_cat_licks = function(_1, _2)
  return ("%sは%sをぺろぺろと舐めた。")
  :format(name(_1), _2)
end,
    caught_by_assassins = "暗殺者につかまった。あなたはクライアントを守らなければならない。",
    corpse_is_dried_up = function(_1)
  return ("%sは上手い具合に干された。")
  :format(_1)
end,
    curse = {
      blood_sucked = function(_1)
  return ("何かが%sの血を吸った。")
  :format(name(_1))
end,
      creature_summoned = "魔力の渦が何かを召喚した！",
      experience_reduced = function(_1)
  return ("%sは未熟になった。")
  :format(name(_1))
end,
      gold_stolen = function(_1)
  return ("悪意のある手が%sの財布から金貨を抜き去った。")
  :format(name(_1))
end
    },
    custom = {
      do_you_want_to_delete = function(_1)
  return ("本当に%sを削除する？ ")
  :format(_1)
end,
      fail_to_retrieve_file = "ファイルの取得に失敗した。",
      incompatible = "互換性のないバージョンのファイルです。",
      key_hint = "BackSpace [削除]  ",
      pet_team = {
        list = "ペットチーム一覧",
        name = "チームの名称",
        which_team = "どのチームと対戦する？"
      },
      show_room = {
        list = "ルーム一覧",
        name = "ルームの名称",
        which_show_room = "どのルームを訪問する？ "
      }
    },
    death = {
      crawl_up = "這い上がる",
      date = function(_1, _2, _3)
  return ("%s年%s月%s日")
  :format(_1, _2, _3)
end,
      dying_message = function(_1)
  return ("「%s」")
  :format(_1)
end,
      good_bye = "さようなら… ",
      lie_on_your_back = "埋まる",
      rank = function(_1)
  return ("%s位")
  :format(_1)
end,
      you_are_about_to_be_buried = "あともう少しで埋葬される…",
      you_died = function(_1, _2)
  return ("%sで%s")
  :format(_2, _1)
end,
      you_have_been_buried = "あなたは埋められた。さようなら…（キーを押すと終了します）",
      you_leave_dying_message = "遺言は？"
    },
    dungeon_level = function(_1, _2) return ("%s %s階"):format(_1, ordinal(_2)) end,
    extract_seed = function(_1)
  return ("あなたは%sから種を取り出した。")
  :format(_1)
end,
    fail_to_cast = {
      creatures_are_summoned = "魔力の渦が何かを召喚した！",
      dimension_door_opens = function(_1)
  return ("%sは奇妙な力に捻じ曲げられた！")
  :format(name(_1))
end,
      is_confused_more = function(_1)
  return ("%sは余計に混乱した。")
  :format(name(_1))
end,
      mana_is_absorbed = function(_1)
  return ("%sはマナを吸い取られた！")
  :format(name(_1))
end,
      too_difficult = "難解だ！"
    },
    finished_eating = function(_1, _2)
  return ("%s%sを食べ終えた。")
  :format(kare_wa(_1), itemname(_2, 1))
end,
    get_rotten = function(_1)
  return ("%sは腐った。")
  :format(_1)
end,
    hostile_action = {
      get_excited = "家畜は興奮した！",
      gets_furious = function(_1)
  return ("%sは激怒した。")
  :format(name(_1))
end,
      glares_at_you = function(_1)
  return ("%sは嫌な顔をした。")
  :format(name(_1))
end
    },
    identify = {
      almost_identified = function(_1, _2)
  return ("バックパックの中の%sは%sだという感じがする。")
  :format(_1, _2)
end,
      fully_identified = function(_1, _2)
  return ("バックパックの中の%sは%sだと判明した。")
  :format(_1, _2)
end
    },
    income = {
      sent_to_your_house = function(_1)
  return ("%sgoldが給料として振り込まれた。")
  :format(_1)
end,
      sent_to_your_house2 = function(_1, _2)
  return ("%sgoldと%s個のアイテムが給料として振り込まれた。")
  :format(_1, _2)
end
    },
    living_weapon_taste_blood = function(_1)
  return ("%sは十分に血を味わった！")
  :format(_1)
end,
    love_miracle = {
      uh = "「あ…！」"
    },
    map = {
      jail = {
        guard_approaches = "あなたはガードの足音が近づいてくるのに気付いた。",
        leave_here = "「そこのお前、もう反省したころだろう。出てもいいぞ」",
        repent_of_sin = "あなたは罪を悔いた。",
        unlocks_your_cell = "ガードは面倒くさそうにあなたの牢の扉を開けた。"
      },
      museum = {
        chats = { " *ざわざわ* ", "「ふむ…悪くないな」", "「何だろう、これは」", "「ほほう…」", "「私も死んだらはく製に…」", "「ここが噂の…」" },
        chats2 = { " *がやがや* ", "「やだっ気持ち悪い」", "「ねーねーこれ死んでるんでしょ？」", "「かわ、いー♪」", "「今日はとことん見るぜ」", "「触ってもいいの？」" }
      },
      shelter = {
        eat_stored_food = "シェルターの貯蔵食品を食べた。",
        no_longer_need_to_stay = "もうシェルターの中にいる必要は無い。"
      },
      shop = {
        chats = { " *ざわざわ* ", "「これ欲しい〜」", "「何だろう、これは」", "「お買い物♪」", "「金が足りん…」", "「ここが噂の…」" }
      }
    },
    no_target_around = "視界内にターゲットは存在しない。",
    pregnant = {
      gets_pregnant = function(_1)
  return ("%sは寄生された。")
  :format(name(_1))
end,
      pats_stomach = function(_1)
  return ("%sは不安げに腹を押さえた。")
  :format(name(_1))
end,
      pukes_out = "しかしすぐに吐き出した。",
      something_breaks_out = function(_1)
  return ("何かが%sの腹を破り飛び出した！")
  :format(name(_1))
end,
      something_is_wrong = { "「なにかが産まれそうだよ！」", "「腹になにかが…」" }
    },
    quest = {
      kamikaze_attack = {
        message = "伝令「パルミア軍の撤退が完了しました！これ以上ここに留まる必要はありません。機を見て地下から退却してください！」",
        stairs_appear = "階段が現れた。"
      }
    },
    ranking = {
      changed = function(_1, _2, _3, _4)
  return ("ランク変動(%s %s位 → %s位) 《%s》")
  :format(_1, _2, _3, _4)
end,
      closer_to_next_rank = "着実に次のランクに近づいている。"
    },
    resurrect = function(_1)
  return ("%sは復活した！")
  :format(_1)
end,
    ["return"] = {
      air_becomes_charged = "周囲の大気がざわめきだした。",
      forbidden = "依頼請負中の帰還は法律で禁止されている。それでも帰還する？",
      lord_of_dungeon_might_disappear = "このままダンジョンを出ると、この階のクエストは達成できない…",
      no_location = "この大陸には帰還できる場所が無い。",
      where_do_you_want_to_go = "どの場所に帰還する？"
    },
    save = {
      cannot_save_in_user_map = "ユーザーマップの中ではセーブできない。",
      need_to_save_in_town = "アップデートを行うには、街中でセーブしたセーブデータが必要です。",
      take_a_while = "次のプロセスの完了までには、しばらく時間がかかることがあります。",
      update = function(_1)
  return ("Ver.%sのセーブデータをアップデートします。")
  :format(_1)
end
    },
    score = {
      rank = function(_1)
  return ("%s位")
  :format(_1)
end,
      score = function(_1)
  return ("%s点")
  :format(_1)
end
    },
    shakes_head = function(_1)
  return ("%sは頭を振った。")
  :format(name(_1))
end,
    sound = {
      can_no_longer_stand = "「もう我慢できない」",
      get_anger = function(_1)
  return ("%sはキレた。")
  :format(name(_1))
end,
      waken = function(_1)
  return ("%sは物音に気付き目を覚ました。")
  :format(name(_1))
end
    },
    spell_passes_through = function(_1)
  return ("%sは巻き込みを免れた。")
  :format(name(_1))
end,
    status_ailment = {
      breaks_away_from_gravity = function(_1)
  return ("%sは重力から抜け出した。")
  :format(name(_1))
end,
      calms_down = function(_1)
  return ("%sはやや落ち着いた。")
  :format(name(_1))
end,
      choked = "「うぐぐ…！」",
      insane = { function(_1)
  return ("%s「キョキョキョ」")
  :format(name(_1))
end, function(_1)
  return ("%s「クワッ」")
  :format(name(_1))
end, function(_1)
  return ("%s「シャアァァ」")
  :format(name(_1))
end, function(_1)
  return ("%s「ばぶっふ！」")
  :format(name(_1))
end, function(_1)
  return ("%s「煮殺せ！」")
  :format(name(_1))
end, function(_1)
  return ("%s「許しなさい許しなさい！！」")
  :format(name(_1))
end, function(_1)
  return ("%s「フゥハハハー！」")
  :format(name(_1))
end, function(_1)
  return ("%s「あ、あ、あ、あ」")
  :format(name(_1))
end, function(_1)
  return ("%s「ぴ…ぴ…ぴか…」")
  :format(name(_1))
end, function(_1)
  return ("%s「お兄ちゃん！」")
  :format(name(_1))
end, function(_1)
  return ("%s「うみみやぁ」")
  :format(name(_1))
end, function(_1)
  return ("%sは突然踊りだした。")
  :format(name(_1))
end, function(_1)
  return ("%sは着ていたものを脱ぎだした。")
  :format(name(_1))
end, function(_1)
  return ("%sはぐるぐる回りだした。")
  :format(name(_1))
end, function(_1)
  return ("%sは奇声を発した。")
  :format(name(_1))
end, function(_1)
  return ("%s「ねうねう♪ねうねう♪」")
  :format(name(_1))
end, function(_1)
  return ("%s「ウージッムシ♪ウージッムシ♪」")
  :format(name(_1))
end, function(_1)
  return ("%s「じゃあ殺さなきゃ。うん♪」")
  :format(name(_1))
end, function(_1)
  return ("%s「このナメクジがっ」")
  :format(name(_1))
end, function(_1)
  return ("%s「おすわり！」")
  :format(name(_1))
end, function(_1)
  return ("%s「フーーーーン フーーーーン･･･ フーーーンフ」")
  :format(name(_1))
end, function(_1)
  return ("%s「このかたつむり野郎がっ」")
  :format(name(_1))
end, function(_1)
  return ("%s「うにゅみゅあ！」")
  :format(name(_1))
end, function(_1)
  return ("%s「ごめんなさいごめんなさい！」")
  :format(name(_1))
end, function(_1)
  return ("%s「もうすぐ生まれるよ♪」")
  :format(name(_1))
end, function(_1)
  return ("%s「フーーーーン フー…クワッ！」")
  :format(name(_1))
end },
      sleepy = "あなたは眠りを必要としている。"
    },
    tax = {
      accused = function(_1)
  return ("あなたは税金を%sヶ月滞納した罪で訴えられた。")
  :format(_1)
end,
      bill = "請求書が送られてきた。",
      caution = "注意！",
      have_to_go_embassy = "早急にパルミア大使館まで行き、税金を納めなければならない。",
      left_bills = function(_1)
  return ("税金を%sヶ月分滞納している。")
  :format(_1)
end,
      lose_fame = function(_1)
  return ("名声値を%s失った。")
  :format(_1)
end,
      no_duty = "レベルが6に達していないので納税の義務はない。",
      warning = "警告！！"
    },
    walk_down_stairs = "階段を降りた。",
    walk_up_stairs = "階段を昇った。",
    wet = {
      gets_wet = function(_1)
  return ("%sは濡れた。")
  :format(name(_1))
end,
      is_revealed = function(_1)
  return ("%sの姿があらわになった。")
  :format(name(_1))
end
    },
    wields_proudly = {
      the = ""
    }
  }
}
