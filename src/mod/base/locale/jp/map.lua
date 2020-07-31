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
    you_see = function(_1)
  return ("%sがある。")
  :format(_1)
end,
    you_see_an_entrance = function(_1, _2)
  return ("%sへの入り口がある(入り口の危険度は%s階相当)。")
  :format(_1, _2)
end,
    default_name = "新規マップ"
  }
}
