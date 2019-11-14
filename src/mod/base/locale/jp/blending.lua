return {
  blending = {
    failed = "調合失敗！",
    ingredient = {
      _1 = "適当な調味料",
      _2 = "適当な鉱石",
      _3 = "木材を含む何か",
      _4 = "魚介類",
      _5 = "何か物体",
      corpse = function(_1)
  return ("%sの死体")
  :format(_1)
end
    },
    prompt = {
      from_the_start = "最初から",
      go_back = "前に戻る",
      how_many = "幾つ作る？",
      start = "調合を始める"
    },
    rate_panel = {
      and_hours = function(_1)
  return ("と%s時間")
  :format(_1)
end,
      required_time = function(_1)
  return ("必要時間: %s")
  :format(_1)
end,
      success_rate = function(_1)
  return ("成功率: %s")
  :format(_1)
end,
      turns = function(_1)
  return ("%sターン")
  :format(_1)
end
    },
    recipe = {
      _200 = "媚薬混入食品",
      _201 = "染色",
      _202 = "特製毒入り食品",
      _203 = "耐火コーティング",
      _204 = "耐酸コーティング",
      _205 = "釣り餌の装着",
      _206 = "アイテムの祝福",
      _207 = "井戸水の回復",
      _208 = "天然ポーション",
      _209 = "2種アーティファクト合成",
      _210 = "3種アーティファクト合成",
      counter = function(_1)
  return ("%s recipes")
  :format(_1)
end,
      hint = "[ページ切替]  ",
      name = "レシピの名称",
      of = function(_1)
  return ("%sのレシピ")
  :format(_1)
end,
      title = "レシピの選択",
      warning = "(製作中)だめまだ",
      which = "どのレシピを使う？"
    },
    required_material_not_found = "調合に必要な材料が見つからない。",
    sounds = { " *こねこね* ", " *トントン* " },
    started = function(_1, _2)
  return ("%sは%sの調合をはじめた。")
  :format(name(_1), _2)
end,
    steps = {
      add_ingredient = function(_1)
  return ("%sを追加しよう。")
  :format(_1)
end,
      add_ingredient_prompt = function(_1)
  return ("%sを追加")
  :format(_1)
end,
      ground = "(地面)",
      item_counter = function(_1)
  return ("%s items")
  :format(_1)
end,
      item_name = "アイテムの名称",
      you_add = function(_1)
  return ("%sを選んだ。")
  :format(itemname(_1))
end
    },
    succeeded = function(_1)
  return ("%sの作成に成功した！")
  :format(itemname(_1, 1))
end,
    success_rate = {
      almost_impossible = "まず無理",
      bad = "だめかも",
      goes_down = "調合の成功率が下がった。",
      goes_up = "調合の成功率が上がった。",
      impossible = "絶対ムリ！",
      maybe = "ちょっと不安",
      no_problem = "まず大丈夫",
      perfect = "もう完璧！",
      piece_of_cake = "朝飯前！",
      probably_ok = "たぶんいける",
      very_bad = "やばい",
      very_likely = "かんたんね"
    },
    window = {
      add = function(_1, _2)
  return ("%sを加える(所持:%s)")
  :format(_1, _2)
end,
      choose_a_recipe = "レシピを選ぶ",
      chose_the_recipe_of = function(_1)
  return ("%sのレシピを選んだ")
  :format(_1)
end,
      havent_identified = "このアイテムは鑑定されていない。",
      no_inherited_effects = "継承効果なし",
      procedure = "調合の手順",
      required_equipment = "必要な機材:",
      required_skills = "必要なスキル:",
      selected = function(_1)
  return ("%sを選んだ")
  :format(itemname(_1))
end,
      start = "調合を始める！",
      the_recipe_of = function(_1)
  return ("%sのレシピ")
  :format(_1)
end
    },
    you_lose = function(_1)
  return ("%sを失った。")
  :format(itemname(_1, 1))
end
  }
}