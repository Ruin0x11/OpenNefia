return {
  magic = {
    absorb_magic = function(_1)
  return ("%sは周囲からマナを吸い取った。")
  :format(name(_1))
end,
    acid = {
      apply = function(_1)
  return ("酸が%sを溶かした。")
  :format(name(_1))
end,
      self = "ぐわぁぁ！"
    },
    alchemy = function(_1)
  return ("それは%sに変容した。")
  :format(itemname(_1, 1))
end,
    alcohol = {
      cursed = { "「うぃっ…」", "「まずいぜ」", "「げー♪」", "「腐ったミルクみたいな味だ」" },
      normal = { "「うぃっ！」", "「うまいぜ」", "「らららー♪」", "「ひっく」", "「ふぅ」", "「たまらないわ」", "「んまっ♪」" }
    },
    arrow = {
      ally = function(_1)
  return ("矢が%sに命中した。")
  :format(name(_1))
end,
      other = function(_1)
  return ("矢は%sに命中し")
  :format(name(_1))
end
    },
    ball = {
      ally = function(_1)
  return ("ボールが%sに命中した。")
  :format(name(_1))
end,
      other = function(_1)
  return ("ボールは%sに命中し")
  :format(name(_1))
end
    },
    bolt = {
      ally = function(_1)
  return ("ボルトが%sに命中した。")
  :format(name(_1))
end,
      other = function(_1)
  return ("ボルトは%sに命中し")
  :format(name(_1))
end
    },
    breath = {
      ally = function(_1)
  return ("ブレスは%sに命中した。")
  :format(name(_1))
end,
      bellows = function(_1, _2)
  return ("%sは%sブレスを吐いた。")
  :format(name(_1), _2)
end,
      named = function(_1)
  return ("%sの")
  :format(_1)
end,
      no_element = "",
      other = function(_1)
  return ("ブレスは%sに命中し")
  :format(name(_1))
end
    },
    buff = {
      ends = function(_1)
  return ("%sの効果が切れた。")
  :format(_1)
end,
      holy_veil_repels = "ホーリーヴェイルが呪いを防いだ。",
      no_effect = "しかし、効果はなかった。",
      resists = function(_1)
  return ("%sは抵抗した。")
  :format(name(_1))
end
    },
    change = {
      apply = function(_1)
  return ("%sは変化した。")
  :format(name(_1))
end,
      cannot_be_changed = function(_1)
  return ("%sは変化できない。")
  :format(name(_1))
end
    },
    change_material = {
      apply = function(_1, _2, _3)
  return ("%sの%sは%sに変化した。")
  :format(name(_1), _2, itemname(_3, 1))
end,
      artifact_reconstructed = function(_1, _2)
  return ("%sの%sは再生成された。")
  :format(name(_1), itemname(_2, 1))
end,
      more_power_needed = "アーティファクトの再生成にはパワーが足りない。"
    },
    cheer = {
      apply = function(_1)
  return ("%sは仲間を鼓舞した。")
  :format(name(_1))
end,
      is_excited = function(_1)
  return ("%sは興奮した！")
  :format(name(_1))
end
    },
    common = {
      cursed = function(_1)
  return ("%sは悪魔が笑う声を聞いた。")
  :format(name(_1))
end,
      it_is_cursed = "これは呪われている！",
      melts_alien_children = function(_1)
  return ("%sの体内のエイリアンは溶けた。")
  :format(name(_1))
end,
      resists = function(_1)
  return ("%sは抵抗した。")
  :format(name(_1))
end,
      too_exhausted = "疲労し過ぎて失敗した！"
    },
    confusion = function(_1)
  return ("%sはひどい頭痛におそわれた！")
  :format(name(_1))
end,
    cook = {
      do_not_know = "料理の仕方を知らない。"
    },
    create = {
      door = {
        apply = "扉が出現した。",
        resist = "この壁は魔法を受け付けないようだ。"
      },
      wall = "床が盛り上がってきた。"
    },
    create_material = {
      apply = function(_1)
  return ("たくさんの%sが降ってきた！")
  :format(_1)
end,
      junks = "クズ",
      materials = "素材"
    },
    cure_corruption = {
      apply = "エーテルの抗体があなたの体内に行き渡った。",
      cursed = "エーテルの病菌があなたの体内に行き渡った。"
    },
    cure_mutation = "あなたは元の自分に近づいた気がした。",
    curse = {
      apply = function(_1, _2)
  return ("%sの%sは黒く輝いた。")
  :format(name(_1), _2)
end,
      no_effect = "あなたは祈祷を捧げ呪いのつぶやきを無効にした。",
      spell = function(_1, _2)
  return ("%sは%sを指差して呪いの言葉を呟いた。")
  :format(name(_1), name(_2))
end
    },
    deed_of_inheritance = {
      can_now_inherit = function(_1)
  return ("今やあなたは%s個の遺産を相続できる。")
  :format(_1)
end,
      claim = function(_1)
  return ("あなたは遺産相続人として認められた(+%s)。")
  :format(_1)
end
    },
    descent = function(_1)
  return ("%sのレベルが下がった…")
  :format(name(_1))
end,
    diary = {
      cat_sister = "なんと、あなたには生き別れた血の繋がっていないぬこの妹がいた！",
      young_lady = "お嬢さんが空から降ってきた！",
      younger_sister = "なんと、あなたには生き別れた血の繋がっていない妹がいた！"
    },
    dirty_water = {
      other = " *ごくっ* ",
      self = "*ごくっ* まずい！"
    },
    disassembly = "「余分な機能は削除してしまえ」",
    domination = {
      cannot_be_charmed = function(_1)
  return ("%sは支配できない。")
  :format(name(_1))
end,
      does_not_work_in_area = "この場所では効果がない。"
    },
    draw_charge = function(_1, _2, _3)
  return ("%sを破壊して%sの魔力を抽出した(計%s)")
  :format(itemname(_1), _2, _3)
end,
    drop_mine = function(_1)
  return ("%sは何かを投下した。")
  :format(name(_1))
end,
    enchant = {
      apply = function(_1)
  return ("%sは黄金の光に包まれた。")
  :format(itemname(_1))
end,
      resist = function(_1)
  return ("%sは抵抗した。")
  :format(itemname(_1))
end
    },
    escape = {
      begin = "周囲の大気がざわめきだした。",
      cancel = "脱出を中止した。",
      during_quest = "依頼請負中の帰還は法律で禁止されている。それでも帰還する？",
      lord_may_disappear = "このままダンジョンを出ると、この階のクエストは達成できない…"
    },
    explosion = {
      ally = function(_1)
  return ("爆風が%sに命中した。")
  :format(name(_1))
end,
      begins = function(_1)
  return ("%sは爆発した。")
  :format(name(_1))
end,
      chain = function(_1)
  return ("%sは誘爆した。")
  :format(name(_1))
end,
      other = function(_1)
  return ("爆風は%sに命中し")
  :format(name(_1))
end
    },
    eye_of_ether = function(_1)
  return ("%sに睨まれ、あなたはエーテルに侵食された。")
  :format(name(_1))
end,
    faith = {
      apply = function(_1)
  return ("あなたは%sの暖かい眼差しを感じた。")
  :format(_1)
end,
      blessed = "空から三つ葉のクローバーがふってきた。",
      doubt = "あなたの神はあなたの信仰に疑問を抱いた。"
    },
    fill_charge = {
      apply = function(_1, _2)
  return ("%sは充填された(+%s)。")
  :format(itemname(_1), _2)
end,
      cannot_recharge = "それは充填ができないようだ。",
      cannot_recharge_anymore = function(_1)
  return ("%sはこれ以上充填できないようだ。")
  :format(itemname(_1))
end,
      explodes = function(_1)
  return ("%sへの充填は失敗した。")
  :format(itemname(_1))
end,
      fail = function(_1)
  return ("%sは破裂した。")
  :format(itemname(_1))
end,
      more_power_needed = "充填するには最低でも魔力の貯蓄が10必要だ。",
      spend = function(_1)
  return ("魔力の貯蓄を10消費した(残り%s)")
  :format(_1)
end
    },
    fish = {
      cannot_during_swim = "水の中からは釣れない。",
      do_not_know = "釣りの仕方を知らない。",
      need_bait = "釣竿には餌が付いていない。",
      not_good_place = "釣りをする場所が見当たらない。"
    },
    flying = {
      apply = function(_1)
  return ("%sは羽が生えたように軽くなった。")
  :format(itemname(_1, 1))
end,
      cursed = function(_1)
  return ("%sはずしりと重くなった。")
  :format(itemname(_1, 1))
end
    },
    four_dimensional_pocket = "あなたは四次元のポケットを召喚した。",
    gain_knowledge = {
      furthermore = "さらに、",
      gain = function(_1)
  return ("%sは%sの魔法の知識を得た。")
  :format(you(), _1)
end,
      lose = function(_1)
  return ("突然、%sは%sの魔法の知識を失った。")
  :format(you(), _1)
end,
      suddenly = "突然、"
    },
    gain_potential = {
      blessed = function(_1)
  return ("%sの全ての能力の潜在能力が上昇した。")
  :format(name(_1))
end,
      decreases = function(_1, _2)
  return ("%sの%sの潜在能力が減少した。")
  :format(name(_1), _2)
end,
      increases = function(_1, _2)
  return ("%sの%sの潜在能力が上昇した。")
  :format(name(_1), _2)
end
    },
    gain_skill = function(_1, _2)
  return ("%sは%sの技術を獲得した！")
  :format(name(_1), _2)
end,
    gain_skill_potential = {
      decreases = function(_1, _2)
  return ("%sの%sの技術の潜在能力が減少した。")
  :format(name(_1), _2)
end,
      furthermore_the = "さらに",
      increases = function(_1, _2)
  return ("%sの%sの技術の潜在能力が上昇した。")
  :format(name(_1), _2)
end,
      the = ""
    },
    garoks_hammer = {
      apply = function(_1)
  return ("それは%sになった。")
  :format(itemname(_1, 1))
end,
      no_effect = "そのアイテムに改良の余地はない。"
    },
    gaze = function(_1, _2)
  return ("%sは%sを睨み付けた。")
  :format(name(_1), name(_2))
end,
    gravity = function(_1)
  return ("%sは重力を感じた。")
  :format(name(_1))
end,
    harvest_mana = function(_1)
  return ("%sのマナが回復した。")
  :format(name(_1))
end,
    healed = {
      completely = function(_1)
  return ("%sは完全に回復した。")
  :format(name(_1))
end,
      greatly = function(_1)
  return ("%sの身体に生命力がみなぎった。")
  :format(name(_1))
end,
      normal = function(_1)
  return ("%sは回復した。")
  :format(name(_1))
end,
      slightly = function(_1)
  return ("%sの傷はふさがった。")
  :format(name(_1))
end
    },
    hunger = function(_1)
  return ("%sはお腹が減った。")
  :format(name(_1))
end,
    ink_attack = function(_1)
  return ("%sは墨を浴びた！")
  :format(name(_1))
end,
    insanity = { function(_1, _2)
  return ("%sは%sの腹の亀裂から蛆虫が沸き出るのを見た。")
  :format(name(_2), name(_1))
end, function(_1, _2)
  return ("%sは%sが屍を貪る姿を目撃した。")
  :format(name(_2), name(_1))
end, function(_1, _2)
  return ("%sは%sの恐ろしい瞳に震えた。")
  :format(name(_2), name(_1))
end, function(_1, _2)
  return ("%sは%sの触手に絡まる臓物に吐き気を感じた。")
  :format(name(_2), name(_1))
end },
    insult = {
      apply = function(_1, _2)
  return ("%sは%sを罵倒した。")
  :format(name(_1), name(_2))
end
    },
    love_potion = {
      cursed = function(_1)
  return ("媚薬は呪われていた。%sは%sを軽蔑のまなざしで見つめた。")
  :format(name(_1), you())
end,
      other = function(_1)
  return ("%sは%sを熱いまなざしで見つめた。")
  :format(name(_1), you())
end,
      self = function(_1)
  return ("%sは興奮した！")
  :format(name(_1))
end,
      spill = function(_1)
  return ("%sは恋の予感がした。")
  :format(name(_1))
end
    },
    map = {
      apply = "何かの場所を記した地図のようだ…",
      cursed = "呪われた地図は触れると崩れ落ちた。",
      mark = "○",
      need_global_map = "それはグローバルマップで読む必要がある。"
    },
    map_effect = {
      acid = "酸の水溜りが発生した。",
      ether_mist = "エーテルの霧が発生した。",
      fire = "火柱が発生した。",
      fog = "辺りを濃い霧が覆った。",
      web = "蜘蛛の巣が辺りを覆った。"
    },
    meteor = "隕石が落ちてきた！",
    mewmewmew = "うみみゃぁ！",
    milk = {
      cursed = {
        other = "「ぺっぺっ、まずー」",
        self = "うわ、これは呪われている。なんだかやばい味だ…"
      },
      other = "「うまー」",
      self = "濃厚で病み付きになりそうな味だ。"
    },
    mirror = "あなたは自分の状態を調べた。",
    molotov = function(_1)
  return ("%sは炎に包まれた。")
  :format(name(_1))
end,
    mount = {
      currently_riding = function(_1, _2)
  return ("現在%sは%sに騎乗している。")
  :format(name(_1), name(_2))
end,
      dismount = function(_1)
  return ("%sから降りた。")
  :format(name(_1))
end,
      dismount_dialog = { "「ふぅ」", "「乗り心地はよかった？」", "「疲れた…」", "「またいつでも乗ってね♪」" },
      mount = {
        dialog = { "「うぐぅ」", "「ダイエットしてよ…」", "「いくよ！」", "「やさしくしてね♪」" },
        execute = function(_1, _2)
  return ("%sに騎乗した(%sの速度: %s→")
  :format(name(_1), name(_1), _2)
end,
        suitable = "この生物は乗馬用にちょうどいい！",
        unsuitable = "この生物はあなたを乗せるには非力すぎる。"
      },
      no_place_to_get_off = "降りるスペースがない。",
      not_client = "護衛対象には騎乗できない。",
      only_ally = "仲間にしか騎乗できない。",
      ride_self = function(_1)
  return ("%sは自分に乗ろうとした。")
  :format(name(_1))
end,
      stays_in_area = "その仲間はこの場所に滞在中だ。"
    },
    mutation = {
      apply = "あなたは変容した！ ",
      resist = "あなたは変異を受け付けなかった。",
      spell = function(_1, _2)
  return ("%sは%sを気の狂いそうな眼差しで見た。")
  :format(name(_1), name(_2))
end
    },
    name = {
      apply = function(_1)
  return ("それは%sという銘になった。")
  :format(_1)
end,
      prompt = "アーティファクトの新しい銘は？"
    },
    oracle = {
      cursed = "何かがあなたの耳元でささやいたが、あなたは聞き取ることができなかった。",
      no_artifacts = "まだ特殊なアイテムは生成されていない。",
      was_created_at = function(_1, _2, _3, _4, _5)
  return ("%sは%s年%s月に%sで生成された。")
  :format(_1, _5, _4, _2)
end,
      was_held_by = function(_1, _2, _3, _4, _5, _6)
  return ("%sは%s年%s月に%sの%sの手に渡った。")
  :format(_1, _6, _5, _3, basename(_2))
end
    },
    paralysis = function(_1)
  return ("%sは痺れた！")
  :format(name(_1))
end,
    perform = {
      do_not_know = function(_1)
  return ("%sは演奏のやり方を知らない。")
  :format(name(_1))
end
    },
    poison_attack = function(_1)
  return ("%sは毒を浴びた！")
  :format(name(_1))
end,
    prayer = function(_1)
  return ("%sは黄金の輝きに包まれた！")
  :format(name(_1))
end,
    pregnant = function(_1, _2)
  return ("%sは%sの口の中に何かを送り込んだ！")
  :format(name(_1), name(_2))
end,
    rain_of_sanity = function(_1)
  return ("%sの狂気は消え去った。")
  :format(name(_1))
end,
    restore = {
      body = {
        apply = function(_1)
  return ("%sの肉体は復活した。")
  :format(name(_1))
end,
        blessed = function(_1)
  return ("さらに、%sの肉体は強化された。")
  :format(name(_1))
end,
        cursed = function(_1)
  return ("%sの肉体は蝕まれた。")
  :format(name(_1))
end
      },
      mind = {
        apply = function(_1)
  return ("%sの精神は復活した。")
  :format(name(_1))
end,
        blessed = function(_1)
  return ("さらに、%sの精神は強化された。")
  :format(name(_1))
end,
        cursed = function(_1)
  return ("%sの精神は蝕まれた。")
  :format(name(_1))
end
      }
    },
    restore_stamina = {
      apply = function(_1)
  return ("%sのスタミナが少し回復した。")
  :format(name(_1))
end,
      dialog = "*シュワワ* 刺激的！"
    },
    restore_stamina_greater = {
      apply = function(_1)
  return ("%sのスタミナはかなり回復した。")
  :format(name(_1))
end,
      dialog = "*ごくり*"
    },
    resurrection = {
      apply = function(_1)
  return ("%sは復活した！")
  :format(_1)
end,
      cursed = "冥界から死霊が呼び出された！",
      dialog = "「ありがとう！」",
      fail = function(_1)
  return ("%sの力は冥界に及ばなかった。")
  :format(name(_1))
end
    },
    ["return"] = {
      cancel = "帰還を中止した。",
      destination_changed = "気まぐれな時の管理者により次元は歪められた！",
      door_opens = "あなたは次元の扉を開けた。",
      prevented = {
        ally = "今は帰還できない仲間を連れている。",
        normal = "不思議な力が帰還を阻止した。",
        overweight = "どこからか声が聞こえた。「悪いが重量オーバーだ」"
      },
      you_commit_a_crime = "あなたは法を犯した。"
    },
    salt = {
      apply = "「しょっぱ〜」",
      snail = function(_1)
  return ("塩だ！%sは溶けはじめた！")
  :format(name(_1))
end
    },
    scavenge = {
      apply = function(_1, _2)
  return ("%sは%sのバックパックを漁った。")
  :format(name(_1), name(_2))
end,
      eats = function(_1, _2)
  return ("%sは%sを食べた！")
  :format(name(_1), itemname(_2, 1))
end,
      rotten = function(_1, _2)
  return ("%sは%sの異臭に気付き手をひっこめた。")
  :format(name(_1), itemname(_2, 1))
end
    },
    sense = {
      cursed = "あれ…？あなたは軽い記憶障害を受けた。",
      magic_mapping = function(_1)
  return ("%sは周囲の地形を察知した。")
  :format(name(_1))
end,
      sense_object = function(_1)
  return ("%sは周囲の物質を感知した。")
  :format(name(_1))
end
    },
    sleep = function(_1)
  return ("%sは甘い液体を浴びた！")
  :format(name(_1))
end,
    slow = function(_1)
  return ("%sの老化は遅くなった。")
  :format(name(_1))
end,
    special_attack = {
      other = function(_1, _2)
  return ("%sは%s")
  :format(name(_1), _2)
end,
      self = function(_1, _2, _3)
  return ("%sは%sの%s")
  :format(name(_1), _2, _3)
end
    },
    speed = function(_1)
  return ("%sの老化は速くなった。")
  :format(name(_1))
end,
    steal = {
      in_quest = "そんなことをしている余裕はない！"
    },
    sucks_blood = {
      ally = function(_1)
  return ("%sに血を吸われた。")
  :format(name(_1))
end,
      other = function(_1, _2)
  return ("%s%sの血を吸い")
  :format(kare_wa(_1), name(_2))
end
    },
    summon = "魔法でモンスターが召喚された。",
    swarm = "スウォーム！",
    teleport = {
      disappears = function(_1)
  return ("%sは突然消えた。")
  :format(name(_1))
end,
      draw_shadow = function(_1)
  return ("%sは引き寄せられた。")
  :format(name(_1))
end,
      prevented = "魔法の力がテレポートを防いだ。",
      shadow_step = function(_1, _2)
  return ("%sは%sの元に移動した。")
  :format(name(_1), basename(_2))
end,
      suspicious_hand = {
        after = "泥棒は笑って逃げた。",
        prevented = function(_1)
  return ("%sは自分の財布を守った。")
  :format(name(_1))
end,
        succeeded = function(_1, _2, _3)
  return ("%sは%sから%s枚の金貨を奪った。")
  :format(name(_1), name(_2), _3)
end
      }
    },
    touch = {
      ally = function(_1, _2, _3, _4, _5)
  return ("%sは%sに%s%sで%s")
  :format(name(_1), name(_2), _3, _4, _5)
end,
      other = function(_1, _2, _3, _4, _5)
  return ("%s%sを%s%sで%s")
  :format(kare_wa(_1), name(_2), _3, _4, _5)
end
    },
    troll_blood = {
      apply = function(_1)
  return ("%sの血は沸きあがるように熱くなった。")
  :format(name(_1))
end,
      blessed = "あつつ！"
    },
    uncurse = {
      apply = function(_1)
  return ("%sの装備品は白い光に包まれた。")
  :format(name(_1))
end,
      blessed = function(_1)
  return ("%sは聖なる光に包み込まれた。")
  :format(name(_1))
end,
      equipment = "身に付けている装備の幾つかが浄化された。",
      item = "幾つかのアイテムが浄化された。",
      resist = "幾つかのアイテムは抵抗した。"
    },
    vanish = function(_1)
  return ("%sは消え去った。")
  :format(name(_1))
end,
    vorpal = {
      ally = function(_1, _2)
  return ("%sは%sの首をちょんぎった。")
  :format(name(_1), name(_2))
end,
      other = function(_1, _2)
  return ("%sは%sの首をちょんぎり")
  :format(name(_1), name(_2))
end,
      sound = " *ブシュッ* "
    },
    water = {
      other = " *ごくっ* ",
      self = "*ごくっ* 綺麗な水だ。"
    },
    weaken = function(_1)
  return ("%sは弱くなった。")
  :format(name(_1))
end,
    weaken_resistance = {
      nothing_happens = "何も起こらなかったようだ。"
    },
    wizards_harvest = function(_1)
  return ("%sが降ってきた！")
  :format(itemname(_1))
end
  }
}