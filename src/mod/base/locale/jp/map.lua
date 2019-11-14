return {
  map = {
    loading_failed = "マップのロードに失敗しました。",
    location_changed = function(_1, _2, _3, _4, _5)
  return ("エリアが再配置されます。%sの位置は、x%s:y%sからx%s:y%sに変更されます。")
  :format(_1, _2, _3, _4, _5)
end,
    misc_location = {
      _1 = "炭鉱",
      _2 = "畑",
      _3 = "アトリエ",
      _4 = "寺院",
      _5 = "盗賊の隠れ家",
      _6 = "灯台"
    },
    nefia = {
      level = "層",
      prefix = {
        type_a = {
          _0 = "はじまりの",
          _1 = "冒険者の",
          _2 = "迷いの",
          _3 = "死の",
          _4 = "不帰の"
        },
        type_b = {
          _0 = "安全な",
          _1 = "時めきの",
          _2 = "勇者の",
          _3 = "闇の",
          _4 = "混沌の"
        }
      },
      suffix = {
        _20 = "洞窟",
        _21 = "塔",
        _22 = "森",
        _23 = "砦"
      }
    },
    no_dungeon_master = function(_1)
  return ("辺りからは何の緊張感も感じられない。%sの主はもういないようだ。")
  :format(_1)
end,
    prompt_initialize = "マップを初期化しますか？（注：ゲームに影響が出る可能性があります。エラーが出てマップが読み込めない場合のみ、必ず元のセーブのバックアップをとった上で実行してください。）",
    quest = {
      field = "街周辺の畑",
      on_enter = {
        conquer = function(_1, _2)
  return ("%s分以内に、%sを討伐しなければならない。")
  :format(_2, _1)
end,
        harvest = function(_1, _2)
  return ("%s分以内に、納入箱に%sの作物を納入しよう。")
  :format(_2, _1)
end,
        party = function(_1, _2)
  return ("%s分間の間にパーティーを盛り上げよう。目標は%sポイント。")
  :format(_1, _2)
end
      },
      outskirts = "街近辺",
      party_room = "パーティー場",
      urban_area = "市街地"
    },
    since_leaving = {
      time_passed = function(_1, _2, _3, _4)
  return ("%sに%sを発ってから、%s日と%s時間の旅を終えた。")
  :format(_4, _3, _1, _2)
end,
      walked = {
        you = function(_1)
  return ("あなたは%sマイルの距離を歩き、経験を積んだ。")
  :format(_1)
end,
        you_and_allies = function(_1)
  return ("あなたとその仲間は%sマイルの距離を歩き、経験を積んだ。")
  :format(_1)
end
      }
    },
    unique = {
      _10 = {
        desc = "墓所が見える。辺りは静寂に包まれている…",
        name = "ルミエスト墓所"
      },
      _101 = {
        name = "博物館"
      },
      _102 = {
        name = "店"
      },
      _103 = {
        name = "畑"
      },
      _104 = {
        name = "倉庫"
      },
      _11 = {
        desc = "ポート・カプールが見える。港は船で賑わっている。",
        name = "ポート・カプール"
      },
      _12 = {
        desc = "ヨウィンの村が見える。懐かしい土の匂いがする。",
        name = "ヨウィン"
      },
      _14 = {
        desc = "ダルフィの街がある。何やら危険な香りがする。",
        name = "ダルフィ"
      },
      _15 = {
        desc = "パルミアの都がある。都は高い壁に囲われている。",
        name = "パルミア"
      },
      _16 = {
        name = "灼熱の塔"
      },
      _17 = {
        name = "死者の洞窟"
      },
      _18 = {
        name = "古城"
      },
      _19 = {
        name = "竜窟"
      },
      _2 = {
        desert = "草原",
        forest = "森",
        grassland = "草原",
        name = "野外",
        plain_field = "平地",
        sea = "水上",
        snow_field = "雪原"
      },
      _20 = {
        desc = "寺院がある。神聖な雰囲気がする。",
        name = "神々の休戦地"
      },
      _21 = {
        desc = "何やら奇妙な建物がある。",
        name = "アクリ・テオラ"
      },
      _22 = {
        desc = "不気味な城がある。絶対に入ってはいけない予感がする。(危険度は666階相当)",
        name = "混沌の城《獣》"
      },
      _23 = {
        desc = "不気味な城がある。絶対に入ってはいけない予感がする。(危険度は666階相当)",
        name = "混沌の城《機甲》"
      },
      _24 = {
        desc = "不気味な城がある。絶対に入ってはいけない予感がする。(危険度は666階相当)",
        name = "混沌の城《奇形》"
      },
      _25 = {
        name = "ラーナ"
      },
      _26 = {
        name = "山道"
      },
      _27 = {
        name = "子犬の洞窟"
      },
      _28 = {
        name = "イークの洞窟"
      },
      _29 = {
        name = "妹の館"
      },
      _3 = {
        desc = "レシマスの洞窟がある。運命の鼓動を感じる。",
        name = "レシマス",
        the_depth = "レシマス最深層"
      },
      _30 = {
        name = "シェルター"
      },
      _31 = {
        name = "牧場"
      },
      _32 = {
        name = "パルミア大使館"
      },
      _33 = {
        desc = "ノイエルの村がある。子供たちの笑い声が聞こえる。",
        name = "ノイエル"
      },
      _34 = {
        name = "工房ミラル・ガロク"
      },
      _35 = {
        name = "ハウスドーム"
      },
      _36 = {
        desc = "ルミエストの都が見える。水のせせらぎが聴こえる。",
        name = "ルミエスト"
      },
      _37 = {
        name = "ピラミッド"
      },
      _38 = {
        name = "ﾐﾉﾀｳﾛｽの巣"
      },
      _39 = {
        desc = "あなたのダンジョンだ。",
        name = "ダンジョン"
      },
      _4 = {
        name = "ノースティリス"
      },
      _40 = {
        name = "コロシアム"
      },
      _41 = {
        desc = "収容所がある。入り口は固く閉ざされている。",
        name = "牢獄"
      },
      _42 = {
        desc = "なんだこの場所は…？",
        name = "すくつ"
      },
      _43 = {
        name = "ノースティリス南関所"
      },
      _44 = {
        name = "サウスティリス"
      },
      _45 = {
        name = "サウスティリス北関所"
      },
      _46 = {
        name = "煙とパイプ亭"
      },
      _47 = {
        name = "テストワールド"
      },
      _48 = {
        name = "テストワールド北関所"
      },
      _499 = {
        name = "デバッグマップ"
      },
      _5 = {
        desc = "ヴェルニースの街が見える。辺りは活気に満ちている。",
        name = "ヴェルニース"
      },
      _6 = {
        name = "闘技場"
      },
      _7 = {
        desc = "あなたの家だ。",
        name = "わが家"
      },
      _9 = {
        name = "実験場"
      },
      battle_field = {
        name = "防衛線"
      },
      cat_mansion = {
        name = "タムの猫屋敷"
      },
      doom_ground = {
        name = "戦場"
      },
      fighters_guild = {
        name = "戦士ギルド"
      },
      mages_guild = {
        name = "魔術士ギルド"
      },
      robbers_hideout = {
        name = "盗賊の隠れ家"
      },
      test_site = {
        name = "生体兵器実験場"
      },
      the_mine = {
        name = "スライムの坑道"
      },
      the_sewer = {
        name = "ルミエスト下水道"
      },
      thieves_guild = {
        name = "盗賊ギルド"
      }
    },
    you_see = function(_1)
  return ("%sがある。")
  :format(_1)
end,
    you_see_an_entrance = function(_1, _2)
  return ("%sへの入り口がある(入り口の危険度は%s階相当)。")
  :format(_1, _2)
end
  }
}