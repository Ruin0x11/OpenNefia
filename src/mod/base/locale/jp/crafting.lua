return {
  crafting = {
    menu = {
      detail = "説明",
      make = function(_1)
  return ("アイテム[%s]")
  :format(_1)
end,
      material = "必要素材",
      product = "生産品",
      requirement = "詳細",
      skill_needed = "必要スキル",
      skills = {
        _176 = "大工",
        _177 = "裁縫",
        _178 = "錬金術",
        _179 = "宝石細工"
      },
      title = "生産品の選択",
      x = "×"
    },
    you_crafted = function(_1)
  return ("%sを製造した。")
  :format(itemname(_1, 1))
end,
    you_do_not_meet_requirements = "生産の条件を満たしてない。"
  }
}