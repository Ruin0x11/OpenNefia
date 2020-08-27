return {
  wish = {
    general_wish = {
      card = "カード",
      figure = { "剥製", "はく製" },
      item = "アイテム",
      skill = "スキル",
      summon = "召喚"
    },
    it_is_sold_out = "あ、それ在庫切れ。",
    something_appears = function(_1)
  return ("足元に%sが転がってきた。")
  :format(itemname(_1))
end,
    something_appears_from_nowhere = function(_1)
  return ("足元に%sが転がってきた。")
  :format(itemname(_1))
end,
    special_wish = {
      alias = { "通り名", "異名" },
      ally = "仲間",
      death = "死",
      ehekatl = "エヘカトル",
      fame = "名声",
      god_inside = "中の神",
      gold = { "金", "金貨", "富", "財産" },
      kumiromi = "クミロミ",
      lulwy = "ルルウィ",
      man_inside = "中の人",
      mani = "マニ",
      opatos = "オパートス",
      platinum = { "プラチナ", "プラチナ硬貨" },
      redemption = "贖罪",
      sex = { "性転換", "性", "異性" },
      small_medal = { "メダル", "小さなメダル", "ちいさなメダル" },
      youth = { "若さ", "若返り", "年", "美貌" }
    },
    what_do_you_wish_for = "何を望む？",
    wish_alias = {
      impossible = "だめよ。",
      new_alias = function(_1)
  return ("あなたの新しい異名は「%s」。満足したかしら？")
  :format(_1)
end,
      no_change = "あら、そのままでいいの？",
      what_is_your_new_alias = "新しい異名は？"
    },
    wish_death = "それがお望みなら…",
    wish_ehekatl = "「うみみゅみゅぁ！」",
    wish_man_inside = "中の人も大変ね。",
    wish_gold = "金貨が降ってきた！",
    wish_kumiromi = "工事中。",
    wish_lulwy = "「アタシを呼びつけるとは生意気ね。」",
    wish_god_inside = "中の神も大変…あ…中の神なんているわけないじゃない！…ねえ、聞かなかったことにしてね。",
    wish_mani = "工事中。",
    wish_opatos = "工事中。",
    wish_platinum = "プラチナ硬貨が降ってきた！",
    wish_redemption = {
      what_a_convenient_wish = "あら…都合のいいことを言うのね。",
      you_are_not_a_sinner = "…罪なんて犯してないじゃない。"
    },
    wish_sex = function(_1, _2)
  return ("%sは%sになった！ …もう後戻りはできないわよ。")
  :format(name(_1), _2)
end,
    wish_small_medal = "小さなメダルが降ってきた！",
    wish_youth = "ふぅん…そんな願いでいいんだ。",
    you_learn_skill = function(_1)
  return ("%sの技術を会得した！")
  :format(_1)
end,
    your_skill_improves = function(_1)
  return ("%sが上昇した！")
  :format(_1)
end,
    your_wish = function(_1)
  return ("%s！！")
  :format(_1)
end
  }
}
