return {
   production = {
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
         title = "生産品の選択",
         x = "×"
      },
      you_crafted = function(_1)
         return ("%sを製造した。")
            :format(_1)
      end,
      you_do_not_meet_requirements = "生産の条件を満たしてない。"
   }
}
