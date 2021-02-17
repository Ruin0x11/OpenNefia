return {
  ai = {
    ally = {
      sells_items = function(_1, _2, _3)
  return ("%sは%s個のアイテムを売りさばき%sgoldを稼いだ。")
  :format(name(_1), _2, _3)
end,
      visits_trainer = function(_1)
  return ("%sは訓練所に通い潜在能力を伸ばした！")
  :format(basename(_1))
end
    },
    crushes_wall = function(_1)
  return ("%sは壁を破壊した！")
  :format(name(_1))
end,
    fire_giant = { "「化け物め！」", "「くたばれっ」", "「退治してやるぅ！」", "「くらえー！」" },
    makes_snowman = function(_1, _2)
  return ("%sは%sを作った！")
  :format(name(_1), _2)
end,
    snail = { "「なめくじだ！」", "「殺す！」" },
    snowball = { " *クスクス* ", "「えいっ」", "「うりゃ」", "「くらえー！」", "「危ないっ！」", "「避けてー」" },
    swap = {
      displace = function(_1, _2)
  return ("%sは%sを押しのけた。")
  :format(name(_1), name(_2))
end,
      glare = function(_1, _2)
  return ("%sは%sを睨み付けた。")
  :format(name(_2), name(_1))
end
    }
  }
}
