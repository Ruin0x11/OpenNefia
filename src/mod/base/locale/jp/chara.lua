return {
  chara = {
    age_unknown = "不明",
    contract_expired = function(_1)
  return ("%sとの契約期間が切れた。")
  :format(basename(_1))
end,
    corruption = {
      add = "あなたはエーテルに侵食された。",
      remove = "あなたのエーテルの侵食はやわらいだ。",
      symptom = "エーテルの病が発症した。"
    },
    gain_level = {
      other = function(_1)
  return ("%sは成長した。")
  :format(name(_1))
end,
      self = function(_1, _2)
  return ("%sはレベル%sになった！")
  :format(name(_1), _2)
end
    },
    garbage = "残りカス",
    height = {
      gain = function(_1)
  return ("%sの身長は少し伸びた。")
  :format(name(_1))
end,
      lose = function(_1)
  return ("%sの身長は少し縮んだ。")
  :format(name(_1))
end
    },
    impression = {
      gain = function(_1, _2)
  return ("%sとの関係が<%s>になった！")
  :format(basename(_1), _2)
end,
      lose = function(_1, _2)
  return ("%sとの関係が<%s>になった…")
  :format(basename(_1), _2)
end
    },
    job = {
      alien = {
        alien_kid = "エイリアンの子供",
        child = "の子供",
        child_of = function(_1)
  return ("%sの子供")
  :format(_1)
end
      },
      baker = function(_1)
  return ("パン屋の%s")
  :format(_1)
end,
      blackmarket = function(_1)
  return ("ブラックマーケットの%s")
  :format(_1)
end,
      blacksmith = function(_1)
  return ("武具店の%s")
  :format(_1)
end,
      dye_vendor = function(_1)
  return ("染色店の%s")
  :format(_1)
end,
      fanatic = { "オパートスの信者", "マニの信者", "エヘカトルの信者" },
      fence = function(_1)
  return ("盗賊店の%s")
  :format(_1)
end,
      fisher = function(_1)
  return ("釣具店の%s")
  :format(_1)
end,
      food_vendor = function(_1)
  return ("食品店%s")
  :format(_1)
end,
      general_vendor = function(_1)
  return ("雑貨屋の%s")
  :format(_1)
end,
      goods_vendor = function(_1)
  return ("何でも屋の%s")
  :format(_1)
end,
      horse_master = function(_1)
  return ("馬屋の%s")
  :format(_1)
end,
      innkeeper = function(_1)
  return ("宿屋の%s")
  :format(_1)
end,
      magic_vendor = function(_1)
  return ("魔法店の%s")
  :format(_1)
end,
      of_derphy = function(_1)
  return ("ダルフィ%s")
  :format(_1)
end,
      of_lumiest = function(_1)
  return ("ルミエストの%s")
  :format(_1)
end,
      of_noyel = function(_1)
  return ("ノイエルの%s")
  :format(_1)
end,
      of_palmia = function(_1)
  return ("パルミア市街地の%s")
  :format(_1)
end,
      of_port_kapul = function(_1)
  return ("ポート・カプールの%s")
  :format(_1)
end,
      of_vernis = function(_1)
  return ("ヴェルニースの%s")
  :format(_1)
end,
      of_yowyn = function(_1)
  return ("ヨウィンの%s")
  :format(_1)
end,
      own_name = function(_1, _2)
  return ("%sの%s")
  :format(_1, _2)
end,
      shade = "シェイド",
      slave_master = "謎の奴隷商人",
      souvenir_vendor = function(_1)
  return ("おみやげ屋の%s")
  :format(_1)
end,
      spell_writer = function(_1)
  return ("魔法書作家の%s")
  :format(_1)
end,
      street_vendor = function(_1)
  return ("屋台商人の%s")
  :format(_1)
end,
      street_vendor2 = function(_1)
  return ("屋台商人屋の%s")
  :format(_1)
end,
      trader = function(_1)
  return ("交易店の%s")
  :format(_1)
end,
      trainer = function(_1)
  return ("ギルドの%s")
  :format(_1)
end,
      wandering_vendor = function(_1)
  return ("行商人の%s")
  :format(_1)
end
    },
    place_failure = {
      ally = function(_1)
  return ("%sとはぐれた。")
  :format(name(_1))
end,
      other = function(_1)
  return ("%sは何かに潰されて息絶えた。")
  :format(name(_1))
end
    },
    quality = {
      god = function(_1)
  return ("《%s》")
  :format(_1)
end,
      great = function(_1)
  return ("『%s』")
  :format(_1)
end
    },
    something = "何か",
    weight = {
      gain = function(_1)
  return ("%sは太った。")
  :format(name(_1))
end,
      lose = function(_1)
  return ("%sは痩せた。")
  :format(name(_1))
end
    },
    you = "あなた"
  }
}
