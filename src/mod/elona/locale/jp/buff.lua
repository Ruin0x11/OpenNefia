return {
  buff = {
    _1 = {
      apply = function(_1)
  return ("%sは光り輝いた。")
  :format(name(_1))
end,
      description = function(_1)
  return ("PVを%s上昇/耐恐怖")
  :format(_1)
end,
      name = "聖なる盾"
    },
    _10 = {
      apply = function(_1)
  return ("%sは聖なる衣に保護された。")
  :format(name(_1))
end,
      description = function(_1)
  return ("ﾊﾟﾜｰ%sの呪い(hex)への抵抗")
  :format(_1)
end,
      name = "ホーリーヴェイル"
    },
    _11 = {
      apply = function(_1)
  return ("%sは悪夢に襲われた。")
  :format(name(_1))
end,
      description = "神経幻惑耐性の減少",
      name = "ナイトメア"
    },
    _12 = {
      apply = function(_1)
  return ("%sの思考は冴え渡った。")
  :format(name(_1))
end,
      description = function(_1, _2)
  return ("習得・魔力を%s上昇/読書を%s上昇")
  :format(_1, _2)
end,
      name = "知者の加護"
    },
    _13 = {
      apply = function(_1)
  return ("%sは雷に打たれた！")
  :format(name(_1))
end,
      description = function(_1, _2)
  return ("%sの鈍足/PVを%s%減少")
  :format(_1, _2)
end,
      name = "天罰"
    },
    _14 = {
      apply = function(_1)
  return ("%sにルルウィが乗り移った。")
  :format(name(_1))
end,
      description = function(_1)
  return ("%sの加速")
  :format(_1)
end,
      name = "ルルウィの憑依"
    },
    _15 = {
      apply = function(_1)
  return ("%sは別人になりすました。")
  :format(name(_1))
end,
      description = "変装",
      name = "インコグニート"
    },
    _16 = {
      apply = function(_1)
  return ("%sは死の宣告を受けた！")
  :format(name(_1))
end,
      description = "呪いが完了したときに確実なる死",
      name = "死の宣告"
    },
    _17 = {
      apply = function(_1)
  return ("%sはブーストした！")
  :format(name(_1))
end,
      description = function(_1)
  return ("%sの加速と能力のアップ")
  :format(_1)
end,
      name = "ブースト"
    },
    _18 = {
      apply = function(_1)
  return ("%sは死神と契約した。")
  :format(name(_1))
end,
      description = function(_1)
  return ("致命傷を負ったとき%s%の確率でダメージ分回復。")
  :format(_1)
end,
      name = "契約"
    },
    _19 = {
      apply = function(_1)
  return ("%sに幸運な日が訪れた！")
  :format(name(_1))
end,
      description = function(_1)
  return ("%sの幸運の上昇")
  :format(_1)
end,
      name = "幸運"
    },
    _2 = {
      apply = function(_1)
  return ("%sはぼやけた霧に覆われた。")
  :format(name(_1))
end,
      description = "魔法の使用を禁止",
      name = "沈黙の霧"
    },
    _20 = {
      apply = "",
      description = function(_1)
  return ("筋力の成長率を%s%上昇")
  :format(_1)
end,
      name = "筋力の成長"
    },
    _21 = {
      apply = "",
      description = function(_1)
  return ("耐久の成長率を%s%上昇")
  :format(_1)
end,
      name = "耐久の成長"
    },
    _22 = {
      apply = "",
      description = function(_1)
  return ("器用の成長率を%s%上昇")
  :format(_1)
end,
      name = "器用の成長"
    },
    _23 = {
      apply = "",
      description = function(_1)
  return ("感覚の成長率を%s%上昇")
  :format(_1)
end,
      name = "感覚の成長"
    },
    _24 = {
      apply = "",
      description = function(_1)
  return ("習得の成長率を%s%上昇")
  :format(_1)
end,
      name = "習得の成長"
    },
    _25 = {
      apply = "",
      description = function(_1)
  return ("意思の成長率を%s%上昇")
  :format(_1)
end,
      name = "意思の成長"
    },
    _26 = {
      apply = "",
      description = function(_1)
  return ("魔力の成長率を%s%上昇")
  :format(_1)
end,
      name = "魔力の成長"
    },
    _27 = {
      apply = "",
      description = function(_1)
  return ("魅力の成長率を%s%上昇")
  :format(_1)
end,
      name = "魅力の成長"
    },
    _28 = {
      apply = "",
      description = function(_1)
  return ("速度の成長率を%s%上昇")
  :format(_1)
end,
      name = "速度の成長"
    },
    _29 = {
      apply = "",
      description = function(_1)
  return ("運勢の成長率を%s%上昇")
  :format(_1)
end,
      name = "運勢の成長"
    },
    _3 = {
      apply = function(_1)
  return ("%sの代謝が活性化した。")
  :format(name(_1))
end,
      description = "自然回復強化",
      name = "リジェネレーション"
    },
    _4 = {
      apply = function(_1)
  return ("%sは元素への耐性を得た。")
  :format(name(_1))
end,
      description = "炎冷気電撃耐性の獲得",
      name = "元素保護"
    },
    _5 = {
      apply = function(_1)
  return ("%sは機敏になった。")
  :format(name(_1))
end,
      description = function(_1)
  return ("%sの加速")
  :format(_1)
end,
      name = "加速"
    },
    _6 = {
      apply = function(_1)
  return ("%sは鈍重になった。")
  :format(name(_1))
end,
      description = function(_1)
  return ("%sの鈍足")
  :format(_1)
end,
      name = "鈍足"
    },
    _7 = {
      apply = function(_1)
  return ("%sの士気が向上した。")
  :format(name(_1))
end,
      description = function(_1)
  return ("筋力・器用を%s上昇/耐恐怖/耐混乱")
  :format(_1)
end,
      name = "英雄"
    },
    _8 = {
      apply = function(_1)
  return ("%sは脆くなった。")
  :format(name(_1))
end,
      description = "DVとPVを半減",
      name = "脆弱の霧"
    },
    _9 = {
      apply = function(_1)
  return ("%sは元素への耐性を失った。")
  :format(name(_1))
end,
      description = "炎冷気電撃耐性の減少",
      name = "元素の傷跡"
    }
  }
}